local wezterm = require("wezterm")
local config = {}
config.font = wezterm.font("JetBrains Mono")
config.color_scheme = "Tokyo Night Moon"
config.default_gui_startup_args = { "--window-position", "top-right" }
config.font_size = 9
config.initial_cols = 120
config.initial_rows = 30
config.default_prog = { "/bin/zsh" }
return config
