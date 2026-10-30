-- Generate every tool's theme file from palette.toml.
--
--   nvim -l scripts/generate.lua            write generated files
--   nvim -l scripts/generate.lua --check    fail if any file on disk is stale
--
-- Each file under templates/ is rendered to the same relative path in the repo
-- root. Placeholders are {{name}} for a base color, {{tint.name}}, {{role.name}}
-- or {{ansi.name}}. Every placeholder must resolve, or generation fails.
local script_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
package.path = script_dir .. "/?.lua;" .. package.path

local toml = require "toml"

local M = {}

M.root = vim.fn.fnamemodify(script_dir, ":h")

--- Resolve palette.toml into a flat { placeholder = "#hex" } lookup.
---@param palette table parsed palette.toml
---@return table<string, string>
function M.resolve(palette)
  local values = {}

  for key, v in pairs(palette.base) do
    if type(v) == "string" then
      values[key] = v:lower()
    end
  end
  for key, v in pairs(palette.base.tint or {}) do
    values["tint." .. key] = v:lower()
  end

  local function lookup(ref, where)
    local hex = values[ref]
    if not hex then
      error(("%s: '%s' is not a base color or tint"):format(where, ref), 0)
    end
    return hex
  end

  for key, ref in pairs(palette.roles or {}) do
    values["role." .. key] = lookup(ref, "roles." .. key)
  end
  for key, ref in pairs(palette.ansi or {}) do
    values["ansi." .. key] = lookup(ref, "ansi." .. key)
  end

  return values
end

local color = require "color"

local function trim_zeros(s)
  return (s:gsub("0+$", ""):gsub("%.$", ""))
end

--- Output filters, applied as {{name|filter}}.
M.filters = {
  -- "#d47070" -> "r g b 1" in the Generic RGB floats Xcode's .xccolortheme expects,
  -- so Xcode displays exactly the palette hex (see scripts/color.lua)
  xcode = function(hex)
    local r, g, b = color.generic_from_hex(hex)
    return ("%s %s %s 1"):format(trim_zeros(("%.6f"):format(r)), trim_zeros(("%.6f"):format(g)), trim_zeros(("%.6f"):format(b)))
  end,
  -- OKLCH parts for .xcworkspacecolortheme: lightness, chroma, hue in radians
  oklch_l = function(hex)
    return ("%.15g"):format((color.oklch_from_hex(hex)))
  end,
  oklch_c = function(hex)
    return ("%.15g"):format((select(2, color.oklch_from_hex(hex))))
  end,
  oklch_h = function(hex)
    return ("%.15g"):format((select(3, color.oklch_from_hex(hex))))
  end,
}

---@param template string
---@param values table<string, string>
---@param name string
function M.render(template, values, name)
  local function lookup(key)
    local hex = values[key]
    if not hex then
      error(("%s: unknown placeholder {{%s}}"):format(name, key), 0)
    end
    return hex
  end

  -- filtered placeholders first, then plain ones
  template = template:gsub("{{%s*([%w_%.]+)%s*|%s*([%w_]+)%s*}}", function(key, filter)
    local fn = M.filters[filter]
    if not fn then
      error(("%s: unknown filter '%s' in {{%s|%s}}"):format(name, filter, key, filter), 0)
    end
    return fn(lookup(key))
  end)
  return (template:gsub("{{%s*([%w_%.]+)%s*}}", lookup))
end

--- Emit lua/redoctober/palette.lua so the Neovim plugin needs no TOML at runtime.
---@param values table<string, string> from M.resolve
---@return string
function M.lua_palette(values)
  local groups = { base = {}, tint = {}, role = {}, ansi = {} }
  for key, hex in pairs(values) do
    local group, name = key:match "^(%a+)%.(.+)$"
    if group == "tint" or group == "role" or group == "ansi" then
      groups[group][name] = hex
    else
      groups.base[key] = hex
    end
  end

  local lines = { "-- Generated from palette.toml by scripts/generate.lua. Do not edit.", "return {" }
  for _, group in ipairs { "base", "tint", "role", "ansi" } do
    local names = vim.tbl_keys(groups[group])
    table.sort(names)
    table.insert(lines, ("  %s = {"):format(group == "role" and "roles" or group))
    for _, name in ipairs(names) do
      -- bracketed so reserved words like `function` stay valid Lua
      table.insert(lines, ('    ["%s"] = "%s",'):format(name, groups[group][name]))
    end
    table.insert(lines, "  },")
  end
  table.insert(lines, "}")
  return table.concat(lines, "\n") .. "\n"
end

--- Render every template. Returns { [relative_path] = content }.
---@return table<string, string>
function M.build()
  local values = M.resolve(toml.read(M.root .. "/palette.toml"))
  local out = { ["lua/redoctober/palette.lua"] = M.lua_palette(values) }
  local dir = M.root .. "/templates"
  for rel, kind in vim.fs.dir(dir, { depth = 10 }) do
    if kind == "file" then
      local f = assert(io.open(dir .. "/" .. rel, "r"))
      local text = f:read "*a"
      f:close()
      out[rel] = M.render(text, values, rel)
    end
  end
  return out
end

local function read_file(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local text = f:read "*a"
  f:close()
  return text
end

function M.main(argv)
  local check = vim.tbl_contains(argv, "--check")
  local ok, built = pcall(M.build)
  if not ok then
    io.stderr:write(tostring(built), "\n")
    os.exit(1)
  end

  local stale = {}
  local paths = vim.tbl_keys(built)
  table.sort(paths)
  for _, rel in ipairs(paths) do
    local path = M.root .. "/" .. rel
    if read_file(path) ~= built[rel] then
      table.insert(stale, rel)
      if not check then
        vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
        local f = assert(io.open(path, "w"))
        f:write(built[rel])
        f:close()
      end
    end
  end

  if check then
    if #stale > 0 then
      io.stderr:write("stale generated files:\n  " .. table.concat(stale, "\n  ") .. "\n")
      os.exit(1)
    end
    print(("ok: %d generated files up to date"):format(#paths))
  else
    print(("wrote %d of %d files"):format(#stale, #paths))
  end
end

-- Run only when invoked as a script, not when required by the tests.
if arg and arg[0] and arg[0]:find("generate.lua", 1, true) then
  M.main(arg)
end

return M
