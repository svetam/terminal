return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    -- Mason setup (UI for managing LSP servers, linters, formatters)
    require("mason").setup({
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    -- LSP capabilities (integrate with nvim-cmp)
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local lspconfig = require("lspconfig")

    -- ================================================================
    -- LSP SERVERS — comment/uncomment to enable/disable
    -- Install instructions:
    --   ruby_lsp:       gem install ruby-lsp
    --   terraformls:    brew install terraform-ls
    --   ts_ls:          npm i -g typescript typescript-language-server
    --   eslint:         npm i -g vscode-langservers-extracted
    --   html:           npm i -g vscode-langservers-extracted
    --   cssls:          npm i -g vscode-langservers-extracted
    --   jsonls:         npm i -g vscode-langservers-extracted
    --   yamlls:         npm i -g yaml-language-server
    --   lua_ls:         brew install lua-language-server
    --   bashls:         npm i -g bash-language-server
    -- ================================================================
    local servers = {
      ruby_lsp = {
        init_options = {
          formatter = "auto",
          linters = { "rubocop" },
        },
      },
      terraformls = {},
      -- ts_ls = {},
      -- eslint = {},
      -- html = {},
      -- cssls = {},
      -- jsonls = {},
      -- yamlls = {},
      -- lua_ls = {
      --   settings = {
      --     Lua = {
      --       diagnostics = { globals = { "vim" } },
      --       workspace = { checkThirdParty = false },
      --     },
      --   },
      -- },
      -- bashls = {},
    }

    for server, config in pairs(servers) do
      config.capabilities = capabilities
      lspconfig[server].setup(config)
    end

    -- Keymaps on LSP attach
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp_attach_keymaps", { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gr", vim.lsp.buf.references, "Find references")
        map("gI", vim.lsp.buf.implementation, "Go to implementation")
        map("K", vim.lsp.buf.hover, "Hover documentation")
        map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        map("<leader>ca", vim.lsp.buf.code_action, "Code actions")
        map("<leader>d", vim.diagnostic.open_float, "Show diagnostic")
        map("[d", vim.diagnostic.goto_prev, "Previous diagnostic")
        map("]d", vim.diagnostic.goto_next, "Next diagnostic")
      end,
    })

    -- Diagnostic appearance
    vim.diagnostic.config({
      virtual_text = {
        prefix = "●",
        spacing = 4,
      },
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = {
        border = "rounded",
        source = true,
      },
    })

    -- Diagnostic signs in gutter
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end
  end,
}
