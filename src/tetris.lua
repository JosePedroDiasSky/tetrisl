local consts = require "src.consts"
local utils = require "src.utils"

local M = {}

local COLORS = {
  {0.5, 1, 1}, -- 1 / cyan / I
  {0.5, 0.5, 1}, -- 2 / blue / J
  {1, 0.5, 0}, -- 3 / orange / L
  {1, 1, 0.5}, -- 4 / yellow / O
  {0.5, 1, 0.5}, -- 5 / light green / S
  {0.75, 0.5, 1}, -- 6 / purple / T
  {1, 0.5, 0.5} -- 7 / red / Z
}

local brickCollections = {
  tetris99 = require "src.bricks_99",
  gameboy = require "src.bricks_gb"
}

local BRICKS

local function setBricks(flavour)
  BRICKS = brickCollections[flavour]
  M.BRICKS = BRICKS
end

--[[ local function brickFromString(st)
  local br = {}
  local lines = utils.splitLines(st)
  for y, line in pairs(lines) do
    local chars = utils.explodeString(line)
    for x, char in pairs(chars) do
      if char ~= " " then
        table.insert(br, {x - 1, y - 1})
      end
    end
  end
  return br
end ]]
---- BOARD RELATED

local function id2(x, y)
  return y * 100 + x
end

--[[ local function id2Rev(id)
  local x = id % 100
  local y = (id - x) / 100
  return {x, y}
end ]]
local function iterateBoard(board, fn)
  for y = 1, consts.h do
    for x = 1, consts.w do
      fn(board, x, y)
    end
  end
end

local function iterateBoardLine(board, y, fn)
  for x = 1, consts.w do
    fn(board, x, y)
  end
end

local function emptyBoard()
  local board = {}
  local function emptyCell(board2, x, y)
    board2[id2(x, y)] = 0
  end
  iterateBoard(board, emptyCell)
  return board
end

--[[ local function boardFromString(st)
  local board = emptyBoard()
  local lines = utils.splitLines(st)
  for y, line in pairs(lines) do
    local chars = utils.explodeString(line)
    for x, char in pairs(chars) do
      local n = tonumber(char)
      if (type(n) == "number") then
        board[id2(x, y)] = n
      end
    end
  end
  return board
end

local function boardToString(board)
  local s = ""
  local lastY = -1
  local function printCell(board2, x, y)
    if y ~= lastY then
      s = s .. "\n"
    end
    local v = board2[id2(x, y)]
    if v == 0 then
      v = " "
    end
    s = s .. v
    lastY = y
  end
  iterateBoard(board, printCell)
  return s
end

local function randomBoard()
  local board = {}
  local function fillCell(board_, x, y)
    local r = love.math.random()
    -- local isOn = r > 0.25
    local isOn = r < ((y - 2) / consts.h)
    board_[id2(x, y)] = (not isOn) and 0 or love.math.random(#BRICKS)
  end
  iterateBoard(board, fillCell)
  return board
end ]]
local function doesBrickHitBoard(brickIdx, brickVar, board, x, y)
  local items = BRICKS[brickIdx][brickVar]
  for _, v in ipairs(items) do
    local X = v[1] + x + 1
    if X < 1 or X > consts.w then
      return true
    end
    local Y = v[2] + y + 1
    if Y >= 1 then
      if Y > consts.h then
        return true
      end
      if board[id2(X, Y)] ~= 0 then
        return true
      end
    end
  end
  return false
end

local function applyBrickToBoard(brickIdx, brickVar, board, x, y)
  local items = BRICKS[brickIdx][brickVar]
  for _, v in pairs(items) do
    local X = v[1] + x + 1
    local Y = v[2] + y + 1
    board[id2(X, Y)] = brickIdx
  end
end

local function electNearestPosition(brickIdx, brickVar, board, x, y)
  local delta = 0
  if not doesBrickHitBoard(brickIdx, brickVar, board, x, y) then
    return x
  end

  while true do
    delta = delta + 1

    if not doesBrickHitBoard(brickIdx, brickVar, board, x - delta, y) then
      return x - delta
    end

    if not doesBrickHitBoard(brickIdx, brickVar, board, x + delta, y) then
      return x + delta
    end

    if delta > 5 then
      return -1
    end
  end
end

local function moveLinesDown(board, sinceY)
  for x = 1, consts.w do
    for y = sinceY, 2, -1 do
      board[id2(x, y)] = board[id2(x, y - 1)]
    end
    board[id2(x, 1)] = 0
  end
end

local function isLineFilled(board, y)
  local counter = 0

  local function incIfPositive(board2, x, y2)
    local v = board2[id2(x, y2)]
    if v > 0 then
      counter = counter + 1
    end
  end

  iterateBoardLine(board, y, incIfPositive)
  return counter == consts.w
end

local function computeLines(board, alsoMoveThem)
  local filledLines = {}

  local function emptyCell(board2, x, y)
    board2[id2(x, y)] = 0
  end

  local y = consts.h
  while y > 0 do
    if isLineFilled(board, y) then
      table.insert(filledLines, y)
      if alsoMoveThem then
        iterateBoardLine(board, y, emptyCell)
        moveLinesDown(board, y)
      else
        y = y - 1
      end
    else
      y = y - 1
    end
  end

  return filledLines
end

---- DRAWING FUNCTIONS

local G = love.graphics

local CANVAS = {}
local GHOST_ALPHA = 0.33

local function drawGradient(cell, maxAlpha)
  for y = 0, cell - 1 do
    local r = 1 - y / cell
    G.setColor(r, r, r, 0.66 * maxAlpha)
    G.rectangle("fill", 0, y, cell, 1)
  end
end

--[[
    0 a   b c
    a

    b
    c
  ]]
local function drawBevel(c, gap, maxAlpha)
  local a = gap
  local b = c - gap

  G.setColor(1, 1, 1, 0.5 * maxAlpha)
  G.polygon("fill", 0, 0, c, 0, b, a, a, a, a, b, 0, c, 0, 0)

  G.setColor(0, 0, 0, 0.5 * maxAlpha)
  G.polygon("fill", c, c, 0, c, a, b, b, b, b, a, c, 0, c, c)
end

local function prepare()
  if #CANVAS == 2 then
    return
  end

  local c = consts.cell

  for i = 1, 2 do
    CANVAS[i] = G.newCanvas(c, c)
    G.setCanvas(CANVAS[i])

    local maxAlpha = i == 1 and 1 or GHOST_ALPHA * 1.5

    G.setColor(0.5, 0.5, 0.5, 1)
    G.rectangle("fill", 0, 0, c, c)

    drawGradient(c, maxAlpha)

    drawBevel(c, c / 6, maxAlpha)

    G.setCanvas()
  end
end

local function drawCell(colorIdx, x, y, isGhost)
  if (colorIdx == 0) then
    return
  end
  local clr = COLORS[colorIdx]
  local alpha = isGhost and GHOST_ALPHA or 1
  G.setColor(clr[1], clr[2], clr[3], alpha)
  local x1 = consts.x0 + x * consts.cell
  local y1 = consts.y0 + y * consts.cell

  G.rectangle("fill", x1, y1, consts.cell, consts.cell)

  local canvas = CANVAS[isGhost and 2 or 1]

  G.setBlendMode("darken", "premultiplied")
  G.draw(canvas, x1, y1)

  G.setBlendMode("lighten", "premultiplied")
  G.draw(canvas, x1, y1)

  G.setBlendMode("alpha")
end

local function drawBrick(pos0, brickIdx, brickVar, isGhost)
  local items = BRICKS[brickIdx][brickVar]
  for _, v in pairs(items) do
    local x = pos0[1] + v[1]
    local y = pos0[2] + v[2]
    drawCell(brickIdx, x, y, isGhost)
  end
end

local function drawBoard(board, destroyedLines)
  local function fn(b, x, y)
    local wasDestroyed = utils.has(destroyedLines, y)
    local v = b[id2(x, y)]
    drawCell(v, x - 1, y - 1, wasDestroyed)
  end
  iterateBoard(board, fn)
end

local function drawBoardBackground()
  for y = 0, consts.h - 1 do
    for x = 0, consts.w - 1 do
      local alpha = (x + y) % 2 == 0 and 0.1 or 0.05
      G.setColor(1, 1, 1, alpha)
      G.rectangle("fill", consts.x0 + x * consts.cell, consts.y0 + y * consts.cell, consts.cell, consts.cell)
    end
  end
end

M.applyBrickToBoard = applyBrickToBoard
M.computeLines = computeLines
M.doesBrickHitBoard = doesBrickHitBoard
M.drawBoard = drawBoard
M.drawBoardBackground = drawBoardBackground
M.drawBrick = drawBrick
M.electNearestPosition = electNearestPosition
M.emptyBoard = emptyBoard
M.prepare = prepare
M.setBricks = setBricks

return M
