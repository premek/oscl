-- example usage with love2d
-- $ oscsend localhost 7773 /message/param i 255

local Server = require("oscl.server")
local server = Server("*", 7773)

local s = 100
local r = 0

server.handlers[".*"] = print -- log everything
server.handlers["/message"] = function() s=200 end
server.handlers["/message/param.*"] = function(address, val) r=val end


function love.draw(dt)
    love.graphics.setColor(r/255, 1, 1)
    love.graphics.circle("fill", 300, 300, s, 5)
end

function love.update(dt) 
 server:update()
 
 s=s-0.2
end


