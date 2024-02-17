local group = vim.api.nvim_create_augroup("lsp_format_on_save", { clear = false })
local event = "BufWritePre" -- or "BufWritePost"
local async = event == "BufWritePre"
local null_ls = require("null-ls")

require("null-ls").setup({
  sources = {
    null_ls.builtins.code_actions.eslint_d.with({
      condition = function(utils)
        return utils.root_has_file({ ".eslintrc.js" })
      end,
    }),
    null_ls.builtins.code_actions.gomodifytags,
    null_ls.builtins.code_actions.impl,
    null_ls.builtins.code_actions.gitsigns,
    null_ls.builtins.code_actions.proselint,
    null_ls.builtins.diagnostics.eslint_d.with({
      condition = function(utils)
        return utils.root_has_file({ ".eslintrc.js" })
      end,
    }),
    null_ls.builtins.diagnostics.proselint,
    null_ls.builtins.diagnostics.gitlint,
    null_ls.builtins.diagnostics.cfn_lint.with({ filetypes = { "yaml", "json" } }),
    null_ls.builtins.diagnostics.luacheck.with({
      extra_args = { "--config", vim.fn.stdpath("config") .. "/.luacheckrc" },
    }),
    null_ls.builtins.diagnostics.solhint,
    null_ls.builtins.diagnostics.trail_space.with({ disabled_filetypes = { "NvimTree" } }),
    null_ls.builtins.formatting.eslint_d.with({
      condition = function(utils)
        return utils.root_has_file({ ".eslintrc.js" })
      end,
    }),
    null_ls.builtins.formatting.prettierd.with({
      extra_filetypes = {
        "svelte",
      },
    }),
    null_ls.builtins.formatting.phpcsfixer,
    null_ls.builtins.formatting.jq,
    null_ls.builtins.formatting.rustywind,
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.golines,
    null_ls.builtins.formatting.gofumpt,
    null_ls.builtins.formatting.ruff_format,
    null_ls.builtins.formatting.goimports_reviser,
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      -- vim.keymap.set("n", "<Leader>f", function()
      --     vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
      -- end, { buffer = bufnr, desc = "[lsp] format" })
      --
      -- -- format on save
      -- vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
      -- vim.api.nvim_create_autocmd(event, {
      --     buffer = bufnr,
      --     group = group,
      --     callback = function()
      --         vim.lsp.buf.format({ bufnr = bufnr, async = async })
      --     end,
      --     desc = "[lsp] format on save",
      -- })
    end

    if client.supports_method("textDocument/rangeFormatting") then
      vim.keymap.set("x", "<Leader>f", function()
        vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
      end, { buffer = bufnr, desc = "[lsp] format" })
    end
  end,
})
