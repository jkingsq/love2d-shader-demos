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
local cameraCenter = {0.0, 0.0}

-- This is automatically written to by setDefaultViewportTransform and should
-- not be modified elsewhere
local defaultViewportTransform = {1.0, 0.0, 0.0, 1.0}
local patternScale = 1.0
local zoomVelocity = 0.0

function reloadShader()
    shader = love.graphics.newShader(shaderFiles[shaderNum])
    sendViewportTransform()
    shader:send("time", love.timer.getTime())
end

function nextShader()
    shaderNum = shaderNum + 1
    if shaderNum > #shaderFiles then
        shaderNum = 1
    end

    resetViewport()
    reloadShader()
end

function setCanvas()
    if canvas ~= nil then
        canvas:release()
    end

    canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
end

function setDefaultViewportTransform()
    window = {love.graphics.getWidth(), love.graphics.getHeight()}

    minDimension = math.min(window[1], window[2])

    defaultViewportTransform = {
        window[1] / minDimension, 0,
        0, window[2] / minDimension
    }
end

function viewportTransform()
    return {
        defaultViewportTransform[1] / patternScale, defaultViewportTransform[2],
        defaultViewportTransform[3], defaultViewportTransform[4] / patternScale
    }
end

function sendViewportTransform()
    shader:send("window_scale", viewportTransform())
end

function setPatternScale(s)
    scale_factor = s/patternScale
    patternScale = s

    setCameraCenter(
        cameraCenter[1]*scale_factor,
        cameraCenter[2]*scale_factor
    )
    sendViewportTransform()
end

function setCameraCenter(centerX, centerY)
    cameraCenter = {centerX, centerY}
    sendCameraCenter()
end

function sendCameraCenter()
    print("Sending camera center: " .. cameraCenter[1] .. ", " .. cameraCenter[2])

    shader:send("mouse", {
        cameraCenter[1] / love.graphics.getWidth() + 0.5,
        cameraCenter[2] / love.graphics.getHeight() + 0.5
    })
end

function resetViewport()
    setCameraCenter(0.0, 0.0)
end

function love.load()
    defaultWindow = {love.graphics.getWidth(), love.graphics.getHeight()}

    reloadShader()
    setCanvas()
    setDefaultViewportTransform()
    resetViewport()
end

function love.draw()
    if not paused then
        shader:send("time", love.timer.getTime())
    end

    if love.mouse.isDown(1) then
        setCameraCenter(
            (cameraCenter[1] + dragEnd[1] - dragStart[1]),
            (cameraCenter[2] + dragEnd[2] - dragStart[2])
        )
        dragStart = dragEnd
    end
    love.graphics.setShader(shader)
    love.graphics.draw(canvas, 0, 0)
    love.graphics.setShader()

    fps = love.timer.getFPS()
    love.graphics.print(
        fps .. "\n" ..
        "Drag start: " .. dragStart[1] .. ", " .. dragStart[2] .. "\n" ..
        "Drag end: " .. dragEnd[1] .. ", " .. dragEnd[2] .. "\n" ..
        "Camera: " .. cameraCenter[1] .. ", " .. cameraCenter[2] ..
        "Zoom: " .. zoomVelocity
    , 0, 0)
end

function love.update(dt)
    if love.mouse.isDown(1) then
        dragEnd = {love.mouse.getX(), love.mouse.getY()}
    end

    if love.keyboard.isDown("=") then
        zoomVelocity = zoomVelocity + 0.02 * dt
    elseif love.keyboard.isDown("-") then
        zoomVelocity = zoomVelocity - 0.02 * dt
    elseif dt < 0.25 then
        zoomVelocity = zoomVelocity - 4 * zoomVelocity * dt
    else
        zoomVelocity = 0
    end

    if zoomVelocity ~= 0 then
        setPatternScale(patternScale + zoomVelocity)
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "f" then
        love.window.setFullscreen(not love.window.getFullscreen())
        setCanvas()
        setDefaultViewportTransform()
        resetViewport()
        sendViewportTransform()
    elseif key == "n" then
        nextShader()
        resetViewport()
    elseif key == "p" then
        paused = not paused
    elseif key == "r" then
        reloadShader()
        resetViewport()
    -- elseif key == "=" then
    --     setPatternScale(patternScale * 1.1)
    -- elseif key == "-" then
    --     setPatternScale(patternScale * 0.9)
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
        cameraCenter = {
            cameraCenter[1] + dragEnd[1] - dragStart[1],
            cameraCenter[2] + dragEnd[2] - dragStart[2]
        }

        love.mouse.setVisible(true)
    end
end
