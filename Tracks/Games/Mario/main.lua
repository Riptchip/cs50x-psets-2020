WIDTH = 1280
HEIGHT = 720

VIRT_WIDTH = 432
VIRT_HEIGHT = 243

Class = require 'class'
push = require 'push'

require 'Util'

require 'Map'

function love.load()
    math.randomseed(os.time())

    map = Map()

    love.graphics.setDefaultFilter('nearest', 'nearest')

    push:setupScreen(VIRT_WIDTH, VIRT_HEIGHT, WIDTH, HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = false
    })
end

function love.update(dt)
    map:update(dt)
end

function love.draw()
    push:apply('start')

    love.graphics.translate(math.floor(-map.camX), math.floor(-map.camY))

    love.graphics.clear(108 / 255, 140 / 255, 1, 1)

    map:render()
    push:apply('end')
end