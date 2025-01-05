return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'BurntSushi/ripgrep',
    'nvim-telescope/telescope-ui-select.nvim',
    -- Pretty icons. Require a Nerd Font.
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    -- Fuzzy Finder Algorithm. Requires local dependencies to be built.
    -- Loads only if `make` is available.
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  config = function()
    local ts = require('telescope')
    local themes = require('telescope.themes')

    ts.setup({
      defaults = {
        path_display = { 'truncate' },
      },
      extensions = {
        ['ui-select'] = {
          themes.get_dropdown(),
        },
      },
    })

    -- Enable extensions, if installed.
    -- This has to come after the telescope setup function.
    pcall(ts.load_extension('fzf'))
    pcall(ts.load_extension('ui-select'))

    -- Shorter aliases to internal modules.
    -- Makes it easier to write keymaps.
    local tsb = require('telescope.builtin') -- `:help telescope.builtin`
    local k = vim.keymap

    k.set('n', '<leader>ff', tsb.find_files, { desc = '[F]ind [F]iles' })
    k.set('n', '<leader>fr', tsb.oldfiles, { desc = '[?] [F]ind [R]ecent files:' })
    k.set('n', '<leader>fh', tsb.help_tags, { desc = '[F]ind [H]elp' })
    k.set('n', '<leader>fw', tsb.grep_string, { desc = '[F]ind [W]ord' })
    k.set('n', '<leader>fg', tsb.live_grep, { desc = '[F]ind by [G]rep' })
    k.set('n', '<leader>fd', tsb.diagnostics, { desc = '[F]ind [D]iagnostics' })
    k.set('n', '<leader>pp', tsb.resume, { desc = '[P]revious [P]icker' })
    k.set('n', '<leader>fb', tsb.buffers, { desc = '[ ] Find existing buffers' })
    k.set('n', '<leader>/', function()
      tsb.current_buffer_fuzzy_find(themes.get_dropdown({
        winblend = 10,
        previewer = false,
      }))
    end, { desc = '[/] Search in current buffer' })
  end,
}
