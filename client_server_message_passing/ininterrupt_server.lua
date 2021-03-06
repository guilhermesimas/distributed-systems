-- This program aims to establish a connection between a client and a server 
-- that will be responsible for passing 1K strings. The client can make several
-- requests with the same connection. The connection will be shutdown
-- only when the client disconnects.
-- Authors: github.com/guilhermesimas ; github.com/claraszw
-- Date: 04.apr.2017

-- loading namespace
local socket = require("socket")

-- gettin TCP connection, with local host IP address and to any port (0)
local server = assert(socket.bind("*",0))
assert(server:setoption('tcp-nodelay',true))

-- get port number and write it in a file 
local ip, port = server:getsockname()
local file_port = assert(io.open("port.txt","w"))
file_port:write(port)
file_port:close()

local file = assert(io.open("lyrics.txt","r"))
local string = file:read(1024)
file:close()

-- accept client conection
local client = server:accept()

while 1 do
	local message = client:receive("*l")
	if message == "quit" then
		break;
	end
	client:send(string)
end

-- close client connection and delete port file
client:close()
os.execute("rm port.txt")
