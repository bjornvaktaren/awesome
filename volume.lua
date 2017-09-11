local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local watch = require("awful.widget.watch")
local spawn = require("awful.spawn")

local request_command = 'amixer -c 1 sget Master'

volume_widget = wibox.widget {
   {
      id               = 'bar',
      max_value        = 1,
      value            = 0.5,
      forced_width     = 80,
      border_width     = 1,
      paddings         = 2,
      color            = beautiful.fg_normal,
      border_color     = beautiful.fg_normal,
      background_color = beautiful.bg_normal,
      widget           = wibox.widget.progressbar,
   },
   {
      id     = 'mute_indicator',
      text   = '',
      align  = 'center',
      color  = '#2aa198',
      widget = wibox.widget.textbox,
   },
   spacing  = 4,
   layout   = wibox.layout.stack,
   set_value = function(self, value)
      self.bar.value = value
   end,
   set_text = function(self, text)
      self.mute_indicator.text = text
   end
}

volume_popup = awful.tooltip({objects = {volume_widget}})

local update_bar = function(widget, stdout, stderr, reason, exit_code)
   local mute = string.match(stdout, "%[(o%D%D?)%]")
   local volume = string.match(stdout, "(%d?%d?%d)%%")
   volume = tonumber(string.format("% 3d", volume))
   if mute == "off"  then
      widget.text = 'muted'
      widget.value = 0.0
   elseif  mute == "on"  then
      widget.text = ''
      widget.value = volume/100.0
   end
end

--[[ allows control volume level by:
- clicking on the widget to mute/unmute
- scrolling when curson is over the widget
]]
volume_widget:connect_signal(
   "button::press", function(_,_,_,button)
      if (button == 4) then
	 awful.spawn("amixer -D pulse sset Master 5%+", false)
      elseif (button == 5) then
	 awful.spawn("amixer -D pulse sset Master 5%-", false)
      elseif (button == 1) then
	 awful.spawn("amixer -D pulse sset Master toggle", false)
      elseif (button == 3) then
	 awful.spawn("pavucontrol")
      end
      spawn.easy_async(request_command,
		       function(stdout, stderr, exitreason, exitcode)
			  update_graphic(volume_widget, stdout, stderr,
					 exitreason, exitcode)
      end)
      
      spawn.easy_async(request_command,
		       function(stdout, stderr, exitreason, exitcode)
			  update_bar(volume_widget, stdout, stderr,
				     exitreason, exitcode)
      end)
end)

watch(request_command, 1, update_bar, volume_widget)
