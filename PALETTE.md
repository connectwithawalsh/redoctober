<!-- Generated from palette.toml by scripts/generate.lua. Edit the template in templates/PALETTE.md. -->
# Red October Palette

Colors are named for the instruments on a submarine console. The tables below say what each color
is used for in the Neovim and Xcode themes.

## Hull (backgrounds, darkest to lightest)

| Name       | Hex           | Used for                              |
|------------|---------------|---------------------------------------|
| `void`     | `#141414`    | Dimmed screen edge, shadows           |
| `abyss`    | `#1a1818`   | Default background                    |
| `panel`    | `#282020`   | Panels, cursor line, popups           |
| `bezel`    | `#382828`   | Raised elements, statusline           |
| `bulkhead` | `#443030` | Borders, selected menu rows          |
| `rivet`    | `#4e3434`   | Splits, whitespace characters         |

## Ink (foregrounds)

| Name    | Hex         | Used for                                   |
|---------|-------------|--------------------------------------------|
| `chart` | `#dac8b8` | Default text, functions, operators         |
| `fog`   | `#a09088`   | Strings, constants, numbers, secondary text |
| `silt`  | `#786866`  | Comments, borders, muted UI                |

## Lamps (accents)

| Name     | Hex          | Used for                                          |
|----------|--------------|---------------------------------------------------|
| `alarm`  | `#d47070`  | Keywords (bold), errors, selection, primary accent |
| `flare`  | `#cc8060`  | Replace mode, secondary warm accent               |
| `brass`  | `#c8a870`  | Warnings                                          |
| `sonar`  | `#879a80`  | Success, insert mode, added lines                 |
| `copper` | `#a07864` | Types (italic)                                    |
| `steel`  | `#a18080`  | Info, links, terminal mode, changed lines         |
| `dusk`   | `#bc8490`   | Hints, search and picker matches                  |

## Tints (backgrounds for diffs and diagnostics)

| Name           | Hex                | Used for            |
|----------------|--------------------|---------------------|
| `tint.visual`  | `#3c2424`  | Visual selection    |
| `tint.alarm`   | `#3e2020`   | Deleted lines, errors |
| `tint.sonar`   | `#242e20`   | Added lines, hints  |
| `tint.steel`   | `#20242e`   | Changed lines, info |
| `tint.brass`   | `#2e2a1a`   | Warnings            |

## Tool-specific shades

Small off-axis colors that individual themes need. Candidates to unify later.

| Name        | Hex             | Used for                          |
|-------------|-----------------|-----------------------------------|
| `pitch`     | `#000000`     | Zellij frame and title filler     |
| `trench`    | `#2a1c1c`    | OpenCode muted background         |
| `silt_dim`  | `#726460`  | Line numbers, OpenCode comments   |
| `sonar_lit` | `#909a88` | OpenCode added-line highlight     |
| `alarm_lit` | `#e08080` | OpenCode removed-line highlight   |

## The look

Syntax highlighting is near-monochrome on purpose. Only two things carry color:

- **Keywords** are `alarm`, bold.
- **Types** are `copper`, italic.

Everything else sits back: strings, constants and numbers in `fog` (strings and constants italic),
functions, operators and variables in `chart`, comments in `silt` italic. The result reads as red,
black and white rather than a rainbow.

`palette.toml` is the source of truth, including the **roles** (what `keyword`, `string`, `error`
and the rest point at) and the ANSI mapping used by terminals.
