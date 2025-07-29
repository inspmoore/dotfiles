--- utils/wezterm.lua -------------------------------------------------------
local M = {}

local is_zellij = os.getenv("ZELLIJ")
local is_wezterm = os.getenv("WEZTERM_EXECUTABLE")
local DIR = { h = "left", l = "right", k = "up", j = "down" }

---@param dir '"h"'|'"j"'|'"k"'|'"l"'
function M.navigate(dir)
  return function()
    local before = vim.api.nvim_get_current_win()
    vim.cmd("wincmd " .. dir) -- 2️⃣
    local after = vim.api.nvim_get_current_win()

    if before == after then -- 3️⃣
      if is_zellij then
        vim.system({ "zellij", "action", "move-focus-or-tab", DIR[dir] })
      elseif is_wezterm then
        vim.system({ "wezterm", "cli", "activate-pane-direction", DIR[dir] })
      end
    end
  end
end

return M
