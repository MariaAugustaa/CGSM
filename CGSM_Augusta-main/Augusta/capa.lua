local composer = require( "composer" )
local scene = composer.newScene() 
local MARGIN = 40
local backgroundSound 
local isSoundOn = false 
 
function scene:create( event )
    local sceneGroup = self.view
    local backgroud = display.newImageRect(sceneGroup, "assets/Capa v2.png", 768, 1024)

    backgroud.x = display.contentCenterX
    backgroud.y = display.contentCenterY

    local proximo = display.newImage(sceneGroup, "/assets/buttons/proximo.png")
    proximo.x = display.contentWidth - proximo.width/2 - MARGIN
    proximo.y = display.contentHeight - proximo.height/2 - MARGIN

    proximo:addEventListener("tap", function (event)
        if backgroundSound then
            audio.stop()
            audio.dispose(backgroundSound)
            backgroundSound = nil
        end
        composer.removeScene("capa")
        composer.gotoScene("pagina2", {
            effect = "crossFade",
            time = 500
        });
        
    end)

    local som = display.newImage(sceneGroup, "/assets/buttons/som.png")
    som.x = display.contentWidth - som.width / 2 - MARGIN + 10
    som.y = display.contentHeight - som.height - 820

    backgroundSound = audio.loadStream("audio/capa.wav")

    
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