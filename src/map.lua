module(..., package.seeall)

local map_data = require('data/map')

return {
  getRoomIndex = function(x,y)
    index = 32*(y-1)+x
    return map_data[index]
  end
}

