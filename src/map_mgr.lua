module(..., package.seeall)

local map_data = require('data/map')
local area_data = require('data/areas')
local room_mgr = require('room_mgr')
local tile = require('tile_mgr')

local map_mgr = {
  room_cache = {},
}

function map_mgr.getMapPosFromGlobalLoc(x,y)
  return math.floor((x+4096)/256)+1, 32-math.floor((y+3840)/240)
end

function map_mgr.getCoordinatesInRoom(x,y)
  return (x+4096)%256, (y+3840)%240
end

function map_mgr.getGlobalLocFromMapPos(rx,ry)
  return -4096+(rx-1)*256, -3840+(32-ry)*240
end

function map_mgr.getRoomIndex(rx,ry)
  return map_data[ry][rx]
end

function map_mgr.getGlobalGrid()
  return map_data
end

function map_mgr.getRoomArea(rx,ry)
  return area_data[ry][rx]
end

function map_mgr:populateRoom(rx, ry)
  self:populateRoomFloor(rx, ry)
end

function map_mgr.updateRoomData(camera, samus)
  local sx, sy = samus.body:getPosition()
  local srx, sry = map_mgr.getCoordinatesInRoom(sx, sy)
  local rx, ry = map_mgr.getMapPosFromGlobalLoc(sx, sy)

  if srx < 32 then
    -- populate room left
    map_mgr:populateRoom(rx-1, ry)
  end
  if srx > 224 then
    -- populate room right
    map_mgr:populateRoom(rx+1, ry)
  end
  if sry < 32 then
    -- populate room up
    map_mgr:populateRoom(rx, ry+1)
  end
  if sry > 208 then
    -- populate room down
    map_mgr:populateRoom(rx, ry-1)
  end
end

function map_mgr.getDoorsForMapPos(rx, ry)
  local area = map_mgr.getRoomArea(rx, ry)
  local rid = map_mgr.getRoomIndex(rx, ry)
  return room_mgr.getRoomDoors(area, rid)
end

--[[
function map_mgr:clearRoom(rx, ry)
  if not self.floors[tostring(rx).."-"..tostring(ry)] then
    return
  end

  for k, floor in pairs(self.floors[tostring(rx).."-"..tostring(ry)]) do
    floor.body:destroy()
    floor.fixture:destroy()
    floor = nil
  end
  self.floors[tostring(rx).."-"..tostring(ry)] = {}
end
]]--

function map_mgr:populateRoomFloor(rx, ry)
  for k,room in pairs(self.room_cache) do
    if room.loc == rx.."-"..ry then
      table.remove(self.room_cache, k)
      table.insert(self.room_cache, room)
      return
    end
  end

  print("populate room floor: "..rx..","..ry)

  local x, y = map_mgr.getGlobalLocFromMapPos(rx, ry)
  local rid = map_mgr.getRoomIndex(rx, ry)
  local area = map_mgr.getRoomArea(rx, ry)

  local tiles = room_mgr.getRoomTileGrid(area, rid)

  local room = {}
  room.loc = rx.."-"..ry

  -- build doors
  local doors = room_mgr.getRoomDoors(area, rid)
  if doors then
    if doors.left then
      local door = map_mgr.getDoor(rx, ry, 'left')
      table.insert(room, door)
    end
    if doors.right then
      local door = map_mgr.getDoor(rx, ry, 'right')
      table.insert(room, door)
    end
  end

  -- build floor fixtures
  for tx = 1,16 do
    for ty = 1,15 do
      local tid = tiles[tx][ty]
      if tid > 0 then
        local poly = tile.getPoly(tid)
        if poly ~= -1 then
          local floor = {}
          floor.body = world:addBody(MOAIBox2DBody.STATIC, x + (tx-1)*16, y + (15-ty)*16)
          floor.fixture = floor.body:addPolygon(poly)
          floor.fixture.id = 'floor'
          table.insert(room, floor)
        end
      end
    end
  end
  table.insert(self.room_cache, room)
end

function map_mgr.getDoor(rx, ry, pos)
  local x,y = map_mgr.getGlobalLocFromMapPos(rx, ry)

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

--[[
function map_mgr:clearRoomFloors()
  for k,room in pairs(self.floors) do
    for k2,floor in pairs(room) do
      floor.body:destroy()
      floor.fixture:destroy()
    end
  end
  self.floors = {}
end
]]--

function map_mgr.init()
  local map = MOAIGrid.new()
  map:initRectGrid(512,480,16,16)
  map:fill(0)

  for rx = 1,32 do
    for ry = 1,32 do
      local rid = map_mgr.getRoomIndex(rx, ry)

      if rid ~= '..' then
        local area = map_mgr.getRoomArea(rx, ry)
        local tiles = room_mgr.getRoomTileGrid(area, rid)

        for tx = 1,16 do
          for ty = 1,15 do
            local tid = tiles[tx][ty]
            if tid > 0 then
              if not debug then
                map:setTile((rx-1)*16+tx, 496-15*ry-ty, tid)
              end
              if debug then
                local textbox = MOAITextBox.new()
                textbox:setString(string.format('%X', tid))
                textbox:setFont(font)
                textbox:setRect(0,0,16,16)
                textbox:setLoc(-4096+(rx-1)*256+(tx-1)*16, -3840+(32-ry)*240+(15-ty)*16)
                textbox:setYFlip(true)
                m_layer:insertProp(textbox)
              end
            end
          end
        end
      end
    end
  end

  local mapTiles = MOAITileDeck2D.new()
  mapTiles:setTexture('../resources/images/tiles.png')
  mapTiles:setSize(16,64)
  local prop = MOAIProp2D.new()
  prop:setDeck(mapTiles)
  prop:setGrid(map)
  prop:setLoc(-32*16*16/2, -32*16*15/2)
  m_layer:insertProp(prop)
end

function map_mgr.getRoomMap()
  local rooms = {}
  for i = 1,32 do
    rooms[i] = {}
    for j = 1,32 do
      local rid = map_mgr.getRoomIndex(i,j)

      rooms[i][j] = room_mgr.getRoomTileGrid(rid)
    end
  end

  return rooms
end

return map_mgr
