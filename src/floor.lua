module(..., package.seeall)

Floor = {}
Floor_mt = {__index = Floor}

function Floor:new(gx, gy, tile_data)
  local this = setmetatable({
    gx = gx,
    gy = gy,
    blast = (tile_data and tile_data.blast),
  }, Floor_mt)

  local poly
  if not tile_data or not tile_data.poly then
    poly = {
      0,0,
      16,0,
      16,16,
      0,16,
    }
  else
    poly = tile_data.poly
  end

  this.body = world:addBody(MOAIBox2DBody.STATIC, gx, gy)
  this.body.parent = this
  if poly ~= -1 then
    this.fixture = this.body:addPolygon(poly)
    this.fixture.id = 'floor'
    this.fixture:setCollisionHandler(collision.handler, MOAIBox2DArbiter.BEGIN)
  end

  return this
end

function Floor:destroy()
  if self.body then
    self.body:destroy()
    self.body = nil
  end
  if self.fixture then
    self.fixture:destroy()
    self.fixture = nil
  end

  local gtx, gty = map_mgr.getGlobalTilePosForGlobalPos(self.gx, self.gy)
  tile_map:setTile(gtx, gty, 0)
end

function Floor:onCollision(fix_a, fix_b)
  if self.blast then
    if fix_b.id == 'bullet' or fix_b.id == 'missile' or fix_b.id == 'bomb' then
      self:destroy()
    end
  end
end

function Floor:endCollision(fix_a, fix_b)
end

return Floor
