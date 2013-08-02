module (..., package.seeall)

local music_files = require('data/music_files')

local volume = 0.25
local bg = nil
local playing = false
local song

local _M = {}

function _M.init ()
  bg = MOAIUntzSound.new ()
  bg:setVolume ( volume )
  bg:setLooping ( true )
  for k,v in pairs(music_files) do
    bg:load('../resources/music/' .. music_files[k].file)
  end
end

function _M.pause ()
  bg:pause ()
  playing = false
end

function _M.stop ()
  bg:stop ()
  playing = false
end

function _M.play ( new_song )
  bg:load ( '../resources/music/' .. music_files[new_song].file )
  bg:setLooping(true)
  bg:setLoopPoints(0, music_files[new_song].loop_point)
  bg:play ()
  playing = true
  song = new_song
end

function _M.interrupt ( new_song )
  local old_song = song
  local thread = MOAICoroutine.new()
  bg:setLooping(false)
  bg:setLoopPoints(0, music_files[new_song].loop_point)
  thread:run( function()
    bg:load('../resources/music/'..music_files[new_song].file)
    bg:play()

    while bg:isPlaying() do
      coroutine:yield()
    end

    bg:setLooping(true)
    _M.stop()
    _M.play(old_song)
  end )
end

function _M.isPlaying()
  return bg:isPlaying()
end

return _M
