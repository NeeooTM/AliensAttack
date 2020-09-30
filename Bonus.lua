Bonus = class{}

bonuses = {}

function Bonus:init()

  self.healthBonusTexture = love.graphics.newImage('graphics/restore_health_bonus.png') 
  self.ammoBonusTexture = love.graphics.newImage('graphics/additional_ammo_bonus.png') 

  self.w = 16
  self.h = 16

  self.timer = 0
  self.spawnTime = 30

end

function Bonus:new(x, y, type)
	local temp = 	{ x = x, y = y, w = self.w, h = self.h, type = type }
	table.insert(bonuses, temp)
end


function Bonus:update(dt)

  self.timer = self.timer + dt
  if self.timer > self.spawnTime then
    -- math.random for a different position everytime you spawn an enemy
		bonus:new(math.random(0, VIRTUAL_WIDTH - 15), math.random(0, VIRTUAL_HEIGHT - 16), math.random(0, 1))
		self.timer = 0
  end

end

function Bonus:render()

  for i, v in ipairs(bonuses) do
    if v.type == 1 then
      love.graphics.draw(self.ammoBonusTexture, v.x, v.y)
    else 
      love.graphics.draw(self.healthBonusTexture, v.x, v.y)
    end
  end

end