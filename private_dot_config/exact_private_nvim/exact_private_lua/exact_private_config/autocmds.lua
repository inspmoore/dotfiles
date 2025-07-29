-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local auto_command_on = vim.api.nvim_create_autocmd

auto_command_on({ "BufRead", "BufNewFile" }, {
  pattern = { "*.podspec", "Podfile" },
  command = "set filetype=ruby",
})
