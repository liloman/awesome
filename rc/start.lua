-- Setup display
local xrandr = {
   uni = "--output VGA1 --auto --output LVDS1 --auto",
   neo    = "--output HDMI-0 --auto --output DVI-0 --auto --right-of HDMI-0"
}
if xrandr[config.hostname] then
   os.execute("xrandr " .. xrandr[config.hostname])
end

-- Spawn a composoting manager
--awful.util.spawn("xcompmgr", false)

-- Start idempotent commands
local execute = {
   -- Disable numlock
   "numlockx off",
   -- Start PulseAudio
   "pulseaudio --check || pulseaudio -D",
   "xset -b",	-- Disable bell
    --Start power-manager
   "xfce4-power-manager",
   -- "urxvtd -o -f",
   -- "dropbox.py start",
    --"nm-applet",
   -- Read resources
   "xrdb -merge " .. awful.util.getdir("config") .. "/Xresources",
   -- Default browser
   "xdg-mime default " .. config.browser .. ".desktop x-scheme-handler/http",
   "xdg-mime default " .. config.browser .. ".desktop x-scheme-handler/https",
   "xdg-mime default " .. config.browser .. ".desktop text/html"
}

-- Keyboard/Mouse configuration
if config.hostname == "guybrush" then
   execute = awful.util.table.join(
      execute, {
	 -- Keyboard and mouse
	 "setxkbmap us,fr '' compose:ralt ctrl:nocaps grp:rctrl_rshift_toggle",
	 "xmodmap -e 'keysym XF86AudioPlay = XF86ScreenSaver'",
	 -- Wheel emulation
	 "xinput set-int-prop 'TPPS/2 IBM TrackPoint' 'Evdev Wheel Emulation' 8 1",
	 "xinput set-int-prop 'TPPS/2 IBM TrackPoint' 'Evdev Wheel Emulation Button' 8 2",
	 "xinput set-int-prop 'TPPS/2 IBM TrackPoint' 'Evdev Wheel Emulation Axes' 8 6 7 4 5",
	 -- Disable touchpad
	 "xinput set-int-prop 'SynPS/2 Synaptics TouchPad' 'Synaptics Off' 8 1"})
else  --config.hostname == "wheezy" then
   execute = awful.util.table.join(
      execute, {
	 -- Keyboard and mouse
	 "xset m 4 3",	-- Mouse acceleration
	 "xmodmap -e 'keysym Pause = XF86ScreenSaver'",
     "xmodmap -e 'clear Lock' -e 'keycode 66 = Escape'"
	       })
end

os.execute(table.concat(execute, ";"))

-- Spawn various X programs
if config.hostname == "uni" then
--xrun("polkit-gnome-authentication-agent-1", "/usr/libexec/polkit-gnome-authentication-agent-1")
end

--Petan y hay que lanzarlos arriba ¿?
--xrun("NetworkManager Applet", "Nm-applet")
--xrun("dropbox", "dropbox.py start")

if config.hostname == "neo" then
   xrun("keepassx", "keepassx -min -lock")
   xrun("transmission", "transmission-gtk -m")
elseif config.hostname == "guybrush" then
   xrun("keepassx", "keepassx -min -lock")
   xrun("NetworkManager Applet", "nm-applet")
end
