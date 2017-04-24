rpc = require "luarpc"
M = require "serialize"

myobj1 = { foo = 
             function (a, b, c)
               return a+b, a+c
             end,
           bar = 
        	 function ()
        	 	
        	 end,
          boo = 
             function (s)
             	--print (s)
             	--t = M.unmarshall('return'..s)
             	return 10
             end
        }

-- myobj2 = { foo = 
--              function (a, b, s)
--                return a-b, "tchau"
--              end,
--           boo = 
--              function (n)
--                return 1
--              end
--         }

local file_port = io.open("port1.txt","w")
arq_interface = assert(io.open("interface.lua"):read("*a"))

ip, port = rpc.createServant(myobj1,arq_interface)
file_port:write(port..'\n')

ip, port = rpc.createServant(myobj1,arq_interface)
file_port:write(port..'\n')

ip, port = rpc.createServant(myobj1,arq_interface)
file_port:write(port..'\n')

file_port:close()

rpc.waitIncoming()