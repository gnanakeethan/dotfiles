vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wildmode = 'longest:full,full' --  complete the longest common match , and allow tabbing the results to fully complete them

vim.opt.title = true
vim.opt.mouse = 'a'
vim.opt.termguicolors = true
vim.opt.spell = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.list = true
vim.opt.listchars = { tab ='> ', trail = '•'}
vim.opt.fillchars:append({eob = ' '})
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.scrolloff = 14
vim.opt.sidescrolloff = 8
vim.opt.cmdheight=1
vim.opt.clipboard = 'unnamedplus'
vim.opt.confirm = true -- ask for confirmation instead of erroring
vim.opt.undofile = true -- persistent undo
vim.opt.backup = true -- automatically save a backup file
vim.opt.backupdir:remove('.') -- keep backups out of current dir


