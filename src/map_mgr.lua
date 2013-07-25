module(..., package.seeall)

local level_map = require('data/level_map')
local area_map = require('data/area_map')

function map_mgr.getMapPosForGlobalLoc(gx,gy)
  return math.floor((gx+4096)/256)+1, 32-math.floor((gy+3840)/240)
end

function map_mgr.getCoordinatesInRoom(x,y)
  return (x+4096)%256, (y+3840)%240
end

function map_mgr.getGlobalLocForMapPos(rx,ry)
  return -4096+(rx-1)*256, -3840+(32-ry)*240
end

function map_mgr.getRoomLocForTilePos(tx, ty)
  return (tx-1)*16, (15-ty)*16
end

function map_mgr.getGlobalLocForMapPosAndTilePos(rx,ry,tx,ty)
  local x,y = map_mgr.getGlobalLocForMapPos(rx,ry)
  return x + (tx-1)*16, y + (15-ty)*16
end

function map_mgr.getRoomIndex(rx,ry)
  return level_map[ry][rx]
end

function map_mgr.getRoomArea(rx,ry)
  return area_map[ry][rx]
end

function map_mgr.getDoorsForMapPos(rx, ry)
  local area = map_mgr.getRoomArea(rx, ry)
  local rid = map_mgr.getRoomIndex(rx, ry)
  return room_mgr.getRoomDoors(area, rid)
end

function map_mgr.getDoor(rx, ry, pos)
  local x,y = map_mgr.getGlobalLocForMapPos(rx, ry)

  if pos == 'right' then
    x = x + 240
  end
  local door = {}
  door.body = world:addBody(MOAIBox2DBody.STATIC, x, y + 112)
  door.fixture = door.body:addRect(0,0,16,48)
  door.fixture:setSensor(true)
  door.fixture.id = 'door'
  if pos == 'right' then
    door.fixture.dir = 'right'
  elseif pos == 'left' then
    door.fixture.dir = 'left'
  end
  return door
end

return map_mgr
