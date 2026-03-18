return {
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>e", "<cmd>Yazi<cr>", desc = "Open Yazi (current file)" },
      { "<leader>E", "<cmd>Yazi cwd<cr>", desc = "Open Yazi (cwd)" },
    },
    opts = {
      open_for_directories = true,
      floating_window_scaling_factor = 0.9,
      yazi_floating_window_border = "rounded",
      keymaps = {
        open_file_in_vertical_split = "<c-v>",
      },
      yazi_opened_multiple_files = function(chosen_files)
        for _, file in ipairs(chosen_files) do
          vim.cmd("badd " .. vim.fn.fnameescape(file))
        end
        vim.cmd("buffer " .. vim.fn.fnameescape(chosen_files[1]))
      end,
    },
  },
}
