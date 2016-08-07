function init()
  if storage.state == nil then
    output(false)
  else
    output(storage.state)
  end
  if storage.timer == nil then
    storage.timer = 0
  end
  
  self.modes = { 0.5, 1, 2, 5, 10, 15, 30, 60, 128 }
  --[[if storage.settings.timerval == nil then
    storage.settings.timerval = self.modes[1] * 66
  end]]
  
  if not storage.settings then
    storage.settings = {}
  	local savedDefaults = root.getConfiguration("AdvancedTimer")
  	if savedDefaults then
	    onDataReceived(nil, nil, savedDefaults)
  	else
	    onDataReceived(nil, nil, config.getParameter("defaultStorage"))
  	end
  end
  
  message.setHandler("setData", onDataReceived)
  
  object.setInteractive(true)
  --self.interval = config.getParameter("interval")
end

function onDataReceived(_, _, data)
	for k,v in pairs(data) do
		local val = v
	    if(k == "timerval") then
			val = v*66
		end
		storage.settings[k] = val
	end
end

--[[function onInteraction(args)
  cycleMode()
end]]

function onInteraction()
  local interactionConfig = root.assetJson(config.getParameter("interactData"))
  interactionConfig.settings = storage.settings
  interactionConfig.settings.timerval = interactionConfig.settings.timerval / 66
  return {"ScriptPane", interactionConfig}
end

function cycleMode()
  for i, mode in ipairs(self.modes) do
    if (mode*66) == storage.settings.timerval then
      storage.settings.timerval = self.modes[(i % #self.modes) + 1] * 66
	  object.say("Mode set to: "..(storage.settings.timerval/66))
      return
    end
  end

  --previous mode invalid, default to mode 1
  storage.settings.timerval = self.modes[1] * 66
end

function output(state)
  if storage.state ~= state then
    storage.state = state
    object.setAllOutputNodes(state)
    if state then
      animator.setAnimationState("switchState", "on")
    else
      animator.setAnimationState("switchState", "off")
    end
  else
  end
end

function update(dt)
  if (not object.isInputNodeConnected(0)) or object.getInputNodeLevel(0) then
    if storage.timer == nil or storage.timer == 0 then
      storage.timer = storage.settings.timerval
      output(not storage.state)
    else
      storage.timer = storage.timer - 1 
    end
  else
    storage.timer = 0
    output(false)
  end
end
