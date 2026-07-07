-- gh_pr_picker.lua: fzf-lua picker for GitHub PRs, filterable by author.
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
    },
  })
end

return M
