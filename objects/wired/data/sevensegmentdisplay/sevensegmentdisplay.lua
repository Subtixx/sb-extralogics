function init()

	storage.supportedColors = {
		"white", -- default color
		"black",
		"pink",
		"orange",
		"yellow",
		"green",
		"blue",
		"red"
	}
	storage.color = config.getParameter("color") and config.getParameter("color") or 1

	self.displaySize = config.getParameter("displaySize") and config.getParameter("displaySize") or 3

	object.setInteractive(true)

	findAdjacentSegments()
end

function update(dt)
end

function die()
	if storage.connectedRight then
		world.callScriptedEntity(storage.connectedRight, "disconnectLeft")
	end

	if storage.connectedLeft then
		world.callScriptedEntity(storage.connectedLeft, "disconnectRight")
	end
	
	local position = object.position()

	if(storage.supportedColors[storage.color] and storage.color ~= 1) then
	   world.spawnItem("sevensegmentdisplay", {position[1] + 2, position[2] + 1}, 1, {
	      color=storage.supportedColors[storage.color]
	      --description=string.format(config.getParameter("colorDescription"), math.floor(storage.fuel))
	   })
	   return
	else
		world.spawnItem("sevensegmentdisplay", {position[1] + 2, position[2] + 1}, 1, {})
	end
end

function onInputNodeChange()
	animator.setAnimationState("aDataState", object.getInputNodeLevel(0) and "on" or "off")
	animator.setAnimationState("bDataState", object.getInputNodeLevel(1) and "on" or "off")
	animator.setAnimationState("cDataState", object.getInputNodeLevel(2) and "on" or "off")
	animator.setAnimationState("dDataState", object.getInputNodeLevel(3) and "on" or "off")
	animator.setAnimationState("eDataState", object.getInputNodeLevel(4) and "on" or "off")
	animator.setAnimationState("fDataState", object.getInputNodeLevel(5) and "on" or "off")
	animator.setAnimationState("gDataState", object.getInputNodeLevel(6) and "on" or "off")
end

function onInteraction()
	if(storage.color < #storage.supportedColors) then
		storage.color = storage.color + 1
	else
		storage.color = 0
	end

	setSegmentColor(storage.color)
end

function setSegmentColor(color)
	if(storage.supportedColors[color]) then
		-- workaround until animator.setGlobalTag("color", "red") works.
		animator.setPartTag("asegment", "color", storage.supportedColors[color])
		animator.setPartTag("bsegment", "color", storage.supportedColors[color])
		animator.setPartTag("csegment", "color", storage.supportedColors[color])
		animator.setPartTag("dsegment", "color", storage.supportedColors[color])
		animator.setPartTag("esegment", "color", storage.supportedColors[color])
		animator.setPartTag("fsegment", "color", storage.supportedColors[color])
		animator.setPartTag("gsegment", "color", storage.supportedColors[color])
	else
		sb.logError("Unsupported color in 7-segment display: " .. sb.print(color))
	end
end

-- Link stuff

function updateLinkAnimationState()
	if storage.connectedRight and storage.connectedLeft then
		animator.setAnimationState("linkState", "both")
	elseif not storage.connectedRight and storage.connectedLeft then
		if object.direction() == 1 then
			animator.setAnimationState("linkState", "left")
		else
			animator.setAnimationState("linkState", "right")
		end
	elseif storage.connectedRight and not storage.connectedLeft then
		if object.direction() == 1 then
			animator.setAnimationState("linkState", "right")
		else
			animator.setAnimationState("linkState", "left")
		end
	else
		animator.setAnimationState("linkState", "none")
	end
end

function disconnectLeft()
	storage.connectedLeft = nil
	updateLinkAnimationState()
end

function disconnectRight()
	storage.connectedRight = nil
	updateLinkAnimationState()
end

function findAdjacentSegments()
	pingLeft()
	pingRight()

	updateLinkAnimationState()
end

function pingRight()
	local entityIds = world.entityQuery({entity.position()[1] + self.displaySize, entity.position()[2]}, 1,
	{ callScript = "isSevenSegmentDisplayToRight", callScriptArgs = { {math.floor(entity.position()[1] + self.displaySize), math.floor(entity.position()[2])}, self.displaySize, entity.id() }, withoutEntityId = entity.id()})

	if #entityIds == 1 then
		storage.connectedRight = entityIds[1]
	else
		storage.connectedRight = false
	end
end

function pingLeft()
	local entityIds = world.entityQuery({entity.position()[1] - self.displaySize, entity.position()[2]}, 1,
	   { callScript = "isSevenSegmentDisplayToLeft", callScriptArgs = { {math.floor(entity.position()[1] - self.displaySize), math.floor(entity.position()[2])}, self.displaySize, entity.id() }, withoutEntityId = entity.id()})

	if #entityIds == 1 then
		storage.connectedLeft = entityIds[1]
	else
		storage.connectedLeft = false
	end
end

function isSevenSegmentDisplayToRight(pos, displaySize, entityId)
	if pos[1] == math.floor(entity.position()[1]) and pos[2] == math.floor(entity.position()[2]) and displaySize == self.displaySize then
		storage.connectedLeft = entityId
		updateLinkAnimationState()
		return true
	else
		return false
	end
end

function isSevenSegmentDisplayToLeft(pos, displaySize, entityId)
	if pos[1] == math.floor(entity.position()[1]) and pos[2] == math.floor(entity.position()[2]) and displaySize == self.displaySize then
		storage.connectedRight = entityId
		updateLinkAnimationState()
		return true
	else
		return false
	end
end