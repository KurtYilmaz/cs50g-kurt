--[[
    GD50
    Angry Birds

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Level = Class{}

function Level:init()
    -- create a new "world" (where physics take place), with no x gravity
    -- and 30 units of Y gravity (for downward force)
    self.world = love.physics.newWorld(0, 300)

    -- bodies we will destroy after the world update cycle; destroying these in the
    -- actual collision callbacks can cause stack overflow and other errors
    self.destroyedBodies = {}

    -- AS6 - Can't split after collision, so keeping track of it
    self.playerCollided = false

    -- define collision callbacks for our world; the World object expects four,
    -- one for different stages of any given collision
    function beginContact(a, b, coll)
        local types = {}
        types[a:getUserData()] = true
        types[b:getUserData()] = true

        -- if we collided between both an alien and an obstacle...
        if types['Obstacle'] and types['Player'] then
            -- destroy the obstacle if player's combined velocity is high enough
            if a:getUserData() == 'Obstacle' then
                local velX, velY = b:getBody():getLinearVelocity()
                local sumVel = math.abs(velX) + math.abs(velY)

                if sumVel > 20 then
                    table.insert(self.destroyedBodies, a:getBody())
                end
            else
                local velX, velY = a:getBody():getLinearVelocity()
                local sumVel = math.abs(velX) + math.abs(velY)

                if sumVel > 20 then
                    table.insert(self.destroyedBodies, b:getBody())
                end
            end

            self.playerCollided = true
        end

        -- if we collided between an obstacle and an alien, as by debris falling...
        if types['Obstacle'] and types['Alien'] then
            -- destroy the alien if falling debris is falling fast enough
            if a:getUserData() == 'Obstacle' then
                local velX, velY = a:getBody():getLinearVelocity()
                local sumVel = math.abs(velX) + math.abs(velY)

                if sumVel > 20 then
                    table.insert(self.destroyedBodies, b:getBody())
                end
            else
                local velX, velY = b:getBody():getLinearVelocity()
                local sumVel = math.abs(velX) + math.abs(velY)

                if sumVel > 20 then
                    table.insert(self.destroyedBodies, a:getBody())
                end
            end
        end

        -- if we collided between the player and the alien...
        if types['Player'] and types['Alien'] then
            -- destroy the alien if player is traveling fast enough
            if a:getUserData() == 'Player' then
                local velX, velY = a:getBody():getLinearVelocity()
                local sumVel = math.abs(velX) + math.abs(velY)
                
                if sumVel > 20 then
                    table.insert(self.destroyedBodies, b:getBody())
                end
            else
                local velX, velY = b:getBody():getLinearVelocity()
                local sumVel = math.abs(velX) + math.abs(velY)

                if sumVel > 20 then
                    table.insert(self.destroyedBodies, a:getBody())
                end
            end

            self.playerCollided = true
        end

        -- if we hit the ground, play a bounce sound
        -- AS6 - checking for collision to disable splitting
        if types['Player'] and types['Ground'] then
            self.playerCollided = true
            gSounds['bounce']:stop()
            gSounds['bounce']:play()
        end
    end

    -- the remaining three functions here are sample definitions, but we are not
    -- implementing any functionality with them in this demo; use-case specific
    function endContact(a, b, coll)
        
    end

    function preSolve(a, b, coll)

    end

    function postSolve(a, b, coll, normalImpulse, tangentImpulse)

    end

    -- register just-defined functions as collision callbacks for world
    self.world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    -- shows alien before being launched and its trajectory arrow
    self.launchMarker = AlienLaunchMarker(self.world)

    -- aliens in our scene
    self.aliens = {}

    -- AS6 - table for extra player aliens to search through
    self.players = {}

    -- obstacles guarding aliens that we can destroy
    self.obstacles = {}

    -- simple edge shape to represent collision for ground
    self.edgeShape = love.physics.newEdgeShape(0, 0, VIRTUAL_WIDTH * 3, 0)

    -- spawn an alien to try and destroy
    table.insert(self.aliens, Alien(self.world, 'square', VIRTUAL_WIDTH - 80, VIRTUAL_HEIGHT - TILE_SIZE - ALIEN_SIZE / 2, 'Alien'))

    -- spawn a few obstacles
    table.insert(self.obstacles, Obstacle(self.world, 'vertical',
        VIRTUAL_WIDTH - 120, VIRTUAL_HEIGHT - 35 - 110 / 2))
    table.insert(self.obstacles, Obstacle(self.world, 'vertical',
        VIRTUAL_WIDTH - 35, VIRTUAL_HEIGHT - 35 - 110 / 2))
    table.insert(self.obstacles, Obstacle(self.world, 'horizontal',
        VIRTUAL_WIDTH - 80, VIRTUAL_HEIGHT - 35 - 110 - 35 / 2))

    -- ground data
    self.groundBody = love.physics.newBody(self.world, -VIRTUAL_WIDTH, VIRTUAL_HEIGHT - 35, 'static')
    self.groundFixture = love.physics.newFixture(self.groundBody, self.edgeShape)
    self.groundFixture:setFriction(0.5)
    self.groundFixture:setUserData('Ground')

    -- background graphics
    self.background = Background()

    -- AS6 - flag for checking if fired and split
    self.hasSplit = false
end

function Level:update(dt)
    -- update launch marker, which shows trajectory
    self.launchMarker:update(dt)

    -- Box2D world update code; resolves collisions and processes callbacks
    self.world:update(dt)

    -- destroy all bodies we calculated to destroy during the update call
    for k, body in pairs(self.destroyedBodies) do
        if not body:isDestroyed() then 
            body:destroy()
        end
    end

    -- reset destroyed bodies to empty table for next update phase
    self.destroyedBodies = {}

    -- remove all destroyed obstacles from level
    for i = #self.obstacles, 1, -1 do
        if self.obstacles[i].body:isDestroyed() then
            table.remove(self.obstacles, i)

            -- play random wood sound effect
            local soundNum = math.random(5)
            gSounds['break' .. tostring(soundNum)]:stop()
            gSounds['break' .. tostring(soundNum)]:play()
        end
    end

    -- remove all destroyed aliens from level
    for i = #self.aliens, 1, -1 do
        if self.aliens[i].body:isDestroyed() then
            table.remove(self.aliens, i)
            gSounds['kill']:stop()
            gSounds['kill']:play()
        end
    end

    for k, player in pairs(self.players) do
        local xPos, yPos = player.body:getPosition()
        local xVel, yVel = player.body:getLinearVelocity()
        
        -- if we fired our alien to the left or it's almost done rolling, respawn
        -- AS6 - also checking for each player to have stopped rolling
        if xPos < 0 or (math.abs(xVel) + math.abs(yVel) < 5) then
            player.body:destroy()
            table.remove(self.players, k)
        end
    end

    -- replace launch marker if original alien stopped moving
    if self.launchMarker.launched then
        local xPos, yPos = self.launchMarker.alien.body:getPosition()
        local xVel, yVel = self.launchMarker.alien.body:getLinearVelocity()
        
        -- if we fired our alien to the left or it's almost done rolling, respawn
        -- AS6 - also checking for each player to have stopped rolling
        if xPos < 0 or (math.abs(xVel) + math.abs(yVel) < 5) and #self.players == 0 then
            self.launchMarker.alien.body:destroy()
            self.launchMarker = AlienLaunchMarker(self.world)

            -- AS6 - reset ability to split
            self.hasSplit = false
            self.playerCollided = false

            -- re-initialize level if we have no more aliens
            if #self.aliens == 0 then
                gStateMachine:change('start')
            end
        end
    end

    -- AS6 - alien split logic
    if love.keyboard.isDown(PLAYER_SPLIT) and not self.hasSplit 
            and self.launchMarker.launched and not self.playerCollided then

        local gravX, gravY = self.world:getGravity()
        local playerVelocityX, playerVelocityY = self.launchMarker.alien.body:getLinearVelocity()
        local playerX = self.launchMarker.alien.body:getX()
        local playerY = self.launchMarker.alien.body:getY()
        -- spawn new alien in the world, passing in user data of player
        local topAlien = Alien(self.world, 'round', playerX, playerY - 40, 'Player', 15)
        local botAlien = Alien(self.world, 'round', playerX, playerY + 40, 'Player', 10)

        -- apply the difference between current X,Y and base X,Y as launch vector impulse
        topAlien.body:setLinearVelocity(playerVelocityX, playerVelocityY - 20) 
        botAlien.body:setLinearVelocity(playerVelocityX, playerVelocityY + 30)

        -- make the alien pretty bouncy
        topAlien.fixture:setRestitution(0.4)
        botAlien.fixture:setRestitution(0.4)
        topAlien.body:setAngularDamping(1)
        botAlien.body:setAngularDamping(1)

        table.insert(self.players, topAlien)
        table.insert(self.players, botAlien)
        
        self.hasSplit = true
    end

    -- AS6 - allows skipping of victory scene (really only useful is player is still rolling)
    if #self.aliens == 0 and #love.mouse.keysPressed > 0 then
        gStateMachine:change('start')
    end
end

function Level:render()
    -- render ground tiles across full scrollable width of the screen
    for x = -VIRTUAL_WIDTH, VIRTUAL_WIDTH * 2, 35 do
        love.graphics.draw(gTextures['tiles'], gFrames['tiles'][12], x, VIRTUAL_HEIGHT - 35)
    end

    self.launchMarker:render()

    for k, alien in pairs(self.aliens) do
        alien:render()
    end

    for k, obstacle in pairs(self.obstacles) do
        obstacle:render()
    end

    for k, player in pairs(self.players) do
        player:render()
    end

    -- render instruction text if we haven't launched bird
    if not self.launchMarker.launched then
        love.graphics.setFont(gFonts['medium'])
        love.graphics.setColor(0, 0, 0, 255)
        love.graphics.printf('Click and drag circular alien to shoot!',
            0, 64, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(255, 255, 255, 255)
    end

    -- render victory text if all aliens are dead
    if #self.aliens == 0 then
        love.graphics.setFont(gFonts['huge'])
        love.graphics.setColor(0, 0, 0, 255)
        love.graphics.printf('VICTORY', 0, VIRTUAL_HEIGHT / 2 - 32, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(255, 255, 255, 255)
    end

    -- if self.launchMarker.alien ~= nil then
    --     love.graphics.printf(tostring(self.hasSplit),0,0,VIRTUAL_WIDTH,'right')
    -- end
end