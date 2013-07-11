module(..., package.seeall)

return {
  ['06'] = {
    tid = 0x07, -- door frame
    poly = nil,
  },
  ['08'] = {
    tid = 0x09, -- square rock
  },
  ['09'] = {
    tid = 0x0A, -- left stalagtite
    poly = {
      0.1,15.9,
      15.9,15.9,
      15.9,0.1
    },
  },
  ['0A'] = {
    tid = 0x0B, -- right stalagtite
    poly = {
      0.1,0.1,
      0.1,15.9,
      15.9,15.9
    },
  },
  ['0B'] = {
    tid = 0x0C,
  },
  ['0C'] = {
    tid = 0x0D, -- skull
  },
  ['1C'] = {
    tid = 0x1D, -- loose fill
  },
  ['1F'] = {
    tid = 0x20, -- pipe
  },
  ['17'] = {
    tid = 0x18, -- column
  },
  ['20'] = {
    tid = 0x21, -- metal block
  },
  ['28'] = {
    tid = 0x22, -- blank
    poly = nil,
  },
  ['34'] = {
    tid = 0x35, -- column
  },
  ['35'] = {
    tid = 0x36, -- right column
  },
  ['36'] = {
    tid = 0x37, -- square block
  },
}
