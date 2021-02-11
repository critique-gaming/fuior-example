local compiler = require "fuior.compiler"
local fui = require "fuior.runtime"

local function nop() end

compiler.compile("/fuior/src/config.fui")(fui.new({
  enum = nop,
  declare_cmd = nop,
  declare_var = function (var_name, type, default_value)
    -- TODO: Do custom stuff with your own data models here
    local var = default_value
    fui.getters[var_name] = function () return var end
    fui.setters[var_name] = function (x) var = x end
  end,
}))
