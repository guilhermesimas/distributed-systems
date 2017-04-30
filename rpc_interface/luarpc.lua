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
		args={}
		for i,arg in ipairs(sig["args"]) do
			if arg["type"]=='double' then
				table.insert(args,defaultNumber)
			elseif arg["type"]=='string' then
				table.insert(args,defaultString)
			end
		end
		if pcall(obj[name],table.unpack(args)) ~= true then
			print "OBJECT DOES NOT MATCH INTERFACE"
			return nil
		end
	end
	servants[servant.server] = servant
	return servant.server:getsockname()

end

function rpc.waitIncoming()

	-- include all servers as observers
	local obs={}

	for _,servant in pairs(servants) do
		table.insert(obs,servant.server)
	end 
	-- call select for list of ready to read 
	while 1 do
		local readyRead, readyWrite, err = socket.select(obs,{},1)
		
		for _,server in ipairs(readyRead) do
			local client = server:accept()
			-- receive message
			local message, err = client:receive("*l")
			if(message) then
				if(message=="QUIT") then
					break
				end
				-- unmarshall message
				local name, params = M.unmarshall_call(message)
				-- call function in protected
				result = {pcall(servants[server].functions[name],table.unpack(params))}
				safe = table.remove(result,1)
				if safe ~= true then
					-- if error was thrown send error message
					message = "___ERRORPC: Error on function call"
				else 
					-- marshall results
					message = M.marshall_ret(result)
				end
				-- send message
				client:send(message..'\n')
				client:close()
			else
				return
			end
		end
	end
	
end

function rpc.createProxy(ip,port,arq_interface)

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
			if #params > #({...}) then
				print "INSUFICIENT PARAMS"
				return nil
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
			connection:send(M.marshall_call(name,{...}).."\n")
			ret = connection:receive("*l")
			connection:close()
			if string.starts(ret,"___ERRORPC:") then
				return ret
			end
			ret_value = M.unmarshall_ret(ret)
			return table.unpack(ret_value)
		end
	end
	return functions
end

function string.starts(String,Start)
	return string.sub(String,1,string.len(Start))==Start
end

return rpc
