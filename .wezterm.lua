local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.initial_cols = 120
config.initial_rows = 28

config.font_size = 12
config.font = wezterm.font("Hasklug Nerd Font")
-- config.color_scheme = "AdventureTime"
config.color_scheme = "Gruvbox Dark (Gogh)"
-- config.color_scheme = "Gruvbox dark, medium (base16)"

config.default_prog = {
	"C:\\WINDOWS\\System32\\wsl.exe",
	"--distribution",
	"FedoraLinux-43",
	"--cd",
	"~",
}

config.max_fps = 60
config.enable_wayland = false
local act = wezterm.action

config.keys = {
	{
		key = "|",
		mods = "CTRL|SHIFT|ALT",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "]",
		mods = "CTRL",
		action = act.ActivateTabRelative(1),
	},
	{
		key = "[",
		mods = "CTRL",
		action = act.ActivateTabRelative(-1),
	},
	{
		key = "]",
		mods = "ALT",
		action = act.ActivateTabRelative(1),
	},
	{
		key = "[",
		mods = "ALT",
		action = act.ActivateTabRelative(-1),
	},
	{
		key = "l",
		mods = "ALT",
		action = act.ActivateTabRelative(1),
	},
	{
		key = "h",
		mods = "ALT",
		action = act.ActivateTabRelative(-1),
	},
	{
		key = "Enter",
		mods = "ALT",
		action = wezterm.action.DisableDefaultAssignment,
	},
	{
		key = "n",
		mods = "ALT",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "w",
		mods = "ALT",
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
	},
}

-- Finally, return the configuration to wezterm:
return config
