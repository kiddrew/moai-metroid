require 'obj_setup'

module (..., package.seeall)

ObjView = {}
ObjView_mt = {__index = ObjView}

function ObjView:new()
  local this = setmetatable({
  }, ObjView_mt)

  return this
end

function ObjView:setup()
  setupObj(self)
end
