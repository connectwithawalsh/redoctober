local M = {}

--- Apply the colorscheme. Called from colors/redoctober.lua, which Neovim runs
--- after `hi clear` on every `:colorscheme redoctober`, so nothing here needs a
--- ColorScheme autocmd to survive a theme switch.
function M.load()
  if vim.o.background ~= "dark" then
    vim.notify_once("redoctober: no light variant yet, using the dark palette", vim.log.levels.WARN)
  end

  vim.cmd "highlight clear"
  if vim.fn.exists "syntax_on" == 1 then
    vim.cmd "syntax reset"
  end
  vim.g.colors_name = "redoctober"

  local palette = require "redoctober.palette"
  local highlights = require "redoctober.highlights"

  for name, spec in pairs(highlights.groups(palette)) do
    vim.api.nvim_set_hl(0, name, spec)
  end

  for i, hex in ipairs(highlights.terminal(palette)) do
    vim.g["terminal_color_" .. (i - 1)] = hex
  end
end

return M
