module(..., package.seeall)

Door = {}
Door_mt = {__index = Door}

function Door:new (gx, gy, pos, hp)
  if pos == 'right' then
    gx = gx + 240
  end

  local this = setmetatable({
    gx = gx,
    gy = gy+112,
    pos = pos,
  }, Door_mt)

  this.body = world:addBody(MOAIBox2DBody.STATIC, this.gx, this.gy)
  this.body.parent = this
  this.fixture = this.body:addRect(0,0,16,48)
  this.fixture:setSensor(true)
  this.fixture.id = 'door'
  this.bubble = require('bubble'):new(this, hp)

  return this
end

function Door:destroy()
  self.body:destroy()
  self.fixture:destroy()
  self.bubble:destroy()
end

return Door
