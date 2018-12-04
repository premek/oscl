local socket = require "socket"
local decoder = require "oscl.decoder"

return function(host, port)
  local server = {}
  server.udp = socket.udp()
  server.udp:settimeout(0)
  server.udp:setsockname(host, port)
  server.handlers = {}

  server.handler = function(self, decodedMessage)
	for k,v in pairs(self.handlers) do
	  if string.match(decodedMessage.addr, '^'..k) then 
	    local status, err = pcall(v, unpack(decodedMessage))
	    if not status then
		  print("Error in handler function: " .. err)
		end
	  end
	end
  end

  server.update = function (self)
    local message = self.udp:receive(1024)
	if message ~= nil then
		local decoderSuccess, decodedMessage = pcall(decoder, message)
		if not decoderSuccess then
			print("Error in decoding: \n" .. decodedMessage)
		else
		    self:handler(decodedMessage)
		end
	end
  end

  return server
end

