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
          "Folded", "FoldColumn", "NonText",
          "TroubleNormal", "TroubleNormalNC",
        }) do
          vim.api.nvim_set_hl(0, g, { bg = "none" })
        end
      end

      -- Treesitter contrast: base16-apathy paints @variable/@variable.builtin with base08
      -- (a dark teal, low-contrast and close to keywords). The old Vim (no treesitter) rendered
      -- plain identifiers as Normal/base05. Restore the light base05 for them.
      local function ts_contrast()
        local colors = require("base16-colorscheme").colors
        if not colors then return end
        vim.api.nvim_set_hl(0, "@variable", { fg = colors.base05 })
        vim.api.nvim_set_hl(0, "@variable.builtin", { fg = colors.base05 })
      end

      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          transparent()
          ts_contrast()
        end,
      })
      transparent()
      ts_contrast()
    end,
  },
}
