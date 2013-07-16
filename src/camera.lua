module(..., package.seeall)

local camera = MOAICamera2D.new()
camera:setScl(1)
camera.direction = 'x'

function camera:setRoomLoc(rx,ry)
  local x,y = map_mgr.getGlobalLocFromMapPos(rx, ry)
  camera:setLoc(x+128, y+120)
end

function camera:seekRoomLoc(rx, ry)
  local x,y = map_mgr.getGlobalLocFromMapPos(rx, ry)
  camera:seekLoc(x+128, y+128)
end

return camera
