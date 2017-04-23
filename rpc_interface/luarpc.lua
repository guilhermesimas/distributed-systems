rpc={}
socket = require "socket"
M = require "serialize"

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
		-- print(load('return globalObj[\"'..name..'\"]'..args)())

	end

	table.insert(servants,servant)

	return servant["server"]:getsockname()

end

function rpc.waitIncoming()

	-- include all servers as observers 
	local obs={}

	for _,servant in ipairs(servants) do
		table.insert(obs,servant.server)
	end 
	-- call select for list of ready to read 
	while 1 do
		local readyRead, readyWrite, err = socket.select(obs,{},1)
		
		for _,server in ipairs(readyRead) do
			local client = server:accept()
			local ip,port = client:getsockname()
			-- receive message


			local message, err = client:receive("*l")
			if(message) then

				if(message=="QUIT") then
					break
				end
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
				client:close()
			else
			 -- print(err)
				return
			end
		end
	end
	
end

function rpc.createProxy(ip,port,arq_interface)

	-- create client
	-- create dynamic functions
	functions = {}
	interfaceTable=load('return '..arq_interface)()
	for name,sig in pairs(interfaceTable["methods"]) do
		-- build params table
		local params = {}
		for i,param in ipairs(sig["args"]) do
			if param["direction"]=="in" or param["direction"]=="inout" then
				params[#params+1] = param
				if param.type == "double" then
					params[#params].type = "number"
				end
			end
		end
		functions[name] = function (...)
			-- validate params
			-- print(#params.." "..#({...}))
			if #params > #({...}) then
				print "INSUFICIENT PARAMS"
			end
			for i,param in ipairs(params) do
					if type(({...})[i])~=param.type then
						print "INCORRECT PARAMETERS"
						print(type(({...})[i]).." != "..param.type)
						return nil
					end
					-- extra parameters dont matter
					if i>#param+1 then
						break
					end
			end
			connection = assert(socket.connect(ip,port))
			-- print(M.marshall_call(name,{...}))
			connection:send(M.marshall_call(name,{...}).."\n")
			ret_value = M.unmarshall_ret(connection:receive("*l"))
			connection:close()
			return table.unpack(ret_value)
		end
	end
	return functions
end

return rpc
