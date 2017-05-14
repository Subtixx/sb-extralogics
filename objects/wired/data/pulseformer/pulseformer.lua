--- Object init event.
-- Gets executed when this object is placed.
-- @param virtual if this is a virtual call?
function init(virtual)
    if not virtual then
        storage.state = storage.state or false
        storage.oldInputState = storage.oldInputState or false

        if not storage.settings then
            storage.settings = {}
            local savedDefaults = root.getConfiguration("PulseFormer")
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
    if(object.isInputNodeConnected(0) == storage.oldInputState) then return end -- We only care about input state changes

    checkNodes()
    storage.oldInputState = object.isOutputNodeConnected(0)
end

--- Object node input change event.
-- Gets executed when the node input changed.
-- @param args a table containing the node and level args["node"], args["level"]
function onInputNodeChange(args)
    checkNodes()
end

--- Object update event
-- Gets executed when this object updates.
-- @param dt delta time, time is specified in *.object as scriptDelta (60 = 1 second)
function update(dt)
    if not object.isInputNodeConnected(0) then return end -- We only care if we have an input.

    if object.getOutputNodeLevel(0) == true and storage.state then
        object.setOutputNodeLevel(0, false)
        storage.state = false
        animator.setAnimationState("switchState", "off")
    end
end

--- Custom function to check input nodes for level change
function checkNodes()
    if not object.isInputNodeConnected(0) then return end -- We only care if we have an input.

    if object.getInputNodeLevel(0) == true then
        storage.state = true
        object.setOutputNodeLevel(0, true)
        animator.setAnimationState("switchState", "on")
    end
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
    -- TODO: Somehow here is a bug. The material is not the same color..
    local mat = storage.settings["camo"] and world.material(entity.position(), "background") or "metamaterial:empty"
    object.setMaterialSpaces({{{0,0},mat}, {{-1,0}, mat}, {{-1,-1},mat}, {{0,-1}, mat}}) -- TODO: Too big?

    if storage.settings["hidden"] then
        animator.setAnimationState("switchState", "hidden")
    else
        animator.setAnimationState("switchState", object.getOutputNodeLevel(0) and "on" or "off")
    end
end