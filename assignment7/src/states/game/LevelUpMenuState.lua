LevelUpMenuState = Class{__includes = BaseState}

function LevelUpMenuState:init(battleState, pokemon, onClose)
    self.battleState = battleState
    self.closed = false
    self.pokemon = pokemon
    self.onClose = onClose

    gSounds['levelup']:play()
    self.previousHP = self.pokemon.HP
    self.previousAttack = self.pokemon.attack
    self.previousDefense = self.pokemon.defense
    self.previousSpeed = self.pokemon.speed
    self.pokemon:levelUp()

    self.levelUpMenu = Menu {
        x = VIRTUAL_WIDTH - 200,
        y = 0,
        width = 200,
        height = VIRTUAL_HEIGHT,
        items = {
            {
                text = 'HP:      ' .. self.previousHP .. ' + ' ..
                    self.pokemon.HP - self.previousHP .. 
                    ' = ' .. self.pokemon.HP
            },
            {
                text = 'Attack:  ' .. self.previousAttack .. ' + ' ..
                    self.pokemon.attack - self.previousAttack .. 
                    ' = ' .. self.pokemon.attack
            },
            {
                text = 'Defense: ' .. self.previousDefense .. ' + '..
                    self.pokemon.defense - self.previousDefense ..
                    ' = ' .. self.pokemon.defense
            },
            {
                text = 'Speed:   ' .. self.previousSpeed .. ' + ' ..
                    self.pokemon.speed - self.previousSpeed .. 
                    ' = ' .. self.pokemon.speed
            }
        },
        cursorEnabled = false
    }
end

function LevelUpMenuState:update(dt)
    self.levelUpMenu:update(dt)
    if love.keyboard.isDown(CTRL_OK) then
        gStateStack:pop()
        self.onClose()
    end
    
end

function LevelUpMenuState:render()
    self.levelUpMenu:render()
end