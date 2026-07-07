return {
  -- diffview.nvim: side-by-side diff viewer and file-history browser.
  -- init() registers :PRReview / :PRReviewClean at startup (before any lazy-load)
  -- so the commands are always available even before diffview itself loads.
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
    },
    opts = function()
      local actions = require("diffview.actions")
      local nav = {
        { "n", "<tab>",   false },  -- restore <C-i> (jumplist-forward) inside diffview
        { "n", "<s-tab>", false },  -- restore Shift-Tab
        { "n", "]f", actions.select_next_entry, { desc = "Next changed file" } },
        { "n", "[f", actions.select_prev_entry, { desc = "Prev changed file" } },
      }
      return {
        keymaps = {
          view               = nav,
          file_panel         = nav,
          file_history_panel = nav,
        },
      }
    end,
    init = function()
      require("pr_review").register()
    end,
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>",          desc = "Diff view (working tree)" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>",   desc = "Repo history" },
      { "<leader>gc", "<cmd>DiffviewClose<cr>",         desc = "Close diff view" },
    },
  },

  -- octo.nvim: GitHub PR/issue review inside Neovim via gh CLI.
  -- plenary.nvim is a new runtime dependency (not present elsewhere in this config).
  -- picker = "fzf-lua" routes list/search popups through fzf-lua, consistent with
  -- the rest of the config (ibhagwan/fzf-lua is already installed via lua/plugins/fzf.lua).
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "ibhagwan/fzf-lua",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "Octo",
    opts = { picker = "fzf-lua" },
    keys = {
      { "<leader>gp", "<cmd>Octo pr list<cr>",                                       desc = "PR list" },
      { "<leader>gi", "<cmd>Octo issue list<cr>",                                    desc = "Issue list" },
      { "<leader>gP", function() require("gh_pr_picker").tagged() end,            desc = "Review PRs (Slack queue; <C-t> repo)" },
    },
  },
}
