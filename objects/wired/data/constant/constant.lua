-- TODO: UI
function init(virtual)
    if not virtual then
        if not storage.data then
            storage.data = ""
        end

        datawire.init()
        object.setInteractive(true)
    end
    message.setHandler("setData", onDataReceived)
end

function onDataReceived(_, _, data)
    if(data["constant"] ~= nil) then
        storage.data = string.upper(data["constant"])
    end
    --[[for k,v in pairs(data) do
        storage.data = v
    end]]
end

function onInteraction(args)
    local interactionConfig = root.assetJson(config.getParameter("interactData"))
    interactionConfig.data = storage.data
    return {"ScriptPane", interactionConfig}
end

function onNodeConnectionChange()
    datawire.onNodeConnectionChange()
end

function validateData(data, dataType, nodeId, sourceEntityId)
    return false
end

function output()
    datawire.sendData(storage.data, "string", 0)
end

function update(dt)
    datawire.update()
    output()
end