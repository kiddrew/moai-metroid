-- scale set so screen is 20 meters tall
scale = 10

-- screen dimensions
Screen = {
    w = 1216,
    h = 760
}

-- stage dimensions
Stage = {
    w = 320,
    h = 200
}

-- open sim window
MOAISim.openWindow( 'platformer_test', Screen.w, Screen.h )

-- setup viewport
viewport = MOAIViewport.new()
viewport:setSize( Screen.w, Screen.h )
viewport:setScale( Stage.w, Stage.h )

-- setup Box2D world
world = MOAIBox2DWorld.new()
world:setGravity( 0, -10 )
world:setUnitsToMeters( 1 / scale )
world:setDebugDrawFlags( MOAIBox2DWorld.DEBUG_DRAW_SHAPES + MOAIBox2DWorld.DEBUG_DRAW_JOINTS +
                         MOAIBox2DWorld.DEBUG_DRAW_PAIRS + MOAIBox2DWorld.DEBUG_DRAW_CENTERS )

-- main rendering layer
layer = MOAILayer2D.new()
layer:setViewport( viewport )
layer:setBox2DWorld( world )

-- char code for fonts
charCode = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 _+-()[]{}|\/?.,<>!~`@#$%^&*\'":;'

-- to scale fonts
fontScale = Screen.h / Stage.h

-- status textbox
status = MOAITextBox.new()
status:setRect( -160 * fontScale, -100 * fontScale, 160 * fontScale, 100 * fontScale )
status:setScl( 1 / fontScale )
status:setYFlip( true )
status:setColor( 1, 1, 1 )
status:setString( 'status' )
status.font = MOAIFont.new()
status.font:load( '../resources/fonts/metroid.ttf' )
status.font:preloadGlyphs( charCode, math.ceil( 4 * fontScale ), 72 )
status:setFont( status.font )
layer2 = MOAILayer2D.new()
layer2:setViewport( viewport )
layer2:insertProp( status )

-- setup ground
ground = {}
ground.verts = {
    -160, 100,
    -160, 10,
    -120, 10,
    -120, -10,
    -15, -10,
    -15, 5,
    5, 5,
    20, 20,
    40, 20,
    40, -18,
    140, -18,
    140, 20,
    160, 20,
    160, 100
}
ground.body = world:addBody( MOAIBox2DBody.STATIC, 0, -60 )
ground.body.tag = 'ground'
ground.fixtures = {
    ground.body:addChain( ground.verts )
}
ground.fixtures[1]:setFriction( 0.3 )

-- setup player
player = {}
player.onGround = false
player.currentContactCount = 0
player.move = {
    left = false,
    right = false
}
player.platform = nil
player.doubleJumped = false
player.verts = {
    -5, 8,
    -5, -9,
    -4, -10,
    4, -10,
    5, -9,
    5, 8
}
player.body = world:addBody( MOAIBox2DBody.DYNAMIC )
player.body.tag = 'player'
player.body:setFixedRotation( true )
player.body:setMassData( 80 )
player.body:resetMassData()
player.fixtures = {
    player.body:addPolygon( player.verts ),
    player.body:addRect( -4.9, -10.1, 4.9, -9.9 )
}
player.fixtures[1]:setRestitution( 0 )
player.fixtures[1]:setFriction( 0 )
player.fixtures[2]:setSensor( true )

-- setup platforms
platforms = {}
platforms[1] = {}
platforms[1].body = world:addBody( MOAIBox2DBody.KINEMATIC, 70, -44 )
platforms[1].body.tag = 'platform'
platforms[1].body:setLinearVelocity( 20, 0 )
platforms[1].limits = {
    xMax = 130, xMin = 70,
    yMax = -43, yMin = -45 
}
platforms[1].fixtures = {
    platforms[1].body:addRect( -10, -4, 10, 4 )
}

platforms[2] = {}
platforms[2].body = world:addBody( MOAIBox2DBody.KINEMATIC, 50, -44 )
platforms[2].body.tag = 'platform'
platforms[2].body:setLinearVelocity( 0, 10 )
platforms[2].limits = {
    xMax = 51, xMin = 49,
    yMax = -44, yMin = -74
}
platforms[2].fixtures = {
    platforms[2].body:addRect( -10, -4, 10, 4 )
}

-- platform movement thread
platformThread = MOAIThread.new()
platformThread:run( function()
    while true do
        for k, v in ipairs( platforms ) do
            local x, y = v.body:getWorldCenter()
            local dx, dy = v.body:getLinearVelocity()
            if x > v.limits.xMax or x < v.limits.xMin then
                dx = -dx
            end
            if y > v.limits.yMax or y < v.limits.yMin then
                dy = -dy
            end
            v.body:setLinearVelocity( dx, dy )
        end
        coroutine.yield()
    end
end )

-- player foot sensor
function footSensorHandler( phase, fix_a, fix_b, arbiter )

    if phase == MOAIBox2DArbiter.BEGIN then
        player.currentContactCount = player.currentContactCount + 1
        if fix_b:getBody().tag == 'platform' then
            player.platform = fix_b:getBody()
        end
    elseif phase == MOAIBox2DArbiter.END then
        player.currentContactCount = player.currentContactCount - 1
        if fix_b:getBody().tag == 'platform' then
            player.platform = nil
        end
    end
    if player.currentContactCount == 0 then
        player.onGround = false
    else
        player.onGround = true
        player.doubleJumped = false
    end
end
player.fixtures[2]:setCollisionHandler( footSensorHandler, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END )

-- keyboard input handler
function onKeyboard( key, down )
    -- 'a' key
    if key == 97 then
        player.move.left = down
    -- 'd' key
    elseif key == 100 then
        player.move.right = down
    end
    
    -- jump
    if key == 119 and down and ( player.onGround or not player.doubleJumped ) then
        player.body:setLinearVelocity( player.body:getLinearVelocity(), 0 )
        player.body:applyLinearImpulse( 0, 80 )
        if not player.onGround then
            player.doubleJumped = true
        end
    end
end
MOAIInputMgr.device.keyboard:setCallback( onKeyboard )

-- player movement thread
playerThread = MOAIThread.new()
playerThread:run( function()
    while true do
        local dx, dy = player.body:getLinearVelocity()
        if player.onGround then
            if player.move.right and not player.move.left then
                dx = 50
            elseif player.move.left and not player.move.right then
                dx = -50
            else
                dx = 0
            end
        else
            if player.move.right and not player.move.left and dx <= 0 then
                dx = 25
            elseif player.move.left and not player.move.right and dx >= 0 then
                dx = -25
            end
        end
        if player.platform then
            dx = dx + player.platform:getLinearVelocity()
        end
        player.body:setLinearVelocity( dx, dy )
        coroutine.yield()
    end
end )

-- update function for status box
statusThread = MOAIThread.new()
statusThread:run( function()
    while true do
        local x, y = player.body:getWorldCenter()
        local dx, dy = player.body:getLinearVelocity()
        status:setString( 'x, y:   ' .. math.ceil( x ) .. ', ' .. math.ceil( y )
                     .. '\ndx, dy: ' .. math.ceil( dx ) .. ', ' .. math.ceil( dy )
                     .. '\nOn Ground: ' .. ( player.onGround and 'true' or 'false' )
                     .. '\nContact Count: ' .. player.currentContactCount
                     .. '\nPlatform: ' .. ( player.platform and 'true' or 'false' ) )
        coroutine.yield()
    end
end )

-- render scene and begin simulation
world:start()
MOAIRenderMgr.setRenderTable( { layer, layer2 } )
-- see http://www.moaisnippets.com/platformer-style-game-implemented-using-box2d-physics
