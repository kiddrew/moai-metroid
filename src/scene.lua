module ( ..., package.seeall )

local viewport, uiviewport
local scenes = {}

function setup ( _viewport, _uiviewport )
	viewport = _viewport
	uiviewport = _uiviewport
end

local function newInsertProp ( target, prop )
	target:oldInsertProp ( prop )
	table.insert ( target.props, prop )
end

function push ( sceneName )
	local s = MOAILayer2D.new ()
	table.insert ( scenes, s )
	s.name = sceneName
	s:setViewport ( viewport )
	s.props = {}
	s.oldInsertProp = s.insertProp
	s.insertProp = newInsertProp
	MOAISim.pushRenderPass ( s )

	local s2 = MOAILayer2D.new ()
	s2.name = sceneName
	s2:setViewport ( uiviewport )
	s2.props = {}
	s2.oldInsertProp = s2.insertProp
	s2.insertProp = newInsertProp
	MOAISim.pushRenderPass ( s2 )
	s.s2 = s2

	require ( sceneName ).new ( s )
end

function pop ()
	MOAISim.popRenderPass ()
	MOAISim.popRenderPass ()

	local num = #scenes
	local s = scenes[num]
	for i = 1, #s.props do
		s.props[i] = nil
	end

	s:clear ()
	s = nil
	table.remove ( scenes, num )
	MOAISim:forceGarbageCollection ()
end

function swap ( sceneName )
	pop ()
	push ( sceneName )
end
