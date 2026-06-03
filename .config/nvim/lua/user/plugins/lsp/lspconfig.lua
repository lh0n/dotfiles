-- LSP, on the native Neovim 0.11+ API:
--   * Per-server overrides live in `~/.config/nvim/lsp/<name>.lua` (auto-loaded
--     from runtimepath and merged with nvim-lspconfig's shipped base configs).
--   * `vim.lsp.enable({...})` below activates them.
-- This file only handles diagnostics UI, on-attach keymaps, the `*` capabilities
-- broadcast, and the enable list.
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

    -- Document-highlight autocmds live in this group; created once so
    -- LspDetach can clear just the detaching buffer's entries.
    local highlight_augroup = vim.api.nvim_create_augroup('user-lsp-highlight', { clear = true })

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
        -- Formatting goes through conform (single path, LSP as fallback);
        -- see formatting.lua. <leader>cf does the same for a visual range.
        map('<leader>f', function()
          require('conform').format({ lsp_format = 'fallback', async = true })
        end, '[F]ormat buffer')

        -- Highlight references of the symbol under the cursor.
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method('textDocument/documentHighlight') then
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })
        end
      end,
    })

    -- Tear down the per-buffer highlight autocmds when a server detaches, so
    -- they don't stack across re-attaches or multiple clients.
    vim.api.nvim_create_autocmd('LspDetach', {
      group = vim.api.nvim_create_augroup('user-lsp-detach', { clear = true }),
      callback = function(event)
        vim.lsp.buf.clear_references()
        vim.api.nvim_clear_autocmds({ group = highlight_augroup, buffer = event.buf })
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

    -- [[ Activate servers ]] (installed via mason; see mason.lua).
    -- Per-server overrides, if any, live in ~/.config/nvim/lsp/<name>.lua.
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
