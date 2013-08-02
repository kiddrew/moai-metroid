module(..., package.seeall)

Bomb = {}
Bomb_mt = {__index = Bomb}

local deck = MOAITileDeck2D.new()
deck:setTexture('../resources/images/bomb.png')
deck:setSize(2,4)
deck:setRect(-4,-4,4,4)

local e_deck = MOAITileDeck2D.new()
e_deck:setTexture('../resources/images/bomb_explode.png')
e_deck:setSize(4,4)
e_deck:setRect(-16,-16,16,16)

local curve = MOAIAnimCurve:new()
curve:reserveKeys(3)
curve:setKey(1, 0*0.16/4, 1, MOAIEaseType.FLAT)
curve:setKey(2, 1*0.16/4, 2, MOAIEaseType.FLAT)
curve:setKey(3, 2*0.16/4, 2, MOAIEaseType.FLAT)

local e_curve = MOAIAnimCurve:new()
e_curve:reserveKeys(4)
e_curve:setKey(1, 0*0.16/2, 1, MOAIEaseType.FLAT)
e_curve:setKey(2, 1*0.16/2, 2, MOAIEaseType.FLAT)
e_curve:setKey(3, 2*0.16/2, 3, MOAIEaseType.FLAT)
e_curve:setKey(4, 3*0.16/2, 3, MOAIEaseType.FLAT)

function Bomb:new (gx, gy)
  local this = setmetatable({
    gx = gx,
    gy = gy,
    status = {
      busy = true
    },
    id = 'bomb',
    exploded = false,
  }, Bomb_mt)

  function remove()
    this:destroy()
  end
  
  this.body = world:addBody(MOAIBox2DBody.STATIC, gx, gy)

  this.body:setFixedRotation(true)
  this.body.parent = this
  this.fixture = this.body:addRect(-4,-4,4,4)
  this.fixture.id = 'bomb'
  this.fixture:setSensor(true)

  this.prop = MOAIProp2D.new()
  this.prop:setDeck(deck)
  this.prop:setParent(this.body)
  this.prop:setLoc(0,0)
  p_layer:insertProp(this.prop)

  this.anim = MOAIAnim:new()
  this.anim:reserveLinks(1)
  this.anim:setLink(1, curve, this.prop, MOAIProp2D.ATTR_INDEX)
  this.anim:setMode(MOAITimer.LOOP)

  this.e_anim = MOAIAnim:new()
  this.e_anim:reserveLinks(1)
  this.e_anim:setLink(1, e_curve, this.prop, MOAIProp2D.ATTR_INDEX)
  this.e_anim:setListener(MOAIAction.EVENT_STOP, remove)
  this.e_anim:setMode(MOAITimer.NORMAL)

  this.ts = MOAISim.getDeviceTime()

  this.anim:start()

  insertGameObject(this)

  sounds.play('bomb_set')

  return this
end

function Bomb:updateWorld()
  if not self.exploded and MOAISim.getDeviceTime()-self.ts > 1 then
    self:explode()
  end
end

function Bomb:onCollision(fix_a, fix_b)
end

function Bomb:endCollision(fix_a, fix_b)
end

function Bomb:explode()
  if self.exploded then return end

  self.exploded = true
  self.anim:stop()
  self.anim:clear()

  self.fixture:destroy()
  self.fixture = self.body:addCircle(0,0,16)
  self.fixture.id = 'bomb_explode'
  self.fixture:setSensor(true)
  self.fixture:setCollisionHandler(collision.handler, MOAIBox2DArbiter.BEGIN)

  self.prop:setDeck(e_deck)
  self.prop:setIndex(1)

  sounds.play('bomb_explode')

  self.e_anim:start()
end

function Bomb:destroy()
  self.prop:setDeck(nil)
  p_layer:removeProp(self.prop)
  self.prop = nil

  self.e_anim = nil
  self.anim = nil

  self.body:destroy()
  self.body = nil

  self.fixture:destroy()
  self.fixture = nil

  Samus:cleanupBombCache()
end

return Bomb
