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
		a,b= proxy1.foo(i,i+1,i+2)
		proxy1.bar()
		a = proxy1.boo('hello')
	elseif n == 1 then
		a,b= proxy2.foo(i,i+1,i+2)
		proxy2.bar()
		a = proxy2.boo('hello')
	elseif n == 2 then
		a,b= proxy3.foo(i,i+1,i+2)
		proxy3.bar()
		a = proxy3.boo('hello')
	elseif n == 3 then
		a,b= proxy4.foo(i,i+1,i+2)
		proxy4.bar()
		a = proxy4.boo('hello')
	elseif n == 4 then
		a,b= proxy5.foo(i,i+1,i+2)
		proxy5.bar()
		a = proxy5.boo('hello')
	elseif n == 5 then
		a,b= proxy6.foo(i,i+1,i+2)
		proxy6.bar()
		a = proxy6.boo('hello')
	elseif n == 6 then
		a,b= proxy7.foo(i,i+1,i+2)
		proxy7.bar()
		a = proxy7.boo('hello')
	elseif n == 7 then
		a,b= proxy8.foo(i,i+1,i+2)
		proxy8.bar()
		a = proxy8.boo('hello')
	elseif n == 8 then
		a,b= proxy9.foo(i,i+1,i+2)
		proxy9.bar()
		a = proxy9.boo('hello')
	else
		a,b= proxy10.foo(i,i+1,i+2)
		proxy10.bar()
		a = proxy10.boo('hello')
	end
	-- print(a)
end

connection = assert(socket.connect(ip,port1))
local t_end = socket.gettime()

print(t_end-t_init)
-- print("Total time was: "..t_end-t_init)