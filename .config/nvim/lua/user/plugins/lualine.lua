return {
  'nvim-lualine/lualine.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    local lualine = require('lualine')
    lualine.setup({
      options = {
        theme = 'auto', -- follow the active colorscheme (catppuccin-mocha)
      },
      -- tabline = {
      --     lualine_a = {'windows'},
      --     lualine_b = {},
      --     lualine_c = {},
      --     lualine_x = {},
      --     lualine_y = {},
      --     lualine_z = {'tabs'},
      -- },
    })
  end,
}
