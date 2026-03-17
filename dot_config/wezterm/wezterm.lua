local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.color_scheme = 'GruvboxDark'

config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

config.font = wezterm.font "JetBrainsMono Nerd Font"

-- https://github.com/wez/wezterm/issues/3032
config.front_end = "OpenGL"

return config
