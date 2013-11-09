local icons = loadrc("icons", "vbe/icons")

   function firstMaster(c)
       local vtag=awful.tag.selected()
       if vtag then  
           if #vtag:clients() == 1 then
               awful.client.setmaster(c)
           else
               awful.client.setslave(c)
           end
       end
   end  
   awful.rules.rules = {
       -- All clients will match this rule.
       { rule = { },
       properties = { border_width = beautiful.border_width,
       border_color = beautiful.border_normal,
       focus = true,
       maximized_vertical   = false,
       maximized_horizontal = false,
       keys = shifty.config.clientkeys,
       buttons = config.mouse.client }
       --First client is always master
       -- what the fuck??? dont print the new clients's border ????
       ,callback = function(c)
           --local cx=c
           --Ugly hack to set the focus
           --awful.client.jumpto(c,false)
          --local prev=awful.client.next(-1) 
           --awful.client.jumpto(prev,true)
           --awful.client.focus.history.add(c)
           --awful.client.focus.history.previous()
           --client.focus=cx
           --awful.client.focus.byidx(0) 
           --cx:raise()
           local vtag=awful.tag.selected()
           if vtag then  
               if #vtag:clients() == 1 then
                   awful.client.setmaster(c)
               else
                   awful.client.setslave(c)
               end
           end
       end }, 
       -- Browser stuff
       { rule = { role = "browser" },
       callback = function(c)
           if not c.icon then
               local icon = icons.lookup({ name = "web-browser",
               type = "apps" })
               if icon then
                   c.icon = image(icon)
               end
           end
       end },
       { rule = { instance = "plugin-container" },
       properties = { floating = true }}, -- Flash with Firefox
       { rule = { instance = "urxvt" },
       properties = { opacity = 0.8 }}, -- Transparencia
       { rule = { instance = "exe", class="Exe", instance="exe" },
       properties = { floating = true }}, -- Flash with Chromium
       -- Skype
       { rule = { class = "Skype" },
       except = { role = "buddy_list" }, -- buddy_list is the master
       properties = { }, callback = awful.client.setslave },
       -- Should not be master
       { rule_any = { class =
       { "URxvt",
       "Transmission-gtk",
       "Keepassx",
   }, instance = { "Download" }},
   except = { icon_name = "QuakeConsoleNeedsUniqueName" },
   properties = { },
   callback = awful.client.setslave },
   -- Floating windows
   { rule_any = { class = { "Display.im6" } },
   properties = { floating = true }},
}
