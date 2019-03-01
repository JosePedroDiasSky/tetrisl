local consts = require "src.consts"
local utils = require "src.utils"
local settings = require "src.settings"
local stages = require "src.stages"

local G = love.graphics

local M = {}

local isMobile = utils.isMobile()

local options = {
  "start game",
  "see high scores",
  "change controls",
  "change bricks",
  "exit"
}

local possibleValues = {
  {""},
  {""},
  {"gameboy", "tetris99"},
  {"gameboy", "tetris99"},
  {""}
}

local IDX_CTRLS = 3
local IDX_BRICK = 4

local state = {}

M.load = function()
  local controls, bricks = settings.get()

  state.chosenOption = 1
  state.chosenIndices = {
    1,
    1,
    utils.tableIndexOf(possibleValues[IDX_CTRLS], controls),
    utils.tableIndexOf(possibleValues[IDX_BRICK], bricks),
    1
  }
end

M.unload = function()
  local controls = possibleValues[IDX_CTRLS][state.chosenIndices[IDX_CTRLS]]
  local bricks = possibleValues[IDX_BRICK][state.chosenIndices[IDX_BRICK]]
  settings.save(controls, bricks)
end

M.draw = function()
  local dy = 30
  local x0 = consts.W / 2 - 100
  local y0 = (consts.H - dy * #options) / 2

  for i, option in ipairs(options) do
    local alpha = 1 -- TODO: alpha borked
    local bullet = "  "
    if state.chosenOption == i and not isMobile then
      alpha = 1
      bullet = "- "
    end

    local value = possibleValues[i][state.chosenIndices[i]]
    G.setColor(1, 1, 1, alpha)
    local sep = value ~= "" and ": " or ""
    G.print(bullet .. option .. sep .. value, x0, y0 + dy * (i - 1))
  end
end

local function onStartGame()
  stages.toStage("game")
end

local function onHighscores()
  stages.toStage("highscores")
end

local function onToggleOption(i)
  state.chosenIndices[i] = utils.plus(state.chosenIndices[i], 1, #possibleValues[i])
end

local function onExit()
  stages.exit()
end

M.onKey = function(key)
  if key == "up" then
    state.chosenOption = utils.minus(state.chosenOption, 1, #options)
  elseif key == "down" then
    state.chosenOption = utils.plus(state.chosenOption, 1, #options)
  elseif key == "return" or key == "space" then
    if state.chosenOption == 1 then
      onStartGame()
    elseif state.chosenOption == 2 then
      onHighscores()
    elseif state.chosenOption == 5 then
      onExit()
    else
      onToggleOption(state.chosenOption)
    end
  elseif key == "escape" then
    onExit()
  end
end

M.onPointer = function(_, y)
  local dy = 30
  local y0 = (consts.H - dy * #options) / 2

  for i, _ in ipairs(options) do
    local yi = y0 + dy * (i - 1)
    if y >= yi and y <= yi + dy then
      if i == 1 then
        onStartGame()
      elseif i == 2 then
        onHighscores()
      elseif i == 5 then
        onExit()
      else -- 3, 4
        onToggleOption(i)
      end
    end
  end
end

return M
