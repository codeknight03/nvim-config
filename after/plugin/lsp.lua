local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.ensure_installed({
  'tsserver',
  'rust_analyzer',
  'gopls',
  'lua_ls',
  'terraformls',
  'tflint',
  'pyright',
  'ruff_lsp',
  'bashls',
  'clangd'
})

-- Fix Undefined global 'vim'
lsp.nvim_workspace()

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['C-p'] = cmp.mapping.select_prev_item(cmp_select),
  ['C-n'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

lsp.set_preferences({
  suggest_lsp_servers = false,
  sign_icons = {
    error = 'E',
    warn = 'W',
    hint = 'H',
    info = 'I'
  }
})

local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

-- Prettier Autoformat for JSON, YAML, Markdown
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.json", "*.yaml", "*.yml", "*.md" },
  callback = function()
    vim.cmd("silent! PrettierAsync") -- Assuming you have Prettier set up as a plugin or external command
  end,
})


-- File-specific indentation rules
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "json",
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.expandtab = true
  end,
})

-- Trailing Whitespace and EOL handling
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    vim.cmd("%s/\\s\\+$//e") -- Remove trailing whitespace
  end,
})

local lsp_format_on_save = function(bufnr)
  vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = augroup,
    buffer = bufnr,
    callback = function()
      vim.lsp.buf.format()
    end,
  })
end

lsp.on_attach(function(client, bufnr)
  lsp_format_on_save(bufnr)
  local opts = { buffer = bufnr, remap = false }

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

lsp.setup()

vim.diagnostic.config({
  virtual_text = true
})
