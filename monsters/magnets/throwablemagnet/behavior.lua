function init(args)
  self.dead = false

  -- Data doesn't attack people
  monster.setDamageOnTouch(false)
  monster.setAggressive(false)
  animator.setAnimationState("default", "idle")
  
  local velMult = 10
  local pos = entity.position()
  local players = world.playerQuery(pos, 5, { order = "nearest" })
  if #players > 0 then
    local playerPos = world.entityPosition(players[1])
    local diff = world.distance(pos, playerPos)
    local vel = {diff[1] * velMult, diff[2] * velMult}
    mcontroller.setVelocity(vel)
  end
  
  self.magSpeed = 0
  self.damageMultiplier = 2
  self.radiusMultiplier = 0.05
  self.velThreshold = 150
  self.oldVel = lengthSquared(mcontroller.velocity())
end

function update(dt)
  local vel = mcontroller.velocity()
  local velMag = lengthSquared(vel)
  
  if self.oldVel - velMag > self.velThreshold then
    self.magSpeed = math.sqrt(self.oldVel) - math.sqrt(self.velThreshold)
    self.dead = true
  end
  
  self.oldVel = velMag
end

function damage(args)
  if status.resource("health") <= 0 then
    self.dead = true
  end
end

function die()
  local damage = self.magSpeed * self.damageMultiplier
  local radius = self.magSpeed * self.radiusMultiplier
  local r2 = radius * 0.7071
  
  world.spawnProjectile("magnetexplosion", entity.position(), entity.id(), {0, 0}, false, {
    power = damage,
    damagePoly = { {-radius, 0}, {-r2, -r2}, {0, -radius}, {r2, -r2}, {radius, 0}, {r2, r2}, {0, radius}, {-r2, r2} },
    actionOnReap =  {
      {
        action = "explosion",
        foregroundRadius = radius,
        backgroundRadius = 0,
        explosiveDamageAmount = damage,
        delaySteps = 0
      }
    }
  })
  world.spawnItem("throwablemagnet", entity.position(), 1)
end

function shouldDie()
  return self.dead
end

function isMagnetized()
  return true
end

function lengthSquared(vec)
  return vec[1] * vec[1] + vec[2] * vec[2]
end