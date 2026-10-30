<!-- Generated from palette.toml by scripts/generate.lua. Edit the template in templates/PALETTE.md. -->
# Redoctober Palette

Colors are named for the instruments on a submarine console. The tables below say what each color
is used for in the Neovim and Xcode themes.

## Hull (backgrounds, darkest to lightest)

| Name       | Hex           | Used for                              |
|------------|---------------|---------------------------------------|
| `void`     | `{{void}}`    | Dimmed screen edge, shadows           |
| `abyss`    | `{{abyss}}`   | Default background                    |
| `panel`    | `{{panel}}`   | Panels, cursor line, popups           |
| `bezel`    | `{{bezel}}`   | Raised elements, statusline           |
| `bulkhead` | `{{bulkhead}}` | Borders, selected menu rows          |
| `rivet`    | `{{rivet}}`   | Splits, whitespace characters         |

## Ink (foregrounds)

| Name    | Hex         | Used for                                   |
|---------|-------------|--------------------------------------------|
| `chart` | `{{chart}}` | Default text, functions, operators         |
| `fog`   | `{{fog}}`   | Strings, constants, numbers, secondary text |
| `silt`  | `{{silt}}`  | Comments, borders, muted UI                |

## Lamps (accents)

| Name     | Hex          | Used for                                          |
|----------|--------------|---------------------------------------------------|
| `alarm`  | `{{alarm}}`  | Keywords (bold), errors, selection, primary accent |
| `flare`  | `{{flare}}`  | Replace mode, secondary warm accent               |
| `brass`  | `{{brass}}`  | Warnings                                          |
| `sonar`  | `{{sonar}}`  | Success, insert mode, added lines                 |
| `copper` | `{{copper}}` | Types (italic)                                    |
| `steel`  | `{{steel}}`  | Info, links, terminal mode, changed lines         |
| `dusk`   | `{{dusk}}`   | Hints, search and picker matches                  |

## Tints (backgrounds for diffs and diagnostics)

| Name           | Hex                | Used for            |
|----------------|--------------------|---------------------|
| `tint.visual`  | `{{tint.visual}}`  | Visual selection    |
| `tint.alarm`   | `{{tint.alarm}}`   | Deleted lines, errors |
| `tint.sonar`   | `{{tint.sonar}}`   | Added lines, hints  |
| `tint.steel`   | `{{tint.steel}}`   | Changed lines, info |
| `tint.brass`   | `{{tint.brass}}`   | Warnings            |

## Tool-specific shades

Small off-axis colors that individual themes need. Candidates to unify later.

| Name        | Hex             | Used for                          |
|-------------|-----------------|-----------------------------------|
| `pitch`     | `{{pitch}}`     | Zellij frame and title filler     |
| `trench`    | `{{trench}}`    | OpenCode muted background         |
| `silt_dim`  | `{{silt_dim}}`  | Line numbers, OpenCode comments   |
| `sonar_lit` | `{{sonar_lit}}` | OpenCode added-line highlight     |
| `alarm_lit` | `{{alarm_lit}}` | OpenCode removed-line highlight   |

## The look

Syntax highlighting is near-monochrome on purpose. Only two things carry color:

- **Keywords** are `alarm`, bold.
- **Types** are `copper`, italic.

Everything else sits back: strings, constants and numbers in `fog` (strings and constants italic),
functions, operators and variables in `chart`, comments in `silt` italic. The result reads as red,
black and white rather than a rainbow.

`palette.toml` is the source of truth, including the **roles** (what `keyword`, `string`, `error`
and the rest point at) and the ANSI mapping used by terminals.
