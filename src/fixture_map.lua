module(..., package.seeall)

local Floor = require('Floor')

local fixture_map = {
  room_cache = {},
  lru = {},
}

function fixture_map:updateRoomLru(rx, ry)
  for k, rci in pairs(self.lru) do
    if rci == rx.."-"..ry then
      table.remove(self.lru, k)
      table.insert(self.lru, rx.."-"..ry)
    end
  end
end

function fixture_map:updateRoomsForSamus(samus)
  local sx, sy = samus.body:getPosition()
  local srx, sry = map_mgr.getCoordinatesInRoomForGlobalPos(sx, sy)
  local rx, ry = map_mgr.getMapPosForGlobalPos(sx, sy)

  local diff = 128

  if srx < 128 then
    -- populate room left
    fixture_map:populateRoom(rx-1, ry)
  end
  if srx > 128 then
    -- populate room right
    fixture_map:populateRoom(rx+1, ry)
  end
  if sry < 120 then
    -- populate room up
    fixture_map:populateRoom(rx, ry+1)
  end
  if sry > 120 then
    -- populate room down
    fixture_map:populateRoom(rx, ry-1)
  end
end

function fixture_map:populateRoom(rx, ry)
  for rci,room in pairs(self.room_cache) do
    if rci == rx.."-"..ry then
      self:updateRoomLru(rx, ry)
      return
    end
  end

  local rci = rx.."-"..ry
  self.room_cache[rci] = {}

  self:populateRoomFixtures(rx, ry)
  self:populateRoomItems(rx, ry)
end

function fixture_map:populateRoomFixtures(rx, ry)
  local x, y = map_mgr.getGlobalPosForMapPos(rx, ry)
  local rid = map_mgr.getRoomIndex(rx, ry)
  local area = map_mgr.getRoomArea(rx, ry)

  local tiles = room_mgr.getRoomTileGrid(area, rid)

  local rci = rx.."-"..ry

  local gx, gy = map_mgr.getGlobalPosForMapPos(rx, ry)

  -- build doors
  local doors = room_mgr.getRoomDoors(area, rid)
  if doors then
    if doors.left then
      local door = require('door'):new(gx, gy, 'left', doors.left)
      table.insert(self.room_cache[rci], door)
    end
    if doors.right then
      local door = require('door'):new(gx, gy, 'right', doors.right)
      table.insert(self.room_cache[rci], door)
    end
  end

  -- build floor fixtures
  for tx = 1,16 do
    for ty = 1,15 do
      local tid = tiles[tx][ty]
      if tid > 0 then
        local tile_data = tile_mgr.getData(tid)
        local floor = Floor:new(x + (tx-1)*16, y + (15-ty)*16, tile_data)
        table.insert(self.room_cache[rci], floor)
      end
    end
  end
end

function fixture_map:populateRoomItems(rx, ry)
  local x,y = map_mgr.getGlobalPosForMapPos(rx, ry)
  local items = item_mgr.populateForRoom(rx, ry)

  local rci = rx.."-"..ry

  for k, item in pairs(items) do
    table.insert(self.room_cache[rci], item)
  end
end

return fixture_map
