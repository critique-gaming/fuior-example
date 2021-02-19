local sys_config = require "crit.sys_config"
local dispatcher = require "crit.dispatcher"

local http_server
local mime
if sys_config.debug then
  http_server = require "defnet.http_server"
  mime = require "socket.mime"
end

local PORT = 3648
local hs
local server = {}

local function load_fuior(matches)
  local ok, err = pcall(function ()
    local data = json.decode(mime.unb64(matches[1]))
    server.fuior_data = { data = data.data, filename = data.filename }

    if defos and defos.activate then
      defos.activate()
    end
    dispatcher.dispatch("run_progression", {
      id = "fuior",
      options = { from_server = true },
    })
  end)
  if ok then
    return hs.json('{}')
  else
    return hs.json('{ "error": "' .. err .. '" }')
  end
end

function server.init()
  hs = http_server.create(PORT)
  hs.router.get("/load_fuior/(.*)$", load_fuior)
  hs.router.unhandled(function(method, uri)
    return hs.json('{ "error": "not_found" }', http_server.NOT_FOUND)
  end)
  hs.start()
end

function server.final()
  hs.stop()
end

function server.update()
  hs.update()
end

if not http_server or not mime then
  local nop = function () end
  server.init = nop
  server.final = nop
  server.update = nop
end

return server
