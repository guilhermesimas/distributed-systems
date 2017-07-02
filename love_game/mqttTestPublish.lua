MQTT = require('mqtt_library')
socket = require('socket')


-- function messageReceived(topic, message)
-- 	print("Received: " .. topic .. ": " .. message)
-- 	if (message == "quit") then running = false end
-- end


mqtt_client = MQTT.client.create("localhost", 1050, messageReceived)
mqtt_client:connect("lua mqtt client 2")
-- mqtt_client:subscribe({"first_test"})

local error_message = nil
local running = true

while (error_message == nil and running) do
	print('loop publish')
  error_message = mqtt_client:handler()

  if (error_message == nil) then
  	mqtt_client:publish("first_test", "test message")
    socket.sleep(1.0)  -- seconds
  else
  	print('Error: ',error_message)
  end
end