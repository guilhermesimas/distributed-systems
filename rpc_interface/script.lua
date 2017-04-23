print "For 1 client:"
assert(os.execute("lua5.3 serverRPC.lua &"))
assert(os.execute("sleep 1"))
assert(os.execute("lua5.3 clientRPC1.lua"))
print "For 3 client:"
assert(os.execute("lua5.3 serverRPC.lua &"))
assert(os.execute("sleep 1"))
assert(os.execute("lua5.3 clientRPC3.lua"))
print "For 10 client:"
assert(os.execute("lua5.3 serverRPC.lua &"))
assert(os.execute("sleep 1"))
assert(os.execute("lua5.3 clientRPC10.lua"))
