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
local paused = false;
local dragStart = {0.0, 0.0}
local dragEnd = {0.0, 0.0}
local cameraPan = {0.0, 0.0}

function reloadShader()
    panCenter()
    shader = love.graphics.newShader(shaderFiles[shaderNum])
    setViewportTransform()
end

function nextShader()
    shaderNum = shaderNum + 1
    if shaderNum > #shaderFiles then
        shaderNum = 1
    end

    panCenter()
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

function panCenter()
    cameraPan = {love.graphics.getWidth() / 2, love.graphics.getHeight() / 2}
end

function love.load()
    defaultWindow = {love.graphics.getWidth(), love.graphics.getHeight()}

    panCenter()
    reloadShader()
    setCanvas()

    shader:send("mouse", {0.5, 0.5})
end

function love.draw()
    if not paused then
        shader:send("time", love.timer.getTime())
    end

    if love.mouse.isDown(1) then
        shader:send(
            "mouse",
            {
                (cameraPan[1] + dragEnd[1] - dragStart[1]) / love.graphics.getWidth(),
                (cameraPan[2] + dragEnd[2] - dragStart[2]) / love.graphics.getHeight()
            }
        )
    end
    love.graphics.setShader(shader)
    love.graphics.draw(canvas, 0, 0)
    love.graphics.setShader()

    fps = love.timer.getFPS()
    love.graphics.print(
        tostring(fps) .. "\n" ..
        "Drag start: " .. tostring(dragStart[1]) .. ", " .. tostring(dragStart[2]) .. "\n" ..
        "Drag end: " .. tostring(dragEnd[1]) .. ", " .. tostring(dragEnd[2]) .. "\n" ..
        "Camera:" .. tostring(cameraPan[1]) .. ", " .. tostring(cameraPan[2])
    , 0, 0)
end

function love.update()
    if love.mouse.isDown(1) then
        dragEnd = {love.mouse.getX(), love.mouse.getY()}
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "f" then
        love.window.setFullscreen(not love.window.getFullscreen())
        panCenter()
        setCanvas()
        setViewportTransform()
    elseif key == "n" then
        nextShader()
        shader:send("mouse", {0.5, 0.5})
    elseif key == "p" then
        paused = not paused
    elseif key == "r" then
        reloadShader()
        shader:send("mouse", {0.5, 0.5})
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        dragStart = {love.mouse.getX(), love.mouse.getY()}
        dragEnd = {love.mouse.getX(), love.mouse.getY()}

        love.mouse.setVisible(false)
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        cameraPan = {
            cameraPan[1] + dragEnd[1] - dragStart[1],
            cameraPan[2] + dragEnd[2] - dragStart[2]
        }

        love.mouse.setVisible(true)
    end
end
