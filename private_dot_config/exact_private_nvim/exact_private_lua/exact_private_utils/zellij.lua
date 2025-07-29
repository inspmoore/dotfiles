local M = {}

local function nav(short_direction, direction, action)
  -- Use "move-focus" if action is nil.
  if not action then
    action = "move-focus"
  end

  if action ~= "move-focus" and action ~= "move-focus-or-tab" then
    error("invalid action: " .. action)
  end

  -- get window ID, try switching windows, and get ID again to see if it worked
  local cur_winnr = vim.fn.winnr()
  vim.api.nvim_command("wincmd " .. short_direction)
  local new_winnr = vim.fn.winnr()

  -- if the window ID didn't change, then we didn't switch
  if cur_winnr == new_winnr then
    vim.fn.system("zellij action " .. action .. " " .. direction)
    if vim.v.shell_error ~= 0 then
      error("zellij executable not found in path")
    end
  end
end

return M
