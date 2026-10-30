-- Turn an existing theme file into a template by replacing each hex with its
-- palette name. Use it when adding a new target:
--
--   nvim -l scripts/templatize.lua zellij/redoctober.kdl
--
-- Reads <repo>/<path>, writes <repo>/templates/<path>. Fails if the file holds a
-- hex that is not in palette.toml, so add it there first.
local script_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
package.path = script_dir .. "/?.lua;" .. package.path

local toml = require "toml"
local root = vim.fn.fnamemodify(script_dir, ":h")
local palette = toml.read(root .. "/palette.toml")

-- hex -> placeholder name; base colors win over tints on a shared hex.
local by_hex = {}
local function add(name, hex)
  hex = hex:lower()
  by_hex[hex] = by_hex[hex] or name
end
for key, v in pairs(palette.base) do
  if type(v) == "string" then
    add(key, v)
  end
end
for key, v in pairs(palette.base.tint or {}) do
  add("tint." .. key, v)
end

if #arg == 0 then
  io.stderr:write "usage: nvim -l scripts/templatize.lua <path> [<path>...]\n"
  os.exit(1)
end

local failed = false
for _, rel in ipairs(arg) do
  local f = assert(io.open(root .. "/" .. rel, "r"), "cannot read " .. rel)
  local text = f:read "*a"
  f:close()

  local missing = {}
  local converted = text:gsub("#%x%x%x%x%x%x", function(hex)
    local name = by_hex[hex:lower()]
    if not name then
      missing[hex:lower()] = true
      return hex
    end
    return "{{" .. name .. "}}"
  end)

  if next(missing) then
    failed = true
    io.stderr:write(rel .. ": not in palette.toml: " .. table.concat(vim.tbl_keys(missing), ", ") .. "\n")
  else
    local out = root .. "/templates/" .. rel
    vim.fn.mkdir(vim.fn.fnamemodify(out, ":h"), "p")
    local w = assert(io.open(out, "w"))
    w:write(converted)
    w:close()
    print("template: " .. rel)
  end
end
os.exit(failed and 1 or 0)
