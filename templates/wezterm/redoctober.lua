local colors = {
  foreground          = "{{chart}}",
  background          = "{{abyss}}",
  cursor_bg           = "{{alarm}}",
  cursor_fg           = "{{abyss}}",
  cursor_border       = "{{alarm}}",
  selection_fg        = "{{chart}}",
  selection_bg        = "{{bezel}}",
  scrollbar_thumb     = "{{bezel}}",
  split               = "{{bezel}}",
  compose_cursor      = "{{alarm}}",

  ansi = {
    "{{abyss}}",  -- black
    "{{alarm}}",  -- red
    "{{sonar}}",  -- green
    "{{brass}}",  -- yellow
    "{{steel}}",  -- blue
    "{{dusk}}",  -- purple
    "{{copper}}",  -- cyan
    "{{chart}}",  -- white
  },

  brights = {
    "{{bezel}}",  -- bright black
    "{{alarm}}",  -- bright red
    "{{sonar}}",  -- bright green
    "{{brass}}",  -- bright yellow
    "{{steel}}",  -- bright blue
    "{{dusk}}",  -- bright purple
    "{{copper}}",  -- bright cyan
    "{{chart}}",  -- bright white
  },

  tab_bar = {
    background = "{{abyss}}",
    active_tab = {
      bg_color = "{{bezel}}",
      fg_color = "{{chart}}",
    },
    inactive_tab = {
      bg_color = "{{abyss}}",
      fg_color = "{{silt}}",
    },
    inactive_tab_hover = {
      bg_color = "{{panel}}",
      fg_color = "{{chart}}",
    },
    new_tab = {
      bg_color = "{{abyss}}",
      fg_color = "{{silt}}",
    },
    new_tab_hover = {
      bg_color = "{{bezel}}",
      fg_color = "{{chart}}",
    },
  },
}

return colors
