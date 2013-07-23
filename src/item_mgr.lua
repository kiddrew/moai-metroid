module(..., package.seeall)

local item_data = require('data/items')
local Item = require('item')

local item_mgr = {}

function item_mgr.getDataForRoom(rx, ry)
  local items = {}

  for k, item in pairs(item_data) do
    for k2, loc in pairs(item.locs) do
      if loc.rx == rx and loc.ry == ry then
        local tmp = {}
        tmp.id = item.id
        tmp.frames = item.frames
        tmp.anim_step = item.anim_step
        tmp.rx = loc.rx
        tmp.ry = loc.ry
        tmp.tx = loc.tx
        tmp.ty = loc.ty
        tmp.gift = item.gift

        if item.poly then
          tmp.poly = item.poly
        else
          tmp.poly = {
            2,2,
            14,2,
            14,4,
            2,4
          }
        end

        table.insert(items, tmp)
      end
    end
  end

  return items
end

function item_mgr.populateForRoom(rx, ry)
  local items = item_mgr.getDataForRoom(rx, ry)

  local tmp = {}

  for k, data in pairs(items) do
    local item = Item:new(data)
    table.insert(tmp, item)
  end

  return tmp
end

return item_mgr
