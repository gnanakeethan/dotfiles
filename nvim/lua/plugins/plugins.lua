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
    { "nvim-tree/nvim-web-devicons" }, -- OPTIONAL: for file icons,
    { "goolord/alpha-nvim", enabled = false },
    {
        "telescope.nvim",
        dependencies = {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
            config = function()
                require("telescope").load_extension("fzf")
            end,
        },
    },
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
    },
    -- formatters
    {
        "nvimtools/none-ls.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "mason.nvim" },
        config = function()
            require("plugins.custom.null-ls")
        end,
    },
    {
        "sbdchd/neoformat",
    },
    {
        "mfussenegger/nvim-dap",
        optional = true,
        dependencies = {
            {
                "mason.nvim",
                opts = function(_, opts)
                    opts.ensure_installed = opts.ensure_installed or {}
                    vim.list_extend(opts.ensure_installed, { "gomodifytags", "impl", "gofumpt", "goimports-reviser", "delve" })
                end,
            },
            {
                "leoluz/nvim-dap-go",
                config = true,
            },
        },
    },
    {
        "lukas-reineke/headlines.nvim",
        enabled = false,
        opts = function()
            local opts = {}
            for _, ft in ipairs({ "markdown", "norg", "rmd", "org" }) do
                opts[ft] = {
                    headline_highlights = {},
                }
                for i = 1, 6 do
                    local hl = "Headline" .. i
                    vim.api.nvim_set_hl(0, hl, { link = "Headline", default = true })
                    table.insert(opts[ft].headline_highlights, hl)
                end
            end
            return opts
        end,
        ft = { "markdown", "norg", "rmd", "org" },
        config = function(_, opts)
            -- PERF: schedule to prevent headlines slowing down opening a file
            vim.schedule(function()
                require("headlines").setup(opts)
                require("headlines").refresh()
            end)
        end,
    },
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        build = ":Copilot auth",
        opts = {
            suggestion = { enabled = false },
            panel = { enabled = false },
            filetypes = {
                markdown = true,
                help = true,
            },
        },
    },
    {
        "nvim-cmp",
        dependencies = {
            {
                "zbirenbaum/copilot-cmp",
                dependencies = "copilot.lua",
                opts = {},
                config = function(_, opts)
                    local copilot_cmp = require("copilot_cmp")
                    copilot_cmp.setup(opts)
                    -- attach cmp source whenever copilot attaches
                    -- fixes lazy-loading issues with the copilot cmp source
                    require("lazyvim.util").lsp.on_attach(function(client)
                        if client.name == "copilot" then
                            copilot_cmp._on_insert_enter({})
                        end
                    end)
                end,
            },
            'L3MON4D3/LuaSnip',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-nvim-lsp-signature-help',
            'hrsh7th/cmp-nvim-lua',
            'jessarcher/cmp-path',
            'onsails/lspkind-nvim',
            'saadparwaiz1/cmp_luasnip',
        },
        ---@param opts cmp.ConfigSchema
        opts = function(_, opts)
            table.insert(opts.sources, 1, {
                name = "copilot",
                group_index = 1,
                priority = 100,
            })
        end,
        config = function()
            require('plugins.custom.cmp')
        end,
    }
}
--use({
--    'tommcdo/vim-lion',
--    config = function()
--        require('user.plugins.lion')
--    end,
--})
--
--use({
--    'whatyouhide/vim-textobj-xmlattr',
--    requires = 'kana/vim-textobj-user',
--})
--
--use({
--    'sickill/vim-pasta',
--    config = function()
--        require('user.plugins.pasta')
--    end,
--})
--
--use({
--    'famiu/bufdelete.nvim',
--    config = function()
--        vim.keymap.set('n', '<Leader>q', ':Bdelete<CR>')
--    end,
--})
--
--use({
--    'lukas-reineke/indent-blankline.nvim',
--    config = function()
--        require('user.plugins.indent-blankline')
--    end,
--})
--
--use({
--    'AndrewRadev/splitjoin.vim',
--    config = function()
--        require('user.plugins.splitjoin')
--    end,
--})
--
--use({
--    'windwp/nvim-autopairs',
--    config = function()
--        require('nvim-autopairs').setup()
--    end,
--})
--
--use({
--    'akinsho/bufferline.nvim',
--    requires = 'kyazdani42/nvim-web-devicons',
--    config = function()
--        require('user.plugins.bufferline')
--    end,
--})
--
--use({
--    'nvim-lualine/lualine.nvim',
--    requires = 'kyazdani42/nvim-web-devicons',
--    config = function()
--        require('user.plugins.lualine')
--    end,
--})
--use({
--    'zbirenbaum/copilot.lua',
--    cmd = 'Copilot',
--    after = { 'lualine.nvim' },
--    config = function()
--        vim.defer_fn(function()
--            require('copilot').setup({
--                suggestion = { enabled = false },
--                panel = { enabled = false },
--            })
--        end, 100)
--    end,
--})
--use({
--    'zbirenbaum/copilot-cmp',
--    after = { 'copilot.lua' },
--    config = function()
--        require('copilot_cmp').setup({
--            method = 'getCompletionsCycling',
--        })
--    end,
--})
--
--use({
--    'kyazdani42/nvim-tree.lua',
--    requires = 'kyazdani42/nvim-web-devicons',
--    config = function()
--        require('user.plugins.nvim-tree')
--    end,
--})
--
--use({
--    'karb94/neoscroll.nvim',
--    config = function()
--        require('user.plugins.neoscroll')
--    end,
--})
--
--use({
--    'vim-test/vim-test',
--    config = function()
--        require('user.plugins.vim-test')
--    end,
--})
--
--use({
--    'voldikss/vim-floaterm',
--    config = function()
--        require('user.plugins.floaterm')
--    end,
--})
--use({
--    'nvim-telescope/telescope.nvim',
--    requires = {
--        { 'nvim-lua/plenary.nvim' },
--        { 'kyazdani42/nvim-web-devicons' },
--        { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
--        { 'nvim-telescope/telescope-live-grep-args.nvim' },
--    },
--    config = function()
--        require('user.plugins.telescope')
--    end,
--})
--
--use({
--    'nvim-treesitter/nvim-treesitter',
--    run = ':TSUpdate',
--    requires = {
--        'nvim-treesitter/playground',
--        'nvim-treesitter/nvim-treesitter-textobjects',
--        'JoosepAlviste/nvim-ts-context-commentstring',
--    },
--    config = function()
--        require('user.plugins.treesitter')
--    end,
--})
--
--use({
--    'tpope/vim-fugitive',
--    requires = 'tpope/vim-rhubarb',
--    cmd = 'G',
--})
--
--use({
--    'lewis6991/gitsigns.nvim',
--    requires = 'nvim-lua/plenary.nvim',
--    config = function()
--        require('gitsigns').setup({
--            sign_priority = 20,
--            on_attach = function(bufnr)
--                vim.keymap.set('n', ']h', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", { expr = true, buffer = bufnr })
--                vim.keymap.set('n', '[h', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", { expr = true, buffer = bufnr })
--            end,
--        })
--    end,
--})
--use({
--    'weilbith/nvim-code-action-menu',
--    cmd = 'CodeActionMenu',
--})
--
---- use {
----   'j-hui/fidget.nvim',
----   config = function()
----     require('fidget').setup{
----       align = {
----         bottom = false
----       }
----     }
----   end,
---- }
--
--use({
--    'L3MON4D3/LuaSnip',
--    config = function()
--        require('user.plugins.luasnip')
--    end,
--})
--use({
--    'phpactor/phpactor',
--    branch = 'master',
--    ft = 'php',
--    run = 'composer install --no-dev -o',
--    config = function()
--        require('user.plugins.phpactor')
--    end,
--})
--
---- Experimental
--
--
---- use({
----   'glepnir/dashboard-nvim',
----   config = function()
----     require('user.plugins.dashboard')
----   end,
---- })
--
--use({
--    'danymat/neogen',
--    config = function()
--        require('neogen').setup({})
--    end,
--    requires = 'nvim-treesitter/nvim-treesitter',
--})
--
--use({
--    'sheerun/vim-polyglot',
--})
--
---- Rename in a popup window
--use({
--    'hood/popui.nvim',
--    requires = 'RishabhRD/popfix',
--    config = function()
--        vim.ui.select = require('popui.ui-overrider')
--        vim.ui.input = require('popui.input-overrider')
--    end,
--})
--
--use({
--    'folke/trouble.nvim',
--    requires = 'kyazdani42/nvim-web-devicons',
--    config = function()
--        require('trouble').setup()
--    end,
--})
--
--use({
--    'antoinemadec/FixCursorHold.nvim',
--    config = function()
--        vim.g.cursorhold_updatetime = 100
--    end,
--})
--use('neovim/nvim-lspconfig')
--use({
--    'jose-elias-alvarez/null-ls.nvim',
--    requires = {
--        'nvim-lua/plenary.nvim',
--        'neovim/nvim-lspconfig',
--        'b0o/schemastore.nvim',
--    },
--    config = function()
--        require('user.plugins.null-ls')
--    end,
--})
--use({
--    'jay-babu/mason-null-ls.nvim',
--    after = 'null-ls.nvim',
--    config = function()
--        require('mason-null-ls').setup({
--            automatic_setup = true,
--        })
--    end,
--})
--use({
--    'MunifTanjim/prettier.nvim',
--    requires = {
--        'neovim/nvim-lspconfig',
--        'jose-elias-alvarez/null-ls.nvim',
--    },
--    config = function()
--        require('user.plugins.prettier')
--    end,
--})
--use({
--    'ray-x/go.nvim',
--    config = function()
--        require('go').setup()
--    end,
--})
--use('ray-x/guihua.lua') -- recommended if need floating window support
--
--use({
--    'hrsh7th/nvim-cmp',
--    requires = {
--        'L3MON4D3/LuaSnip',
--        'hrsh7th/cmp-buffer',
--        'hrsh7th/cmp-cmdline',
--        'hrsh7th/cmp-nvim-lsp',
--        'hrsh7th/cmp-nvim-lsp-signature-help',
--        'hrsh7th/cmp-nvim-lua',
--        'jessarcher/cmp-path',
--        'onsails/lspkind-nvim',
--        'saadparwaiz1/cmp_luasnip',
--    },
--    config = function()
--        require('user.plugins.cmp')
--    end,
--})
--use({
--    'iamcco/markdown-preview.nvim',
--    ft = 'markdown',
--    run = 'cd app && yarn install',
--})
--use({
--    'EdenEast/nightfox.nvim',
--    config = function()
--        require('user.themes.onehalf')
--    end,
--})
--
--use 'romgrk/barbar.nvim
