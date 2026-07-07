-- gh_pr_picker.lua: fzf-lua pickers for GitHub PRs. Exposes two entry points:
-- by_author (sourced from `gh pr list`, filterable by author) and tagged
-- (sourced from the slack-review-query Slack-queue CLI).
-- Mirrors the local M = {} / return M pattern of lua/fzf_ag.lua and lua/nr2bin.lua.

local M = {}

-- Shell command that lists open PRs, one per line:
--   <number>  @<author>  <title>
-- Number is first so fzf's default whitespace fielding gives {1} = PR number
-- (used by the preview command and by parse_number), while fuzzy search covers
-- the whole line so author and title are both searchable.
local function pr_list_cmd()
  return table.concat({
    "gh pr list --state open --limit 200",
    "--json number,title,author",
    [[--jq '.[] | "\(.number)  @\(.author.login)  \(.title)"']],
  }, " ")
end

-- Extract the PR number from a picker line.
-- Line format: "<number>  @<author>  <title>" — the number is always first.
local function parse_number(line)
  return line and line:match("^(%d+)")
end

-- Open an fzf-lua picker listing open PRs.
-- <CR>     → open selected PR in an octo buffer (:Octo pr edit <n>)
-- <C-r>    → open selected PR in an isolated git worktree (:PRReview <n>)
function M.by_author()
  local fzf = require("fzf-lua")
  fzf.fzf_exec(pr_list_cmd(), {
    prompt = "PRs> ",
    -- Default fzf whitespace fielding: {1} = PR number, search covers the whole line
    -- (author and title are both fuzzy-searchable with no extra fzf_opts needed).
    -- gh pr view's default rendered view hard-fails in this gh version (the classic
    -- Projects deprecation is now a fatal GraphQL error), so render from --json via jq:
    -- title / #number / state / author / body. {1} = the raw PR number.
    -- Lua long-bracket string keeps the jq single quotes and \( \n escapes literal.
    preview = [[gh pr view {1} --json number,title,author,state,body --jq '"\(.title)  #\(.number)  ·  \(.state)\nby @\(.author.login)\n\n\(.body)"']],
    actions = {
      -- default (Enter): open the PR in an octo buffer for inline review/commenting.
      ["default"] = function(selected)
        local n = parse_number(selected and selected[1])
        if n then vim.cmd("Octo pr edit " .. n) end
      end,
      -- ctrl-r: open the PR in an isolated git worktree via pr_review.lua.
      ["ctrl-r"] = function(selected)
        local n = parse_number(selected and selected[1])
        if n then require("pr_review").review(tonumber(n)) end
      end,
      -- ctrl-t: toggle to the tagged (Slack-queue) picker.
      ["ctrl-t"] = function() M.tagged() end,
    },
  })
end

-- True if the slack-review-query CLI (the Slack-queue poller) is on PATH.
local function has_query()
  return vim.fn.executable("slack-review-query") == 1
end

-- Extract the PR URL from a picker line.
-- Line format: "<url>\t<display>" — the URL is always first and contains no
-- spaces, so a leading-non-space match is sufficient (unlike parse_number,
-- fzf hands us the whole tab-delimited line here, not just the display half).
local function parse_url(line)
  return line and line:match("^(%S+)")
end

-- Open an fzf-lua picker listing PRs tagged for review via Slack (sourced
-- from the slack-review-query CLI). Each line is "<url>\t<display>"; the
-- display half (the Rich-rendered ANSI text) is shown while the URL stays
-- hidden, and the URL drives both the preview and the actions below.
-- <CR>     → open selected PR in an octo buffer, by URL (cross-repo-correct)
-- <C-r>    → open selected PR in an isolated git worktree (:PRReview <n>)
--            NOTE: pr_review.review() operates on the current repo, so this
--            is only correct when nvim is inside the PR's own repo.
function M.tagged()
  if not has_query() then
    vim.notify("slack-review-query not found (install the poller)", vim.log.levels.WARN)
    return
  end
  local fzf = require("fzf-lua")
  fzf.fzf_exec("slack-review-query", {
    prompt = "Review PRs> ",
    fzf_opts = {
      ["--delimiter"] = "\t",
      ["--with-nth"] = "2..", -- hide field 1 (the URL) from the list
      ["--ansi"] = true, -- render the Rich ANSI preview
    },
    preview = "slack-review-query --preview {1}",
    actions = {
      -- default (Enter): open the PR in an octo buffer by URL (cross-repo-correct).
      ["default"] = function(selected)
        local url = parse_url(selected and selected[1])
        if url then vim.cmd("Octo " .. url) end
      end,
      -- ctrl-r: run :PRReview on the PR number parsed from the URL (same-repo
      -- assumption — pr_review.review operates on the current repo).
      ["ctrl-r"] = function(selected)
        local url = parse_url(selected and selected[1])
        local n = url and url:match("/pull/(%d+)")
        if n then require("pr_review").review(tonumber(n)) end
      end,
      -- ctrl-t: toggle to the by-author (repo) picker.
      ["ctrl-t"] = function() M.by_author() end,
    },
  })
end

return M
