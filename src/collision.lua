module(..., package.seeall)

function handler(phase, fix_a, fix_b, arbiter)
  if phase == MOAIBox2DArbiter.BEGIN then
    -- begin collision
    fix_a:getBody().parent:onCollision(fix_a, fix_b)
  elseif phase == MOAIBox2DArbiter.END then
    -- end collision
    fix_a:getBody().parent:endCollision(fix_a, fix_b)
  end
end

