return {
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
        file_ignore_patterns = {
          "node_modules",
          ".svelte-kit/*",
        },
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--ignore-file",
          ".gitignore",
        },
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
  {
    "sbdchd/neoformat",
    event = "LazyFile",
  },
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { { "nvim-tree/nvim-web-devicons" } },
    opts = function()
      local logo = [[


 ██████╗██╗      ██████╗ ██╗   ██╗██████╗     ██████╗  █████╗ ██████╗  █████╗ ██╗     ██╗      █████╗ ██╗  ██╗    ██╗███╗   ██╗ ██████╗
██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗    ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██║     ██║     ██╔══██╗╚██╗██╔╝    ██║████╗  ██║██╔════╝
██║     ██║     ██║   ██║██║   ██║██║  ██║    ██████╔╝███████║██████╔╝███████║██║     ██║     ███████║ ╚███╔╝     ██║██╔██╗ ██║██║
██║     ██║     ██║   ██║██║   ██║██║  ██║    ██╔═══╝ ██╔══██║██╔══██╗██╔══██║██║     ██║     ██╔══██║ ██╔██╗     ██║██║╚██╗██║██║
╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝    ██║     ██║  ██║██║  ██║██║  ██║███████╗███████╗██║  ██║██╔╝ ██╗    ██║██║ ╚████║╚██████╗
 ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝     ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝╚═╝  ╚═══╝ ╚═════╝

 1111B S Governors Ave STE 21786, Dover, DE 19904


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
              action = LazyVim.pick("files"),
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
              action = [[lua LazyVim.pick.config_files()()]],
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
  {

    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        "stylua",
        "sonarlint-language-server",
        "shfmt",
        "xmlformatter",
        -- "flake8",
      },
    },
  },
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
          settings = {
            redhat = { telemetry = { enabled = false } },
            yaml = {
              keyOrdering = false,
              schemas = {
                ["https://d1uauaxba7bl26.cloudfront.net/latest/gzip/CloudFormationResourceSpecification.json"] = {
                  "/*.cf.yaml",
                  "/*.cf.yml",
                  "/*.cloudformation.yaml",
                  "/*.cloudformation.yml",
                },
              },
              format = {
                enable = true,
              },
              customTags = {
                "!If",
                "!GetAtt",
              },
              validate = true,
              schemaStore = {
                -- Must disable built-in schemaStore support to use
                -- schemas from SchemaStore.nvim plugin
                enable = true,
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
            LazyVim.lsp.on_attach(function(client, _)
              client.server_capabilities.documentFormattingProvider = true
            end, "yamlls")
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
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      dashboard = {
        width = 80,
        preset = {
          header = [[ 
 ▗▄▄▗▖   ▗▄▖▗▖ ▗▗▄▄▄     ▗▄▄▖ ▗▄▖▗▄▄▖ ▗▄▖▗▖  ▗▖   ▗▄▖▗▖  ▗▖
▐▌  ▐▌  ▐▌ ▐▐▌ ▐▐▌  █    ▐▌ ▐▐▌ ▐▐▌ ▐▐▌ ▐▐▌  ▐▌  ▐▌ ▐▌▝▚▞▘ 
▐▌  ▐▌  ▐▌ ▐▐▌ ▐▐▌  █    ▐▛▀▘▐▛▀▜▐▛▀▚▐▛▀▜▐▌  ▐▌  ▐▛▀▜▌ ▐▌  
▝▚▄▄▐▙▄▄▝▚▄▞▝▚▄▞▐▙▄▄▀    ▐▌  ▐▌ ▐▐▌ ▐▐▌ ▐▐▙▄▄▐▙▄▄▐▌ ▐▗▞▘▝▚▖

 1111B S Governors Ave STE 21786, Dover, DE 19904
                ]],
        },
        enabled = true,
        sections = {
          { section = "header", panes = 2 },
          { section = "keys", gap = 1, padding = 1 },
          { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 5 },
          { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
          {
            pane = 2,
            icon = " ",
            title = "Git Status",
            section = "terminal",
            enabled = vim.fn.isdirectory(".git") == 1,
            cmd = "hub status --short --branch --renames",
            height = 5,
            padding = 1,
            ttl = 5 * 60,
            indent = 3,
          },
          { section = "startup" },
        },
      },
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      styles = {
        notification = {
          wo = { wrap = true }, -- Wrap notifications
        },
      },
    },
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
      event_handlers = {

        {
          event = "file_opened",
          handler = function(file_path)
            -- auto close
            -- vimc.cmd("Neotree close")
            -- OR
            require("neo-tree.command").execute({ action = "close" })
          end,
        },
      },
      close_if_last_window = true,
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = true,
        },
        follow_current_file = {
          enabled = true,
          leave_dirs_open = false,
        },
      },
      window = {
        position = "float",
        mappings = {
          ["P"] = { "toggle_preview", config = { use_float = false, use_image_nvim = true } },
        },
      },
    },
  },
  { "terrastruct/d2-vim" },
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
