return {
  {
    "EdenEast/nightfox.nvim",
    event = { "LazyFile", "VeryLazy" },
    config = function()
      local latitude = 6.99
      local longitude = 79.99
      local sunrise = io.popen("timer " .. latitude .. " " .. longitude .. " sunrise"):read("*all")
      local sunset = io.popen("timer " .. latitude .. " " .. longitude .. " sunset"):read("*all")
      local now = os.time()

      if now > tonumber(sunrise) and now < tonumber(sunset) then
        vim.api.nvim_command("colorscheme dayfox")
      else
        vim.api.nvim_command("colorscheme nightfox")
      end
    end,
  },
}
