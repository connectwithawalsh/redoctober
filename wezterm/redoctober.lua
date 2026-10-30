local colors = {
  foreground          = "#dac8b8",
  background          = "#1a1818",
  cursor_bg           = "#d47070",
  cursor_fg           = "#1a1818",
  cursor_border       = "#d47070",
  selection_fg        = "#dac8b8",
  selection_bg        = "#382828",
  scrollbar_thumb     = "#382828",
  split               = "#382828",
  compose_cursor      = "#d47070",

  ansi = {
    "#1a1818",  -- black
    "#d47070",  -- red
    "#879a80",  -- green
    "#c8a870",  -- yellow
    "#a18080",  -- blue
    "#bc8490",  -- purple
    "#a07864",  -- cyan
    "#dac8b8",  -- white
  },

  brights = {
    "#382828",  -- bright black
    "#d47070",  -- bright red
    "#879a80",  -- bright green
    "#c8a870",  -- bright yellow
    "#a18080",  -- bright blue
    "#bc8490",  -- bright purple
    "#a07864",  -- bright cyan
    "#dac8b8",  -- bright white
  },

  tab_bar = {
    background = "#1a1818",
    active_tab = {
      bg_color = "#382828",
      fg_color = "#dac8b8",
    },
    inactive_tab = {
      bg_color = "#1a1818",
      fg_color = "#786866",
    },
    inactive_tab_hover = {
      bg_color = "#282020",
      fg_color = "#dac8b8",
    },
    new_tab = {
      bg_color = "#1a1818",
      fg_color = "#786866",
    },
    new_tab_hover = {
      bg_color = "#382828",
      fg_color = "#dac8b8",
    },
  },
}

return colors
