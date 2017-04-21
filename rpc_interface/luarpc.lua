socket = require "socket"

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

servants={}
defaultNumber=1
defaultString='\'\''

function interface(t)
	return t
end


function createServant(obj, arq_interface) -- create new Service
	-- create a new service object, add it to the table and returns ip and port
	interfaceTable=load('return '..arq_interface)()
	servant={}
	servant["functions"]=obj
	globalObj = obj
	servant["server"] = assert(socket.bind("*",0))
	assert(servant["server"]:setoption('tcp-nodelay',true))

	for name,sig in pairs(interfaceTable["methods"]) do
		args='('
		for i,arg in ipairs(sig["args"]) do
			if arg["type"]=='double' then
				args=args..defaultNumber
			elseif arg["type"]=='string' then
				args=args..defaultString
			end

		if i ~= #sig["args"] then args = args..',' end

		end
		args=args..')'
		print(load('return globalObj[\"'..name..'\"]'..args)())

	end


	table.insert(servants,servant)

	return servant["server"]:getsockname()


end

function waitIncoming()
end

function createProxy(ip,port,interface)
	-- body
end


arq_interface = assert(io.open("interface.lua"):read("*a"))
createServant(myobj1,arq_interface)

