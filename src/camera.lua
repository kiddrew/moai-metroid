module(..., package.seeall)

local map_mgr = require('map_mgr')

local camera = MOAICamera2D.new()
camera:setScl(1)
camera.direction = 'x'

function camera:swapDirection()
  if self.direction == 'x' then
    self.direction = 'y'
  else
    self.direction = 'x'
  end
end

function camera:setRoomLoc(rx,ry)
  local x,y = map_mgr.getGlobalPosForMapPos(rx, ry)
  self:setLoc(x+128, y+120)
end

function camera:seekRoomLoc(rx, ry, duration)
  if not duration then
    duration = 1
  end
  local x,y = map_mgr.getGlobalPosForMapPos(rx, ry)
  MOAIThread.blockOnAction(self:seekLoc(x+128, y+120, duration))
end

function camera:updateLocForSamus(samus)
  if samus.status.busy then return end
  
  local sx, sy = samus.body:getPosition()
  local srx, sry = map_mgr.getCoordinatesInRoomForGlobalPos(sx, sy)
  local cx, cy = self:getLoc()
  local dx = 0
  local dy = 0

  local rx, ry = map_mgr.getMapPosForGlobalPos(sx, sy)

  local doors = map_mgr.getDoorsForMapPos(rx, ry)

  -- update camera pos
  if self.direction == 'x' then
    if sx > cx + 16 then
      dx = sx - cx - 16
      if doors and doors.right and srx > 144 then
        dx = 0
      end
    elseif sx < cx - 16 then
      dx = sx - cx + 16
      if doors and doors.left and srx < 112 then
        dx = 0
      end
    end
  elseif self.direction == 'y' then
    if sy > cy + 16 then
      dy = sy - cy - 16
    elseif sy < cy - 16 then
      dy = sy - cy + 16
    end
  end
  self:moveLoc(dx, dy)
end

function camera:moveRightRoom()
  self:correctLoc()
  MOAIThread.blockOnAction(self:moveLoc(256, 0, 1))
end

function camera:moveLeftRoom()
  self:correctLoc()
  MOAIThread.blockOnAction(self:moveLoc(-256, 0, 1))
end

function camera:correctLoc()
  local x,y = self:getLoc()

  local rx,ry = map_mgr.getMapPosForGlobalPos(x,y)

  self:seekRoomLoc(rx, ry, 0.1)
end

return camera
