return {
  -- gruvbox (lua port from gruvbox-community)
  {
    'ellisonleao/gruvbox.nvim',
    lazy = false, -- Default theme should load on startup.
    priority = 1000,
    config = function()
      require('gruvbox').setup({
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          emphasis = true,
          strings = false,
          comments = true,
          operators = false,
          folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_intend_guides = false,
        inverse = true, -- invert background for search, diffs, statuslines and errors
        contrast = 'hard', -- can be "hard", "soft" or empty string
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = true,
      })
    end,
  },

  -- tokyonight
  {
    'folke/tokyonight.nvim',
    lazy = true,
    opts = { style = 'moon' },
  },

  -- rose-pine
  {
    'rose-pine/neovim',
    lazy = true,
    name = 'rose-pine',
  },

  -- catppuccin
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false, -- Default theme should load on startup.
    priority = 1000,
    config = function()
      require('catppuccin').setup({
        flavour = 'mocha',
        dim_inactive = {
          enabled = true, -- dims the background color of inactive window
          shade = 'dark',
          percentage = 0.15,
        },
        integrations = {
          cmp = true,
          dap = true,
          dap_ui = true,
          fidget = true,
          gitsigns = true,
          harpoon = true,
          lsp_trouble = true,
          markdown = true,
          mason = true,
          mini = {
            enabled = true,
            indentscope_color = '',
          },
          noice = true,
          notify = true,
          nvimtree = true,
          snacks = true,
          telescope = {
            enabled = true,
          },
          treesitter = true,
          which_key = true,
        },
      })
    end,
  },
}
