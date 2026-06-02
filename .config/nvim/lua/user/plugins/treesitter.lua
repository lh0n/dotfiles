-- nvim-treesitter, rewritten for the `main` branch API (Neovim 0.11+).
--
-- The `main` branch dropped the old `require('nvim-treesitter.configs').setup`
-- module system. Parsers are installed via `install()`, and highlighting /
-- indentation are enabled per-buffer through `vim.treesitter.start()` and
-- `indentexpr` from a FileType autocmd.
--
-- Removed vs. the old config: `incremental_selection` no longer exists on
-- `main`. (If you miss it, it can be re-implemented with `vim.treesitter`
-- node ranges, but it's intentionally left out here.)
local ensure_installed = {
  'bash',
  'c',
  'cpp',
  'git_config',
  'git_rebase',
  'gitattributes',
  'gitcommit',
  'gitignore',
  'go',
  'gomod',
  'gosum',
  'lua',
  'make',
  'markdown',
  'markdown_inline',
  'nix',
  'proto',
  'python',
  'regex',
  'rasi',
  'rust',
  'sql',
  'starlark',
  'terraform',
  'toml',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'yaml',
}

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main', -- the rewritten branch; `master` is now maintenance-only.
    build = ':TSUpdate',
    lazy = false,
    config = function()
      -- The `main` branch compiles parsers with the `tree-sitter` CLI. We
      -- install it via mason (see mason.lua), but treesitter may load before
      -- mason prepends its bin dir, so make sure the CLI is on PATH here.
      local mason_bin = vim.fn.stdpath('data') .. '/mason/bin'
      if vim.fn.isdirectory(mason_bin) == 1 and not string.find(vim.env.PATH, mason_bin, 1, true) then
        vim.env.PATH = mason_bin .. ':' .. vim.env.PATH
      end

      local ts = require('nvim-treesitter')
      ts.setup() -- only configures `install_dir`; defaults are fine.

      -- Install any missing parsers from the list above.
      local installed = ts.get_installed()
      local missing = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
      end, ensure_installed)
      if #missing > 0 then
        ts.install(missing)
      end

      -- Enable highlighting + treesitter indentation per buffer.
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('user-treesitter', { clear = true }),
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
          if not lang then
            return
          end
          -- `start` errors if the parser isn't installed yet (async install on
          -- first launch); guard so a missing parser doesn't break the buffer.
          if not pcall(vim.treesitter.start, args.buf, lang) then
            return
          end
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main', -- must match nvim-treesitter's branch.
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('nvim-treesitter-textobjects').setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require('nvim-treesitter-textobjects.select')
      local move = require('nvim-treesitter-textobjects.move')
      local swap = require('nvim-treesitter-textobjects.swap')

      -- Selection textobjects (visual + operator-pending).
      local selections = {
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      }
      for lhs, query in pairs(selections) do
        vim.keymap.set({ 'x', 'o' }, lhs, function()
          select.select_textobject(query, 'textobjects')
        end, { desc = 'TS select ' .. query })
      end

      -- Movement.
      local movements = {
        goto_next_start = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
        goto_next_end = { [']M'] = '@function.outer', [']['] = '@class.outer' },
        goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
        goto_previous_end = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' },
      }
      for fn, maps in pairs(movements) do
        for lhs, query in pairs(maps) do
          vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
            move[fn](query, 'textobjects')
          end, { desc = 'TS ' .. fn .. ' ' .. query })
        end
      end

      -- Swap parameters.
      vim.keymap.set('n', '<leader>a', function()
        swap.swap_next('@parameter.inner')
      end, { desc = 'TS swap next parameter' })
      vim.keymap.set('n', '<leader>A', function()
        swap.swap_previous('@parameter.inner')
      end, { desc = 'TS swap previous parameter' })
    end,
  },

  {
    -- Sticky context header. Works directly on `vim.treesitter`, so it's
    -- independent of the nvim-treesitter branch.
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {},
  },
}
