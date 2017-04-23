rpc = require "luarpc"
socket = require "socket"

arq_interface = assert(io.open("interface.lua"):read("*a"))

local file_port = assert(io.open("port1.txt","r"))
local port = file_port:read("*n")
file_port:close()

ip="0.0.0.0"

proxy = rpc.createProxy(ip,port,arq_interface)

local t_init = socket.gettime()

for i=0, 100, 1  do 
	a= proxy.boo(i)
	print(a)
end

connection = assert(socket.connect(ip,port))
local t_end = socket.gettime()

print("Total time was: "..t_end-t_init)