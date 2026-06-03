-- blink.cmp — completion engine replacing nvim-cmp and its cmp-* sources.
-- Snippets use blink's `default` preset: friendly-snippets (VSCode-format) are
-- scanned from runtimepath and expanded via Neovim's built-in `vim.snippet`,
-- so no separate snippet engine (LuaSnip) is needed. lspkind is no longer
-- needed either (blink draws its own kind icons).
--
-- Using a release tag (`version`) pulls a prebuilt fuzzy-matcher binary, so no
-- Rust toolchain / `cargo build` is required.
return {
  'saghen/blink.cmp',
  event = 'InsertEnter',
  version = '1.*',
  dependencies = {
    'rafamadriz/friendly-snippets', -- VSCode-format snippets, loaded by the `default` preset
  },
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    snippets = { preset = 'default' },

    -- Keymap kept close to the previous nvim-cmp bindings.
    keymap = {
      preset = 'none',
      ['<C-n>'] = { 'select_next', 'fallback' },
      ['<C-p>'] = { 'select_prev', 'fallback' },
      ['<C-y>'] = { 'accept', 'fallback' },
      ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation', 'fallback' },
      ['<C-c>'] = { 'cancel', 'fallback' },
      ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
      -- Snippet tabstop jumps (routed to vim.snippet.jump).
      ['<C-l>'] = { 'snippet_forward', 'fallback' },
      ['<C-h>'] = { 'snippet_backward', 'fallback' },
    },

    appearance = { nerd_font_variant = 'mono' },

    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      menu = { draw = { treesitter = { 'lsp' } } },
    },

    -- `lsp` covers the old nvim_lsp + nvim_lua sources (lazydev feeds lua_ls).
    -- `buffer` was disabled before; enabled here as a low-priority fallback.
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    -- Inline signature help while typing (complements the 0.11 default <C-s>).
    signature = { enabled = true },

    fuzzy = { implementation = 'prefer_rust_with_warning' },
  },
  opts_extend = { 'sources.default' },
}
