return {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-nvim-lsp', -- additional LSP capabilities
    'hrsh7th/cmp-nvim-lua', -- completion for Lua API
    { 'saadparwaiz1/cmp_luasnip', dependencies = { 'LuaSnip' } },
    'onsails/lspkind.nvim',
  },
  config = function()
    local cmp = require('cmp')
    local luasnip = require('luasnip')
    local lspkind = require('lspkind')

    cmp.setup({
      completion = {
        completeopt = 'menu,menuone,noinsert',
      },
      snippet = {
        -- REQUIRED - must specify a snippet engine.
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-n>'] = cmp.mapping.select_next_item(), -- next item
        ['<C-p>'] = cmp.mapping.select_prev_item(), -- prev item
        ['<C-y>'] = cmp.mapping.confirm({ select = true }), -- accept item
        ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- scroll up
        ['<C-d>'] = cmp.mapping.scroll_docs(4), -- scroll down
        ['<C-Space>'] = cmp.mapping.complete(), -- trigger completion
        ['<C-c>'] = cmp.mapping.abort(), -- close completion window
        -- <c-l> will move you to the right of each of the expansion locations.
        -- <c-h> is similar, except moving you backwards.
        ['<C-l>'] = cmp.mapping(function()
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          end
        end, { 'i', 's' }),
        ['<C-h>'] = cmp.mapping(function()
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          end
        end, { 'i', 's' }),
      }),
      sources = {
        { name = 'nvim_lua' }, -- 'hrsh7th/cmp-nvim-lua'
        { name = 'nvim_lsp' }, -- 'hrsh7th/cmp-nvim-lsp'
        { name = 'luasnip' }, -- 'saadparwaiz1/cmp_luasnip'
        -- { name = 'buffer' }, -- 'hrsh7th/cmp-buffer'
        { name = 'path' }, -- 'hrsh7th/cmp-path'
      },
      formatting = {
        format = lspkind.cmp_format({
          mode = 'symbol_text',
        }),
      },
    })

    -- Useful for debugging.
    -- local handle = io.popen('date +"%T.%6N"')
    -- local output = handle:read('*a')
    -- local time = output:gsub('[\n\r]', ' ')
    -- handle:close()
    -- print(time .. 'DEBUG: Loaded nvim-cmp')
  end,
}
