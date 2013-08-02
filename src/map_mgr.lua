module(..., package.seeall)

local level_map = require('data/level_map')
local area_map = require('data/area_map')

function map_mgr.getMapPosForGlobalPos(gx,gy)
  return math.floor((gx+4096)/256)+1, 32-math.floor((gy+3840)/240)
end

function map_mgr.getCoordinatesInRoomForGlobalPos(gx,gy)
  return (gx+4096)%256, (gy+3840)%240
end

function map_mgr.getGlobalPosForMapPos(rx,ry)
  return -4096+(rx-1)*256, -3840+(32-ry)*240
end

function map_mgr.getRoomPosForTilePos(tx, ty)
  return (tx-1)*16, (15-ty)*16
end

function map_mgr.getGlobalTilePosForGlobalPos(gx, gy)
  return math.floor((gx+4096)/16)+1, math.floor((gy+3840)/16)+1
end

function map_mgr.getGlobalPosForMapPosAndTilePos(rx,ry,tx,ty)
  local x,y = map_mgr.getGlobalPosForMapPos(rx,ry)
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
  local gx,gy = map_mgr.getGlobalPosForMapPos(rx, ry)

  local door = require('door'):new(gx, gy, pos)

  return door
end

return map_mgr
