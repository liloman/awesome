-- Tags

--local shifty = loadrc("shifty", "vbe/shifty")
--shifty = require("shifty")
local keydoc = loadrc("keydoc", "vbe/keydoc")

local tagicon = function(icon)
   if screen.count() > 1 then
      return beautiful.icons .. "/taglist/" .. icon .. ".png"
   end
   return nil
end

shifty.config.tags = {
   dev = {
    position = 2,
    mwfact = 0.6,
    exclusive = false,
    screen = 1,
   --   spawn = "vim",
    icon_only= false,
    icon = tagicon("dev"),
    nopopup = true,           -- don't give focus on creation
    persist=false,
   },
   web = {
      position = 3,
      mwfact = 0.7,
      exclusive = false,
      max_clients = 1,
      screen = math.max(screen.count(), 2),
      spawn = config.browser,
      icon = tagicon("web"),
      nopopup = true,           -- don't give focus on creation
      persist=false, -- dont destroy on empty
      layout=awful.layout.suit.tile.bottom,
   
   },
   mail = {
      position = 4,
      mwfact = 0.2,
      exclusive = false,
     screen = 1, -- Parece que teien que ponerse ¿ -- Parece que teien que ponerse ¿??
 --     spawn = usr/bin/claws-mail,
      icon = tagicon("mail"),
      nopopup = true,           -- don't give focus on creation
      persist=false, -- dont destroy on empty
      layout=awful.layout.suit.floating,
   },
   music = {
    position = 5,
    mwfact = 0.6,
    exclusive = false,
    screen = 1,
   --   spawn = "vim",
    icon = tagicon("music"),
    nopopup = true,           -- don't give focus on creation
     persist=false, -- dont destroy on empty
   },
   im = {
    position = 6,
    mwfact = 0.6,
    exclusive = false,
    screen = 1,
    icon = tagicon("im"),
    nopopup = true,           -- don't give focus on creation
    persist=false,
    layout=awful.layout.suit.floating,
   }
--   xterm = {
--      position = 1,
--      layout = awful.layout.suit.fair,
--      exclusive = true,
--      slave = true,
--      spawn = config.terminal,
--      icon = tagicon("main"),
--   },
 }


-- Also, see rules.lua
shifty.config.apps = {
   {
      match = { role = { "browser" } },
      tag = "web",
   },
   {
      match = { class = { "Claws[-]mail","Balsa" } }, 
      tag = "mail",
   },
   {
      match = { name= {"MOC*" } },
      tag = "music",
   },
   {
      match = { class= {"Eclipse" } },
      float = true,
      tag = "dev",
   },
   {
        match = {"gcolor2", "xmag", "MPlayer","Event Tester"},
        float = true,
        intrusive = true,   -- Disregard a tag's exclusive property.
    },
   {
      match = { class = { "Skype", "buddy_list" } },
      float = true,
      tag = "im",
   },
   {
      match = { class = { "Keepassx" },
                role = { "pop[-]up" },
                instance = { "plugin[-]container", "exe" } },
      intrusive = true,
   },
}

shifty.config.defaults = {
 layout = config.layouts[1],
 mwfact = 0.6,
 ncol = 1,
 sweep_delay = 1,
}

shifty.taglist = config.taglist -- Set in widget.lua
shifty.init()

config.keys.global = awful.util.table.join(
   config.keys.global,
   keydoc.group("Tag management"),
   awful.key({ modkey }, "Escape", awful.tag.history.restore, "Switch to previous tag"),
   awful.key({ modkey }, "Left", awful.tag.viewprev),
   awful.key({ modkey }, "Right", awful.tag.viewnext),
   awful.key({ modkey, "Shift"}, "o",
             function()
                local t = awful.tag.selected()
                local s = awful.util.cycle(screen.count(), t.screen + 1)
                awful.tag.history.restore()
                t = shifty.tagtoscr(s, t)
                awful.tag.viewonly(t)
             end,
             "Send tag to next screen"),
   awful.key({ modkey }, 0, shifty.add),
   awful.key({ modkey, "Shift" }, 0, shifty.del, "Delete current tag"),
   awful.key({ modkey, "Control" }, 0, shifty.rename, "Rename current tag"))

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  config.keys.global = awful.util.table.join(
     config.keys.global,
     keydoc.group("Tag management"),
     awful.key({ "Mod1" }, i,
               function ()
                   if numClientes[i] then client.focus = numClientes[i] end
               end,
               i == 5 and "Nos movemos al cliente 5" or nil),
     awful.key({ modkey }, i,
               function ()
                  local t = shifty.getpos(i)
                  local s = t.screen
                  local c = awful.client.focus.history.get(s, 0)
                  awful.tag.viewonly(t)
                  if not s then s=1 end
                  mouse.screen = s
                  if c then client.focus = c end
               end,
               i == 5 and "Display only this tag" or nil),
     awful.key({ modkey, "Control" }, i,
               function ()
                  local t = shifty.getpos(i)
                  t.selected = not t.selected
               end,
               i == 5 and "Toggle display of this tag" or nil),
     awful.key({ modkey, "Shift" }, i,
               function ()
                  local c = client.focus
                  if c then
                     local t = shifty.getpos(i)
                     awful.client.movetotag(t, c)
                  end
               end,
               i == 5 and "Move window to this tag" or nil),
     awful.key({ modkey, "Control", "Shift" }, i,
               function ()
                  if client.focus then
                     awful.client.toggletag(shifty.getpos(i))
                  end
               end,
               i == 5 and "Toggle this tag on this window" or nil),
     keydoc.group("Misc"))
end
