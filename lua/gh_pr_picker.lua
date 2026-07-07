-- gh_pr_picker.lua: fzf-lua picker for GitHub PRs, filterable by author.
-- Mirrors the local M = {} / return M pattern of lua/fzf_ag.lua and lua/nr2bin.lua.

local M = {}

-- Shell command that lists open PRs as space-separated columns:
--   #<num>  @<author>  <title>
-- Space format (no --delimiter/--with-nth fzf opts needed) keeps the entry
-- inline and author fuzzy-filterable as a plain substring of the line.
local function pr_list_cmd()
  return table.concat({
    "gh pr list --state open --limit 200",
    "--json number,title,author",
    [[--jq '.[] | "#\(.number)  @\(.author.login)  \(.title)"']],
  }, " ")
end

-- Extract the PR number from a picker line like "#123  @author  Title".
local function parse_number(line)
  return line and line:match("^#(%d+)")
end

-- Open an fzf-lua picker listing open PRs.
-- <CR>     → open selected PR in an octo buffer (:Octo pr edit <n>)
-- <C-r>    → open selected PR in an isolated git worktree (:PRReview <n>)
function M.by_author()
  local fzf = require("fzf-lua")
  fzf.fzf_exec(pr_list_cmd(), {
    prompt = "PRs> ",
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
