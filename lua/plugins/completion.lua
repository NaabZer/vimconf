return {
  {
    "saghen/blink.cmp",
    version = "1.*",  -- PIN v1: v2 needs a separate blink.lib plugin (see lsp.lua); v1 ships the prebuilt fuzzy binary
    event = "InsertEnter",
    opts = {
      keymap = { preset = "default" },  -- <C-n>/<C-p> navigate, <C-y> accept, <C-space> show; <CR> stays a literal newline
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      completion = {
        menu = { auto_show = true },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        ghost_text = { enabled = false },
      },
      signature = { enabled = true },
    },
    opts_extend = { "sources.default" },
  },
}
