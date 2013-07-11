module(..., package.seeall)

function handler(phase, fix_a, fix_b, arbiter)
  if phase == MOAIBox2DArbiter.BEGIN then
    -- begin collision
    if fix_a.parent then
      fix_a.parent:onCollision(fix_a, fix_b)
    end
    if fix_b.parent then
      fix_b.parent:onCollision(fix_b, fix_a)
    end
  elseif phase == MOAIBox2DArbiter.END then
    -- end collision
    if fix_a.parent then
      fix_a.parent:endCollision(fix_a, fix_b)
    end
    if fix_b.parent then
      fix_b.parent:endCollision(fix_b, fix_a)
    end
  end
end

