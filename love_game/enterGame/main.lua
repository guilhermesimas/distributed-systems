MQTT = require('mqtt_library')

function love.keypressed(key)

	print("Key: " .. key)
    if(key == "return") then
		mqtt_client:publish("gameStart", myID)
	elseif (key == "up" or key == "down" or key == "left" or key == "right") then
		mqtt_client:publish("directions", "{direction = " .. "'"..key.."'" .. ", player = " .. myPlayer .. "}")
	end

end

function love.load()

	myPlayer = 1;
	totPlayers = 1;
	startedPlayers = 0;
	isGameStarted = false;
	speed = 100;

	initPlayers = {{quadrado = {x=20,y=20},direction= "right" }, {quadrado = {x=480,y=20},direction= "down"},
					{quadrado = {x=480,y=480},direction= "left" },{quadrado = {x=20,y=480},direction= "up" }}

	players = {}

	colors = {{255,0,0},{0,255,0},{0,0,255},{255,255,255}}


	mqtt_client = MQTT.client.create("localhost", 1050, messageReceived)
	myID = os.time() .. love.math.random(200)
	mqtt_client:connect(myID)
	mqtt_client:subscribe({"entered",myID,"gameStart","directions"})

	mqtt_client:publish("entered", myID)

	love.window.setMode(500,500)
	
end

function love.update(dt)
	error_message = mqtt_client:handler()
    if(isGameStarted) then

    	for _,player in ipairs(players) do
	    	if player.direction == "right" then
		        player.quadrado.x = player.quadrado.x + dt*speed;
		    elseif player.direction == "left" then
		        player.quadrado.x = player.quadrado.x - dt*speed;
		    elseif player.direction == "down" then
		        player.quadrado.y = player.quadrado.y + dt*speed;
		    elseif player.direction == "up" then
		        player.quadrado.y = player.quadrado.y - dt*speed;
		    end
		end
    end

end

function love.draw()
	if(isGameStarted) then
		for player, info in ipairs(players) do
			love.graphics.setColor(unpack(colors[player]))
    		love.graphics.rectangle("fill",info.quadrado.x,info.quadrado.y,20,20)
		end
    else
    	love.graphics.print("Press enter to start game", 200, 200)
    end

end


function messageReceived(topic, message)
	print("Received: " .. topic .. ": " .. message)
	

	if(topic == "entered") then

		if(message ~= myID) then
			mqtt_client:publish(message, "ack")
			totPlayers = totPlayers + 1
			print("Total Players: " .. totPlayers)
		end

		table.insert(players,initPlayers[totPlayers])


	elseif (topic == myID) then

		totPlayers = totPlayers + 1
		myPlayer = myPlayer + 1

		player = {quadrado = {x=x,y=y},direction= "right" }

		table.insert(players,initPlayers[totPlayers])
		print("Total Players: " .. totPlayers)

	elseif (topic == "gameStart") then

		print("Total Players: " .. totPlayers .. " Me: " .. myPlayer)

		startedPlayers = startedPlayers + 1
		if(startedPlayers == totPlayers) then
			isGameStarted = true
		end

	elseif (topic == "directions") then
		info = loadstring('return'..message)()
		--print('info: ' .. info)
		for index, value in ipairs(info) do
			print('index: ' .. index .. ' value: '..value)
		end
		print("Player: " .. info.player )--.. "Direction: " .. info.direction)
		players[info.player].direction = info.direction
	end
end

