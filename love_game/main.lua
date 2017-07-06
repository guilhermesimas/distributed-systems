MQTT = require('mqtt_library')


-- WINDOW_WIDTH = 700
-- WINDOW_HEIGHT = 700

N_TILES = 100

TILE_SIZE = 10

SPEED = 1

COLOR_GRAY = {255,255,255,100}

COLOR_GREEN = {0,255,0,255}
COLOR_GREEN_TAIL = {0,255,0,100}

COLOR_BLUE = {0,0,255,255}
COLOR_BLUE_TAIL = {0,0,255,100}

COLOR_RED = {255,0,0,255}
COLOR_RED_TAIL = {255,0,0,100}

COLOR_WHITE = {255,255,255,255}
COLOR_WHITE_TAIL = {255,255,255,100}

COLOR_GREEN_TABLE = {head = COLOR_GREEN, tail = COLOR_GREEN_TAIL}
COLOR_BLUE_TABLE = {head = COLOR_BLUE, tail = COLOR_BLUE_TAIL}
COLOR_RED_TABLE = {head = COLOR_RED, tail = COLOR_RED_TAIL}
COLOR_WHITE_TABLE = {head = COLOR_WHITE, tail = COLOR_WHITE_TAIL}

blocked_tiles = {}

i=0
count = 0


function love.keypressed(keyPressed)
    print("Key: " .. keyPressed)
    if keyPressed == "escape" then
        love.window.close()
    elseif(keyPressed == "space" or keyPressed == " ") then
        mqttClient:publish("gameStart", myPlayer)
    elseif (keyPressed == "up" or keyPressed == "down" or keyPressed == "left" or keyPressed == "right") then
        mqttClient:publish("directions", "{direction = " .. "'"..keyPressed.."'" .. ", player = " .. myPlayer .. "}")
    end

end


function love.load()
    love.window.setMode(TILE_SIZE * N_TILES , TILE_SIZE * N_TILES,{resizable=false})

    myPlayer = 1
    totPlayers = 1
    startedPlayersCount = 0
    startedPlayers = {false,false,false,false}
    isGameStarted = false
    speed = 100

    deadPlayers = 0
    gameOver = false

    initPlayers = {{20,20,"right",COLOR_RED_TABLE},{N_TILES - 20,20,"down",COLOR_BLUE_TABLE},
                    {N_TILES - 20,N_TILES - 20,"left",COLOR_GREEN_TABLE},{20,N_TILES - 20,"up",COLOR_WHITE_TABLE}}

    players = {}

    mqttClient = MQTT.client.create("localhost", 1050, messageReceived)
    myID = os.time() .. love.math.random(200)
    mqttClient:connect(myID)
    mqttClient:subscribe({"entered",myID,"gameStart","directions"})

    mqttClient:publish("entered", myID)

    player = spawnPlayer(COLOR_GREEN_TABLE)
end

function love.update(dt)

    errorMessage = mqttClient:handler()
    if(errorMessage ~= nil) then
        print('Error: ' .. errorMessage)
    end

    if(isGameStarted) then
        if(not gameOver) then
            if count > SPEED then
                count = 0
                for _,player in ipairs(players) do
                    if(player.isDead == false) then
                        player:move()
                    end
                end
            end
            count = count + 1
        end
    end
end

function love.draw()

    if(gameOver and (not players[myPlayer].isDead)) then
        love.graphics.print("You Win! :)",(TILE_SIZE * N_TILES / 2) - 175, (TILE_SIZE * N_TILES / 2) - 50, 0 , 5, 5)
    elseif (gameOver) then
        love.graphics.print("You Lost :/",(TILE_SIZE * N_TILES / 2) - 175, (TILE_SIZE * N_TILES / 2) - 50, 0 , 5, 5)
    end

    if(isGameStarted) then
        --sdrawGrid()
        for i,player in ipairs(players) do
            -- love.graphics.print(player.x.."|"..player.y,i*200,400)
            player:draw()
            player:drawTail()
        end
    elseif(startedPlayers[myPlayer])then
        for i,player in ipairs(players) do
            if(startedPlayers[i]) then
                player:draw()
            end
        end

    else
        love.graphics.print("Press space to start game", (TILE_SIZE * N_TILES / 2) - 225, (TILE_SIZE * N_TILES / 2) - 20, 0, 2.5)
    end

end

function drawGrid()
    original_color = {love.graphics.getColor()}
    love.graphics.setColor(unpack(COLOR_GRAY))
    for i=0,N_TILES,1 do
        love.graphics.line(i * TILE_SIZE, 0 ,i * TILE_SIZE , N_TILES * TILE_SIZE)
        love.graphics.line(0,i * TILE_SIZE , N_TILES * TILE_SIZE , i * TILE_SIZE)
    end
    love.graphics.setColor(unpack(original_color))
end

function spawnPlayer(x,y,direction,color_table)
    return {
        x = x,
        y = y,
        tail = {},
        direction = direction,
        isDead = false,
        draw = function(table)
                original_color = {love.graphics.getColor()}
                love.graphics.setColor(unpack(color_table.head))
                love.graphics.rectangle("fill",table.x*TILE_SIZE,table.y*TILE_SIZE,TILE_SIZE,TILE_SIZE)
                love.graphics.setColor(unpack(original_color))
        end,
        move = function(arg_table)
            table.insert(arg_table.tail,{x=arg_table.x,y=arg_table.y})
            insertBlockTile(arg_table.x,arg_table.y)
            d = arg_table.direction
            if d == "right" then
                arg_table.x = arg_table.x + 1
            elseif d == "left" then
                arg_table.x = arg_table.x - 1
            elseif d == "up" then
                arg_table.y = arg_table.y - 1
            elseif d == "down" then
                arg_table.y = arg_table.y + 1
            end
            if collision(arg_table) == true then
                print "COLLISION"
                arg_table.isDead = true
                deadPlayers = deadPlayers + 1
                if(deadPlayers >= totPlayers-1) then
                    print("set game over ")
                    gameOver = true
                end
                arg_table.direction = "escape"
            end
        end,
        drawTail = function(table)
            for _,tile in ipairs(table.tail) do
                original_color = {love.graphics.getColor()}
                love.graphics.setColor(unpack(color_table.tail))
                love.graphics.rectangle("fill",tile.x*TILE_SIZE,tile.y*TILE_SIZE,TILE_SIZE,TILE_SIZE)
                love.graphics.setColor(unpack(original_color))
            end
        end
    }
end

function insertBlockTile(x,y)
    if blocked_tiles[x] == nil then
        blocked_tiles[x] = {}
    end
    blocked_tiles[x][y] = true;
end

function collision(table)
    if (table.x >= N_TILES) or (table.y >= N_TILES ) or (table.x < 0) or (table.y) < 0 then
        return true
    end
    if blocked_tiles[table.x] == nil then
        return false
    end
    if blocked_tiles[table.x][table.y] == true then
        return true
    end
    return false
end

function messageReceived(topic, message)
    print("Received: " .. topic .. ": " .. message)
    

    if(topic == "entered") then

        if(message ~= myID) then
            mqttClient:publish(message, "{player = " .. myPlayer .. ", hasStarted = " .. tostring(myPlayerStarted) .."}")
            totPlayers = totPlayers + 1
            print("Total Players: " .. totPlayers)
        end

        player = spawnPlayer(unpack(initPlayers[totPlayers]))
        table.insert(players,player)

    elseif (topic == myID) then

        totPlayers = totPlayers + 1
        myPlayer = myPlayer + 1

        info = loadstring('return'..message)()

        table.insert(players,spawnPlayer(unpack(initPlayers[totPlayers])))

        if(info.hasStarted) then
            startedPlayers[info.player] = true
            startedPlayersCount = startedPlayersCount + 1
        end
        print("Total Players: " .. totPlayers)

    elseif (topic == "gameStart") then


        startedPlayersCount = startedPlayersCount + 1
        print("Total Players: " .. totPlayers .. " Started Players Count: " .. startedPlayersCount)

        playerNumber = tonumber(message)
        startedPlayers[playerNumber] = true

        if(startedPlayersCount == totPlayers) then
            isGameStarted = true
        end

    elseif (topic == "directions") then
        info = loadstring('return'..message)()
        print("Player: " .. info.player .. "Direction: " .. info.direction)
        if players[info.player].direction == "left" or players[info.player].direction == "right" then
            if not(info.direction == "left" or info.direction == "right") then
                players[info.player].direction = info.direction
            end
        end
        if players[info.player].direction == "up" or players[info.player].direction == "down" then
            if not(info.direction == "up" or info.direction == "down") then
                players[info.player].direction = info.direction
            end
        end
    end
end