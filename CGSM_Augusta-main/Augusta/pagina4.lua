local composer = require("composer")
local scene = composer.newScene()
local MARGIN = 30
local backgroundSound 
local isSoundOn = false 
local paginaAtiva = false

local coelho1, coelho2, cervo, passaro

local destinoCoelho1 = {x = 108, y = 758}
local destinoCoelho2 = {x = 108, y = 758}
local destinoCervo = {x = 404, y = 622}
local destinoPassaro = {x = 476, y = 540}

local particulas = {}

local function criarParticulas(sceneGroup)
    for i = 1, 2000 do
        local particula = display.newCircle(math.random(86, 702), 870, math.random(5, 15))
        particula:setFillColor(0.8, 0.7, 0.5, 0.3)
        particula.velocidadeX = math.random(-50, 50) / 100 
        particula.velocidadeY = math.random(-150, 0) / 100

        particulas[#particulas + 1] = particula
    end
end

local function atualizarParticulas(sceneGroup)
    for i = #particulas, 1, -1 do
        local particula = particulas[i]
        
        if particula then
            particula.x = particula.x + particula.velocidadeX
            particula.y = particula.y + particula.velocidadeY

            particula.velocidadeX = particula.velocidadeX + math.random(-10, 10) / 100

            if particula.y < 384 or particula.x < 86 or particula.x > 702 then

                particula:removeSelf()
                particula = nil
                table.remove(particulas, i) 
            end
        end
    end
end


local function removerParticulas(sceneGroup)
    for _, particula in ipairs(particulas) do
        if particula and particula.removeSelf then
            particula:removeSelf()
        end
    end
    particulas = {}
end


local function iniciarAnimacoes()
    if coelho1 and coelho1.play then
        coelho1:play()
    end
    if coelho2 and coelho2.play then
        timer.performWithDelay(100, function()
            coelho2.xScale = -1
            coelho2:play()
        end)
    end
    if cervo and cervo.play then
        cervo.xScale = -1
        cervo:play()
    end
    if passaro and passaro.play then
        passaro:play()
    end
end


local function moverParaDestino(objeto, destino, diminuirTamanho)
    if objeto and objeto.removeSelf then

        transition.to(objeto, {
            x = destino.x,
            y = destino.y,
            time = 3000,
            onComplete = function()
                if objeto and objeto.removeSelf then
                    display.remove(objeto)
                    objeto = nil
                end
            end
        })

        if diminuirTamanho then
            transition.to(objeto, {
                xScale = 0.1, 
                yScale = 0.1,
                time = 3000 
            })
        end
    end
end



local function onAccelerometer(event)
    if not paginaAtiva then
        return
    end
    local limiar = 0.5
    if math.abs(event.xInstant) > limiar or math.abs(event.yInstant) > limiar then
        Runtime:removeEventListener("accelerometer", onAccelerometer)
        iniciarAnimacoes()

        moverParaDestino(coelho1, destinoCoelho1, false) 
        moverParaDestino(coelho2, destinoCoelho2, false) 
        moverParaDestino(cervo, destinoCervo, true)  
        moverParaDestino(passaro, destinoPassaro, false) 
    end
    if math.abs(event.xInstant) > limiar or math.abs(event.yInstant) > limiar then
        if not acelerometroAtivo then
            acelerometroAtivo = true
            criarParticulas() 
            Runtime:addEventListener("enterFrame", atualizarParticulas)
        end
    else
        if acelerometroAtivo then
            acelerometroAtivo = false
            Runtime:removeEventListener("enterFrame", atualizarParticulas)
            removerParticulas() 
        end
    end
end


function scene:create(event)
    local sceneGroup = self.view

    local backgroud = display.newImageRect(sceneGroup, "assets/page4/pagina 4 v2.png", 768, 1024)
    backgroud.x = display.contentCenterX
    backgroud.y = display.contentCenterY

    local proximo = display.newImage(sceneGroup, "/assets/buttons/proximo.png")
    proximo.x = display.contentWidth - proximo.width / 2 - MARGIN
    proximo.y = display.contentHeight - proximo.height / 2 - MARGIN

    proximo:addEventListener("tap", function()
        paginaAtiva = false
        acelerometroAtivo = false
        removerParticulas()
        if backgroundSound then
            audio.stop()
            audio.dispose(backgroundSound)
            backgroundSound = nil
        end
        composer.removeScene("pagina4")
        composer.gotoScene("pagina5", {
            effect = "crossFade",
            time = 500
        })
    end)

    local voltar = display.newImage(sceneGroup, "/assets/buttons/voltar.png")
    voltar.x = display.contentWidth - voltar.width / 2 - MARGIN - 605
    voltar.y = display.contentHeight - voltar.height / 2 - MARGIN

    voltar:addEventListener("tap", function()
        paginaAtiva = false
        acelerometroAtivo = false
        removerParticulas()
        if backgroundSound then
            audio.stop()
            audio.dispose(backgroundSound)
            backgroundSound = nil
        end
        composer.removeScene("pagina4")
        composer.gotoScene("pagina3", {
            effect = "crossFade",
            time = 500
        })
    end)

    local coelhoSheetOptions = {
        width = 437 / 6 + 2.6,  
        height = 214 / 3, 
        numFrames = 6, 
        sheetContentWidth = 437,
        sheetContentHeight = 214
    }
    local coelhoSpriteSheet = graphics.newImageSheet("assets/page4/coelho-anima.png", coelhoSheetOptions)

    local coelhoSequences = {
        {
            name = "coelho-animacao",
            start = 1,
            count = 6,
            time = 800,
            loopCount = 0
        }
    }

    coelho1 = display.newSprite(sceneGroup, coelhoSpriteSheet, coelhoSequences)
    coelho1.x = display.contentCenterX + 300 
    coelho1.y = display.contentCenterY + 300
    coelho1.xScale = -1 
    coelho1:setSequence("coelho-animacao")

    coelho2 = display.newSprite(sceneGroup, coelhoSpriteSheet, coelhoSequences)
    coelho2.x = display.contentCenterX + 220  
    coelho2.y = display.contentCenterY + 330
    coelho2:setSequence("coelho-animacao")

    local cervoSheetOptions = {
        width = 607 / 3,  
        height = 423 / 2, 
        numFrames = 5,  
        sheetContentWidth = 608,
        sheetContentHeight = 424
    }
    local cervoSpriteSheet = graphics.newImageSheet("assets/page4/cervo.png", cervoSheetOptions)

    local cervoSequences = {
        {
            name = "cervo-animacao",
            start = 1,
            count = 5,
            time = 800,   
            loopCount = 0 
        }
    }


    cervo = display.newSprite(sceneGroup, cervoSpriteSheet, cervoSequences)
    cervo.x = display.contentCenterX - 190 
    cervo.y = display.contentCenterY + 250
    cervo:setSequence("cervo-animacao")
    
    local passaroSheetOptions = {
        width = 243 / 3 - 5, 
        height = 169 / 3,
        numFrames = 9,   
        sheetContentWidth = 244,
        sheetContentHeight = 170
    }
    local passaroSpriteSheet = graphics.newImageSheet("assets/page4/passaro.png", passaroSheetOptions)

    local passaroSequences = {
        {
            name = "passaro-animacao",
            start = 1,
            count = 9,
            time = 800,    
            loopCount = 0 
        }
    }

    -- SIMULAR O ACELEROMETRO PARA VER SE ESTÁ FUNCIONANDAO
    local function simularAcelerometro()
        local event = {
            xInstant = math.random(0.5, 1), 
            yInstant = math.random(0.5, 1),
            name = "accelerometer"
        }
        onAccelerometer(event)
    end

    timer.performWithDelay(5000, function()
        simularAcelerometro()
    end, 1) 
    

    passaro = display.newSprite(sceneGroup, passaroSpriteSheet, passaroSequences)
    passaro.x = display.contentCenterX - 300 
    passaro.y = display.contentCenterY + 150
    passaro:setSequence("passaro-animacao")

    local som = display.newImage(sceneGroup, "/assets/buttons/som.png")
    som.x = display.contentWidth - som.width / 2 - MARGIN + 10
    som.y = display.contentHeight - som.height - 820

    backgroundSound = audio.loadStream("audio/pagina4.wav")

    
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
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        paginaAtiva = true
        Runtime:addEventListener("accelerometer", onAccelerometer)
    elseif (phase == "did") then
        if not isSoundOn then
            audio.play(backgroundSound, { loops = -1 })
            isSoundOn = true
        end
    end
end


function scene:hide(event)
    local phase = event.phase

    if (phase == "will") then
        if isSoundOn then
            audio.stop()
            isSoundOn = false
        end
        paginaAtiva = false
        Runtime:removeEventListener("accelerometer", onAccelerometer)
        removerParticulas()
    elseif (phase == "did") then
    end
end

function scene:destroy(event)
    if backgroundSound then
        audio.dispose(backgroundSound)
        backgroundSound = nil
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene