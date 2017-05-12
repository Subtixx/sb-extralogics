-- TODO: UI
function init(virtual)
  if not virtual then
    if not storage.data then
      storage.data = ""
    end
    
    datawire.init()
  end

  object.setInteractive(true)
end

function onInteraction()
  -- TODO: UI
end

function onNodeConnectionChange()
  datawire.onNodeConnectionChange()
end

function output()
  datawire.sendData(storage.data, "string", 0)
end

function update(dt)
  datawire.update()
  output()
end