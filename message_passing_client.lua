-- This program aims to establish a connection between a client and a server 
-- that will be responsible for passing 1K strings. After passing the message 
-- the connection will be shut down
-- Authors: github.com/guilhermesimas ; github.com/claraszw
-- Date: 04.apr.2017

-- loading namespace
local socket = require("socket")

print "Please specify IP:"

local ip = io.read("l")

print "Please specify Port"

local port = io.read("n")

-- gettin TCP connection, with local host IP address and to any port (0)
local server = assert(socket.connect(ip,port))

print(server:receive("*l"))