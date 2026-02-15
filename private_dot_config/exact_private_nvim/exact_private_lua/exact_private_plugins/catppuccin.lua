return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    require("catppuccin").setup({
      transparent_background = true,
      term_colors = true,
      custom_highlights = function(colors)
        return {
          LazyGitNormal = { bg = colors.base },
          LazyGitBorder = { fg = colors.blue, bg = colors.base },
        }
      end,
    })
    vim.cmd.colorscheme("catppuccin")
    vim.cmd.hi("Comment gui=none")
  end,
}
