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
        "lua_ls",
        "pyright",
      },
      automatic_installation = false, -- whether to auto-install lspconfig servers
    })

    mason_tool_installer.setup({
      ensure_installed = {
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
