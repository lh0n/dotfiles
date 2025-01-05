return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    { 'folke/neodev.nvim', opts = {} },
  },
  config = function()
    local lspconfig = require('lspconfig')
    local util = require('lspconfig/util')
    local cmp_nvim_lsp = require('cmp_nvim_lsp')
    local tsb = require('telescope.builtin')

    local opts = { noremap = true, silent = true }

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, options)
          vim.keymap.set('n', keys, func, options)
        end

        -- Buffer local mappings.
        opts.buffer = event.buf

        -- keybinds
        --  To jump back, press <C-t>.
        opts.desc = 'LSP: [G]oto [D]efinition'
        map('gd', tsb.lsp_definitions, opts)

        opts.desc = 'LSP: [G]oto [R]eferences'
        map('gr', tsb.lsp_references, opts)

        opts.desc = 'LSP: [G]oto [D]eclaration'
        map('gD', vim.lsp.buf.declaration, opts)

        opts.desc = 'LSP: [G]oto [I]mplementation'
        map('gI', tsb.lsp_implementations, opts)

        opts.desc = 'LSP: [G]oto [T]ype Definition'
        map('<leader>gt', tsb.lsp_type_definitions, opts)

        opts.desc = 'LSP: [D]ocument [S]ymbols'
        map('<leader>ds', tsb.lsp_document_symbols, opts)

        opts.desc = 'LSP: [W]orkspace [S]ymbols'
        map('<leader>ws', tsb.lsp_dynamic_workspace_symbols, opts)

        opts.desc = 'LSP: [R]e[n]ame'
        map('<leader>rn', vim.lsp.buf.rename, opts)

        opts.desc = 'LSP: [C]ode [A]ction'
        map('<leader>ca', vim.lsp.buf.code_action, opts)

        opts.desc = 'LSP: Hover Documentation'
        map('K', vim.lsp.buf.hover, opts)

        opts.desc = 'LSP: Signature Help'
        map('<C-k>', vim.lsp.buf.signature_help, opts)

        opts.desc = 'LSP: Show Buffer [D]iagnostics'
        map('<leader>D', '<cmd>Telescope diagnostics bufnr=0<CR>', opts)

        opts.desc = 'LSP: Line [d]iagnostics'
        map('<leader>d', vim.diagnostic.open_float, opts)

        opts.desc = 'LSP: Previous diagnostic'
        map('[d', vim.diagnostic.goto_prev, opts)

        opts.desc = 'LSP: Next diagnostic'
        map(']d', vim.diagnostic.goto_next, opts)

        opts.desc = 'LSP: [F]ormat buffer'
        map('<leader>f', function()
          vim.lsp.buf.format({ async = true })
        end, opts)

        opts.desc = 'LSP: Restart LSP'
        map('<leader>rs', ':LspRestart<CR>', opts)

        -- Autocommands to highlight references of the word under your cursor.
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            callback = vim.lsp.buf.clear_references,
          })
        end
      end,
    })

    -- Announce additional capabilities from plugins to the LSP servers.
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, cmp_nvim_lsp.default_capabilities())

    -- Change the Diagnostic symbols in the sign column (gutter)
    local signs = { Error = ' ', Warn = ' ', Hint = '󰠠 ', Info = ' ' }
    for type, icon in pairs(signs) do
      local hl = 'DiagnosticSign' .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
    end

    -- configure ansible server
    lspconfig.ansiblels.setup({
      capabilities = capabilities,
      filetypes = { 'yaml' },
      root_dir = util.root_pattern('ansible.cfg'),
    })

    -- configure html server
    lspconfig.html.setup({
      capabilities = capabilities,
    })

    -- configure typescript server with plugin
    lspconfig.ts_ls.setup({
      capabilities = capabilities,
    })

    -- configure css server
    lspconfig.cssls.setup({
      capabilities = capabilities,
    })

    -- configure emmet language server
    lspconfig.emmet_ls.setup({
      capabilities = capabilities,
      filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less', 'svelte' },
    })

    -- configure markdown server
    lspconfig.marksman.setup({
      capabilities = capabilities,
      filetypes = { 'markdown', 'markdown.mdx' },
      root_dir = util.root_pattern('.git', '.marksman.toml'),
    })

    -- configure golang server
    lspconfig.gopls.setup({
      capabilities = capabilities,
      cmd = { 'gopls' },
      filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
      root_dir = util.root_pattern('go.work', 'go.mod', '.git'),
      settings = {
        gopls = {
          completeUnimported = true,
          usePlaceholders = true,
          analyses = {
            unusedparams = true,
          },
        },
      },
    })

    -- configure python server
    lspconfig.pyright.setup({
      capabilities = capabilities,
    })

    -- configure lua server (with special settings)
    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      settings = { -- custom settings for lua
        Lua = {
          -- Recognize "vim" global
          diagnostics = {
            globals = { 'vim' },
          },
          completion = {
            callSnippet = 'Replace',
          },
          -- workspace = {
          --   -- make language server aware of runtime files
          --   library = {
          --     [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          --     [vim.fn.stdpath('config') .. '/lua'] = true,
          --   },
          -- },
        },
      },
    })
  end,
}
