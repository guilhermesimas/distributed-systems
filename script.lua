-- Lua script used for calling the client and servers for different numbers of
-- requisitons and log the data

print("============INTERRUPTED SCRIPT===============")

-- starts server
-- sets timeout for the server so the process does not get stuck
-- in case of failure from counter-part
-- gets server output, which is the port number
local n=1;
local port
while n<=10000000 do
	print("---------BEGIN N="..n.."--------------")
	assert(os.execute("lua5.3 server.lua>port.txt &"))
	assert(os.execute("sleep 1"))
	local port_file = io.open("port.txt","r")
	port = port_file:read("n")
	print("Using port "..port)
	assert(os.execute("rm port.txt"))
	-- executes client passing in params
	assert(os.execute("lua5.3 client.lua "..port.." "..n))
	assert(os.execute("sleep 1"))
	print("---------END N="..n.."--------------")
	n=n*10
end

local socket = require("socket")
local server_connection = assert(socket.connect("0.0.0.0",port))
server_connection:send("quit\n")
server_connection:close()

print("============END SCRIPT===============")