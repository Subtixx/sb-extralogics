-- FIXME: If the pulse extender is connected to a pulseformer which is connected to a lever that is on,
-- the pulse extender triggers, even though the pulseformer wasn't.

--- Object init event.
-- Gets executed when this object is placed.
-- @param virtual if this is a virtual call?
function init(virtual)
	if not virtual then
		storage.state = storage.state or 0

		if not storage.settings then
        	storage.settings = {}
    		local savedDefaults = root.getConfiguration("PulseExtender")
	    	if savedDefaults then
            	onDataReceived(nil, nil, savedDefaults)
    		else
            	onDataReceived(nil, nil, config.getParameter("defaultStorage"))
    		end
    	end

		-- UI Setup
        message.setHandler("setData", onDataReceived)
        object.setInteractive(true)

		checkNodes()
	end
end

--- Object on interaction event.
-- Gets executed when a player interacts (Presses E) on the object.
function onInteraction()
    local interactionConfig = root.assetJson(config.getParameter("interactData"))
    interactionConfig.settings = storage.settings
    return {"ScriptPane", interactionConfig}
end

--- Object node connection change event.
-- Gets executed when this object node connections changes
-- Input and Output nodes are connected / disconnected.
function onNodeConnectionChange()
	if not object.isInputNodeConnected(0) then return end

  	checkNodes()
end

--- Object node input change event.
-- Gets executed when the node input changed.
-- @param args a table containing the node and level args["node"], args["level"]
function onInputNodeChange(args)
	if not object.isInputNodeConnected(0) then return end

	checkNodes()
end

--- Object update event.
-- Gets executed when this object updates.
-- @param dt delta time, time is specified in *.object as scriptDelta (60 = 1 second)
function update(dt)
	if not object.isInputNodeConnected(0) then return end

	if object.getOutputNodeLevel(0) then
		if storage.state > 0 then
			storage.state = storage.state-1
		else
			object.setOutputNodeLevel(0, false)
			animator.setAnimationState("switchState", "off")
		end
	end
end

--- Custom function to check input nodes for level change.
function checkNodes()
	if not object.isInputNodeConnected(0) or not object.getInputNodeLevel(0) then return end

	storage.state = storage.settings["timerval"]
	object.setOutputNodeLevel(0, true)
	animator.setAnimationState("switchState", "on")
end

--- Custom function to receive data from UI.
function onDataReceived(_, _, data)
    for k,v in pairs(data) do
        storage.settings[k] = v
    end

    ApplyConfig()
end

--- Custom functions to apply the current settings.
function ApplyConfig()
	local mat = storage.settings["camo"] and world.material(entity.position(), "background") or "metamaterial:empty"
    object.setMaterialSpaces({{{0,0},mat}, {{-1,0}, mat}, {{-1,-1},mat}, {{0,-1}, mat}}) -- TODO: Too big?

    if storage.settings["hidden"] then
    	animator.setAnimationState("switchState", "hidden")
	else
		animator.setAnimationState("switchState", object.getOutputNodeLevel(0) and "on" or "off")
	end
end