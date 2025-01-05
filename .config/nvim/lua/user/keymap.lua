local k = vim.keymap

-- Say no to `:Q`.
vim.api.nvim_create_user_command("WQ", "wq", {})
vim.api.nvim_create_user_command("Wq", "wq", {})
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("Qa", "qa", {})
vim.api.nvim_create_user_command("Q", "q", {})

-- Space is the <leader> key, so disable it in normal and visual mode.
k.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Keep system's clipboard separate from nvim's registers.
k.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Copy selected text to system clipboard" })
k.set("n", "<leader>Y", [["+Y]], { desc = "Copy line to system clipboard" })

-- Move selected lines in visual mode.
k.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected text DOWN" })
k.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected text UP" })

-- Improve joining lines.
k.set("n", "J", "mzJ`z", { desc = "Join line below" })

-- Center cursor when scrolling.
k.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll-DOWN (Centered)" })
k.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll-UP (Centered)" })

-- Center cursor when going through search results.
k.set("n", "n", "nzzzv", { desc = "Next match" })
k.set("n", "N", "Nzzzv", { desc = "Previous match" })

-- Preserve 'copy' buffer when pasting/replacing selected text in visual mode.
k.set("x", "<leader>p", [["_dP]], { desc = "Super paste" })

-- Search highlight
k.set("n", "<leader><space>", "<cmd>nohlsearch<CR>", { desc = "Clean search highlight" })
