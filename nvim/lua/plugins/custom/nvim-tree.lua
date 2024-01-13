-- vim.g.nvim_tree_indent_markers = 1
-- vim.g.nvim_tree_git_hl = 1

require("nvim-tree").setup({
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
})

vim.cmd([[
  highlight NvimTreeIndentMarker guifg=#30323E
  augroup NvimTreeHighlights
    autocmd ColorScheme * highlight NvimTreeIndentMarker guifg=#30323E
  augroup end
]])
local api = require("nvim-tree.api")

local function edit_or_open()
  local node = api.tree.get_node_under_cursor()

  if node.nodes ~= nil then
    -- expand or collapse folder
    api.node.open.edit()
  else
    -- open file
    api.node.open.edit()
    -- Close the tree if file was opened
    api.tree.close()
  end
end

-- open as vsplit on current node
local function vsplit_preview()
  local node = api.tree.get_node_under_cursor()

  if node.nodes ~= nil then
    -- expand or collapse folder
    api.node.open.edit()
  else
    -- open file as vsplit
    api.node.open.vertical()
  end

  -- Finally refocus on tree if it was lost
  api.tree.focus()
end
vim.keymap.set("n", "<leader>n", ":NvimTreeFindFileToggle<CR>")
-- vim.keymap.set("n", "l", edit_or_open, opts("Edit Or Open"))
-- vim.keymap.set("n", "L", vsplit_preview, opts("Vsplit Preview"))
-- vim.keymap.set("n", "h", api.tree.close, opts("Close"))
-- vim.keymap.set("n", "H", api.tree.collapse_all, opts("Collapse All"))
--vim.api.nvim_create_autocmd('BufEnter', {
--    command = "if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif",
--    nested = true,
--})
vim.api.nvim_create_autocmd({ "QuitPre" }, {
  callback = function()
    vim.cmd("NvimTreeClose")
  end,
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
  require("nvim-tree.api").tree.toggle({ focus = false, find_file = true })
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
