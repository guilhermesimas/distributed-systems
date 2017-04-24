os.execute("rm clientrpc1.result clientrpc3.result clientrpc10.result ")
for i=1,arg[1] do
	-- print "For 1 client:"
	assert(os.execute("lua5.3 serverRPC.lua &"))
	assert(os.execute("sleep 0.01"))
	assert(os.execute("lua5.3 clientRPC1.lua >> clientrpc1.result"))
	-- print "For 3 client:"
	assert(os.execute("lua5.3 serverRPC.lua &"))
	assert(os.execute("sleep 0.01"))
	assert(os.execute("lua5.3 clientRPC3.lua >> clientrpc3.result"))
	-- print "For 10 client:"
	assert(os.execute("lua5.3 serverRPC.lua &"))
	assert(os.execute("sleep 0.01"))
	assert(os.execute("lua5.3 clientRPC10.lua >> clientrpc10.result"))
end
rpc1file = assert(io.open("clientrpc1.result","r"))
rpc3file = assert(io.open("clientrpc3.result","r"))
rpc10file = assert(io.open("clientrpc10.result","r"))

local rpc1_total = 0
for i=1,arg[1] do
	rpc1_total = rpc1_total + rpc1file:read("*n")
end
print("Total average time for 1 client:"..rpc1_total/arg[1])

local rpc3_total = 0
for i=1,arg[1] do
	rpc3_total = rpc3_total + rpc3file:read("*n")
end
print("Total average time for 3 client:"..rpc3_total/arg[1])

local rpc10_total = 0
for i=1,arg[1] do
	rpc10_total = rpc10_total + rpc10file:read("*n")
end
print("Total average time for 10 client:"..rpc10_total/arg[1])
