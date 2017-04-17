-- Lua script used for calling the client and servers for different numbers of
-- requisitons and log the data

print("============INTERRUPTED SCRIPT===============")

os.execute("rm port1.txt")
local n=1;
while n<=100000 do
	print("---------BEGIN N="..n.."--------------")
	assert(os.execute("lua5.3 server.lua &"))
	assert(os.execute("sleep 1"))
	assert(os.execute("lua5.3 client.lua "..n))
	-- executes client passing in params
	print("---------END N="..n.."--------------")
	n=n*10
end

print("============END SCRIPT===============")
print("============ININTERRUPTED SCRIPT===============")

os.execute("rm port.txt")
local n=1;
while n<=100000 do
	print("---------BEGIN N="..n.."--------------")
	assert(os.execute("lua5.3 ininterrupt_server.lua &"))
	assert(os.execute("sleep 1"))
	assert(os.execute("lua5.3 ininterrupt_client.lua "..n))
	-- executes client passing in params
	print("---------END N="..n.."--------------")
	n=n*10
end

print("============END SCRIPT===============")