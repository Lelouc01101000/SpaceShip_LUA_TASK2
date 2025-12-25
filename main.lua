-- main.lua

-- Require Class Files
Player = require "Player"
Laser = require "Laser"
Meteor = require "Meteor"
PhoenixMeteor = require "PhoenixMeteor"
TrackerMeteor = require "TrackerMeteor"
CrabMeteor = require "CrabMeteor"
LobsterMeteor = require "LobsterMeteor"
AnimatedExplosion = require "AnimatedExplosion"

-- Pixel Collision Helper
function checkPixelCollision(a, b) 
    local ax1 = a.x - a.width / 2
    local ay1 = a.y - a.height / 2
    local ax2 = a.x + a.width / 2
    local ay2 = a.y + a.height / 2

    local bx1 = b.x - b.width / 2
    local by1 = b.y - b.height / 2
    local bx2 = b.x + b.width / 2
    local by2 = b.y + b.height / 2

    if not (ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1) then
        return false 
    end
    
    local overlapX1 = math.max(ax1, bx1)
    local overlapY1 = math.max(ay1, by1)
    local overlapX2 = math.min(ax2, bx2)
    local overlapY2 = math.min(ay2, by2)

    local bRot = b.rotation or 0
    local angleRad = math.rad(-bRot) 
    local cos_t = math.cos(angleRad)
    local sin_t = math.sin(angleRad)

    for x = math.floor(overlapX1), math.ceil(overlapX2) do
        for y = math.floor(overlapY1), math.ceil(overlapY2) do
            local localAx = math.floor(x - ax1)
            local localAy = math.floor(y - ay1)
            if localAx >= 0 and localAx < a.width and localAy >= 0 and localAy < a.height then
                local _, _, _, a_alpha = a.imageData:getPixel(localAx, localAy)
                if a_alpha > 0 then
                    local relativeBx = x - b.x
                    local relativeBy = y - b.y
                    local unrotatedBx = relativeBx * cos_t + relativeBy * sin_t
                    local unrotatedBy = -relativeBx * sin_t + relativeBy * cos_t
                    local localBx = unrotatedBx + b.width / 2
                    local localBy = unrotatedBy + b.height / 2

                    if localBx >= 0 and localBx < b.width and localBy >= 0 and localBy < b.height then
                        local _, _, _, b_alpha = b.imageData:getPixel(math.floor(localBx), math.floor(localBy))
                        if b_alpha > 0 then return true end
                    end
                end
            end
        end
    end
    return false 
end

-- Spawn Functions
function spawnMeteor() 
    local x = love.math.random(0, WINDOW_WIDTH)
    local y = love.math.random(-200, -100)
    table.insert(meteors, Meteor:new(x, y, meteorSurf, meteorImageData))
end

function spawnPhoenixMeteor()
    local x = love.math.random(0, WINDOW_WIDTH)
    local y = love.math.random(-200, -100)
    table.insert(phoenixMeteors, PhoenixMeteor:new(x, y, phoenixSurf1, phoenixImageData1, phoenixSurf2, phoenixImageData2))
end

function spawnTrackerMeteor()
    local x = love.math.random(0, WINDOW_WIDTH)
    local y = love.math.random(-200, -100)
    table.insert(trackerMeteors, TrackerMeteor:new(x, y, player.x, player.y, trackerSurf, trackerImageData))
end

function spawnCrabMeteor()
    local x = player.x
    local y = love.math.random(-200, -100)
    table.insert(crabMeteors, CrabMeteor:new(x, y, crabSurf, crabImageData, player))
end

function spawnLobsterMeteor()
    local x = player.x
    local y = love.math.random(-200, -100)
    table.insert(lobsterMeteors, LobsterMeteor:new(x, y, lobsterSurf, lobsterImageData))
end

-- UI Drawing Helpers
function drawSettings()
    love.graphics.draw(settingsBackgroundSurf, 0, 0)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont("images/Oxanium-Bold.ttf", 40))
    love.graphics.printf("SETTINGS", 0, 50, WINDOW_WIDTH, "center")
    love.graphics.setFont(font)

    local sliders = {
        {name = "Game Music", val = tempVolMusic, y = 200},
        {name = "Explosion SFX", val = tempVolExplosion, y = 280},
        {name = "Laser SFX", val = tempVolLaser, y = 360}
    }
    local sliderWidth = 300
    local sliderX = WINDOW_WIDTH / 2 - sliderWidth / 2
    
    for i, s in ipairs(sliders) do
        love.graphics.printf(s.name .. ": " .. math.floor(s.val * 100) .. "%", 0, s.y - 30, WINDOW_WIDTH, "center")
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.setLineWidth(4)
        love.graphics.line(sliderX, s.y, sliderX + sliderWidth, s.y)
        
        local handleX = sliderX + (s.val * sliderWidth)
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("fill", handleX, s.y, 10)
    end
    
    local mx, my = love.mouse.getPosition()
    -- Save Button
    local isHoveringSave = mx > (saveButton.x - saveButton.width/2) and mx < (saveButton.x + saveButton.width/2) and my > (saveButton.y - saveButton.height/2) and my < (saveButton.y + saveButton.height/2)
    if isHoveringSave then love.graphics.setColor(0.9, 0.9, 0.9) else love.graphics.setColor(0.5, 0.5, 0.5) end
    love.graphics.rectangle("fill", saveButton.x - saveButton.width/2, saveButton.y - saveButton.height/2, saveButton.width, saveButton.height, 10, 10)
    if isHoveringSave then love.graphics.setColor(0, 0, 0) else love.graphics.setColor(1, 1, 1) end
    love.graphics.printf(saveButton.text, saveButton.x - saveButton.width/2, saveButton.y - font:getHeight()/2, saveButton.width, "center")

    -- Back Button
    local isHoveringBack = mx > (backButton.x - backButton.width/2) and mx < (backButton.x + backButton.width/2) and my > (backButton.y - backButton.height/2) and my < (backButton.y + backButton.height/2)
    if isHoveringBack then love.graphics.setColor(0.9, 0.9, 0.9) else love.graphics.setColor(0.5, 0.5, 0.5) end
    love.graphics.rectangle("fill", backButton.x - backButton.width/2, backButton.y - backButton.height/2, backButton.width, backButton.height, 10, 10)
    if isHoveringBack then love.graphics.setColor(0, 0, 0) else love.graphics.setColor(1, 1, 1) end
    love.graphics.printf(backButton.text, backButton.x - backButton.width/2, backButton.y - font:getHeight()/2, backButton.width, "center")
    love.graphics.setColor(1, 1, 1)
end

function drawMenu()
    love.graphics.draw(menuBackgroundSurf, 0, 0)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont("images/Oxanium-Bold.ttf", 40))
    love.graphics.printf("SPACE SHOOTER", 0, WINDOW_HEIGHT / 2 - 170, WINDOW_WIDTH, "center")
    love.graphics.setFont(font)

    local scores = scoresByDifficulty[difficulty]
    love.graphics.printf("Highest Score ("..difficulty:upper().."): " .. scores.highScore, 0, WINDOW_HEIGHT / 2 - 120, WINDOW_WIDTH, "center")
    love.graphics.printf("Best Time ("..difficulty:upper().."): " .. math.floor(scores.highTime) .. "s", 0, WINDOW_HEIGHT / 2 - 90, WINDOW_WIDTH, "center")

    local mx, my = love.mouse.getPosition()
    if Paused then
        local canResume = (difficulty == activeGameDifficulty)
        local isHoveringResume = mx > (resumeButton.x - resumeButton.width/2) and mx < (resumeButton.x + resumeButton.width/2) and my > (resumeButton.y - resumeButton.height/2) and my < (resumeButton.y + resumeButton.height/2)
        if canResume then
            if isHoveringResume then love.graphics.setColor(0.9, 0.9, 0.9) else love.graphics.setColor(0.5, 0.5, 0.5) end
        else
            love.graphics.setColor(0.2, 0.2, 0.2, 0.7)
        end
        love.graphics.rectangle("fill", resumeButton.x - resumeButton.width/2, resumeButton.y - resumeButton.height/2, resumeButton.width, resumeButton.height, 10, 10)
        if canResume then
            if isHoveringResume then love.graphics.setColor(0, 0, 0) else love.graphics.setColor(1, 1, 1) end
        else
            love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
        end
        love.graphics.printf(resumeButton.text, resumeButton.x - resumeButton.width/2, resumeButton.y - font:getHeight()/2, resumeButton.width, "center")
    end

    local isHoveringPlay = mx > (playButton.x - playButton.width/2) and mx < (playButton.x + playButton.width/2) and my > (playButton.y - playButton.height/2) and my < (playButton.y + playButton.height/2)
    if isHoveringPlay then love.graphics.setColor(0.9, 0.9, 0.9) else love.graphics.setColor(0.5, 0.5, 0.5) end
    love.graphics.rectangle("fill", playButton.x - playButton.width/2, playButton.y - playButton.height/2, playButton.width, playButton.height, 10, 10)
    if isHoveringPlay then love.graphics.setColor(0, 0, 0) else love.graphics.setColor(1, 1, 1) end
    love.graphics.printf(playButton.text, playButton.x - playButton.width/2, playButton.y - font:getHeight()/2, playButton.width, "center")

    local isHoveringSettings = mx > (settingsButton.x - settingsButton.width/2) and mx < (settingsButton.x + settingsButton.width/2) and my > (settingsButton.y - settingsButton.height/2) and my < (settingsButton.y + settingsButton.height/2)
    if isHoveringSettings then love.graphics.setColor(0.9, 0.9, 0.9) else love.graphics.setColor(0.5, 0.5, 0.5) end
    love.graphics.rectangle("fill", settingsButton.x - settingsButton.width/2, settingsButton.y - settingsButton.height/2, settingsButton.width, settingsButton.height, 10, 10)
    if isHoveringSettings then love.graphics.setColor(0, 0, 0) else love.graphics.setColor(1, 1, 1) end
    love.graphics.printf(settingsButton.text, settingsButton.x - settingsButton.width/2, settingsButton.y - font:getHeight()/2, settingsButton.width, "center")

    local diffs = {"easy", "normal", "hard"}
    local startX = WINDOW_WIDTH / 2 - 120
    for i, diff in ipairs(diffs) do
        local btnX = startX + (i-1) * 120
        local btnY = WINDOW_HEIGHT / 2 + 130
        local isHoveringDiff = mx > (btnX - 50) and mx < (btnX + 50) and my > (btnY - 20) and my < (btnY + 20)
        
        if difficulty == diff then
            if diff == "easy" then love.graphics.setColor(0, 0.8, 0)
            elseif diff == "normal" then love.graphics.setColor(0.9, 0.9, 0)
            elseif diff == "hard" then love.graphics.setColor(0.9, 0, 0) end
        elseif isHoveringDiff then
            love.graphics.setColor(0.7, 0.7, 0.7)
        else
            love.graphics.setColor(0.4, 0.4, 0.4)
        end
        love.graphics.rectangle("fill", btnX - 50, btnY - 20, 100, 40, 5, 5)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(diff:upper(), btnX - 50, btnY - 10, 100, "center")
    end
    love.graphics.setColor(1, 1, 1)
end

function checkAllCollisions()
    local function handlePlayerDeath()
        gameState = "gameOver"
        Paused = false 
        local currentScore = math.floor(score)
        local scores = scoresByDifficulty[activeGameDifficulty]
        if currentScore > scores.highScore then scores.highScore = currentScore end
        if timeAlive > scores.highTime then scores.highTime = timeAlive end
    end

    -- Player Collisions
    for i = #meteors, 1, -1 do if checkPixelCollision(player, meteors[i]) then handlePlayerDeath() end end
    for i = #phoenixMeteors, 1, -1 do if checkPixelCollision(player, phoenixMeteors[i]) then handlePlayerDeath() end end
    for i = #trackerMeteors, 1, -1 do if checkPixelCollision(player, trackerMeteors[i]) then handlePlayerDeath() end end
    for i = #crabMeteors, 1, -1 do if checkPixelCollision(player, crabMeteors[i]) then handlePlayerDeath() end end
    for i = #lobsterMeteors, 1, -1 do if checkPixelCollision(player, lobsterMeteors[i]) then handlePlayerDeath() end end

    -- Laser Collisions
    for i = #lasers, 1, -1 do 
        local laser = lasers[i]
        local laserHit = false

        if not laserHit then
            for j = #meteors, 1, -1 do 
                local meteor = meteors[j]
                if checkPixelCollision(laser, meteor) then
                    laser.dead = true; meteor.dead = true
                    table.insert(explosions, AnimatedExplosion:new(meteor.x, meteor.y, explosionFrames))
                    explosionSound:clone():play()
                    meteorsDestroyed = meteorsDestroyed + 1
                    score = score + 50 
                    laserHit = true
                    break
                end
            end
        end

        if not laserHit then
            for j = #phoenixMeteors, 1, -1 do 
                local pMeteor = phoenixMeteors[j]
                if checkPixelCollision(laser, pMeteor) then
                    laser.dead = true
                    pMeteor:hit() 
                    if pMeteor.dead then
                        table.insert(explosions, AnimatedExplosion:new(pMeteor.x, pMeteor.y, explosionFrames))
                        meteorsDestroyed = meteorsDestroyed + 1
                        score = score + 150 
                    end
                    explosionSound:clone():play()
                    laserHit = true
                    break
                end
            end
        end

        if not laserHit then
            for j = #trackerMeteors, 1, -1 do 
                local tMeteor = trackerMeteors[j]
                if checkPixelCollision(laser, tMeteor) then
                    laser.dead = true; tMeteor.dead = true
                    table.insert(explosions, AnimatedExplosion:new(tMeteor.x, tMeteor.y, explosionFrames))
                    explosionSound:clone():play()
                    meteorsDestroyed = meteorsDestroyed + 1
                    score = score + 500
                    laserHit = true
                    break
                end
            end
        end

        if not laserHit then
            for j = #crabMeteors, 1, -1 do
                local cMeteor = crabMeteors[j]
                if checkPixelCollision(laser, cMeteor) then
                    laser.dead = true; cMeteor.dead = true
                    table.insert(explosions, AnimatedExplosion:new(cMeteor.x, cMeteor.y, explosionFrames))
                    explosionSound:clone():play()
                    meteorsDestroyed = meteorsDestroyed + 1
                    score = score + 250
                    laserHit = true
                    break
                end
            end
        end

        if not laserHit then
            for j = #lobsterMeteors, 1, -1 do
                local lMeteor = lobsterMeteors[j]
                if checkPixelCollision(laser, lMeteor) then
                    laser.dead = true; lMeteor.dead = true
                    table.insert(explosions, AnimatedExplosion:new(lMeteor.x, lMeteor.y, explosionFrames))
                    explosionSound:clone():play()
                    meteorsDestroyed = meteorsDestroyed + 1
                    score = score + 250
                    laserHit = true
                    break
                end
            end
        end
    end
end

function displayScore() 
    local scoreText = tostring(math.floor(score))
    local text = love.graphics.newText(font, scoreText)
    local textWidth = text:getWidth()
    local textHeight = text:getHeight()
    local x = WINDOW_WIDTH / 2
    local y = WINDOW_HEIGHT - 50
    local paddingX, paddingY = 10, 5
    love.graphics.setColor(240/255, 240/255, 240/255)
    love.graphics.rectangle("line", x - textWidth/2 - paddingX, y - textHeight/2 - paddingY, textWidth + paddingX*2, textHeight + paddingY*2, 10, 10)
    love.graphics.printf(scoreText, 0, y - textHeight/2, WINDOW_WIDTH, "center")
    love.graphics.setColor(1, 1, 1)
end

function drawInGameMenuButton()
    local mx, my = love.mouse.getPosition()
    local isHovering = mx > (inGameMenuButton.x - inGameMenuButton.width/2) and mx < (inGameMenuButton.x + inGameMenuButton.width/2) and my > (inGameMenuButton.y - inGameMenuButton.height/2) and my < (inGameMenuButton.y + inGameMenuButton.height/2)
    if isHovering then love.graphics.setColor(0.9, 0.9, 0.9) else love.graphics.setColor(0.5, 0.5, 0.5) end
    love.graphics.rectangle("fill", inGameMenuButton.x - inGameMenuButton.width/2, inGameMenuButton.y - inGameMenuButton.height/2, inGameMenuButton.width, inGameMenuButton.height, 10, 10)
    if isHovering then love.graphics.setColor(0, 0, 0) else love.graphics.setColor(1, 1, 1) end
    love.graphics.printf(inGameMenuButton.text, inGameMenuButton.x - inGameMenuButton.width/2, inGameMenuButton.y - font:getHeight()/2, inGameMenuButton.width, "center")
    love.graphics.setColor(1, 1, 1)
end

function drawGameOver()
    love.graphics.draw(gameOverBackgroundSurf, 0, 0)
    local finalScore = math.floor(score)
    local time = math.floor(timeAlive)
    love.graphics.setColor(200/255, 200/255, 200/255)
    love.graphics.printf("GAME OVER", 0, WINDOW_HEIGHT / 2 - 50, WINDOW_WIDTH, "center")
    love.graphics.printf("Score: " .. finalScore, 0, WINDOW_HEIGHT / 2, WINDOW_WIDTH, "center")
    love.graphics.printf("You survived for: " .. time .. " seconds", 0, WINDOW_HEIGHT / 2 + 50, WINDOW_WIDTH, "center")

    if activeGameDifficulty == "easy" then love.graphics.setColor(0, 0.8, 0)
    elseif activeGameDifficulty == "normal" then love.graphics.setColor(0.9, 0.9, 0)
    elseif activeGameDifficulty == "hard" then love.graphics.setColor(0.9, 0, 0)
    else love.graphics.setColor(1, 1, 1) end
    
    love.graphics.printf("Difficulty: " .. activeGameDifficulty:upper(), 0, WINDOW_HEIGHT / 2 + 100, WINDOW_WIDTH, "center")

    local mx, my = love.mouse.getPosition()
    local isHovering = mx > (replayButton.x - replayButton.width/2) and mx < (replayButton.x + replayButton.width/2) and my > (replayButton.y - replayButton.height/2) and my < (replayButton.y + replayButton.height/2)
    if isHovering then love.graphics.setColor(0.9, 0.9, 0.9) else love.graphics.setColor(0.5, 0.5, 0.5) end
    love.graphics.rectangle("fill", replayButton.x - replayButton.width/2, replayButton.y - replayButton.height/2, replayButton.width, replayButton.height, 10, 10)
    if isHovering then love.graphics.setColor(0, 0, 0) else love.graphics.setColor(1, 1, 1) end
    love.graphics.printf(replayButton.text, replayButton.x - replayButton.width/2, replayButton.y - font:getHeight()/2, replayButton.width, "center")

    local isHoveringMenu = mx > (menuButton.x - menuButton.width/2) and mx < (menuButton.x + menuButton.width/2) and my > (menuButton.y - menuButton.height/2) and my < (menuButton.y + menuButton.height/2)
    if isHoveringMenu then love.graphics.setColor(0.9, 0.9, 0.9) else love.graphics.setColor(0.5, 0.5, 0.5) end
    love.graphics.rectangle("fill", menuButton.x - menuButton.width/2, menuButton.y - menuButton.height/2, menuButton.width, menuButton.height, 10, 10)
    if isHoveringMenu then love.graphics.setColor(0, 0, 0) else love.graphics.setColor(1, 1, 1) end
    love.graphics.printf(menuButton.text, menuButton.x - menuButton.width/2, menuButton.y - font:getHeight()/2, menuButton.width, "center")
    love.graphics.setColor(1, 1, 1)
end

function resetGame()
    gameState = "playing" 
    Paused = false 
    activeGameDifficulty = difficulty 
    timeAlive = 0 
    meteorsDestroyed = 0
    score = 0 
    lasers = {}
    meteors = {}
    phoenixMeteors = {}
    trackerMeteors = {}
    crabMeteors = {}
    lobsterMeteors = {}
    explosions = {}
    
    player = Player:new(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 1.5, playerSurf, playerImageData)

    -- Base Spawn Timer Configuration
    spawnRateConfig = {
        easy = { start = 0.75, min = 0.25 },
        normal = { start = 0.5, min = 0.175 },
        hard = { start = 0.3, min = 0.1 }
    }
    baseSpawnTimer = spawnRateConfig[activeGameDifficulty].start
    
    -- Initialize timers
    meteorSpawnTimer = 0
    phoenixSpawnTimer = 0
    trackerSpawnTimer = 0
    crabSpawnTimer = 0
    lobsterSpawnTimer = 0
end

function love.load()
    WINDOW_WIDTH, WINDOW_HEIGHT = 1200, 630
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {vsync = true})
    love.window.setTitle("spaceow")

    -- Load Assets
    backgroundSurf = love.graphics.newImage('images/background1.jpg')
    gameOverBackgroundSurf = love.graphics.newImage('images/background.jpg')
    menuBackgroundSurf = love.graphics.newImage('images/menu_background.png')
    settingsBackgroundSurf = love.graphics.newImage('images/settings_background.jpg')
    playerSurf = love.graphics.newImage('images/shimeji.png')
    meteorSurf = love.graphics.newImage('images/egg_one.png')
    laserSurf = love.graphics.newImage('images/fish1.png')
    phoenixSurf1 = love.graphics.newImage('images/lemon_meteor_1.png')
    phoenixSurf2 = love.graphics.newImage('images/lemon_meteor_2.png')
    trackerSurf = love.graphics.newImage('images/tracker_meteor.png') 
    crabSurf = love.graphics.newImage('images/crab_meteor.png')
    lobsterSurf = love.graphics.newImage('images/lobster_meteor.png')

    -- ImageData for pixel collision
    playerImageData = love.image.newImageData('images/shimeji.png')
    meteorImageData = love.image.newImageData('images/egg_one.png')
    laserImageData = love.image.newImageData('images/fish1.png')
    phoenixImageData1 = love.image.newImageData('images/lemon_meteor_1.png')
    phoenixImageData2 = love.image.newImageData('images/lemon_meteor_2.png')
    trackerImageData = love.image.newImageData('images/tracker_meteor.png')
    crabImageData = love.image.newImageData('images/crab_meteor.png')
    lobsterImageData = love.image.newImageData('images/lobster_meteor.png')
    
    font = love.graphics.newFont("images/Oxanium-Bold.ttf", 20)
    love.graphics.setFont(font)

    ExplosionImageCount = 8
    explosionFrames = {}
    for i = 0, ExplosionImageCount do
        table.insert(explosionFrames, love.graphics.newImage("images/explosion/" .. i .. ".png"))
    end

    laserSound = love.audio.newSource("audio/mewo.mp3", "static")
    explosionSound = love.audio.newSource("audio/eggsplotion.mp3", "static")
    gameMusic = love.audio.newSource("audio/gamesong1.mp3", "stream")

    currentVolLaser = 0.3
    currentVolExplosion = 0.4
    currentVolMusic = 0.1
    laserSound:setVolume(currentVolLaser)
    explosionSound:setVolume(currentVolExplosion)
    gameMusic:setVolume(currentVolMusic)
    gameMusic:setLooping(true)
    gameMusic:play()

    -- Buttons
    replayButton = {x = WINDOW_WIDTH / 2, y = WINDOW_HEIGHT / 2 + 180, width = 150, height = 50, text = "Replay"}
    menuButton = {x = WINDOW_WIDTH / 2, y = WINDOW_HEIGHT / 2 + 240, width = 150, height = 50, text = "Menu"}
    playButton = {x = WINDOW_WIDTH / 2, y = WINDOW_HEIGHT / 2 + 50, width = 150, height = 50, text = "Play"}
    resumeButton = {x = WINDOW_WIDTH / 2, y = WINDOW_HEIGHT / 2 - 20, width = 150, height = 50, text = "Resume"}
    inGameMenuButton = {x = 70, y = WINDOW_HEIGHT - 40, width = 100, height = 40, text = "Menu"}
    settingsButton = {x = 70, y = WINDOW_HEIGHT - 40, width = 100, height = 40, text = "Settings"}
    saveButton = {x = WINDOW_WIDTH / 2 - 80, y = WINDOW_HEIGHT - 100, width = 150, height = 50, text = "Save"}
    backButton = {x = WINDOW_WIDTH / 2 + 80, y = WINDOW_HEIGHT - 100, width = 150, height = 50, text = "Back"}
    
    activeSlider = nil 
    tempVolMusic = currentVolMusic
    tempVolExplosion = currentVolExplosion
    tempVolLaser = currentVolLaser

    difficulty = "normal"
    activeGameDifficulty = "normal" 
    scoresByDifficulty = {
        easy = { highScore = 0, highTime = 0 },
        normal = { highScore = 0, highTime = 0 },
        hard = { highScore = 0, highTime = 0 }
    }
    
    Paused = false
    resetGame() 
    gameState = "menu"
end

function love.update(dt)
    if gameState == "playing" and not Paused then
        timeAlive = timeAlive + dt
        score = score + (10 * dt)

        -- Dynamic Spawn Timer
        local config = spawnRateConfig[activeGameDifficulty]
        local targetTime = 300 
        local t = math.min(timeAlive, targetTime) / targetTime 
        local ease = t * t 
        baseSpawnTimer = config.start - (config.start - config.min) * ease

        meteorSpawnRate = baseSpawnTimer
        phoenixSpawnRate = baseSpawnTimer * 12
        trackerSpawnRate = baseSpawnTimer * 31
        crabSpawnRate = baseSpawnTimer * 25
        lobsterSpawnRate = baseSpawnTimer * 63

        -- Spawn Timers
        meteorSpawnTimer = meteorSpawnTimer + dt
        if meteorSpawnTimer > meteorSpawnRate then spawnMeteor(); meteorSpawnTimer = 0 end

        phoenixSpawnTimer = phoenixSpawnTimer + dt
        if phoenixSpawnTimer > phoenixSpawnRate then spawnPhoenixMeteor(); phoenixSpawnTimer = 0 end

        trackerSpawnTimer = trackerSpawnTimer + dt
        if trackerSpawnTimer > trackerSpawnRate then spawnTrackerMeteor(); trackerSpawnTimer = 0 end

        crabSpawnTimer = crabSpawnTimer + dt
        if crabSpawnTimer > crabSpawnRate then spawnCrabMeteor(); crabSpawnTimer = 0 end

        lobsterSpawnTimer = lobsterSpawnTimer + dt
        if lobsterSpawnTimer > lobsterSpawnRate then spawnLobsterMeteor(); lobsterSpawnTimer = 0 end

        -- Entity Updates
        player:update(dt)

        for i = #lasers, 1, -1 do
            lasers[i]:update(dt)
            if lasers[i].dead then table.remove(lasers, i) end
        end

        for i = #meteors, 1, -1 do
            meteors[i]:update(dt)
            if meteors[i].dead then table.remove(meteors, i) end
        end
        
        for i = #phoenixMeteors, 1, -1 do
            phoenixMeteors[i]:update(dt)
            if phoenixMeteors[i].dead then table.remove(phoenixMeteors, i) end
        end

        for i = #trackerMeteors, 1, -1 do
            trackerMeteors[i]:update(dt)
            if trackerMeteors[i].dead then table.remove(trackerMeteors, i) end
        end

        for i = #crabMeteors, 1, -1 do
            crabMeteors[i]:update(dt)
            if crabMeteors[i].dead then table.remove(crabMeteors, i) end
        end

        for i = #lobsterMeteors, 1, -1 do
            -- Pass player and lasers to Lobster for AI logic
            lobsterMeteors[i]:update(dt, player, lasers)
            if lobsterMeteors[i].dead then table.remove(lobsterMeteors, i) end
        end
        
        for i = #explosions, 1, -1 do
            explosions[i]:update(dt)
            if explosions[i].dead then table.remove(explosions, i) end
        end

        checkAllCollisions()
    
    elseif gameState == "settings" then
        if love.mouse.isDown(1) and activeSlider then
            local mx, my = love.mouse.getPosition()
            local sliderWidth = 300
            local sliderX = WINDOW_WIDTH / 2 - sliderWidth / 2
            local val = (mx - sliderX) / sliderWidth
            if val < 0 then val = 0 end
            if val > 1 then val = 1 end
            
            if activeSlider == "music" then tempVolMusic = val end
            if activeSlider == "explosion" then tempVolExplosion = val end
            if activeSlider == "laser" then tempVolLaser = val end
        else
            activeSlider = nil
        end
    end
end

function love.draw()
    if gameState == "menu" then
        drawMenu()
    elseif gameState == "settings" then
        drawSettings()
    elseif gameState == "playing" then
        love.graphics.draw(backgroundSurf, 0, 0)
        player:draw()
        for _, m in ipairs(meteors) do m:draw() end
        for _, pm in ipairs(phoenixMeteors) do pm:draw() end
        for _, tm in ipairs(trackerMeteors) do tm:draw() end
        for _, cm in ipairs(crabMeteors) do cm:draw() end
        for _, lm in ipairs(lobsterMeteors) do lm:draw() end
        for _, l in ipairs(lasers) do l:draw() end
        for _, e in ipairs(explosions) do e:draw() end
        
        displayScore()
        drawInGameMenuButton()

        -- UI Instructions
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.printf("WASD -> movement", 20, 20, 200, "left")
        love.graphics.printf("Space -> Shoot", 20, 45, 200, "left")
        love.graphics.printf("Shift -> Sprint", 20, 70, 200, "left")
        love.graphics.printf("P -> Pause/Unpause", 20, 95, 200, "left")
        love.graphics.printf("M -> Menu", 20, 120, 200, "left")
        love.graphics.setColor(1, 1, 1)
        
        if Paused then
            love.graphics.setColor(0, 0, 0, 0.5)
            love.graphics.rectangle("fill", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("PAUSED", 0, WINDOW_HEIGHT/2, WINDOW_WIDTH, "center")
        end
        
    elseif gameState == "gameOver" then
        drawGameOver()
    end
end

function love.keypressed(key)
    if key == "space" then
        if gameState == "playing" and not Paused then
            player:shoot(lasers, laserSurf, laserImageData, laserSound)
        end
    end
    if key == "p" then if gameState == "playing" then Paused = not Paused end end
    if key == "m" then if gameState == "playing" then gameState = "menu"; Paused = true end end
end

function love.mousepressed(x, y, button)
    if button == 1 then 
        if gameState == "menu" then
            if Paused then
                local isHoveringResume = x > (resumeButton.x - resumeButton.width/2) and x < (resumeButton.x + resumeButton.width/2) and y > (resumeButton.y - resumeButton.height/2) and y < (resumeButton.y + resumeButton.height/2)
                if isHoveringResume and (difficulty == activeGameDifficulty) then
                    gameState = "playing"
                    Paused = true 
                end
            end
            local isHoveringPlay = x > (playButton.x - playButton.width/2) and x < (playButton.x + playButton.width/2) and y > (playButton.y - playButton.height/2) and y < (playButton.y + playButton.height/2)
            if isHoveringPlay then
                if Paused and timeAlive > 0 then
                    local currentScore = math.floor(score)
                    local scores = scoresByDifficulty[activeGameDifficulty]
                    if currentScore > scores.highScore then scores.highScore = currentScore end
                    if timeAlive > scores.highTime then scores.highTime = timeAlive end
                end
                resetGame() 
            end
            local isHoveringSettings = x > (settingsButton.x - settingsButton.width/2) and x < (settingsButton.x + settingsButton.width/2) and y > (settingsButton.y - settingsButton.height/2) and y < (settingsButton.y + settingsButton.height/2)
            if isHoveringSettings then
                gameState = "settings"
                tempVolMusic = currentVolMusic; tempVolExplosion = currentVolExplosion; tempVolLaser = currentVolLaser
            end
            local diffs = {"easy", "normal", "hard"}
            local startX = WINDOW_WIDTH / 2 - 120
            for i, diff in ipairs(diffs) do
                local btnX = startX + (i-1) * 120
                local btnY = WINDOW_HEIGHT / 2 + 130
                if x > (btnX - 50) and x < (btnX + 50) and y > (btnY - 20) and y < (btnY + 20) then difficulty = diff end
            end
        
        elseif gameState == "settings" then
            local sliderWidth = 300
            local sliderX = WINDOW_WIDTH / 2 - sliderWidth / 2
            local function checkSlider(sy) return x >= sliderX and x <= sliderX + sliderWidth and y >= sy - 15 and y <= sy + 15 end
            if checkSlider(200) then activeSlider = "music" end
            if checkSlider(280) then activeSlider = "explosion" end
            if checkSlider(360) then activeSlider = "laser" end

            local isHoveringSave = x > (saveButton.x - saveButton.width/2) and x < (saveButton.x + saveButton.width/2) and y > (saveButton.y - saveButton.height/2) and y < (saveButton.y + saveButton.height/2)
            if isHoveringSave then
                currentVolMusic = tempVolMusic; currentVolExplosion = tempVolExplosion; currentVolLaser = tempVolLaser
                gameMusic:setVolume(currentVolMusic); explosionSound:setVolume(currentVolExplosion); laserSound:setVolume(currentVolLaser)
                gameState = "menu"
            end
            local isHoveringBack = x > (backButton.x - backButton.width/2) and x < (backButton.x + backButton.width/2) and y > (backButton.y - backButton.height/2) and y < (backButton.y + backButton.height/2)
            if isHoveringBack then gameState = "menu" end

        elseif gameState == "playing" then
            local isHoveringMenu = x > (inGameMenuButton.x - inGameMenuButton.width/2) and x < (inGameMenuButton.x + inGameMenuButton.width/2) and y > (inGameMenuButton.y - inGameMenuButton.height/2) and y < (inGameMenuButton.y + inGameMenuButton.height/2)
            if isHoveringMenu then
                gameState = "menu"
                Paused = true
            else
                if not Paused then player:shoot(lasers, laserSurf, laserImageData, laserSound) end
            end
            
        elseif gameState == "gameOver" then
            local isHoveringReplay = x > (replayButton.x - replayButton.width/2) and x < (replayButton.x + replayButton.width/2) and y > (replayButton.y - replayButton.height/2) and y < (replayButton.y + replayButton.height/2)
            if isHoveringReplay then resetGame() end
            local isHoveringMenu = x > (menuButton.x - menuButton.width/2) and x < (menuButton.x + menuButton.width/2) and y > (menuButton.y - menuButton.height/2) and y < (menuButton.y + menuButton.height/2)
            if isHoveringMenu then gameState = "menu"; Paused = false end
        end
    end
end
