function init(args)
  self.dead = false

  -- Data doesn't attack people
  monster.setDamageOnTouch(false)
  monster.setAggressive(false)
  animator.setAnimationState("default", "idle")
end

function main()
end

function damage(args)
  -- Data doesn't die from damage
end

-- Function to let the magnetblock destroy this piece of data
function kill()
  self.dead = true
end

function shouldDie()
  return self.dead
end