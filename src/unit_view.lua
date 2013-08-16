module(..., package.seeall)

UnitView = {}

function UnitView:new(parent)
  local this = setmetatable({
    parent = parent,
    deck_row = 1,
  }, {__index = UnitView})
end

function UnitView:setupObjGfx(unit, data, name, deck_row)
  deck_row = deck_row or 1

  if not unit.deckcache then
    unit.deckcache = {}
  end

  if not unit.animcache then
    unit.animcache = {}
  end

  local gfxData = data[name]

  local deck = unit.deckcache[name]

  if not deck then
    deck = MOAITileDeck2D.new()
    deck:setTexture(gfxData.texture)
    deck:setSize(gfxData.size[1],gfxData.size[2])
    if gfxData.rect then
      deck:setRect(gfxData.rect[1],gfxData.rect[2],gfxData.rect[3],gfxData.rect[4])
    else
      deck:setRect(-16,-1,16,31)
    end

    unit.deckcache[name] = deck
  end

  if gfxData.frames then
    local frames = gfxData.frames
    local curve = MOAIAnimCurve:new()
    curve:reserveKeys(#frames)
    local frame_count = #frames
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

    unit.anim = anim
  end

  unit.prop:setDeck(deck)
  unit.prop:setIndex(1+gfxData.size[1]*(deck_row-1))
end

return UnitView
