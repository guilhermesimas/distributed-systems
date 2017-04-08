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
print(port)
-- assert(server:setoption('tcp-nodelay',true))
server:settimeout(20)

local file = assert(io.open("./lyrics.txt","r"))
local string = file:read(1024);
local client
while 1 do
	client = assert(server:accept())
	if client==nil then
		server:close()
		return
	end
	local message = client:receive("*l")
	if message == "quit" then
		break
	end
	client:send(string)
	client:close()
end
server:close()
client:close()
