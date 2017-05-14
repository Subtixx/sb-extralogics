-- TODO: Maybe add a way to increase the size of the pitfall with datawires.
---      Sending two numbers one for X and one for Y
function init(virtual)
    if not virtual then
        if storage.sizeX == nil then
            storage.sizeX = 1
        end

        if storage.sizeY == nil then
            storage.sizeY = 1
        end
        datawire.init()
    end
    camoflague(true)
end

function onNodeConnectionChange()
    datawire.onNodeConnectionChange()
end

function validateData(data, dataType, nodeId, sourceEntityId)
    --only receive data on node 0
    return (nodeId == 0 or nodeId == 1) and dataType == "number"
end

function onValidDataReceived(data, dataType, nodeId, sourceEntityId)
    -- Only x for now.
    if dataType == "number" and type(data) == "number" then

        if nodeId == 0 then
            storage.sizeX = tonumber(data)
            if storage.sizeX <= 0 or storage.sizeX > 100 then
                storage.sizeX = 1
            end
        else
            storage.sizeY = tonumber(data)
            if storage.sizeY <= 0 or storage.sizeY > 100 then
                storage.sizeY = 1
            end
        end

        camoflague(self.oldCamo, true)
    end
end

function onInputNodeChange()
    camoflague(not object.getInputNodeLevel(0))
end

function update(dt)
	datawire.update()
end

function camoflague(camo, force)
    if self.oldCamo == nil or self.oldCamo ~= camo or force then
        self.oldCamo = camo
        if(camo) then
            animator.setAnimationState("camoState", "hidden")
        end
        local mat = camo and world.material(entity.position(), "background") or "metamaterial:empty"
        --object.setMaterialSpaces({{{0,0},mat}})
        local space = {}
        --[[if world.rectTileCollision({entity.position()[1], entity.position()[2], entity.position()[1]+storage.sizeX, entity.position()[2]+storage.sizeY}) then
            storage.sizeX = 1
            storage.sizeY = 1
        end]]
        for x = 0, storage.sizeX - 1 do
            for y = 0, storage.sizeY - 1 do
                local pos = entity.position()
                pos[1] = pos[1] + x 
                pos[2] = pos[2] - y
                mat = camo and world.material(pos, "background") or "metamaterial:empty"
                table.insert(space, {{x,-y},mat})
            end
        end
        object.setMaterialSpaces(space)
    end
end