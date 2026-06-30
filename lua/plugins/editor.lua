return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      -- show jump labels on f/F/t/T so you can pick any match (not just the next)
      modes = { char = { jump_labels = true } },
    },
    -- s = flash jump (type chars -> labels -> teleport). Safe with vim-surround
    -- (ys/cs/ds + visual S are unaffected); only replaces vanilla s=substitute (use cl).
    keys = {
      { "s", function() require("flash").jump() end, mode = { "n", "x", "o" }, desc = "Flash jump" },
    },
  },
  { "kevinhwang91/nvim-ufo", dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    init = function() vim.o.foldlevel = 99; vim.o.foldlevelstart = 99; vim.o.foldenable = true end,
    opts = {
      -- treesitter + indent fold providers (no LSP attach required); fixes python folding
      provider_selector = function() return { "treesitter", "indent" } end,
    } },
  { "tpope/vim-surround", dependencies = { "tpope/vim-repeat" }, event = "VeryLazy" },
  { "tpope/vim-unimpaired", event = "VeryLazy" },
  { "echasnovski/mini.align", version = false, event = "VeryLazy", opts = {} },  -- gA operator (replaces tabular)
  { "tpope/vim-fugitive", cmd = { "Git", "G", "Gdiffsplit", "Gblame" },
    keys = { { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" } } },
  { "idanarye/vim-merginal", dependencies = { "tpope/vim-fugitive" }, cmd = { "Merginal" } },
  { "lervag/vimtex", ft = "tex",
    init = function()
      vim.g.vimtex_view_method = "zathura"
    end,
    config = function()
      -- `I → \item  via vimtex#imaps#add_map (leader=backtick by default; wrap_trivial = always rhs).
      -- Stored in s:custom_maps; applied by vimtex#imaps#init_buffer() on each tex buffer open.
      -- Do NOT use a literal `imap I` (fires on every capital-I). See :help g:vimtex_imaps_leader.
      vim.fn["vimtex#imaps#add_map"]({ lhs = "I", rhs = "\\item ", wrapper = "vimtex#imaps#wrap_trivial" })
      local function tex_imaps(buf)
        local opts = { buffer = buf }
        vim.keymap.set("i", "<C-b>", "\\begin{}<Left>", opts)
        vim.keymap.set("i", "<C-e>", "\\emph{}<Left>", opts)
        vim.keymap.set("i", "<C-f>", "\\textbf{}<Left>", opts)
      end
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "tex",
        callback = function(ev) tex_imaps(ev.buf) end,
      })
      -- vimtex is ft-loaded, so the triggering buffer's FileType already fired before
      -- this config ran; apply to it directly so the first tex buffer also gets the maps.
      if vim.bo.filetype == "tex" then tex_imaps(0) end
    end },
  { "mbbill/undotree", cmd = "UndotreeToggle",
    keys = { { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undotree toggle" } },
    init = function() vim.api.nvim_create_user_command("Undo", "UndotreeToggle", {}) end },
  { "iamcco/markdown-preview.nvim", ft = "markdown",
    build = "cd app && npx --yes yarn install",
    init = function() vim.g.mkdp_filetypes = { "markdown" } end },
  { "rhysd/vim-grammarous", cmd = { "GrammarousCheck" } },
  { "jmcantrell/vim-virtualenv", ft = "python" },
}
