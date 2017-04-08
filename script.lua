-- Lua script used for calling the client and servers for different numbers of
-- requisitons and log the data

print("============INTERRUPTED SCRIPT===============")

-- starts server
-- sets timeout for the server so the process does not get stuck
-- in case of failure from counter-part
-- gets server output, which is the port number
local n=1;
while n<=10000000 do
	print("---------BEGIN N="..n.."--------------")
	local server = assert(io.popen("lua5.3 server.lua","r"))
	assert(os.execute("sleep 1"))
	local port = server:read("n")
	-- executes client passing in params
	assert(os.execute("lua5.3 client.lua "..port.." "..n))
	assert(os.execute("sleep 1"))
	server:close()
	print("---------END N="..n.."--------------")
	n=n*10
end

local socket = require("socket")
local server_connection = assert(socket.connect("*",port))
assert(server_connection:setoption('tcp-nodelay',true))
server_connection:send("quit\n")
server_connection:close()

print("============END SCRIPT===============")