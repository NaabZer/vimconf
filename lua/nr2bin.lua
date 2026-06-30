-- nr2bin.lua: <leader>h utility — echo the binary representation of the number
-- under a motion or visual selection (port of NrToBinaryWithMovement + Nr2Bin).
-- operatorfunc module, mirroring lua/fzf_ag.lua.

local M = {}

local function nr2bin(nr)
  local n = tonumber(nr)
  if not n then return tostring(nr) end
  n = math.floor(n)
  if n == 0 then return "0" end
  local neg = n < 0
  n = math.abs(n)
  local r = ""
  while n > 0 do
    r = (n % 2) .. r
    n = math.floor(n / 2)
  end
  return (neg and "-" or "") .. r
end

-- operatorfunc target: yank the motion/visual range, echo its binary value, then
-- restore the unnamed register (contents + type) so the yank is non-destructive.
function M.opfunc(motion_type)
  local saved = vim.fn.getreg('"')
  local saved_type = vim.fn.getregtype('"')
  if motion_type == "char" then
    vim.cmd("normal! `[v`]y")
  elseif motion_type == "line" then
    vim.cmd("normal! `[V`]y")
  elseif motion_type == "v" then
    vim.cmd("normal! `<v`>y")
  elseif motion_type == "V" then
    vim.cmd("normal! `<V`>y")
  else
    vim.fn.setreg('"', saved, saved_type)
    return
  end
  local text = vim.fn.getreg('"')
  vim.fn.setreg('"', saved, saved_type)
  vim.notify(nr2bin(text))
end

return M
