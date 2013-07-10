module ( ..., package.seeall )

local soundFiles = {
  jump = 'jump.wav'
}

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
	sounds[name] = {}
end

return {
	sounds = sounds,
	play = function ( name )
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
	end,
	setVolume = function ( value )
		volume = value
	end
}
