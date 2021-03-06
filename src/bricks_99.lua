local BRICKS = {}

--[[
    01234 01234 01234 01234
 -1         X              
  0         X           X  
  1 XXOX    O    XOXX   O  
  2         X           X  
  3                     X  
      1     2     3     4

]]
local brickI = {
  {{0, 1}, {1, 1}, {2, 1}, {3, 1}},
  {{2, -1}, {2, 0}, {2, 1}, {2, 2}},
  {{1, 1}, {2, 1}, {3, 1}, {4, 1}},
  {{2, 0}, {2, 1}, {2, 2}, {2, 3}}
}
table.insert(BRICKS, brickI)

--[[
    012 012  012 012
  0  XX       X  X  
  1  O  XOX   O  XOX
  2  X    X  XX     
     2   3    4   1
]]
local brickJ = {
  {{0, 0}, {0, 1}, {1, 1}, {2, 1}},
  {{2, 0}, {1, 0}, {1, 1}, {1, 2}},
  {{0, 1}, {1, 1}, {2, 1}, {2, 2}},
  {{0, 2}, {1, 2}, {1, 1}, {1, 0}}
}
table.insert(BRICKS, brickJ)

--[[
    012 012 012 012
  0 XX    X  X     
  1  O  XOX  O  XOX
  2  X       XX X  
     4   1    2  3
]]
local brickL = {
  {{2, 0}, {2, 1}, {1, 1}, {0, 1}},
  {{1, 0}, {1, 1}, {1, 2}, {2, 2}},
  {{2, 1}, {1, 1}, {0, 1}, {0, 2}},
  {{0, 0}, {1, 0}, {1, 1}, {1, 2}}
}
table.insert(BRICKS, brickL)

--[[
    012
  0  XX
  1  XX
]]
local brickO = {
  {{1, 0}, {1, 1}, {2, 0}, {2, 1}}
}
table.insert(BRICKS, brickO)

--[[
    012 012 012 012
  0 X    XX  X
  1 XO  XO   OX  OX
  2  X        X XX
      4  1   2   3
]]
local brickS = {
  {{0, 1}, {1, 1}, {1, 0}, {2, 0}},
  {{1, 0}, {1, 1}, {2, 1}, {2, 2}},
  {{0, 2}, {1, 2}, {1, 1}, {2, 1}},
  {{0, 0}, {0, 1}, {1, 1}, {1, 2}}
}
table.insert(BRICKS, brickS)

--[[
    012 01 012 012
  0      X  X   X
  1 XOX XO XOX  OX
  2  X   X      X
     3   4  1   2
]]
local brickT = {
  {{0, 1}, {1, 1}, {2, 1}, {1, 0}},
  {{1, 0}, {1, 1}, {1, 2}, {2, 1}},
  {{0, 1}, {1, 1}, {2, 1}, {1, 2}},
  {{1, 0}, {1, 1}, {1, 2}, {0, 1}}
}
table.insert(BRICKS, brickT)

--[[
    012 012 012 012
  0   X      X  XX 
  1  OX XO  XO   OX
  2  X   XX X      
      2  3   4   1
]]
local brickZ = {
  {{0, 0}, {1, 0}, {1, 1}, {2, 1}},
  {{1, 1}, {2, 1}, {2, 0}, {1, 2}},
  {{0, 1}, {1, 1}, {1, 2}, {2, 2}},
  {{1, 0}, {1, 1}, {0, 1}, {0, 2}}
}

table.insert(BRICKS, brickZ)

return BRICKS
