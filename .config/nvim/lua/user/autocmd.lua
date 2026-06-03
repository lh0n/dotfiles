-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('user-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Apply personal 'formatoptions' after filetype plugins run (they reset it),
-- so these stick regardless of the buffer's filetype. See `:help fo-table`.
vim.api.nvim_create_autocmd('FileType', {
  desc = "Enforce personal 'formatoptions'",
  group = vim.api.nvim_create_augroup('user-formatoptions', { clear = true }),
  callback = function()
    vim.opt_local.formatoptions:remove('a') -- auto-formatting is BAD
    vim.opt_local.formatoptions:remove('t') -- don't auto-format code; linters handle it
    vim.opt_local.formatoptions:append('c') -- wrap comments to textwidth
    vim.opt_local.formatoptions:append('q') -- allow `gq` to format comments
    vim.opt_local.formatoptions:remove('o') -- o/O don't continue comments
    vim.opt_local.formatoptions:append('r') -- <Enter> does continue comments
    vim.opt_local.formatoptions:append('n') -- recognize numbered lists
    vim.opt_local.formatoptions:append('j') -- remove comment leader when joining
    vim.opt_local.formatoptions:remove('2') -- don't use second-line indent for paragraphs
  end,
})
