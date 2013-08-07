function setupObjGfx(unit, data, name, deck_row)
  deck_row = deck_row or 1

  if not unit.deckcache then
    unit.deckcache = {}
  elseif unit.deckcache[name] then
--    return unit.deckcache[name]
  end

  if not unit.animcache then
    unit.animcache = {}
  elseif unit.animcache[name] then
--    return unit.animcache[name]
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
    local frames = gfxData.frames
    local curve = MOAIAnimCurve:new()
    curve:reserveKeys(#frames)
    local frame_count = #frames
    print("frame count "..frame_count)
    print("deck row "..deck_row)
    for i = 1, frame_count do
      curve:setKey(i, gfxData.anim_step*(i-1), frames[i]+gfxData.size[1]*(deck_row-1), MOAIEaseType.FLAT)
    end
  
    function nextState()
      unit.parent:action(gfxData.next_state)
    end

    function remove()
      unit:remove()
    end

    function cancel()
      unit:cancel(name)
    end
  
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
      if gfxData.on_complete == 'remove' then
        anim:setListener(MOAIAction.EVENT_STOP, remove)
      elseif gfxData.on_complete == 'cancel' then
        anim:setListener(MOAIAction.EVENT_STOP, cancel)
      end
    end

--    unit.animcache[name] = anim
    unit.anim = anim
  end

  unit.prop:setDeck(deck)
  unit.prop:setIndex(1+gfxData.size[1]*(deck_row-1))
end
