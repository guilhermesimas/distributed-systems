local rpc = require("luarpc")
arq_interface = assert(io.open("interface.lua"):read("*a"))
print "port"
local port = io.read("*l")
local proxy = rpc.createProxy("0.0.0.0",port,arq_interface)
a,b = proxy.foo(0.5,7)
print(a.." "..b)
-- proxy.foo(0.5)
-- proxy.boo(2)
print "done proxy"