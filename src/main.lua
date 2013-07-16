_G._ = require 'underscore'

_G.simTimeFactor = 1
MOAISim.setStep(simTimeFactor / MOAISim.DEFAULT_STEPS_PER_SECOND)

_G.scale = 2
_G.window = {width = 256, height = 240}
_G.debug = false

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function initializeGrid(rows, cols)
  local tmp = {}
  for i=1,rows do
    tmp[i] = {}
    for j=1,cols do
      tmp[i][j] = 0
    end
  end

  return tmp
end

function rprint(table)
  for k,v in ipairs(table) do
    if type(v) == 'table' then
      rprint(v)
    end

    print(v)
  end
end

MOAISim.openWindow ("Metroid", window.width*scale, window.height*scale)

_G.input = require 'input'

_G.viewport = MOAIViewport.new()
viewport:setSize (window.width*scale, window.height*scale)
viewport:setScale (window.width, window.height)

MOAIUntzSystem.initialize()
_G.music = require 'music'
music.init ()
_G.sounds = require 'sounds'
sounds.setVolume (1)

local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-? "
_G.font = MOAIFont:new ()
font:loadFromTTF ('../resources/fonts/metroid.ttf', chars, 4, 163)

_G.camera = require('camera')

p_layer = MOAILayer2D.new()
p_layer:setViewport(viewport)
p_layer:setCamera(camera)
p_layer:showDebugLines(debug)
MOAISim.pushRenderPass(p_layer)

m_layer = MOAILayer2D.new()
m_layer:setViewport(viewport)
m_layer:setCamera(camera)
m_layer:showDebugLines(debug)
MOAISim.pushRenderPass(m_layer)

world = MOAIBox2DWorld.new()
world:setGravity(0,-10)
world:setUnitsToMeters(1/30)
world:start()
p_layer:setBox2DWorld(world)

_G.map_mgr = require('map_mgr')
_G.room = require('room_mgr')
map_mgr.init()

_G.collision = require('collision')
_G.gameObjects = {}

camera:setRoomLoc(4, 15)
--camera:setLoc(1000,8)

_G.ppu = initializeGrid(15, 16)

--[[
function setBackgroundGrid(ppu)
  for r, row in pairs(ppu) do
    local tmp = {}
    for c, tid in pairs(row) do
        local poly = tile.getPoly(tid)
        if tid > 0 then
          tmp[c] = tid
          if poly ~= -1 then
            local platform = {}
            platform.body = world:addBody(MOAIBox2DBody.STATIC, -144+c*16, 120-r*16)
            platform.fixture = platform.body:addPolygon(poly)
            platform.fixture.id = 'floor'
          end
        end
        if debug then
          local textbox = MOAITextBox.new()
          textbox:setString(string.format('%X', tid))
          textbox:setFont(font)
          textbox:setRect(0,0,16,16)
          textbox:setLoc(-144+c*16, 120-r*16)
          textbox:setYFlip(true)
          m_layer:insertProp(textbox)
        end
    end
    background:setRow(16-r,tmp[1],tmp[2],tmp[3],tmp[4],tmp[5],tmp[6],tmp[7],tmp[8],tmp[9],tmp[10],tmp[11],tmp[12],tmp[13],tmp[14],tmp[15],tmp[16])
  end
end
]]--

function insertGameObject(obj)
  table.insert(gameObjects, obj)
end

_G.Samus = require('samus').Samus:new()
input.init(Samus)
insertGameObject(Samus)

_G.SamusView = require('samus_view').SamusView:new(Samus)

map_mgr:populateRoomFloor(Samus.map_pos.x, Samus.map_pos.y)

Samus:spawn()

gameLoop = MOAIThread.new()
gameLoop:run(function()
  while true do
    for k, obj in pairs(gameObjects) do
      local dx, dy = obj.body:getLinearVelocity()

      if obj.move.right and not obj.move.left then
        dx = obj.speed
      elseif obj.move.left and not obj.move.right then
        dx = obj.speed * -1
      elseif obj.friction.x then
        dx = 0
      end

      if obj.move.up and not obj.move.down then
        dy = obj.speed
      elseif obj.move.down and not obj.move.up then
        dy = obj.speed * -1
      elseif obj.friction.y then
        dy = 0
      end
  
      obj.body:setLinearVelocity(dx, dy)

      -- update Samus
      if obj.id == 'samus' then
        local sx, sy = obj.body:getPosition()
        local srx, sry = map_mgr.getCoordinatesInRoom(sx, sy)
        local cx, cy = camera:getLoc()
        local dx = 0
        local dy = 0

        -- update Samus map pos
        local rx, ry = map_mgr.getMapPosFromGlobalLoc(sx, sy)
        Samus.map_pos.x = rx
        Samus.map_pos.y = ry

        -- update camera pos
        if camera.direction == 'x' then
          if sx > cx + 16 then
            dx = sx - cx - 16
          elseif sx < cx - 16 then
            dx = sx - cx + 16
          end

          if srx < 32 then
            -- populate room left
            map_mgr:populateRoom(rx-1, ry)
          elseif srx > 224 then
            -- populate room right
            map_mgr:populateRoom(rx+1, ry)
          end
        elseif camera.direction == 'y' then
          if sy > cy + 16 then
            dy = sy - cy - 16
          elseif sy < cy - 16 then
            dy = sy - cy + 16
          end

          if sry < 32 then
            -- populate room up
            map_mgr:populateRoom(rx, ry-1)
          elseif sry > 208 then
            -- populate room down
            map_mgr:populateRoom(rx, ry+1)
          end
        end
        camera:moveLoc(dx, dy)
      end

    end
    coroutine.yield()
  end 
end)
