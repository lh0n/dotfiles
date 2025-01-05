return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  dependencies = { 'rafamadriz/friendly-snippets' },
  config = function()
    local ls = require('luasnip')
    -- local types = ls.luasnip.util.types

    ls.config.setup({
      -- Remember last snippet.
      -- Jump back into it even if you move outside of the selection.
      history = true,
      -- Dynamically update as you type.
      updateevents = 'TextChanged,TextChangedI',
      -- Snippets aren't automatically removed if their text is deleted.
      -- `delete_check_events` determines on which events (:h events) a check for
      -- deleted snippets is performed.
      -- This can be especially useful when `history` is enabled.
      delete_check_events = "TextChanged",
      -- Auto-snippets.
      enable_autosnippets = true,
    })

    -- 'rafamadriz/friendly-snippets' - Load friendly snippets.
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Useful for debugging.
    -- local handle = io.popen('date +"%T.%6N"')
    -- local output = handle:read('*a')
    -- local time = output:gsub('[\n\r]', ' ')
    -- handle:close()
    -- print(time .. 'DEBUG: Loaded LuaSnip.')
  end,
}

