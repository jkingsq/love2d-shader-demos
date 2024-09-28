local shader
local canvas
local defaultWindow
local shaderNum = 1
local shaderFiles = {
    "checkerboard.frag",
    "waves.frag",
    "star_grid.frag",
    "wheel.frag"
}

function reloadShader()
    shader = love.graphics.newShader(shaderFiles[shaderNum])
    setViewportTransform()
end

function nextShader()
    shaderNum = shaderNum + 1
    if shaderNum > #shaderFiles then
        shaderNum = 1
    end

    reloadShader()
end

function setCanvas()
    if canvas ~= nil then
        canvas:release()
    end

    canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
end

function setViewportTransform()
    window = {love.graphics.getWidth(), love.graphics.getHeight()}
    maxDimension = math.max(defaultWindow[1], defaultWindow[2])

    viewportTransform = {
        maxDimension / window[1], 0,
        0, maxDimension / window[2]
    }

    shader:send("window_scale", viewportTransform)
end

function setViewportTransform()
    window = {love.graphics.getWidth(), love.graphics.getHeight()}
    minDimension = math.min(window[1], window[2])

    viewportTransform = {
        window[1] / minDimension, 0,
        0, window[2] / minDimension
    }

    shader:send("window_scale", viewportTransform)
end

function love.load()
    defaultWindow = {love.graphics.getWidth(), love.graphics.getHeight()}

    reloadShader()
    setCanvas()

    shader:send("mouse", {0.5, 0.5})
end

function love.draw()
    shader:send("time", love.timer.getTime())
    if love.mouse.isDown(1) then
        shader:send(
            "mouse",
            {
                love.mouse.getX() / love.graphics.getWidth(),
                love.mouse.getY() / love.graphics.getHeight()
            }
        )
    end
    love.graphics.setShader(shader)
    love.graphics.draw(canvas, 0, 0)
    love.graphics.setShader()

    fps = love.timer.getFPS()
    love.graphics.print(tostring(fps), 0, 0)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "r" then
        reloadShader()
        shader:send("mouse", {0.5, 0.5})
    elseif key == "f" then
        love.window.setFullscreen(not love.window.getFullscreen())
        setCanvas()
        setViewportTransform()
    elseif key == "n" then
        nextShader()
        shader:send("mouse", {0.5, 0.5})
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        love.mouse.setVisible(false)
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        love.mouse.setVisible(true)
    end
end
