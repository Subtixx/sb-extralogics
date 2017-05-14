function init(virtual)
  -- self.displayCharSet = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-"}
  -- self.linkStates = {"none", "left", "right", "both"}

  if not virtual then
    self.dataFormat = config.getParameter("dataFormat")
    if self.dataFormat == nil then
      self.dataFormat = "%d"
    end

    self.displaySize = config.getParameter("displaySize")
    if self.displaySize == nil then
      --maybe no point to setting a default since this will totally break if it's wrong
      self.displaySize = 1
    end

    storage.supportedColors = {
        "default", -- default color
        "black",
        "pink",
        "orange",
        "yellow",
        "green",
        "blue",
        "red"
    }
    storage.color = config.getParameter("color") and config.getParameter("color") or 1

    object.setInteractive(true)

    datawire.init()
  end
end

function onInteraction()
  if(storage.color < #storage.supportedColors) then
    storage.color = storage.color + 1
  else
    storage.color = 1
  end

  setSegmentColor(storage.color)
  object.say("Set color to " .. storage.supportedColors[storage.color])
end

function initAfterLoading()
  findAdjacentSegments()
end

function onNodeConnectionChange()
  datawire.onNodeConnectionChange()
end

function die()
  if storage.connectedRight then
    world.callScriptedEntity(storage.connectedRight, "disconnectLeft")
  end

  if storage.connectedLeft then
    world.callScriptedEntity(storage.connectedLeft, "disconnectRight")
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

  if storage.data == nil then
    if storage.connectedLeft then
      storage.data = world.callScriptedEntity(storage.connectedLeft, "getData", {})
    end
  end
end

function pingRight()
  local entityIds = world.entityQuery({entity.position()[1] + self.displaySize, entity.position()[2]}, 1,
     { callScript = "isLinkedDisplayToRight", callScriptArgs = { {math.floor(entity.position()[1] + self.displaySize), math.floor(entity.position()[2])}, self.displaySize, entity.id() }, withoutEntityId = entity.id()})

  if #entityIds == 1 then
    storage.connectedRight = entityIds[1]
  else
    storage.connectedRight = false
  end
end

function pingLeft()
  local entityIds = world.entityQuery({entity.position()[1] - self.displaySize, entity.position()[2]}, 1,
      { callScript = "isLinkedDisplayToLeft", callScriptArgs = { {math.floor(entity.position()[1] - self.displaySize), math.floor(entity.position()[2])}, self.displaySize, entity.id() }, withoutEntityId = entity.id()})

  if #entityIds == 1 then
    storage.connectedLeft = entityIds[1]
  else
    storage.connectedLeft = false
  end
end

function isLinkedDisplayToRight(pos, displaySize, entityId)
  if pos[1] == math.floor(entity.position()[1]) and pos[2] == math.floor(entity.position()[2]) and displaySize == self.displaySize then
    storage.connectedLeft = entityId
    updateLinkAnimationState()
    return true
  else
    return false
  end
end

function isLinkedDisplayToLeft(pos, displaySize, entityId)
  if pos[1] == math.floor(entity.position()[1]) and pos[2] == math.floor(entity.position()[2]) and displaySize == self.displaySize then
    storage.connectedRight = entityId
    updateLinkAnimationState()
    return true
  else
    return false
  end
end

function validateData(data, dataType, nodeId, sourceEntityId)
  --return dataType == "number"
  return true
end

function onValidDataReceived(data, dataType, nodeId, sourceEntityId)
  setData(data)
end

function getData()
  return storage.data
end

function setData(data)
  storage.data = tostring(data)

  if storage.connectedRight then
    world.callScriptedEntity(storage.connectedRight, "setData", data)
  end

  return true
end

function takeOneAndPassToYourLeft(args)
  --abort if not initialized
  if not datawire.initialized then return end

  storage.data = args.data

  --take one
  local newDisplayData
  if #args.dataString >= 1 then
    newDisplayData = args.dataString:sub(#args.dataString, #args.dataString)
    if(newDisplayData == " ") then -- Check spaces and replace it with off state
      newDisplayData = "off"
   end
  end
  updateDisplay(newDisplayData)

  --pass to your left
  if storage.connectedLeft then
    world.callScriptedEntity(storage.connectedLeft, "takeOneAndPassToYourLeft", {data = args.data, dataString = args.dataString:sub(1, #args.dataString - 1)})
  end
end

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

function updateDisplay(newDisplayData)
  if newDisplayData and newDisplayData ~= "" then
    if object.direction() == 1 then
      animator.setAnimationState("dataState", newDisplayData)
    else
      animator.setAnimationState("dataState", "flipped."..newDisplayData)
    end
  else
    animator.setAnimationState("dataState", "off")
  end

  storage.currentDisplayData = newDisplayData
end

function update(dt)
  datawire.update()

  if storage.data then
    if not storage.connectedRight then
	  if(self.dataFormat == "%.1f" and math.floor(storage.data) ~= storage.data) then
		  dataStr = string.format(self.dataFormat, storage.data)
	  else
      if(storage.data:match("[^%w%s]")) then dataStr = "0" else
      --dataStr = string.format("%d", math.floor(storage.data))
	    dataStr = string.format("%s", string.upper(tostring(storage.data))) -- Force string & upper
      end
	  end
	  takeOneAndPassToYourLeft({data = storage.data, dataString = dataStr:sub(1, #dataStr)})
    end
  end
end

function setSegmentColor(color)
    if(storage.supportedColors[color]) then
        animator.setPartTag("display", "color", storage.supportedColors[color])
        object.setConfigParameter("color", color)
    else
        sb.logError("Unsupported color in link display: " .. sb.print(color))
    end
end