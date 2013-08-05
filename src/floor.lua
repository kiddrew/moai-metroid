module(..., package.seeall)

Floor = {}
Floor_mt = {__index = Floor}

function Floor:new(gx, gy, tile_data)
  local this = setmetatable({
    gx = gx,
    gy = gy,
    blast = (tile_data and tile_data.blast),
    blast_timeout = nil,
    status = {
      busy = true
    },
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

  if this.blast then
    insertGameObject(this)
  end

  return this
end

function Floor:updateWorld()
  if self.blast_timeout then
    if MOAISim.getDeviceTime() > self.blast_timeout then
      self:respawn()
    end
  end
end

function Floor:doBlast()
  self.fixture:setSensor(true)
  local gtx, gty = map_mgr.getGlobalTilePosForGlobalPos(self.gx, self.gy)
  tile_map:removeTile(gtx, gty)
  self.blast_timeout = MOAISim.getDeviceTime()+6
end

function Floor:respawn()
  print "floor:respawn"
  self.fixture:setSensor(false)
  local gtx, gty = map_mgr.getGlobalTilePosForGlobalPos(self.gx, self.gy)
  tile_map:setTileFromMapData(gtx, gty)
  self.blast_timeout = nil
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
  tile_map:removeTile(gtx, gty)
end

function Floor:onCollision(fix_a, fix_b)
  if self.blast and (fix_b.id == 'bullet' or fix_b.id == 'missile' or fix_b.id == 'bomb_explode') then
    if fix_b.id == 'bullet' or fix_b.id == 'missile' then
      self:doBlast()
    elseif fix_b.id == 'bomb_explode' then
      local fx, fy = self.body:getPosition()
      local bx, by = fix_b:getBody():getPosition()
      -- The original game only allows for one floor tile in the X position to be destroyed per bomb.
      -- This checks to make sure the bomb is directly above a floor tile before it calls doBlast()
      if bx > fx and bx < fx + 16 then
        self:doBlast()
      end
    end
  end
end

function Floor:endCollision(fix_a, fix_b)
end

return Floor
