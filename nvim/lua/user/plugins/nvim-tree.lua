-- vim.g.nvim_tree_indent_markers = 1
-- vim.g.nvim_tree_git_hl = 1

require('nvim-tree').setup({
  git = {
    ignore = true,
  },
  view = {
    side = "left",
    width = 30,
  },
  renderer = {
    highlight_opened_files = '1',
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
})

vim.cmd([[
  highlight NvimTreeIndentMarker guifg=#30323E
  augroup NvimTreeHighlights
    autocmd ColorScheme * highlight NvimTreeIndentMarker guifg=#30323E
  augroup end
]])

vim.keymap.set('n', '<leader>n', ':NvimTreeFindFileToggle<CR>')
vim.api.nvim_create_autocmd("BufEnter", {
  nested = true,
  callback = function()
    if #vim.api.nvim_list_wins() == 1 and require("nvim-tree.utils").is_nvim_tree_buf() then
      vim.cmd "quit"
    end
  end
})
local function open_nvim_tree()
  -- open the tree
  require("nvim-tree.api").tree.open()
end
vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
