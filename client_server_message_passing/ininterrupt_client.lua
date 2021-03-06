-- This program aims to establish a connection between a client and a server 
-- that will be responsible for passing 1K strings. The client can make several
-- requests with the same connection. The connection will be shutdown
-- only when the client disconnects.
-- Authors: github.com/guilhermesimas ; github.com/claraszw
-- Date: 04.apr.2017

-- loading namespace
local socket = require("socket")

-- get server port number
local file_port = io.open("port.txt","r")
local port = file_port:read("*n")

-- gettin TCP connection, with local host IP address and server port
local server = assert(socket.connect("0.0.0.0",port))
local t_init = socket.gettime()

for i=1,arg[1] do
	server:send("download\n")
	local message = server:receive(1024)
end

local t_end = socket.gettime()

server:send("quit\n")
server:close()
print("Total client running time was <"..t_end - t_init .. ">s")

