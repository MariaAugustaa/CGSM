local composer = require("composer")
local scene = composer.newScene()
local MARGIN = 40
local backgroundSound 
local isSoundOn = false
local currentSegment = nil

function scene:create(event)
    local sceneGroup = self.view

    local background = display.newImageRect(sceneGroup, "assets/page3/pagina 3 v2.png", 768, 1024)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local proximo = display.newImage(sceneGroup, "/assets/buttons/proximo.png")
    proximo.x = display.contentWidth - proximo.width / 2 - MARGIN
    proximo.y = display.contentHeight - proximo.height / 2 - MARGIN

    proximo:addEventListener("tap", function(event)
        if backgroundSound then
            audio.stop()
            audio.dispose(backgroundSound)
            backgroundSound = nil
        end
        composer.removeScene("pagina3")
        composer.gotoScene("pagina4", {
            effect = "crossFade",
            time = 500
        });
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
        composer.removeScene("pagina3")
        composer.gotoScene("pagina2", {
            effect = "crossFade",
            time = 500
        });
    end)

    local butterfly = display.newImage(sceneGroup, "assets/page3/butterfly_default.png")
    butterfly.x = display.contentCenterX - 140
    butterfly.y = display.contentCenterY + 130

    local dnaMolecule = display.newImage(sceneGroup, "assets/page3/molecula.png")
    dnaMolecule.x = display.contentCenterX + 235
    dnaMolecule.y = display.contentCenterY + 138

    local dnaSegments = {
        {image = "assets/page3/dna1.png", butterflyImage = "assets/page3/butterfly_1.png"},
        {image = "assets/page3/dna2.png", butterflyImage = "assets/page3/butterfly_2.png"},
        {image = "assets/page3/dna3.png", butterflyImage = "assets/page3/butterfly_3.png"},
        {image = "assets/page3/dna4.png", butterflyImage = "assets/page3/butterfly_4.png"}
    }

    local function createSegment(data, x, y)
        local segment = display.newImage(sceneGroup, data.image)
        segment.x = x
        segment.y = y
        segment.originalX = x
        segment.originalY = y
        segment.butterflyImage = data.butterflyImage

        segment:addEventListener("touch", function(event)
            if event.phase == "began" then
                display.getCurrentStage():setFocus(segment)
                segment.isFocus = true
            elseif event.phase == "moved" and segment.isFocus then
                segment.x = event.x
                segment.y = event.y
            elseif event.phase == "ended" or event.phase == "cancelled" then
                display.getCurrentStage():setFocus(nil)
                segment.isFocus = false

                local dx = math.abs(segment.x - dnaMolecule.x)
                local dy = math.abs(segment.y - dnaMolecule.y)
                if dx < 70 and dy < 70 then
                    
                    if currentSegment then
                        currentSegment.x = currentSegment.originalX
                        currentSegment.y = currentSegment.originalY
                        currentSegment.rotation = 0
                    end

                    segment.x = dnaMolecule.x
                    segment.y = dnaMolecule.y
                    segment.rotation = 90
                    butterfly.fill = {type = "image", filename = segment.butterflyImage}
                    currentSegment = segment 
                else
                    segment.x = segment.originalX
                    segment.y = segment.originalY
                end
            end
            return true
        end)

        return segment
    end

    local startX = display.contentCenterX - 290
    local startY = display.contentHeight - 120
    for i, data in ipairs(dnaSegments) do
        createSegment(data, startX + (i * 100), startY)
    end

    local som = display.newImage(sceneGroup, "/assets/buttons/som.png")
    som.x = display.contentWidth - som.width / 2 - MARGIN + 10
    som.y = display.contentHeight - som.height - 820

    backgroundSound = audio.loadStream("audio/pagina3.wav")

    
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

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
