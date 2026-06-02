local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  { import = 'user.plugins' },
  { import = 'user.plugins.lsp' },
}, {
  install = {
    colorscheme = { 'catppuccin-mocha' },
  },
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
  -- No plugin here needs luarocks; disable it to silence the hererocks
  -- checkhealth error (see `:checkhealth lazy`).
  rocks = {
    enabled = false,
  },
})

vim.cmd.colorscheme('catppuccin-mocha')
