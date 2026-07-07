-- pr_review.lua: worktree-based GitHub PR review commands.
-- Creates an isolated git worktree for each PR number so the main working tree
-- is never touched.  `:PRReview N` opens the review; `:PRReviewDone N` removes
-- the worktree and closes the review tab.
-- Mirrors the local M = {} / return M pattern of lua/fzf_ag.lua and lua/nr2bin.lua.

local M = {}

-- Run cmd (table of strings) synchronously.  opts forwarded to vim.system
-- (supported keys include { cwd = "..." }).
-- Returns stdout (string), stderr (string), exit code (integer).
local function run(cmd, opts)
  local result = vim.system(
    cmd,
    vim.tbl_extend("force", { text = true }, opts or {})
  ):wait()
  return result.stdout or "", result.stderr or "", result.code
end

-- Strip trailing whitespace / newlines (common on shell stdout).
local function trim(s)
  return (s:gsub("%s+$", ""))
end

-- Absolute path of the MAIN worktree (first entry of `git worktree list --porcelain`),
-- regardless of which linked worktree we're currently in. Returns nil on error.
local function main_root()
  local out, err, code = run({ "git", "worktree", "list", "--porcelain" })
  if code ~= 0 then
    vim.notify("pr_review: not inside a git repo: " .. trim(err), vim.log.levels.ERROR)
    return nil
  end
  local first = out:match("^worktree (.-)\n")
  if not first or first == "" then
    vim.notify("pr_review: could not determine main worktree", vim.log.levels.ERROR)
    return nil
  end
  return first
end

-- Compute the worktree directory for PR n.
-- Layout: <parent_of_repo>/.pr-review/<repo_name>/pr-<n>
-- Kept outside the repo so it never appears in git status / rg results.
local function worktree_dir(root, n)
  local parent = vim.fs.dirname(root)
  local name   = vim.fs.basename(root)
  return parent .. "/.pr-review/" .. name .. "/pr-" .. tostring(n)
end

-- Open a review for PR number n in an isolated git worktree.
function M.review(n)
  if not n then
    vim.notify("pr_review: usage: PRReview <number>", vim.log.levels.WARN)
    return
  end

  local root = main_root()
  if not root then return end

  local dir = worktree_dir(root, n)

  -- Create the worktree only if it does not already exist.
  local stat = vim.uv.fs_stat(dir)
  if stat then
    vim.notify(
      "pr_review: reusing existing worktree at " .. dir,
      vim.log.levels.INFO
    )
  else
    -- Start from a detached HEAD copy of the current repo state; gh pr checkout
    -- will then replace it with the PR branch.
    local _, err1, code1 = run({
      "git", "-C", root, "worktree", "add", "--detach", dir, "HEAD",
    })
    if code1 ~= 0 then
      vim.notify(
        "pr_review: git worktree add failed:\n" .. trim(err1),
        vim.log.levels.ERROR
      )
      return
    end

    -- gh pr checkout <n> fetches the PR branch and switches the worktree to it.
    -- cwd = dir so gh operates on the right worktree and finds the correct remote.
    local _, err2, code2 = run(
      { "gh", "pr", "checkout", tostring(n) },
      { cwd = dir, timeout = 120000 }
    )
    if code2 ~= 0 then
      -- Fallback for closed/merged PRs whose branch was deleted: the PR head still
      -- lives at refs/pull/<n>/head. Fetch it and detach onto it (read-only review).
      local _, ferr, fcode = run(
        { "git", "-C", dir, "fetch", "origin", ("refs/pull/%d/head"):format(n) },
        { timeout = 120000 }
      )
      if fcode ~= 0 then
        run({ "git", "-C", root, "worktree", "remove", "--force", dir })
        vim.notify(
          "pr_review: could not check out PR " .. n ..
          " (branch may be deleted and pull ref unavailable):\n" ..
          trim(err2) .. "\n" .. trim(ferr),
          vim.log.levels.ERROR
        )
        return
      end

      local _, cerr, ccode = run(
        { "git", "-C", dir, "checkout", "--detach", "FETCH_HEAD" }
      )
      if ccode ~= 0 then
        run({ "git", "-C", root, "worktree", "remove", "--force", dir })
        vim.notify(
          "pr_review: fetched pull/" .. n .. "/head but checkout --detach failed:\n" .. trim(cerr),
          vim.log.levels.ERROR
        )
        return
      end

      vim.notify(
        "pr_review: PR #" .. n .. " branch not available; reviewing pull/" .. n .. "/head (detached, read-only).",
        vim.log.levels.INFO
      )
    end
  end

  -- Determine the PR base branch so the diff is against the right upstream ref.
  local base_out, _, base_code = run(
    { "gh", "pr", "view", tostring(n), "--json", "baseRefName", "-q", ".baseRefName" },
    { cwd = dir, timeout = 30000 }
  )
  local base
  if base_code == 0 and trim(base_out) ~= "" then
    base = trim(base_out)
  else
    -- Fallback: try origin/HEAD → extract branch name, then guess "main".
    local head_out, _, head_code = run(
      { "git", "-C", dir, "rev-parse", "--abbrev-ref", "origin/HEAD" }
    )
    if head_code == 0 and trim(head_out) ~= "" then
      -- "origin/HEAD" → remove leading "origin/"
      base = trim(head_out):match("origin/(.+)") or "main"
    else
      base = "main"
    end
    vim.notify(
      "pr_review: could not resolve PR base via gh; falling back to '" .. base .. "'",
      vim.log.levels.WARN
    )
  end

  -- Open a new tab, pin its cwd to the worktree, then open the diff.
  -- --imply-local: makes the working-tree files the right-hand side of the diff
  -- so Neovim LSP attaches to real on-disk files (not to git blob objects).
  -- Triple-dot (origin/<base>...HEAD) computes the merge-base, so only PR-specific
  -- changes are shown (commits on origin/<base> after the branch point are excluded).
  vim.cmd("tabnew")
  vim.cmd("tcd " .. vim.fn.fnameescape(dir))
  vim.cmd("DiffviewOpen origin/" .. base .. "...HEAD --imply-local")
  vim.notify(
    string.format(
      "PR #%d  base: origin/%s  worktree: %s\nClose: :PRReviewDone %d  (or :DiffviewClose to keep the worktree)",
      n, base, dir, n
    ),
    vim.log.levels.INFO
  )
end

-- Remove the worktree for PR number n and close its review tab (if open).
function M.done(n)
  if not n then
    vim.notify("pr_review: usage: PRReviewDone <number>", vim.log.levels.WARN)
    return
  end

  local root = main_root()
  if not root then return end

  local dir = worktree_dir(root, n)

  -- Find and close any tab whose cwd is inside the worktree.
  -- Iterating all tabs handles the case where :PRReviewDone is called from a
  -- different tab than the review tab.
  for _, tabnr in ipairs(vim.api.nvim_list_tabpages()) do
    -- nvim_list_tabpages() yields tabpage HANDLES; getcwd(-1, ...) wants a tab NUMBER
    -- (position). Convert so lookup stays correct after any tab has been closed.
    local tab_cwd = vim.fn.getcwd(-1, vim.api.nvim_tabpage_get_number(tabnr))
    if vim.startswith(tab_cwd, dir) then
      vim.api.nvim_set_current_tabpage(tabnr)
      -- Move the tab-local cwd away from the worktree before removing it;
      -- otherwise git worktree remove will refuse (locked by the process).
      vim.cmd("tcd " .. vim.fn.fnameescape(root))
      -- Close the diffview panel if it is still open inside this tab.
      pcall(vim.cmd, "DiffviewClose")
      -- Close the tab itself.  pcall guards against "last tab" (E784).
      pcall(vim.cmd, "tabclose")
      break
    end
  end

  -- Remove the worktree from git's list (--force in case of untracked files).
  local _, err, code = run({
    "git", "-C", root, "worktree", "remove", "--force", dir,
  })
  if code ~= 0 then
    vim.notify(
      "pr_review: git worktree remove failed:\n" .. trim(err),
      vim.log.levels.ERROR
    )
    return
  end

  -- Prune stale worktree admin directories left by the removal.
  run({ "git", "-C", root, "worktree", "prune" })
  vim.notify("pr_review: PR #" .. n .. " worktree removed.", vim.log.levels.INFO)
end

-- Register :PRReview and :PRReviewDone as Neovim user commands.
-- Called from the diffview.nvim init() so the commands exist at startup,
-- before diffview itself is lazy-loaded.
function M.register()
  vim.api.nvim_create_user_command("PRReview", function(o)
    local n = tonumber(o.args)
    if not n then
      vim.notify(
        "pr_review: PRReview expected a numeric PR number, got: " .. o.args,
        vim.log.levels.WARN
      )
      return
    end
    M.review(n)
  end, { nargs = 1, desc = "Open PR #n for review in an isolated git worktree" })

  vim.api.nvim_create_user_command("PRReviewDone", function(o)
    local n = tonumber(o.args)
    if not n then
      vim.notify(
        "pr_review: PRReviewDone expected a numeric PR number, got: " .. o.args,
        vim.log.levels.WARN
      )
      return
    end
    M.done(n)
  end, { nargs = 1, desc = "Remove the review worktree for PR #n and close its tab" })
end

return M
