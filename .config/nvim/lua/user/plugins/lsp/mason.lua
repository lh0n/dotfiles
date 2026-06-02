return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")

    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      ensure_installed = {
        "ansiblels",
        "yamlls",
        "bashls",
        "clangd",
        "dockerls",
        "docker_compose_language_service",
        "gopls",
        "marksman",
        "ts_ls",
        "html",
        "cssls",
        "emmet_ls",
        "lua_ls",
        "pyright",
      },
      -- mason-lspconfig 2.0 can auto-call `vim.lsp.enable` for installed
      -- servers. We enable explicitly in lspconfig.lua (after applying our
      -- `vim.lsp.config` overrides), so keep this off to avoid double setup.
      automatic_enable = false,
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "tree-sitter-cli", -- REQUIRED by nvim-treesitter `main` to compile parsers
        "gofumpt", -- golang formatter stricter than gofmt
        "goimports-reviser", -- golang imports sorting
        "golines", -- golang fixes long lines
        "ansible-lint", -- ansible linter
        "prettier", -- prettier formatter
        "stylua", -- lua formatter
        "isort", -- python imports sorting
        "black", -- python formatter
        "pylint", -- python linter
        "eslint_d", -- js linter
      },
    })
  end,
}
