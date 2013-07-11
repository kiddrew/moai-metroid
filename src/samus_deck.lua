local x = 0
local y = 0

---------------------------
-- Animation curves
---------------------------

-- 2 frames
curve2 = MOAIAnimCurve.new()
curve2:reserveKeys(3)
curve2:setKey(1, 0.0000, 1, MOAIEaseType.FLAT)
curve2:setKey(2, 0.0467, 2, MOAIEaseType.FLAT)
curve2:setKey(3, 0.0934, 3, MOAIEaseType.FLAT)

-- 3 frames
curve3 = MOAIAnimCurve.new()
curve3:reserveKeys(4)
curve3:setKey(1, 0.0000, 1, MOAIEaseType.FLAT)
curve3:setKey(2, 0.0467, 2, MOAIEaseType.FLAT)
curve3:setKey(3, 0.0934, 3, MOAIEaseType.FLAT)
curve3:setKey(4, 0.1400, 1, MOAIEaseType.FLAT)

-- 4 frames
curve4 = MOAIAnimCurve.new()
curve4:reserveKeys(5)
curve4:setKey(1, 0.000, 1, MOAIEaseType.FLAT)
curve4:setKey(2, 0.035, 2, MOAIEaseType.FLAT)
curve4:setKey(3, 0.070, 3, MOAIEaseType.FLAT)
curve4:setKey(4, 0.105, 4, MOAIEaseType.FLAT)
curve4:setKey(5, 0.140, 1, MOAIEaseType.FLAT)

-- Spawn
spawn_curve = MOAIAnimCurve.new()
spawn_curve:reserveKeys(5)
spawn_curve:setKey(1, 0.00, 1, MOAIEaseType.FLAT)
spawn_curve:setKey(2, 1.50, 2, MOAIEaseType.FLAT)
spawn_curve:setKey(3, 3.00, 3, MOAIEaseType.FLAT)
spawn_curve:setKey(4, 4.50, 4, MOAIEaseType.FLAT)
spawn_curve:setKey(5, 6.00, 5, MOAIEaseType.FLAT)

---------------------------
-- Decks
---------------------------

-- Spawn
samusSpawn = MOAITileDeck2D.new()
samusSpawn:setTexture('../resources/images/samus_spawn.png')
samusSpawn:setSize(5,2)
samusSpawn:setRect(-16,0,16,32)

-- Stand
samusStand = MOAITileDeck2D.new()
samusStand:setTexture('../resources/images/samus_stand.png')
samusStand:setSize(1,4)
samusStand:setRect(-16,0,16,32)

-- Jump
samusJump = MOAITileDeck2D.new()
samusJump:setTexture('../resources/images/samus_jump.png')
samusJump:setSize(2,4)
samusJump:setRect(-16,0,16,32)

-- Flip
samusFlip = MOAITileDeck2D.new()
samusFlip:setTexture('../resources/images/samus_flip.png')
samusFlip:setSize(4,4)
samusFlip:setRect(-16,0,16,32)

-- Run
samusRun = MOAITileDeck2D.new()
samusRun:setTexture('../resources/images/samus_run.png')
samusRun:setSize(4,4)
samusRun:setRect(-16,0,16,32)

-- Duck into ball
samusDuck = MOAITileDeck2D.new()
samusDuck:setTexture('../resources/images/samus_duck_into_ball.png')
samusDuck:setSize(2,1)
samusDuck:setRect(-16,0,16,32)

-- Come out of ball
-- TODO

-- Roll
samusRoll = MOAITileDeck2D.new()
samusRoll:setTexture('../resources/images/samus_roll.png')
samusRoll:setSize(4,4)
samusRoll:setRect(-16,0,16,32)

-- Aim up (top only)
samusAimUp = MOAITileDeck2D.new()
samusAimUp:setTexture('../resources/images/samus_aimup_top.png')
samusAimUp:setSize(1,4)
samusAimUp:setRect(-16,0,16,32)

-- Fire (top only)
samusFire = MOAITileDeck2D.new()
samusFire:setTexture('../resources/images/samus_fire_top.png')
samusFire:setSize(1,4)
samusFire:setRect(-16,0,16,16)

---------------------------
-- Build prop
---------------------------

local samus_prop = MOAIProp2D.new()
local samus_child_prop = MOAIProp2D.new()
samus_child_prop:setParent(samus_prop)
samus_prop:setLoc(x-16,y)
samus_child_prop:setLoc(0,16)

layer:insertProp(samus_prop)
layer:insertProp(samus_child_prop)

-- Main prop
samus_prop:setDeck(samusRun)

anim = MOAIAnim:new()
anim:reserveLinks(1)
anim:setLink(1, curve3, samus_prop, MOAIProp2D.ATTR_INDEX)
anim:setMode(MOAITimer.LOOP)

anim:start()

-- Child
samus_child_prop:setDeck(samusAimUp)



