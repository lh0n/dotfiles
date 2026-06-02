-- Context-aware 'commentstring' for embedded languages (JSX/TSX, Vue, etc.).
--
-- Commenting itself is handled by Neovim's BUILT-IN gc/gcc mappings (0.10+),
-- so Comment.nvim is no longer needed. This plugin only computes the correct
-- 'commentstring' for the cursor location and feeds it to the built-in mappings
-- through the documented `vim.filetype.get_option` hook.
return {
  'JoosepAlviste/nvim-ts-context-commentstring',
  lazy = true,
  ft = { 'javascriptreact', 'typescriptreact', 'svelte', 'vue', 'html' },
  init = function()
    -- Skip the legacy autocmd/regex backend; we drive it on demand below.
    vim.g.skip_ts_context_commentstring_module = true
  end,
  config = function()
    require('ts_context_commentstring').setup({ enable_autocmd = false })

    local get_option = vim.filetype.get_option
    vim.filetype.get_option = function(filetype, option)
      return option == 'commentstring'
          and require('ts_context_commentstring.internal').calculate_commentstring()
        or get_option(filetype, option)
    end
  end,
}
