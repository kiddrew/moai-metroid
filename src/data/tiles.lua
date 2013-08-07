module(..., package.seeall)

return {
    [0x04] = {
      poly = -1,
    },
    [0x41] = {
      poly = {
        0,0,
        16,0,
        16,2,
        0,2
      }
    },
    [0x42] = {
      poly = -1
    },
    [0x07] = { -- door frame
      poly = -1,
    },
    [0x08] = { -- special item door frame
      poly = -1,
    },
    [0x0A] = { -- left stalagtite
      poly = {
        0,16,
        16,16,
        16,0
      },
    },
    [0x0B] = { -- right stalagtite
      poly = {
        0,0,
        0,16,
        16,16
      },
    },
    [0x22] = { -- blank
      poly = -1,
    },
    [0x23] = { -- item orb
      blast = true,
    },
    [0x24] = { -- item orb
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
    [0x2A] = { -- blank
      poly = -1,
    },
    [0x2B] = {
      poly = -1,
    },
    [0x2C] = { -- passable
      poly = -1,
    },
    [0x2D] = {
      poly = -1,
    },
    [0x2E] = {
      poly = -1,
    },
    [0x2F] = {
      poly = -1,
    },
    [0x30] = {
      blast = true,
    },
    [0x70] = {
      blast = true,
    },
    [0xB0] = {
      blast = true,
    },
    [0x32] = {
      poly = {
        0,0,
        16,0,
        16,8,
        0,8
      },
    },
    [0x33] = {
      poly = {
        0,0,
        16,0,
        16,8,
        0,8
      },
    },
    [0x34] = {
      blast = true,
    },

    -- gateway tiles
    [0x3B] = {
      poly = {
        8,0,
        16,0,
        16,16,
        8,16,
      },
    },

    [0x3C] = {
      poly = -1,
    },
    [0x7C] = {
      poly = -1,
    },
    [0xBC] = {
      poly = -1,
    },

    [0x3D] = {
      poly = {
        8,0,
        16,0,
        16,16,
        8,16,
      },
    },

    [0x72] = {
      poly = {
        0,0,
        16,0,
        16,8,
        0,8
      },
    },
    [0x73] = {
      poly = {
        0,0,
        16,0,
        16,8,
        0,8
      },
    },
    [0xB2] = {
      poly = {
        0,0,
        16,0,
        16,8,
        0,8
      },
    },
    [0xB3] = {
      poly = {
        0,0,
        16,0,
        16,8,
        0,8
      },
    },
    [0x34] = {
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
    [0x4A] = { -- left stalagtite
      poly = {
        0,16,
        16,16,
        16,0
      },
    },
    [0x4B] = { -- right stalagtite
      poly = {
        0,0,
        0,16,
        16,16
      },
    },
    [0x56] = {
      poly = {
        0,0,
        16,0,
        16,8,
        0,8,
      },
    },
    [0x62] = {
      poly = -1
    },
    [0x66] = {
      poly = -1
    },
    [0x67] = {
      poly = -1
    },
    [0x68] = {
      poly = -1
    },
    [0x69] = {
      poly = -1
    },
    [0x6A] = {
      poly = -1
    },
    [0x6B] = {
      poly = -1
    },
    [0x6C] = {
      poly = -1
    },
    [0x6D] = {
      poly = -1
    },
    [0x6E] = {
      poly = -1
    },
    [0xA9] = {
      poly = -1
    },
}

