speed = 100;

function love.keypressed(key)
    direction = key
end

function love.load()
    direction = "right";
    quadrado = {x = 20,y = 20}
end

function love.update(dt)
    if direction == "right" then
        quadrado.x = quadrado.x + dt*speed;
    elseif direction == "left" then
        quadrado.x = quadrado.x - dt*speed;
    elseif direction == "down" then
        quadrado.y = quadrado.y + dt*speed;
    elseif direction == "up" then
        quadrado.y = quadrado.y - dt*speed;
    end

end

function love.draw()
    love.graphics.rectangle("fill",quadrado.x,quadrado.y,20,20)
end