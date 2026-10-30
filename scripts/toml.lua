-- Minimal TOML reader for palette.toml. Supports only what that file uses:
--   # comments, [table] / [a.b] headers, and key = "string" pairs.
-- Anything else is an error, so a contributor never gets a silent misparse.
local M = {}

local function strip_comment(line)
  local in_str = false
  for i = 1, #line do
    local ch = line:sub(i, i)
    if ch == '"' then
      in_str = not in_str
    elseif ch == "#" and not in_str then
      return line:sub(1, i - 1)
    end
  end
  return line
end

---@param text string
---@param name? string used in error messages
---@return table
function M.parse(text, name)
  name = name or "toml"
  local root = {}
  local cur = root
  local lineno = 0

  local function fail(msg)
    error(("%s:%d: %s"):format(name, lineno, msg), 0)
  end

  for line in (text .. "\n"):gmatch("(.-)\n") do
    lineno = lineno + 1
    local s = vim.trim(strip_comment(line))
    if s ~= "" then
      local header = s:match "^%[([%w_%.]+)%]$"
      local key, value = s:match '^([%w_]+)%s*=%s*"([^"]*)"$'
      if header then
        cur = root
        for part in header:gmatch "[^%.]+" do
          if type(cur[part]) == "string" then
            fail("table '" .. header .. "' collides with a key")
          end
          cur[part] = cur[part] or {}
          cur = cur[part]
        end
      elseif key then
        if cur[key] ~= nil then
          fail("duplicate key '" .. key .. "'")
        end
        cur[key] = value
      else
        fail("unsupported syntax: " .. s)
      end
    end
  end

  return root
end

---@param path string
---@return table
function M.read(path)
  local f = assert(io.open(path, "r"))
  local text = f:read "*a"
  f:close()
  return M.parse(text, path)
end

return M
