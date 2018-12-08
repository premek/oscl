local socket = require "socket"
local decoder = require "oscl.decoder"

return function(host, port)
  local server = {}
  server.udp = socket.udp()
  server.udp:settimeout(0)
  server.udp:setsockname(host, port)
  server.handlers = {}

  server.handle = function(self, decodedMessage)
	for k,v in pairs(self.handlers) do
	  if string.match(decodedMessage.addr, '^'..k..'$') then 
	    local status, err = pcall(v, decodedMessage.addr, unpack(decodedMessage))
	    if not status then
		  print("Error in handler function: " .. err)
		end
	  end
	end
  end

 server.doesHandle = function(self, addr)
	for k,v in pairs(self.handlers) do
	  if string.match(addr, '^'..k..'$') then return true end
	end
	return false
  end

  server.update = function (self)
    local message = self.udp:receive(1024)
	if message ~= nil then
		local success, err = pcall(decoder, message, self)
		if not success then
			print("Error in decoding: \n" .. err)
		end
	end
  end

  return server
end

