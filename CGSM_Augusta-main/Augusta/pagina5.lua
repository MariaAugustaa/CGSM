local composer = require("composer")
local scene = composer.newScene()
local MARGIN = 40
local backgroundSound 
local isSoundOn = false
local passaroAtivo = false
local mariposas = {}

local function calcularDistancia(obj1, obj2)
    local dx = obj1.x - obj2.x
    local dy = obj1.y - obj2.y
    return math.sqrt(dx * dx + dy * dy)
end

local function animacaoPassaro(sceneGroup)
    if passaroAtivo then return end
    passaroAtivo = true

    local passaroSheetOptions = {
        width = 243 / 3 - 5, 
        height = 169 / 3,
        numFrames = 9,   
        sheetContentWidth = 244,
        sheetContentHeight = 170
    }
    local passaroSpriteSheet = graphics.newImageSheet("assets/page5/passaro.png", passaroSheetOptions)

    local passaroSequences = {
        {
            name = "passaro-animacao",
            start = 1,
            count = 9,
            time = 1000,    
            loopCount = 0 
        }
    }
    
    local passaro = display.newSprite(sceneGroup, passaroSpriteSheet, passaroSequences)
    passaro.x = display.contentWidth + 200 
    passaro.y = display.contentCenterY + 100
    passaro.xScale = -1
    passaro:play()
    

    local function verificarColisoes()
        for i = #mariposas, 1, -1 do
            local mariposa = mariposas[i]
            if mariposa and calcularDistancia(passaro, mariposa) < 50 then
                mariposa:removeSelf()
                table.remove(mariposas, i)
            end
        end
    end


    local function onEnterFrame()
        verificarColisoes()
    end

    Runtime:addEventListener("enterFrame", onEnterFrame)

    transition.to(passaro, {
        time = 5000,
        x = -50, 
        onComplete = function()
            Runtime:removeEventListener("enterFrame", onEnterFrame) 
            passaro:removeSelf()
            passaroAtivo = false
        end
    })
end

function scene:create(event)
    local sceneGroup = self.view

    local fumacas = {}
    local fumacaAtiva = true 
    local reduzindoFumacas = false 

    local function criarFumacas()
        if fumacaAtiva then
            for i = 1, 25 do 
                local fumaca = display.newCircle(math.random(86, 702), 678, math.random(5, 15))
                fumaca:setFillColor(0.5, 0.5, 0.5, 0.3)
                fumaca.velocidadeX = math.random(-30, 30) / 100
                fumaca.velocidadeY = math.random(-150, -30) / 100
                sceneGroup:insert(fumaca)
                fumacas[#fumacas + 1] = fumaca
            end
        end
    end

    local function atualizarFumacas()
        for i = #fumacas, 1, -1 do
            local fumaca = fumacas[i]
            if fumaca then
                if reduzindoFumacas then

                    fumaca.alpha = fumaca.alpha - 0.01
                    if fumaca.alpha <= 0 then
                        fumaca:removeSelf()
                        fumaca = nil
                        table.remove(fumacas, i)
                    end
                else
                    fumaca.x = fumaca.x + fumaca.velocidadeX
                    fumaca.y = fumaca.y + fumaca.velocidadeY
                    fumaca.alpha = fumaca.alpha - 0.002
                    if fumaca.alpha <= 0 or fumaca.y < 384 then
                        fumaca:removeSelf()
                        fumaca = nil
                        table.remove(fumacas, i)
                    end
                end
            end
        end
       
        if fumacaAtiva and not reduzindoFumacas then
            criarFumacas()
        end
    end

    local background = display.newImageRect(sceneGroup, "assets/page5/pagina 5 v2.png", 768, 1024)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local proximo = display.newImage(sceneGroup, "assets/buttons/proximo.png")
    proximo.x = display.contentWidth - proximo.width / 2 - MARGIN
    proximo.y = display.contentHeight - proximo.height / 2 - MARGIN
    proximo:addEventListener("tap", function()
        if backgroundSound then
            audio.stop()
            audio.dispose(backgroundSound)
            backgroundSound = nil
        end
        composer.removeScene("pagina5")
        composer.gotoScene("pagina6", { effect = "crossFade", time = 500 })
    end)

    local voltar = display.newImage(sceneGroup, "assets/buttons/voltar.png")
    voltar.x = voltar.width / 2 + MARGIN
    voltar.y = display.contentHeight - voltar.height / 2 - MARGIN
    voltar:addEventListener("tap", function()
        if backgroundSound then
            audio.stop()
            audio.dispose(backgroundSound)
            backgroundSound = nil
        end
        composer.removeScene("pagina5")
        composer.gotoScene("pagina4", { effect = "crossFade", time = 500 })
    end)

    local valvula = display.newImage(sceneGroup, "assets/page5/valvula.png")
    valvula.x = 530
    valvula.y = 930

    local currentAngle = 0
    local previousAngle = 0

    local function calculateAngle(event)
        local deltaX = event.x - valvula.x
        local deltaY = event.y - valvula.y
        local angle = math.atan2(deltaY, deltaX) * (180 / math.pi)
        return angle
    end

    local minX, maxX = 96, 640
    local minY, maxY = 600, 654

    local function espalharMariposas()
        for i = 1, 15 do
            local posX = math.random(minX, maxX)
            local posY = math.random(minY, maxY)

            local mariposa = display.newImage(sceneGroup, "/assets/page5/mariposa.png")
            mariposa.x = posX
            mariposa.y = posY
            table.insert(mariposas, mariposa)
        end
    end

    local mariposasEspalhadas = false

    local passaroCriado = false

    local function onValvulaTouch(event)
        if event.phase == "began" then
            display.getCurrentStage():setFocus(valvula)
            valvula.isFocus = true
            previousAngle = calculateAngle(event)
        elseif event.phase == "moved" and valvula.isFocus then
            local newAngle = calculateAngle(event)
            local deltaAngle = newAngle - previousAngle
            currentAngle = currentAngle + deltaAngle
            valvula.rotation = currentAngle
            previousAngle = newAngle
    
            if currentAngle >= 10 and currentAngle <= 50 then
                fumacaAtiva = false
                reduzindoFumacas = true
                mariposasEspalhadas = false
                if not passaroCriado then
                    animacaoPassaro(sceneGroup)
                    passaroCriado = true
                end
            else
                fumacaAtiva = true
                reduzindoFumacas = false
                if not mariposasEspalhadas then
                    espalharMariposas()
                    mariposasEspalhadas = true 
                end
                passaroCriado = false 
            end
        elseif event.phase == "ended" or event.phase == "cancelled" then
            display.getCurrentStage():setFocus(nil)
            valvula.isFocus = false
        end
        return true
    end
    

    valvula:addEventListener("touch", onValvulaTouch)


    Runtime:addEventListener("enterFrame", atualizarFumacas)

    espalharMariposas()

    local som = display.newImage(sceneGroup, "/assets/buttons/som.png")
    som.x = display.contentWidth - som.width / 2 - MARGIN + 10
    som.y = display.contentHeight - som.height - 820

    backgroundSound = audio.loadStream("audio/pagina5.wav")

    
    local function handleButtonTouch(event)
        if event.phase == "began" then
            local newImage
            if isSoundOn then
                audio.stop()
                isSoundOn = false
                newImage = display.newImage(sceneGroup, "/assets/buttons/somoff.png")
            else
                audio.play(backgroundSound, { loops = -1 })
                isSoundOn = true
                newImage = display.newImage(sceneGroup, "/assets/buttons/som.png")
            end
    
            newImage.x = som.x
            newImage.y = som.y
    
            som:removeEventListener("touch", handleButtonTouch)
            som:removeSelf()
            som = nil
    
            som = newImage
            som:addEventListener("touch", handleButtonTouch) 
        end
        return true
    end
    
    som:addEventListener("touch", handleButtonTouch)
end


function scene:show(event)
    local phase = event.phase
    if phase == "did" then
        if not isSoundOn then
            audio.play(backgroundSound, { loops = -1 })
            isSoundOn = true
        end
    end
end

function scene:hide(event)
    local phase = event.phase
    if phase == "will" then
        if isSoundOn then
            audio.stop()
            isSoundOn = false
        end
        Runtime:removeEventListener("enterFrame", atualizarFumacas)
    end
end

function scene:destroy(event)
    if backgroundSound then
        audio.dispose(backgroundSound)
        backgroundSound = nil
    end
    if self.removerFumacas then
        self.removerFumacas()
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
