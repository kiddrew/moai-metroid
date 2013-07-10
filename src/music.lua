module (..., package.seeall)

local volume = 0.25
local bg = nil
local playing = false

local _M = {}

function _M.init ()
  bg = MOAIUntzSound.new ()
  bg:setVolume ( volume )
  bg:setLooping ( true )
end

function _M.pause ()
  bg:pause ()
  playing = false
end

function _M.stop ()
  bg:stop ()
  playing = false
end

function _M.play ( song )
  bg:load ( '../resources/music/' .. song )
  bg:play ()
  playing = true
end

return _M
