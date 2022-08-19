Map = Class{}

TILE_BRICK = 1
TILE_BUSH_LEFT = 2
TILE_BUSH_RIGHT = 3
TILE_EMPTY = 4
TILE_EXCL_ON = 5
TILE_CLOUD_LEFT = 6
TILE_CLOUD_RIGHT = 7
TILE_GOAL_TOP = 8
TILE_EXCL_OFF = 9
TILE_COLLUMN_TOP = 10
TILE_COLLUMN_MID = 11
TILE_GOAL_MID = 12
TILE_FLAG_1 = 13
TILE_FLAG_2 = 14
TILE_FLAG_3 = 15
TILE_GOAL_BOTTOM = 16

local SCROLL_SPEED = 62

function Map:init()
    self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 30
    self.mapHeight = 20
    self.tiles = {}

    self.camX = 0
    self.camY = 0

    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    self.tileSprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)

    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    local x = 1
    while x < self.mapWidth do
        if math.random(math.random(15, 25)) == 1 and x < self.mapWidth - 3 then
            local y = math.random(math.floor(self.mapHeight / 2) - 6)
            self:setTile(x, y, TILE_CLOUD_LEFT)
            self:setTile(x + 1, y, TILE_CLOUD_RIGHT) 
        
        elseif math.random(math.random(15, 25)) == 1 and x < self.mapWidth - 3 then
            self:setTile(x, math.floor(self.mapHeight / 2) - 1, TILE_BUSH_LEFT)
            self:setTile(x + 1, math.floor(self.mapHeight / 2) - 1, TILE_BUSH_RIGHT)

            self:setBricks(x, 2)
            
            x = x + 2
        
        elseif math.random(math.random(15, 25)) == 1 and x < self.mapWidth - 3 then
            local collumnHeight = math.random(2, 5)
            self:setTile(x, math.floor(self.mapHeight / 2) - collumnHeight, TILE_COLLUMN_TOP)
            for i = 1, collumnHeight - 1 do
                self:setTile(x, math.floor(self.mapHeight / 2) - i, TILE_COLLUMN_MID)
            end

            self:setBricks(x, 2)
            
            x = x + 1
        
        elseif math.random(math.random(10, 20)) == 1 and x < self.mapWidth - 3 then
            self:setTile(x, math.floor(self.mapHeight / 2) - 3, TILE_EXCL_ON)
        end
        
        if math.random(30) ~= 1 then
            self:setBricks(x, 1)
        else
            x = x + 2
        end
        x = x + 1
    end
end

function Map:setBricks(x, lines)
    for i = 0, lines - 1 do
        for y = self.mapHeight / 2, self.mapHeight do    
            self:setTile(x + i, y, TILE_BRICK)
        end
    end
end

function Map:setTile(x, y, tile)
    self.tiles[(y - 1) * self.tileWidth + x] = tile
end

function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.tileWidth + x]
end

function Map:update(dt)
    if love.keyboard.isDown('d') then
        self.camX = math.min(self.mapWidthPixels - VIRT_WIDTH, self.camX + SCROLL_SPEED * dt)
    elseif love.keyboard.isDown('a') then
        self.camX = math.max(0, self.camX + -SCROLL_SPEED * dt)
    end
end

function Map:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            love.graphics.draw(self.spritesheet, self.tileSprites[self:getTile(x, y)], (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
        end
    end
end