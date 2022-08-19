--[[
    Represents our player in the game, with its own sprite.
]]

Player = Class{}

local WALKING_SPEED = 140
local JUMP_VELOCITY = 400
local finishLevel = false
local opacity = 0
local rotation = 0
gameOver = false

function Player:init(map)

    self.x = 0
    self.y = 0
    self.width = 16
    self.height = 20

    -- offset from top left to center to support sprite flipping
    self.xOffset = 8
    self.yOffset = 10

    -- reference to map for checking tiles
    self.map = map
    self.texture = love.graphics.newImage('graphics/blue_alien.png')

    -- sound effects
    self.sounds = {
        ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
        ['hit'] = love.audio.newSource('sounds/hit.wav', 'static'),
        ['coin'] = love.audio.newSource('sounds/coin.wav', 'static'),
        ['death'] = love.audio.newSource('sounds/death.wav', 'static')
    }

    -- animation frames
    self.frames = {}

    -- current animation frame
    self.currentFrame = nil

    -- used to determine behavior and animations
    self.state = 'idle'

    -- determines sprite flipping
    self.direction = 'left'

    -- x and y velocity
    self.dx = 0
    self.dy = 0

    -- position on top of map tiles
    self.y = map.tileHeight * ((map.mapHeight - 2) / 2) - self.height
    self.x = map.tileWidth

    -- player lifes
    self.lifes = 3

    -- initialize all player animations
    self.animations = {
        ['idle'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0, 0, 16, 20, self.texture:getDimensions())
            }
        }),
        ['walking'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(128, 0, 16, 20, self.texture:getDimensions()),
                love.graphics.newQuad(144, 0, 16, 20, self.texture:getDimensions()),
                love.graphics.newQuad(160, 0, 16, 20, self.texture:getDimensions()),
                love.graphics.newQuad(144, 0, 16, 20, self.texture:getDimensions()),
            },
            interval = 0.15
        }),
        ['jumping'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(32, 0, 16, 20, self.texture:getDimensions())
            }
        }),
        ['climbing'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(96, 0, 16, 20, self.texture:getDimensions()),
                love.graphics.newQuad(112, 0, 16, 20, self.texture:getDimensions()),
            },
            interval = 0.5
        }),
        ['fall'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(64, 0, 16, 20, self.texture:getDimensions())
            }
        })
    }

    -- initialize animation and current frame we should render
    self.animation = self.animations['idle']
    self.currentFrame = self.animation:getCurrentFrame()

    -- behavior map we can call based on player state
    self.behaviors = {
        ['idle'] = function(dt)

            -- add spacebar functionality to trigger jump state
            if love.keyboard.wasPressed('space') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jumping']
                self.sounds['jump']:play()
            elseif love.keyboard.isDown('left') then
                self.direction = 'left'
                self.dx = -WALKING_SPEED
                self.state = 'walking'
                self.animations['walking']:restart()
                self.animation = self.animations['walking']
            elseif love.keyboard.isDown('right') then
                self.direction = 'right'
                self.dx = WALKING_SPEED
                self.state = 'walking'
                self.animations['walking']:restart()
                self.animation = self.animations['walking']
            else
                self.dx = 0
            end
        end,
        ['walking'] = function(dt)

            -- keep track of input to switch movement while walking, or reset
            -- to idle if we're not moving
            if love.keyboard.wasPressed('space') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jumping']
                self.sounds['jump']:play()
            elseif love.keyboard.isDown('left') then
                self.direction = 'left'
                self.dx = -WALKING_SPEED
            elseif love.keyboard.isDown('right') then
                self.direction = 'right'
                self.dx = WALKING_SPEED
            else
                self.dx = 0
                self.state = 'idle'
                self.animation = self.animations['idle']
            end

            -- check for collisions moving left and right
            self:checkRightCollision()
            self:checkLeftCollision()

            -- check if there's a tile directly beneath us
            if not self.map:collides(self.map:tileAt(self.x, self.y + self.height)) and
                not self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then

                -- if so, reset velocity and position and change state
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            end
        end,
        ['jumping'] = function(dt)
            -- break if we go below the surface
            if self.y > 300 then
                return
            end

            if love.keyboard.isDown('left') then
                self.direction = 'left'
                self.dx = -WALKING_SPEED
            elseif love.keyboard.isDown('right') then
                self.direction = 'right'
                self.dx = WALKING_SPEED
            end

            -- apply map's gravity before y velocity
            self.dy = self.dy + self.map.gravity

            -- check if there's a tile directly beneath us
            if self.map:collides(self.map:tileAt(self.x, self.y + self.height)) or
                self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then

                isGoal = self.map:tileAt(self.x, self.y + self.height).id
                isGoal2 = self.map:tileAt(self.x + self.width - 1, self.y + self.height).id

                if isGoal == 8 or isGoal == 12 or isGoal == 16 then
                    -- if so, reset velocity and position and change state
                    self.x = GOAL_TOP_X
                    self.state = 'climbing'
                    self.animation = self.animations['climbing']
                elseif isGoal2 == 8 or isGoal2 == 12 or isGoal2 == 16 then
                    self.x = GOAL_TOP_X
                    self.state = 'climbing'
                    self.animation = self.animations['climbing']
                else
                    self.dy = 0
                    self.state = 'idle'
                    self.animation = self.animations['idle']
                    self.y = (self.map:tileAt(self.x - self.width, self.y + self.height).y - 1) * self.map.tileHeight - self.height
                end
            end

            -- check for collisions moving left and right
            self:checkRightCollision()
            self:checkLeftCollision()
        end,
        ['climbing'] = function(dt)
            self.dx = 0
            self.dy = JUMP_VELOCITY / 2.5

            if self.y >= map.tileHeight * ((map.mapHeight - 2) / 2) - self.height then
                self.y = map.tileHeight * ((map.mapHeight - 2) / 2) - self.height
                self.dx = WALKING_SPEED
                self.dy = 0
                self.direction = 'right'
                self.animation = self.animations['walking']
                finishLevel = true
            end
        end,
        ['fall'] = function(dt)

            if self.y <= VIRTUAL_HEIGHT + self.height and self.y >= VIRTUAL_HEIGHT - (2.5 * map.tileHeight) and not falling then
                self.dy = -JUMP_VELOCITY / 5
                self.y = self.y + self.dy * dt
            else
                falling = true
                self.dy = JUMP_VELOCITY / 5
                self.y = self.y + self.dy * dt
            end

            if rotation <= 6.25 then
                rotation = rotation + 0.25
            else
                rotation = 0
            end

            if self.y >= VIRTUAL_HEIGHT + (2 * map.tileHeight) then
                self.lifes = self.lifes - 1
                if self.lifes == 0 then
                    gameOver = true
                elseif not gameOver then
                    self.dy = 0
                    self.x = self.width
                    self.y = map.tileHeight * ((map.mapHeight - 2) / 2) - self.height
                    self.state = 'idle'
                    self.animation = self.animations['idle']
                    rotation = 0
                    falling = false
                end
            end

        end
    }
end

function Player:update(dt)
    self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
    self.x = self.x + self.dx * dt

    self:calculateJumps()

    if (finishLevel or gameOver) and opacity <= 1 then
        opacity = opacity + 0.1
    end

    if self.y >= VIRTUAL_HEIGHT and not falling then
        self.dy = 0
        self.dx = 0
        self.y = VIRTUAL_HEIGHT
        rotation = 0
        self.state = 'fall'
        self.animation = self.animations['fall']
        self.sounds['death']:play()
    end

    -- apply velocity
    self.y = self.y + self.dy * dt
end

-- jumping and block hitting logic
function Player:calculateJumps()

    -- if we have negative y velocity (jumping), check if we collide
    -- with any blocks above us
    if self.dy < 0 then
        block = self.map:tileAt(self.x, self.y).id
        block2 = self.map:tileAt(self.x + self.width - 1, self.y).id
        if (block ~= TILE_EMPTY or block2 ~= TILE_EMPTY) and
            ((block ~= CLOUD_LEFT and block ~= CLOUD_RIGHT) and
            (block2 ~= CLOUD_LEFT and block2 ~= CLOUD_RIGHT)) and
            (block ~= GOAL_TOP and block ~= GOAL_MID and block ~= GOAL_BOTTOM) and
            (block2 ~= GOAL_TOP and block2 ~= GOAL_MID and block2 ~= GOAL_BOTTOM) then
            -- reset y velocity
            self.dy = 0

            -- change block to different block
            local playCoin = false
            local playHit = false
            if self.map:tileAt(self.x, self.y).id == JUMP_BLOCK then
                self.map:setTile(math.floor(self.x / self.map.tileWidth) + 1,
                    math.floor(self.y / self.map.tileHeight) + 1, JUMP_BLOCK_HIT)
                playCoin = true
            else
                playHit = true
            end
            if self.map:tileAt(self.x + self.width - 1, self.y).id == JUMP_BLOCK then
                self.map:setTile(math.floor((self.x + self.width - 1) / self.map.tileWidth) + 1,
                    math.floor(self.y / self.map.tileHeight) + 1, JUMP_BLOCK_HIT)
                playCoin = true
            else
                playHit = true
            end

            if playCoin then
                self.sounds['coin']:play()
            elseif playHit then
                self.sounds['hit']:play()
            end
        end
    end
end

-- checks two tiles to our left to see if a collision occurred
function Player:checkLeftCollision()
    if self.dx < 0 then
        -- check if there's a tile directly beneath us
        if self.map:collides(self.map:tileAt(self.x - 1, self.y)) or
            self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 1)) then

            isGoal = self.map:tileAt(self.x - 1, self.y)
            isGoal2 = self.map:tileAt(self.x - 1, self.y + self.height - 1)

            if (isGoal.id == 8 or isGoal.id == 12 or isGoal.id == 16) or (isGoal2.id == 8 or isGoal2.id == 12 or isGoal2.id == 16) then
                self.state = 'climbing'
                self.animation = self.animations['climbing']
                self.x = GOAL_TOP_X
            end

            -- if so, reset velocity and position and change state
            self.dx = 0
            self.x = self.map:tileAt(self.x - 1, self.y).x * self.map.tileWidth
        end
    end
end

-- checks two tiles to our right to see if a collision occurred
function Player:checkRightCollision()
    if self.dx > 0 then
        -- check if there's a tile directly beneath us
        if self.map:collides(self.map:tileAt(self.x + self.width, self.y)) or
            self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then

            isGoal = self.map:tileAt(self.x + self.width, self.y)
            isGoal2 = self.map:tileAt(self.x + self.width, self.y + self.height - 1)

            if (isGoal.id == 8 or isGoal.id == 12 or isGoal.id == 16) or (isGoal2.id == 8 or isGoal2.id == 12 or isGoal2.id == 16) then
                self.x = GOAL_TOP_X
                self.state = 'climbing'
                self.animation = self.animations['climbing']
            end

            -- if so, reset velocity and position and change state
            self.dx = 0
            self.x = (self.map:tileAt(self.x + self.width, self.y).x - 1) * self.map.tileWidth - self.width
        end
    end
end

function Player:render()
    local scaleX

    -- set negative x scale factor if facing left, which will flip the sprite
    -- when applied
    if self.direction == 'right' then
        scaleX = 1
    else
        scaleX = -1
    end

    love.graphics.setColor(.3, .3, .4, 1)
    love.graphics.setFont(fonts['pixel8'])
    love.graphics.print('LIFES: ' .. self.lifes, map.camX + 10, map.camY + 7)
    love.graphics.setColor(1, 1, 1, 1)

    if finishLevel then
        love.graphics.setFont(fonts['pixel32'])
        love.graphics.setColor(0.05, 0.05, 0.1, opacity)
        love.graphics.rectangle('fill', 0, -3, map.mapWidthPixels, map.mapHeightPixels)
        love.graphics.setColor(1, 1, 1, opacity)
        love.graphics.printf('You Won!', map.camX, VIRTUAL_HEIGHT / 2 - 20, VIRTUAL_WIDTH, 'center')
    elseif gameOver then
        love.graphics.setFont(fonts['pixel32'])
        love.graphics.setColor(0.05, 0.05, 0.1, opacity)
        love.graphics.rectangle('fill', 0, -3, map.mapWidthPixels, map.mapHeightPixels)
        love.graphics.setColor(1, 1, 1, opacity)
        love.graphics.printf('Game Over', map.camX, VIRTUAL_HEIGHT / 2 - 20, VIRTUAL_WIDTH, 'center')
    end

    -- draw sprite with scale factor and offsets
    love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x + self.xOffset),
        math.floor(self.y + self.yOffset), rotation, scaleX, 1, self.xOffset, self.yOffset)
end