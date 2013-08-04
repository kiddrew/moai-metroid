local states = require('data/states/samus')
require 'unit'

module ( ..., package.seeall)

SamusChild = {}
SamusChild_mt = {__index = SamusChild}

function SamusChild:new(parent)
  if debug then
    print "creating child view"
  end

  local this = setmetatable({}, SamusChild_mt)

  this.prop = MOAIProp2D.new()
  this.prop:setAttrLink(MOAIProp2D.INHERIT_TRANSFORM, parent.prop, MOAIProp2D.TRANSFORM_TRAIT)
  this.prop:setLoc(0,16)
  if not debug then
    p_layer:insertProp(this.prop)
  end

  return this
end

function SamusChild:setState(name)
  if debug then
    print("set child state: "..name)
  end
  setupObjGfx(self, states.child, name)

  self.prop:setDeck(self.deckcache[name])
  self.prop:setVisible(true)
end

function SamusChild:remove()
  self.prop:setVisible(false)
end


SamusView = {}
SamusView_mt = {__index = SamusView}

function SamusView:new(samus)
  if debug then
    print "creating view"
  end

  local this = setmetatable({
    action = nil,
    firing = false,
    parent = samus
  }, SamusView_mt)

  -- Main prop
  this.prop = MOAIProp2D.new()
--  this.prop:setDeck(deck)
  this.prop:setParent(this.parent.body)

  if not debug then
    p_layer:insertProp(this.prop)
  end

  this.child = SamusChild:new(this)

  return this
end

function SamusView:setState(name)
  if debug then
    print("next state: "..name)
  end
  setupObjGfx(self, states.parent, name)

  if debug and not self.deckcache[name] then
    print("deckcache not set!")
  end
  self.prop:setDeck(self.deckcache[name])
  self.prop:setIndex(1)

  self.anim = self.animcache[name]

  if self.anim then
    self.anim:start()
  end

  self.action = name
end

function SamusView:getDeckIndex(samus)
  local index = 1

  if samus.status.missile_mode then
    index = index + deck_size[1]
  end
  if samus.gear.varia then
    index = index + 2*deck_size[1]
  end

  return index
end

function SamusView:setChildState(name)
  self.child:setState(name)
end

function SamusView:updateForSamus(samus)
  self:update(samus.status.action, samus.status.facing, samus.status.aiming_up, not not samus.status.firing_timeout)
end

function SamusView:update(action, facing, aiming_up, firing)
  self:setFace(facing)

  if self.action ~= action or self.firing ~= firing then
    if self.anim then
      self.anim:stop()
      self.anim:clear()
      self.anim = nil
    end
  
    if debug then
      print("update state: "..action)
    end
  
    -- update main prop
    local state = action
    if action == 'flip' and firing == true then
      state = 'jump'
    end
    self:setState(state)
    self.firing = firing
  end

  self.child:remove()
  -- update child prop
  if aiming_up == true then
    self:setChildState('aimup')
  elseif (action == 'jump' or action == 'run' or action == 'flip') and firing == true then
    self:setChildState('fire')
  end

end

function SamusView:setFace(facing)
  if facing == 'right' then
    self.prop:setScl(1,1)
  else
    self.prop:setScl(-1,1)
  end
end
