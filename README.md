# redoctober

> The dark side of the moon has a certain something.

A red, black, and white dark theme. Inspired by the earthy calm of [everforest](https://github.com/sainnhe/everforest) and the tension of *The Hunt for Red October*.

Syntax highlighting is kept to a minimum. Keywords are red and types are copper; everything else is pulled back to a whisper so the palette reads as red, black, and white, not a rainbow. The goal is a workspace that's easy on the eyes, focused, and quietly intentional.

Think of it as the control room of a submarine: dark, focused, with just enough red to remind you what's at stake.

> *"When you reach for the periscope, you want to see what's there, not be blinded by the instruments."*

Dark only, for now. Colors are named for the console instruments; see [PALETTE.md](PALETTE.md).

## Install

### Quick install (macOS and Linux)

Clone the repo and run the installer. It finds the apps you have and copies each theme to that app's default directory.

```sh
git clone https://github.com/connectwithawalsh/redoctober
cd redoctober
scripts/install.sh --list    # see what it found, change nothing
scripts/install.sh           # install for the apps you have
```

| Option | Does |
|---|---|
| `--list`, `--dry-run` | show what would happen |
| `--link` | symlink to the clone instead of copying |
| `--only a,b` | limit to `ghostty,zellij,yazi,bat,wezterm,meli,opencode,claude,xcode` |
| `--all` | install for every app, found or not |

A different existing file is kept as `<name>.bak`. The installer prints the one line each app still needs in its config (for example `theme = redoctober`). Starship is merge-only, so it just tells you what to paste. Neovim and Yazi have their own package install, below. Windows isn't supported yet; copy the files by hand.

### Manual install

Every file is in this repo, so you can also copy them yourself.

### Neovim

No dependencies (no zenbones or lush).

```lua
vim.pack.add { 'https://github.com/connectwithawalsh/redoctober' }
vim.cmd.colorscheme 'redoctober'
```

Other plugin managers work the same way, for example lazy.nvim: `{ 'connectwithawalsh/redoctober', priority = 1000 }`.

It covers Treesitter, LSP semantic tokens, diagnostics, diff, and mini, snacks, blink, gitsigns, fzf-lua and more. Highlights are re-applied on every `:colorscheme redoctober`.

**lualine:** `require('lualine').setup { options = { theme = 'redoctober' } }`

**mini.statusline** colors are set by the colorscheme itself.

### Ghostty

Copy `ghostty/redoctober` to `~/.config/ghostty/themes/redoctober`, then set `theme = redoctober`.

### WezTerm

Copy `wezterm/redoctober.lua` to `~/.config/wezterm/colors/redoctober.lua`:

```lua
config.colors = require 'colors/redoctober'
```

`wezterm/redoctober.toml` is the same scheme in the format of WezTerm's color scheme gallery.

### Zellij

Copy `zellij/redoctober.kdl` to `~/.config/zellij/themes/redoctober.kdl`, then set `theme "redoctober"` in your config. The theme uses Zellij's named-style schema, and selected rows use `alarm` so selection is visible.

### Yazi

```sh
ya pkg add connectwithawalsh/redoctober:redoctober
```

Or copy the `redoctober.yazi/` folder to `~/.config/yazi/flavors/`. Then in `theme.toml`:

```toml
[flavor]
dark = "redoctober"
```

### bat

Copy `bat/redoctober.tmTheme` to `$(bat --config-dir)/themes/`, then run `bat cache --build` and use `--theme=redoctober`.

### Starship

Merge `starship/redoctober.toml` into your `starship.toml` and set `palette = "redoctober"`.

### Meli

Copy `meli/redoctober.toml` to `~/.config/meli/themes/redoctober.toml` and set `theme = "redoctober"` under `[terminal]`.

### OpenCode

Copy `opencode/redoctober.json` to `~/.config/opencode/themes/redoctober.json`, then set `"theme": "redoctober"` in `tui.json`.

### Claude Code

Copy `claude/redoctober.json` to `~/.claude/themes/redoctober.json`, then run `/theme` in Claude Code and pick **redoctober** (restart once if `~/.claude/themes/` didn't exist). It's a custom theme on the `dark` base that recolors the accent, status, diff, message-background and subagent tokens.

### Xcode

Copy both files to `~/Library/Developer/Xcode/UserData/FontAndColorThemes/` and pick **redoctober** in Settings > Themes:

- `xcode/redoctober.xccolortheme` (source editor and console)
- `xcode/redoctober.xcworkspacecolortheme` (Xcode 26 workspace colors)

The `.xccolortheme` colors are written in Generic RGB, which is how Xcode reads them, so they display as the palette hexes.

## How it's built

`palette.toml` is the single source of truth. Every theme file is generated from it, so a color change is one edit and a regenerate.

```
palette.toml        base colors, roles, ANSI mapping
templates/          one template per generated file, with {{placeholders}}
scripts/            generator, tests, color math
lua/, colors/       the Neovim plugin (reads the generated palette.lua)
```

You need Neovim to regenerate or test:

```sh
nvim -l scripts/generate.lua           # regenerate every theme file
nvim -l scripts/generate.lua --check   # fail if a generated file is stale
nvim -l scripts/test.lua               # run the tests
```

Edit `palette.toml` or a template, never a generated file. To add a tool, put an existing theme file in place and run `nvim -l scripts/templatize.lua <path>` to turn its hexes into placeholders.

## License

[MIT](LICENSE). Adjust the colors as you see fit; they're yours now.
