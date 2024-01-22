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
  --{
  --  "mfussenegger/nvim-dap",
  --  optional = true,
  --  dependencies = {
  --    {
  --      "mason.nvim",
  --      opts = function(_, opts)
  --        --opts.ensure_installed = opts.ensure_installed or {}
  --        --vim.list_extend(opts.ensure_installed, {
  --        --  "gomodifytags",
  --        --  "impl",
  --        --  "gofumpt",
  --        --  "goimports-reviser",
  --        --  "delve"
  --        --})
  --      end,
  --    },
  --    {
  --      "leoluz/nvim-dap-go",
  --      config = true,
  --    },
  --  },
  --},
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
      -- {
      --   "gnanakeethan/cmp-ai",
      --   dependencies = {
      --     "nvim-lua/plenary.nvim",
      --   },
      --   config = function()
      --     local cmp_ai = require("cmp_ai.config")
      --     cmp_ai:setup({
      --       max_lines = 100,
      --       provider = "Ollama",
      --       provider_options = {
      --         model = "codellama:34b-code",
      --       },
      --       notify = true,
      --       notify_callback = function(msg)
      --         vim.notify(msg)
      --       end,
      --       run_on_every_keystroke = true,
      --       ignored_file_types = {
      --         -- default is not to ignore
      --         -- uncomment to ignore in lua:
      --         -- lua = true
      --       },
      --     })
      --   end,
      -- },
      "L3MON4D3/LuaSnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-path",
      "onsails/lspkind-nvim",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      require("plugins.custom.cmp")
    end,
  },
  {
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-lua/plenary.nvim" },
    "laytan/tailwind-sorter.nvim",
    build = "cd formatter && npm i && npm run build",
    config = true,
  },
  -- {
  --   "gnanakeethan/llm.nvim",
  --   opts = {
  --     tokens_to_clear = { "<EOT>" },
  --     fim = {
  --       enabled = true,
  --       prefix = "<PRE> ",
  --       middle = " <MID>",
  --       suffix = " <SUF>",
  --     },
  --     lsp = {
  --       bin_path = "/Users/gnanakeethan/.cargo/bin/llm-ls",
  --     },
  --     model = "http://localhost:11434/api/generate",
  --     context_window = 4096,
  --     tokenizer = {
  --       repository = "codellama/CodeLlama-34b-hf",
  --     },
  --     request_params = {},
  --     query_params = {
  --       maxNewTokens = 120,
  --       temperature = 0.3,
  --       topP = 0.95,
  --       stopTokens = nil,
  --       doSample = true,
  --     },
  --     adaptor = "ollama",
  --     api_token = "Test",
  --     request_body = { model = "codellama:34b-code" },
  --   },
  -- },
}
