local View = require('obj_view').ObjView

module ( ..., package.seeall)

Obj = {}
Obj_mt = {__index = Obj}

function Obj:new ()
  local this = setmetatable({
    health = 99
  }, Obj_mt)

  this.view = View:new()

  return this
end

function Obj:setupView()
  self.view:setup()
end
