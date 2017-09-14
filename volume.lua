local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local watch = require("awful.widget.watch")
local spawn = require("awful.spawn")

local request_command = 'pamixer --sink 1 --get-volume'

awful.spawn("pamixer --sink 0 --mute", false)
awful.spawn("pamixer --sink 1 --unmute", false)

volume_widget = wibox.widget {
   {
      id     = 'sink_indicator',
      image  = '/home/mikael/.config/awesome/themes/solar/audio-speakers-symbolic.svg',
      resize = true,
      widget = wibox.widget.imagebox
   },
   {
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
      id       = 'slider',
      spacing  = 4,
      layout   = wibox.layout.stack,
   },
   layout = wibox.layout.align.horizontal,
   set_icon = function(self, path)
      self.sink_indicator.image = path
   end,
   set_value = function(self, value)
      self.slider.bar.value = value
   end,
   set_text = function(self, text)
      self.slider.mute_indicator.text = text
   end
}

local update_sink = function(widget, stdout, stderr, reason, exit_code)
   if stdout == "true"  then
      widget.icon = '/home/mikael/.config/awesome/themes/solar/audio-headphones-symbolic.svg'
   elseif  stdout == "false"  then
      widget.icon = '/home/mikael/.config/awesome/themes/solar/audio-speakers-symbolic.svg'
   end
end

local update_slider = function(widget, stdout, stderr, reason, exit_code)
   -- local mute = string.match(stdout, "%[(o%D%D?)%]")
   -- local volume = string.match(stdout, "(%d?%d?%d)%%")
   -- volume = tonumber(string.format("% 3d", volume))
   -- local mute = string.match(stdout, "%[(o%D%D?)%]")
   local volume = tonumber(stdout)
   local mute = 'on'
   if mute == "off"  then
      widget.text = 'muted'
      widget.value = 0.0
   elseif  mute == "on"  then
      widget.text = ''
      widget.value = volume/100.0
   end
end

volume_widget.slider:connect_signal(
   "button::press", function(_,_,_,button)
      if (button == 4) then
	 awful.spawn("pamixer --sink 1 --increase 5", false)
      elseif (button == 5) then
	 awful.spawn("pamixer --sink 1 --decrease 5", false)
      elseif (button == 1) then
	 awful.spawn("pamixer --sink 0 --toggle-mute", false)
	 awful.spawn("pamixer --sink 1 --toggle-mute", false)
      elseif (button == 3) then
	 awful.spawn("pavucontrol")
      end
    
      spawn.easy_async(request_command,
		       function(stdout, stderr, exitreason, exitcode)
			  update_slider(volume_widget, stdout, stderr,
					exitreason, exitcode)
      end)
      spawn.easy_async('pamixer --sink 1 --get-mute',
		       function(stdout, stderr, exitreason, exitcode)
			  update_sink(volume_widget, stdout, stderr,
				      exitreason, exitcode)
      end)
end)

watch(request_command, 1, update_slider, volume_widget)

watch('pamixer --sink 1 --get-mute', 1, update_sink, volume_widget)

-- local update_source = function(widget, stdout, stderr, reason, exit_code)
--    local mute = string.match(stdout, "%[(o%D%D?)%]")
--    local volume = string.match(stdout, "(%d?%d?%d)%%")
--    volume = tonumber(string.format("% 3d", volume))
--    if mute == "off"  then
--       widget.text = 'muted'
--       widget.value = 0.0
--    elseif  mute == "on"  then
--       widget.text = ''
--       widget.value = volume/100.0
--    end
-- end

-- volume_widget.slider:connect_signal(
--    "button::press", function(_,_,_,button)
--       if (button == 4) then
-- 	 awful.spawn("amixer -c 1 sset Master 5%+", false)
--       elseif (button == 5) then
-- 	 awful.spawn("amixer -c 1 sset Master 5%-", false)
--       elseif (button == 1) then
-- 	 awful.spawn("amixer -c 1 sset Master toggle", false)
--       elseif (button == 3) then
-- 	 awful.spawn("pavucontrol")
--       end
    
--       spawn.easy_async(request_command,
-- 		       function(stdout, stderr, exitreason, exitcode)
-- 			  update_slider(volume_widget, stdout, stderr,
-- 					 exitreason, exitcode)
--     end)
-- end)

-- watch(, 1, update_slider, volume_widget)

