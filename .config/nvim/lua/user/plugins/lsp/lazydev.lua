-- lazydev.nvim configures lua_ls for editing your Neovim config: it loads the
-- vim API, plugin types, and `vim.uv` on demand. Replaces the archived
-- neodev.nvim.
return {
  'folke/lazydev.nvim',
  ft = 'lua',
  opts = {
    library = {
      -- Load luvit (vim.uv) types when `vim.uv` is referenced.
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
    },
  },
}
