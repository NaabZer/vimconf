return {
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        config = true,
        -- `cmd` lets lazy.nvim create command stubs that load the plugin on first use,
        -- so `:ClaudeCode` and friends work on a fresh start. Without it, a keys-only
        -- spec defers loading until a <leader>a* mapping is pressed and the commands
        -- would not exist yet.
        cmd = {
            "ClaudeCode",
            "ClaudeCodeFocus",
            "ClaudeCodeSelectModel",
            "ClaudeCodeAdd",
            "ClaudeCodeSend",
            "ClaudeCodeTreeAdd",
            "ClaudeCodeStatus",
            "ClaudeCodeStart",
            "ClaudeCodeStop",
            "ClaudeCodeOpen",
            "ClaudeCodeClose",
            "ClaudeCodeDiffAccept",
            "ClaudeCodeDiffDeny",
            "ClaudeCodeCloseAllDiffs",
        },
        keys = {
            { "<leader>c",  nil,                              desc = "AI/Claude Code" },
            { "<leader>cc", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
            { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
            { "<leader>cr", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
            { "<leader>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
            { "<leader>cm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
            { "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
            { "<leader>cs", "<cmd>ClaudeCodeSend<cr>",        mode = "v",                  desc = "Send to Claude" },
            {
                "<leader>cs",
                "<cmd>ClaudeCodeTreeAdd<cr>",
                desc = "Add file",
                ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw", "snacks_picker_list" },
            },
            -- Diff management
            { "<leader>ca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
            { "<leader>cd", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny diff" },
        },
    },
    {
        --dir = "~/develop/nvim-claude-assistant",
        dir = "~/develop/nvim-claude-assistant/.claude/worktrees/command-expansions/",
        dependencies = {
            { "coder/claudecode.nvim" },
        },
        -- Load when you first reach for it (any command or the default keymaps).
        cmd = { "ClaudeAssistantReview", "ClaudeAssistantExplain", "ClaudeAssistantPaste" },
        keys = {
            { "<leader>cr", mode = { "n", "x" } },
            { "<leader>ce", mode = { "n", "x" } },
            { "<leader>cp", mode = { "n", "x" } },
        },
        opts = {
            keymaps = { enable = true },            -- installs <leader>cr / ce / cp in normal + visual
            manage_claudecode = false,              -- plugin calls claudecode.setup() with the role injected
            claudecode = {
                terminal = { provider = "native" }, -- you don't have snacks; native is the pane
            },
            -- role_prompt = "You are a terse, strict reviewer.",  -- optional override
        },
    },
}
