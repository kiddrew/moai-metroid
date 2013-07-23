module(..., package.seeall)

Bullet = {}
Bullet_mt = {__index = Bullet}

local deck = MOAITileDeck2D.new()
deck:setTexture('../resources/images/bullet.png')
deck:setSize(1,4)
deck:setRect(-2, -2.5, 2, 5.5)

function Bullet:new (x, y, dir, weapon, longbeam)
  local this = setmetatable({
    x = x,
    y = y,
    dir = dir,
    weapon = weapon,
    longbeam = longbeam,
    status = {
      busy = true
    },
  }, Bullet_mt)

  if dir == 'right' then
    this.body = world:addBody(MOAIBox2DBody.KINEMATIC, x+10, y+21)
  elseif dir == 'left' then
    this.body = world:addBody(MOAIBox2DBody.KINEMATIC, x-10, y+21)
  elseif dir == 'up' then
  end

  this.body:setFixedRotation(true)
  this.body.parent = this
  this.fixture = this.body:addRect(-2, -2.5, 2, 2.5)
  this.fixture.parent = this
  this.fixture.id = 'bullet'
  this.fixture:setSensor(true)

  if dir == 'right' then
    this.body:setLinearVelocity(200, 0)
  elseif dir == 'left' then
    this.body:setLinearVelocity(-200, 0)
  elseif dir == 'up' then
    this.body:setLinearVelocity(0, 200)
  end

  local prop = MOAIProp2D.new()
  prop:setDeck(deck)
  prop:setParent(this.body)
  this.prop = prop
  prop:setLoc(-2,0)
  if dir == 'left' then
    prop:setScl(-1,1)
  end
  p_layer:insertProp(prop)

  insertGameObject(this)

  return this
end

function Bullet:updateWorld()
  local gx, gy = self.body:getPosition()
  local distance = 256

  -- check if bullet needs to die
  if self.longbeam == false then
    distance = 60
  end
    
  if self.dir == 'left' or self.dir == 'right' then
    if math.abs(gx-self.x) > distance then
      self:destroy()
    end
  elseif self.dir == 'up' then
    if math.abs(gy-self.y) > distance then
      self:destroy()
    end
  end
end

function Bullet:onCollision(fix_a, fix_b)
end

function Bullet:endCollision(fix_a, fix_b)
end

function Bullet:destroy()
  p_layer:removeProp(self.prop)
  self.fixture:destroy()
  self.fixture = nil
  self.body:destroy()
  self.body = nil
end

return Bullet
