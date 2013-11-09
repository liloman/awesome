-- Widgets
local wibox=require("wibox")
local vicious=require("vicious")
local vlayout = require("wibox.layout")
local common = require("awful.widget.common")
local icons = loadrc("icons", "vbe/icons")
local pomodoro = loadrc("pomodoro")
pomodoro.init()
-- Separators
local sepopen = wibox.widget.imagebox(beautiful.icons .. "/widgets/left.png")
local sepclose = wibox.widget.imagebox(beautiful.icons .. "/widgets/right.png")
local spacer = wibox.widget.imagebox(beautiful.icons .. "/widgets/spacer.png")

-- Date
local datewidget = wibox.widget.textbox()
local dateformat = "%H:%M"
if screen.count() > 1 then dateformat = "%a %d/%m, " .. dateformat end
vicious.register(datewidget, vicious.widgets.date, '<span color="' .. beautiful.fg_widget_clock .. '">' ..  dateformat .. '</span>', 61)
local dateicon = wibox.widget.imagebox(beautiful.icons .. "/widgets/clock.png")
local cal = (
function()
    local calendar = nil
    local offset = 0

    local remove_calendar = function()
        if calendar ~= nil then
            naughty.destroy(calendar)
            calendar = nil
            offset = 0
        end
    end

    local add_calendar = function(inc_offset)
        local save_offset = offset
        remove_calendar()
        offset = save_offset + inc_offset
        local datespec = os.date("*t")
        datespec = datespec.year * 12 + datespec.month - 1 + offset
        datespec = (datespec % 12 + 1) .. " " .. math.floor(datespec / 12)
        local cal = awful.util.pread("ncal -w -m " .. datespec)
        -- Highlight the current date and month
        cal = cal:gsub("_.([%d ])",
        string.format('<span color="%s">%%1</span>',
        beautiful.fg_widget_clock))
        cal = cal:gsub("^( +[^ ]+ [0-9]+) *",
        string.format('<span color="%s">%%1</span>',
        beautiful.fg_widget_clock))
        -- Turn anything other than days in labels
        cal = cal:gsub("(\n[^%d ]+)",
        string.format('<span color="%s">%%1</span>',
        beautiful.fg_widget_label))
        cal = cal:gsub("([%d ]+)\n?$",
        string.format('<span color="%s">%%1</span>',
        beautiful.fg_widget_label))
        calendar = naughty.notify(
        {
            text = string.format('<span font="%s">%s</span>',
            "Terminus 8",
            cal:gsub(" +\n","\n")),
            timeout = 0, hover_timeout = 0.5,
            width = 160,
            screen = mouse.screen,
        })
    end

    return { add = add_calendar,
    rem = remove_calendar }
end)()

datewidget:connect_signal("mouse::enter", function() cal.add(0) end)
datewidget:connect_signal("mouse::leave", cal.rem)
datewidget:buttons(awful.util.table.join(
awful.button({ }, 3, function() cal.add(-1) end),
awful.button({ }, 1, function() cal.add(1) end)))

-- CPU usage
local cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu,
function (widget, args)
    return string.format('<span color="' .. beautiful.fg_widget_value .. '">%2d%%</span>',args[1])
end, 10)
local cpuicon = wibox.widget.imagebox(beautiful.icons .. "/widgets/cpu.png")

-- Battery
local batwidget =wibox.widget 
--if config.hostname == "guybrush" then
batwidget.widget = wibox.widget.textbox()
vicious.register(batwidget.widget, vicious.widgets.bat,
function (widget, args)
    local color = beautiful.fg_widget_value
    local current = args[2]
    if current < 10 and args[1] == "-" then
        color = beautiful.fg_widget_value_important
        -- Maybe we want to display a small warning?
        if current ~= batwidget.lastwarn then
            batwidget.lastid = naughty.notify(
            { title = "Battery low!",
            preset = naughty.config.presets.critical,
            timeout = 20,
            text = "Battery level is currently " ..
            current .. "%.\n" .. args[3] ..
            " left before running out of power.",
            icon = icons.lookup({name = "battery-caution",
            type = "status"}),
            replaces_id = batwidget.lastid }).id
            batwidget.lastwarn = current
        end
    end
    return string.format('<span color="' .. color ..
    '">%s%d%%</span>', args[1], current)
end,
59, "BAT0")
-- end
local baticon = wibox.widget.imagebox(beautiful.icons .. "/widgets/bat.png")

------ Network
local netup   = wibox.widget.textbox()
local netdown  = wibox.widget.textbox()
local netupicon = wibox.widget.imagebox(beautiful.icons .. "/widgets/up.png")
local netdownicon = wibox.widget.imagebox(beautiful.icons .. "/widgets/down.png")

--local netgraph = awful.widget.graph()
--netgraph:set_width(80):set_height(16)
--netgraph:set_stack(true):set_scale(true)
--netgraph:set_border_color(beautiful.fg_widget_border)
--netgraph:set_stack_colors({ "#EF8171", "#cfefb3" })
--netgraph:set_background_color("#00000033")
vicious.register(netup, vicious.widgets.net,
function (widget, args)
    -- We sum up/down value for all interfaces
    local up = 0
    local down = 0
    local iface
    for name, value in pairs(args) do
        iface = name:match("^{(%S+) down_b}$")
        if iface and iface ~= "lo" then down = down + value end
        iface = name:match("^{(%S+) up_b}$")
        if iface and iface ~= "lo" then up = up + value end
    end
    -- Update the graph
    --netgraph:add_value(up, 1)
    --netgraph:add_value(down, 2)
    -- Format the string representation
    local format = function(val)
        if val > 500000 then
            return string.format("%.1f MB", val/1000000.)
        elseif val > 500 then
            return string.format("%.1f KB", val/1000.)
        else return string.format("%d B", val) 
        end
    end
    -- Down
    netdown.text = string.format('<span color="' .. beautiful.fg_widget_value ..  '">%08s</span>', format(down))
    -- Up
    return  string.format('<span color="' .. beautiful.fg_widget_value ..  '">%08s</span>', format(up))
end, 3)
vicious.register(netdown, vicious.widgets.net,netdown.text,3)

---- Memory usage
local memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem, '<span color="' .. beautiful.fg_widget_value .. '">$1</span>', 19)
local memicon = wibox.widget.imagebox(beautiful.icons .. "/widgets/mem.png")
---- Volume level
local volwidget = wibox.widget.textbox()
vicious.register(volwidget, vicious.widgets.volume, '<span color="' .. beautiful.fg_widget_value .. '">$2 $1</span>',17,"Master")
local volicon=wibox.widget.imagebox(beautiful.icons .. "/widgets/vol.png")

volume = loadrc("volume", "vbe/volume")
volwidget:buttons(awful.util.table.join(
awful.button({ }, 1, volume.mixer),
awful.button({ }, 3, volume.toggle),
awful.button({ }, 4, volume.increase),
awful.button({ }, 5, volume.decrease)))

----Mocp client
----mocpwidget = widget({ type = "textbox" })
------ Register widget
----vicious.register(mocpwidget, vicious.widgets.mocp,
----function (widget, args)
----  if args["{state}"] == "Stop" then 
----    return " - "
----  else 
----    return args["{Artist}"]..' - '.. args["{Title}"]
----  end
----end, 10)
--
--
---- File systems
--local fs = { ["/"] = "root",
--	     ["/home"] = "home",
--	     ["/var"] = "var",
--	     ["/usr"] = "usr",
--	     ["/tmp"] = "tmp",
--	     ["/var/cache/build"] = "pbuilder" }
----local fsicon = widget({ type = "imagebox" })
--local fsicon = wibox.widget.imagebox()
--fsicon.image = wibox.widget.imagebox(beautiful.icons .. "/widgets/disk.png")
----local fswidget = widget({ type = "textbox" })
--local fsiwidget = wibox.widget.textbox()
--vicious.register(fswidget, vicious.widgets.fs,
--		 function (widget, args)
--		    local result = ""
--		    for path, name in pairs(fs) do
--		       local used = args["{" .. path .. " used_p}"]
--		       local color = beautiful.fg_widget_value
--		       if used then
--			  if used > 90 then
--			     color = beautiful.fg_widget_value_important
--			  end
--			  result = string.format(
--			     '%s%s<span color="' .. beautiful.fg_widget_label .. '">%s: </span>' ..
--				'<span color="' .. color .. '">%2d%%</span>',
--			     result, #result > 0 and " " or "", name, used)
--		       end
--		    end
--		    return result
--     end, 53)

local systray = wibox.widget.systray()
--
-- Wibox initialisation
mywibox     = {}
local promptbox = {}
local layoutbox = {}

local taglist = {}

for s = 1, screen.count() do
    promptbox[s] = awful.widget.prompt()
    layoutbox[s] = awful.widget.layoutbox(s)
    --Creamos los botones
    taglist.buttons = awful.util.table.join(
    awful.button({ }, 1, awful.tag.viewonly),
    awful.button({ modkey }, 1, awful.client.movetotag),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, awful.client.toggletag)
    )
    -- Create the taglist
    taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all,taglist.buttons,'',
    --
    -- Copia awful.widget.common.list_update para modificar el aspecto de la taglist
    function (w, buttons, label, data, objects)
        -- update the widgets, creating them if needed
        w:reset()
       
       for i, o in ipairs(objects) do

           local cache = data[o]
           local ib, tb, bgb, m, l
           if cache then
               ib = cache.ib
               tb = cache.tb
               bgb = cache.bgb
               m   = cache.m
           else
               ib = wibox.widget.imagebox()
               tb = wibox.widget.textbox()
               --tb:set_text(i)
               bgb = wibox.widget.background()
               m = wibox.layout.margin(tb, 4, 4)
               l=wibox.layout.fixed.horizontal()

               l:fill_space(true)
               l:add(ib)
               l:add(m)

               -- And all of this gets a background
               bgb:set_widget(l)

               bgb:buttons(common.create_buttons(buttons, o))

               data[o] = {
                   ib = ib,
                   tb = tb,
                   bgb = bgb,
                   m   = m
               }
           end

           local text, bg, bg_image, icon = label(o)
           for i,vtag in ipairs(awful.tag.gettags(mouse.screen)) do
               --Localizamos espartanamente las tags...
               if string.find(tostring(text),vtag.name)  then
                      local position=awful.tag.getproperty(vtag,"position")
                       if not position then
                           text=" "..text.."*"
                       else
                           text=" "..text .. "<sup><small>"..position .."</small></sup>"
                       end
               end
           end
           -- The text might be invalid, so use pcall
           if not pcall(tb.set_markup, tb, text) then
               tb:set_markup("<i>&lt;Invalid text&gt;</i>")
           end
           bgb:set_bg(bg)
           if type(bg_image) == "function" then
               bg_image = bg_image(tb,o,m,objects,i)
           end
           bgb:set_bgimage(bg_image)
           ib:set_image(icon)
           w:add(bgb)
       end
   end) -- /taglist

    -- Create the mywibox
    mywibox[s] = awful.wibox({ screen = s,
    fg = beautiful.fg_normal,
    bg = beautiful.bg_widget,
    position = "top",
    height = 16,
})
-- Add widgets to the mywibox
local on = function(n, what)
    if s == n or n > screen.count() then return what end
    return ""
end

-- Widgets that are aligned to the left
--Los de la izquierda
local izquierdo=vlayout.fixed.horizontal()
izquierdo:add(taglist[s])
izquierdo:add(promptbox[s])
local derecho=vlayout.fixed.horizontal()
derecho:add(layoutbox[s])
derecho:add(sepopen)
derecho:add(cpuicon)
derecho:add(cpuwidget)
derecho:add(spacer)
--derecho:add(volicon)
derecho:add(memicon)
derecho:add(memwidget)
derecho:add(spacer)
derecho:add(volwidget)
derecho:add(spacer)
--derecho:add(baticon)
--derecho:add(batwidget)
--derecho:add(spacer)
derecho:add(netdown)
derecho:add(netdownicon)
derecho:add(netup)
derecho:add(netupicon)
--derecho:add(netgraph)
derecho:add(spacer)
derecho:add(dateicon)
derecho:add(datewidget)
derecho:add(sepclose)
derecho:add(sepopen)
derecho:add(systray)
derecho:add(pomodoro.icon_widget)
derecho:add(pomodoro.widget)
derecho:add(sepclose)
--Los ponemos a la derecha ahora
local capa = vlayout.align.horizontal()
capa:set_left(izquierdo)
capa:set_right(derecho)
mywibox[s]:set_widget(capa)


-- Second mywibox para anadir el tasklist abajo
mywibox[2] = awful.wibox({screen = s,
fg = beautiful.fg_normal, bg = beautiful.bg_widget,
position = "bottom", height = 16})

------------ preparamos los tasklist
local tasklist = {}
tasklist.buttons = awful.util.table.join(
awful.button({ }, 1, function (c)
    if c == client.focus then
        c.minimized = true
    else
        if not c:isvisible() then
            awful.tag.viewonly(c:tags()[1])
        end
        -- This will also un-minimize
        -- the client, if needed
        client.focus = c
        c:raise()
    end
end))

for s = 1, screen.count() do
    tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist.buttons,'',
    --
    -- Copia awful.widget.common.list_update para modificar el aspecto de la tasklist
    function (w, buttons, label, data, objects)
        -- update the widgets, creating them if needed
        w:reset()
       numClientes={}
       
       local swibox=mywibox[2]
       local min=beautiful.tasklist_max_width
       swibox.width=10
       
       for i, o in ipairs(objects) do
           --Que las tasklist tengan um maximo de width para que no ocupe una sola toda el layout
           if screen[s].geometry.width>=swibox.width+min then
               swibox.width=swibox.width+min
           elseif screen[s].geometry.width~=swibox.width then
               awful.wibox.stretch(swibox,s) 
           end

           local cache = data[o]
           local ib, tb, bgb, m, l
           if cache then
               ib = cache.ib
               tb = cache.tb
               bgb = cache.bgb
               m   = cache.m
           else
               ib = wibox.widget.imagebox()
               tb = wibox.widget.textbox()
               tb:set_text(i)
               bgb = wibox.widget.background()
               m = wibox.layout.margin(tb, 4, 4)
               l=wibox.layout.fixed.horizontal()

               l:fill_space(true)
               l:add(ib)
               l:add(m)

               -- And all of this gets a background
               bgb:set_widget(l)

               bgb:buttons(common.create_buttons(buttons, o))

               data[o] = {
                   ib = ib,
                   tb = tb,
                   bgb = bgb,
                   m   = m
               }
           end

           local text, bg, bg_image, icon = label(o)
           text=i .." "..text
           numClientes[i]=o
           -- The text might be invalid, so use pcall
           if not pcall(tb.set_markup, tb, text) then
               tb:set_markup("<i>&lt;Invalid text&gt;</i>")
           end
           bgb:set_bg(bg)
           if type(bg_image) == "function" then
               bg_image = bg_image(tb,o,m,objects,i)
           end
           bgb:set_bgimage(bg_image)
           ib:set_image(icon)
           w:add(bgb)
       end
   end)
end
------------------- FIN de tasklist


mywibox[2]:set_widget(tasklist[s])
end

config.keys.global = awful.util.table.join(
config.keys.global,
awful.key({ modkey }, "r", function () promptbox[mouse.screen]:run() end, "Prompt for a command"))

config.taglist = taglist
