module (..., package.seeall)

Item = {}
Item_mt = {__index = Item}

function Item:new(data)
  local rx = data.rx
  local ry = data.ry
  local tx = data.tx
  local ty = data.ty

  local x,y = map_mgr.getGlobalPosForMapPos(rx, ry)

  local this = setmetatable({
    rx = data.rx,
    ry = data.ry,
    tx = data.tx,
    ty = data.ty,
    gift = data.gift,
    gotten = false,
  }, Item_mt)
  this.body = world:addBody(MOAIBox2DBody.STATIC, x + (tx-1)*16, y + (15-ty)*16)
  this.body.parent = this
  this.fixture = this.body:addPolygon(data.poly)
  this.fixture.parent = this
  this.fixture.id = 'item'
--  this.fixture:setCollisionHandler(collision.handler, MOAIBox2DArbiter.BEGIN)

  local deck = MOAITileDeck2D.new()
  this.deck = deck
  deck:setTexture('../resources/images/item_tiles.png')
  deck:setSize(8,8)
  deck:setRect(0,0,16,16)

  local prop = MOAIProp2D.new()
  prop:setDeck(deck)
  prop:setParent(this.body)
  this.prop = prop
  prop:setLoc(0,0)
  if not debug then
    p_layer:insertProp(prop)
  end

  local frames = data.frames
  local curve = MOAIAnimCurve:new()
  this.curve = curve
  curve:reserveKeys(#frames)
  for i = 1, #frames do
    curve:setKey(i, data.anim_step*(i-1), frames[i], MOAIEaseType.FLAT)
  end

  local anim = MOAIAnim:new()
  this.anim = anim
  anim:reserveLinks(1)
  anim:setLink(1, curve, prop, MOAIProp2D.ATTR_INDEX)
  anim:setMode(MOAITimer.LOOP)
  anim:start()

  return this
end

function Item:destroy()
  print "Item:destroy()"
  self.prop:setDeck(nil)
  p_layer:removeProp(self.prop)
  self.body:destroy()
  self.body = nil
  self.fixture:destroy()
  self.fixture = nil
end

function Item:onCollision(fix_a, fix_b)
  print "Item:onCollision"
  local thread = MOAICoroutine.new()
  thread:run( function()
    if fix_b:getBody().parent.id == 'samus' then
      self:destroy()
    end
  end )
end

function Item:endCollision(fix_a, fix_b)
end

return Item
