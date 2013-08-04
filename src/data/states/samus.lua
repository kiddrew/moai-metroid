module(..., package.seeall)

return {
  parent = {
    spawn = {
      texture = '../resources/images/samus_spawn.png',
      size = {4,2},
      frames = {1,2,3,4,4},
      anim_step = 1.5,
    },
    stand = {
      texture = '../resources/images/samus_stand.png',
      size = {2,4},
    },
    jump = {
      texture = '../resources/images/samus_jump.png',
      size = {2,4},
    },
    jumpToFlip = {
      texture = '../resources/images/samus_jump.png',
      size = {2,4},
      frames = {1,1},
      anim_step = 0.16/2,
      next_state = 'flip',
    },
    flip = {
      texture = '../resources/images/samus_flip.png',
      size = {4,4},
      frames = {1,2,3,4,4},
      anim_step = 0.16/4,
      loop = true,
    },
    run = {
      texture = '../resources/images/samus_run.png',
      size = {4,4},
      frames = {1,2,3,3},
      anim_step = 0.16/3,
      loop = true,
    },
    duck = {
      texture = '../resources/images/samus_duck.png',
      size = {2,1},
      frames = {1,2,2},
      anim_step = 0.16/4,
      next_state = 'roll',
    },
    getup = {
      texture = '../resources/images/samus_getup.png',
      size = {5,2},
      frames = {1,2},
      anim_step = 0.16/4,
      next_state = 'stand',
    },
    roll = {
      texture = '../resources/images/samus_roll.png',
      size = {4,4},
      frames = {1,2,3,4,4},
      anim_step = 0.16/5,
      loop = true,
    },
  },
  child = {
    fire = {
      texture = '../resources/images/samus_fire_top.png',
      size = {1,4},
    },
    aimup = {
      texture = '../resources/images/samus_aimup_top.png',
      size = {1,4},
    },
  }
}


