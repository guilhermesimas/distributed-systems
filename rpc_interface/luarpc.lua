rpc={}
socket = require "socket"
M = require "serialize"

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


function rpc.createServant(obj, arq_interface) -- create new Service
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

function rpc.waitIncoming()

	-- include all servers as observers 
	local obs={}

	for _,servant in ipairs(servants) do
		print(servant)
		table.insert(obs,servant.server:accept())
	end 
	-- call select for list of ready to read 
	while 1 do
		local readyRead, readyWrite, err = socket.select(obs,{},1)
		
		for _,client in ipairs(readyRead) do
			local ip,port = client:getsockname()
			-- receive message
			local message, err = client:receive("*l")
			if(message) then
				-- unmarshall message
				local name, params = M.unmarshall_call(message)
				-- call function
				args='('
				for i,arg in ipairs(params) do
					args=args..arg
					if i ~= #params then args = args..',' end

				end
				args=args..')'
				
				for _,servant in pairs(servants) do
					ipserver,portserver=servant.server:getsockname()
					if port == portserver then--
						globalClient = servant
						break
					end
				end

				
				result = {load('return globalClient[\"functions\"][\"'..name..'\"]'..args)()}
				
				-- marshall results
				message = M.marshall_ret(result)
				-- send message
				client:send(message..'\n')
			else
			 print(err)
			end
		end
	end
	
end

function rpc.createProxy(ip,port,interface)

	-- create client
	-- create dynamic functions
	-- marshall message
	-- receive results
	-- unmarshall
	-- return 
end


--arq_interface = assert(io.open("interface.lua"):read("*a"))
--createServant(myobj1,arq_interface)
return rpc
