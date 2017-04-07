-- This program aims to establish a connection between a client and a server 
-- that will be responsible for passing 1K strings. After passing the message 
-- the connection will be shut down
-- Authors: github.com/guilhermesimas ; github.com/claraszw
-- Date: 04.apr.2017

-- loading namespace
local socket = require("socket")

-- gettin TCP connection, with local host IP address and to any port (0)
local server = assert(socket.bind("*",0))

local ip, port = server:getsockname()

print("Local IP:" .. ip .. " Port:" .. port)
local file_port = assert(io.open("port.txt","w"))
file_port:write(port)
file_port:close()

local file = assert(io.open("lyrics.txt","r"))
local string = file:read(1024)
file:close()

local client = server:accept()
local t_init = socket.gettime()
print "Client connected"


while 1 do
	local message = client:receive("*l")
	if message == "quit" then
		break;
	end
	client:send(string)
end

local t_end = socket.gettime()

print("Total server ininterrupted time was " .. t_end-t_init .. "seconds \n")
client:close()