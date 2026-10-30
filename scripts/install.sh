#!/bin/sh
# Install Red October for the apps you have, into each app's default directory.
# macOS and Linux. Neovim is not handled here: use your plugin manager (see README).
#
#   scripts/install.sh [--list] [--dry-run] [--link] [--all] [--only a,b]
#
#   --list, --dry-run  show what would happen, change nothing
#   --link             symlink to this clone instead of copying
#   --all              install for every app, even if it was not detected
#   --only a,b         limit to: ghostty zellij yazi bat wezterm meli opencode claude xcode
#
# A different existing file is kept as <name>.bak. Starship and lazygit are merge-only:
# neither can import a theme file, so the script only tells you what to do.
set -eu

root=$(cd "$(dirname "$0")/.." && pwd)
cfg=${XDG_CONFIG_HOME:-$HOME/.config}
dry=0 link=0 all=0 only=""
notes=""

while [ $# -gt 0 ]; do
  case $1 in
    --list|--dry-run) dry=1 ;;
    --link) link=1 ;;
    --all) all=1 ;;
    --only) shift; only=${1:-} ;;
    -h|--help) sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $1 (try --help)" >&2; exit 2 ;;
  esac
  shift
done

wanted() {
  [ -z "$only" ] && return 0
  case ",$only," in *",$1,"*) return 0 ;; *) return 1 ;; esac
}

# found <command-or-/absolute/app/path>...
found() {
  for x in "$@"; do
    case $x in
      /*) [ -d "$x" ] && return 0 ;;
      *) command -v "$x" >/dev/null 2>&1 && return 0 ;;
    esac
  done
  return 1
}

# go <name> <detect>...  -> succeeds if this target should be installed
go() {
  name=$1; shift
  wanted "$name" || return 1
  [ "$all" = 1 ] && return 0
  found "$@" && return 0
  echo "$name: skipped (not found)"
  return 1
}

same() {
  if [ -d "$1" ]; then diff -r "$1" "$2" >/dev/null 2>&1; else cmp -s "$1" "$2"; fi
}

note() { notes="$notes
  $1: $2"; }

# place <name> <src> <dst>
place() {
  if [ "$link" = 1 ]; then
    if [ -L "$3" ] && [ "$(readlink "$3")" = "$2" ]; then echo "$1: already linked"; return; fi
  elif [ -e "$3" ] && [ ! -L "$3" ] && same "$2" "$3"; then
    echo "$1: up to date"; return
  fi
  if [ "$dry" = 1 ]; then
    [ "$link" = 1 ] && v="would link" || v="would copy"
    echo "$1: $v -> $3"; return
  fi
  if [ -L "$3" ]; then
    rm "$3"
  elif [ -e "$3" ]; then
    rm -rf "$3.bak"; mv "$3" "$3.bak"; echo "$1: kept the old one as $3.bak"
  fi
  mkdir -p "$(dirname "$3")"
  if [ "$link" = 1 ]; then ln -s "$2" "$3"; else cp -R "$2" "$3"; fi
  echo "$1: installed -> $3"
}

go ghostty ghostty /Applications/Ghostty.app && {
  place ghostty "$root/ghostty/redoctober" "$cfg/ghostty/themes/redoctober"
  note ghostty 'set `theme = redoctober`'
}

go zellij zellij && {
  place zellij "$root/zellij/redoctober.kdl" "${ZELLIJ_CONFIG_DIR:-$cfg/zellij}/themes/redoctober.kdl"
  note zellij 'set `theme "redoctober"`'
}

go yazi yazi && {
  place yazi "$root/redoctober.yazi" "${YAZI_CONFIG_HOME:-$cfg/yazi}/flavors/redoctober.yazi"
  note yazi 'set `[flavor] dark = "redoctober"` in theme.toml'
}

go bat bat batcat && {
  bat_exe=$(command -v bat || command -v batcat || true)
  if [ -n "$bat_exe" ]; then bat_dir=$("$bat_exe" --config-dir); else bat_dir="$cfg/bat"; fi
  place bat "$root/bat/redoctober.tmTheme" "$bat_dir/themes/redoctober.tmTheme"
  [ "$dry" = 0 ] && [ -n "$bat_exe" ] && "$bat_exe" cache --build >/dev/null 2>&1
  note bat 'use `--theme=redoctober`'
}

go wezterm wezterm /Applications/WezTerm.app && {
  place wezterm "$root/wezterm/redoctober.toml" "$cfg/wezterm/colors/redoctober.toml"
  note wezterm "set config.color_scheme = 'redoctober'"
}

go meli meli && {
  place meli "$root/meli/redoctober.toml" "$cfg/meli/themes/redoctober.toml"
  note meli 'set `theme = "redoctober"` under [terminal]'
}

go opencode opencode && {
  place opencode "$root/opencode/redoctober.json" "$cfg/opencode/themes/redoctober.json"
  note opencode 'set `"theme": "redoctober"` in tui.json'
}

go claude claude && {
  place claude "$root/claude/redoctober.json" "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/themes/redoctober.json"
  note claude 'run /theme and pick Red October (restart once if ~/.claude/themes did not exist)'
}

if [ "$(uname)" = Darwin ]; then
  go xcode /Applications/Xcode.app && {
    xc="$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes"
    place xcode "$root/xcode/redoctober.xccolortheme" "$xc/redoctober.xccolortheme"
    place xcode "$root/xcode/redoctober.xcworkspacecolortheme" "$xc/redoctober.xcworkspacecolortheme"
    note xcode "restart Xcode, then pick redoctober in Settings > Themes"
  }
fi

if wanted lazygit && { [ "$all" = 1 ] || found lazygit; }; then
  note lazygit "merge the gui.theme block from $root/lazygit/redoctober.yml into config.yml, or run lazygit with LG_CONFIG_FILE set to your config.yml and that file, comma-separated"
fi

if wanted starship && { [ "$all" = 1 ] || found starship; }; then
  note starship 'merge starship/redoctober.toml into starship.toml and set palette = "redoctober"'
fi

if [ "$dry" = 0 ] && [ -n "$notes" ]; then
  printf '\nnext:%s\n' "$notes"
fi
