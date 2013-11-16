Liloman's awesome configuration
--------------------------------------

This is my [awesome](http://awesome.naquadah.org) configuration.
It's based on Vicent Bernat's one but I have added new awesomeness to it
and it's made for Awesome 3.5.

--------------------------

--Copy of vicent bernat's readme with just the parts left---

Here some of the things you may be interested in:

 - It is modular. I am using `config` as a table to pass different
   things between "modules".

 - In `rc/xrun.lua`, there is a `xrun` function which runs a program
   only if it is not already running. Instead of relying on tools like
   `ps`, it looks at the list of awesome clients and at the list of
   connected clients with `xwininfo`. Seems reliable.

 - In `rc/apparance.lua`, you may be interested by the way I configure
   GTK2 and GTK3 to have an unified look. It works and it does not
   need `gnome-control-center`.

 - I am using notifications when changing volume or brightness. I am
   also using notifications to change xrandr setup. This is pretty
   cool.
 
 - Keybindings are "autodocumented". See `lib/keydoc.lua` to see how
   this works. The list of key bindings can be accessed with Mod4 +
   F1.
   
 - On the debug front, I am quite happy with `dbg()` in
   `rc/debug.lua`.

Things in `lib/` are meant to be reused. I am using my own `loadrc()`
function to load modules and therefore, I prefix my modules with
`vbe/`. Before reusing a module, you may want to change this. Another
way to load them is to use:

	require("lib/quake")
	local quake = package.loaded["vbe/quake"]
--------------------------

Added by me:
 - Clients in each tags are numbered and you can get them with Alt+Num.
 
 - There's a drop-down client implementation in scratch/, just press modkey + F4 
  to drop-down-ish any client and modkey+F5 to show it.

 - The tasklist is shown bottom of screen in a spare widget, not at top as usual.

 - It's came with pomodoro task  ( pomodoroTasks in progress by myself which is going to
 be great, at least for me ;) )

 - You can configure maximum tasklist window width in rc/theme.lua (theme.tasklist_max_width)

 - Only works in Awesome 3.5!!

 - I use sakura as terminal and tmux 

 - There're a lot coming in and maybe some changes missed but be patient. :)
 
