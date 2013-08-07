local states = require('data/states/samus')
require 'unit'

module ( ..., package.seeall)

SamusChild = {}
SamusChild_mt = {__index = SamusChild}

function samusDeckRow(samus)
  local row = 1
  if samus.status.missile_mode then
    row = row + 1
  end
  if samus.gear.varia then
    row = row + 2
  end

  return row
end

function SamusChild:new(parent)
  local this = setmetatable({
    parent = parent,
  }, SamusChild_mt)

  this.prop = MOAIProp2D.new()
  this.prop:setAttrLink(MOAIProp2D.INHERIT_TRANSFORM, parent.prop, MOAIProp2D.TRANSFORM_TRAIT)
  this.prop:setLoc(0,16)
  if not debug then
    p_layer:insertProp(this.prop)
  end

  return this
end

function SamusChild:setState(name)
  setupObjGfx(self, states.child, name, self.parent.deck_row)

  self.prop:setVisible(true)
end

function SamusChild:remove()
  self.prop:setVisible(false)
end


SamusView = {}
SamusView_mt = {__index = SamusView}

function SamusView:new(samus)
  local this = setmetatable({
    action = nil,
    firing = false,
    deck_row = 1,
    parent = samus
  }, SamusView_mt)

  -- Main prop
  this.prop = MOAIProp2D.new()
  this.prop:setParent(this.parent.body)

  if not debug then
    p_layer:insertProp(this.prop)
  end

  this.child = SamusChild:new(this)

  return this
end

function SamusView:setState(name)
  setupObjGfx(self, states.parent, name, self.deck_row)

  if self.anim then
    self.anim:start()
  end

  self.action = name
end

function SamusView:setChildState(name)
  self.child:setState(name)
end

function SamusView:updateForSamus(samus)
  self:update(samus.status.action, samus.status.facing, samus.status.aiming_up, not not samus.status.firing_timeout)
end

function SamusView:update(action, facing, aiming_up, firing)
  self:setFace(facing)

  local deck_row = samusDeckRow(self.parent)

  if self.action ~= action or self.firing ~= firing or deck_row ~= self.deck_row then
    self.deck_row = deck_row

    if self.anim then
      self.anim:stop()
      self.anim:clear()
      self.anim = nil
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
