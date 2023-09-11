-- vim.g.nvim_tree_indent_markers = 1
-- vim.g.nvim_tree_git_hl = 1

require("nvim-tree").setup {
    git = {
        ignore = true,
    },
    view = {
        side = "left",
        width = 30,
    },
    renderer = {
        highlight_opened_files = "all",
        group_empty = true,
        icons = {
            show = {
                folder_arrow = true,
            },
        },
        indent_markers = {
            enable = true,
            -- inline_arrows = false,
        },
    },
}

vim.cmd([[
  highlight NvimTreeIndentMarker guifg=#30323E
  augroup NvimTreeHighlights
    autocmd ColorScheme * highlight NvimTreeIndentMarker guifg=#30323E
  augroup end
]])

vim.keymap.set('n', '<leader>n', ':NvimTreeFindFileToggle<CR>')
--vim.api.nvim_create_autocmd('BufEnter', {
--    command = "if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif",
--    nested = true,
--})
vim.api.nvim_create_autocmd({"QuitPre"}, {
    callback = function() vim.cmd("NvimTreeClose") end,
})
local function open_nvim_tree(data)

    -- buffer is a real file on the disk
    local real_file = vim.fn.filereadable(data.file) == 1

    -- buffer is a [No Name]
    local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

    if not real_file and not no_name then
        return
    end

    -- open the tree, find the file but don't focus it
    require("nvim-tree.api").tree.toggle({ focus = false, find_file = true, })
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
