_G._ = require 'underscore'

_G.simTimeFactor = 1
MOAISim.setStep(simTimeFactor / MOAISim.DEFAULT_STEPS_PER_SECOND)

_G.scale = 2
_G.window = {width = 256, height = 240}

MOAISim.openWindow ("Metroid", window.width*scale, window.height*scale)

MOAIUntzSystem.initialize()

_G.viewport = MOAIViewport.new()
viewport:setSize (window.width*scale, window.height*scale)
viewport:setScale (window.width, window.height)

_G.camera = MOAICamera2D.new()
camera = MOAICamera.new()
camera:setLoc(0, 0, camera:getFocalLength(256))

layer = MOAILayer2D.new()
layer:setViewport(viewport)
MOAISim.pushRenderPass(layer)

background_layer = MOAILayer2D.new()
background_layer:setViewport(viewport)
MOAISim.pushRenderPass(layer)

_G.music = require 'music'
music.init ()

_G.sounds = require 'sounds'
sounds.setVolume (1)

_G.collision = require('collision')
_G.gameObjects = {}

_G.map_data = require('data/map')
_G.room_data = require('data/rooms')
_G.structure_data = require('data/structures')

_G.map = MOAIGrid.new()
map:initRectGrid(16,15,16,16)

local mapTiles = MOAITileDeck2D.new()
mapTiles:setTexture('../resources/tiles.png')
mapTiles:setSize(16,36)

function insertGameObject(obj)
  table.insert(gameObjects, obj)
end

local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-? "
font = MOAIFont:new ()
font:loadFromTTF ('../resources/fonts/metroid.ttf', chars, 4, 163)

world = MOAIBox2DWorld.new()
world:setGravity(0,-10)
world:setUnitsToMeters(1/30)
world:start()
layer:setBox2DWorld(world)

staticBody = world:addBody(MOAIBox2DBody.STATIC, 0, -120)
ground = staticBody:addRect(-128,0,128,32)
ground.id = 'platform'

_G.Samus = require('samus').Samus:new()
insertGameObject(Samus)

require 'input'

_G.SamusView = require('samus_view').SamusView:new(Samus)

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
    end
    coroutine.yield()
  end 
end)
