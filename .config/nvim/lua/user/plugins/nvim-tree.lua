return {
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  version = "*",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local nt = require("nvim-tree")
    local k = vim.keymap

    nt.setup({})

    k.set("n", "<leader>e", vim.cmd.NvimTreeToggle, { desc = "Toggle File Explorer." })
  end,
}
