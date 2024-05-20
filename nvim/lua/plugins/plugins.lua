return {
  { "christoomey/vim-tmux-navigator" },
  { "farmergreg/vim-lastplace" },
  { "tpope/vim-repeat" },
  { "tpope/vim-surround" },
  { "tpope/vim-eunuch" }, -- Adds :Rename, :SudoWrite,
  { "tpope/vim-unimpaired" }, -- Adds [b and other handy mappings,
  { "tpope/vim-sleuth" }, -- Indent autodetection with editorconfig support,
  { "jessarcher/vim-heritage" }, -- Automatically create parent dirs when saving,
  { "nelstrom/vim-visual-star-search" },
  -- { "nvim-tree/nvim-web-devicons" }, -- OPTIONAL: for file icons,
  {
    "telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },
    opts = {
      defaults = {
        preview = {
          mime_hook = function(filepath, bufnr, opts)
            local is_image = function(filepath)
              local image_extensions = { "png", "jpg" } -- Supported image formats
              local split_path = vim.split(filepath:lower(), ".", { plain = true })
              local extension = split_path[#split_path]
              return vim.tbl_contains(image_extensions, extension)
            end
            if is_image(filepath) then
              local term = vim.api.nvim_open_term(bufnr, {})
              local function send_output(_, data, _)
                for _, d in ipairs(data) do
                  vim.api.nvim_chan_send(term, d .. "\r\n")
                end
              end
              vim.fn.jobstart({
                "catimg",
                filepath, -- Terminal image viewer command
              }, { on_stdout = send_output, stdout_buffered = true, pty = true })
            else
              require("telescope.previewers.utils").set_preview_message(bufnr, opts.winid, "Binary cannot be previewed")
            end
          end,
        },
      },
    },
  },
  -- {
  --   "nvim-tree/nvim-tree.lua",
  --   version = "*",
  --   lazy = false,
  --   dependencies = {
  --     "nvim-tree/nvim-web-devicons",
  --   },
  --   config = function()
  --     require("plugins.custom.nvim-tree")
  --   end,
  -- },
  -- formatters
  -- {
  --   "nvimtools/none-ls.nvim",
  --   event = { "BufReadPre", "BufNewFile" },
  --   dependencies = {
  --     "mason.nvim",
  --     "nvimtools/none-ls-extras.nvim",
  --   },
  --   config = function()
  --     require("plugins.custom.null-ls")
  --   end,
  -- },
  {
    "sbdchd/neoformat",
  },
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { { "nvim-tree/nvim-web-devicons" } },
    opts = function()
      local logo = [[




 ██████╗██╗      ██████╗ ██╗   ██╗██████╗     ██████╗  █████╗ ██████╗  █████╗ ██╗     ██╗      █████╗ ██╗  ██╗    ██████╗ ██╗   ██╗████████╗    ██╗  ████████╗██████╗
██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗    ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██║     ██║     ██╔══██╗╚██╗██╔╝    ██╔══██╗██║   ██║╚══██╔══╝    ██║  ╚══██╔══╝██╔══██╗
██║     ██║     ██║   ██║██║   ██║██║  ██║    ██████╔╝███████║██████╔╝███████║██║     ██║     ███████║ ╚███╔╝     ██████╔╝██║   ██║   ██║       ██║     ██║   ██║  ██║
██║     ██║     ██║   ██║██║   ██║██║  ██║    ██╔═══╝ ██╔══██║██╔══██╗██╔══██║██║     ██║     ██╔══██║ ██╔██╗     ██╔═══╝ ╚██╗ ██╔╝   ██║       ██║     ██║   ██║  ██║
╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝    ██║     ██║  ██║██║  ██║██║  ██║███████╗███████╗██║  ██║██╔╝ ██╗    ██║      ╚████╔╝    ██║       ███████╗██║   ██████╔╝
 ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝     ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝       ╚═══╝     ╚═╝       ╚══════╝╚═╝   ╚═════╝
        No 33, Level 12, Park Street, Colombo 03, Sri Lanka



      ]]
      local opts = {
        theme = "doom",
        hide = {
          -- this is taken care of by lualine
          -- enabling this messes up the actual laststatus setting after loading a file
          statusline = false,
        },
        config = {
          header = vim.split(logo, "\n"),
          center = {
            {
              action = LazyVim.telescope("files"),
              desc = " Find File",
              icon = " ",
              key = "f",
            },
            {
              action = "ene | startinsert",
              desc = " New File",
              icon = " ",
              key = "n",
            },
            {
              action = "Telescope oldfiles",
              desc = " Recent Files",
              icon = " ",
              key = "r",
            },
            {
              action = "Telescope live_grep",
              desc = " Find Text",
              icon = " ",
              key = "g",
            },
            {
              action = [[lua LazyVim.telescope.config_files()()]],
              desc = " Config",
              icon = " ",
              key = "c",
            },
            {
              action = 'lua require("persistence").load()',
              desc = " Restore Session",
              icon = " ",
              key = "s",
            },
            {
              action = "LazyExtras",
              desc = " Lazy Extras",
              icon = " ",
              key = "x",
            },
            {
              action = "Lazy",
              desc = " Lazy",
              icon = "󰒲 ",
              key = "l",
            },
            {
              action = "qa",
              desc = " Quit",
              icon = " ",
              key = "q",
            },
          },
          footer = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
          end,
        },
      }
      for _, button in ipairs(opts.config.center) do
        button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
        button.key_format = "  %s"
      end

      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "DashboardLoaded",
          callback = function()
            require("lazy").show()
          end,
        })
      end
      return opts
    end,
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
  { "nvim-neotest/nvim-nio" },
  {
    "glacambre/firenvim",
    -- Lazy load firenvim
    -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
    lazy = not vim.g.started_by_firenvim,
    build = function()
      vim.fn["firenvim#install"](0)
    end,
  },
  {
    "leoluz/nvim-dap-go",
    dependencies = {
      "mfussenegger/nvim-dap",
      "mason.nvim",
    },
    config = function()
      require("dap-go").setup({
        dap_configurations = {
          {
            -- Must be "go" or it will be ignored by the plugin
            type = "go",
            name = "Attach remote",
            mode = "remote",
            request = "attach",
          },
        },
        delve = {
          port = "2345",
        },
      })
    end,
  },
  --{
  --  "mfussenegger/nvim-dap",
  --  dependencies = {
  --
  --    { "mfussenegger/nvim-dap-python",
  --      -- stylua: ignore
  --      keys = {
  --        { "<leader>dPt", function() require('dap-python').test_method() end, desc = "Debug Method", ft = "python" },
  --        { "<leader>dPc", function() require('dap-python').test_class() end, desc = "Debug Class", ft = "python" },
  --      },
  --      config = function()
  --        local path = require("mason-registry").get_package("debugpy"):get_install_path()
  --        require("dap-python").setup(path .. "/venv/bin/python")
  --      end,
  --    },
  --    -- fancy UI for the debugger
  --    {
  --      "rcarriga/nvim-dap-ui",
  --              -- stylua: ignore
  --              keys = {
  --                  { "<leader>du", function()
  --                      require("dapui").toggle({ })
  --                  end, desc = "Dap UI" },
  --                  { "<leader>de", function()
  --                      require("dapui").eval()
  --                  end, desc = "Eval", mode = { "n", "v" } },
  --              },
  --      opts = {},
  --      config = function(_, opts)
  --        -- setup dap config by VsCode launch.json file
  --        -- require("dap.ext.vscode").load_launchjs()
  --        local dap = require("dap")
  --        local dapui = require("dapui")
  --        dapui.setup(opts)
  --        dap.listeners.after.event_initialized["dapui_config"] = function()
  --          dapui.open({})
  --        end
  --        dap.listeners.before.event_terminated["dapui_config"] = function()
  --          dapui.close({})
  --        end
  --        dap.listeners.before.event_exited["dapui_config"] = function()
  --          dapui.close({})
  --        end
  --      end,
  --    },
  --
  --    -- virtual text for the debugger
  --    {
  --      "theHamsta/nvim-dap-virtual-text",
  --      opts = {},
  --    },
  --
  --    -- which key integration
  --    {
  --      "folke/which-key.nvim",
  --      optional = true,
  --      opts = {
  --        defaults = {
  --          ["<leader>d"] = { name = "+debug" },
  --        },
  --      },
  --    },
  --
  --    -- mason.nvim integration
  --    {
  --      "jay-babu/mason-nvim-dap.nvim",
  --      dependencies = "mason.nvim",
  --      cmd = { "DapInstall", "DapUninstall" },
  --      opts = {
  --        -- Makes a best effort to setup the various debuggers with
  --        -- reasonable debug configurations
  --        automatic_installation = true,
  --
  --        -- You can provide additional configuration to the handlers,
  --        -- see mason-nvim-dap README for more information
  --        handlers = {},
  --
  --        -- You'll need to check that you have the required things installed
  --        -- online, please don't ask me how to install them :)
  --        ensure_installed = {
  --          -- Update this to ensure that you have the debuggers for the langs you want
  --        },
  --      },
  --    },
  --    -- golang debugger
  --    {
  --      "leoluz/nvim-dap-go",
  --      config = true,
  --    },
  --  },
  --  config = function()
  --    local Config = require("lazyvim.config")
  --    vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
  --
  --    for name, sign in pairs(Config.icons.dap) do
  --      sign = type(sign) == "table" and sign or { sign }
  --      vim.fn.sign_define(
  --        "Dap" .. name,
  --        { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
  --      )
  --    end
  --  end,
  --},
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- make sure mason installs the server
      servers = {
        yamlls = {
          -- Have to add this for yamlls to understand that we support line folding
          capabilities = {
            textDocument = {
              foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
              },
            },
          },
          -- lazy-load schemastore when needed
          on_new_config = function(new_config)
            new_config.settings.yaml.schemas = vim.tbl_deep_extend(
              "force",
              new_config.settings.yaml.schemas or {},
              require("schemastore").yaml.schemas()
            )
          end,
          settings = {
            redhat = { telemetry = { enabled = false } },
            yaml = {
              keyOrdering = false,
              format = {
                enable = true,
              },
              validate = true,
              customTags = {
                "!Ref",
                "!Sub",
                "!If",
                "!Equals",
                "!Not",
                "!And",
                "!Or",
                "!FindInMap",
                "!Base64",
                "!Cidr",
                "!Select",
                "!Split",
                "!Join",
                "!GetAZs",
                "!GetAtt",
              },
              schemaStore = {
                -- Must disable built-in schemaStore support to use
                -- schemas from SchemaStore.nvim plugin
                enable = false,
                -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                url = "",
              },
            },
          },
        },
      },
      setup = {
        yamlls = function()
          -- Neovim < 0.10 does not have dynamic registration for formatting
          if vim.fn.has("nvim-0.10") == 0 then
            require("lazyvim.util").lsp.on_attach(function(client, _)
              if client.name == "yamlls" then
                client.server_capabilities.documentFormattingProvider = true
              end
            end)
          end
        end,
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
    "nvim-cmp",
    event = { "LazyFile", "VeryLazy" },
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
      --{
      --  "gnanakeethan/cmp-ai",
      --  dependencies = {
      --    "nvim-lua/plenary.nvim",
      --  },
      --  config = function()
      --    local cmp_ai = require("cmp_ai.config")
      --    cmp_ai:setup({
      --      max_lines = 100,
      --      provider = "Ollama",
      --      provider_options = {
      --        model = "codegemma",
      --      },
      --      notify = true,
      --      notify_callback = function(msg)
      --        vim.notify(msg)
      --      end,
      --      run_on_every_keystroke = true,
      --      ignored_file_types = {
      --        -- default is not to ignore
      --        -- uncomment to ignore in lua:
      --        -- lua = true
      --      },
      --    })
      --  end,
      --},
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
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    event = { "LazyFile", "VeryLazy" },
    init = function(plugin)
      -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
      -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
      -- no longer trigger the **nvim-treeitter** module to be loaded in time.
      -- Luckily, the only thins that those plugins need are the custom queries, which we make available
      -- during startup.
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
    end,
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        config = function()
          -- When in diff mode, we want to use the default
          -- vim text objects c & C instead of the treesitter ones.
          local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
          local configs = require("nvim-treesitter.configs")
          for name, fn in pairs(move) do
            if name:find("goto") == 1 then
              move[name] = function(q, ...)
                if vim.wo.diff then
                  local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
                  for key, query in pairs(config or {}) do
                    if q == query and key:find("[%]%[][cC]") then
                      vim.cmd("normal! " .. key)
                      return
                    end
                  end
                end
                return fn(q, ...)
              end
            end
          end
        end,
      },
    },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
      { "<c-space>", desc = "Increment selection" },
      { "<bs>", desc = "Decrement selection", mode = "x" },
    },
    ---@type TSConfig
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      auto_install = true,
      sync_install = true,
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "html",
        "javascript",
        "dockerfile",
        "jsdoc",
        "json",
        "jsonc",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "toml",
        "tsx",
        "go",
        "typescript",
        "svelte",
        "vim",
        "vimdoc",
        "yaml",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      textobjects = {
        move = {
          enable = true,
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
        },
      },
    },
    ---@param opts TSConfig
    config = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        ---@type table<string, boolean>
        local added = {}
        opts.ensure_installed = vim.tbl_filter(function(lang)
          if added[lang] then
            return false
          end
          added[lang] = true
          return true
        end, opts.ensure_installed)
      end
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "vhyrro/luarocks.nvim",
    priority = 1001, -- this plugin needs to run before anything else
    opts = {
      rocks = { "magick" },
    },
  },
  {
    "3rd/image.nvim",
    dependencies = { "luarocks.nvim" },
    opts = {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
          filetypes = { "markdown", "vimwiki" },
        },
        neorg = {
          enabled = true,
          filetypes = { "norg" },
        },
      },
      hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = true,
        },
      },
      window = {
        position = "left",
        mappings = {
          ["P"] = { "toggle_preview", config = { use_float = false, use_image_nvim = true } },
        },
      },
    },
  },
  {
    "laytan/tailwind-sorter.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-lua/plenary.nvim" },
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
