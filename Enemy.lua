Enemy = class{}

enemies = {}

enemyVelocity = 25
enemySpawnTime = 3

function Enemy:init()

  self.texture = love.graphics.newImage('graphics/alien.png')

  self.width = 12
  self.height = 8

	self.timer = 0 
  
end

function Enemy:new(x, y)
	local temp = 	{ x = x, y = y, w = self.width, h = self.height }
	table.insert(enemies, temp)
end

function Enemy:update(dt)

  self.timer = self.timer + dt

  if self.timer > enemySpawnTime then
    -- math.random for a different position everytime you spawn an enemy
		enemy:new(math.random(0, VIRTUAL_WIDTH - 12), 0)
		self.timer = 0
  end
  
  for i,v in ipairs(enemies) do 
    v.y = v.y + enemyVelocity * dt
	end

end


function Enemy:render()

  for i, v in ipairs(enemies) do
    love.graphics.draw(self.texture, v.x, v.y)
  end
  
end
