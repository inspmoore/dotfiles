local overrides = require "custom.configs.overrides"

---@type NvPluginSpec[]
local plugins = {

  -- Override plugin definition options
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- format & linting
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          require "custom.configs.null-ls"
        end,
      },
    },
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end, -- Override to setup mason-lspconfig
  },

  -- override plugin configs
  {
    "williamboman/mason.nvim",
    opts = overrides.mason,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  -- Install a plugin
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },
  {
    "phaazon/hop.nvim",
    branch = "v2",
    config = function()
      require "custom.configs.hop"
    end,
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  },
  {
    "RRethy/vim-illuminate",
    lazy = true,
    enabled = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    event = { "CursorMoved", "InsertLeave" },
    config = function()
      require("illuminate").configure {
        active = true,
        on_config_done = nil,
        options = {
          -- providers: provider used to get references in the buffer, ordered by priority
          providers = {
            "lsp",
            "treesitter",
            "regex",
          },
          -- delay: delay in milliseconds
          delay = 120,
          -- filetype_overrides: filetype specific overrides.
          -- The keys are strings to represent the filetype while the values are tables that
          -- supports the same keys passed to .configure except for filetypes_denylist and filetypes_allowlist
          filetype_overrides = {},
          -- filetypes_denylist: filetypes to not illuminate, this overrides filetypes_allowlist
          filetypes_denylist = {
            "dirvish",
            "fugitive",
            "alpha",
            "NvimTree",
            "lazy",
            "neogitstatus",
            "Trouble",
            "lir",
            "Outline",
            "spectre_panel",
            "toggleterm",
            "DressingSelect",
            "TelescopePrompt",
          },
          -- under_cursor: whether or not to illuminate under the cursor
          under_cursor = true,
        },
      }
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup {
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<C-j>",
            next = "<C-l>",
            prev = "<C-h>",
            dismiss = "<C-k>",
          },
        },
      }
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-treesitter.configs").setup {
        autotag = {
          enable = true,
        },
      }
    end,
  },
  {
    "mg979/vim-visual-multi",
    event = "VeryLazy",
  },
  {
    "kevinhwang91/nvim-bqf",
    event = { "BufRead", "BufNew" },
    config = function()
      require("bqf").setup {
        auto_enable = true,
        preview = {
          win_height = 12,
          win_vheight = 12,
          delay_syntax = 80,
          border_chars = { "┃", "┃", "━", "━", "┏", "┓", "┗", "┛", "█" },
        },
        func_map = {
          vsplit = "",
          ptogglemode = "z,",
          stoggleup = "",
        },
        filter = {
          fzf = {
            action_for = { ["ctrl-s"] = "split" },
            extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
          },
        },
      }
    end,
  },
  { "sitiom/nvim-numbertoggle", event = "VeryLazy" },
  -- {
  --   "zbirenbaum/copilot-cmp",
  --   dependencies = { "copilot.lua" },
  --   config = function()
  --     require("copilot").setup {
  --       suggestion = { enabled = false },
  --       panel = { enabled = false },
  --     }
  --   end,
  -- },
  --
  -- {
  --   "zbirenbaum/copilot.lua",
  --   event = "VimEnter",
  --   config = function()
  --     require("copilot").setup {}
  --   end,
  -- },
  -- {
  --   "zbirenbaum/copilot-cmp",
  --   dependencies = { "copilot.lua", "hrsh7th/nvim-cmp" },
  --   config = function()
  --     require("copilot_cmp").setup()
  --   end,
  -- },

  -- To make a plugin not be loaded
  -- {
  --   "NvChad/nvim-colorizer.lua",
  --   enabled = false
  -- },
}

return plugins
