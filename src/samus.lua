local View = require('samus_view').SamusView

module ( ..., package.seeall)

Samus = {}
Samus_mt = {__index = Samus}

function Samus:new ()
  local this = setmetatable({
    id = 'samus',
    health = 99,
    missiles = 0,
    speed = 85,
    floor_y = nil,
    map_pos = {
      x = 6,
      y = 15,
    },
    friction = {
      x = false,
      y = false,
    },
    button = {
      up = false,
      down = false,
      left = false,
      right = false,
      fire = false,
      jump = false,
      select = false,
    },
    move = {
      right = false,
      left = false,
      down = false,
    },
    status = {
      busy = false,
      action = nil, -- spawn, stand, run, roll, jump, flip
      missile_mode = false,
      in_ball = nil,
      aiming_up = false,
      on_floor = false,
      floor_contacts = 0,
      ball_sensor_contacts = 0,
      door_contacts = 0,
      lava_contacts = 0,
      facing = 'right',
      in_door = false,
      firing = false,
      lava_contact = 0,
    }
  }, Samus_mt)

  this.gear = {
    energy_tanks = energy_tanks or {},
    missiles = missiles or {},
    ball = ball or false,
    bomb = bomb or false,
    longbeam = longbeam or false,
    icebeam = icebeam or false,
    wavebeam = wavebeam or false,
    boots = boots or false,
    varia = varia or false,
    screw = screw or false,
    bomb_cache = {
    },
  }

  this.fixture_data = {
    ['body'] = {
      poly = {
        -3.5,1,
        3.5,1,
        4,1.5,
        4,30,
        -4,30,
        -4,1.5
      },
      friction = 0,
      restitution = 0,
    },
    ['ball'] = {
      poly = {
        -3.5,0,
        3.5,0,
        4,0.5,
        4,14,
        -4,14,
        -4,0.5,
      },
      friction = 1,
      restitution = 0.3,
    },
    ['foot'] = {
      poly = {
        -2.5,0,
        2.5,0,
        3.5,1,
        -3.5,1,
      },
      friction = 1,
      restitution = 0,
    },
    ['ball_sensor'] = {
      poly = {
        -4,16,
        4,16,
        4,30,
        -4,30,
      },
      friction = 0,
      restitution = 0,
    }
  }

  this.view = View:new(this)

  return this
end

function Samus.init()
  local Samus = Samus:new()
  local sx, sy = map_mgr.getGlobalPosForMapPos(Samus.map_pos.x, Samus.map_pos.y)
  Samus:setBody(sx+128, sy+48)

  return Samus
end

function Samus:updateWorld()
  self:updateMapPos()
  camera:updateLocForSamus(self)
  fixture_map:updateRoomsForSamus(self)
end

function Samus:updateMapPos()
  local sx, sy = self.body:getPosition()
  local rx, ry = map_mgr.getMapPosForGlobalPos(sx, sy)
  self.map_pos.x = rx
  self.map_pos.y = ry
end

function Samus:setBody(x,y)
  if self.body then
    self.body:destroy()
    self.body = nil
  end
  self.body = world:addBody(MOAIBox2DBody.DYNAMIC, x, y)
  self.body:setFixedRotation(true)
  self.body:setMassData(80)
  self.body:resetMassData()
  self.body.parent = self

  self.view.prop:setParent(self.body)
end

--------------------
-- Fixtures
--------------------
function Samus:clearFixtures()
  if self.body.fixtures then
    local fixtures = self.body.fixtures
    for i,fixture in pairs(fixtures) do
      fixture:destroy()
    end
  end
  self.body.fixtures = {}
end

function Samus:addFixture(name)
  if not self.body.fixtures then
    self.body.fixtures = {}
  end
  fixture = self.body:addPolygon(self.fixture_data[name].poly)
  fixture.id = name
  fixture:setFriction(self.fixture_data[name].friction)
  fixture:setRestitution(self.fixture_data[name].restitution)
  fixture:setCollisionHandler(collision.handler, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END)

  self.body.fixtures[name] = fixture
end

function Samus:setStandFixtures()
  if self.status.in_ball == false then
    return
  end
  self:clearFixtures()
  self:addFixture('foot')
  self:addFixture('body')
end

function Samus:setBallFixtures()
  self:clearFixtures()
  self:addFixture('ball')
  self:addFixture('foot')
  self:addFixture('ball_sensor')
  self.body.fixtures['ball_sensor']:setSensor(true)
end

--------------------
-- Controls
--------------------
function Samus:input (key, down)
  if down then
--    print(key..": down")
  else
--    print(key..": up")
  end

  if key == 'right' then 
    self.button.right = down
    self:right (down)
  elseif key == 'left' then
    self.button.left = down
    self:left (down)
  elseif key == 'up' then
    self.button.up = down
    self:up (down)
  elseif key == 'down' then
    self.button.down = down
    self:down (down)
  elseif key == 'fire' then
    self.button.fire = down
    self:fireButton (down)
  elseif key == 'jump' then
    self.button.jump = down
    self:jumpButton(down)
  elseif key == 'select' then
    self.button.select = down
    self:selectButton(down)
  end
end

function Samus:right (down)
  if debug then
--    print "Samus:right"
  end
  if down then
    self:setMove('right')

    if self.status.action ~= 'flip' then
      self:face('right')
    end

    if self.status.on_floor and self.status.action == 'stand' then
      self:action('run')
    end
  else -- right button up
    self:cancelMove('right')

    if self.button.left then
      self:left(true)
    elseif self.status.action == 'run' then
      self:action('stand')

      if self.button.down then
        self:action('duck')
      end
    end
  end
end

function Samus:left (down)
  if debug then
--    print "Samus:left"
  end
  if down then
    self:setMove('left')

    if self.status.action ~= 'flip' then
      self:face('left')
    end

    if self.status.on_floor and self.status.action == 'stand' then
      self:action('run')
    end
  else -- left button up
    self:cancelMove('left')

    if self.button.right then
      self:right(true)
    elseif self.status.action == 'run' then
      self:action('stand')

      if self.button.down then
        self:action('duck')
      end
    end
  end
end

function Samus:up (down)
  if down then
--    print("self.status.action == "..self.status.action)
    if self.status.in_ball then
      self:action('getup')
    elseif self.status.action ~= 'flip' then
      self:aim('up')
    end

  else
    self:aim()
  end
end

function Samus:down (down)
  if down and self.status.action == 'stand' then
    self:action('duck')
  end
end

function Samus:fireButton (down)
  if down then
    self:fire()
  end
end
  
function Samus:jumpButton (down)
  if down then
    self:action('jump')
  else
    self:inverseJump()
  end
end

function Samus:selectButton (down)
  if down then
    self:toggleMissiles()
  end
end

--------------------
-- Actions
--------------------
function Samus:setMove(dir)
  if dir == 'left' then
    self.move.left = true
  elseif dir == 'right' then
    self.move.right = true
  end
end

function Samus:cancelMove(dir)
  if dir == 'left' then
    self.move.left = false
  elseif dir == 'right' then
    self.move.right = false
  elseif dir == 'down' then
    self.move.down = false
  end
end

function Samus:face(face)
  if self.status.busy then return end

  self.status.facing = face

  self:updateView()
end

function Samus:reset()
  
end

function Samus:action(action)
--  print("action: "..action)
  if self.status.busy then return end

  if action == 'spawn' then
    self:spawn()
  elseif action == 'die' then
    self:die()
  elseif action == 'stand' then
    self:stand()
  elseif action == 'run' then
    self:run()
  elseif action == 'duck' then
    self:duck()
  elseif action == 'roll' then
    self:roll()
  elseif action == 'getup' then
    self:getup()
  elseif action == 'jump' then
    self:jump()
  elseif action == 'flip' then
    self:flip()
  elseif action == 'land' then
    self:land()
  end

  self:updateView()
end

function Samus:spawn ()
  self:setStandFixtures()
  self.status.in_ball = false
--  self.status.busy = true
  self.status.action = 'spawn'
end

function Samus:die ()
  self.status.busy = true
  self.status.action = 'die'
end

function Samus:stand ()
  if not self.body.fixtures then
    self:setStandFixtures()
  end
  self.status.in_ball = false
  self.status.action = 'stand'
end

function Samus:run ()
  self.status.in_ball = false
  self.status.action = 'run'
end

function Samus:duck ()
  if not self.gear.ball then
    return false
  end
  if self.status.on_floor == false then
    return false
  end

  self.status.in_ball = true
  self:setBallFixtures()
  self.status.action = 'duck'

  sounds.play('morphball')
end

function Samus:getup ()
  if self.status.ball_sensor_contacts > 0 then
    return
  end
  self.status.action = 'getup'
  self:setStandFixtures()
  self.status.in_ball = false
  print "Samus:getup"
  print("on floor: "..tostring(self.status.on_floor))
  if not self.status.on_floor then
    self.status.action = 'jump'
    self.status.aiming_up = true
  elseif self.move.right or self.move.left then
    self.status.action = 'run'
  else
    self.status.action = 'stand'
  end
end

function Samus:roll ()
  self.status.action = 'roll'
  self.speed = 80
end

function Samus:jump ()
  if self.status.in_ball or not self.status.on_floor then
    return false
  end

  self.status.on_floor = false
  self.speed = 60
--  print "on floor: false"

  if self:isMoving() and not self.status.aiming_up then
    self.status.action = 'jumpToFlip'
  else
    self.status.action = 'jump'
  end
  if self.gear.boots == true then
    self.body:applyLinearImpulse(0,300)
  else
    self.body:applyLinearImpulse(0,225)
  end
  sounds.play('jump')
end

function Samus:flip ()
  self.friction.x = false
  self.status.action = 'flip'
end

function Samus:fall ()
  self.speed = 60
  self.status.on_floor = false
  self.friction.x = false
  if not self.status.in_ball then
    self.status.action = 'jump'
  end

  self:updateView()
end

function Samus:inverseJump ()
  local dx, dy = self.body:getLinearVelocity()
  if dy > 0 then
    self.body:setLinearVelocity(dx, 0)
  end
end

function Samus:land ()
  self.status.on_floor = true
  self.speed = 80
--  print "on floor: true"
  self.friction.x = true
  if self:isMoving() then
    if self.move.left then
      self:face('left')
    else
      self:face('right')
    end
    if not self.status.in_ball then
      self:run()
    end
  elseif not self.status.in_ball then
    self:stand()
  end

  self:updateView()
end

function Samus:aim (dir)
  if self.status.in_ball then return end

  if dir == 'up' then
    self.status.aiming_up = true
  else
    self.status.aiming_up = false
  end

  self:updateView()
end

function Samus:fire ()
  if self.status.facing == 'forward' then
    self:face('right')
  end

  if self.status.in_ball then
    self:dropBomb()
  elseif self.status.missile_mode then
    self:fireMissile()
  else
    self:fireWeapon()
  end
end

function Samus:fireWeapon ()
--  self.status.firing = true

  local gx, gy = self.body:getPosition()

  local dir
  local bx, by
  if self.status.facing == 'left' then
    if self.status.aiming_up then
      dir = 'up'
      bx = gx-1
      by = gy+31
    else
      dir = 'left'
      bx = gx-10
      by = gy+21
    end
  elseif self.status.facing == 'right' then
    if self.status.aiming_up then
      dir = 'up'
      bx = gx+1
      by = gy+31
    else
      dir = 'right'
      bx = gx+10
      by = gy+21
    end
  end

  local weapon
  if self.gear.icebeam then
    weapon = 'icebeam'
    sounds.play('icebeam')
  elseif self.gear.wavebeam then
    weapon = 'wavebeam'
    sounds.play('wavebeam')
  else
    weapon = 'normal'
    if self.gear.longbeam then
      sounds.play('longbeam')
    else
      sounds.play('shortbeam')
    end
  end

  local longbeam = false
  if self.gear.longbeam then
    longbeam = true
  end

  local bullet = require('bullet'):new(bx, by, dir, weapon, longbeam)

  self:updateView()
end

function Samus:dropBomb ()
  if not self.gear.bomb then
    return false
  end

  local bombs = self.gear.bomb_cache
  if #bombs >= 3 then
    return
  end

  local gx, gy = self.body:getPosition()
  local bx = gx
  local by = gy+4

  local bomb = require('bomb'):new(bx, by)
  table.insert(self.gear.bomb_cache, bomb)
end

function Samus:cleanupBombCache()
  for k, v in pairs(self.gear.bomb_cache) do
    if not v.body then
      table.remove(self.gear.bomb_cache, k)
    end
  end
end

function Samus:fireMissile ()
  if self.gear.missiles == 0 then
    return false
  end
--  self.status.firing = true
  self.gear.missiles = self.gear.missiles - 1
  if self.gear.missiles == 0 then
    self:toggleMissiles()
  end

  -- TODO: spawn missile
end

function Samus:toggleMissiles ()
  if self.gear.missiles == 0 then
    self.missile_mode = false
    return false
  end

  if self.missile_mode == true then
    self.missile_mode = false
  else
    self.missile_mode = true
  end

  self:updateView()
end

function Samus:enterDoor(door)
  local dir = door.pos

  self.status.in_door = true
  self.status.busy = true

  if self.view.anim then
    self.view.anim:pause()
  end

  local x,y = self.body:getPosition()
  local rx, ry = map_mgr.getMapPosForGlobalPos(x,y)

  local factor
  if dir == 'right' then
    factor = 1
    fixture_map:populateRoom(rx+1, ry)
  elseif dir == 'left' then
    factor = -1
    fixture_map:populateRoom(rx-1, ry)
  end
    
  local thread = MOAICoroutine.new()
  thread:run( function()
    -- pull Samus into door
    repeat
      self.body:setLinearVelocity(60*factor,5)
      local dx, dy = self.body:getPosition()
      coroutine:yield()
    until math.abs(dx - x) >= 20
  
    self.body:setLinearVelocity(0,5)
    -- move camera
    if dir == 'right' then
      camera:moveRightRoom()
    elseif dir == 'left' then
      camera:moveLeftRoom()
    end
  
    -- push Samus out of door
    repeat
      self.body:setLinearVelocity(60*factor,5)
      local dx, dy = self.body:getPosition()
      coroutine:yield()
    until math.abs(dx - x) >= 51

    -- swap camera direction
    camera:swapDirection()

    self.status.in_door = false
    self.status.busy = false
    if self.view.anim then
      self.view.anim:start()
    end
    if self.status.on_floor then
      self.status.floor_contacts = 2
      self:land()
    end
  end )
end

function Samus:exitDoor()
  self.status.in_door = false
  self.status.busy = false
end

function Samus:takeHit (obj)
  self.health = self.health - dmg
  if self.health <= 0 then
    self:die()
  end
end

function Samus:getHealth()
  self.health = self.health + 5
  if self.health > 99 then
    self.health = 99
  end
end

function Samus:getMissiles()
  self.missiles = self.missiles + 2
  if self.missiles > self.max_missiles then
    self.missiles = self.max_missiles
  end
end

function Samus:enterLava()
  self.status.lava_contact = self.status.lava_contact + 1
end

function Samus:leaveLava()
  self.status.lava_contact = self.status.lava_contact - 1
end

function Samus:isMoving()
  return (self.move.left and not self.move.right) or (self.move.right and not self.move.left)
end

function Samus:getItem(item)
  item.anim:pause()

  local gift = item.gift
  print("Samus:getItem "..gift)
  if gift == 'missile' then
    table.insert(self.gear.missiles, item.rx.."-"..item.ry)
  elseif gift == 'energy tank' then
    table.insert(self.gear.energy_tanks, item.rx.."-"..item.ry)
  elseif gift == 'ball' then
    self.gear.ball = true
  elseif gift == 'varia' then
    self.gear.varia = true
  elseif gift == 'boots' then
    self.gear.boots = true
  elseif gift == 'screw' then
    self.gear.screw = true
  elseif gift == 'longbeam' then
    self.gear.longbeam = true
  elseif gift == 'icebeam' then
    self.gear.icebeam = true
  elseif gift == 'wavebeam' then
    self.gear.wavebeam = true
  elseif gift == 'bomb' then
    self.gear.bomb = true
  end

  self.status.busy = true
  paused = true
  if self.view.anim then
    self.view.anim:pause()
  end

  local thread = MOAICoroutine.new()
  thread:run( function()
    _G.music.interrupt('item')
    while _G.music.isPlaying() do
      self.body:setLinearVelocity(0,0)
      coroutine:yield()
    end
    self.status.busy = false
    if self.view.anim then
      self.view.anim:start()
    end
    item:destroy()
  end )

end

--------------------
-- Game events
--------------------
function Samus:onCollision (fix_a, fix_b)
  if fix_b.id == 'item' then
    self:getItem(fix_b:getBody().parent)
  elseif fix_b.id == 'bomb_explode' and (fix_a.id == 'body' or fix_a.id == 'ball') then
    local lx, ly = fix_b:getBody():getLinearVelocity()
    local bx, by = fix_b:getBody():getPosition()
    local sx, sy = self.body:getPosition()
    local dx = sx - bx
    local dy = sy - by + 8

    local h = math.sqrt(dx*dx+dy*dy)

    self.body:setLinearVelocity(dx*140/h, dy*140/h - ly)

    if dy > 0 then
      self:fall()
    end
  elseif fix_b.id == 'floor' then
    if fix_a.id == 'foot' then
      local dx, dy = self.body:getLinearVelocity()
      if dy <= 0 then
        self:land()
        self.status.floor_contacts = self.status.floor_contacts + 1
        if self.status.floor_contacts > 2 then
          self.status.floor_contacts = 2
        end
      end
    elseif fix_a.id == 'ball_sensor' then
      self.status.ball_sensor_contacts = self.status.ball_sensor_contacts + 1
      if self.status.ball_sensor_contacts > 2 then
        self.status.ball_sensor_contacts = 2
      end
    end
  elseif fix_b.id == 'door' then
    if fix_a.id == 'body' then
      self.status.door_contacts = self.status.door_contacts + 1
      if not self.status.in_door then
        self:enterDoor(fix_b:getBody().parent)
      end
    end
  elseif fix_b.id == 'lava' then
    self:enterLava()
  elseif fix_b.id == 'enemy' then
    self:takeHit(fix_b.parent)
  end
end

function Samus:endCollision (fix_a, fix_b)
  if fix_b.id == 'floor' then
    if fix_a.id == 'foot' then
      self.status.floor_contacts = self.status.floor_contacts - 1
      if self.status.floor_contacts < 0 then
        self.status.floor_contacts = 0
      end
      local dx, dy = self.body:getLinearVelocity()
      if dy <= 0 and self.status.floor_contacts == 0 then
        self:fall()
      end
    elseif fix_a.id == 'ball_sensor' then
      self.status.ball_sensor_contacts = self.status.ball_sensor_contacts - 1
      if self.status.ball_sensor_contacts < 0 then
        self.status.ball_sensor_contacts = 0
      end
    end
  elseif fix_b.id == 'door' then
    if fix_a.id == 'body' then
      self.status.door_contacts = self.status.door_contacts - 1
      if self.status.door_contacts == 0 then
        self:exitDoor()
      end
    end
  end
end

function Samus:updateView ()
  self.view:updateForSamus(self)
end

