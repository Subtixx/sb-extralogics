require "/scripts/util.lua"

function init()
	local data = config.getParameter("data")
	widget.setText("tbxConstant", tostring(data))
end

function saveConstantValue()
	send("constant", widget.getText("tbxConstant"))
end

function setConstantValue()

end

function send(dataOrKey, value)
	local data = dataOrKey
	if type(dataOrKey) ~= table then
	  data = {}
	  data[dataOrKey] = value
	end
  	world.sendEntityMessage(pane.sourceEntity(), "setData", data)
end