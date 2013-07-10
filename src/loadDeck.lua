local inspect = require 'inspect'

module ( ..., package.seeall )

function loadDeck ( filename, lookup )
	local texture = MOAITexture.new ()
	texture:load ( filename )
	texture:setWrap ( false )
	local width, height = texture:getSize ()

	local deck = MOAIGfxQuadListDeck2D.new ()
	deck:setTexture ( texture )

	local n = 0
	local frameCount = 0
	for name, data in pairs ( lookup ) do
		n = n + ( data.frames or 1 )
		if ( data.frames or 1 ) > 1 then
			frameCount = frameCount + ( data.frames or 1 )
		end
	end

	local remapper = MOAIDeckRemapper.new ()
	remapper:reserve ( n )

	deck:reserveQuads ( n )
	deck:reserveUVQuads ( n )
	deck:reservePairs ( n )
	deck:reserveLists ( n )

	local image = {width = width, height = height}
	local idx = 1
	function setupThing ( name )
		local item = lookup[name]
		local firstIdx = idx
		for i = 1, ( item.frames or 1 ) do
			local j = idx + i - 1
			local offs = {0, 0}
			if item.offs then
				offs = item.offs[i]
			end
			deck:setRect ( j, 
				-item.view.anchor[1] + offs[1], 
				-item.view.anchor[2] + offs[2], 
				item.view.size[1] - item.view.anchor[1] + offs[1],
				item.view.size[2] - item.view.anchor[2] + offs[2]
			)
			deck:setUVRect ( j, 
				(item.image.pos[1] + item.image.size[1] * (i - 1)) * item.gridsize / image.width, 
				item.image.pos[2] * item.gridsize / image.height, 
				(item.image.pos[1] + item.image.size[1] * i) * item.gridsize / image.width, 
				(item.image.pos[2] + item.image.size[2]) * item.gridsize / image.height 
			)
			deck:setPair ( j, j, j )
			deck:setList ( j, j, 1 )
		end
		local anim = nil
		if ( item.frames or 1 ) > 1 and item.anim then
			local function makeAnim ( remapper )
				local loop = true
				if item.loop ~= nil then
					loop = item.loop
				end

				if not remapper then
					remapper = MOAIDeckRemapper.new ()
					remapper:reserve ( n )
				end

				local curve = MOAIAnimCurve.new ()
				curve:reserveKeys ( #item.anim )
				for i = 1, #item.anim do
					curve:setKey ( i, seconds ( item.anim[i][1] * item.duration ), firstIdx + item.anim[i][2] - 1, MOAIEaseType.FLAT )
				end
				if loop then
					curve:setWrapMode ( MOAIAnimCurve.APPEND )
				end

				anim = MOAIAnim.new ()
				anim:reserveLinks ( 1 )
				anim:setLink ( 1, curve, remapper, firstIdx )
				if loop then
					anim:setMode ( MOAITimer.LOOP )
				end
				anim:start ()
				return remapper, anim
			end
			makeAnim ( remapper )
			item.makeAnim = makeAnim
		end
		item.impl = {
			idx = firstIdx,
			anim = anim,
		}
		idx = idx + ( item.frames or 1 )
	end

	for name, data in pairs ( lookup ) do
		setupThing ( name )
	end

	local function prop ( name, startAnim )
		local def = lookup[name]
		local _remapper, anim
		if startAnim then
			_remapper, anim = def.makeAnim ()
		else
			_remapper = remapper
		end
		local prop = MOAIProp2D.new ()
		prop:setDeck ( deck )
		prop:setIndex ( def.impl.idx )
		prop:setRemapper ( _remapper )
		return {
			prop = prop,
			anim = anim,
			def = def,
		}
	end

	return {
		deck = deck,
		remapper = remapper,
		lookup = lookup,
		prop = prop,
	}
end

return {loadDeck = loadDeck}
