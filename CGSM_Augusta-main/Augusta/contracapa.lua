local composer = require( "composer" )
local scene = composer.newScene()
local MARGIN = 40
local backgroundSound 
local isSoundOn = false 
 
function scene:create( event )
    local sceneGroup = self.view

    local backgroud = display.newImageRect(sceneGroup, "assets/Contra-Capa v2.png", 768, 1024)

    backgroud.x = display.contentCenterX
    backgroud.y = display.contentCenterY

    local voltar = display.newImage(sceneGroup, "/assets/buttons/voltar.png")
    voltar.x = display.contentWidth - voltar.width/2 - MARGIN - 60
    voltar.y = display.contentHeight - voltar.height/2 - MARGIN

    voltar:addEventListener("tap", function (event)
        if backgroundSound then
            audio.stop()
            audio.dispose(backgroundSound)
            backgroundSound = nil
        end
        composer.removeScene("contracapa")
        composer.gotoScene("pagina6", {
            effect = "crossFade",
            time = 500
        });
        
    end)

    local home = display.newImage(sceneGroup, "/assets/buttons/home.png")
    home.x = display.contentWidth - home.width/2 - MARGIN - 615
    home.y = display.contentHeight - home.height/2 - MARGIN

    home:addEventListener("tap", function (event)
        if backgroundSound then
            audio.stop()
            audio.dispose(backgroundSound)
            backgroundSound = nil
        end
        composer.removeScene("contracapa")
        composer.gotoScene("capa", {
            effect = "crossFade",
            time = 500
        });
        
    end)

    local ref = display.newImage(sceneGroup, "/assets/buttons/referencias.png")
    ref.x = display.contentWidth - 415
    ref.y = display.contentHeight - ref.height

    ref:addEventListener("tap", function (event)
        if backgroundSound then
            audio.stop()
            audio.dispose(backgroundSound)
            backgroundSound = nil
        end
        composer.removeScene("contracapa")
        composer.gotoScene("referencias", {
            effect = "crossFade",
            time = 500

        });

    end)

    local som = display.newImage(sceneGroup, "/assets/buttons/som.png")
    som.x = display.contentWidth - som.width / 2 - MARGIN - 590
    som.y = display.contentHeight - som.height - 820

    backgroundSound = audio.loadStream("audio/contracapa.wav")

    
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

 
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
return scene