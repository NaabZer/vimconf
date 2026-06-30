return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local fzf = require("fzf-lua")
      fzf.setup({
        "default",
        winopts = { preview = { layout = "vertical" } },
        -- The global CursorLine highlight has bg="none" (set by colorscheme.lua for
        -- editor transparency). FzfLuaCursorLine links to CursorLine by default, so
        -- the builtin previewer's cursorline (which marks the reference line) becomes
        -- invisible. Override hls.cursorline to a group that always has a visible bg,
        -- so the matched/reference line stands out in the preview without un-transparenting
        -- the main editor's CursorLine.
        hls = { cursorline = "Visual" },
        -- Remap send-selected-to-quickfix from <Alt-q> to <C-q>.
        -- i3 binds Alt-q to close the window, so <Alt-q> never reaches Neovim
        -- (it kills the terminal instead). <C-q> is also the historical fzf.vim
        -- quickfix key. Setting ["alt-q"]=false removes it from the --expect
        -- list (fzf-lua's actions.expect() skips falsy values).
        -- This table is deep-merged with the defaults by fzf-lua's setup, so
        -- ctrl-s / ctrl-v / ctrl-t / enter are all preserved. All LSP pickers
        -- (including lsp_references used by gr) inherit actions.files via
        -- _actions = function() return M.globals.actions.files end.
        actions = {
          files = {
            -- [1]=true tells fzf-lua's build_bind_tables to deep-merge with the
            -- static defaults (enter/ctrl-s/ctrl-v/ctrl-t/alt-i/alt-h/alt-f).
            -- Without this flag the user table REPLACES defaults entirely.
            [1]        = true,
            ["ctrl-q"] = require("fzf-lua.actions").file_sel_to_qf,
            ["alt-q"]  = false,  -- remove: i3 binds Alt-q to close the window
          },
        },
      })

      -- gr: LSP references picker (headline workflow)
      -- Preview is centered on the match line (fzf-lua's builtin previewer).
      -- <CR> on a single result jumps directly; multi-select + <C-q> sends to quickfix.
      -- jump1=false: always show the picker even for a single result (mirrors old LspFzf
      -- behaviour where the fzf window always opened).
      -- includeDeclaration=true: pass context.includeDeclaration to the LSP request (top-level
      -- option, confirmed in fzf-lua sources — fzf-lua reads opts.includeDeclaration and
      -- injects it into params.context).
      vim.keymap.set("n", "gr", function()
        fzf.lsp_references({ jump1 = false, includeDeclaration = true })
      end)

      -- <C-p>: git-aware file picker
      -- Uses git_files (tracked + untracked, excluding .gitignored) when inside a git repo,
      -- falls back to files otherwise.  Mirrors:
      --   map <expr> <C-p> FugitiveHead() != '' ? ':GFiles --cached --others …' : ':Files<CR>'
      vim.keymap.set("n", "<C-p>", function()
        if vim.fn.systemlist("git rev-parse --is-inside-work-tree 2>/dev/null")[1] == "true" then
          fzf.git_files()
        else
          fzf.files()
        end
      end)

      -- :Files   -> all files under cwd (respects .gitignore; shows dotfiles)
      -- :Files!  -> EVERYTHING incl. .gitignored + hidden (find .env / secrets); .git/ still excluded
      -- Approach: fzf-lua's get_files_cmd() (files.lua) supports `hidden` and `no_ignore` as
      -- direct boolean opts — it toggles --hidden / --no-ignore on the underlying rg command.
      -- `hidden=true` is already fzf-lua's default, but set explicitly here so :Files! is
      -- self-contained and immune to global config overrides.
      -- `.git/` stays excluded via rg_opts default: `--color=never --files -g "!.git" -g "!.jj"`.
      vim.api.nvim_create_user_command("Files", function(o)
        if o.bang then
          -- include .gitignored files and all hidden files; .git/ excluded by rg_opts default
          fzf.files({ no_ignore = true, hidden = true })
        else
          fzf.files()
        end
      end, { bang = true, desc = "fzf files (! = include ignored+hidden)" })

      -- <leader>]: repo-wide LSP workspace symbols (definitions/symbols across the project).
      -- Replaces the old ctags :Tags picker now that built-in LSP is in place.
      -- (gS is also bound to this in lsp.lua's LspAttach; <leader>] gives a non-buffer-local entry point.)
      vim.keymap.set("n", "<leader>]", fzf.lsp_live_workspace_symbols)

      -- <leader>e: open file in a NEW TAB (replaces :FZFTE / fzf#run with 'tabedit' sink)
      -- file_tabedit action confirmed in fzf-lua actions.lua (M.file_tabedit).
      vim.keymap.set("n", "<leader>e", function()
        fzf.files({ actions = { ["default"] = require("fzf-lua.actions").file_tabedit } })
      end)

      -- <leader>a{motion}: grep the motion text (operator-motion, replaces AgWithMovement)
      -- <leader>a in visual mode: grep the visual selection.
      -- grep({ search = ... }) does a fixed (non-live) grep — confirmed in grep.lua.
      -- grep_visual() grabs the current visual selection — confirmed in grep.lua.
      vim.keymap.set("n", "<leader>a", function()
        vim.o.operatorfunc = "v:lua.require'fzf_ag'.grep_motion"
        return "g@"
      end, { expr = true })
      vim.keymap.set("x", "<leader>a", fzf.grep_visual)
    end,
  },
}
