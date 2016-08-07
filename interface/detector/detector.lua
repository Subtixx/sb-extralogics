local color = {
	white = {255,255,255},
	red = {255,0,0}
}

function init()
  local settings = config.getParameter("settings")
  widget.setText("tbxRange",tostring(settings.range))
  spnRange.current = settings.range
  
  widget.setChecked("cbxIgnoreWalls", settings.ignoreWalls)
  
  widget.setChecked("cbxHidden", settings.hidden)
  widget.setChecked("cbxCamo", settings.camo)
  
  spnMode.modes = settings.modes or {"all", "owner", "player", "monster", "item", "npc", "vehicle"}
  spnMode.currentMode = settings.mode or 1
  widget.setText("tbxMode", tostring(spnMode.modes[spnMode.currentMode]))
end

spnMode = {
	modes = {"all", "owner", "player", "monster", "item", "npc"},
	
	up = function()
		if(spnMode.currentMode + 1 > #spnMode.modes) then
			spnMode.currentMode = 1
		else
			spnMode.currentMode = spnMode.currentMode + 1
		end
		widget.setText("tbxMode", spnMode.modes[spnMode.currentMode])
	end,
	
	down = function()
		if(spnMode.currentMode - 1 < 1) then
			spnMode.currentMode = #spnMode.modes
		else
			spnMode.currentMode = spnMode.currentMode - 1
		end
		widget.setText("tbxMode", spnMode.modes[spnMode.currentMode])
	end
}

spnRange = {
	min = 0.5,
	max = 10.0,
	step = 0.5,
	current = 5.5,

	up = function()
		spnRange.current = math.min(spnRange.current + spnRange.step, spnRange.max)
		widget.setText("tbxRange", tostring(spnRange.current))
  end,

	down = function()
	  spnRange.current = math.max(spnRange.current - spnRange.step, spnRange.min)
		widget.setText("tbxRange", tostring(spnRange.current))
  end
}

function setMode()
	local n = tonumber(spnMode.currentMode)
	if n ~= nil and n >= 1 and n <= #spnMode.modes then
		widget.setFontColor("tbxMode", color.white)
		spnMode.currentMode = n
		send("mode", n)
	else
		widget.setFontColor("tbxMode", color.red)
	end
end

function setRange()
	local n = tonumber(widget.getText("tbxRange"))
	if n ~= nil and n >= spnRange.min and n <= spnRange.max then
		widget.setFontColor("tbxRange", color.white)
		spnRange.current = n
		send("range", n)
	else
		widget.setFontColor("tbxRange", color.red)
	end
end

function setIgnoreWalls()
	send("ignoreWalls", widget.getChecked("cbxIgnoreWalls"))
end

function setHidden()
	send("hidden",  widget.getChecked("cbxHidden"))
end

function setCamo()
	send("camo", widget.getChecked("cbxCamo"))
end

function loadDefaults()
	local settings = root.getConfiguration("Detector")
	if settings then
  	send(settings)
		initGUI(settings)
	end
end

function saveDefaults()
	root.setConfiguration("Detector", {
		range = spnRange.current,
		mode = spnRange.currentMode,
		hidden = widget.getChecked("cbxHidden"),
		camo = widget.getChecked("cbxCamo")
	})
end

function send(dataOrKey, value)
	local data = dataOrKey
	if type(dataOrKey) ~= table then
	  data = {}
	  data[dataOrKey] = value
	end
  world.sendEntityMessage(pane.sourceEntity(), "setData", data)
end
