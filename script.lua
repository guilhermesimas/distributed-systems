-- Lua script used for calling the client and servers for different numbers of
-- requisitons and log the data

print("============INTERRUPTED SCRIPT===============")

-- starts server
local server = assert(io.popen("lua5.3 server.lua","r"))
-- gets server output, which is the port number
local port = server:read("n")
local n=1;
while n<=100000 do
	print("---------BEGIN N="..n.."--------------")
	-- executes client passing in params
	assert(os.execute("lua5.3 client.lua "..port.." "..n))
	
	print("---------END N="..n.."--------------")
	n=n*10
end

local server_connection = assert(socket.connect("0.0.0.0",port))
assert(server_connection:setoption('tcp-nodelay',true))
server_connection:send("quit")
server_connection:close()

print("============END SCRIPT===============")