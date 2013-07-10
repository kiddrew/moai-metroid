module ( ..., package.seeall )

local _M = {}

_M.levels = {
	info = 1,
	debug = 2,
	warn = 3,
	error = 4,
	fatal = 5,
	none = 6,
}

_M.level = _M.levels.info

function _M.info () 
	return _M.level <= _M.levels.info
end

function _M.debug () 
	return _M.level <= _M.levels.debug
end

function _M.warn () 
	return _M.level <= _M.levels.warn
end

function _M.error () 
	return _M.level <= _M.levels.error
end

function _M.fatal () 
	return _M.level <= _M.levels.fatal
end

return {
	levels = _M.levels,
	setLevel = function ( _level ) _M.level = _level end,
	print = print,
	info = function ( ... ) if _M.info () then print ( arg ) end end,
	debug = function ( ... ) if _M.debug () then print ( arg ) end end,
	warn = function ( ... ) if _M.warn () then print ( arg ) end end,
	error = function ( ... ) if _M.error () then print ( arg ) end end,
	fatal = function ( ... ) if _M.fatal () then print ( arg ) end end,
}
