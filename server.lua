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

local client = server:accept()

print "Client connected"

while 1 do
	local message = client:receive("*l")
	print(message)
	client:send(io.read("l").."\n")
end

client:shutdown("both")