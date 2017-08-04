--[[
Brightness control
==================
based on `xbacklight`!
alternative ways to control brightness:
    sudo setpci -s 00:02.0 F4.B=80
    xgamma -gamma .75
    xrandr --output LVDS1 --brightness 0.9
    echo X > /sys/class/backlight/intel_backlight/brightness
    xbacklight
--]]

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local timer = gears.timer or timer


------------------------------------------
-- Private utility functions
------------------------------------------

local function readcommand(command)
    local file = io.popen(command)
    local text = file:read('*all')
    file:close()
    return text
end

local function quote_arg(str)
    return "'" .. string.gsub(str, "'", "'\\''") .. "'"
end

local function quote_args(first, ...)
    if #{...} == 0 then
        return quote_arg(first)
    else
        return quote_arg(first), quote_args(...)
    end
end

local function make_argv(...)
    return table.concat({quote_args(...)}, " ")
end


------------------------------------------
-- Volume control interface
------------------------------------------

local vcontrol = {}

function vcontrol:new(args)
    return setmetatable({}, {__index = self}):init(args)
end

function vcontrol:init(args)
    self.cmd = "xbacklight"
    self.step = args.step or '5'

    self.widget = wibox.widget { 
       {
    	  id = "icon",
	  image = "/usr/share/icons/Numix/scalable/status/display-brightness-symbolic.svg",
	  -- image = beautiful.brightness_icon,	  
    	  resize = true,
    	  widget = wibox.widget.imagebox, 
       },
       layout = wibox.container.margin(brightness_icon, 0, 0, 3),
       set_image = function(self, path)
       	  self.icon.image = path
       end
    }
    -- self.widget = wibox.widget.imagebox(beautiful.brightness_icon, true)
    -- self.widget:set_layout(wibox.container.margin(brightness_icon, 0, 0, 3))
    -- self.widget.image = beautiful.brightness_icon

    -- self.widget = wibox.widget.textbox()
    -- self.widget.set_align("right")

    self.widget:buttons(awful.util.table.join(
        awful.button({ }, 1, function() self:up() end),
        awful.button({ }, 3, function() self:down() end),
        awful.button({ }, 2, function() self:toggle() end),
        awful.button({ }, 4, function() self:up(1) end),
        awful.button({ }, 5, function() self:down(1) end)
    ))

    self.timer = timer({ timeout = args.timeout or 3 })
    self.timer:connect_signal("timeout", function() self:get() end)
    self.timer:start()
    self:get()

    return self
end

function vcontrol:exec(...)
    return readcommand(make_argv(self.cmd, ...))
end

function vcontrol:get()
   local brightness = math.floor(0.5+tonumber(self:exec("-get")))
   local brightness_icon="/usr/share/icons/Numix/48/notifications/notification-display-brightness-"
   if (brightness < 10) then 
      brightness_icon = brightness_icon .. 'off.svg'
   elseif (brightness >= 20 and brightness < 40) then
      brightness_icon = brightness_icon .. 'low.svg'
   elseif (brightness >= 40 and brightness < 60) then
      brightness_icon = brightness_icon .. 'medium.svg'
   elseif (brightness >= 60 and brightness < 80) then
      brightness_icon = brightness_icon .. 'high.svg'
   elseif (brightness >= 80 and brightness < 100) then
      brightness_icon = brightness_icon .. 'full.svg'
   end
    self.widget:set_image(brightness_icon)
    return brightness
end

function vcontrol:set(brightness)
    self:exec('-set', tostring(brightness))
    self:get()
end

function vcontrol:up(step)
    self:exec("-inc", step or self.step)
    self:get()
end

function vcontrol:down(step)
    self:exec("-dec", step or self.step)
    self:get()
end

function vcontrol:toggle()
    if self:get() >= 50 then
      self:set(1)
    else
      self:set(100)
    end
end

return setmetatable(vcontrol, {
  __call = vcontrol.new,
})
