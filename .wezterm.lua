local wezterm = require("wezterm")
local config = {}
local act = wezterm.action

config.keys = {
	-- Clears only the scrollback and leaves the viewport intact.
	-- You won't see a difference in what is on screen, you just won't
	-- be able to scroll back until you've output more stuff on screen.
	-- This is the default behavior.
	{
		key = "K",
		mods = "CMD|SHIFT",
		action = act.ClearScrollback("ScrollbackOnly"),
	},
	-- Clears the scrollback and viewport leaving the prompt line the new first line.
	{
		key = "K",
		mods = "CMD|SHIFT",
		action = act.ClearScrollback("ScrollbackAndViewport"),
	},
	-- Clears the scrollback and viewport, and then sends CTRL-L to ask the
	-- shell to redraw its prompt
	{
		key = "K",
		mods = "CMD|SHIFT",
		action = act.Multiple({
			act.ClearScrollback("ScrollbackAndViewport"),
			act.SendKey({ key = "L", mods = "CTRL" }),
		}),
	},
}
config.font = wezterm.font("VictorMono Nerd Font Propo")
config.font_size = 14
config.use_dead_keys = false
config.line_height = 1.5
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.tab_bar_at_bottom = false
-- config.tab_max_width = 16
config.text_blink_rate = 500
config.cursor_blink_rate = 500
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
	config.color_scheme = "nightfox"
end

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
