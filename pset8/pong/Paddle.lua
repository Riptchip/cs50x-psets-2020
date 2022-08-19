--[[
    This is CS50 2019.
    Games Track
    Pong

    -- Paddle Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents a paddle that can move up and down. Used in the main
    program to deflect the ball back toward the opponent.
]]

Paddle = Class{}

--[[
    The `init` function on our class is called just once, when the object
    is first created. Used to set up all variables in the class and get it
    ready for use.

    Our Paddle should take an X and a Y, for positioning, as well as a width
    and height for its dimensions.

    Note that `self` is a reference to *this* object, whichever object is
    instantiated at the time this function is called. Different objects can
    have their own x, y, width, and height values, thus serving as containers
    for data. In this sense, they're very similar to structs in C.
]]
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
    -- math.max here ensures that we're the greater of 0 or the player's
    -- current calculated Y position when pressing up so that we don't
    -- go into the negatives; the movement calculation is simply our
    -- previously-defined paddle speed scaled by dt
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    -- similar to before, this time we use math.min to ensure we don't
    -- go any farther than the bottom of the screen minus the paddle's
    -- height (or else it will go partially below, since position is
    -- based on its top left corner)
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
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
        if not (self.y <= (VIRTUAL_HEIGHT / 2 - 10) + 4 and self.y >= (VIRTUAL_HEIGHT / 2 - 10) - 4) then
            if ((VIRTUAL_HEIGHT / 2) - 10) - self.y >= 0 then
                self.dy = PADDLE_SPEED
            else
                self.dy = -PADDLE_SPEED
            end
        else
            self.dy = 0
        end
    end
end

--[[
    To be called by our main function in `love.draw`, ideally. Uses
    LÖVE2D's `rectangle` function, which takes in a draw mode as the first
    argument as well as the position and dimensions for the rectangle. To
    change the color, one must call `love.graphics.setColor`. As of the
    newest version of LÖVE2D, you can even draw rounded rectangles!
]]
function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end