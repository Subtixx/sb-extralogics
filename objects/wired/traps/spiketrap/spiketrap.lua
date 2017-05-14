function init()

end

--- non functioning yet. have to figure out how to properly damage the player without projectiles or statuseffects
function update(dt)
	if(object.getInputNodeLevel(0)) then
		if(animator.animationState("spikesState") ~= "on") then
			animator.setAnimationState("spikesState", "on")

			object.setDamageSources(
			{
				{
				poly = {
					{-1.8, 0.3},
					{-0.8, 2.0},
					{0.8, 2.0},
					{1.8, 0.3}
				},
	         damage = 50,
	         knockback = 0,

	        damageType = "Damage",
	        damageSourceKind = "spiketrap", -- "sawblade",
	        sourceEntityId = entity.id()
			}}
			)
			--world.callScriptedEntity(,"applyDamageRequest", )
		end
		object.say("I'M ON!")
	else
		animator.setAnimationState("spikesState", "off")
		-- TODO make hidden too?
		object.setDamageSources(nil)
	end
end