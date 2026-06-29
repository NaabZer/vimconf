return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = {
      formatters_by_ft = { rust = { "rustfmt" }, go = { "gofmt" } },
      format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
    },
  },
}
