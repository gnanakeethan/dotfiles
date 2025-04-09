local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action
config.font = wezterm.font("VictorMono Nerd Font Propo", { weight = "Regular" })
config.font_size = 15
config.use_dead_keys = false
config.line_height = 1.4
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- The filled in variant of the < symbol
local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider

-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider
config.window_decorations = "RESIZE"
config.tab_bar_at_bottom = false
-- config.tab_max_width = 16
config.text_blink_rate = 500
config.cursor_blink_rate = 350
config.default_cursor_style = "BlinkingBlock"
config.keys = {
	{ key = "p", mods = "CMD", action = wezterm.action.SendKey({ key = "p", mods = "CTRL" }) },
	-- { key = "w", mods = "CMD", action = wezterm.action.SendKey({ key = "w", mods = "CTRL" }) },
	{ key = "n", mods = "CMD", action = wezterm.action.SendKey({ key = "n", mods = "CTRL" }) },
	{ key = "LeftArrow", mods = "OPT", action = act.SendKey({ key = "b", mods = "ALT" }) },
	{ key = "RightArrow", mods = "OPT", action = act.SendKey({ key = "f", mods = "ALT" }) },
}
local io = require("io")
local latitude = 6.99
local longitude = 79.99
local success, sunrise, stderr =
	wezterm.run_child_process({ wezterm.home_dir .. "/go/bin/timer", latitude, longitude, "sunrise" })
local success, sunset, stderr =
	wezterm.run_child_process({ wezterm.home_dir .. "/go/bin/timer", latitude, longitude, "sunset" })
local now = os.time()
if now > tonumber(sunrise) and now < tonumber(sunset) then
	config.color_scheme = "dayfox"
else
	config.color_scheme = "carbonfox"
end

function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "carbonfox"
	else
		return "dayfox"
	end
end

wezterm.on("window-config-reloaded", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	local appearance = window:get_appearance()
	local scheme = scheme_for_appearance(appearance)
	if overrides.color_scheme ~= scheme then
		overrides.color_scheme = scheme
		window:set_config_overrides(overrides)
	end
end)

wezterm.on("update-right-status", function(window, pane)
	-- "Wed Mar 3 08:14"
	local date = wezterm.strftime("%a %b %-d %H:%M:%S ")

	local bat = ""
	for _, b in ipairs(wezterm.battery_info()) do
		bat = "🔋 " .. string.format("%.0f%%", b.state_of_charge * 100)
	end

	window:set_right_status(wezterm.format({
		{ Text = bat .. "   " .. date },
	}))
end)
config.initial_rows = 50
config.initial_cols = 220
config.force_reverse_video_cursor = true

return config
