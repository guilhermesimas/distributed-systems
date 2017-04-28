rpc = require "luarpc"
socket = require "socket"

arq_interface = assert(io.open("interface.lua"):read("*a"))

-- local file_port = assert(io.open("port1.txt","r"))
-- local port = file_port:read("*n")
-- file_port:close()
port = io.read()

ip="0.0.0.0"

proxy = rpc.createProxy(ip,port,arq_interface)

print "Got here"

print(proxy.foo(1,2,3))

print(proxy.foo(1,2))