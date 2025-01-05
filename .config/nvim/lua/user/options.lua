local opt = vim.opt -- for consiseness

vim.g.mapleader = " " -- set leader before plugins so mappings are correct.
vim.g.maplocalleader = " " -- same as leader.
vim.g.loaded_netrw = 1 -- disable netrw.
vim.g.loaded_netrwPlugin = 1 -- disable netrw.

opt.termguicolors = true -- true-colors support.
opt.background = "dark" -- default dark background.
opt.autoread = true -- re-read file if changed outside.
opt.backup = false -- creates a backup file
opt.clipboard = "unnamed" -- keep system clipboard separate from neovim.
opt.cmdheight = 2 -- more space in the neovim command line for displaying messages'
opt.colorcolumn = "80" -- highlight column 80
opt.completeopt = { "menu", "menuone", "noselect" } -- supported modes for completion while in insert mode.
opt.conceallevel = 0 -- do not conceal any text.
opt.cursorcolumn = true -- highlight the current column
opt.cursorline = true -- highlight the current line
opt.expandtab = true -- convert tabs to spaces
opt.fileencoding = "utf-8" -- the encoding written to a file
opt.grepprg = "rg --vimgrep --smart-case --follow" -- program used by the :grep command.
opt.guifont = "monospace:h17" -- the font used in graphical neovim applications
opt.hlsearch = true -- highlight all matches on previous search pattern
opt.ignorecase = true -- ignore case in search patterns
opt.inccommand = "split" -- shows effects of a command in a preview window.
opt.incsearch = true -- shows partial matches while typing search pattern.
opt.laststatus = 3 -- only the last window shall have a status line.
opt.linebreak = true -- companion to wrap, don't split words
opt.list = true -- enable list mode to show otherwise hidden characters.
opt.listchars = { eol = "↲", tab = "» ", trail = "°" } -- happier symbols for listchars.
opt.mouse = "a" -- allow the mouse to be used in neovim
opt.number = true -- set numbered lines
opt.numberwidth = 4 -- set the number column width.
opt.pumheight = 10 -- pop up menu height
opt.relativenumber = true -- set relative numbered lines
opt.ruler = true -- shows line/column number of the cursor position.
opt.scrolloff = 10 -- minimal number of screen lines to keep above and below the cursor
opt.shiftwidth = 2 -- the number of spaces inserted for each indentation
opt.showmode = false -- we don't need to see things like -- INSERT -- anymore
opt.showtabline = 2 -- always show tabs
opt.sidescrolloff = 10 -- minimal number of screen columns either side of cursor if wrap is `false`
opt.signcolumn = "yes" -- always show the sign column, otherwise it would shift the text each time
opt.smartcase = true -- smart case
opt.smartindent = true -- make indenting smarter again
opt.splitbelow = true -- force all horizontal splits to go below current window
opt.splitright = true -- force all vertical splits to go to the right of current window
opt.swapfile = false -- creates a swapfile
opt.tabstop = 2 -- insert 2 spaces for a tab
opt.textwidth = 80 -- maximum width of text being inserted.
opt.timeout = true -- enable timeout for mapped commands. Set via `timeoutlen`.
opt.timeoutlen = 500 -- timeout for a mapped sequence to complete (in milliseconds).
opt.undofile = true -- enable persistent undo
opt.updatetime = 300 -- faster completion (4000ms default)
opt.whichwrap = "<>[]" -- which 'horizontal' keys are allowed to travel to prev/next line
opt.wildmenu = true -- enhanced menu completion.
opt.wildmode = "full" -- completes the next full match.
opt.wrap = true -- display lines as one long line
opt.writebackup = false -- editing a file is not allowed if it's is already being edited by another program.

-- opt.shortmess = 'ilmnrx'             -- flags to shorten vim messages, see :help 'shortmess'
opt.shortmess:append("c") -- don't give |ins-completion-menu| messages
opt.iskeyword:append("-") -- hyphenated words recognized by searches

-- :help fo-table
-- This is overridden by the default ftplugin definitions.
-- Can be overridden per-filetype using after/ftplugin/...
opt.formatoptions = vim.opt.formatoptions
  - "a" -- Auto formatting is BAD.
  - "t" -- Don't auto format my code. I got linters for that.
  + "c" -- In general, I like it when comments respect textwidth
  + "q" -- Allow formatting comments w/ gq
  - "o" -- O and o, don't continue comments
  + "r" -- But do continue when pressing enter.
  + "n" -- Indent past the formatlistpat, not underneath it.
  + "j" -- Auto-remove comments if possible.
  - "2" -- I'm not in gradeschool anymore

opt.runtimepath:remove("/usr/share/vim/vimfiles") -- separate vim plugins from neovim in case vim still in use
