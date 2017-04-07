-- This program aims to establish a connection between a client and a server 
-- that will be responsible for passing 1K strings. After passing the message 
-- the connection will be shut down
-- Authors: github.com/guilhermesimas ; github.com/claraszw
-- Date: 04.apr.2017

-- loading namespace
local socket = require("socket")

-- gettin TCP connection, with local host IP address and to any port (0)
local server = assert(socket.bind("*",0))
assert(server:setoption('tcp-nodelay',true))

local ip, port = server:getsockname()

print(port)

local file = assert(io.open("./lyrics.txt","r"))
local string = file:read(1024);
while 1 do
	local client = server:accept()
	local message = client:receive("*l")
	if message == "quit" then
		break
	end
	client:send(string)
	client:close()
end
client:close()
