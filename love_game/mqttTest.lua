MQTT = require('mqtt_library')



function messageReceived(topic, message)
	print("Received: " .. topic .. ": " .. message)
	if (message == "quit") then running = false end
end


mqtt_client = MQTT.client.create("localhost", 1050, messageReceived)
mqtt_client:connect("lua mqtt client 1")
mqtt_client:subscribe({"first_test"})

local error_message = nil
local running = true

while (error_message == nil and running) do
  error_message = mqtt_client:handler()

  if (error_message == nil) then
    socket.sleep(1.0)  -- seconds
  end
end
