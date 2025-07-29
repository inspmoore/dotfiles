local M = {}

function M:spell_suggest()
  vim.spell_suggest(require("telescope.themes").get_cursor({}))
end

return M
