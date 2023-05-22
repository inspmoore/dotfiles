---@type MappingsTable
local M = {}

M.disabled = {
  n = {
    ["s"] = "",
    ["S"] = "",
    ["<leader>v"] = "",
    ["<leader>h"] = "",
    ["gr"] = "",
    ["<C-n>"] = "",
  },
  i = {
    ["<C-j>"] = "",
  },
}

M.nvimtree = {
  n = {
    ["U"] = { "<C-R>", "Redo" },
    ["<leader>v"] = { ":vsplit<CR>", "Vertical Split" },
    ["<leader>h"] = { "<cmd>nohlsearch<CR>", "No Highlight" },
    ["<leader>e"] = { ":NvimTreeToggle<CR>", "Toggle File Tree" },
    -- HOP
    ["s"] = {
      function()
        require("hop").hint_words()
      end,
      "HOP hint",
    },
    ["S"] = {
      function()
        require("hop").hint_patterns()
      end,
      "HOP Pattern",
    },
    -- move up/down line(s) in visual mode with Alt-Up/Alt-Dw
    ["Ż"] = { ":<C-u>m-2<cr>==", "Move line up" },
    ["∆"] = { ":<C-u>m+<cr>==", "Move line down" },
    -- +/- increment and decrement the number in normal mode
    ["+"] = { "<C-a>", "Increment number" },
    ["-"] = { "<C-x>", "Decrement number" },
    -- lsp
    ["gr"] = { ":Telescope lsp_references<CR>", "Refrences" },
    -- tmux navigation
    ["<C-h>"] = { "<cmd> TmuxNavigateLeft<CR>", "nav window left" },
    ["<C-l>"] = { "<cmd> TmuxNavigateRight<CR>", "nav window right" },
    ["<C-k>"] = { "<cmd> TmuxNavigateUp<CR>", "nav window up" },
    ["<C-j>"] = { "<cmd> TmuxNavigateDown<CR>", "nav window down" },
  },
  v = {
    -- move up/down line(s) in normal mode with Alt-Up/Alt-Dw
    ["Ż"] = { ":m-2<cr>gv=gv", "Move line up" },
    ["∆"] = { ":m'>+<cr>gv=gv", "Move line down" },
  },
  i = {
    -- remap copilot accept to ctrl j
    -- ["<C-j>"] = { "<silent><script><expr>copilot#Accept<CR>", "Accept Copilot" },
  },
}

-- more keybinds!

return M
