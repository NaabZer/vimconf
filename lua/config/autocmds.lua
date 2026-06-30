-- Global + per-filetype autocmds.

local global_augroup = vim.api.nvim_create_augroup("GlobalAutocmds", { clear = true })

local function ftset(pat, fn)
  vim.api.nvim_create_autocmd("FileType", { group = global_augroup, pattern = pat, callback = fn })
end

ftset("make", function() vim.bo.expandtab = false end)

ftset("tex", function()
  vim.opt_local.linebreak = true
  vim.opt_local.wrap = false
  vim.opt_local.textwidth = 80
  vim.opt_local.conceallevel = 0
end)

ftset({ "html", "javascript", "javascriptreact", "typescriptreact" }, function()
  vim.opt_local.shiftwidth = 2
  vim.opt_local.softtabstop = 2
  vim.opt_local.tabstop = 2
end)

ftset("python", function()
  if vim.env.VIRTUAL_ENV then
    vim.opt_local.tags:append(vim.env.VIRTUAL_ENV .. "/tags")
  end
end)

-- Marker folds for vimscript config files (ufo manages folds elsewhere).
ftset("vim", function()
  vim.opt_local.foldmethod = "marker"
  vim.opt_local.foldlevel = 0
end)

-- tex skeleton template (templates/skeleton.tex is kept in the repo).
vim.api.nvim_create_autocmd("BufNewFile", {
  group = global_augroup,
  pattern = "*.tex",
  command = "0r " .. vim.fn.stdpath("config") .. "/templates/skeleton.tex",
})
