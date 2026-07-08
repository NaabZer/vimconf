return {
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    {
        "saghen/blink.cmp",
        version = "1.*", -- PIN v1: v2 needs a separate blink.lib plugin (see lsp.lua); v1 ships the prebuilt fuzzy binary
        event = "InsertEnter",
        opts = {
            keymap = { preset = "default" }, -- <C-n>/<C-p> navigate, <C-y> accept, <C-space> show; <CR> stays a literal newline
            sources = {
                default = { "lazydev", "lsp", "path", "snippets", "buffer" },
                providers = {
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        -- make lazydev completions top priority (see `:h blink.cmp`)
                        score_offset = 100,
                    },
                },
            },
            completion = {
                menu = { auto_show = true },
                documentation = { auto_show = true, auto_show_delay_ms = 200 },
                ghost_text = { enabled = false },
                list = {
                    selection = { preselect = false },
                },
            },
            signature = { enabled = true },
        },
        opts_extend = { "sources.default" },
    },
}
