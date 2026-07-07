-- pr_review.lua: worktree-based GitHub PR review commands.
-- Creates an isolated git worktree for each PR number so the main working tree
-- is never touched.  `:PRReview N` opens the review; close with <leader>gc
-- (:DiffviewClose).  `:PRReviewClean` removes worktrees whose diffview is
-- already closed.  Worktrees are also pruned automatically on VimLeavePre.
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

-- True if `path` is `dir` itself or a file/dir strictly inside it. The trailing-slash
-- form avoids matching sibling worktrees whose number shares a numeric prefix
-- (pr-5 must NOT match pr-51/...).
local function path_inside(path, dir)
  return path == dir or vim.startswith(path, dir .. "/")
end

-- Absolute paths of all PR-review worktrees for the current repo (parsed from
-- `git worktree list --porcelain`). These live under `<parent>/.pr-review/<repo>/pr-<n>`.
local function pr_review_worktrees()
  local out, _, code = run({ "git", "worktree", "list", "--porcelain" })
  if code ~= 0 then return {} end
  local list = {}
  for wt in out:gmatch("worktree (.-)\n") do
    if wt:match("/%.pr%-review/[^/]+/pr%-%d+$") then
      list[#list + 1] = wt
    end
  end
  return list
end

-- Is any live diffview view attached to a tab whose cwd is inside `wt`?
-- Uses diffview's lib (tabpage_to_view). If diffview isn't loaded, nothing is live.
local function worktree_has_live_diffview(wt)
  local ok, lib = pcall(require, "diffview.lib")
  if not (ok and lib and lib.tabpage_to_view) then return false end
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local cwd = vim.fn.getcwd(-1, vim.api.nvim_tabpage_get_number(tab))
    if path_inside(cwd, wt) and lib.tabpage_to_view(tab) then
      return true
    end
  end
  return false
end

-- Move any tab cwd'd inside `wt` back to `root`, and wipe any buffer whose path is
-- inside `wt`, so nothing references the directory when git removes it.
local function detach_worktree(wt, root)
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local cwd = vim.fn.getcwd(-1, vim.api.nvim_tabpage_get_number(tab))
    if path_inside(cwd, wt) then
      vim.api.nvim_set_current_tabpage(tab)
      vim.cmd("tcd " .. vim.fn.fnameescape(root))
    end
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if name ~= "" and path_inside(name, wt) then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
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

  -- Refresh the base branch so the merge-base matches GitHub's. gh pr checkout
  -- only fetches the PR branch, so the local origin/<base> ref may be stale; a
  -- stale base makes the three-dot merge-base land too far back and pulls in
  -- commits from OTHER PRs already merged into the base. Best-effort: on failure
  -- we warn and diff against whatever origin/<base> currently points to.
  local _, ferr, fcode = run(
    { "git", "-C", dir, "fetch", "origin", base },
    { timeout = 60000 }
  )
  if fcode ~= 0 then
    vim.notify(
      "pr_review: could not fetch origin/" .. base ..
      " (diff may include changes from other merged PRs):\n" .. trim(ferr),
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
      "pr_review: PR #%d  base: origin/%s  worktree: %s\nClose: <leader>gc (:DiffviewClose), then :PRReviewClean to remove the worktree.",
      n, base, dir
    ),
    vim.log.levels.INFO
  )
end

-- Remove PR-review worktrees that have no live diffview open on them. Worktrees
-- whose diffview is still open are skipped (close them with <leader>gc first).
function M.clean()
  local root = main_root()
  if not root then return end
  -- Restore the tab the user invoked :PRReviewClean from, since detach_worktree
  -- calls nvim_set_current_tabpage to tcd each worktree tab back to root.
  local cur_tab = vim.api.nvim_get_current_tabpage()
  local removed, skipped = 0, 0
  for _, wt in ipairs(pr_review_worktrees()) do
    if worktree_has_live_diffview(wt) then
      skipped = skipped + 1
    else
      detach_worktree(wt, root)
      local _, err, code = run({ "git", "-C", root, "worktree", "remove", "--force", wt })
      if code == 0 then
        removed = removed + 1
      else
        vim.notify("pr_review: could not remove " .. wt .. ":\n" .. trim(err), vim.log.levels.WARN)
      end
    end
  end
  run({ "git", "-C", root, "worktree", "prune" })
  if vim.api.nvim_tabpage_is_valid(cur_tab) then
    vim.api.nvim_set_current_tabpage(cur_tab)
  end
  vim.notify(
    string.format("pr_review: cleaned %d worktree(s)%s.", removed,
      skipped > 0 and (", skipped " .. skipped .. " (diffview still open)") or ""),
    vim.log.levels.INFO
  )
end

-- Remove ALL PR-review worktrees for the current repo. Called on VimLeavePre —
-- nvim is exiting, so there is no diffview async to collide with; no tab/buffer
-- teardown is needed.
function M.clean_all()
  local root = main_root()
  if not root then return end
  for _, wt in ipairs(pr_review_worktrees()) do
    run({ "git", "-C", root, "worktree", "remove", "--force", wt })
  end
  run({ "git", "-C", root, "worktree", "prune" })
end

-- Register :PRReview and :PRReviewClean as Neovim user commands, and wire up
-- VimLeavePre auto-cleanup. Called from the diffview.nvim init() so the commands
-- exist at startup, before diffview itself is lazy-loaded.
function M.register()
  vim.api.nvim_create_user_command("PRReview", function(o)
    local n = tonumber(o.args)
    if not n then
      vim.notify("pr_review: PRReview expected a numeric PR number, got: " .. o.args, vim.log.levels.WARN)
      return
    end
    M.review(n)
  end, { nargs = 1, desc = "Open PR #n for review in an isolated git worktree" })

  vim.api.nvim_create_user_command("PRReviewClean", function()
    M.clean()
  end, { desc = "Remove PR-review worktrees with no open diffview" })

  -- Auto-clean all PR-review worktrees on exit (safe: nvim is quitting).
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("PrReviewCleanup", { clear = true }),
    callback = function()
      pcall(M.clean_all)
    end,
  })
end

return M
