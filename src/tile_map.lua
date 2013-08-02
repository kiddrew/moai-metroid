module(..., package.seeall)

local tile_map = MOAIGrid.new()
tile_map:initRectGrid(512, 480, 16, 16)
tile_map:fill(0)

function tile_map:init()
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
                self:setTile((rx-1)*16+tx, 496-15*ry-ty, tid)
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
  prop:setGrid(self)
  prop:setLoc(-32*16*16/2, -32*16*15/2)
  m_layer:insertProp(prop)
end

return tile_map
