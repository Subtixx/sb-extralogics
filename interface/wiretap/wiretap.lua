require "/scripts/util.lua"

function init()
	widget.clearListItems("scrollArea.itemList")
	
	local entries = config.getParameter("entries")
	for k,v in ipairs(entries) do
		local listItem = widget.addListItem("scrollArea.itemList")
		
		
		local name = "^"..v.colour..";"..v.item.."^white;"
		local desc = v.message
		local icon = v.icon
		
		widget.setText(string.format("scrollArea.itemList.%s.itemName", listItem), name)
		widget.setText(string.format("scrollArea.itemList.%s.itemDesc", listItem), desc)
		widget.setImage(string.format("scrollArea.itemList.%s.itemIcon", listItem), icon)
	end
end