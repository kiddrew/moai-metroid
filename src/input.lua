module(..., package.seeall)

return {
  init = function(obj)
    MOAIInputMgr.device.keyboard:setCallback(
      function(key, is_down)
        if key == 119 then -- W
          obj:input('up', is_down)
        elseif key == 115 then -- S
          obj:input('down', is_down)
        elseif key == 97 then -- A
          obj:input('left', is_down)
        elseif key == 100 then -- D
          obj:input('right', is_down)
        elseif key == 46 then -- .
          obj:input('fire', is_down)
        elseif key == 47 then -- /
          obj:input('jump', is_down)
        elseif key == 45 then -- -
          obj:input('select', is_down)
        elseif key == 61 then -- =
          -- Pause game
        end
      end
    )
  end
}
