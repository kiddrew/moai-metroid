module(..., package.seeall)

function handler(phase, fix_a, fix_b, arbiter)
--  print("collision: "..fix_a.id.." vs "..fix_b.id)
  if phase == MOAIBox2DArbiter.BEGIN then
    -- begin collision
    fix_a:getBody().parent:onCollision(fix_a, fix_b)
    if fix_b:getBody().parent then
      fix_b:getBody().parent:onCollision(fix_b, fix_a)
    end
  elseif phase == MOAIBox2DArbiter.END then
    -- end collision
    fix_a:getBody().parent:endCollision(fix_a, fix_b)
    if fix_b:getBody().parent then
      fix_b:getBody().parent:endCollision(fix_b, fix_a)
    end
  end
end

