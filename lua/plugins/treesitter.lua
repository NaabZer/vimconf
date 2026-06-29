return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        "c", "cpp", "c_sharp", "lua", "vim", "vimdoc", "query", "rust", "go", "python",
        "javascript", "tsx", "typescript", "html", "css", "json", "yaml", "toml",  -- NOTE: no "jsx" parser; JSX is handled by javascript/tsx
        "markdown", "markdown_inline", "bash", "latex", "bibtex",
      },
      sync_install = false,
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
}
