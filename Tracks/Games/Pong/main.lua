WIDTH = 1280
HEIGHT = 720

VIRT_WIDTH = 432
VIRT_HEIGHT = 243

playerServing = 0

winCondition = 10

gameState = ''

Class = require 'class'
push = require 'push'

require 'Paddle'
require 'Ball'

function love.load()
    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Pong')

    fonts = {}

    newFont('04B_03__.TTF', 8, 'pixel')
    newFont('04B_03__.TTF', 16, 'pixel')
    newFont('04B_03__.TTF', 32, 'pixel')

    push:setupScreen(VIRT_WIDTH, VIRT_HEIGHT, WIDTH, HEIGHT, {
        fullscreen = false,
        vsync = true,
        reziseble = true,
    })

    player1 = Paddle(5, 20, 5, 20, 1, 1)
    player2 = Paddle(VIRT_WIDTH - 10, VIRT_HEIGHT - 40, 5, 20, 1, 2)
    player3 = Paddle(105, VIRT_HEIGHT - 40, 5, 20, 1, 3)
    player4 = Paddle(VIRT_WIDTH - 110, 20, 5, 20, 1, 4)

    ball = Ball(VIRT_WIDTH / 2 - 2, VIRT_HEIGHT / 2 - 2, 4, 4)
    
    player1Score = 0
    player2Score = 0

    PADDLE_SPEED = 200

    gameState = 'menu'
end

function love.update(dt)
    player1:update(dt)
    player2:update(dt)

    if ball.dy < 15 and ball.dy > -15 then
        ball.dy = math.random(-50, 50)
    end

    if ball.x <= 0 then
        player2Score = player2Score + 1
        playerServing = 0
        
        if player2Score >= winCondition then
            gameState = 'victory'
            winner = 2
        else
            gameState = 'serve'
        end
        
        ball:reset(playerServing)
    end

    if ball.x >= VIRT_WIDTH - ball.width then
        player1Score = player1Score + 1
        playerServing = 1
        
        if player1Score >= winCondition then
            gameState = 'victory'
            winner = 1
        else
            gameState = 'serve'
        end
        
        ball:reset(playerServing)
    end

    if ball:collision(player1) then
        ball.dx = -ball.dx * 1.03
        ball.dy = ball.dy * math.random(0.8, 1.2)
        player2:calculate()
    end
    if ball:collision(player2) then
        ball.dx = -ball.dx * 1.03
        ball.dy = ball.dy * math.random(0.8, 1.2)
        player1:calculate()
    end

    if ball.y <= 0 then
        ball.y = 0
        ball.dy = -ball.dy * math.random(0.95, 1.05)
        player1:calculate()
        player2:calculate()
    end
    if ball.y >= VIRT_HEIGHT - ball.height then
        ball.y = VIRT_HEIGHT - ball.height
        ball.dy = -ball.dy * math.random(0.8, 1.2)
        player1:calculate()
        player2:calculate()
    end

    if player1.isAI == 0 then
        if love.keyboard.isDown('w') then
            player1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            player1.dy = PADDLE_SPEED
        else
            player1.dy = 0
        end
    end

    if player2.isAI == 0 then
        if love.keyboard.isDown('up') then
            player2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            player2.dy = PADDLE_SPEED
        else
            player2.dy = 0
        end
    end

    if gameState == 'play' then
        ball:update(dt)

        player1:AI()
        player2:AI()
        player3:AI()
        player4:AI()
    end
end

function love.rezise(w, h)
    push:rezise(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'menu' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
            player1:calculate()
            player2:calculate()
        elseif gameState == 'victory' then
            gameState = 'menu'
            player1Score = 0
            player2Score = 0
        end
    end
end

function love.draw()
    push:apply('start')

        love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 1)
        
        if gameState == 'play' then
            renderGame(fonts['pixel16'], false, 80 / 255, 85 / 255, 92 / 255, 1)
        elseif gameState == 'menu' then
            love.graphics.setFont(fonts['pixel32'], true)
            love.graphics.printf("Pong", 0, 20, VIRT_WIDTH, 'center')        
            
            love.graphics.printf("Press Enter to Play", 0, VIRT_HEIGHT / 2 - 16, VIRT_WIDTH, 'center')
        elseif gameState == 'serve' then
            renderGame(fonts['pixel16'], true, 80 / 255, 85 / 255, 92 / 255, 1)
            love.graphics.printf('Player ' .. tostring(playerServing + 1) .. "'s serve", 0, 40, VIRT_WIDTH, 'center')
            love.graphics.printf('Press enter to serve', 0, 60, VIRT_WIDTH, 'center')
        elseif gameState == 'victory' then
            renderGame(fonts['pixel16'], false, 80 / 255, 85 / 255, 92 / 255, 1)
            love.graphics.printf('Player ' .. winner .. " wins", 0, 40, VIRT_WIDTH, 'center')
            love.graphics.printf('Press enter to restart', 0, 60, VIRT_WIDTH, 'center')
        end

    push:apply('end')
end

function displayFPS(r, g, b, a)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(fonts['pixel8'])
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 20, 10)
    love.graphics.setColor(r, g, b, a)
    love.graphics.setFont(fonts['pixel32'])
end

function renderGame(font, pong, r, g, b, a)
    love.graphics.setFont(font)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle('fill', VIRT_WIDTH / 2 - 1, 0, 2, VIRT_HEIGHT)

    if pong then
        love.graphics.setColor(80 / 255, 85 / 255, 92 / 255, 1)
        love.graphics.printf("Pong", 0, 20, VIRT_WIDTH, 'center')
    end

    love.graphics.setColor(80 / 255, 85 / 255, 92 / 255, 1)
    love.graphics.setFont(fonts['pixel32'])
    love.graphics.print(player1Score, VIRT_WIDTH / 2 - 50, VIRT_HEIGHT / 3)
    love.graphics.print(player2Score, VIRT_WIDTH / 2 + 30, VIRT_HEIGHT / 3)

    love.graphics.setColor(1, 1, 1, 1)    
    ball:render()

    player1:render()
    player2:render()
    player3:render()
    player4:render()

    displayFPS(1, 1, 1, 1)

    love.graphics.setFont(font)
    love.graphics.setColor(r, g, b, a)
end

function newFont(font, size, name)
    fonts[name .. tostring(size)] = love.graphics.newFont(font, size)
end