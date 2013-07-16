module(..., package.seeall)

return {
    [0x07] = { -- door frame
      poly = -1,
    },
    [0x08] = { -- special item door frame
      poly = -1,
    },
    [0x0A] = { -- left stalagtite
      poly = {
        0.1,15.9,
        15.9,15.9,
        15.9,0.1
      },
    },
    [0x0B] = { -- right stalagtite
      poly = {
        0.1,0.1,
        0.1,15.9,
        15.9,15.9
      },
    },
    [0x22] = { -- blank
      poly = -1,
    },
    [0x23] = { -- item orb
      blast = true,
    },
    [0x25] = { -- blastable square rock
      blast = true,
    },
    [0x26] = { -- blank
      poly = -1,
    },
    [0x27] = { -- blank
      poly = -1,
    },
    [0x28] = { -- blank
      poly = -1,
    },
    [0x29] = { -- blank
      poly = -1,
    },
    [0x2C] = { -- passable
      poly = -1,
    },
    [0x30] = {
      blast = true,
    },
    [0x34] = {
      blast = true,
    },
    [0x36] = {
      blast = true,
    },
    [0x3F] = { -- bush
      poly = -1,
    },
    [0x40] = { -- bush
      poly = -1,
    },
    [0x47] = { -- door frame
      poly = -1,
    },
    [0x48] = { -- special item door frame
      poly = -1,
    },
}

