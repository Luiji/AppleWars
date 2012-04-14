-- check for a collision between two sprites
-- x1, y1 is the position of the 1st sprite
-- x2, y2 is the position of the 2nd sprite
function isSpriteCollision(x1, y1, x2, y2)
    -- sprite dimensions
    local w = 48
    local h = 48

    -- algorithm
    if x1 > x2 + w - 1
       or y1 > y2 + h - 1
       or x2 > x1 + w - 1
       or y2 > y1 + h - 1 then
      return false -- no collision
    else
      return true -- yes collision
    end
end

-- check for a collision between a sprite and a tile
-- x, y is the position of the sprite
-- tiles is set in love.load (see below)
function isTileCollision (x, y)
  -- calculate the tile position by column/row in a grid (% = get remainder
  -- when divided); the -x%4 code allows us to round the tile's position to
  -- the nearest 4th pixel, so that we can more easily squeeze through tight
  -- spaces; remove it and try to squeeze through a tight space!
  tileX = (x - x % 4) / 48 + 1
  tileY = (y - y % 4) / 48 + 1

  -- get a tile at the specified position
  -- if the specified grid index is not within the grid, it returns 0
  function getTile(tileX, tileY)
    if tileX < 1 or tileX > tileMapWidth or tileY < 1 or tileY > tileMapHeight then
      return 0
    else
      return tiles[tileY][tileX]
    end
  end

  -- check for collisions by determining if there is a tile at a specified
  -- point; ceil rounds up and floor rounds down, this rounding allows us to
  -- check all four possible tiles that a sprite could be overlapping
  if getTile(math.floor (tileX), math.floor (tileY)) ~= 0
     or getTile(math.ceil (tileX), math.floor (tileY)) ~= 0
     or getTile(math.floor (tileX), math.ceil (tileY)) ~= 0
     or getTile(math.ceil (tileX), math.ceil (tileY)) ~= 0 then
    return true
  else
    return false
  end
end

-- create a player at the given position on the screen and return it
function newPlayer (x, y)
  return {type = "player", x = x, y = y, jumping = false, jumpHeight = 0}
end

-- create an enemy at the given position on the screen and return it
function newEnemy (x, y)
  return {type = "enemy", x = x, y = y, direction = "right"}
end

-- game load function
function love.load ()
  -- set the background color to red=200, green=200 and blue=200
  love.graphics.setBackgroundColor (200, 200, 200)

  -- load images
  playerImage = love.graphics.newImage ("player.png")
  enemyImage = love.graphics.newImage ("enemy.png")
  blackImage = love.graphics.newImage ("black.png")
  whiteImage = love.graphics.newImage ("white.png")

  -- position of the camera (a.k.a. the offset of the screen)
  cameraX = 0
  cameraY = 0

  -- create tile map
  tiles =
  {
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0},
    {2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 1, 0, 0, 0, 0, 0, 0},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2}
  }

  -- calculate tile map dimensions (# == get string or array length)
  tileMapWidth = #tiles[1] -- i.e. length of first row/column count
  tileMapHeight = #tiles -- i.e. length of main table/row count

  -- define player sprite
  player = newPlayer (48, 480)

  -- create sprite list
  sprites =
  {
    player,
    newEnemy (432, 480),
    newEnemy (384, 480),
    newEnemy (384 - 48, 480 - 48)
  }
end

-- game update function
-- dt: time since the last time this function was called
function love.update (dt)
  -- number used as a factor for movement
  local n = dt * 128

  -- apply the force of gravity to players and enemies
  -- gravity is not applied if there is a tile in the way
  for index, sprite in pairs (sprites) do
    if sprite["type"] == "enemy" or sprite["type"] == "player" then
      if not isTileCollision (sprite["x"], sprite["y"] + n) then
	sprite["y"] = sprite["y"] + n
      end
    end
  end

  -- move the player based on which keys are down
  -- does not move if there is a tile in the way
  if love.keyboard.isDown ("left")
    and not isTileCollision (player["x"] - n, player["y"]) then
    player["x"] = player["x"] - n
  end
  if love.keyboard.isDown ("right")
    and not isTileCollision (player["x"] + n, player["y"]) then
    player["x"] = player["x"] + n
  end

  -- jump algorithm
  -- if the player is already jumping
  if player["jumping"] then
    -- if the jump key is pressed
    if love.keyboard.isDown ("up") then
      -- jump some more
      player["jumpHeight"] = player["jumpHeight"] + n
      -- stop jumping if we have jumped to our maximum capability or if we
      -- are going to hit a tile
      if player["jumpHeight"] > 120 or isTileCollision (player["x"], player["y"] - n * 2) then
	player["jumping"] = false
      -- otherwise, jump! (* 2 to overcome gravity)
      else
	player["y"] = player["y"] - n * 2
      end
    else
      player["jumping"] = false
    end
  -- if the player is not jumping, but the jump key is pressed
  elseif love.keyboard.isDown ("up") then
    -- if we are on the floor, then jump!
    if isTileCollision (player["x"], player["y"] + 4) then
      player["jumping"] = true
      player["jumpHeight"] = 0
    end
  end

  -- check for a collision between the player and an enemy
  for index, sprite in pairs (sprites) do
    if sprite["type"] == "enemy" then
      if isSpriteCollision (player["x"], player["y"], sprite["x"], sprite["y"]) then
	-- game over! -- set window title to reflect
	love.graphics.setCaption ("GAME OVER!!!")
	-- create new sprite table with player removed
	local newSpriteTable = {}
	for index, sprite in pairs (sprites) do
	  if sprite["type"] ~= "player" then
	    table.insert (newSpriteTable, sprite)
	  end
	end
	sprites = newSpriteTable
	-- old sprite table will be automatically deleted by LOVE
      end
    end
  end

  -- move enemies based on their direction
  -- if there is a collision, then do not move and simply switch directions
  for index, sprite in pairs (sprites) do
    if sprite["type"] == "enemy" then
      if sprite["direction"] == "left" then
	if isTileCollision (sprite["x"] - n, sprite["y"]) then
	  sprite["direction"] = "right"
	else
	  sprite["x"] = sprite["x"] - n
	end
      elseif sprite["direction"] == "right" then
	if isTileCollision (sprite["x"] + n, sprite["y"]) then
	  sprite["direction"] = "left"
	else
	  sprite["x"] = sprite["x"] + n
	end
      end
    end
  end

  -- adjust camera position based on player's position
  if player["x"] - cameraX < 48 then
    cameraX = player["x"] - 48
  elseif player["x"] - cameraX > 704 then
    cameraX = player["x"] - 704
  end
  if player["y"] - cameraY < 48 then
    cameraY = player["y"] - 48
  elseif player["y"] - cameraY > 504 then
    cameraY = player["y"] - 504
  end
end

-- game drawing function
function love.draw ()
  -- render tiles
  for y, row in pairs (tiles) do
    for x, tile in pairs (row) do
      if tile == 1 then
	love.graphics.draw (blackImage, (x - 1) * 48 - cameraX, (y - 1) * 48 - cameraY)
      elseif tile == 2 then
	love.graphics.draw (whiteImage, (x - 1) * 48 - cameraX, (y - 1) * 48 - cameraY)
      end
    end
  end

  -- render sprites
  for index, sprite in pairs (sprites) do
    if sprite["type"] == "player" then
      love.graphics.draw (playerImage, sprite["x"] - cameraX, sprite["y"] - cameraY)
    elseif sprite["type"] == "enemy" then
      love.graphics.draw (enemyImage, sprite["x"] - cameraX, sprite["y"] - cameraY)
    end
  end
end

-- vim:set ts=8 sts=2 sw=2 noet:
