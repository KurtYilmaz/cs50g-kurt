--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerIdleState = Class{__includes = EntityIdleState}

function PlayerIdleState:init(entity)
    EntityIdleState.init(self, entity)
    self.directionFrames = 0
end

function PlayerIdleState:update(dt)
    if love.keyboard.isDown(CTRL_LEFT) then
        if self.entity.direction == 'left' then
            self.directionFrames = self.directionFrames + 1
        else
            self.directionFrames = 1
            self.entity.direction = 'left'
            self.entity:changeAnimation('idle-' .. self.entity.direction)
        end      
        
    elseif love.keyboard.isDown(CTRL_RIGHT) then
        if self.entity.direction == 'right' then
            self.directionFrames = self.directionFrames + 1
        else
            self.directionFrames = 1
            self.entity.direction = 'right'
            self.entity:changeAnimation('idle-' .. self.entity.direction)            
        end      
    elseif love.keyboard.isDown(CTRL_UP) then
        if self.entity.direction == 'up' then
            self.directionFrames = self.directionFrames + 1
        else
            self.directionFrames = 1
            self.entity.direction = 'up'
            self.entity:changeAnimation('idle-' .. self.entity.direction)            
        end      
    elseif love.keyboard.isDown(CTRL_DOWN) then
        if self.entity.direction == 'down' then
            self.directionFrames = self.directionFrames + 1
        else
            self.directionFrames = 1
            self.entity.direction = 'down'
            self.entity:changeAnimation('idle-' .. self.entity.direction)            
        end 
    end

    if self.directionFrames >= 4 then 
        self.entity:changeState('walk')
        self.directionFrames = 0
    end
end