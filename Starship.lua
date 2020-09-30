Starship = class{}

MOVE_SPEED = 160

require 'Bullet'

function Starship:init()

  self.shuttleTexture = love.graphics.newImage('graphics/shuttle.png')
  self.healthTexture = love.graphics.newImage('graphics/health.png')

  self.w = self.shuttleTexture:getWidth()
  self.h = self.shuttleTexture:getHeight()

  self.x = VIRTUAL_WIDTH / 2 - 10
  self.y = 200
  
end

function Starship:update(dt)

  if love.keyboard.isDown('a') then
    self.x = self.x - MOVE_SPEED * dt
  elseif love.keyboard.isDown('d') then
    self.x = self.x + MOVE_SPEED * dt
  end

  if love.keyboard.isDown('w') then
    self.y = self.y - MOVE_SPEED * dt
  elseif love.keyboard.isDown('s') then
    self.y = self.y + MOVE_SPEED * dt
  end

  if FIRE_COOL_DOWN == false then
    if love.keyboard.wasPressed('space') then
      sounds['laser_shoot']:stop()
      sounds['laser_shoot']:play()
      bullet:new(self.x + 6, self.y - 9)
    elseif love.keyboard.wasPressed('r') then
      FIRE_COOL_DOWN = true
      bullet.reloadTime = 1.5
      bullet.currentBullet = 0
      bullet.bulletsLeft = 0
    end
  end

end

function Starship:render()
  love.graphics.draw(self.shuttleTexture, self.x, self.y)
  love.graphics.draw(self.healthTexture, 10, 10)
end