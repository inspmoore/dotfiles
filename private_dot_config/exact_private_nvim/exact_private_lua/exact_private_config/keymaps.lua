-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
-- local dmap = vim.keymap.del
-- local Navigator = require("zellij-nav")
-- local FZF = require("fzf-lua")
local wtv = require("utils.wezterm")
-- local Snacks = require("snacks")

-- copy whole buffer with ctrl+c in normal mode
map("n", "<C-c>", ":%y+<CR>")
-- move line up in normal model with alt+k
map("n", "Ż", ":m .-2<CR>==")
-- move line down in normal model with alt+j
map("n", "∆", ":m .+1<CR>==")
-- move line up in visual model with alt+k
map("v", "Ż", ":m '<-2<CR>gv=gv")
-- move line down in visual model with alt+j
map("v", "∆", ":m '>+1<CR>gv=gv")
-- remap redo to U
map("n", "U", "<C-r>")
-- zellij navigation
-- map("n", "<C-j>", Navigator.down)
-- map("n", "<C-k>", Navigator.up)
-- map("n", "<C-h>", Navigator.left)
-- map("n", "<C-l>", Navigator.right)
-- wezterm navigation
map({ "n", "t" }, "<C-j>", wtv.navigate("j"))
map({ "n", "t" }, "<C-k>", wtv.navigate("k"))
map({ "n", "t" }, "<C-h>", wtv.navigate("h"))
map({ "n", "t" }, "<C-l>", wtv.navigate("l"))
-- spectre replace in current files
map("n", "<leader>sf", '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>')

-- spell check
map("n", "<leader>i", Snacks.picker.spelling)
