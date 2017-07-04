MQTT = require('mqtt_library')


-- WINDOW_WIDTH = 700
-- WINDOW_HEIGHT = 700

N_TILES = 70

TILE_SIZE = 10

SPEED = 7

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
    elseif(keyPressed == "space") then
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
    myPlayerStarted = false
    speed = 100

    initPlayers = {{20,20,"right",COLOR_RED_TABLE},{50,20,"down",COLOR_BLUE_TABLE},
                    {50,50,"left",COLOR_GREEN_TABLE},{20,50,"up",COLOR_WHITE_TABLE}}

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

function love.draw()
    if(isGameStarted) then
        drawGrid()
        for i,player in ipairs(players) do
            love.graphics.print(player.x.."|"..player.y,i*200,400)
            player:draw()
            player:drawTail()
        end
    elseif(myPlayerStarted)then
        for i,player in ipairs(players) do
            if(startedPlayers[i]) then
                player:draw()
            end
        end

    else
        love.graphics.print("Press space to start game", 200, 200)
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
        --print "1"
        blocked_tiles[x] = {}
    end
    blocked_tiles[x][y] = true;
end

function collision(table)
    if (table.x >= N_TILES) or (table.y >= N_TILES ) or (table.x < 0) or (table.y) < 0 then
        -- print('OUCH! HIT THE WALL :/')
        -- print(table.x .."|"..N_TILES.."||".. table.y  .. "|")  
        return true
    end
    if blocked_tiles[table.x] == nil then
        --print "2"
        return false
    end
    if blocked_tiles[table.x][table.y] == true then
        --print "3"
        return true
    end
    -- print('TABLE X'.. table.x)
    -- print('TABLE X TILE SIZE: '.. table.x * TILE_SIZE )
    -- print('WINDOW_WIDTH: '.. WINDOW_WIDTH )
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
        if(playerNumber == myPlayer) then
            myPlayerStarted = true
        end

        startedPlayers[playerNumber] = true

        if(startedPlayersCount == totPlayers) then
            isGameStarted = true
        end

    elseif (topic == "directions") then
        info = loadstring('return'..message)()
        print("Player: " .. info.player .. "Direction: " .. info.direction)
        players[info.player].direction = info.direction
    end
end