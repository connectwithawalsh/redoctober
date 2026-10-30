-- Highlight groups for Red October. Colors come from palette.lua (generated from
-- palette.toml); this file holds no hex literals. Shades that sit between two
-- palette colors are blended at load time.
local M = {}

local function to_rgb(hex)
  local n = tonumber(hex:sub(2), 16)
  return math.floor(n / 65536) % 256, math.floor(n / 256) % 256, n % 256
end

--- Mix `a` toward `b` by `t` (0 = a, 1 = b).
local function blend(a, b, t)
  local ar, ag, ab = to_rgb(a)
  local br, bg, bb = to_rgb(b)
  local function mix(x, y)
    return math.floor(x + (y - x) * t + 0.5)
  end
  return ("#%02x%02x%02x"):format(mix(ar, br), mix(ag, bg), mix(ab, bb))
end

M.blend = blend

-- Treesitter: Neovim's built-in links differ (bluish @variable, bold @constant.builtin),
-- so the whole set is spelled out.
local ts_links = {
  ["@attribute"] = "PreProc",
  ["@attribute.builtin"] = "Special",
  ["@boolean"] = "Boolean",
  ["@character"] = "Constant",
  ["@character.special"] = "Special",
  ["@comment"] = "Comment",
  ["@comment.documentation"] = "@comment",
  ["@comment.error"] = "Error",
  ["@comment.note"] = "DiagnosticInfo",
  ["@comment.todo"] = "Todo",
  ["@comment.warning"] = "WarningMsg",
  ["@constant.builtin"] = "Constant",
  ["@constant.macro"] = "Constant",
  ["@constructor"] = "Special",
  ["@constructor.lua"] = "Delimiter",
  ["@diff.delta"] = "DiffChange",
  ["@diff.minus"] = "DiffDelete",
  ["@diff.plus"] = "DiffAdd",
  ["@function"] = "Function",
  ["@function.builtin"] = "Special",
  ["@function.call"] = "@function",
  ["@function.macro"] = "PreProc",
  ["@function.method"] = "@function",
  ["@function.method.call"] = "@function",
  ["@keyword"] = "Keyword",
  ["@keyword.conditional"] = "Statement",
  ["@keyword.conditional.ternary"] = "@keyword.conditional",
  ["@keyword.coroutine"] = "Statement",
  ["@keyword.debug"] = "Special",
  ["@keyword.directive"] = "PreProc",
  ["@keyword.directive.define"] = "@keyword.directive",
  ["@keyword.exception"] = "Statement",
  ["@keyword.function"] = "Statement",
  ["@keyword.import"] = "PreProc",
  ["@keyword.operator"] = "Statement",
  ["@keyword.repeat"] = "Statement",
  ["@keyword.return"] = "Statement",
  ["@keyword.storage"] = "Type",
  ["@label"] = "Statement",
  ["@markup"] = "Special",
  ["@markup.environment"] = "PreProc",
  ["@markup.heading"] = "Title",
  ["@markup.italic"] = "Italic",
  ["@markup.italic.markdown"] = "Italic",
  ["@markup.link"] = "Constant",
  ["@markup.link.label"] = "Special",
  ["@markup.link.url"] = "Constant",
  ["@markup.link.url.markdown"] = "SpecialComment",
  ["@markup.list"] = "Special",
  ["@markup.list.checked"] = "@markup.list",
  ["@markup.list.unchecked"] = "@markup.list",
  ["@markup.math"] = "Special",
  ["@markup.raw"] = "Constant",
  ["@markup.raw.block"] = "@markup.raw",
  ["@markup.raw.markdown"] = "Type",
  ["@markup.strong"] = "Bold",
  ["@markup.title.markdown"] = "Statement",
  ["@markup.underline"] = "Underlined",
  ["@module"] = "Constant",
  ["@module.builtin"] = "@module",
  ["@number"] = "Number",
  ["@number.float"] = "@number",
  ["@operator"] = "Statement",
  ["@property"] = "Identifier",
  ["@punctuation"] = "Delimiter",
  ["@punctuation.bracket"] = "Delimiter",
  ["@punctuation.delimiter"] = "Delimiter",
  ["@punctuation.special"] = "Delimiter",
  ["@punctuation.special.markdown"] = "Special",
  ["@string"] = "String",
  ["@string.documentation"] = "@string",
  ["@string.escape"] = "Special",
  ["@string.escape.markdown"] = "SpecialKey",
  ["@string.regexp"] = "Constant",
  ["@string.special"] = "Special",
  ["@string.special.path"] = "@string.special",
  ["@string.special.symbol"] = "Identifier",
  ["@string.special.url"] = "@string.special",
  ["@tag"] = "Special",
  ["@tag.attribute"] = "@property",
  ["@tag.builtin"] = "Special",
  ["@tag.delimiter"] = "Delimiter",
  ["@type"] = "Type",
  ["@type.builtin"] = "@type",
  ["@type.definition"] = "@type",
  ["@type.qualifier"] = "@type",
  ["@variable"] = "Identifier",
  ["@variable.builtin"] = "Constant",
  ["@variable.member"] = "@variable",
  ["@variable.parameter"] = "@variable",
  ["@variable.parameter.builtin"] = "Special",
  ["@variable.parameter.vimdoc"] = "Type",
}

-- LSP semantic tokens (mostly rust-analyzer modifiers) that Zenbones mapped explicitly.
local lsp_links = {
  ["@lsp.mod.deprecated"] = "DiagnosticDeprecated",
  ["@lsp.type.boolean"] = "@boolean",
  ["@lsp.type.builtinType"] = "@type.builtin",
  ["@lsp.type.class"] = "@type",
  ["@lsp.type.comment"] = "@comment",
  ["@lsp.type.decorator"] = "@attribute",
  ["@lsp.type.deriveHelper"] = "@attribute",
  ["@lsp.type.enum"] = "@type",
  ["@lsp.type.enumMember"] = "@constant",
  ["@lsp.type.escapeSequence"] = "@string.escape",
  ["@lsp.type.event"] = "@type",
  ["@lsp.type.formatSpecifier"] = "@markup.list",
  ["@lsp.type.function"] = "@function",
  ["@lsp.type.generic"] = "@variable",
  ["@lsp.type.interface"] = "@type",
  ["@lsp.type.keyword"] = "Statement",
  ["@lsp.type.lifetime"] = "@keyword.storage",
  ["@lsp.type.macro"] = "@constant.macro",
  ["@lsp.type.method"] = "@function.method",
  ["@lsp.type.modifier"] = "@type.qualifier",
  ["@lsp.type.namespace"] = "@module",
  ["@lsp.type.number"] = "@number",
  ["@lsp.type.operator"] = "@operator",
  ["@lsp.type.parameter"] = "@variable.parameter",
  ["@lsp.type.property"] = "@property",
  ["@lsp.type.regexp"] = "@string.regexp",
  ["@lsp.type.selfKeyword"] = "@variable.builtin",
  ["@lsp.type.selfTypeKeyword"] = "@variable.builtin",
  ["@lsp.type.string"] = "@string",
  ["@lsp.type.struct"] = "@type",
  ["@lsp.type.type"] = "@type",
  ["@lsp.type.typeAlias"] = "@type.definition",
  ["@lsp.type.typeParameter"] = "@type.definition",
  ["@lsp.typemod.class.defaultLibrary"] = "@type.builtin",
  ["@lsp.typemod.enum.defaultLibrary"] = "@type.builtin",
  ["@lsp.typemod.enumMember.defaultLibrary"] = "@constant.builtin",
  ["@lsp.typemod.function.defaultLibrary"] = "@function.builtin",
  ["@lsp.typemod.keyword.async"] = "@keyword.coroutine",
  ["@lsp.typemod.keyword.injected"] = "Statement",
  ["@lsp.typemod.macro.defaultLibrary"] = "@function.builtin",
  ["@lsp.typemod.method.defaultLibrary"] = "@function.builtin",
  ["@lsp.typemod.operator.injected"] = "@operator",
  ["@lsp.typemod.string.injected"] = "@string",
  ["@lsp.typemod.struct.defaultLibrary"] = "@type.builtin",
  ["@lsp.typemod.type.defaultLibrary"] = "@type",
  ["@lsp.typemod.typeAlias.defaultLibrary"] = "@type",
  ["@lsp.typemod.variable.callable"] = "@function",
  ["@lsp.typemod.variable.defaultLibrary"] = "@variable.builtin",
  ["@lsp.typemod.variable.injected"] = "@variable",
  ["@lsp.typemod.variable.static"] = "@constant",
}

---@param p table palette.lua
---@return table<string, table>
function M.groups(p)
  local c, r, t = p.base, p.roles, p.tint

  local identifier = blend(r.identifier, r.fg_dim, 0.5)
  local hot = blend(r.bg, r.error, 0.4) -- search match, diff text

  local g = {
    -- Editor
    Normal = { fg = r.fg, bg = r.bg },
    NormalFloat = { bg = r.surface },
    FloatBorder = { fg = r.comment },
    FloatTitle = { fg = r.fg, bg = r.surface, bold = true },
    FloatShadow = { bg = r.bg_dim },
    FloatShadowThrough = { bg = r.bg_dim },
    Cursor = { fg = r.bg, bg = r.fg },
    lCursor = { fg = r.bg, bg = r.fg_dim },
    CursorLine = { bg = r.surface },
    CursorLineNr = { fg = r.fg, bold = true },
    LineNr = { fg = r.line_nr },
    FoldColumn = { fg = r.line_nr, bold = true },
    Folded = { fg = r.fg_dim, bg = r.overlay },
    ColorColumn = { bg = t.brass },
    Visual = { bg = r.selection },
    Search = { fg = r.fg, bg = hot },
    IncSearch = { fg = r.bg, bg = c.dusk, bold = true },
    Pmenu = { bg = r.surface },
    PmenuSel = { bg = r.border },
    PmenuSbar = { bg = r.guide },
    PmenuThumb = { bg = r.comment },
    PmenuMatch = { bold = true },
    PmenuMatchSel = { bold = true },
    StatusLine = { fg = r.fg, bg = r.overlay },
    StatusLineNC = { fg = r.fg_dim, bg = r.surface },
    WinSeparator = { fg = r.border },
    NonText = { fg = r.guide },
    SpecialKey = { fg = r.guide, italic = true },
    Conceal = { fg = r.fg_dim, italic = true },
    Directory = { bold = true },
    Title = { fg = r.fg, bold = true },
    Error = { fg = r.error },
    ErrorMsg = { fg = r.error },
    StderrMsg = { link = "ErrorMsg" },
    NvimInvalidSpacing = { link = "ErrorMsg" },
    QuickFixLine = { bg = r.overlay, bold = true },
    MoreMsg = { fg = r.ok, bold = true },
    WarningMsg = { fg = r.warning },
    Question = { fg = r.ok, bold = true },
    DiagnosticDeprecated = { sp = r.error, strikethrough = true },
    DiagnosticUnnecessary = { fg = r.comment, italic = true },
    Sneak = { fg = r.fg, bg = hot },
    SneakLabel = { fg = r.bg, bg = c.dusk },
    OkMsg = { fg = r.ok },
    WildMenu = { fg = r.bg, bg = c.dusk },
    TabLineSel = { bold = true },
    Todo = { bold = true, underline = true },
    Underlined = { underline = true },
    Bold = { bold = true },
    Italic = { italic = true },
    SpellBad = { sp = r.error, undercurl = true },
    SpellCap = { sp = r.error, undercurl = true },
    SpellRare = { sp = r.error, undercurl = true },

    -- Syntax: near-monochrome; keywords and types carry the color
    Comment = { fg = r.comment, italic = true },
    SpecialComment = { fg = r.comment },
    Constant = { fg = r.constant, italic = true },
    String = { fg = r.string, italic = true },
    Number = { fg = r.number },
    Boolean = { fg = r.fg, italic = true },
    Function = { fg = r["function"] },
    Identifier = { fg = identifier },
    Statement = { fg = r.keyword, bold = true },
    Keyword = { link = "Statement" },
    PreProc = { link = "Statement" },
    Operator = { fg = r.operator },
    Type = { fg = r.type, italic = true },
    Special = { fg = r.special, bold = true },
    Delimiter = { fg = r.comment },

    -- Diff
    DiffAdd = { bg = r.diff_add },
    DiffChange = { bg = r.diff_change },
    DiffDelete = { bg = r.diff_delete },
    DiffText = { fg = r.fg, bg = hot },
    Added = { fg = r.ok },
    Changed = { fg = r.info },
    Removed = { fg = r.error },
    diffFile = { fg = r.warning, bold = true },
    diffIndexLine = { fg = r.warning },
    diffLine = { fg = r.hint, bold = true },
    diffNewFile = { fg = r.ok, italic = true },
    diffOldFile = { fg = r.error, italic = true },

    -- LSP, help, markdown
    LspInlayHint = { fg = r.comment, bg = r.surface },
    helpHyperTextEntry = { fg = r.fg_dim, bold = true },
    helpHyperTextJump = { fg = identifier, underline = true },
    markdownLinkText = { fg = identifier, underline = true },

    -- Plugins
    GitSignsAdd = { fg = r.ok },
    GitSignsChange = { fg = r.info },
    GitSignsDelete = { fg = r.error },
    BlinkCmpKind = { fg = r.fg_dim },
    CmpItemAbbr = { fg = identifier },
    CmpItemAbbrDeprecated = { fg = r.comment },
    CmpItemAbbrMatch = { fg = r.fg, bold = true },
    CmpItemAbbrMatchFuzzy = { fg = r.fg, bold = true },
    CmpItemKind = { fg = r.fg_dim },
    CmpItemMenu = { fg = r.fg_dim },
    TelescopeBorder = { fg = r.comment },
    TelescopeMatching = { fg = c.dusk, bold = true },
    TelescopeSelectionCaret = { fg = r.error, bg = r.surface },
    SnacksIndent = { fg = r.surface },
    SnacksIndentScope = { fg = r.border },
    SnacksPickerMatch = { fg = c.dusk, bold = true },
    IblIndent = { fg = r.surface },
    IblScope = { fg = r.border },
    FzfLuaBufFlagAlt = { fg = r.info },
    FzfLuaBufFlagCur = { fg = r.warning },
    FzfLuaBufNr = { fg = r.ok },
    FzfLuaFzfMatch = { fg = c.dusk, bold = true },
    FzfLuaHeaderBind = { fg = r.ok },
    FzfLuaHeaderText = { fg = r.warning },
    FzfLuaLiveSym = { fg = r.warning },
    FzfLuaPathColNr = { fg = r.fg_dim, bold = true },
    FzfLuaTabMarker = { fg = r.ok },
    FzfLuaTabTitle = { fg = c.copper },
    HopNextKey = { fg = c.dusk, bold = true, underline = true },
    HopNextKey1 = { fg = c.copper, bold = true, underline = true },
    HopNextKey2 = { fg = r.info },
    HopUnmatched = { fg = r.comment },
    FlashBackdrop = { fg = r.comment },
    FlashLabel = { fg = r.fg, bg = r.guide },
    SneakLabelMask = { fg = r.hint, bg = r.hint },
    ModeMsg = { link = "Normal" }, -- Neovim's default is mint green
    BlinkCmpSource = { fg = c.copper, italic = true },
    BlinkCmpLabelDetail = { fg = c.copper, italic = true },
    NoiceCmdlinePopupBorder = { fg = r.info },
    NoiceCmdlinePopupTitle = { fg = r.info },
    NoiceCmdlinePopupBorderSearch = { fg = r.warning },
    NoiceCmdlineIconSearch = { fg = r.warning },
    GrugFarHelpHeader = { link = "Normal" },
    GrugFarHelpWinActionText = { link = "Normal" },
    GrugFarResultsActionMessage = { link = "Normal" },
    MasonHeader = { fg = r.bg, bg = r.warning, bold = true },
    MasonHighlight = { fg = r.info },
    MasonHighlightBlock = { fg = r.bg, bg = r.info },
    MasonHighlightBlockBold = { fg = r.bg, bg = r.info, bold = true },
    MasonHighlightSecondary = { fg = r.warning },
    MasonHighlightBlockSecondary = { fg = r.bg, bg = r.warning },
    MasonHighlightBlockBoldSecondary = { fg = r.bg, bg = r.warning, bold = true },
    MasonMuted = { fg = r.fg_dim },
    MasonMutedBlock = { fg = r.bg, bg = r.fg_dim },
    MasonMutedBlockBold = { fg = r.bg, bg = r.fg_dim, bold = true },
    NoiceCmdlineIcon = { fg = r.info },
    NoiceCompletionItemKindDefault = { fg = r.fg_dim },
    NeogitHunkHeaderHighlight = { fg = r.fg, bg = r.surface, bold = true },
    RenderMarkdownCode = { bg = r.surface },
    WhichKeySeparator = { fg = r.line_nr },
    GrugFarResultsAddIndicator = { fg = r.ok },
    GrugFarResultsChangeIndicator = { fg = r.info },
    GrugFarResultsRemoveIndicator = { fg = r.error },
    DapBreakpointSign = { fg = r.error, bold = true },
    MiniHipatternsFixme = { fg = r.error, bold = true, reverse = true },
    MiniHipatternsHack = { fg = r.warning, bold = true, reverse = true },
    MiniHipatternsNote = { fg = r.hint, bold = true, reverse = true },
    MiniHipatternsTodo = { fg = r.info, bold = true, reverse = true },

    -- mini.statusline, same mode colors as the lualine theme
    MiniStatuslineModeNormal = { fg = r.bg, bg = r.fg, bold = true },
    MiniStatuslineModeInsert = { fg = r.bg, bg = c.sonar, bold = true },
    MiniStatuslineModeVisual = { fg = r.bg, bg = c.alarm, bold = true },
    MiniStatuslineModeReplace = { fg = r.bg, bg = c.flare, bold = true },
    MiniStatuslineModeCommand = { fg = r.bg, bg = r.fg, bold = true },
    MiniStatuslineModeOther = { fg = r.bg, bg = c.steel, bold = true },
    MiniStatuslineDevinfo = { fg = r.fg, bg = r.overlay },
    MiniStatuslineFileinfo = { fg = r.fg, bg = r.surface },
    MiniStatuslineFilename = { fg = r.fg, bg = r.surface },
    MiniStatuslineInactive = { fg = r.comment, bg = r.bg },
  }

  -- Treesitter overrides that are not plain links
  g["@constant"] = { fg = identifier, bold = true }
  g["@label.vimdoc"] = { fg = r.fg_dim, bold = true }
  g["@markup.heading.1.delimiter.vimdoc"] = { fg = r.bg, bg = r.bg }
  g["@markup.heading.2.delimiter.vimdoc"] = { fg = r.bg, bg = r.bg, underline = true }
  g["@markup.link.markdown"] = { fg = identifier, underline = true }
  g["@markup.link.vimdoc"] = { fg = identifier, underline = true }
  g["@markup.quote"] = { fg = r.string }
  g["@markup.raw.block.vimdoc"] = {}
  g["@markup.strikethrough"] = { strikethrough = true }
  g["@none"] = {}
  g["@lsp.type.variable"] = {} -- let Treesitter color variables
  g["@lsp.type.unresolvedReference"] = {}
  g["@lsp.mod.deprecated"] = { fg = r.warning }
  for _, links in ipairs { ts_links, lsp_links } do
    for name, target in pairs(links) do
      g[name] = { link = target }
    end
  end

  -- Diagnostics: one block per severity
  local levels = {
    Error = { r.error, t.alarm },
    Warn = { r.warning, t.brass },
    Info = { r.info, t.steel },
    Hint = { r.hint, t.sonar },
    Ok = { r.ok, t.sonar },
  }
  for level, colors in pairs(levels) do
    local fg, line_bg = colors[1], colors[2]
    g["Diagnostic" .. level] = { fg = fg }
    g["DiagnosticSign" .. level] = { fg = fg }
    g["DiagnosticUnderline" .. level] = { sp = fg, undercurl = true }
    g["DiagnosticVirtualText" .. level] = { fg = fg, bg = blend(r.bg, fg, 0.08) }
    g["Diagnostic" .. level .. "Line"] = { bg = line_bg }
  end

  return g
end

--- ANSI colors for :terminal, in slot order 0-15.
---@param p table palette.lua
---@return string[]
function M.terminal(p)
  local order = {
    "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white",
    "bright_black", "bright_red", "bright_green", "bright_yellow",
    "bright_blue", "bright_magenta", "bright_cyan", "bright_white",
  }
  return vim.tbl_map(function(name)
    return p.ansi[name]
  end, order)
end

return M
