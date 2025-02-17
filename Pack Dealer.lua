cardOffset = 2.5

function onload()
    makingPacks = false
    self.createButton({
        label='Pack Dealer', click_function='none', function_owner=self,
        position={0,0.04,0}, rotation={0,180,0}, scale={0.5,0.5,0.5}, width=0, height=0, font_size=60, font_color="White"
    })
end

function tryObjectEnter(object)
    local type = object.type
    if type ~= "Card" and type ~= "CardCustom" and type ~= "Deck" and type ~= "DeckCustom" then
        broadcastToAll('Only decks are allowed in the pack dealing tool.', {1,1,1})
        return false
    end
    if #self.getObjects() == 0 then
        return true
    end
    
    broadcastToAll('Only 1 deck at a time is allowed in the pack dealing tool.', {1,1,1})
    return false
end

function onObjectLeaveContainer(container, obj)
    if container == self and makingPacks == false and #self.getObjects() == 0 then
        self.clearButtons()
        self.createButton({
            label='Pack Dealer', click_function='none', function_owner=self,
            position={0,0.04,0}, rotation={0,180,0}, scale={0.5,0.5,0.5}, width=0, height=0, font_size=60, font_color="White"
        })
    end
end

function onCollisionEnter(collisionInfo)
    local collidingObject = collisionInfo.collision_object
    local collidingObjectName = tostring(collidingObject)
    local deckType1 = 'Deck(Clone) (LuaGameObjectScript)'
    local deckType2 = 'DeckCustom(Clone) (LuaGameObjectScript)'
    if collidingObjectName == deckType1 or collidingObjectName == deckType2 then
        deck = collidingObject
        deckCount = deck.getQuantity()
        distanceScale = deck.getScale().x
        packs = 3
        size = 15
        spawnButtons()
    end
end

function spawnButtons()
    self.clearButtons()
    buttonParams.countDisplay.label = 'Total Cards: ' .. deckCount
    buttonParams.packsDisplay.label = 'Packs:\n' .. packs
    buttonParams.sizeDisplay.label = 'Size:\n' .. size
    for i, v in pairs(buttonParams) do
        self.createButton(v)
    end
end

function packsAdd1()
    if (packs+1)*size < deckCount then
        packs = packs + 1
        buttonParams.packsDisplay.label = 'Packs:\n' .. packs
        buttonParams.sizeDisplay.label = 'Size:\n' .. size
        updateButtons()
    end
end
function packsAdd5()
    if (packs+5)*size < deckCount then
        packs = packs + 5
        buttonParams.packsDisplay.label = 'Packs:\n' .. packs
        buttonParams.sizeDisplay.label = 'Size:\n' .. size
        updateButtons()
    end
end
function packsSub1()
    if packs > 1 then
        packs = packs - 1
        buttonParams.packsDisplay.label = 'Packs:\n' .. packs
        buttonParams.sizeDisplay.label = 'Size:\n' .. size
        updateButtons()
    end
end
function packsSub5()
    if packs > 5 then
        packs = packs - 5
        buttonParams.packsDisplay.label = 'Packs:\n' .. packs
        buttonParams.sizeDisplay.label = 'Size:\n' .. size
        updateButtons()
    end
end

function sizeAdd1()
    if packs*(size+1) < deckCount then
        size = size + 1
        buttonParams.sizeDisplay.label = 'Size:\n' .. size
        updateButtons()
    end
end
function sizeAdd5()
    if packs*(size+5) < deckCount then
        size = size + 5
        buttonParams.sizeDisplay.label = 'Size:\n' .. size
        updateButtons()
    end
end
function sizeSub1()
    if size > 1 then
        size = size - 1
        buttonParams.sizeDisplay.label = 'Size:\n' .. size
        updateButtons()
    end
end
function sizeSub5()
    if size > 5 then
        size = size - 5
        buttonParams.sizeDisplay.label = 'Size:\n' .. size
        updateButtons()
    end
end

function updateButtons()
    for i, v in pairs(buttonParams) do
        self.editButton(v)
        --only update count, packs, & size
        if i==3 then
            break
        end
    end
end

function splitDeck()
    makingPacks = true
    
    local deckPosition = self.getPosition()
    deckPosition.y = deckPosition.y+2
    local deckTakeParam = {position=deckPosition, rotation={180,0,0}, callback='makePacks', callback_owner=self}
    
    deck = self.takeObject(deckTakeParam)
end

function sin(theta)
    return math.sin(math.rad(theta))
end
function cos(theta)
    return math.cos(math.rad(theta))
end

function makePacks()
    for c=1, size do
        for p=1, packs do
            local cardDistanceScale = 0.2*self.getScale().x/distanceScale
            
            local cardRot = self.getRotation()
            cardRot.x = cardRot.x+180
            
            local cardPos = self.getPosition()
            cardPos.x = cardPos.x + (sin(90+cardRot.y) * (cardDistanceScale+(cardOffset*p*distanceScale)))
            cardPos.y = cardPos.y + 1
            cardPos.z = cardPos.z + (cos(90+cardRot.y) * (cardDistanceScale+(cardOffset*p*distanceScale)))
            
            local takeParam = {position=cardPos, rotation=cardRot}
            deck.takeObject(takeParam)
        end
    end
    
    deckCount = deck.getQuantity()
    if packs > deckCount then
        packs = deckCount
        size = 1
    elseif deckCount < (packs*size) then
        size = math.floor(deckCount/packs)
    end
    
    buttonParams.countDisplay.label = 'Total Cards: ' .. deckCount
    buttonParams.packsDisplay.label = 'Packs:\n' .. packs
    buttonParams.sizeDisplay.label = 'Size:\n' .. size
    updateButtons()
    
    Timer.destroy(self.getGUID())
    Timer.create({identifier=self.getGUID(), function_name='afterEntry', function_owner=self, delay=0.5})
end

function afterEntry()
    makingPacks = false
end

buttonParams = {
    countDisplay = {
        label='Total Cards: -', click_function='none', function_owner=self,
        position={0,0.04,0.175}, rotation={0,180,0}, scale={0.5,0.5,0.5}, width=0, height=0, font_size=60, font_color="White"
    },
    packsDisplay = {
        label='Packs:\n-', click_function='none', function_owner=self,
        position={0,0.08,0.06}, rotation={0,180,0}, scale={0.5,0.5,0.5}, width=0, height=0, font_size=50, font_color="White"
    },
    sizeDisplay = {
        label='Size:\n-', click_function='none', function_owner=self,
        position={0,0.08,-0.06}, rotation={0,180,0}, scale={0.5,0.5,0.5}, width=0, height=0, font_size=50, font_color="White"
    },
    splitIntoPacks = {
        label='Make Packs', click_function='splitDeck', function_owner=self,
        position={0,0.04,-0.175}, rotation={0,180,0}, scale={0.5,0.5,0.5}, width=360, height=80, font_size=60, color="Green", font_color="White"
    },
    packsAdd1 = {
        label='+1', click_function='packsAdd1', function_owner=self,
        position={-0.13,0.08,0.06}, rotation={0,180,0}, scale={0.5,0.5,0.5}, width=80, height=80, font_size=50
    },
    packsAdd5 = {
        label='+5', click_function='packsAdd5', function_owner=self,
        position={-0.21,0.08,0.06}, rotation={0,180,0}, scale={0.5,0.5,0.5}, width=80, height=80, font_size=50
    },
    packsSub1 = {
        label='-1', click_function='packsSub1', function_owner=self,
        position={0.13,0.08,0.06}, rotation={0,180,0}, scale={0.5,0.5,0.5}, width=80, height=80, font_size=50
    },
    packsSub5 = {
        label='-5', click_function='packsSub5', function_owner=self,
        position={0.21,0.08,0.06}, rotation={0,180,0}, scale={0.5,0.5,0.5}, width=80, height=80, font_size=50
    },
    sizeAdd1 = {
        label='+1', click_function='sizeAdd1', function_owner=self,
        position={-0.13,0.08,-0.06}, rotation={0,180,0}, scale={0.5,0.5,0.5}, width=80, height=80, font_size=50
    },
    sizeAdd5 = {
        label='+5', click_function='sizeAdd5', function_owner=self,
        position={-0.21,0.08,-0.06}, rotation={0,180,0}, scale={0.5,0.5,0.5}, width=80, height=80, font_size=50
    },
    sizeSub1 = {
        label='-1', click_function='sizeSub1', function_owner=self,
        position={0.13,0.08,-0.06}, rotation={0,180,0}, scale={0.5,0.5,0.5}, width=80, height=80, font_size=50
    },
    sizeSub5 = {
        label='-5', click_function='sizeSub5', function_owner=self,
        position={0.21,0.08,-0.06}, rotation={0,180,0}, scale={0.5,0.5,0.5}, width=80, height=80, font_size=50
    }
}