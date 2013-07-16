module(..., package.seeall)

local map_data = require('data/map')
local area_data = require('data/areas')
local room_mgr = require('room_mgr')
local tile = require('tile_mgr')

local map_mgr = {
  floors = {},
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

function map_mgr:populateRoomFloor(rx, ry)
  if self.floors[tostring(rx).."-"..tostring(ry)] then
    return
  end

  print("populate room floor: "..rx..","..ry)

  local x, y = map_mgr.getGlobalLocFromMapPos(rx, ry)
  local rid = map_mgr.getRoomIndex(rx, ry)
  local area = map_mgr.getRoomArea(rx, ry)

  local tiles = room_mgr.getRoomTileGrid(area, rid)

  self.floors[tostring(rx).."-"..tostring(ry)] = {}

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
          table.insert(self.floors[tostring(rx).."-"..tostring(ry)], floor)
        end
      end
    end
  end
end

function map_mgr:clearRoomFloors()
  for k,room in pairs(self.floors) do
    for k2,floor in pairs(room) do
      floor.body:destroy()
      floor.fixture:destroy()
      floor:destroy()
    end
  end
  self.floors = {}
end

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
