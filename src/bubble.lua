module(..., package.seeall)

Bubble = {}
Bubble_mt = {__index = Bubble}

local deck = MOAITileDeck2D.new()
deck:setTexture('../resources/images/door.png')
deck:setSize(3,1)
deck:setRect(0,0,8,48)

local curve = MOAIAnimCurve:new()
curve:reserveKeys(4)
curve:setKey(1, 0*0.16/2, 1, MOAIEaseType.FLAT)
curve:setKey(2, 1*0.16/2, 2, MOAIEaseType.FLAT)
curve:setKey(3, 2*0.16/2, 3, MOAIEaseType.FLAT)
curve:setKey(4, 3*0.16/2, 3, MOAIEaseType.FLAT)

function Bubble:new(door)
  local gy = door.gy
  local gx
  local dir
  if door.pos == 'right' then
    dir = 'left'
    gx = door.gx-8
  elseif door.pos == 'left' then
    dir = 'right'
    gx = door.gx+16
  end

  local this = setmetatable({
    gx = gx,
    gy = gy,
    dir = dir,
    timeout = nil,
    status = {
      busy = true,
    },
  }, Bubble_mt)

  this.body = world:addBody(MOAIBox2DBody.STATIC, gx, gy)
  this.body.parent = this

  this.fixture = this.body:addRect(0,0,8,48)
  this.fixture.id = 'bubble'
  this.fixture:setCollisionHandler(collision.handler, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END)

  this.prop = MOAIProp2D.new()
  this.prop:setDeck(deck)
  this.prop:setParent(this.body)
  this.prop:setLoc(0,0)
  if dir == 'right' then
    this.prop:setScl(-1,1)
    this.prop:setLoc(8,0)
  end
  p_layer:insertProp(this.prop)

  this.anim = MOAIAnim:new()
  this.anim:reserveLinks(1)
  this.anim:setLink(1, curve, this.prop, MOAIProp2D.ATTR_INDEX)

  insertGameObject(this)

  return this
end

function Bubble:updateWorld()
  if self.timeout and MOAISim.getDeviceTime() > self.timeout then
    self:close()
  end
end

function Bubble:open(timeout)
  timeout = timeout or 3

  self.timeout = MOAISim.getDeviceTime() + timeout
  self.fixture:setSensor(true)

  sounds.play('door')
  self.anim:setMode(MOAITimer.NORMAL)
  self.anim:start()
end

function Bubble:close()
  sounds.play('door')

  self.timeout = nil
  self.fixture:setSensor(false)
  self.anim:setMode(MOAITimer.REVERSE)
  self.anim:start()
end

function Bubble:onCollision(fix_a, fix_b)
  if not self.timeout and (fix_b.id == 'bullet' or fix_b.id == 'missile') then
    self:open()
  end

  if fix_b:getBody().parent.id == 'samus' then
    if not self.timeout and fix_b:getBody().parent.status.in_door then
      self:open(0.6)
    end
  end
end

function Bubble:endCollision(fix_a, fix_b)
  if fix_b:getBody().parent.id == 'samus' and fix_b:getBody().parent.status.in_door then
    if self.timeout then
      self:close()
    end
  end
end

function Bubble:destroy()
end

return Bubble
