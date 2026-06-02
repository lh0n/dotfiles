-- LSP, migrated to the native Neovim 0.11+ API:
--   * `vim.lsp.config(name, opts)` for per-server overrides
--   * `vim.lsp.enable({...})` to activate servers
-- The base cmd/filetypes/root for each server still come from nvim-lspconfig's
-- shipped `lsp/<name>.lua` files; we only override what we customize.
--
-- Lua/nvim-API awareness is provided by lazydev.nvim (see lazydev.lua), which
-- replaces the archived neodev.nvim.
return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    -- [[ Diagnostics ]] (replaces the deprecated `vim.fn.sign_define` loop).
    vim.diagnostic.config({
      severity_sort = true,
      float = { border = 'rounded', source = true },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = ' ',
          [vim.diagnostic.severity.WARN] = ' ',
          [vim.diagnostic.severity.HINT] = '󰠠 ',
          [vim.diagnostic.severity.INFO] = ' ',
        },
      },
      virtual_text = { source = 'if_many', spacing = 2 },
    })

    -- [[ Buffer-local keymaps on attach ]]
    -- Neovim 0.11 ships defaults we no longer remap: K (hover), <C-s> (insert
    -- signature help), grn (rename), gra (code action), grr (references),
    -- gri (implementation), grt (type definition), gO (document symbols),
    -- and ]d / [d (diagnostic jumps). We keep Telescope-backed navigation and
    -- a few leader maps below.
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
      callback = function(event)
        local tsb = require('telescope.builtin')
        local map = function(keys, fn, desc)
          vim.keymap.set('n', keys, fn, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Telescope-backed navigation (richer pickers than the gr* defaults).
        map('gd', tsb.lsp_definitions, '[G]oto [D]efinition')
        map('gr', tsb.lsp_references, '[G]oto [R]eferences')
        map('gI', tsb.lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>gt', tsb.lsp_type_definitions, '[G]oto [T]ype definition')
        map('<leader>ds', tsb.lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', tsb.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>D', function()
          tsb.diagnostics({ bufnr = 0 })
        end, 'Buffer [D]iagnostics')

        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>d', vim.diagnostic.open_float, 'Line [d]iagnostics')
        map('<leader>rs', '<cmd>LspRestart<CR>', 'Restart LSP')
        map('<leader>f', function()
          vim.lsp.buf.format({ async = true })
        end, '[F]ormat buffer')

        -- Highlight references of the symbol under the cursor.
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method('textDocument/documentHighlight') then
          local hl_group = vim.api.nvim_create_augroup('user-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = hl_group,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = hl_group,
            callback = vim.lsp.buf.clear_references,
          })
        end
      end,
    })

    -- [[ Capabilities ]] — broadcast blink.cmp's extra completion capabilities
    -- to every server via the `*` wildcard config.
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok_blink, blink = pcall(require, 'blink.cmp')
    if ok_blink then
      capabilities = blink.get_lsp_capabilities(capabilities)
    end
    vim.lsp.config('*', { capabilities = capabilities })

    -- [[ Per-server overrides ]]
    vim.lsp.config('ansiblels', {
      filetypes = { 'yaml' },
      root_markers = { 'ansible.cfg' },
    })

    vim.lsp.config('emmet_ls', {
      filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less', 'svelte' },
    })

    vim.lsp.config('marksman', {
      filetypes = { 'markdown', 'markdown.mdx' },
      root_markers = { '.marksman.toml', '.git' },
    })

    vim.lsp.config('gopls', {
      settings = {
        gopls = {
          completeUnimported = true,
          usePlaceholders = true,
          analyses = { unusedparams = true },
        },
      },
    })

    vim.lsp.config('lua_ls', {
      settings = {
        Lua = {
          completion = { callSnippet = 'Replace' },
        },
      },
    })

    -- [[ Activate servers ]] (installed via mason; see mason.lua).
    vim.lsp.enable({
      'ansiblels',
      'yamlls',
      'bashls',
      'clangd',
      'dockerls',
      'docker_compose_language_service',
      'gopls',
      'marksman',
      'ts_ls',
      'html',
      'cssls',
      'emmet_ls',
      'lua_ls',
      'pyright',
    })
  end,
}
