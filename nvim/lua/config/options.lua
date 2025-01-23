-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- This file is automatically loaded by plugins.core
vim.g.mapleader = ","
vim.g.maplocalleader = ","

local opt = vim.opt

opt.autowrite = true -- Enable auto write
opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 3 -- Hide * markup for bold and italic
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
opt.guicursor = "n-v-i:blinkwait200-blinkon400-blinkoff400"
opt.showtabline = 2
opt.expandtab = true -- Use spaces instead of tabs
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true -- Ignore case
opt.inccommand = "nosplit" -- preview incremental substitute
opt.laststatus = 0
opt.list = true -- Show some invisible characters (tabs...
opt.mouse = "a" -- Enable mouse mode
opt.number = true -- Print line number
opt.pumblend = 5 -- Popup blend
opt.pumheight = 20 -- Maximum number of entries in a popup
opt.relativenumber = true -- Relative line numbers
opt.scrolloff = 4 -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent
opt.shortmess:append({ W = true, I = true, c = true })
opt.showmode = false -- Dont show mode since we have a statusline
opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.spelllang = { "en" }
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current
opt.tabstop = 2 -- Number of spaces tabs count for
opt.termguicolors = true -- True color support
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap
opt.splitkeep = "screen"
opt.shortmess:append({ C = true })
-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0
vim.g.lazyvim_php_lsp = "intelephense"

opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true
opt.number = true
opt.relativenumber = true
opt.title = true
opt.termguicolors = true
opt.spell = false
opt.ignorecase = true
opt.smartcase = true
opt.cmdheight = 1
opt.breakindent = true -- maintain indent when wrapping indented lines
opt.list = true -- enable the below listchars
opt.listchars = { tab = "▸ ", trail = "·" }
opt.fillchars:append({ eob = " " }) -- remove the ~ from end of buffer
opt.splitbelow = true
opt.splitright = true
opt.scrolloff = 999
opt.sidescrolloff = 999
opt.fileformat = "unix"
opt.confirm = true -- ask for confirmation instead of erroring
opt.undofile = true -- persistent undo
opt.backup = true -- automatically save a backup file
opt.backupdir:remove(".") -- keep backups out of the current directory
opt.shortmess:append({ I = true }) -- disable the splash screen
opt.wildmode = "longest:full,full" -- complete the longest common match, and allow tabbing the results to fully complete them
opt.showmode = false
opt.updatetime = 4001 -- Set updatime to 1ms longer than the default to prevent polyglot from changing it
opt.redrawtime = 10000 -- Allow more time for loading syntax on large files
opt.colorcolumn = { 80, 120 }
