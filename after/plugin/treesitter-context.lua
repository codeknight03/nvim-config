require 'treesitter-context'.setup {
    enable = true,
    max_lines = 0,
    multiline_threshold = 20,
    trim_scope = 'outer'
}

-- Corrected keymap setting
vim.keymap.set("n", "<leader>ct", function()
    vim.cmd("TSContextToggle")
end, { desc = "Toggle Treesitter Context" }) -- Optional desc for clarity
