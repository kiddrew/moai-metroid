module(..., package.seeall)

local room_data = require('data/rooms')
local structure_mgr = require('structure_mgr')

return {
  getRoomTileGrid = function(area, rid)
    local grid = initializeGrid(16, 15)
    if area == 0 then
      return grid
    end
  
    local d = room_data[area][tonumber(rid,16)+1]
    if not d then
      return grid
    end
    local pd = d[1]
    local sd = d[2]
    local od = d[3]
  
    -- set up structures
    for k, s in pairs(sd) do
      local yx = tonumber(s[1],16) -- structure coordinates in 0bYYYYXXXX
      local sid = s[2] -- structure index
      local pid = s[3] -- structure palette id
  
      local x = 1 + yx % 0x10
      local y = 1 + math.floor(yx / 0x10)
  
      structure_mgr.drawToGrid(grid, x, y, area, sid, pid)
    end
  
    return grid
  end,
  getRoomDoors = function(area, rid)
    if area == 0 then
      return nil
    end

    local d = room_data[area][tonumber(rid,16)+1]

    if d[3] and d[3].doors then
      return d[3].doors
    else
      return nil
    end
  end,
  getRoomEnemies = function(area, rid)
    if area == 0 then
      return nil
    end

    local d = room_data[area][tonumber(rid,16)+1]

    return d[3].enemies or nil
  end
}
