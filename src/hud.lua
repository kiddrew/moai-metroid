module(..., package.seeall)

local hud_data = require 'data/hud'

Hud = {}

local deck = MOAITileDeck2D.new()
deck:setTexture('../resources/images/hud.png')
deck:setSize(16,16)
deck:setRect(-4,-4,4,4)

function Hud:new(samus)
  local this = setmetatable({
    samus = samus,
    props = {
    },
  }, {__index = Hud})

  this.container = MOAIProp2D.new()
  this.container:setLoc(-104,96)
  h_layer:insertProp(this.container)

  for i = 1, #hud_data do
    local prop = MOAIProp2D.new()
    prop:setDeck(deck)
    prop:setIndex(hud_data[i].deck_index)
    prop:setParent(this.container)
    prop:setLoc(hud_data[i].x, hud_data[i].y)
    h_layer:insertProp(prop)
    this.props[hud_data[i].index] = prop
  end

--[[
  local textbox = MOAITextBox.new()
  textbox:setString(tostring(samus.health))
  textbox:setFont(font)
  textbox:setRect(0,0,16,9)
  textbox:setYFlip(true)
  textbox:setParent(this.container)
  textbox:setLoc(20,-17.5)
  this.props.health = textbox
  h_layer:insertProp(textbox)

  if samus.max_missiles then
    local prop = MOAIProp2D.new()
    prop:setDeck(deck)
    prop:setIndex(6)
    prop:setParent(this.container)
    prop:setLoc(0, -22)
    h_layer:insertProp(prop)
    local prop = MOAIProp2D.new()
    prop:setDeck(deck)
    prop:setIndex(7)
    prop:setParent(this.container)
    prop:setLoc(8, -22)
    h_layer:insertProp(prop)
    local textbox = MOAITextBox.new()
    textbox:setString(tostring(samus.missiles))
    textbox:setFont(font)
    textbox:setRect(0,0,16,9)
    textbox:setYFlip(true)
    textbox:setParent(this.container)
    textbox:setLoc(12,-26.5)
    this.props.missiles = textbox
    h_layer:insertProp(textbox)
  end
  ]]--

  this:update()

  return this
end

function Hud:resetDeckIndex(index)
  self.props[index]:setIndex(hud_data[index].deck_index)
end

function Hud:updateCharacter(index, character)
  local deck_index = 9 + character
  self.props[index]:setIndex(deck_index)
end

function Hud:update()
  local samus = self.samus

  for i = 1,6 do
    local deck_index = 1
    if samus.energy_tanks >= i then
      if samus.energy >= (100 * i) then
        deck_index = 3
      else
        deck_index = 2
      end
    end
    self.props[7-i]:setIndex(deck_index)
  end

  self:updateCharacter(10, math.floor((samus.energy % 100) / 10))
  self:updateCharacter(11, (samus.energy % 100) % 10)

  if samus.max_missiles > 0 then
    self:resetDeckIndex(12)
    self:resetDeckIndex(13)
    self:updateCharacter(14, math.floor(samus.missiles / 100))
    self:updateCharacter(15, math.floor((samus.missiles % 100) / 10))
    self:updateCharacter(16, samus.missiles % 10)
  else
    -- disable missile display
    self.props[12]:setIndex(1)
    self.props[13]:setIndex(1)
    self.props[14]:setIndex(1)
    self.props[15]:setIndex(1)
    self.props[16]:setIndex(1)
  end
end

return Hud
