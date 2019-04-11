--[[
    GD50
    Super Mario Bros. Remake

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerIdleState = Class{__includes = BaseState}

function PlayerIdleState:init(player)
    self.player = player

    self.animation = Animation {
        frames = {1},
        interval = 1
    }

    self.player.currentAnimation = self.animation
end

function PlayerIdleState:update(dt)
    if love.keyboard.isDown(PLAYER_LEFT) or love.keyboard.isDown(PLAYER_RIGHT) then
        self.player:changeState('walking')
    end

    if love.keyboard.wasPressed(PLAYER_JUMP) then
        self.player:changeState('jump')
    end

    -- check if we've collided with any entities and die if so
    for k, entity in pairs(self.player.level.entities) do
        if entity:collides(self.player) then
            gSounds['death']:play()
            gStateMachine:change('start')
        end
    end
end