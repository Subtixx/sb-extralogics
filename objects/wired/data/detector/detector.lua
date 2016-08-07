require "/scripts/util.lua"

function init(virtual)
	if virtual then return end
	object.setInteractive(true)
	object.setAllOutputNodes(false)
	
	self.pos = entity.position()
	self.pos = {self.pos[1] + 0.5,self.pos[2] + 0.5}

	self.timer = 0
	
	self.modes = config.getParameter("modes") or {"all", "owner", "player", "monster", "item", "npc", "vehicle"}

	--storage.currentMode = storage.currentMode or self.modes[1]
	--animator.setGlobalTag("modePart", storage.currentMode)
	
	if not storage.settings then
		storage.settings = {}
		local savedDefaults = root.getConfiguration("Detector")
		if savedDefaults then
			onDataReceived(nil, nil, savedDefaults)
		else
			onDataReceived(nil, nil, config.getParameter("defaultStorage"))
		end
	end
	message.setHandler("setData", onDataReceived)
end

function onInteraction(args)
  storage.owner = world.entityName(args["sourceId"])

  local interactionConfig = root.assetJson(config.getParameter("interactData"))
  interactionConfig.settings = storage.settings
  return {"ScriptPane", interactionConfig}
end

function onDataReceived(_, _, data)
	for k,v in pairs(data) do
		if(k == "mode") then
			animator.setGlobalTag("modePart", self.modes[v])
			sb.logInfo(sb.print(self.modes[v]))
			sb.logInfo(sb.print(k))
		end
		storage.settings[k] = v
	end
end

function entitiesInRange()
  if(storage.settings.mode == 1 or storage.settings.mode == 2) then --owner
		local ids = world.playerQuery(self.pos, storage.settings.range)
		if not storage.settings.ignoreWalls then ids = util.filter(ids, filterInSight) end
	   for _, entityId in pairs(ids) do
		if world.entityName(entityId) == storage.owner then
		   return true
		end
	 end
  end
  
  if storage.settings.mode == 1 or storage.settings.mode == 3 then --players
    local ids = world.playerQuery(self.pos, storage.settings.range)
    if not storage.settings.ignoreWalls then ids = util.filter(ids, filterInSight) end
	  if #ids > 0 then return true end
  end

  if storage.settings.mode == 1 or storage.settings.mode == 7 then --vehicle
    local ids = world.entityQuery(self.pos, storage.settings.range, {includedTypes = {"vehicle"}})
    if not storage.settings.ignoreWalls then ids = util.filter(ids, filterInSight) end
	  if #ids > 0 then return true end
  end

  if storage.settings.mode == 1 or storage.settings.mode == 5 then --items
    local ids = world.itemDropQuery(self.pos, storage.settings.range)
    if not storage.settings.ignoreWalls then ids = util.filter(ids, filterInSight) end
	  if #ids > 0 then return true end
  end
  
  if storage.settings.mode == 1 or storage.settings.mode == 6 then --npcs
    local ids = world.npcQuery(self.pos, storage.settings.range)
    if not storage.settings.ignoreWalls then ids = util.filter(ids, filterInSight) end
	  if #ids > 0 then return true end
  end

  if storage.settings.mode == 1 or storage.settings.mode == 4 then --monsters
    local ids = world.monsterQuery(self.pos, storage.settings.range)
    if not storage.settings.ignoreWalls     then ids = util.filter(ids, filterInSight) end
    if #ids > 0 then return true end
  end
  
  --if storage.settings.mode == 8 then --solar?
--	if world.lightLevel(self.pos) >= storage.settings.lightlevel then return true end
  --end

  return false
end

function filterInSight(eid)
	local max = storage.settings.camo and 2 or 1
  return max > #world.collisionBlocksAlongLine(self.pos, world.entityPosition(eid), nil, max)
end

function update(dt)
   --stupid tags don't update properly in init()
   --animator.setGlobalTag("modePart", self.modes[storage.settings.mode])
   
   	if self.timer > 0 then
		self.timer = self.timer - dt
	else
		local found = entitiesInRange()
		object.setAllOutputNodes(found)
		
		if storage.settings.hidden or storage.settings.camo then
			animator.setAnimationState("detectorState", "hidden")
		else
			if(found) then
				animator.setAnimationState("detectorState", "on")
			else
				animator.setAnimationState("detectorState", "off")
			end
		end
		camoflague(storage.settings.camo)
		self.timer = 0.2
	end
end

function camoflague(camo)
  if self.oldCamo == nil or self.oldCamo ~= camo then
    self.oldCamo = camo

    local mat = camo and world.material(entity.position(), "background") or "metamaterial:empty"
    object.setMaterialSpaces({{{0,0},mat},{{-1,-1},mat},{{0,-1},mat},{{-1,0},mat}})
  end
end