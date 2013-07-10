MOAIInputMgr.device.keyboard:setCallback(
  function(key, is_down)
    if key == 119 then -- W
      Samus:input('up', is_down)
    elseif key == 115 then -- S
      Samus:input('down', is_down)
    elseif key == 97 then -- A
      Samus:input('left', is_down)
    elseif key == 100 then -- D
      Samus:input('right', is_down)
    elseif key == 46 then -- .
      Samus:input('fire', is_down)
    elseif key == 47 then -- /
      Samus:input('jump', is_down)
    elseif key == 45 then -- -
      Samus:input('select', is_down)
    elseif key == 61 then -- =
      -- Pause game
    end
  end
)
