local composer = require("composer")
local scene = composer.newScene()
local MARGIN = 40
local backgroundSound 
local isSoundOn = false
local activeTransitions = {}

local function cancelAllTransitions()
    for i, transitionHandle in ipairs(activeTransitions) do
        if transitionHandle then
            transition.cancel(transitionHandle)
        end
    end
    activeTransitions = {}
end

local function resetPage(sceneGroup)
    cancelAllTransitions()

    for i = sceneGroup.numChildren, 1, -1 do
        local child = sceneGroup[i]
        if child then
            child:removeSelf()
            child = nil
        end
    end

    scene:create({view = sceneGroup})
end

function scene:create(event)
    local sceneGroup = self.view

    local backgroud = display.newImageRect(sceneGroup, "assets/page2/pagina 2 v2.png", 768, 1024)
    backgroud.x = display.contentCenterX
    backgroud.y = display.contentCenterY

    local proximo = display.newImage(sceneGroup, "/assets/buttons/proximo.png")
    proximo.x = display.contentWidth - proximo.width / 2 - MARGIN
    proximo.y = display.contentHeight - proximo.height / 2 - MARGIN

    proximo:addEventListener("tap", function(event)
        if backgroundSound then
            audio.stop()
            audio.dispose(backgroundSound)
            backgroundSound = nil
        end
        composer.removeScene("pagina2")
        composer.gotoScene("pagina3", {
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
        composer.removeScene("pagina2")
        composer.gotoScene("capa", {
            effect = "crossFade",
            time = 500
        })
    end)

    local floresta = display.newImage(sceneGroup, "/assets/page2/floresta.png")
    floresta.x = display.contentCenterX
    floresta.y = display.contentCenterY - 15

    local pavao1 = display.newImage("assets/page2/pavao1.png")
    pavao1.x = display.contentCenterX + 70
    pavao1.y = display.contentCenterY + 90

    sceneGroup:insert(pavao1)

    local pavao2Added = false
    local function addPavao2()
        if not pavao2Added then
            pavao2Added = true
            local pavao2 = display.newImage("assets/page2/pavao2.png")
            pavao2.x = pavao1.x - 40
            pavao2.y = pavao1.y - 30
            sceneGroup:insert(2, pavao2)
        end
    end
    pavao1:addEventListener("tap", addPavao2)


    local images4 = {
        "assets/page2/camaleao1.png",
        "assets/page2/camaleao2.png",
        "assets/page2/camaleao3.png",
        "assets/page2/camaleao4.png"
    }
    local currentImageIndex4 = 1
    local animationStarted4 = false

    local animationImage4 = display.newImage(sceneGroup, images4[currentImageIndex4])
    animationImage4.x = display.contentCenterX - 160
    animationImage4.y = display.contentCenterY - 175

    local function changeImage4()
        currentImageIndex4 = currentImageIndex4 + 1
        if currentImageIndex4 > #images4 then return end
        animationImage4:removeSelf()
        animationImage4 = display.newImage(sceneGroup, images4[currentImageIndex4])
        animationImage4.x = display.contentCenterX - 160
        animationImage4.y = display.contentCenterY - 175
        sceneGroup:insert(animationImage4)
        if currentImageIndex4 <= #images4 then
            timer.performWithDelay(200, changeImage4)
        end
    end

    local function startAnimation4()
        if not animationStarted4 then
            animationStarted4 = true
            changeImage4()
        end
    end
    animationImage4:addEventListener("tap", startAnimation4)

    local sapo = display.newImage(sceneGroup, "/assets/page2/sapo.png")
    sapo.x = display.contentCenterX + 200
    sapo.y = display.contentCenterY - 90

    local sapoClicked = false

    local function startSnakeAnimation()
        if sapoClicked then return end 
        sapoClicked = true

        local cobra = display.newImage(sceneGroup, "/assets/page2/cobra.png")
        cobra.x = display.contentWidth + 220 
        cobra.y = display.contentHeight

        local origemX = cobra.x
        local origemY = cobra.y

        local toSapo = transition.to(cobra, {
            x = sapo.x, 
            y = sapo.y, 
            time = 3000,
            onComplete = function()
                if sapo then
                    sapo:removeSelf()
                end

                cobra.rotation = 180 

                local toOrigem = transition.to(cobra, {
                    x = origemX,
                    y = origemY,
                    time = 3000,
                    onComplete = function()
                        if cobra then
                            cobra:removeSelf()
                        end
                    end
                })

                table.insert(activeTransitions, toOrigem)
            end
        })

        table.insert(activeTransitions, toSapo)
    end

    sapo:addEventListener("tap", startSnakeAnimation)

    local som = display.newImage(sceneGroup, "/assets/buttons/som.png")
    som.x = display.contentWidth - som.width / 2 - MARGIN + 10
    som.y = display.contentHeight - som.height - 820

    backgroundSound = audio.loadStream("audio/pagina2.wav")

    
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

    if phase == "did" then
        if not isSoundOn then
            audio.play(backgroundSound, { loops = -1 })
            isSoundOn = true
        end
    end
end

function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        cancelAllTransitions()
        if isSoundOn then
            audio.stop()
            isSoundOn = false
        end
    end
end

function scene:destroy(event)
    local sceneGroup = self.view
    cancelAllTransitions()
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