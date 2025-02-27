local shader
local canvas
local defaultWindow
local shaderNum = 1
local shaderFiles = {
    "slices.frag",
    "checkerboard.frag",
    "waves.frag",
    "star_grid.frag",
    "wheel.frag"
}
local debugInfo = false
local paused = false
local dragStart = {0.0, 0.0}
local dragEnd = {0.0, 0.0}
local cameraCenter = {0.0, 0.0}

-- This is automatically written to by setDefaultViewportTransform and should
-- not be modified elsewhere
local defaultViewportTransform = {1.0, 0.0, 0.0, 1.0}
local patternScale = 1.0
local zoomVelocity = 1.0

local timeOffset = 0.0
local pausedTime = 0.0
local timeStepIncrement = 1.0
local timeStepMult = 2.0

function reloadShader()
    shader = love.graphics.newShader(shaderFiles[shaderNum])
    sendViewportTransform()
end

function nextShader()
    shaderNum = shaderNum + 1
    if shaderNum > #shaderFiles then
        shaderNum = 1
    end

    resetViewport()
    reloadShader()
end

function prevShader()
    shaderNum = shaderNum - 1
    if shaderNum < 1 then
        shaderNum = #shaderFiles
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
    shader:send("mouse", {
        cameraCenter[1] / love.graphics.getWidth() + 0.5,
        cameraCenter[2] / love.graphics.getHeight() + 0.5
    })
end

function sendTime()
    shader:send("time", pausedTime + timeOffset)
end

function resetViewport()
    setCameraCenter(0.0, 0.0)
end

function isShiftHeld()
    return love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
end

function increaseTimestep()
    timeStepIncrement = timeStepIncrement * timeStepMult

    timeStepMult = timeStepMult == 2.0 and 5.0 or 2.0
end

function decreaseTimestep()
    timeStepIncrement = timeStepIncrement / (timeStepMult == 2.0 and 5.0 or 2.0)

    timeStepMult = timeStepMult == 2.0 and 5.0 or 2.0
end

function love.load()
    defaultWindow = {love.graphics.getWidth(), love.graphics.getHeight()}

    reloadShader()
    setCanvas()
    setDefaultViewportTransform()
    resetViewport()
end

function love.draw()
    sendTime()

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
    if debugInfo then
        love.graphics.print(
            fps .. "\n" ..
            "Camera: " .. cameraCenter[1] .. ", " .. cameraCenter[2] .. "\n" ..
            "Zoom coeff: " .. zoomVelocity .. "\n" ..
            "Pattern scale: " .. patternScale .. "\n" ..
            "Time offset: " .. timeOffset .. "\n" ..
            "Time increment: " .. timeStepIncrement .. "\n" ..
            "Shift held: " .. tostring(isShiftHeld())
        , 0, 0)
    end
end

function love.update(dt)
    if not paused then
        pausedTime = love.timer.getTime()
    end

    if love.mouse.isDown(1) then
        dragEnd = {love.mouse.getX(), love.mouse.getY()}
    end

    if love.keyboard.isDown("=") and not isShiftHeld() then
        zoomVelocity = zoomVelocity * (1.0 + 0.05 * dt)
    elseif love.keyboard.isDown("-") and not isShiftHeld() then
        zoomVelocity = zoomVelocity * (1.0 - 0.05 * dt)
    else
        zoomVelocity = zoomVelocity - (zoomVelocity - 1) * dt
    end

    if isShiftHeld() then
        if love.keyboard.isDown(",") then
            timeOffset = timeOffset - timeStepIncrement * dt
        elseif love.keyboard.isDown(".") then
            timeOffset = timeOffset + timeStepIncrement * dt
        end
    end

    if zoomVelocity ~= 0 then
        setPatternScale(patternScale * zoomVelocity)
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
    elseif key == "n" and not isShiftHeld() then
        nextShader()
        resetViewport()
    elseif key == "n" and isShiftHeld() then
        prevShader()
        resetViewport()
    elseif key == "p" then
        if paused then
            timeOffset = timeOffset - (love.timer.getTime() - pausedTime)
        end

        paused = not paused
    elseif key == "r" then
        reloadShader()
        resetViewport()
    elseif key == "0" and isShiftHeld() then
        timeOffset = 0.0
        pausedTime = 0.0
    elseif key == "0" and not isShiftHeld() then
        setPatternScale(1.0)
    elseif key == "-" and isShiftHeld() then
        decreaseTimestep()
    elseif key == "=" and isShiftHeld() then
        increaseTimestep()
    elseif key == "," and not isShiftHeld() then
        timeOffset = timeOffset - timeStepIncrement
        sendTime()
    elseif key == "." and not isShiftHeld() then
        timeOffset = timeOffset + timeStepIncrement
        sendTime()
    elseif key == "/" then
        debugInfo = not debugInfo
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

function love.wheelmoved(x, y)
    if y ~= 0 then
        zoomVelocity = zoomVelocity * (1.0 + 0.25 * y * love.timer.getDelta())
    end
end
