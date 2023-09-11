return {
    { "christoomey/vim-tmux-navigator" },
    { "farmergreg/vim-lastplace" },
    { "tpope/vim-commentary" },
    { "tpope/vim-repeat" },
    { "tpope/vim-surround" },
    { "tpope/vim-eunuch" }, -- Adds :Rename, :SudoWrite,
    { "tpope/vim-unimpaired" }, -- Adds [b and other handy mappings,
    { "tpope/vim-sleuth" }, -- Indent autodetection with editorconfig support,
    { "jessarcher/vim-heritage" }, -- Automatically create parent dirs when saving,
    { "nelstrom/vim-visual-star-search" },
    { "b0o/schemastore.nvim" },
    { "nvim-tree/nvim-web-devicons" }, -- OPTIONAL: for file icons,
    { "goolord/alpha-nvim", enabled = false },
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
           require("plugins.custom.nvim-tree")
        end,
    }
}
