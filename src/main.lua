_G._ = require 'underscore'

_G.simTimeFactor = 1
MOAISim.setStep(simTimeFactor / MOAISim.DEFAULT_STEPS_PER_SECOND)

_G.scale = 3
_G.window = {width = 256, height = 240}
_G.debug = false
_G.sound_enabled = true
_G.input = require 'input'
_G.camera = require 'camera'
_G.paused = false

require 'helpers'

_G.viewport = MOAIViewport.new()
viewport:setSize (window.width*scale, window.height*scale)
viewport:setScale (window.width, window.height)

MOAIUntzSystem.initialize()
_G.music = require 'music'
music.init ()
_G.sounds = require 'sounds'
sounds.setVolume (1)

local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-? "
--_G.font = MOAIFont:new ()
--font:loadFromTTF ('../resources/fonts/metroid.ttf', chars, 4, 163)

MOAISim.openWindow ("Metroid", window.width*scale, window.height*scale)

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

h_layer = MOAILayer2D.new()
h_layer:setViewport(viewport)
MOAISim.pushRenderPass(h_layer)

world = MOAIBox2DWorld.new()
world:setGravity(0,-10)
world:setUnitsToMeters(1/30)
world:start()
p_layer:setBox2DWorld(world)

_G.map_mgr = require('map_mgr')
_G.item_mgr = require('item_mgr')
_G.tile_mgr = require('tile_mgr')
_G.room_mgr = require('room_mgr')
_G.fixture_map = require('fixture_map')
_G.tile_map = require('tile_map')
tile_map:init()

_G.collision = require('collision')
_G.gameObjects = {}

function insertGameObject(obj)
  table.insert(gameObjects, obj)
end

_G.Samus = require('samus').Samus.init()
input.init(Samus)
_G.hud = require('hud'):new(Samus)
insertGameObject(Samus)
camera:setRoomLoc(Samus.map_pos.x, Samus.map_pos.y)

fixture_map:populateRoom(Samus.map_pos.x, Samus.map_pos.y)

Samus:spawn()

gameLoop = MOAIThread.new()
gameLoop:run(function()
  while true do
    for k, obj in pairs(gameObjects) do
      if not obj.body then
        -- cleanup
        table.remove(gameObjects, k)
      else
        local dx, dy = obj.body:getLinearVelocity()
  
        -- update body velocity
        if not obj.status.busy then
          -- normal body movement
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

        obj:updateWorld()
      end
    end
    coroutine.yield()
  end 
end)
