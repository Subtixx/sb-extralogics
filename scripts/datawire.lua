datawire = {}

--- this should be called by the implementing object in its own init()
function datawire.init()
  datawire.inboundConnections = {}
  datawire.outboundConnections = {}

  datawire.initialized = false
  
  message.setHandler("datawire.receiveData", datawire.receiveData)
end

--- this should be called by the implementing object in its own onNodeConnectionChange()
function datawire.onNodeConnectionChange()
  datawire.createConnectionTable()
end

--- any datawire operations that need to be run when main() is first called
function datawire.update()
  if datawire.initialized then
    -- nothing for now
  else
    datawire.initAfterLoading()
    if initAfterLoading then initAfterLoading() end
  end
end

-------------------------------------------

--- this will be called internally, to build connection tables once the world has fully loaded
function datawire.initAfterLoading()
  datawire.createConnectionTable()
  datawire.initialized = true
end

--- Creates connection tables for inbound and outbound nodes
function datawire.createConnectionTable()
  datawire.outboundConnections = {}
  local i = 0
  while i < object.outputNodeCount() do
    local connInfo = object.getOutputNodeIds(i)
    local entityIds = {}
    for k, v in pairs(connInfo) do
      entityIds[#entityIds + 1] = k --v[1]
    end
    datawire.outboundConnections[i] = entityIds
    i = i + 1
  end

  datawire.inboundConnections = {}
  i = 0
  while i < object.inputNodeCount() do
    local connInfo = object.getInputNodeIds(i)
    for k, v in pairs(connInfo) do
      datawire.inboundConnections[k] = i
    end
    i = i + 1
  end

  --sb.logInfo(string.format("%s (id %s) created connection tables for %d outbound and %d inbound nodes", config.getParameter("objectName"), sb.print(entity.id()), object.outputNodeCount(), object.inputNodeCount()))
  --sb.logInfo("outbound: %s", datawire.outboundConnections)
  --sb.logInfo("inbound: %s", datawire.inboundConnections)
end

--- determine whether there is a valid recipient on the specified outbound node
-- @param nodeId the node to be queried
-- @returns true if there is a recipient connected to the node
function datawire.isOutboundNodeConnected(nodeId)
  return datawire.outboundConnections and datawire.outboundConnections[nodeId] and #datawire.outboundConnections[nodeId] > 0
end

--- Sends data to another datawire object
-- @param data the data to be sent
-- @param dataType the data type to be sent ("boolean", "number", "string", "area", etc.)
-- @param nodeId the outbound node id to send to, or "all" for all outbound nodes
-- @returns true if at least one object successfully received the data
function datawire.sendData(data, dataType, nodeId)
  -- don't transmit if connection tables haven't been built
  if not datawire.initialized then
    return false
  end

  local transmitSuccess = false

  if nodeId == "all" then
    for k, v in pairs(datawire.outboundConnections) do
      transmitSuccess = datawire.sendData(data, dataType, k) or transmitSuccess
    end
  else
    if datawire.outboundConnections[nodeId] and #datawire.outboundConnections[nodeId] > 0 then 
      for i, entityId in ipairs(datawire.outboundConnections[nodeId]) do
        if entityId ~= entity.id() then
		  transmitSuccess = world.sendEntityMessage(entityId, "datawire.receiveData", { data, dataType, entity.id() }) or transmitSuccess
          --transmitSuccess = world.callScriptedEntity(entityId, "datawire.receiveData", { data, dataType, entity.id() }) or transmitSuccess
        end
      end
    end
  end

  -- if not transmitSuccess then
  --   sb.logInfo(string.format("DataWire: %s (id %d) FAILED to send data of type %s", entity.configParameter("objectName"), entity.id(), dataType))
  --   sb.logInfo(data)
  -- end

  return transmitSuccess
end

--- Receives data from another datawire object
-- @param data (args[1]) the data received
-- @param dataType (args[2]) the data type received ("boolean", "number", "string", "area", etc.)
-- @param sourceEntityId (args[3]) the id of the sending entity, which can be use for an imperfect node association
-- @returns true if valid data was received
function datawire.receiveData(_, _, args)
  --unpack args
  local data = args[1]
  local dataType = args[2]
  local sourceEntityId = args[3]

  -- sb.logInfo("%s %d sent me this %s %s", world.callScriptedEntity(sourceEntityId, "entity.configParameter", "objectName"), sourceEntityId, dataType, data)

  --convert entityId to nodeId
  local nodeId = datawire.inboundConnections[sourceEntityId]

  if nodeId == nil then
    if datawire.initialized then
       sb.logInfo("DataWire: %s received data of type %s from UNRECOGNIZED %s %s, not in table:", config.getParameter("objectName"), dataType, world.callScriptedEntity(sourceEntityId, "config.getParameter", "objectName"), sb.print(sourceEntityId))
       sb.logInfo("%s", datawire.inboundConnections)
    end

    return false
  elseif validateData and validateData(data, dataType, nodeId, sourceEntityId) then
    if onValidDataReceived then
      onValidDataReceived(data, dataType, nodeId, sourceEntityId)
    end

    --sb.logInfo(string.format("DataWire: %s received data %s of type %s on node %s from %s (%s)", config.getParameter("objectName"), sb.print(data), dataType, sb.print(nodeId), world.callScriptedEntity(sourceEntityId, "config.getParameter", "objectName"), sb.print(sourceEntityId)))

    return true
  else
    sb.logInfo("DataWire: %s received INVALID data of type %s from entity %s: %s", config.getParameter("objectName"), dataType, sb.print(sourceEntityId), data)
    
    return false
  end
end