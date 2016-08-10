-- TODO: Maybe add a way to increase the size of the pitfall with datawires.
---      Sending two numbers one for X and one for Y
function init()
	camoflague(true)
end

function onInputNodeChange()
	camoflague(not object.getInputNodeLevel(0))
end

function update(dt)
	--camoflague(not object.getInputNodeLevel(0))
end

function camoflague(camo)
  if self.oldCamo == nil or self.oldCamo ~= camo then
    self.oldCamo = camo

    if(camo) then
    	animator.setAnimationState("camoState", "hidden")
    end
    local mat = camo and world.material(entity.position(), "background") or "metamaterial:empty"
    object.setMaterialSpaces({{{0,0},mat}})
  end
end