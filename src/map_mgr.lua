module(..., package.seeall)

local map_data = require('data/map')
local area_data = require('data/areas')
local room_mgr = require('room_mgr')
local tile = require('tile_mgr')

local map_mgr = {}

function map_mgr.getRoomCoordinates(rx,ry)
  return -4096+(rx-1)*16*16+128, -3840+(32-ry)*15*16+120
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
              map:setTile((rx-1)*16+tx, 496-15*ry-ty, tid)
              local poly = tile.getPoly(area, tid)
              if poly ~= -1 then
--                local platform = {}
--                platform.body = world:addBody(MOAIBox2DBody.STATIC, -4096+(rx-1)*256+(tx-1)*16, 3840-(ry-1)*240-ty*16)
--                platform.fixture = platform.body:addPolygon(poly)
--                platform.fixture.id = 'ground'
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
