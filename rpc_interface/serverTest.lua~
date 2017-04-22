rpc = require("luarpc")
--socket = require "socket"
--M = require "serialize"

myobj1 = { foo = 
             function (a, b, s)
               return a+b, "alo alo"
             end,
          boo = 
             function (n)
               return n
             end
        }
myobj2 = { foo = 
             function (a, b, s)
               return a-b, "tchau"
             end,
          boo = 
             function (n)
               return 1
             end
        }

arq_interface = assert(io.open("interface.lua"):read("*a"))

ip, port = rpc.createServant(myobj1,arq_interface)

print("ip:"..ip.. " port: "..port)

rpc.waitIncoming()
