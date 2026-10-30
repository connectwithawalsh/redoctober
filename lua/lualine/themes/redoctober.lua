local p = require "redoctober.palette"
local c, r = p.base, p.roles

local function mode(bg)
  return {
    a = { fg = r.bg, bg = bg, gui = "bold" },
    b = { fg = r.fg, bg = r.overlay },
    c = { fg = r.fg, bg = r.surface },
  }
end

return {
  normal = mode(r.fg),
  insert = mode(c.sonar),
  visual = mode(c.alarm),
  replace = mode(c.flare),
  command = mode(r.fg),
  terminal = mode(c.steel),
  inactive = {
    a = { fg = r.comment, bg = r.bg },
    b = { fg = r.comment, bg = r.bg },
    c = { fg = r.comment, bg = r.bg },
  },
}
