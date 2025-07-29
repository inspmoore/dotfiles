local get_highlight_value = function(dim_elements, hlgroup)
  return table.concat(dim_elements, ":" .. hlgroup .. ",") .. ":" .. hlgroup
end

local merge_tb = function(default, new)
  return vim.tbl_deep_extend("force", default, new)
end

local hex_to_rgb = function(hex)
  hex = hex:gsub("#", "")
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

local rgb_to_hsl = function(r, g, b)
  r, g, b = r / 255, g / 255, b / 255
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, l
  l = (max + min) / 2
  if max == min then
    h, s = 0, 0 -- achromatic
  else
    local d = max - min
    s = l > 0.5 and d / (2 - max - min) or d / (max + min)
    if max == r then
      h = (g - b) / d + (g < b and 6 or 0)
    elseif max == g then
      h = (b - r) / d + 2
    elseif max == b then
      h = (r - g) / d + 4
    end
    h = h / 6
  end
  return h, s, l
end

local hsl_to_rgb = function(h, s, l)
  local hue2rgb = function(p, q, t)
    if t < 0 then
      t = t + 1
    end
    if t > 1 then
      t = t - 1
    end
    if t < 1 / 6 then
      return p + (q - p) * 6 * t
    end
    if t < 1 / 2 then
      return q
    end
    if t < 2 / 3 then
      return p + (q - p) * (2 / 3 - t) * 6
    end
    return p
  end

  local r, g, b
  if s == 0 then
    r, g, b = l, l, l -- achromatic
  else
    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    r = hue2rgb(p, q, h + 1 / 3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1 / 3)
  end
  return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
end

local rgb_to_hex = function(r, g, b)
  return string.format("#%02x%02x%02x", r, g, b)
end

-- Function to dim the color
local dim_color = function(hex, amount)
  local r, g, b = hex_to_rgb(hex)
  local h, s, l = rgb_to_hsl(r, g, b)
  l = l * amount -- Reduce lightness by the amount (0.5 for 50% dimmer)
  r, g, b = hsl_to_rgb(h, s, l)
  return rgb_to_hex(r, g, b)
end

local M = {}

M.config = {
  bgcolor = "#303030",
  highlight_group = "Dimit",
  auto_dim = true,
  dim_elements = {
    "ColorColumn",
    "CursorColumn",
    "CursorLine",
    "CursorLineFold",
    "CursorLineNr",
    "CursorLineSign",
    "EndOfBuffer",
    "FoldColumn",
    "LineNr",
    "NonText",
    "Normal",
    "SignColumn",
    "VertSplit",
    "Whitespace",
    "WinBarNC",
    "WinSeparator",
  },
}

M.dim_inactive = function()
  local config = M.config
  local original_colors = {}

  -- Optionally save the original colors before changing them
  for _, elem in ipairs(config.dim_elements) do
    local hl = vim.api.nvim_get_hl(0, { name = elem })
    print(hl)
    config.original_colors[elem] = hl.bg or "NONE" -- Store the original bg color or "NONE" if not set
  end

  -- Apply the new highlight group with config.bgcolor
  for _, elem in ipairs(config.dim_elements) do
    local original_bg_hex = original_colors[elem] -- This should be a hex color like "#rrggbb"
    if original_bg_hex and original_bg_hex ~= "NONE" then
      local dimmed_color = dim_color(original_bg_hex, 0.5) -- 50% dimmer
      -- Apply `dimmed_color` to your highlight group or directly as needed
      vim.api.nvim_set_hl(0, config.highlight_group, { bg = dimmed_color })
    end
  end

  local current = vim.api.nvim_get_current_win()
  local dim_value = get_highlight_value(config.dim_elements, config.highlight_group)
  for _, w in pairs(vim.api.nvim_list_wins()) do
    local winhighlights = current == w and "" or dim_value
    vim.api.nvim_win_set_option(w, "winhighlight", winhighlights)
  end
  -- vim.api.nvim_set_hl(0, config.highlight_group, { bg = config.bgcolor })
  -- local current = vim.api.nvim_get_current_win()
  -- local dim_value = get_highlight_value(config.dim_elements, config.highlight_group)
  -- for _, w in pairs(vim.api.nvim_list_wins()) do
  --     local winhighlights = current == w and "" or dim_value
  --     vim.api.nvim_win_set_option(w, "winhighlight", winhighlights)
  -- end
end

M.setup = function(opts)
  opts = opts == nil and {} or opts
  M.config = merge_tb(M.config, opts)
  M.dim_inactive()
  vim.api.nvim_create_user_command("Dimit", M.dim_inactive, {})
  if not M.config.auto_dim then
    return
  end
  if M.autocmd ~= nil then
    vim.api.nvim_del_autocmd(M.autocmd)
  end
  M.autocmd = vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter", "WinClosed" }, {
    callback = function()
      M.dim_inactive()
    end,
  })
end

return M
