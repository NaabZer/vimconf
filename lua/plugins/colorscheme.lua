return {
  {
    "RRethy/base16-nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("base16-apathy")

      -- Terminal-background transparency (replaces the CSApprox_hook_post block)
      local function transparent()
        for _, g in ipairs({
          "Normal", "NormalNC", "SignColumn", "LineNr",
          "CursorLine", "CursorLineNr", "Folded", "FoldColumn", "NonText",
        }) do
          vim.api.nvim_set_hl(0, g, { bg = "none" })
        end
      end

      vim.api.nvim_create_autocmd("ColorScheme", { callback = transparent })
      transparent()
    end,
  },
}
