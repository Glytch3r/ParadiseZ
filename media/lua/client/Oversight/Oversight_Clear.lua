----------------------------------------------------------------
-----  ▄▄▄   ▄    ▄   ▄  ▄▄▄▄▄   ▄▄▄   ▄   ▄   ▄▄▄    ▄▄▄  -----
----- █   ▀  █    █▄▄▄█    █    █   ▀  █▄▄▄█  ▀  ▄█  █ ▄▄▀ -----
----- █  ▀█  █      █      █    █   ▄  █   █  ▄   █  █   █ -----
-----  ▀▀▀▀  ▀▀▀▀   ▀      ▀     ▀▀▀   ▀   ▀   ▀▀▀   ▀   ▀ -----
----------------------------------------------------------------
--                                                            --
--   Project Zomboid Modding Commissions                      --
--   https://steamcommunity.com/id/glytch3r/myworkshopfiles   --
--                                                            --
--   ▫ Discord  ꞉   glytch3r                                  --
--   ▫ Support  ꞉   https://ko-fi.com/glytch3r                --
--   ▫ Youtube  ꞉   https://www.youtube.com/@glytch3r         --
--   ▫ Github   ꞉   https://github.com/Glytch3r               --
--                                                            --
----------------------------------------------------------------
----- ▄   ▄   ▄▄▄   ▄   ▄   ▄▄▄     ▄      ▄   ▄▄▄▄  ▄▄▄▄  -----
----- █   █  █   ▀  █   █  ▀   █    █      █      █  █▄  █ -----
----- ▄▀▀ █  █▀  ▄  █▀▀▀█  ▄   █    █    █▀▀▀█    █  ▄   █ -----
-----  ▀▀▀    ▀▀▀   ▀   ▀   ▀▀▀   ▀▀▀▀▀  ▀   ▀    ▀   ▀▀▀  -----
----------------------------------------------------------------

ParadiseZ = ParadiseZ or {}


function ParadiseZ.highlightSqHandler()
    local function highlightSq(sq)
        local flr = sq:getFloor()
        if flr then
            flr:setHighlightColor(1, 1, 0, 1)
            flr:setHighlighted(true, true)
        end
    end
    ParadiseZ.highlightTick = ParadiseZ.highlightTick + 1
    if ParadiseZ.highlightTick % 3 == 0 then
        ParadiseZ.highlightTick = 0
        local rad = SandboxVars.ParadiseZ.ClearRadius or 15
        local pl = getPlayer()
        local cell = pl:getCell()
        local x, y, z = pl:getX(), pl:getY(), pl:getZ()
        for xDelta = -rad, rad do
            for yDelta = -rad, rad do
                local sq = cell:getOrCreateGridSquare(x + xDelta, y + yDelta, z)
                highlightSq(sq)
            end
        end
    end
end

function ParadiseZ.closeModal()
    Events.OnPlayerUpdate.Remove(ParadiseZ.highlightSqHandler)
    if ParadiseZ.ClearModalInstance then
        ParadiseZ.ClearModalInstance:destroy()
        ParadiseZ.ClearModalInstance = nil
    end
end

function ParadiseZ.popup(title, text, yesFn, yesTitle)
    if ParadiseZ.ClearModalInstance then ParadiseZ.closeModal() end

    local pl = getPlayer()
    if not pl then return end
    local plNum = pl:getPlayerNum()
    
    ParadiseZ.ClearModalInstance = ISModalDialog:new(
        0,
        0,
        300,
        150,
        text or "",
        true,
        nil,
        function(_, button)
            if button == ParadiseZ.ClearModalInstance.yes then
                if yesFn then
                    local pl = getSpecificPlayer(plNum)
                    if pl then yesFn(pl) end
                end
            end
            ParadiseZ.closeModal()
        end,
        plNum
    )

    ParadiseZ.ClearModalInstance.yes = yesTitle and tostring(yesTitle) or getText("UI_Yes")
    ParadiseZ.ClearModalInstance.no  = getText("UI_Cancel")
    ParadiseZ.ClearModalInstance.title = title or ""

    ParadiseZ.highlightTick = 0
    Events.OnPlayerUpdate.Add(ParadiseZ.highlightSqHandler)

    ParadiseZ.ClearModalInstance.onRightMouseUp = function()
        ParadiseZ.closeModal()
    end

    ParadiseZ.ClearModalInstance:initialise()
    ParadiseZ.ClearModalInstance:addToUIManager()
end


-----------------------            ---------------------------
--[[ function luautils.okModal(_text, _centered, _width, _height, _posX, _posY)
    local posX = _posX or 0;
    local posY = _posY or 0;
    local width = _width or 230;
    local height = _height or 120;
    local centered = _centered;
    local txt = _text;
    local core = getCore();

    if centered then
        posX = core:getScreenWidth() * 0.5 - width * 0.5;
        posY = core:getScreenHeight() * 0.5 - height * 0.5;
    end
    
    local modal = ISModalDialog:new(posX, posY, width, height, txt, false, nil, nil);
    modal:initialise();
    modal:addToUIManager();
end ]]
function ParadiseZ.ClearFloorItems(pl)
    pl = pl or getPlayer() 
    if not pl then return end

    local count = 0
    local plNum = pl:getPlayerNum()
    local inv = ISInventoryPage.GetFloorContainer(plNum)
    if inv then
        for i = inv:getItems():size(), 1, -1 do
            local item = inv:getItems():get(i-1)
            if item then
                ISRemoveItemTool.removeItem(item, plNum)
                count = count + 1
            end
        end
    end
    local s = count ~= 1 and 's' or ''
    pl:addLineChatElement("Removed "..tostring(count)..' Item'..s)
    ISInventoryPage.dirtyUI()
    getPlayerLoot(plNum):refreshBackpacks()
end

function ParadiseZ.ClearFloorItems2(pl)
    pl = pl or getPlayer() 
    if not pl then return end

    local itemBuffer = {}
    local rad = SandboxVars.ParadiseZ.ClearRadius or 15
    local cell = pl:getCell()
    local sq = pl:getCurrentSquare()
    if not cell or not sq then return end
    local x, y, z = sq:getX(), sq:getY(), sq:getZ()

    for xDelta = -rad, rad do
        for yDelta = -rad, rad do
            local targetSq = cell:getGridSquare(x + xDelta, y + yDelta, z)
            if targetSq then
                for i = targetSq:getObjects():size()-1, 0, -1 do
                    local obj = targetSq:getObjects():get(i)
                    if instanceof(obj, "IsoWorldInventoryObject") then
                        table.insert(itemBuffer, { it = obj, square = targetSq })
                    end
                end
            end
        end
    end

    for _, itemData in ipairs(itemBuffer) do
        local targetSq = itemData.square
        local item = itemData.it
        targetSq:transmitRemoveItemFromSquare(item)
        item:removeFromWorld()
        item:removeFromSquare()
        item:setSquare(nil)
    end

    getPlayerLoot(pl:getPlayerNum()):refreshBackpacks()
    ISInventoryPage.renderDirty = true
end

function ParadiseZ.StopFire(pl)
    pl = pl or getPlayer() 
    if not pl then return end

    local rad = SandboxVars.ParadiseZ.ClearRadius or 15
    local cell = pl:getCell()
    local sq = pl:getCurrentSquare()
    if not cell or not sq then return end
    local x, y, z = sq:getX(), sq:getY(), sq:getZ()

    for xDelta = -rad, rad do
        for yDelta = -rad, rad do
            local targetSq = cell:getOrCreateGridSquare(x + xDelta, y + yDelta, z)
            if targetSq and targetSq:Is(IsoFlagType.burning) then
                targetSq:transmitStopFire()
                targetSq:stopFire()
            end
        end
    end

    pl:addLineChatElement("Stopped Fire")
end

function ParadiseZ.DespawnCars(pl)
    pl = pl or getPlayer() 
    if not pl then return end

    local rad = SandboxVars.ParadiseZ.ClearRadius or 15
    local cell = pl:getCell()
    local sq = pl:getCurrentSquare()
    if not cell or not sq then return end
    local x, y, z = sq:getX(), sq:getY(), sq:getZ()
    local count = 0

    for xDelta = -rad, rad do
        for yDelta = -rad, rad do
            local targetSq = cell:getOrCreateGridSquare(x + xDelta, y + yDelta, z)
            if targetSq then
                local car = targetSq:getVehicleContainer()
                if car then
                    count = count + 1
                    if isClient() then sendClientCommand(pl, "vehicle", "remove", { vehicle = car:getId() }) end
                    car:permanentlyRemove()
                end
            end
        end
    end

    local s = count ~= 1 and 's' or ''
    pl:addLineChatElement("Removed "..tostring(count)..' Vehicle'..s)
end

function ParadiseZ.DespawnPlants(pl)
    pl = pl or getPlayer() 
    if not pl then return end

    local rad = SandboxVars.ParadiseZ.ClearRadius or 15
    local cell = pl:getCell()
    local sq = pl:getCurrentSquare()
    if not cell or not sq then return end
    local x, y, z = sq:getX(), sq:getY(), sq:getZ()
    local count = 0

    for xx = -rad, rad do
        for yy = -rad, rad do
            local targetSq = cell:getGridSquare(x + xx, y + yy, z)
            if targetSq then
                for i = targetSq:getObjects():size()-1, 0, -1 do
                    local obj = targetSq:getObjects():get(i)
                    if obj then
                        local spr = obj:getSprite()
                        local props = spr and spr:getProperties()
                        if (props and (props:Is(IsoFlagType.canBeCut) or props:Is(IsoFlagType.canBeRemoved))) then
                            sledgeDestroy(obj)
                            local objSq = obj:getSquare()
                            if objSq then objSq:transmitRemoveItemFromSquare(obj) end
                            count = count + 1
                        else
                            local attached = obj:getAttachedAnimSprite()
                            if attached then
                                for n = 0, attached:size()-1 do
                                    local sprite = attached:get(n)
                                    if sprite and sprite:getParentSprite() and sprite:getParentSprite():getName() and
                                       luautils.stringStarts(sprite:getParentSprite():getName(), "f_wallvines_") then
                                        obj:RemoveAttachedAnims()
                                        if isClient() then obj:transmitUpdatedSpriteToServer() end
                                        count = count + 1
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    pl:addLineChatElement("Removed "..tostring(count)..' grass, bushes, and vines')
end

function ParadiseZ.ClearTrees(pl)
    pl = pl or getPlayer() 
    if not pl then return end

    local rad = SandboxVars.ParadiseZ.ClearRadius or 15       
    local count = 0
    local cell = pl:getCell()
    if not cell then return end
    local x, y, z = pl:getX(), pl:getY(), pl:getZ()
    for xDelta = -rad, rad do
        for yDelta = -rad, rad do
            local sq = cell:getOrCreateGridSquare(x + xDelta, y + yDelta, z)
            if sq then
                for i = sq:getObjects():size()-1, 0, -1 do
                    local obj = sq:getObjects():get(i)
                    if instanceof(obj, "IsoTree") then
                        count = count + 1
                        if isClient() then
                            sledgeDestroy(obj)
                            obj:getSquare():transmitRemoveItemFromSquare(obj)
                        else
                            sq:RemoveTileObject(obj)
                            sq:getSpecialObjects():remove(obj)
                            sq:getObjects():remove(obj)
                            obj:getSquare():transmitRemoveItemFromSquare(obj)
                        end
                    end
                end
            end
        end
    end
    local s = count ~= 1 and 's' or ''
    pl:addLineChatElement("Removed "..tostring(count)..' Tree'..s)
end
-----------------------            ---------------------------

function ParadiseZ.cleanChar()
    local pl = getPlayer()
    if not pl then return end
    pl:getHumanVisual():removeBlood()
    pl:resetModelNextFrame()
    triggerEvent("OnClothingUpdated", pl)
    pl:resetModel()
    local blood = 0
    local inventory = pl:getInventory()
    if inventory and inventory:getItems():size() > 0 then
        local item = inventory:getItems():get(0)
        if item and item:getBloodClothingType() then
            local coveredParts = BloodClothingType.getCoveredParts(item:getBloodClothingType())
            if coveredParts then
                for j = 0, coveredParts:size()-1 do
                    item:setBlood(coveredParts:get(j), blood)
                end
            end
            item:setBloodLevel(blood)
        end
    end

    local soapList = {}
    local soapCount = 3
    for i = 1, soapCount do
        local soapItem = pl:getInventory():AddItem("Base.Soap2")
        table.insert(soapList, soapItem)
    end
    local sink = IsoThumpable.new(getCell(), pl:getSquare(), nil, "fixtures_sinks_01_0", false, {})
    sink:setWaterAmount(100)
    local action = ISWashYourself:new(pl, sink, soapList)
    action:perform()

    pl:resetModel()
    sendClothing(pl)
end

function ParadiseZ.washChar()
    local pl = getPlayer() 
    if not pl or not pl:isAlive() then return end

    local vis = pl:getHumanVisual()
    local iVis = pl:getItemVisuals()
    local bVis = vis:getBodyVisuals()

    vis:removeBlood()
    vis:randomDirt() 
    for i = 0, BloodBodyPartType.MAX:index() - 1 do
        local part = BloodBodyPartType.FromIndex(i)
        vis:setBlood(part, 0)
        vis:setDirt(part, 0)
    end

    for i = 0, iVis:size() - 1 do
        local item = iVis:get(i)
        if item then
            for j = 0, BloodBodyPartType.MAX:index() - 1 do
                local part = BloodBodyPartType.FromIndex(j)
                item:setBlood(part, 0)
                item:setDirt(part, 0)
                if item:getHole(part) ~= 0 then item:removeHole(j) end
            end
        end
    end

    for j = bVis:size() - 1, 0, -1 do
        local item = bVis:get(j)
        if item then
            local fType = item:getItemType()
            if luautils.stringStarts(fType, "Base.ZedDmg_") or 
               luautils.stringStarts(fType, "Base.Wound_") or 
               luautils.stringStarts(fType, "Base.Bandage_") then
                vis:removeBodyVisualFromItemType(fType)
            end
        end
    end

    pl:resetModelNextFrame()
    pl:resetModel()
end

function ParadiseZ.clearWeather()
    if isClient() then
        getClimateManager():transmitStopWeather()
    else
        getClimateManager():stopWeatherAndThunder()
    end
    local pl = getPlayer() 
    if pl then pl:addLineChatElement("Stopped Weather") end
end

function ParadiseZ.ClearMap()
    WorldMapVisited.getInstance():forget()
    local pl = getPlayer()
    if pl then pl:addLineChatElement("Map Records Deleted") end
end

function ParadiseZ.ClearModData()
    local pl = getPlayer() 
    if pl then
        local modData = pl:getModData()
        for k in pairs(modData) do
            modData[k] = nil
        end
    end
end
function ParadiseZ.ClearLearned()
    local pl = getPlayer() 
    if not pl then return end
    pl:getKnownRecipes():clear()
    sendPlayerExtraInfo(pl)
    pl:addLineChatElement("All Learned Recipes Removed")
end

function ParadiseZ.ClearTraits()
    local pl = getPlayer() 
    if not pl then return end
    for i = TraitFactory.getTraits():size()-1, 0, -1 do
        local trait = TraitFactory.getTraits():get(i)
        local tType = trait:getType()
        if tType and pl:HasTrait(tType) then  
            pl:getTraits():remove(tType) 
        end
    end
    pl:addLineChatElement("All Traits Removed")
    sendPlayerExtraInfo(pl)
end

function ParadiseZ.ClearPerks()
    local pl = getPlayer() 
    if not pl then return end
    for _ = 1, 10 do
        for i = 0, Perks.getMaxIndex() - 1 do
            local perkType = PerkFactory.getPerk(Perks.fromIndex(i))
            pl:getXp():setXPToLevel(perkType, 0)
            pl:LoseLevel(perkType)
        end
    end
    pl:addLineChatElement("All Experience set to 0")
    SyncXp(pl)
    sendPlayerExtraInfo(pl)
end

function ParadiseZ.ClearWornItems()
    local pl = getPlayer() 
    if not pl then return end
    local plNum = pl:getPlayerNum() 
    pl:clearWornItems()
    pl:resetModelNextFrame()
    ISInventoryPage.dirtyUI()
    getPlayerLoot(plNum):refreshBackpacks()
end

function ParadiseZ.lvlUp()
    local pl = getPlayer()
    if not pl then return end
    for _ = 0, 10 do
        for i = 0, Perks.getMaxIndex() - 1 do
            local perkType = PerkFactory.getPerk(Perks.fromIndex(i))
            local perkLevel = pl:getPerkLevel(perkType)
            if perkLevel < 10 then
                pl:LevelPerk(perkType, false)
                pl:getXp():setXPToLevel(perkType, pl:getPerkLevel(perkType))
                SyncXp(pl)
            end
        end
    end
    for i = TraitFactory.getTraits():size()-1, 0, -1 do
        local trait = TraitFactory.getTraits():get(i)
        if trait:getCost() >= 0 then
            if not pl:HasTrait(trait:getType()) then pl:getTraits():add(trait:getType()) end
        else
            if pl:HasTrait(trait:getType()) then pl:getTraits():remove(trait:getType()) end
        end
    end
    pl:addLineChatElement("Level Up!")    
    getSoundManager():playUISound("GainExperienceLevel")
end
-----------------------            ---------------------------