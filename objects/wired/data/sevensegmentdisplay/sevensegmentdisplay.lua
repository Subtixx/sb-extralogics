function init()
	animator.setAnimationState("linkState", "none")
end

function onInputNodeChange()
	animator.setAnimationState("aDataState", object.getInputNodeLevel(0) and "on" or "off")
	animator.setAnimationState("bDataState", object.getInputNodeLevel(1) and "on" or "off")
	animator.setAnimationState("cDataState", object.getInputNodeLevel(2) and "on" or "off")
	animator.setAnimationState("dDataState", object.getInputNodeLevel(3) and "on" or "off")
	animator.setAnimationState("eDataState", object.getInputNodeLevel(4) and "on" or "off")
	animator.setAnimationState("fDataState", object.getInputNodeLevel(5) and "on" or "off")
	animator.setAnimationState("gDataState", object.getInputNodeLevel(6) and "on" or "off")
end

function update(dt)
end