return {
  -- disable render-markdown.nvim (from LazyVim markdown extra)
  { "MeanderingProgrammer/render-markdown.nvim", enabled = false },

  -- replace with markview.nvim
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    ft = { "markdown", "Avante" },
    dependencies = { "gunasekar/markview-smart-tables.nvim" },
    opts = {
      -- markview's stock table renderer degrades (or bails entirely) when a
      -- table is wider than the window. Hand tables to smart-tables, which
      -- word-wraps cells so the table fits; it falls back to the stock
      -- renderer whenever it declines.
      renderers = {
        markdown_table = function(buffer, item)
          require("markview-smart-tables").render(buffer, item)
        end,
      },
    },
  },

  {
    "gunasekar/markview-smart-tables.nvim",
    opts = {
      wrap_width = 0.9, -- fit tables to 90% of the window
      wrap_minwidth = 5, -- narrowest a column may shrink before words are broken
    },
  },
}
