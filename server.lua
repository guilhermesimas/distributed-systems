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

print "Client connected"

local file = assert(io.open("lyrics.txt","r"))
local string = file:read(1024);

while 1 do
	local client = server:accept()
	local message = client:receive("*l")
	print(message)
	client:send(io.read("l").."\n")
	client:close()
end
