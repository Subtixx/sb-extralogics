function init(virtual)
  if virtual then return end
    object.setInteractive(true)
	
	self.pos = entity.position()
    self.pos = {self.pos[1] + 0.5,self.pos[2] + 0.5}
	
	self.timer = 0
	
	storage.settings = {}
	storage.settings.range = 5.5

    
    self.modes = { "heal", "fire", "lowgrav", "glow" }
    if storage.currentDisplayMode == nil then
      storage.currentDisplayMode = self.modes[1]
      storage.currentMode = self.modes[1]
    end

    updateAnimationState()
end

function onNodeConnectionChange()
end

function onInteraction()
  cycleMode()
end

function cycleMode()
  for i, mode in ipairs(self.modes) do
    if mode == storage.currentMode then
      storage.currentDisplayMode = self.modes[(i % #self.modes) + 1]
      storage.currentMode = storage.currentDisplayMode
      updateAnimationState()
      return
    end
  end

  --previous mode invalid, default to mode 1
  storage.currentDisplayMode = self.modes[1]
  storage.currentMode = storage.currentDisplayMode
  updateAnimationState()
end

function updateAnimationState()
  animator.setAnimationState("scannerState", storage.currentDisplayMode)
end

function doDetect()
	local ids = world.playerQuery(self.pos, storage.settings.range)
	for i, entityId in pairs(ids) do
		local entityType = world.entityType(entityId)
		if(entityType == "player") then
			if(storage.currentMode == "heal") then
				world.sendEntityMessage(entityId, "applyStatusEffect", "regeneration4", 0.5)
			elseif(storage.currentMode == "fire") then
				world.sendEntityMessage(entityId, "applyStatusEffect", "burning", 0.5)
			elseif(storage.currentMode == "lowgrav") then
				world.sendEntityMessage(entityId, "applyStatusEffect", "lowgrav", 0.5)
			elseif(storage.currentMode == "glow") then
				world.sendEntityMessage(entityId, "applyStatusEffect", "glow", 0.5)
			end
		end
	end
end
  
function update(dt)
	if(object.isInputNodeConnected(0) and object.getInputNodeLevel(0)) then
		if(storage.currentDisplayMode ~= "off") then
			storage.currentDisplayMode = "off"
			object.setInteractive(false)
		end
		
		updateAnimationState()
		return
	end
	
	if(storage.currentDisplayMode == "off") then
		storage.currentDisplayMode = storage.currentMode
		updateAnimationState()
		object.setInteractive(true)
	end
	
	if self.timer > 0 then
		self.timer = self.timer - dt
	else
		doDetect()
	end
end