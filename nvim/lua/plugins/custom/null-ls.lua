local group = vim.api.nvim_create_augroup('lsp_format_on_save', { clear = false })
local event = 'BufWritePre' -- or "BufWritePost"
local async = event == 'BufWritePost'

require('null-ls').setup({
  sources = {
    require('null-ls').builtins.code_actions.eslint_d.with({
      condition = function(utils)
        return utils.root_has_file({ '.eslintrc.js' })
      end,
    }),
    require('null-ls').builtins.code_actions.gitsigns,
    require('null-ls').builtins.code_actions.proselint,
    require('null-ls').builtins.diagnostics.eslint_d.with({
      condition = function(utils)
        return utils.root_has_file({ '.eslintrc.js' })
      end,
    }),
    require('null-ls').builtins.diagnostics.proselint,
    require('null-ls').builtins.diagnostics.gitlint,
    require('null-ls').builtins.diagnostics.cfn_lint.with({
      filetypes = { 'yaml', 'json' },
    }),
    require('null-ls').builtins.diagnostics.luacheck.with({
      extra_args = { '--config', vim.fn.stdpath('config') .. '/.luacheckrc' },
    }),
    -- require("null-ls").builtins.diagnostics.phpstan,
    require('null-ls').builtins.diagnostics.solhint,
    require('null-ls').builtins.diagnostics.trail_space.with({ disabled_filetypes = { 'NvimTree' } }),
    require('null-ls').builtins.formatting.eslint_d.with({
      condition = function(utils)
        return utils.root_has_file({ '.eslintrc.js' })
      end,
    }),
    require('null-ls').builtins.formatting.prettier.with({
      filetypes = {
        'javascript',
        'typescript',
        'css',
        'scss',
        'html',
        'json',
        'yaml',
        'markdown',
        'graphql',
        'md',
        'txt',
        'svelte',
      },
    }),
    require('null-ls').builtins.formatting.phpcsfixer,
    require('null-ls').builtins.formatting.jq,
    require('null-ls').builtins.formatting.rustywind,
    require('null-ls').builtins.formatting.stylua,
  },
  on_attach = function(client, bufnr)
    if client.supports_method('textDocument/formatting') then
      vim.keymap.set('n', '<Leader>f', function()
        vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
      end, { buffer = bufnr, desc = '[lsp] format' })

      -- format on save
      vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
      vim.api.nvim_create_autocmd(event, {
        buffer = bufnr,
        group = group,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr, async = async })
        end,
        desc = '[lsp] format on save',
      })
    end

    if client.supports_method('textDocument/rangeFormatting') then
      vim.keymap.set('x', '<Leader>f', function()
        vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
      end, { buffer = bufnr, desc = '[lsp] format' })
    end
  end,
})

