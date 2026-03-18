--- utils/navigator.lua -------------------------------------------------------
local M = {}

local is_zellij = os.getenv("ZELLIJ")
local is_tmux = os.getenv("TMUX")
local is_wezterm = os.getenv("WEZTERM_EXECUTABLE")
local DIR = { h = "left", l = "right", k = "up", j = "down" }

---@param dir '"h"'|'"j"'|'"k"'|'"l"'
function M.navigate(dir)
  return function()
    local before = vim.api.nvim_get_current_win()
    vim.cmd("wincmd " .. dir)
    local after = vim.api.nvim_get_current_win()

    if before == after then
      if is_zellij then
        vim.system({ "zellij", "action", "move-focus-or-tab", DIR[dir] })
      elseif is_tmux then
        if dir == "h" or dir == "l" then
          vim.system({ os.getenv("HOME") .. "/.config/tmux/move-focus-or-tab.sh", DIR[dir] })
        else
          vim.system({ "tmux", "select-pane", "-" .. ({ j = "D", k = "U" })[dir] })
        end
      elseif is_wezterm then
        vim.system({ "wezterm", "cli", "activate-pane-direction", DIR[dir] })
      end
    end
  end
end

return M
