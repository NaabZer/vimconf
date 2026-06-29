-- Global autocmds
-- Per-filetype autocmds and the tex skeleton template are deferred to a later commit.

-- Shared augroup for global (non-filetype) autocmds; later commits attach via `group = global_augroup`.
local global_augroup = vim.api.nvim_create_augroup("GlobalAutocmds", { clear = true })

-- Suppress "unused local" until the first autocmd is added in a later commit.
local _ = global_augroup
