-- local autocmd = vim.api.nvim_create_autocmd

vim.g.copilot_assume_mapped = true

-- custom options
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.spell = true
vim.opt.spelloptions:append "camel"
vim.opt.cursorline = true

vim.cmd [[echo "hello world"]]

-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })
