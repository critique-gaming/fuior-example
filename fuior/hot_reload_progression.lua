local compiler = require "fuior.compiler"
local fui = require "fuior.runtime"
local server = require "fuior.hot_reload_server"
local dispatcher = require "crit.dispatcher"

return function (arg)
  if type(arg) == "table" and arg.from_server then
    arg = server.fuior_data
  end

  if type(arg) == "string" then
    arg = { filename = arg }
  end

  local data = arg.data
  local filename = arg.filename

  local ok, err = xpcall(function ()
    local func
    if data then
      func = compiler.compile_string(data, filename)
    else
      func = compiler.compile(filename)
    end

    local runtime = fui.new()
    func(runtime)
  end, debug.traceback)

  if not ok then
    print("ERROR: " .. err)
  end

  dispatcher.dispatch("run_progression", { id = "main", })
end
