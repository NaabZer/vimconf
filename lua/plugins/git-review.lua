return {
  -- diffview.nvim: side-by-side diff viewer and file-history browser.
  -- init() registers :PRReview/:PRReviewDone at startup (before any lazy-load)
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
    opts = {},
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
      { "<leader>gP", function() require("gh_pr_picker").by_author() end,            desc = "PRs by author (fzf)" },
    },
  },
}
