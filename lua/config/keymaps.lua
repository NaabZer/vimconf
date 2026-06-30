local map = vim.keymap.set

-- Clear search highlight
map("n", "<leader><space>", "<cmd>noh<cr>")

-- Window navigation (replaces <C-w> dance)
map("n", "<C-h>", "<C-w>h")
map("n", "<C-l>", "<C-w>l")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")

-- Split resize
map("n", "<C-Up>",    "<cmd>resize +2<cr>")
map("n", "<C-Down>",  "<cmd>resize -2<cr>")
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>")
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>")

-- Diagnostics: ]d/[d (all severities) are Neovim defaults; ]e/[e jump errors only.
local function diag_jump_error(count)
  return function()
    vim.diagnostic.jump({ count = count, severity = vim.diagnostic.severity.ERROR })
  end
end
map("n", "]e", diag_jump_error(1),  { desc = "Next error" })
map("n", "[e", diag_jump_error(-1), { desc = "Prev error" })

-- Commenting: gc/gcc are built into Neovim (>=0.10) — no plugin needed.

-- Nr2Bin / <leader>h: echo the binary representation of the number under a motion or
-- visual selection (the "fun" utility). Logic in lua/nr2bin.lua (operatorfunc module).
map("n", "<leader>h", function()
  vim.o.operatorfunc = "v:lua.require'nr2bin'.opfunc"
  return "g@"
end, { expr = true, desc = "Echo binary of number (motion)" })
map("x", "<leader>h", function()
  require("nr2bin").opfunc(vim.fn.visualmode())
end, { desc = "Echo binary of number (selection)" })
