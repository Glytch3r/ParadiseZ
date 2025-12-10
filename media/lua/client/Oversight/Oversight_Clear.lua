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

function ParadiseZ.ClearFloorItems()
    local count = 0
    local rad = SandboxVars.ParadiseZ.ClearRadius or 15
    local pl = getPlayer()
    if not pl then return end
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

function ParadiseZ.ClearFloorItems2()
    local pl = getPlayer() 
    if not pl then return end
    local itemBuffer = {}
    local rad = SandboxVars.ParadiseZ.ClearRadius or 15
    local cell = pl:getCell()
    local x, y, z = pl:getX(), pl:getY(), pl:getZ()
    for xDelta = -rad, rad do
        for yDelta = -rad, rad do
            local sq = cell:getGridSquare(x + xDelta, y + yDelta, z)
            if sq then
                for i = sq:getObjects():size()-1, 0, -1 do
                    local obj = sq:getObjects():get(i)
                    if instanceof(obj, "IsoWorldInventoryObject") then
                        table.insert(itemBuffer, { it = obj, square = sq })
                    end
                end
            end
        end
    end
    for _, itemData in ipairs(itemBuffer) do
        local sq = itemData.square
        local item = itemData.it
        sq:transmitRemoveItemFromSquare(item)
        item:removeFromWorld()
        item:removeFromSquare()
        item:setSquare(nil)
    end
    getPlayerLoot(0):refreshBackpacks()
    ISInventoryPage.renderDirty = true
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

function ParadiseZ.DespawnBodies() 
    local count = 0
    local rad = SandboxVars.ParadiseZ.ClearRadius or 15
    local pl = getPlayer()
    if not pl then return end
    local cell = pl:getCell()
    if not cell then return end
    local x, y, z = pl:getX(), pl:getY(), pl:getZ()
    for xDelta = -rad, rad do
        for yDelta = -rad, rad do
            local sq = cell:getOrCreateGridSquare(x + xDelta, y + yDelta, z)
            if sq then
                local objs = sq:getStaticMovingObjects()
                for i = objs:size()-1, 0, -1 do
                    local obj = objs:get(i)
                    if instanceof(obj, "IsoDeadBody") then
                        sq:removeCorpse(obj, true)
                        count = count + 1
                    end
                end
            end
        end
    end
    local s = count ~= 1 and 's' or ''
    pl:addLineChatElement("Removed "..tostring(count)..' Corpse'..s)
end

function ParadiseZ.StopFire()
    local rad = SandboxVars.ParadiseZ.ClearRadius or 15
    local pl = getPlayer()
    if not pl then return end
    local cell = pl:getCell()
    if not cell then return end
    local x, y, z = pl:getX(), pl:getY(), pl:getZ()
    for xDelta = -rad, rad do
        for yDelta = -rad, rad do
            local sq = cell:getOrCreateGridSquare(x + xDelta, y + yDelta, z)
            if sq and sq:Is(IsoFlagType.burning) then
                sq:transmitStopFire()
                sq:stopFire()
            end
        end
    end   
    pl:addLineChatElement("Stopped Fire")
end

function ParadiseZ.DespawnCars()
    local count = 0
    local rad = SandboxVars.ParadiseZ.ClearRadius or 15
    local pl = getPlayer()
    if not pl then return end
    local cell = pl:getCell()
    local x, y, z = pl:getX(), pl:getY(), pl:getZ()
    for xDelta = -rad, rad do
        for yDelta = -rad, rad do
            local sq = cell:getOrCreateGridSquare(x + xDelta, y + yDelta, z)
            if sq then
                local car = sq:getVehicleContainer() 
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

function ParadiseZ.DespawnPlants()
    local pl = getPlayer()
    if not pl then return end
    local x, y, z = pl:getX(), pl:getY(), pl:getZ()
    local rad = SandboxVars.ParadiseZ.ClearRadius or 15
    local cell = pl:getCell()
    if not cell then return end

    local count = 0
    for xx = -rad, rad do
        for yy = -rad, rad do
            local sq = cell:getGridSquare(x + xx, y + yy, z)
            if sq then
                for i = sq:getObjects():size()-1, 0, -1 do
                    local obj = sq:getObjects():get(i)
                    if obj then
                        local spr = obj:getSprite()
                        local props = spr and spr:getProperties()
                        if props and props:Is(IsoFlagType.canBeCut) or props:Is(IsoFlagType.canBeRemoved) then
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

function ParadiseZ.clearWeather()
    if isClient() then
        getClimateManager():transmitStopWeather()
    else
        getClimateManager():stopWeatherAndThunder()
    end
    local pl = getPlayer() 
    if pl then pl:addLineChatElement("Stopped Weather") end
end

function ParadiseZ.ClearTrees()
    local rad = SandboxVars.ParadiseZ.ClearRadius or 15       
    local pl = getPlayer() 
    if not pl then return end
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
