love.window.setTitle("Aliens Attack!")

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

class = require 'class'
push = require 'push'

require 'Starship'
require 'Enemy'
require 'Bullet'
require 'Bonus'

function love.load()

  math.randomseed(os.time())

  -- makes upscaling look pixel-y instead of blurry
  love.graphics.setDefaultFilter('nearest', 'nearest')

  -- sets up virtual screen resolution for an authentic retro feel
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {fullscreen = false, resizable = true})

  -- load all fonts
  loadFonts()

  -- load background
  background = love.graphics.newImage("graphics/background.png")
  
  gameStates = {
    ['play'] = 'play',
    ['start'] = 'start',
    ['death'] = 'death'
  }

  sounds = {
    ['bonus_pickup'] = love.audio.newSource('sfx/bonus_pickup.wav', 'static'),
    ['death'] = love.audio.newSource('sfx/death.wav', 'static'),
    ['kill'] = love.audio.newSource('sfx/kill.wav', 'static'),
    ['laser_shoot'] = love.audio.newSource('sfx/laser_shoot.wav', 'static'),
    ['reload'] = love.audio.newSource('sfx/reload.wav', 'static')
  }

  music = love.audio.newSource('sfx/imperial_march.mp3', 'static') 

  state = gameStates['start']

  music:setLooping(true)
  music:setVolume(0.07)
  music:play()

  love.keyboard.keysPressed = {}
  love.keyboard.keysReleased = {}

end

function love.update(dt)

  if state == 'play' then
    player:update(dt)
    enemy:update(dt)
    bullet:update(dt)
    bonus:update(dt)

    checkCollisions()
  
    -- reset all keys pressed and released this frame
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
  end

  if state == 'play' and health == 0 then
    sounds['death']:play()
    state = 'death'
  end

end

function love.draw()

  -- begin rendering at virtual resolution
  push:apply('start')

  love.graphics.setFont(smallFont)

  if state == 'start' then
    showStartMessage()
  end

  if state == 'play' then

    loadBackground(background)
    displayLogMessages()

    player:render()
    enemy:render()
    bullet:render()
    bonus:render()

  end

  if state == 'death' then
    loadBackground(background)
    showDeathMessage()
  end
  
  -- end rendering at virtual resolution
  push:apply('end')
  
end

function startGame()

  player = Starship()
  enemy = Enemy()
  bullet = Bullet()
  bonus = Bonus()

  health = 3
  score = 0
  enemyVelocity = 25
  enemySpawnTime = 3
  maxAmmo = 7

end

function displayLogMessages()

  love.graphics.setColor(1,1,1)
  love.graphics.printf("x " .. tostring(health), 25, 11, VIRTUAL_WIDTH)
  love.graphics.printf(tostring(bullet.bulletsLeft) .. "/" .. tostring(maxAmmo), 30, 31, VIRTUAL_WIDTH)
  love.graphics.printf("" .. tostring(score), VIRTUAL_WIDTH / 2 - 6, 11, VIRTUAL_WIDTH)

end

function showStartMessage()
  love.graphics.setFont(bigFont)
  love.graphics.setColor(0,1,1)
  love.graphics.printf("Welcome to Aliens Attack!", 0, 10, VIRTUAL_WIDTH, 'center')
  love.graphics.setColor(1,1,1)
  love.graphics.setFont(mediumFont)
  love.graphics.printf("Press Enter to Play!", 0, 75, VIRTUAL_WIDTH, 'center')
  love.graphics.setColor(1,1,0)
  love.graphics.printf("Game Controls:", 0, 130, VIRTUAL_WIDTH, 'center')
  love.graphics.printf("Move:", -75, 160, VIRTUAL_WIDTH, 'center')
  love.graphics.printf("W", -75, 185, VIRTUAL_WIDTH, 'center')
  love.graphics.printf("ASD", -75, 197, VIRTUAL_WIDTH, 'center')
  love.graphics.printf("Fire:", 0, 160, VIRTUAL_WIDTH, 'center')
  love.graphics.printf("SPACE", 0, 189, VIRTUAL_WIDTH, 'center')
  love.graphics.printf("Reload:", 75, 160, VIRTUAL_WIDTH, 'center')
  love.graphics.printf("R", 75, 189, VIRTUAL_WIDTH, 'center')
  love.graphics.setColor(1,1,1)
  love.graphics.setFont(smallFont)
end

function showDeathMessage()
  love.graphics.setFont(bigFont)
  love.graphics.setColor(1,0,0)
  love.graphics.printf("YOU DIED!", 0, 10, VIRTUAL_WIDTH, 'center')
  love.graphics.setColor(1,1,1)
  love.graphics.setFont(mediumFont)
  love.graphics.printf("Total score:", 0, 110, VIRTUAL_WIDTH, 'center')
  love.graphics.printf("" .. tostring(score), 0, 140, VIRTUAL_WIDTH, 'center')
  love.graphics.setColor(1,1,0)
  love.graphics.setFont(smallFont)
  love.graphics.printf("Thanks for playing! :)", 0, 230, VIRTUAL_WIDTH, 'center')
end

function checkCollisions()

  -- don't give to player get out of boundaries(X)
  if player.x <= -1 then
    player.x = -1
  elseif player.x >= VIRTUAL_WIDTH - 15 then
    player.x = VIRTUAL_WIDTH - 15
  end

  -- don't give to player get out of boundaries(Y)
  if player.y <= 0 then
    player.y = 0
  elseif player.y >= VIRTUAL_HEIGHT - 16 then
    player.y = VIRTUAL_HEIGHT - 16
  end

  for index, enemy in ipairs(enemies) do
    if enemy.y >= VIRTUAL_HEIGHT - 8 then
      health = health - 1
      sounds['kill']:stop()
      sounds['kill']:play()
      table.remove(enemies, index)
    end
  end

  for index, enemy in ipairs(enemies) do
    if intersects(player, enemy) or intersects(enemy, player) then
      health = health - 1
      sounds['kill']:stop()
      sounds['kill']:play()
      table.remove(enemies, index)
    end
  end

  for index, bonus in ipairs(bonuses) do
    if intersects(player, bonus) then
      if bonus.type == 1 then
        maxAmmo = maxAmmo + 1
      else 
        health = health + 1
      end
      sounds['bonus_pickup']:stop()
      sounds['bonus_pickup']:play()
      table.remove(bonuses, index)
    end
  end

  for index, enemy in ipairs(enemies) do
    for index2, bullet in ipairs(bullets) do
      if intersects(enemy, bullet) then

        score = score + 100
        sounds['kill']:stop()
        sounds['kill']:play()
        increaseTheDifficulty()

        table.remove(enemies, index)
        table.remove(bullets, index2)
        break

      end
    end
  end
end

function intersects(rect1, rect2)
  if rect1.x < rect2.x and rect1.x + rect1.w > rect2.x and
     rect1.y < rect2.y and rect1.y + rect1.h > rect2.y then
    return true
  else
    return false
  end
end

function changeGameState(gameState)
  state = gameState
end

function increaseTheDifficulty()

  if enemySpawnTime >= 1.8 then
    enemySpawnTime = enemySpawnTime - 0.05
  end

  if enemyVelocity <= 80 then
    enemyVelocity = enemyVelocity * 1.02
  end

end

function loadFonts()
  smallFont = love.graphics.newFont('fonts/font.ttf', 8)
  mediumFont = love.graphics.newFont('fonts/font.ttf', 16)
  bigFont = love.graphics.newFont('fonts/font.ttf', 28)
end

function love.resize(w, h)
  push:resize(w, h)
end

function loadBackground(background)
  for i = 0, love.graphics.getWidth() / background:getWidth() do
    for j = 0, love.graphics.getHeight() / background:getHeight() do
      love.graphics.draw(background, i * background:getWidth(), j * background:getHeight())
    end
  end
end

function love.keypressed(key)
  if key == 'enter' or key == 'return' then
    if state == 'start' then
      changeGameState(gameStates['play'])
      startGame()
    end
  end

  if key == 'escape' then
      love.event.quit()
  end
  
  love.keyboard.keysPressed[key] = true
end

function love.keyreleased(key)
  love.keyboard.keysReleased[key] = true
end

function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end

function love.keyboard.wasReleased(key)
    if (love.keyboard.keysReleased[key]) then
        return true
    else
        return false
    end
end