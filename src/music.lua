module (..., package.seeall)

local musicFiles = require('data/musicFiles')

local volume = 0.25
local bg = nil
local playing = false
local song

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
  print("bg:load "..song)
  bg:load ( '../resources/music/' .. musicFiles[song] )
  print "bg:play"
  bg:play ()
  playing = true
  song = song
end

function _M.interrupt ( new_song )
  local old_song = song
  bg:stop()
  print "song stopped"
  bg:setLooping(false)
  print "looping false"
  _M.play(new_song)
  print "_M.play"
  local thread = MOAICoroutine.new()
  thread:run( function()
    while bg:isPlaying() do
      coroutine.yield()
    end
  end )
  bg:setLooping(true)
  _M.play(old_song)
end

return _M
