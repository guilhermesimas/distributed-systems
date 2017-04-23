rpc = require "luarpc"

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

local file_port = io.open("port1.txt","w")
arq_interface = assert(io.open("interface.lua"):read("*a"))

createServant(myobj1,arq_interface)
ip, port = rpc.createServant(myobj1,arq_interface)
file_port:write(port..'\n')

ip, port = rpc.createServant(myobj1,arq_interface)
file_port:write(port..'\n')

ip, port = rpc.createServant(myobj2,arq_interface)
file_port:write(port..'\n')

file_port:close()

waitIncoming()