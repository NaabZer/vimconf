-- fzf_ag.lua: operator-motion helper for <leader>a grep (replaces AgWithMovement)
-- Registered as operatorfunc so it is called by Neovim after a motion completes.
-- Visual-mode <leader>a goes directly to fzf.grep_visual() (see lua/plugins/fzf.lua).

local M = {}

-- operatorfunc target: yank the motion range into the unnamed register, grep for it,
-- then restore the register so the yank is non-destructive.
-- Mirrors old AgWithMovement: normal! `[v`]y  →  :Ag <yanked text>
function M.grep_motion(motion_type)
  local saved = vim.fn.getreg('"')
  local saved_type = vim.fn.getregtype('"')
  if motion_type == "char" then
    vim.cmd("normal! `[v`]y")
  elseif motion_type == "line" then
    vim.cmd("normal! `[V`]y")
  else
    -- block motions not supported; restore and bail
    vim.fn.setreg('"', saved, saved_type)
    return
  end
  local text = vim.fn.getreg('"')
  vim.fn.setreg('"', saved, saved_type)
  require("fzf-lua").grep({ search = text })
end

return M
