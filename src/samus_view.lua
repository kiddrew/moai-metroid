local data = require('data/samus').getData()
local data_child = require('data/samus_child').getData()
local debug = false
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
  layer:insertProp(this.prop)

  return this
end

function SamusChild:setState(name)
  if debug then
    print("set child state: "..name)
  end
  setupObjGfx(self, data_child, name)

  self.prop:setDeck(self.deckcache[name])
  self.prop:setVisible(true)
end

function SamusChild:cancel(action)
  print("cancel action: "..action)
  if action == 'fire' then
    self.parent.parent.status.firing = false
  end
  self:remove()
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
    parent = samus
  }, SamusView_mt)

  -- Main prop
  this.prop = MOAIProp2D.new()
  this.prop:setDeck(deck)
  this.prop:setParent(this.parent.body)

  layer:insertProp(this.prop)

  this.child = SamusChild:new(this)

  return this
end

function SamusView:setState(name)
  if debug then
    print("next state: "..name)
  end
  setupObjGfx(self, data, name)

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

function SamusView:setChildState(name)
  self.child:setState(name)
end

function SamusView:updateForObject(samus)
  self:update(samus.status.action, samus.status.facing, samus.status.aiming_up, samus.status.firing)
end

function SamusView:update(action, facing, aiming_up, firing)
  self:setFace(facing)

  if self.action ~= action then
    if self.anim then
      self.anim:stop()
      self.anim:clear()
      self.anim = nil
    end
  
    if debug then
      print("update state: "..action)
    end
  
    -- update main prop
    if action == 'spawn' then
      self:setState('spawn')
    elseif action == 'duck' then
      self:setState('duck')
    elseif action == 'roll' then
      self:setState('roll')
    elseif action == 'jumpToFlip' then
      self:setState('jumpToFlip')
    elseif action == 'flip' then
      if firing == true then
        self:setState('jump')
      else
        self:setState('flip')
      end
    elseif action == 'jump' then
      self:setState('jump')
    elseif action == 'run' then
      self:setState('run')
    else
      self:setState('stand')
    end
  end

  self.child:remove()
  -- update child prop
  if aiming_up == true then
    self:setChildState('aimup')
  elseif action == 'jump' and firing == true then
    self:setChildState('fire')
  end

end

function SamusView:setFace(facing)
  if debug then
    print("facing = "..facing)
  end
  if facing == 'right' then
    self.prop:setScl(1,1)
  else
    self.prop:setScl(-1,1)
  end
end
