module ( ..., package.seeall )

local soundFiles = require('data/soundFiles')

local sounds = {}
local volume = 1

-- cache the files
for name, file in pairs ( soundFiles ) do
	local untz = MOAIUntzSound.new ()
	untz:load ( '../resources/sounds/' .. file )
	untz:setVolume ( volume )
	untz:setLooping ( false )

	local sound = {
		untz = untz,
	}
--	sounds[name] = {}
  sounds[name] = {
    untz = untz,
  }
end

return {
	play = function ( name, looping )
    looping = looping or false
    local untz = sounds[name].untz
    untz:setLooping(looping)
    untz:play()
    return {
      untz = untz
    }
    --[[
		local file = soundFiles[name]
		local untz = MOAIUntzSound.new ()
		untz:load ( '../resources/sounds/' .. file )
		untz:setVolume ( volume )
		untz:setLooping ( false )
		untz:play ()
		local sound = {
			untz = untz,
		}
		return sound
    ]]--
	end,
	setVolume = function ( value )
		volume = value
	end
}
