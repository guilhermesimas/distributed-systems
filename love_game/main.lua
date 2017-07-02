WINDOW_WIDTH = 1000
WINDOW_HEIGHT = 1000

TILE_SIZE = 10

SPEED = 3

COLOR_GRAY = {255,255,255,100}
COLOR_GREEN = {0,255,0,255}
COLOR_GREEN_TAIL = {0,255,0,100}
COLOR_GREEN_TABLE = {head = COLOR_GREEN, tail = COLOR_GREEN_TAIL}

blocked_tiles = {}

i=0
c = "press any key"
count = 0
function love.keypressed(keypressed)
    c = keypressed
    if keypressed == "escape" then
        love.window.close()
    elseif keypressed == "right" or keypressed == "left" or keypressed == "up" or keypressed == "down" then
        player.direction = keypressed
    end

end
function love.load()
    love.window.setMode(WINDOW_WIDTH,WINDOW_HEIGHT,{resizable=false})

    player = spawnPlayer(COLOR_GREEN_TABLE)
end

function love.update(dt)
    if count > SPEED then
        count = 0
        player:move();
    end
    count = count + 1
end

function love.draw()
    love.graphics.print(player.x.."|"..player.y,400,400)
    drawGrid()
    player:draw()
    player:drawTail()
end

function drawGrid()
    original_color = {love.graphics.getColor()}
    love.graphics.setColor(unpack(COLOR_GRAY))
    for i=0,WINDOW_WIDTH,TILE_SIZE do
        love.graphics.line(i,0,i,WINDOW_HEIGHT)
        love.graphics.line(0,i,WINDOW_WIDTH,i)
    end
    love.graphics.setColor(unpack(original_color))
end

function spawnPlayer(color_table)
    return {
        x = 10,
        y = 10,
        tail = {},
        direction = "right",
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
        print "1"
        blocked_tiles[x] = {}
    end
    blocked_tiles[x][y] = true;
end

function collision(table)
    if blocked_tiles[table.x] == nil then
        print "2"
        return false
    end
    if blocked_tiles[table.x][table.y] == true then
        print "3"
        return true
    end
    return false
end