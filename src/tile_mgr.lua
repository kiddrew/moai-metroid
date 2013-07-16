module(..., package.seeall)

local tile_data = require('data/tiles')

return {
  getIndex = function(area, tid, pid)
    local offset = 0

    if area == 1 then
      if pid == '03' or pid == '01' then -- blue
        offset = 0
      elseif pid == '02' then -- yellow
        offset = 0x040
      elseif pid == '01' then -- green
        offset = 0x080
      end
    elseif area == 2 then
      offset = 0x120
    elseif area == 3 then
      offset = 0x0C0
    elseif area == 4 then
      offset = 0x1A0
    elseif area == 5 then
      offset = 0x1E0
    end

    return offset + tonumber(tid, 16) + 1
  end,
  getPoly = function(tid)
    if tile_data[tid] and tile_data[tid].poly then
      return tile_data[tid].poly
    end
    return {
      0,0,
      16,0,
      16,16,
      0,16,
    }
  end
}
