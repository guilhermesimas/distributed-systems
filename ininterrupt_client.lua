-- This program aims to establish a connection between a client and a server 
-- that will be responsible for passing 1K strings. After passing the message 
-- the connection will be shut down
-- Authors: github.com/guilhermesimas ; github.com/claraszw
-- Date: 04.apr.2017

-- loading namespace
local socket = require("socket")

print "Please specify IP:"

--local ip = io.read("l")

print "Please specify Port"

local port = io.read("n")

-- gettin TCP connection, with local host IP address and to any port (0)
local server = assert(socket.connect("0.0.0.0",port))
local t_init = socket.gettime()

for i=1,200 do
	--local request = io.read("l").."\n"
	server:send("download\n")
	-- if request =="quit\n" then
	-- 	break;
	-- end
	local message = server:receive(1024)
	print("received")
end

server:send("quit\n")

local t_end = socket.gettime()

print("Total client ininterrupted time was " .. t_end-t_init .. "seconds \n")
server:close()
