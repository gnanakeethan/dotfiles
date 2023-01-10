vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- when text is wrapped move by terminal rows
vim.keymap.set('n','k',"v:count == 0 ? 'gk' : 'k'", { expr = true })
vim.keymap.set('n','j',"v:count == 0 ? 'gj' : 'j'", { expr = true })

vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- http://ddrscott.github.io/blog/2016/yank-without-jank/
vim.keymap.set('v','y','myy`y')
vim.keymap.set('n','q:',':q')

-- paste replace visual selection without copying it.
vim.keymap.set('v','p','"_dP')

-- quick enter ; and ,
vim.keymap.set('i',';;','<Esc>A;')
vim.keymap.set('i',',','<Esc>A,')

-- clear highlighting
vim.keymap.set('n','<Leader>k',':nohlsearch<CR>')

-- open the current file in default program
vim.keymap.set('n','<Leader>x',':!open %<CR><CR>')

-- move lines
vim.keymap.set('i','<A-j>', '<Esc>:move .+1<CR>==gi')
vim.keymap.set('i','<A-k>', '<Esc>:move .-2<CR>==gi')
