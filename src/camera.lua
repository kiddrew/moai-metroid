module(..., package.seeall)

local camera = MOAICamera2D.new()
camera:setScl(1)
camera.direction = 'x'

function camera:setRoomLoc(rx,ry)
  local x,y = map_mgr.getRoomCoordinates(rx, ry)
  camera:setLoc(x, y)
end

function camera:seekRoomLoc(rx, ry)
  local x,y = map_mgr.getRoomCoordinates(rx, ry)
  camera:seekLoc(x, y)
end

return camera
