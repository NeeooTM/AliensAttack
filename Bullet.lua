Bullet = class{}

bullets = {}

BULLET_VELOCITY = 100
FIRE_COOL_DOWN = false

function Bullet:init()

  self.texture = love.graphics.newImage('graphics/bullet.png')

  self.w = 2
  self.h = 10
  self.currentBullet = 0
  self.currentMaxAmmo = 7
  self.bulletsLeft = 7

  self.reloadTime = 0

end

function Bullet:new(x, y)

  if FIRE_COOL_DOWN == false then

    local temp = 	{ x = x, y = y, w = self.w, h = self.h }
    self.currentBullet = self.currentBullet + 1
    self.bulletsLeft = self.bulletsLeft - 1
    table.insert(bullets, temp)

    if bullet.currentBullet == self.currentMaxAmmo then
      FIRE_COOL_DOWN = true
      self.reloadTime = 2
      self.currentBullet = 0
    end

  end 

end

function Bullet:update(dt)

  for i,v in ipairs(bullets) do 
		v.y = v.y - BULLET_VELOCITY * dt
  end
  
  if FIRE_COOL_DOWN == true and self.reloadTime < 0 then
    FIRE_COOL_DOWN = false
    self.bulletsLeft = maxAmmo
    self.currentMaxAmmo = maxAmmo
    sounds['reload']:play()
  end
  
  self.reloadTime = self.reloadTime - dt

end

function Bullet:render()

  love.graphics.draw(self.texture, 10, 30)

  for i, v in ipairs(bullets) do
    love.graphics.setColor(1,1,0)
    love.graphics.rectangle('fill', v.x, v.y, self.w, self.h)
    love.graphics.setColor(1,1,1)
  end

end
