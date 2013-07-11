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
      tmp[i][j] = -1
    end
  end

  return tmp
end

MOAISim.openWindow ("Metroid", window.width*scale, window.height*scale)

MOAIUntzSystem.initialize()

_G.viewport = MOAIViewport.new()
viewport:setSize (window.width*scale, window.height*scale)
viewport:setScale (window.width, window.height)

_G.fb = MOAIGfxDevice:getFrameBuffer()
fb:setClearColor(0,0,0)

_G.camera = MOAICamera2D.new()
camera:setLoc(0, 0)

layer = MOAILayer2D.new()
layer:setViewport(viewport)
layer:showDebugLines(debug)
MOAISim.pushRenderPass(layer)

background_layer = MOAILayer2D.new()
background_layer:setViewport(viewport)
background_layer:showDebugLines(debug)
MOAISim.pushRenderPass(background_layer)

layer:setCamera(camera)
background_layer:setCamera(camera)

_G.music = require 'music'
music.init ()

_G.sounds = require 'sounds'
sounds.setVolume (1)

local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-? "
_G.font = MOAIFont:new ()
font:loadFromTTF ('../resources/fonts/metroid.ttf', chars, 4, 163)

_G.collision = require('collision')
_G.gameObjects = {}

_G.map = require('map')
_G.room_data = require('data/rooms')
_G.structure = require('structure')
_G.tile_data = require('data/tiles')

_G.background = MOAIGrid.new()
background:initRectGrid(16,15,16,16)

local backgroundTiles = MOAITileDeck2D.new()
backgroundTiles:setTexture('../resources/images/tiles.png')
backgroundTiles:setSize(16,36)

local background_prop = MOAIProp2D.new()
background_prop:setDeck(backgroundTiles)
background_prop:setGrid(background)
background_prop:setLoc(-256/2,-240/2)
background_layer:insertProp(background_prop)

_G.ppu = initializeGrid(15, 16)

function getTileIndex(tid, pid)
  if tile_data[tid] then
    local offset = 0
    if pid == '03' or pid == '01' then -- blue
      offset = 0
    elseif pid == '02' then -- yellow
      offset = 0x40
    elseif pid == '01' then -- green
      offset = 0x80
    end
    return (tile_data[tid].tid + offset)
  end
end

function getRoomGrid(index)
  local grid = initializeGrid(15, 16)

  local d = room_data[tonumber(index,16)+1]
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

    structure.drawToGrid(grid, y, x, sid, pid)
  end

  return grid
end

function setBackgroundGrid()
  for r, row in pairs(ppu) do
    local tmp = initializeGrid(15,16)
    for c, tid in pairs(row) do
        if tid > 0 then
          tmp[c] = tid
          local platform = {}
          platform.body = world:addBody(MOAIBox2DBody.STATIC, -144+c*16, 120-r*16)
          platform.fixture = platform.body:addRect(0,0,16,16)
          platform.fixture.id = 'ground'
          platform.fixture.body = platform.body
        elseif tid ~= -1 then
          local textbox = MOAITextBox.new()
          textbox:setString(tostring(tid))
          textbox:setFont(font)
          textbox:setRect(0,0,16,16)
          textbox:setLoc(-144+c*16, 120-r*16)
          textbox:setYFlip(true)
          background_layer:insertProp(textbox)
        end
    end
    background:setRow(16-r,tmp[1],tmp[2],tmp[3],tmp[4],tmp[5],tmp[6],tmp[7],tmp[8],tmp[9],tmp[10],tmp[11],tmp[12],tmp[13],tmp[14],tmp[15],tmp[16])
  end
end

function insertGameObject(obj)
  table.insert(gameObjects, obj)
end

world = MOAIBox2DWorld.new()
world:setGravity(0,-10)
world:setUnitsToMeters(1/30)
world:start()
layer:setBox2DWorld(world)

-- floor placeholder
--staticBody = world:addBody(MOAIBox2DBody.STATIC, 0, -120)
--ground = staticBody:addRect(-128,0,128,31.9)
--ground.id = 'platform'

_G.Samus = require('samus').Samus:new()
insertGameObject(Samus)

require 'input'

_G.SamusView = require('samus_view').SamusView:new(Samus)

start_room = map.getRoomIndex(Samus.map_pos.x, Samus.map_pos.y)
print("start room: "..start_room)
ppu = getRoomGrid(start_room)
setBackgroundGrid()

Samus:stand()

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

      -- adjust camera position
      if obj.id == 'samus' then
        local sx, sy = obj.body:getPosition()
        local cx, cy = camera:getLoc()
        if sx > cx + 16 then
          cx = sx - 16
        elseif sx < cx - 16 then
          cx = sx + 16
        end
        camera:setLoc(cx, cy)
      end
    end
    coroutine.yield()
  end 
end)
