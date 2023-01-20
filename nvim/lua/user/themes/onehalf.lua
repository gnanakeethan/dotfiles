local lustrous = require("lustrous")

local function switch_colorscheme(sunrise_time, sunset_time)
  local current_time = os.time()
  if current_time >= sunrise_time and current_time < sunset_time then
    vim.api.nvim_command("colorscheme dayfox")
  else
    vim.api.nvim_command("colorscheme nightfox")
  end
end

local function check_time()
  local lat = 6.91 -- Example latitude
  local lng = 79.99 -- Example longitude
  local date = os.date("*t")
  local zenith = 90.8333 -- Example zenith angle
  local local_offset = 0 -- Example offset in minutes
  local sunrise_time, sunset_time = lustrous.sunturn_time(date, true, lat, lng, zenith, local_offset),
      lustrous.sunturn_time(date, false, lat, lng, zenith, local_offset)
  switch_colorscheme(sunrise_time, sunset_time)
end

vim.schedule(check_time, 30000)
