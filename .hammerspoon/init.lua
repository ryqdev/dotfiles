hs.hotkey.bind({ "cmd", "ctrl" }, "H", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind({ "cmd", "ctrl" }, "L", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w / 2)
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind({ "cmd", "ctrl" }, "J", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y + max.h / 2
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f)
end)

hs.hotkey.bind({ "cmd", "ctrl" }, "K", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f)
end)

hs.hotkey.bind({ "cmd", "alt" }, "F", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h
  win:setFrame(f)
end)


function reloadConfig(files)
  doReload = false
  for _, file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
  end
end

myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")


menubarFont = hs.menubar.new()
menubarFont:setTitle("ryqdev")

function menubarClicked()
  setCaffeineDisplay(hs.alert.show("Who is your daddy?"))
end

if menubarFont then
  menubarFont:setClickCallback(menubarClicked)
end



switcher = hs.window.switcher.new(hs.window.filter.new():setCurrentSpace(true))
function mapCmdTab(event)
  local flags = event:getFlags()
  local chars = event:getCharacters()
  if chars == "\t" and flags:containExactly { 'cmd' } then
    switcher:next()
    return true
  elseif chars == string.char(25) and flags:containExactly { 'cmd', 'shift' } then
    switcher:previous()
    return true
  end
end

tapCmdTab = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, mapCmdTab)
tapCmdTab:start()

-- Hammerspoon config to send escape on short ctrl press

ctrl_table = {
  sends_escape = true,
  last_mods = {}
}

control_key_timer = hs.timer.delayed.new(0.15, function()
  ctrl_table["send_escape"] = false
  -- log.i("timer fired")
  -- control_key_timer:stop()
end
)

last_mods = {}

control_handler = function(evt)
  local new_mods = evt:getFlags()
  if last_mods["ctrl"] == new_mods["ctrl"] then
    return false
  end
  if not last_mods["ctrl"] then
    -- log.i("control pressed")
    last_mods = new_mods
    ctrl_table["send_escape"] = true
    -- log.i("starting timer")
    control_key_timer:start()
  else
    -- log.i("contrtol released")
    -- log.i(ctrl_table["send_escape"])
    if ctrl_table["send_escape"] then
      -- log.i("send escape key...")
      hs.eventtap.keyStroke({}, "ESCAPE")
    end
    last_mods = new_mods
    control_key_timer:stop()
  end
  return false
end

control_tap = hs.eventtap.new({ 12 }, control_handler)

control_tap:start()
