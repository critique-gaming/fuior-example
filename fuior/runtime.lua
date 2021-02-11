local sys_config = require "crit.sys_config"
local intl = require "crit.intl"

local M = {}
local runtime = {}

if sys_config.debug then
  setmetatable(runtime, {
    __index = function (table, key)
      error("Command \"" .. key .. "\" does not exist")
    end,
  })
end

function runtime.intl(namespace_id, en_strings)
  local namespace = intl.namespace("fuior_" .. (namespace_id or "main"))
  if en_strings then
    namespace.register({ en = en_strings })
  end
  return namespace
end

function runtime.animate(character, animation, instant, flipped)
  print("animate", character, animation, instant, flipped)
end

function runtime.text(character, animation, text)
  print("text", character, animation, text)
end

function runtime.set(variable)
  runtime.var_set(variable, true)
end

function runtime.unset(variable)
  runtime.var_set(variable, nil)
end

function runtime.choose(options)
  pprint("choose", options)
  return 1
end

function runtime.log_var(variable)
  pprint(runtime.var_get(variable))
end

function runtime.log(...)
  print(...)
end

local getters = {}
local setters = {}
local incrementers = {}

M.getters = getters
M.setters = setters
M.incrementers = incrementers

function runtime.var_set(variable, value)
  local setter = setters[variable]
  if setter then
    setter(value, variable)
  else
    error("Used undeclared Fuior variable: \"" .. variable .. "\"")
  end
end

function runtime.var_get(variable)
  local getter = getters[variable]
  if getter then
    return getter(variable)
  else
    error("Used undeclared Fuior variable: \"" .. variable .. "\"")
  end
end

function runtime.var_increment(variable, amount)
  local incrementer = incrementers[variable]
  if incrementer then
    incrementer(amount, variable)
  else
    local value = runtime.var_get(variable)
    if type(value) ~= "number" then
      error("Fuior variable \"" .. variable .. "\" is not numeric, so it cannot be incremented")
    end
    runtime.var_set(variable, value + amount)
  end
end

function runtime.var_decrement(variable, value)
  runtime.var_increment(variable, -value)
end

function M.new(self)
  self = self or {}
  setmetatable(self, { __index = runtime })

  self.try = function (command, ...)
    local ok, err = xpcall(function (...)
      return self[command](...)
    end, debug.traceback)
    if ok then return err end
    print('WARNING: ' .. err)
  end

  return self
end

return M
