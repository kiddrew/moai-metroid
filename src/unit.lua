function setupObjGfx(unit, data, name)
  if not unit.deckcache then
    unit.deckcache = {}
  elseif unit.deckcache[name] then
    return unit.deckcache[name]
  end

  if not unit.animcache then
    unit.animcache = {}
  end
  if unit.animcache[name] then
    return unit.animcache[name]
  end

  local gfxData = data[name]

  local deck = MOAITileDeck2D.new()
  deck:setTexture(gfxData.texture)
  deck:setSize(gfxData.size[1],gfxData.size[2])
  if gfxData.rect then
    deck:setRect(gfxData.rect[1],gfxData.rect[2],gfxData.rect[3],gfxData.rect[4])
  else
    deck:setRect(-16,-1,16,31)
  end

  unit.deckcache[name] = deck

  if gfxData.frames then
    print("setting up curve for: "..name)
    local frames = gfxData.frames
    local curve = MOAIAnimCurve:new()
    curve:reserveKeys(#frames)
    for i = 1, #frames do
      curve:setKey(i, gfxData.anim_step*(i-1), frames[i], MOAIEaseType.FLAT)
    end
  
    function nextState()
      unit.parent:action(gfxData.next_state)
    end

    function remove()
      print "remove prop"
      unit:remove()
    end

    function cancel()
      unit:cancel(name)
    end
  
    print("setting up anim for: "..name)
    local anim = MOAIAnim:new()
    anim:reserveLinks(1)
    anim:setLink(1, curve, unit.prop, MOAIProp2D.ATTR_INDEX)
    if gfxData.loop then
      anim:setMode(MOAITimer.LOOP)
    end
    if gfxData.next_state then
      anim:setListener(MOAIAction.EVENT_STOP, nextState)
    end
    if gfxData.on_complete then
      print "on_complete"
      if gfxData.on_complete == 'remove' then
        print "setting up remove event"
        anim:setListener(MOAIAction.EVENT_STOP, remove)
      elseif gfxData.on_complete == 'cancel' then
        print "setting up cancel event"
        anim:setListener(MOAIAction.EVENT_STOP, cancel)
      end
    end

    unit.animcache[name] = anim
  end
end
