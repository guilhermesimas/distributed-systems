socket = require "socket"
M = require "serialize"
print "Please specify IP:"

--local ip = io.read("l")

print "Please specify Port"

local port = io.read("*l")

function test()
local server = assert(socket.connect("0.0.0.0",port))

local message = M.marshall_call("foo", {1,2,'ola'})

server:send(message..'\n')

message = server:receive("*l")
print(message)
local result = M.unmarshall_ret(message)

print(result)

server:close()
return result
end

a,b=test()

print(a)
print(b)