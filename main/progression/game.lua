local screens = require "lib.screens"
local fuiorc = require "fuior.compiler"
local fui = require "fuior.runtime"

local function game()
  fuiorc.compile("/fuior/src/test.fui")(fui.new())

  local wait_for_transition = screens.replace("game")
  print("Screen loaded")
  wait_for_transition()
  print("Screen transition finished")
end

return game
