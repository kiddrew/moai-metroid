module(..., package.seeall)

UnitProp = {}
UnitProp_mt = {__index = UnitProp}

function UnitProp:new(parent, states, x, y)
  local this = setmetatable({
  }, UnitProp_mt)

  this.prop = MOAIProp2D.new()
  this.prop:setParent(parent.body)
  this.prop:setLoc(x,y)

  p_layer:insertProp(this.prop)

  return this
end

return UnitProp
