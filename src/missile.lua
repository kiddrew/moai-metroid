module(..., package.seeall)

Missile = {}
Missile_mt = {__index = Missile}

local deck = MOAITileDeck2D.new()
deck:setTexture('../resources/images/missile.png')
deck:setSize(1,4)
deck:setRect()

local e_deck = MOAITileDeck2D.new()
e_deck:setTexture('../resources/images/missile_explode.png')
e_deck:setSize()
e_deck:setRect()

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
  this.fixture = this.body:addRect()
  this.fixture.id = 'missile'
  this.fixture:setCollisionHandler(collision.handler, MOAIBox2DArbiter.BEGIN)
  this.fixture:setSensor(true)

  if dir == 'right' then
  elseif dir == 'left' then
  elseif dir == 'up' then
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

  return this
end

function Missile:updateWorld()
end

function Missile:onCollision(fix_a, fix_b)
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
