return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "base16",  -- integrates with the RRethy/nvim-base16 colorscheme (confirmed in lualine themes/)
        globalstatus = false,
        section_separators = "",
        component_separators = "|",
      },
      sections = {
        -- Reproduce the old airline section_z: Lnnr() = line('.')/line('$')
        lualine_z = {
          function()
            return ("%d/%d"):format(vim.fn.line("."), vim.fn.line("$"))
          end,
        },
      },
      tabline = {
        lualine_a = {
          {
            "tabs",
            mode = 2,  -- mode 2: show tab number + file name (replaces airline tabline)
          },
        },
      },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {
      -- Replaces signify: green add (+), yellow change (~), red delete (_).
      -- Transparent sign column bg is handled by the colorscheme override in colorscheme.lua.
      signs = {
        add          = { text = "+" },
        change       = { text = "~" },
        delete       = { text = "_" },
      },
    },
  },

  {
    "echasnovski/mini.files",
    version = false,
    keys = {
      {
        "<leader>n",
        function()
          local mf = require("mini.files")
          -- Toggle: close() returns nil (nothing open) or false (user declined) → open.
          -- close() returns true on successful close → don't reopen.
          -- Replaces NERDTreeTabsToggle; auto-open-on-empty is intentionally not reproduced.
          if not mf.close() then
            mf.open(vim.api.nvim_buf_get_name(0), false)
          end
        end,
        desc = "Files (toggle)",
      },
    },
    opts = {},
    config = function(_, opts)
      local mf = require("mini.files")

      -- Hide dotfiles by default; toggle with `g.` inside the explorer.
      local show_dotfiles = false
      local filter_show = function() return true end
      local filter_hide = function(entry) return not vim.startswith(entry.name, ".") end
      local function dotfiles_filter() return show_dotfiles and filter_show or filter_hide end
      local function toggle_dotfiles()
        show_dotfiles = not show_dotfiles
        mf.refresh({ content = { filter = dotfiles_filter() } })
      end
      opts.content = opts.content or {}
      opts.content.filter = filter_hide
      mf.setup(opts)

      -- Open the entry under the cursor in a split / vsplit / new tab, then close the explorer.
      -- Mirrors fzf-lua's split actions (<C-s>/<C-v>/<C-t>).
      local function open_in(direction)
        return function()
          local target = mf.get_explorer_state().target_window
          if target == nil then return end
          local new_win = vim.api.nvim_win_call(target, function()
            vim.cmd(direction)
            return vim.api.nvim_get_current_win()
          end)
          mf.set_target_window(new_win)
          mf.go_in({ close_on_file = true })
        end
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf = args.data.buf_id
          vim.keymap.set("n", "<C-s>", open_in("belowright split"),  { buffer = buf, desc = "Open in horizontal split" })
          vim.keymap.set("n", "<C-v>", open_in("belowright vsplit"), { buffer = buf, desc = "Open in vertical split" })
          vim.keymap.set("n", "<C-t>", open_in("tab split"),         { buffer = buf, desc = "Open in new tab" })
          vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf, desc = "Toggle hidden files" })
        end,
      })
    end,
  },

  {
    "stevearc/aerial.nvim",
    -- Replaces tagbar (<leader>b = TagbarToggle).
    keys = {
      { "<leader>b", "<cmd>AerialToggle<cr>", desc = "Symbols outline" },
    },
    opts = {
      backends = { "lsp", "treesitter" },
      show_guides = true,
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufReadPost",
    opts = {
      -- Replaces indentLine; exclude same filetypes to keep conceallevel sane.
      exclude = {
        filetypes = { "json", "tex", "markdown", "help" },
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = { delay = 4000 },  -- plain number accepted: number|fun(ctx) (config.lua types); 4 s prevents flash during normal use
  },

  {
    "folke/trouble.nvim",
    -- v3 API: cmd = "Trouble", command syntax "Trouble diagnostics toggle" (confirmed in README).
    -- v2 used "TroubleToggle" — not applicable here.
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
    },
    init = function()
      -- Trouble loads after the colorscheme's startup transparency pass and re-links
      -- TroubleNormal/TroubleNormalNC to NormalFloat (which has a bg). Re-clear them
      -- whenever a trouble window opens so the panel is transparent like the editor.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "trouble",  -- confirmed: trouble.nvim sets bo.filetype = "trouble" in view/window.lua
        callback = function()
          vim.api.nvim_set_hl(0, "TroubleNormal", { bg = "none" })
          vim.api.nvim_set_hl(0, "TroubleNormalNC", { bg = "none" })
        end,
      })
    end,
  },
}
