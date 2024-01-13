-- vim.g.nvim_tree_indent_markers = 1
-- vim.g.nvim_tree_git_hl = 1
local HEIGHT_RATIO = 0.9 -- You can change this
local WIDTH_RATIO = 0.3 -- You can change this too

require("nvim-tree").setup({
  git = {
    ignore = true,
  },
  view = {
    float = {
      enable = true,
      open_win_config = function()
        local screen_w = vim.opt.columns:get()
        local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
        local window_w = screen_w * WIDTH_RATIO
        local window_h = screen_h * HEIGHT_RATIO
        local window_w_int = math.floor(window_w)
        local window_h_int = math.floor(window_h)
        local center_x = (screen_w - window_w) / 2
        local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
        return {
          border = "rounded",
          relative = "editor",
          row = -2,
          col = -2,

          width = window_w_int,
          height = window_h_int,
        }
      end,
    },
    width = function()
      return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
    end,
    -- width = 30,
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
