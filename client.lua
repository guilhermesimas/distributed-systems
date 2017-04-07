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

local t_init = socket.gettime()
for i=1,arg[1] do
	-- gettin TCP connection, with local host IP address and to any port (0)
	-- print("#"..i.."\n")
	local server = assert(socket.connect("0.0.0.0",port))
	server:send("Give me a string".."\n")
	local message = server:receive(1024)
	server:close()
end
local server = assert(socket.connect("0.0.0.0",port))
server:send("quit\n")
server:close()
local t_end = socket.gettime()
print("Total client running time was <"..t_end - t_init .. ">s")