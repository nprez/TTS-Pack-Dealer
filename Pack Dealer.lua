local makingPacks = false
local cardOffset = 2.5
local packs = 3
local cardsPerPack = 15
local distanceScale = 0
local deck = nil
local deckCount = 0

local buttonParams = {
    countDisplay = {
        label='Total Cards: -', click_function='none', function_owner=self,
        position={0,0.04,0.175}, rotation={0,180,0}, scale={0.5,0.5,0.5}, width=0, height=0, font_size=60, font_color="White"
    },
    splitIntoPacks = {
        label='Make Packs', click_function='splitDeck', function_owner=self,
        position={0,0.04,-0.175}, rotation={0,180,0}, scale={0.5,0.5,0.5}, width=360, height=80, font_size=60, color="Green", font_color="White"
    },
}

local inputParams = {
    packsInput = {
        input_function="handlePacksInput", function_owner=self, tooltip="Pack count",
        alignment=3, position={0.12,0.08,0}, rotation={0,180,0}, scale={0.5,0.5,0.5}, height=120, width=200,
        font_size=60, validation=2, label="Packs", value=packs
    },
    packSizeInput = {
        input_function="handPackSizeInput", function_owner=self, tooltip="Cards per pack",
        alignment=3, position={-0.12,0.08,0}, rotation={0,180,0}, scale={0.5,0.5,0.5}, height=120, width=200,
        font_size=60, validation=2, label="Cards", value=cardsPerPack
    }
}

function handlePacksInput(obj, color, input, stillEditing)
    if not stillEditing then
        packs = tonumber(input)
    end
end

function handPackSizeInput(obj, color, input, stillEditing)
    if not stillEditing then
        cardsPerPack = tonumber(input)
    end
end

function onload()
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

function despawnButtons()
    self.clearButtons()
    self.clearInputs()
    self.createButton({
        label='Pack Dealer', click_function='none', function_owner=self,
        position={0,0.04,0}, rotation={0,180,0}, scale={0.5,0.5,0.5}, width=0, height=0, font_size=60, font_color="White"
    })
end

function onObjectLeaveContainer(container, obj)
    if container == self and makingPacks == false and #self.getObjects() == 0 then
        despawnButtons()
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
        spawnButtons()
    end
end

function spawnButtons()
    self.clearButtons()
    self.clearInputs()
    buttonParams.countDisplay.label = 'Total Cards: ' .. deckCount
    self.createButton(buttonParams.countDisplay)
    self.createButton(buttonParams.splitIntoPacks)
    inputParams.packsInput.value = packs
    inputParams.packSizeInput.value = cardsPerPack
    self.createInput(inputParams.packsInput)
    self.createInput(inputParams.packSizeInput)
end

function updateButtons()
    self.editButton(buttonParams.countDisplay)
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

function afterEntry()
    makingPacks = false
end

function makePacks()
    for p=1, packs do
        if deckCount == 0 or deckCount < cardsPerPack then
            broadcastToAll('Not enough cards left to form another pack.', {1,1,1})
            break
        end
        for c=1, cardsPerPack do
            if deckCount == 0 then
                break
            end
            local cardDistanceScale = 0.2*self.getScale().x/distanceScale
            
            local cardRot = self.getRotation()
            cardRot.x = cardRot.x+180
            
            local cardPos = self.getPosition()
            cardPos.x = cardPos.x + (sin(90+cardRot.y) * (cardDistanceScale+(cardOffset*p*distanceScale)))
            cardPos.y = cardPos.y + 1
            cardPos.z = cardPos.z + (cos(90+cardRot.y) * (cardDistanceScale+(cardOffset*p*distanceScale)))
            
            local takeParam = {position=cardPos, rotation=cardRot}
            deck.takeObject(takeParam)
            deckCount = deckCount - 1
        end
    end
    
    if deckCount == 0 then
        despawnButtons()
    else
        buttonParams.countDisplay.label = 'Total Cards: ' .. deckCount
        updateButtons()
    end
    
    Timer.destroy(self.getGUID())
    Timer.create({identifier=self.getGUID(), function_name='afterEntry', function_owner=self, delay=0.5})
end