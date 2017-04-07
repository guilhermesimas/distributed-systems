-- This program aims to establish a connection between a client and a server 
-- that will be responsible for passing 1K strings. After passing the message 
-- the connection will be shut down
-- Authors: github.com/guilhermesimas ; github.com/claraszw
-- Date: 04.apr.2017

-- loading namespace
local socket = require("socket")

--print "Please specify IP:"

--local ip = io.read("l")

--print "Please specify Port"

local port = arg[1]

local t_init = socket.gettime()
for i=1,arg[2] do
	-- gettin TCP connection, with local host IP address and to any port (0)
	-- print("#"..i.."\n")
	local server = assert(socket.connect("0.0.0.0",port))
	assert(server:setoption('tcp-nodelay',true))
	server:send("Give me a string".."\n")
	local message = server:receive(1024)
	server:close()
end
local t_end = socket.gettime()
print("Total client running time was <"..t_end - t_init .. ">s")