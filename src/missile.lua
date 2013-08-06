module(..., package.seeall)

Missile = {}
Missile_mt = {__index = Missile}

local deck = MOAITileDeck2D.new()
deck:setTexture('../resources/images/missile.png')
deck:setSize(2,4)
deck:setRect(-6,-6,6,6)

--[[
local e_deck = MOAITileDeck2D.new()
e_deck:setTexture('../resources/images/missile_explode.png')
e_deck:setSize()
e_deck:setRect(-6,-6,6,6)
]]--

local e_curve = MOAIAnimCurve:new()
e_curve:reserveKeys(4)
e_curve:setKey(1, 0*0.16/2, 1, MOAIEaseType.FLAT)

function Missile:new (x, y, dir)
  local this = setmetatable({
    x = x,
    y = y,
    dir = dir,
    status = {
      busy = true
    },
  }, Missile_mt)

  this.body = world:addBody(MOAIBox2DBody.DYNAMIC, x, y)

  this.body:setFixedRotation(true)
  this.body.parent = this
  this.body:setBullet(true)
  this.fixture = this.body:addRect(-6,-4,6,4)
  this.fixture.id = 'missile'
  this.fixture:setCollisionHandler(collision.handler, MOAIBox2DArbiter.BEGIN)
  this.fixture:setSensor(true)

  if dir == 'right' then
    this.body:setLinearVelocity(220,0)
  elseif dir == 'left' then
    this.body:setLinearVelocity(-220,0)
  elseif dir == 'up' then
    this.body:setLinearVelocity(0,220)
  end

  local prop = MOAIProp2D.new()
  prop:setDeck(deck)
  prop:setParent(this.body)
  this.prop = prop
  prop:setLoc(0,0)
  if dir == 'left' then
    prop:setScl(-1,1)
  end
  p_layer:insertProp(prop)

  insertGameObject(this)

  sounds.play('missile')

  return this
end

function Missile:updateWorld()
  local gx, gy = self.body:getPosition()
  local distance = 256

  if self.dir == 'left' or self.dir == 'right' then
    local dx, dy = self.body:getLinearVelocity()
    self.body:setLinearVelocity(dx, 5)
  elseif self.dir == 'up' then
    self.body:setLinearVelocity(0,225)
  end
end

function Missile:onCollision(fix_a, fix_b)
  if fix_b.id == 'floor' or fix_b.id == 'enemy' or fix_b.id == 'bubble' then
    self:destroy()
  end
end

function Missile:endCollision(fix_a, fix_b)
end

function Missile:explode()
  print "Missile:explode"
  self.anim:stop()
  self.anim:clear()

  self.prop:setDeck(e_deck)
  self.prop:setIndex(1)

  self.e_anim:start()
end

function Missile:destroy()
  self.prop:setDeck(nil)
  p_layer:removeProp(self.prop)
  self.prop = nil

  self.fixture:destroy()
  self.fixture = nil

  self.body:destroy()
  self.body = nil
end

return Missile
