return {
  { "mason-org/mason.nvim", opts = {} },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason-lspconfig.nvim", dependencies = { "mason-org/mason.nvim" } },
      { "saghen/blink.cmp", version = "1.*" },  -- v1 release line: prebuilt binary, no blink.lib dep (v2 split)
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- diagnostics ON (old config had them OFF because ALE owned them)
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      local lsp_augroup = vim.api.nvim_create_augroup("UserLspAttach", { clear = true })

      -- buffer-local keymaps on attach (port of s:on_lsp_buffer_enabled)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = lsp_augroup,
        callback = function(args)
          local b = args.buf
          local function m(lhs, rhs) vim.keymap.set("n", lhs, rhs, { buffer = b }) end
          -- fzf-lua isn't installed until commit 5; guard so these no-op until then
          local function fzf_map(method)
            return function()
              local ok, fzf = pcall(require, "fzf-lua")
              if ok then fzf[method]() end
            end
          end
          m("gd", vim.lsp.buf.definition)
          m("gD", vim.lsp.buf.declaration)
          m("gi", vim.lsp.buf.implementation)
          m("gs", fzf_map("lsp_document_symbols"))
          m("gS", fzf_map("lsp_live_workspace_symbols"))
          m("K", vim.lsp.buf.hover)
          m("<leader>rn", vim.lsp.buf.rename)
          -- gr (references) is defined in commit 5 via fzf-lua.lsp_references
        end,
      })

      -- merge blink completion capabilities into all servers (graceful if blink unavailable)
      local ok_blink, blink = pcall(require, "blink.cmp")
      local capabilities = ok_blink and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()
      vim.lsp.config("*", { capabilities = capabilities })

      -- per-server override: use clangd (ccls was Windows-only, dropped)
      vim.lsp.config("clangd", { cmd = { "clangd", "--background-index" } })

      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "clangd",
          "omnisharp",
          "rust_analyzer",
          "gopls",
          "pyright",
          "texlab",
          "ts_ls",
          "html",
          "cssls",
        },
        automatic_enable = true, -- calls vim.lsp.enable() for each installed server
      })
    end,
  },
}
