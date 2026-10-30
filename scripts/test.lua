-- nvim -l scripts/test.lua
local script_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
package.path = script_dir .. "/?.lua;" .. package.path

local toml = require "toml"
local gen = require "generate"

local failures, total = {}, 0

local function test(name, fn)
  total = total + 1
  local ok, err = pcall(fn)
  if not ok then
    table.insert(failures, name .. ": " .. tostring(err))
  end
end

local function throws(fn, pattern)
  local ok, err = pcall(fn)
  assert(not ok, "expected an error")
  assert(tostring(err):find(pattern, 1, true), ("error %q does not contain %q"):format(tostring(err), pattern))
end

local function read(path)
  local f = assert(io.open(path, "r"))
  local text = f:read "*a"
  f:close()
  return text
end

local palette = toml.read(gen.root .. "/palette.toml")
local values = gen.resolve(palette)

test("toml: tables, strings and comments", function()
  local t = toml.parse('# c\n[a]\nx = "#fff" # trailing\n[a.b]\ny = "z"\n')
  assert(t.a.x == "#fff" and t.a.b.y == "z")
end)

test("toml: rejects unsupported syntax", function()
  throws(function() toml.parse "x = 1" end, "unsupported syntax")
end)

test("toml: rejects duplicate keys", function()
  throws(function() toml.parse 'x = "a"\nx = "b"' end, "duplicate key")
end)

test("resolve: every base, role and ansi value is a 6-digit hex", function()
  for key, hex in pairs(values) do
    assert(hex:match "^#%x%x%x%x%x%x$", key .. " = " .. hex)
  end
end)

test("resolve: unknown role reference fails loudly", function()
  throws(function() gen.resolve { base = {}, roles = { x = "nope" } } end, "not a base color")
end)

test("render: unknown placeholder fails loudly", function()
  throws(function() gen.render("{{nope}}", values, "t") end, "unknown placeholder")
end)

test("templates: no literal hex colors, only placeholders", function()
  local dir = gen.root .. "/templates"
  for rel, kind in vim.fs.dir(dir, { depth = 10 }) do
    if kind == "file" then
      assert(not read(dir .. "/" .. rel):find "#%x%x%x%x%x%x", rel .. " has a literal hex")
    end
  end
end)

test("output: every hex in every generated file exists in palette.toml", function()
  local known = {}
  for _, hex in pairs(values) do known[hex] = true end
  for rel, content in pairs(gen.build()) do
    for hex in content:gmatch "#%x%x%x%x%x%x" do
      assert(known[hex:lower()], rel .. " contains " .. hex .. " which is not in the palette")
    end
  end
end)

test("output: generated files on disk are up to date", function()
  for rel, content in pairs(gen.build()) do
    local f = io.open(gen.root .. "/" .. rel, "r")
    assert(f, rel .. " is missing; run nvim -l scripts/generate.lua")
    local disk = f:read "*a"
    f:close()
    assert(disk == content, rel .. " is stale; run nvim -l scripts/generate.lua")
  end
end)

-- Xcode -----------------------------------------------------------------

local color = require "color"

-- Ground truth from AppKit (macOS 27): NSColor(srgbRed:...).usingColorSpace(.genericRGB)
test("color: hex -> Generic RGB matches AppKit", function()
  local truth = {
    ["#d47070"] = { 0.7843952179, 0.3512568176, 0.3648602962 },
    ["#879a80"] = { 0.4572980702, 0.5387148261, 0.4269061089 },
    ["#dac8b8"] = { 0.8190773129, 0.7377929688, 0.6650198698 },
    ["#141414"] = { 0.0634853989, 0.0634853989, 0.0634853989 },
    ["#000000"] = { 0, 0, 0 },
  }
  for hex, want in pairs(truth) do
    local r, g, b = color.generic_from_hex(hex)
    for i, got in ipairs { r, g, b } do
      assert(math.abs(got - want[i]) < 1e-6, ("%s channel %d: %.8f vs AppKit %.8f"):format(hex, i, got, want[i]))
    end
  end
end)

-- Everforest-Dark-Medium: the same colors in its .xccolortheme (legacy floats) and in the
-- .xcworkspacecolortheme Xcode migrated from it (OKLCH). Pins how Xcode reads legacy floats.
test("color: legacy floats -> OKLCH reproduces Xcode's migrated values", function()
  local fixture = {
    { { 0.827451, 0.776471, 0.666667 }, { 0.860712516, 0.034333133, 1.482504809 } },
    { { 0.521569, 0.572549, 0.537255 }, { 0.702315121, 0.017440268, 2.741879328 } },
    { { 0.901961, 0.494118, 0.501961 }, { 0.755288621, 0.108793962, 0.358444699 } },
    { { 0.858824, 0.733333, 0.498039 }, { 0.838887595, 0.076148830, 1.446808865 } },
    { { 0.278431, 0.321569, 0.345098 }, { 0.498194021, 0.017920665, 4.019752834 } },
    { { 0.329412, 0.227451, 0.282353 }, { 0.450354645, 0.043086046, 6.048452041 } },
  }
  for _, case in ipairs(fixture) do
    local L, C, h = color.oklch_from_generic(unpack(case[1]))
    assert(math.abs(L - case[2][1]) < 1e-5 and math.abs(C - case[2][2]) < 1e-5 and math.abs(h - case[2][3]) < 1e-5, "OKLCH mismatch for " .. vim.inspect(case[1]))
  end
end)

test("color: round trips are exact for every palette color", function()
  for key, hex in pairs(values) do
    assert(color.hex_from_generic(color.generic_from_hex(hex)) == hex, key .. " via Generic RGB")
    assert(color.hex_from_oklch(color.oklch_from_hex(hex)) == hex, key .. " via OKLCH")
  end
end)

test("filter: xcode emits Generic RGB floats", function()
  assert(gen.render("{{alarm|xcode}}", values, "t") == "0.784395 0.351257 0.36486 1")
  assert(gen.render("{{ void | xcode }}", values, "t") == "0.063485 0.063485 0.063485 1")
  assert(gen.render("{{pitch|xcode}}", values, "t") == "0 0 0 1")
end)

test("filter: unknown filter fails loudly", function()
  throws(function() gen.render("{{alarm|nope}}", values, "t") end, "unknown filter")
end)

test("xcode: every color string converts back to a palette hex", function()
  local known = {}
  for _, hex in pairs(values) do known[hex] = true end
  local content = gen.build()["xcode/redoctober.xccolortheme"]
  assert(content, "xcode/redoctober.xccolortheme was not generated")
  local count = 0
  for r, g, b, a in content:gmatch "<string>([%d%.]+) ([%d%.]+) ([%d%.]+) ([%d%.]+)</string>" do
    count = count + 1
    assert(a == "1", "unexpected alpha " .. a)
    local hex = color.hex_from_generic(tonumber(r), tonumber(g), tonumber(b))
    assert(known[hex], ("%s %s %s -> %s is not in the palette"):format(r, g, b, hex))
  end
  -- 28 syntax colors plus the top-level color keys
  assert(count >= 28 + 20, "suspiciously few colors: " .. count)
end)

test("xcode: plist is valid and has Xcode's full syntax token set", function()
  local path = gen.root .. "/xcode/redoctober.xccolortheme"
  if vim.fn.executable "plutil" == 1 then
    local res = vim.system({ "plutil", "-lint", path }, { text = true }):wait()
    assert(res.code == 0, "plutil: " .. (res.stdout or "") .. (res.stderr or ""))
    local json = vim.system({ "plutil", "-convert", "json", "-o", "-", path }, { text = true }):wait()
    local theme = vim.json.decode(json.stdout)
    assert(vim.tbl_count(theme.DVTSourceTextSyntaxColors) == 28, "syntax color tokens")
    assert(vim.tbl_count(theme.DVTSourceTextSyntaxFonts) == 28, "syntax font tokens")
  end
end)

-- The override names Xcode 26 itself writes (taken from a migrated Everforest theme)
local WORKSPACE_OVERRIDES = {
  "comment", "currentLineHighlight", "insertionPointColor", "invisibles", "keyword", "keyword.attribute",
  "link", "markdown", "memberDeclaration", "number", "number.character", "otherMember",
  "otherMember.constant", "otherMember.function", "otherMember.variable", "otherType", "otherType.class",
  "otherType.type", "plainText", "preprocessor", "preprocessor.macro", "preprocessor.macroSystem",
  "projectMember", "projectMember.constant", "projectMember.function", "projectMember.variable",
  "projectType", "projectType.class", "projectType.type", "selectedTextBackgroundColor", "string",
  "string.regex", "typeDeclaration",
}

local function workspace()
  return vim.json.decode(gen.build()["xcode/redoctober.xcworkspacecolortheme"])
end

local function oklch_of(entry)
  local c = entry.color or entry.colorWithOpacity or entry.customColor or entry.custom
  return c.lightness.exact, c.chroma.exact, c.hue.radians, c
end

test("xcode workspace: valid JSON with exactly the override names Xcode writes", function()
  local theme = workspace()
  assert(theme.fileVersion == 1 and theme.recipe.colorScheme == "dark")
  local overrides = theme.recipe.palette.colorOverrides
  for _, name in ipairs(WORKSPACE_OVERRIDES) do
    assert(overrides[name], "missing override " .. name)
  end
  assert(vim.tbl_count(overrides) == #WORKSPACE_OVERRIDES, "unexpected extra overrides")
  assert(theme.recipe.palette.primary.hue.intensity and theme.recipe.palette.secondary.custom)
end)

test("xcode workspace: every OKLCH color converts back to a palette hex", function()
  local known = {}
  for _, hex in pairs(values) do known[hex] = true end
  local theme = workspace()
  local entries = { theme.recipe.background, theme.recipe.palette.secondary }
  for _, e in pairs(theme.recipe.palette.colorOverrides) do entries[#entries + 1] = e end
  for _, e in ipairs(entries) do
    local L, C, h, c = oklch_of(e)
    assert(c.gamut == "P3" and c.opacity == 1)
    local hex = color.hex_from_oklch(L, C, h)
    assert(known[hex], ("OKLCH %.4f %.4f %.4f -> %s is not in the palette"):format(L, C, h, hex))
  end
end)

test("xcode: .xccolortheme and .xcworkspacecolortheme agree under Xcode's migration math", function()
  if vim.fn.executable "plutil" ~= 1 then return end
  local json = vim.system({ "plutil", "-convert", "json", "-o", "-", gen.root .. "/xcode/redoctober.xccolortheme" }, { text = true }):wait()
  local editor = vim.json.decode(json.stdout)
  local syntax = editor.DVTSourceTextSyntaxColors
  local overrides = workspace().recipe.palette.colorOverrides
  local pairs_ = {
    plainText = syntax["xcode.syntax.plain"],
    comment = syntax["xcode.syntax.comment"],
    keyword = syntax["xcode.syntax.keyword"],
    string = syntax["xcode.syntax.string"],
    number = syntax["xcode.syntax.number"],
    ["preprocessor"] = syntax["xcode.syntax.preprocessor"],
    typeDeclaration = syntax["xcode.syntax.declaration.type"],
    ["projectType.class"] = syntax["xcode.syntax.identifier.class"],
    ["projectMember.function"] = syntax["xcode.syntax.identifier.function"],
    ["projectMember.constant"] = syntax["xcode.syntax.identifier.constant"],
    insertionPointColor = editor.DVTSourceTextInsertionPointColor,
    invisibles = editor.DVTSourceTextInvisiblesColor,
    currentLineHighlight = editor.DVTSourceTextCurrentLineHighlightColor,
    selectedTextBackgroundColor = editor.DVTSourceTextSelectionColor,
    link = editor.DVTMarkupTextLinkColor,
  }
  for name, floats in pairs(pairs_) do
    local r, g, b = floats:match "([%d%.]+) ([%d%.]+) ([%d%.]+)"
    local mL, mC, mh = color.oklch_from_generic(tonumber(r), tonumber(g), tonumber(b))
    local L, C, h = oklch_of(overrides[name])
    assert(
      math.abs(mL - L) < 1e-4 and math.abs(mC - C) < 1e-4 and math.abs(mh - h) < 1e-3,
      ("%s: editor floats imply OKLCH %.4f %.4f %.4f, workspace has %.4f %.4f %.4f"):format(name, mL, mC, mh, L, C, h)
    )
  end
end)

-- Keys under gui.theme in lazygit's Config.md. lazygit's YAML loader ignores unknown keys silently.
test("lazygit: only documented gui.theme keys, with palette colors", function()
  local known_keys = {}
  for _, k in ipairs {
    "activeBorderColor", "inactiveBorderColor", "searchingActiveBorderColor", "optionsTextColor",
    "selectedLineFgColor", "selectedLineBgColor", "inactiveViewSelectedLineBgColor",
    "cherryPickedCommitFgColor", "cherryPickedCommitBgColor", "markedBaseCommitFgColor",
    "markedBaseCommitBgColor", "unstagedChangesColor", "defaultFgColor", "authorColors", "branchColorPatterns",
  } do
    known_keys[k] = true
  end
  local known_hex = {}
  for _, hex in pairs(values) do known_hex[hex] = true end

  local content = gen.build()["lazygit/redoctober.yml"]
  assert(content:find "^#.-\ngui:\n  theme:\n", "expected a gui.theme block")
  local count = 0
  for line in content:gmatch "[^\n]+" do
    local key = line:match "^    (%w+):"
    if key then
      assert(known_keys[key], "unknown lazygit theme key: " .. key)
      count = count + 1
    end
    for hex in line:gmatch "#%x%x%x%x%x%x" do
      assert(known_hex[hex], hex .. " is not in the palette")
    end
    assert(not line:find "\t", "YAML must not contain tabs")
  end
  assert(count >= 12, "suspiciously few theme keys: " .. count)
end)

-- `ya pkg add` copies exactly these files out of redoctober.yazi/ and fails if any is missing
-- (found by trial against ya 26.9; a missing LICENSE deletes the user's installed flavor).
test("yazi: flavor folder has every file ya pkg add requires", function()
  for _, name in ipairs { "flavor.toml", "tmtheme.xml", "LICENSE", "LICENSE-tmtheme", "README.md", "preview.png" } do
    assert(vim.fn.filereadable(gen.root .. "/redoctober.yazi/" .. name) == 1, "redoctober.yazi/" .. name .. " is missing")
  end
  local license = read(gen.root .. "/LICENSE")
  assert(read(gen.root .. "/redoctober.yazi/LICENSE") == license, "yazi LICENSE differs from the root LICENSE")
  assert(read(gen.root .. "/redoctober.yazi/LICENSE-tmtheme") == license, "yazi LICENSE-tmtheme differs from the root LICENSE")
  local png = read(gen.root .. "/redoctober.yazi/preview.png")
  assert(png:sub(2, 4) == "PNG", "preview.png is not a PNG")
end)

-- Token names from Claude Code's "Create a custom theme" docs. Unknown tokens are silently
-- ignored by Claude Code, so a typo here would be a theme color that never applies.
local CLAUDE_TOKENS = {}
for token in ([[
  claude text inverseText inactive subtle suggestion permission remember success error warning merged
  promptBorder planMode autoAccept bashBorder ide fastMode effortUltra diffAdded diffRemoved diffAddedDimmed
  diffRemovedDimmed diffAddedWord diffRemovedWord userMessageBackground userMessageBackgroundHover
  bashMessageBackgroundColor memoryBackgroundColor selectionBg composerSidebarBackground rate_limit_fill
  rate_limit_empty briefLabelYou briefLabelClaude claudeShimmer warningShimmer permissionShimmer
  promptBorderShimmer inactiveShimmer fastModeShimmer
]]):gmatch "%S+" do
  CLAUDE_TOKENS[token] = true
end
for _, c in ipairs { "red", "blue", "green", "yellow", "purple", "orange", "pink", "cyan" } do
  CLAUDE_TOKENS[c .. "_FOR_SUBAGENTS_ONLY"] = true
end

test("claude: valid theme using only documented tokens and palette colors", function()
  local known = {}
  for _, hex in pairs(values) do known[hex] = true end
  local theme = vim.json.decode(gen.build()["claude/redoctober.json"])
  assert(theme.base == "dark" and theme.name == "Red October")
  for token, hex in pairs(theme.overrides) do
    assert(CLAUDE_TOKENS[token], "unknown Claude Code color token: " .. token)
    assert(known[hex], token .. " = " .. hex .. " is not in the palette")
  end
  -- shimmer variants must travel with their base token (docs: override both)
  for _, base in ipairs { "claude", "warning", "permission", "promptBorder", "inactive", "fastMode" } do
    assert(theme.overrides[base .. "Shimmer"], base .. " is set without " .. base .. "Shimmer")
  end
end)

-- Installer (always run against a sandbox home; env vars keep app tools out of the real config)
local function install(args, home)
  local env = {
    HOME = home,
    XDG_CONFIG_HOME = home .. "/.config",
    XDG_DATA_HOME = home .. "/.local/share",
    BAT_CONFIG_DIR = home .. "/.config/bat",
    BAT_CACHE_PATH = home .. "/.cache/bat",
    YAZI_CONFIG_HOME = home .. "/.config/yazi",
    ZELLIJ_CONFIG_DIR = home .. "/.config/zellij",
    CLAUDE_CONFIG_DIR = home .. "/.claude",
  }
  local cmd = { "sh", gen.root .. "/scripts/install.sh" }
  vim.list_extend(cmd, args)
  local res = vim.system(cmd, { text = true, env = env }):wait()
  return res.code, (res.stdout or "") .. (res.stderr or "")
end

local function sandbox()
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  return dir
end

local function same_file(a, b)
  return read(a) == read(b)
end

test("install: --all copies every theme to its default directory", function()
  local home = sandbox()
  local code, out = install({ "--all" }, home)
  assert(code == 0, out)
  local cfg = home .. "/.config"
  assert(same_file(gen.root .. "/ghostty/redoctober", cfg .. "/ghostty/themes/redoctober"), "ghostty")
  assert(same_file(gen.root .. "/zellij/redoctober.kdl", cfg .. "/zellij/themes/redoctober.kdl"), "zellij")
  assert(same_file(gen.root .. "/redoctober.yazi/flavor.toml", cfg .. "/yazi/flavors/redoctober.yazi/flavor.toml"), "yazi flavor")
  assert(same_file(gen.root .. "/redoctober.yazi/tmtheme.xml", cfg .. "/yazi/flavors/redoctober.yazi/tmtheme.xml"), "yazi tmtheme")
  assert(same_file(gen.root .. "/bat/redoctober.tmTheme", cfg .. "/bat/themes/redoctober.tmTheme"), "bat")
  assert(same_file(gen.root .. "/wezterm/redoctober.toml", cfg .. "/wezterm/colors/redoctober.toml"), "wezterm")
  assert(same_file(gen.root .. "/meli/redoctober.toml", cfg .. "/meli/themes/redoctober.toml"), "meli")
  assert(same_file(gen.root .. "/opencode/redoctober.json", cfg .. "/opencode/themes/redoctober.json"), "opencode")
  assert(same_file(gen.root .. "/claude/redoctober.json", home .. "/.claude/themes/redoctober.json"), "claude")
  if vim.uv.os_uname().sysname == "Darwin" then
    assert(same_file(gen.root .. "/xcode/redoctober.xccolortheme", home .. "/Library/Developer/Xcode/UserData/FontAndColorThemes/redoctober.xccolortheme"), "xcode")
  end
end)

test("install: rerun is a no-op and a changed file is backed up", function()
  local home = sandbox()
  assert(install({ "--only", "ghostty", "--all" }, home) == 0)
  local code, out = install({ "--only", "ghostty", "--all" }, home)
  assert(code == 0 and out:find "up to date", out)
  local dest = home .. "/.config/ghostty/themes/redoctober"
  local f = assert(io.open(dest, "w")); f:write "edited"; f:close()
  assert(install({ "--only", "ghostty", "--all" }, home) == 0)
  assert(read(dest .. ".bak") == "edited", "edited file was not backed up")
  assert(same_file(gen.root .. "/ghostty/redoctober", dest), "not restored")
end)

test("install: --dry-run and --list change nothing, --only filters", function()
  local home = sandbox()
  for _, flag in ipairs { "--dry-run", "--list" } do
    local code = install({ flag, "--all" }, home)
    assert(code == 0)
  end
  assert(vim.fn.isdirectory(home .. "/.config") == 0, "dry run created files")
  assert(install({ "--only", "meli", "--all" }, home) == 0)
  assert(vim.fn.filereadable(home .. "/.config/meli/themes/redoctober.toml") == 1)
  assert(vim.fn.isdirectory(home .. "/.config/ghostty") == 0, "--only installed another target")
end)

test("install: lazygit and starship are merge-only (nothing written, paste-ready blocks printed)", function()
  local home = sandbox()
  local code, out = install({ "--only", "lazygit,starship", "--all" }, home)
  assert(code == 0, out)
  -- the exact content a user needs, so they never have to open the repo
  assert(out:find('palette = "redoctober"', 1, true), "starship palette line")
  assert(out:find("[palettes.redoctober]", 1, true), "starship palette table")
  assert(out:find("gui:\n  theme:", 1, true), "lazygit gui.theme block")
  assert(out:find("activeBorderColor", 1, true), "lazygit theme keys")
  assert(out:find("LG_CONFIG_FILE=", 1, true), "lazygit LG_CONFIG_FILE alternative")
  assert(vim.fn.isdirectory(home .. "/.config") == 0, "a merge-only target wrote files")
end)

test("install: --link symlinks into this clone", function()
  local home = sandbox()
  assert(install({ "--link", "--only", "zellij", "--all" }, home) == 0)
  local dest = home .. "/.config/zellij/themes/redoctober.kdl"
  assert(vim.uv.fs_readlink(dest) == gen.root .. "/zellij/redoctober.kdl", "not a link into the repo")
end)

-- Neovim plugin ---------------------------------------------------------

test("plugin: lua sources hold no literal hex colors", function()
  for _, rel in ipairs {
    "lua/redoctober/highlights.lua",
    "lua/redoctober/init.lua",
    "lua/lualine/themes/redoctober.lua",
    "colors/redoctober.lua",
  } do
    assert(not read(gen.root .. "/" .. rel):find "#%x%x%x%x%x%x", rel .. " has a literal hex")
  end
end)

test("plugin: colorscheme loads with no zenbones or lush", function()
  vim.opt.rtp:prepend(gen.root)
  package.loaded["redoctober"] = nil
  package.loaded["redoctober.highlights"] = nil
  package.loaded["redoctober.palette"] = nil
  vim.cmd.colorscheme "redoctober"
  assert(vim.g.colors_name == "redoctober", "colors_name is " .. tostring(vim.g.colors_name))
  assert(not pcall(require, "lush") and not pcall(require, "zenbones"), "unexpected zenbones/lush on rtp")

  local function hl(name)
    return vim.api.nvim_get_hl(0, { name = name, link = false })
  end
  local function hex(n)
    return ("#%06x"):format(n)
  end
  assert(hex(hl("Normal").bg) == values.abyss, "Normal bg")
  assert(hex(hl("Normal").fg) == values.chart, "Normal fg")
  assert(hex(hl("Statement").fg) == values.alarm and hl("Statement").bold, "Statement")
  assert(hex(hl("Type").fg) == values.copper and hl("Type").italic, "Type")
  assert(hex(hl("@keyword.return").fg) == values.alarm, "treesitter keyword links to Statement")
  assert(hex(hl("@variable").fg) ~= "#e0e2ea", "@variable fell back to Neovim's default")
  assert(vim.g.terminal_color_1 == values.alarm, "terminal red")
end)

test("plugin: reloading after :hi clear restores every group", function()
  local function statement_fg()
    return ("#%06x"):format(vim.api.nvim_get_hl(0, { name = "Statement" }).fg)
  end
  vim.cmd "highlight clear"
  assert(statement_fg() ~= values.alarm, "highlight clear did not reset Statement")
  vim.cmd.colorscheme "redoctober"
  assert(statement_fg() == values.alarm, "Statement not restored")
  assert(vim.api.nvim_get_hl(0, { name = "MiniStatuslineModeNormal" }).bg ~= nil, "mini statusline group lost")
end)

test("plugin: lualine theme has every mode with a/b/c sections", function()
  package.loaded["lualine.themes.redoctober"] = nil
  local theme = dofile(gen.root .. "/lua/lualine/themes/redoctober.lua")
  for _, mode in ipairs { "normal", "insert", "visual", "replace", "command", "terminal", "inactive" } do
    for _, section in ipairs { "a", "b", "c" } do
      local s = theme[mode] and theme[mode][section]
      assert(s and s.fg:match "^#%x%x%x%x%x%x$" and s.bg:match "^#%x%x%x%x%x%x$", mode .. "." .. section)
    end
  end
end)

if #failures > 0 then
  io.stderr:write(("%d of %d tests failed:\n  %s\n"):format(#failures, total, table.concat(failures, "\n  ")))
  os.exit(1)
end
print(("ok: %d tests passed"):format(total))
