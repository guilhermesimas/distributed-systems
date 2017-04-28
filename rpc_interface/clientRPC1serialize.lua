rpc = require "luarpc"
socket = require "socket"
M = require "serialize"

arq_interface = assert(io.open("interface.lua"):read("*a"))

local file_port = assert(io.open("port1.txt","r"))
local port = file_port:read("*n")
file_port:close()

ip="0.0.0.0"

proxy = rpc.createProxy(ip,port,arq_interface)


local t = {}

for i=0, 10, 0.1  do
	table.insert(t,i)
end 

local t_init = socket.gettime()
local avgSerializeTime = 0;
for i=0, 100, 1  do
	t_init_serialize = socket.gettime()
	s = M.marshall(t)
	-- print(s)
	t_end_serialize = socket.gettime()
	avgSerializeTime= avgSerializeTime+t_end_serialize -t_init_serialize
	a = proxy.boo(s)
	-- print(a)
end

connection = assert(socket.connect(ip,port))
local t_end = socket.gettime()

print("Total time was: "..t_end-t_init)
print("Average serialize time was: "..avgSerializeTime/100)
