module(..., package.seeall)

local structure_data = require('data/structures')

return {
  drawToGrid = function(grid, y, x, sid, pid)
    local s_data = structure_data[tonumber(sid,16)+1]
  
    for r,row in pairs(s_data) do
      for c,tid in pairs(row) do
        local grid_x = x+c-1
        local grid_y = y+r-1
  
        if grid_x <= 16 and grid_y <= 15 then
          grid[grid_y][grid_x] = getTileIndex(tid, pid)
        end
      end
    end
  end
}
