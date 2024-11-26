local composer = require("composer")
local scene = composer.newScene()
local MARGIN = 40
local backgroundSound 
local isSoundOn = false

function scene:create(event)
    local sceneGroup = self.view

    local background = display.newImageRect(sceneGroup, "assets/page6/pagina 6 v2.png", 768, 1024)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local pavao1 = display.newImage(sceneGroup, "assets/page6/pavao.png")
    pavao1.x, pavao1.y = 142, 790

    local pavao2 = display.newImage(sceneGroup, "assets/page6/pavao.png")
    pavao2.x, pavao2.y = 434, 930

    local pavao3 = display.newImage(sceneGroup, "assets/page6/pavao.png")
    pavao3.x, pavao3.y = 118, 618

    local pavao4 = display.newImage(sceneGroup, "assets/page6/pavao.png")
    pavao4.x, pavao4.y = 386, 722

    local pavao5 = display.newImage(sceneGroup, "assets/page6/pavao.png")
    pavao5.x, pavao5.y = 624, 742

    local pavao6 = display.newImage(sceneGroup, "assets/page6/pavao.png")
    pavao6.x, pavao6.y = 604, 528

    local pavaoBonito = display.newImage(sceneGroup, "assets/page6/bonito.png")
    pavaoBonito.x, pavaoBonito.y = display.contentCenterX, display.contentCenterY

    local femea = display.newImage(sceneGroup, "assets/page6/femea.png")
    femea.x, femea.y = 50, 800

    local speed = 2

    local path = {
        {x = pavao1.x + 50, y = pavao1.y}, 
        {x = pavao2.x + 50, y = pavao2.y}, 
        {x = pavao3.x + 50, y = pavao3.y}, 
        {x = pavao4.x + 50, y = pavao4.y},
        {x = pavao5.x + 50, y = pavao5.y},
        {x = pavao6.x + 50, y = pavao6.y},
        {x = pavaoBonito.x, y = pavaoBonito.y} 
    }

    local currentPointIndex = 1

        local function criarFilhotinhos()
            local numFilhotes = 5
            local raio = 100 
            local anguloInicial = 40
            local incrementoAngulo = 150 / numFilhotes
    
            for i = 1, numFilhotes do
                local anguloRad = math.rad(anguloInicial + (i - 1) * incrementoAngulo)
                local filhote = display.newImage(sceneGroup, "assets/page6/filhote.png")
                filhote.x = pavaoBonito.x + raio * math.cos(anguloRad)
                filhote.y = pavaoBonito.y + raio * math.sin(anguloRad)
            end
        end

    local function moverFemea()
        if currentPointIndex <= #path then
            local targetPoint = path[currentPointIndex]
            local dx = targetPoint.x - femea.x
            local dy = targetPoint.y - femea.y
            local distancia = math.sqrt(dx^2 + dy^2)

            if distancia > 5 then
                femea.x = femea.x + dx / distancia * speed
                femea.y = femea.y + dy / distancia * speed
            else
                currentPointIndex = currentPointIndex + 1

                if currentPointIndex > #path then
                    Runtime:removeEventListener("enterFrame", moverFemea)
                    femea.x, femea.y = pavaoBonito.x, pavaoBonito.y
                    femea:toFront()
                    criarFilhotinhos()
                end
            end
        end
    end

    Runtime:addEventListener("enterFrame", moverFemea)

    local proximo = display.newImage(sceneGroup, "/assets/buttons/proximo.png")
    proximo.x = display.contentWidth - proximo.width / 2 - MARGIN
    proximo.y = display.contentHeight - proximo.height / 2 - MARGIN

    proximo:addEventListener("tap", function(event)
        if backgroundSound then
            audio.stop()
            audio.dispose(backgroundSound)
            backgroundSound = nil
        end
        composer.removeScene("pagina6")
        composer.gotoScene("contracapa", {
            effect = "crossFade",
            time = 500
        })
    end)

    local voltar = display.newImage(sceneGroup, "/assets/buttons/voltar.png")
    voltar.x = display.contentWidth - voltar.width / 2 - MARGIN - 605
    voltar.y = display.contentHeight - voltar.height / 2 - MARGIN

    voltar:addEventListener("tap", function(event)
        if backgroundSound then
            audio.stop()
            audio.dispose(backgroundSound)
            backgroundSound = nil
        end
        composer.removeScene("pagina6")
        composer.gotoScene("pagina5", {
            effect = "crossFade",
            time = 500
        })
    end)

    local som = display.newImage(sceneGroup, "/assets/buttons/som.png")
    som.x = display.contentWidth - som.width / 2 - MARGIN + 10
    som.y = display.contentHeight - som.height - 820

    backgroundSound = audio.loadStream("audio/pagina6.wav")

    
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
    elseif (phase == "did") then
        if not isSoundOn then
            audio.play(backgroundSound, { loops = -1 })
            isSoundOn = true
        end
    end
end

function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
    elseif (phase == "did") then
        if isSoundOn then
            audio.stop()
            isSoundOn = false
        end
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
