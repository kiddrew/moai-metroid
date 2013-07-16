local View = require('samus_view').SamusView
local debug = true

module ( ..., package.seeall)

Samus = {}
Samus_mt = {__index = Samus}

function Samus:new ()
  print "creating samus"

  local this = setmetatable({
    id = 'samus',
    health = 99,
    speed = 80,
    ground_y = nil,
    map_pos = {
      x = 4,
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
      on_ground = false,
      ground_contacts = 0,
      facing = 'right',
      in_door = false,
      firing = false,
      lava_contact = 0,
    }
  }, Samus_mt)

  this.gear = {
    energyTanks = energyTanks or 0,
    missiles = max_missiles or 0,
    max_missiles = max_missiles or 0,
    ball = ball or true,
    bomb = bomb or false,
    longbeam = longbeam or false,
    icebeam = icebeam or false,
    wavebeam = wavebeam or false,
    boots = boots or false,
    varia = varia or false,
    screw = screw or false,
  }

  local sx, sy = map_mgr.getRoomCoordinates(this.map_pos.x, this.map_pos.y)

  this.body = world:addBody(MOAIBox2DBody.DYNAMIC, sx, sy)
  this.body:setFixedRotation(true)
  this.body:setMassData(80)
  this.body:resetMassData()
  this.body.parent = this

  this.fixture_data = {
    ['body'] = {
      poly = {
        -4,1,
        4,1,
        4,30,
        -4,30,
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
      restitution = 0.1,
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
    }
  }

  this.view = View:new(this)

  return this
end

--------------------
-- Fixtures
--------------------
function Samus:clearFixtures()
  if self.body.fixtures then
    print "clearing samus fixtures"
    local fixtures = self.body.fixtures
    for i,fixture in pairs(fixtures) do
      print(fixture)
      fixture:destroy()
    end
  end
  self.body.fixtures = {}
end

function Samus:addFixture(name)
  if not self.body.fixtures then
    self.body.fixtures = {}
  end
  print("add fixture: "..name)
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
end

--------------------
-- Controls
--------------------
function Samus:input (key, down)
  if down then
    print(key..": down")
  else
    print(key..": up")
  end

  if self.status.busy == true then
    return false
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
    print "Samus:right"
  end
  if down then
    self:setMove('right')
    if self.status.action ~= 'flip' then
      self:face('right')
    end

    if self.status.on_ground and self.status.action == 'stand' then
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
    print "Samus:left"
  end
  if down then
    self:setMove('left')
    if self.status.action ~= 'flip' then
      self:face('left')
    end

    if self.status.on_ground and self.status.action == 'stand' then
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
    print("self.status.action == "..self.status.action)
    if self.status.in_ball then
      self:action('getup')
    end
    if self.status.action ~= 'flip' then
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
  self.status.facing = face

  self:updateView()
end

function Samus:action(action)
  print("action: "..action)
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
  self.setStandFixtures()
  self.status.in_ball = false
  self.status.busy = true
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
  if self.status.on_ground == false then
    return false
  end

  self.status.in_ball = true
  self:setBallFixtures()
  self.status.action = 'duck'
end

function Samus:getup ()
  self.status.action = 'getup'
  self:setStandFixtures()
  self.status.in_ball = false
  if self.move.right or self.move.left then
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
  if self.status.in_ball or not self.status.on_ground then
    return false
  end

  self.status.on_ground = false
  self.speed = 60
  print "on ground: false"

  if self:isMoving() then
    self.status.action = 'jumpToFlip'
  else
    self.status.action = 'jump'
  end
  if self.gear.boots == true then
    self.body:applyLinearImpulse(0,300)
  else
    self.body:applyLinearImpulse(0,225)
  end
--  sounds.play('jump')
end

function Samus:flip ()
  self.friction.x = false
  self.status.action = 'flip'
end

function Samus:fall ()
  self.speed = 60
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
  self.status.on_ground = true
  self.speed = 80
  print "on ground: true"
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

  -- TODO: spawn bullet

  self:updateView()
end

function Samus:dropBomb ()
  if not self.gear.bomb then
    return false
  end

  -- TODO: spawn bomb
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

function Samus:door ()
  self.in_door = true
  if self.anim then
    self.anim:stop()
  end
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

--------------------
-- Game events
--------------------
function Samus:onCollision (fix_a, fix_b)
  if fix_a.id == 'foot' then
    if fix_b.id == 'ground' then
      local dx, dy = self.body:getLinearVelocity()
      if dy <= 0 then
        self:land()
        self.status.ground_contacts = self.status.ground_contacts + 1
        if self.status.ground_contacts > 2 then
          self.status.ground_contacts = 2
        end
      end
    end
  else
    if fix_b.id == 'ground' then
    elseif fix_b.id == 'lava' then
      self:enterLava()
    else
      self:takeHit(fix_b.parent)
    end
  end
end

function Samus:endCollision (fix_a, fix_b)
  if fix_a.id == 'foot' then
    if fix_b.id == 'ground' then
      self.status.ground_contacts = self.status.ground_contacts - 1
      if self.status.ground_contacts < 0 then
        self.status.ground_contacts = 0
      end
      local dx, dy = self.body:getLinearVelocity()
      if dy <= 0 and self.status.ground_contacts == 0 then
        self:fall()
      end
    end
  end
end

function Samus:updateView ()
  self.view:updateForObject(self)
end

