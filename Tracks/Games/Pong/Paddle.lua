Paddle = Class{}

function Paddle:init(x, y, width, height, isAI, player)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.dy = 0

    self.isAI = isAI
    self.reflectPosition = 0
    self.ballDX = 0
    self.ballX = 0
    self.distanceBall = 0
    self.player = player
end

function Paddle:update(dt)
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    else
        self.y = math.min(VIRT_HEIGHT - 20, self.y + self.dy * dt)
    end
end

function Paddle:calculate()
    if self.isAI == 1 then
        self.reflectPosition = (((self.x - ball.x) / ball.dx) * ball.dy) + ball.y - 10 
    end
end

function Paddle:AI()
    if self.isAI ~= 1 then
        return
    end

    self.ballDX = self.player == 1 and -ball.dx or ball.dx
    self.ballX = self.player == 1 and -ball.x or ball.x
    
    self.distanceBall = self.x - self.ballX

    if self.ballDX > 0 and self.distanceBall < 268 then
        if not (self.y >= self.reflectPosition - 4 and self.y <= self.reflectPosition + 4) then
            if self.reflectPosition - self.y > 0 then
                self.dy = PADDLE_SPEED
            else
                    self.dy = -PADDLE_SPEED
            end
        else
            self.dy = 0
        end
    else
        if not (self.y <= (VIRT_HEIGHT / 2 - 10) + 4 and self.y >= (VIRT_HEIGHT / 2 - 10) - 4) then
            if ((VIRT_HEIGHT / 2) - 10) - self.y >= 0 then
                self.dy = PADDLE_SPEED
            else
                self.dy = -PADDLE_SPEED
            end
        else
            self.dy = 0
        end
    end
end

function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end