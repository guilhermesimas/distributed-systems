rpc = require "luarpc"
socket = require "socket"

arq_interface = assert(io.open("interface.lua"):read("*a"))

local file_port = assert(io.open("port1.txt","r"))
local port1 = file_port:read("*n")
local port2 = file_port:read("*n")
local port3 = file_port:read("*n")
file_port:close()

ip="0.0.0.0"

proxy1 = rpc.createProxy(ip,port1,arq_interface)
proxy2 = rpc.createProxy(ip,port2,arq_interface)
proxy3 = rpc.createProxy(ip,port3,arq_interface)
proxy4 = rpc.createProxy(ip,port1,arq_interface)
proxy5 = rpc.createProxy(ip,port2,arq_interface)
proxy6 = rpc.createProxy(ip,port3,arq_interface)
proxy7 = rpc.createProxy(ip,port1,arq_interface)
proxy8 = rpc.createProxy(ip,port2,arq_interface)
proxy9 = rpc.createProxy(ip,port3,arq_interface)
proxy10 = rpc.createProxy(ip,port1,arq_interface)

local t_init = socket.gettime()

for i=0, 100, 1  do
	n = i%10 
	if n == 0 then
		a = proxy1.boo(i)
	elseif n == 1 then
		a = proxy2.boo(i)
	elseif n == 2 then
		a = proxy3.boo(i)
	elseif n == 3 then
		a = proxy4.boo(i)
	elseif n == 4 then
		a = proxy5.boo(i)
	elseif n == 5 then
		a = proxy6.boo(i)
	elseif n == 6 then
		a = proxy7.boo(i)
	elseif n == 7 then
		a = proxy8.boo(i)
	elseif n == 8 then
		a = proxy9.boo(i)
	else
		a = proxy10.boo(i)
	end
	-- print(a)
end

connection = assert(socket.connect(ip,port1))
local t_end = socket.gettime()

print("Total time was: "..t_end-t_init)