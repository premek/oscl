-- example usage with love2d
-- $ oscsend localhost 7773 /message/param i 255

local Server = require("oscl.server")
local server = Server("*", 7773)

local s,p,r,x=0,0,0,0

server.handlers["/midi/op%-z_midi_.*/.*/16/note_on"] = function(_address, note, _velocity) p=note; s=200 end
server.handlers[".*"] = print -- log everything
--server.handlers["/midi/op%-z_midi_1/1/clock"] = function() t=t+1 end

function love.draw()
    love.graphics.setColor((r-55)*20/255, (r-60)*10/255, 1)
    love.graphics.circle("fill", (p-30)*10, 300, s, (x-70)%10+3)
end

function love.update(_dt)
 server:update()
 s=s-0.4
end
