
-- Change wallpaper
local gears = require("gears")
local wtimer = timer { timeout = 0 }

config.wallpaper = {}
config.wallpaper.directory = "/home/charly/.wallpapers/"
config.wallpaper.current = awful.util.getdir("cache") .. "/current-wallpaper.png"

-- scan directory, and optionally filter outputs
function scandir(directory, filter)
    local i, t, popen = 0, {}, io.popen
    if not filter then
        filter = function(s) return true end
    end
    print(filter)
    for filename in popen('ls -a "'..directory..'"'):lines() do
        if filter(filename) then
            i = i + 1
            t[i] = filename
        end
    end
    return t
end

-- configuration - edit to your liking
wp_timeout  = 600 --seconds
wp_path = config.wallpaper.directory
wp_filter = function(s) return string.match(s,"%.png$") or string.match(s,"%.jpg$") or string.match(s,"%.jpeg$") end
wp_files = scandir(wp_path, wp_filter)
wp_index = math.random( 1, #wp_files)
 
gears.wallpaper.maximized(wp_path .. wp_files[wp_index], s, true)
-- setup the timer
wp_timer = timer { timeout = wp_timeout }
wp_timer:connect_signal("timeout", function()
 
  -- set wallpaper to current index for all screens
  for s = 1, screen.count() do
    gears.wallpaper.maximized(wp_path .. wp_files[wp_index], s, true)
  end
 
  -- stop the timer (we don't need multiple instances running at the same time)
  wp_timer:stop()
 
  -- get next random index
  wp_index = math.random( 1, #wp_files)
 
  --restart the timer
  wp_timer.timeout = wp_timeout
  wp_timer:start()
end)
 
-- initial start when rc.lua is first run
wp_timer:start()


