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
    pl:getKnownRecipes():clear()
    sendPlayerExtraInfo(pl)
    pl:addLineChatElement(tostring("All Learned Recipes Removed"))
end

function ParadiseZ.ClearTraits()
    local pl = getPlayer() 
	for i=1,TraitFactory.getTraits():size() do
        local trait = TraitFactory.getTraits():get(i-1)
        local tType = trait:getType()
        if tType then
            if pl:HasTrait(tType) then  
                pl:getTraits():remove(tType) 
            end
        end
    end
    pl:addLineChatElement(tostring("All Traits Removed"))
    sendPlayerExtraInfo(pl)
end

function ParadiseZ.ClearPerks()
    local pl = getPlayer() 
    for i = 1, 10  do
        for i=0, Perks.getMaxIndex() - 1 do
            perkType = PerkFactory.getPerk(Perks.fromIndex(i));
            pl:getXp():setXPToLevel(perkType, 0);
            pl:LoseLevel(perkType);
        end
    end
    pl:addLineChatElement(tostring("All Experience set to 0"))
    SyncXp(pl)
    sendPlayerExtraInfo(pl)
end
function ParadiseZ.ClearFloorItems()
    local count = 0
    local rad = SandboxVars.ParadiseZ.ClearRadius or 15
    local pl = getPlayer()
    local plNum = pl:getPlayerNum()

    local inv = ISInventoryPage.GetFloorContainer(plNum)
    for i = inv:getItems():size(), 1, -1 do
        local item = inv:getItems():get(i-1)
        if item then
            ISRemoveItemTool.removeItem(item, plNum)  
            count = count + 1
        end
    end
                  
    local s = ''
    if count > 1 then
        s = 's'
    end
    pl:addLineChatElement("Removed "..tostring(count)..' Item'..tostring(s))

    ISInventoryPage.dirtyUI()
    getPlayerLoot(plNum):refreshBackpacks() 
end

function ParadiseZ.ClearFloorItems2()
    local pl = getPlayer() 
    local itemBuffer = {}
    local rad = SandboxVars.ParadiseZ.ClearRadius or 15
    local cell = pl:getCell()
    local x, y, z = pl:getX(), pl:getY(), pl:getZ()
    for xDelta = -rad, rad do
        for yDelta = -rad, rad do
            local sq = cell:getGridSquare(x + xDelta, y + yDelta, z)
            for i=0, sq:getObjects():size()-1 do
                if instanceof(sq:getObjects():get(i), "IsoWorldInventoryObject") then
                    local item = sq:getObjects():get(i)
                    table.insert(itemBuffer, { it = item, square = sq })
                end
            end
        end
    end
    for i, itemData in ipairs(itemBuffer) do
        local sq = itemData.square
        local item = itemData.it
        sq:transmitRemoveItemFromSquare(item);
        item:removeFromWorld()
        item:removeFromSquare()
        item:setSquare(nil)
    end
    getPlayerLoot(0):refreshBackpacks()
    ISInventoryPage.renderDirty = true

end


function ParadiseZ.ClearWornItems()
    local pl = getPlayer() 
    local plNum = pl:getPlayerNum() 
    pl:clearWornItems();
    pl:resetModelNextFrame();
    ISInventoryPage.dirtyUI()
    getPlayerLoot(plNum):refreshBackpacks() 
end

function ParadiseZ.lvlUp()
    local pl = getPlayer()
    for i = 0, 11 -1 do
        for i=0, Perks.getMaxIndex() - 1 do
        perkType = PerkFactory.getPerk(Perks.fromIndex(i));
            local perkLevel = pl:getPerkLevel(perkType);
            if perkLevel < 10 then
                pl:LevelPerk(perkType, false);
                pl:getXp():setXPToLevel(perkType, pl:getPerkLevel(perkType));
                SyncXp(pl)
            end
        end
    end

    for i=0,TraitFactory.getTraits():size()-1 do
        local trait = TraitFactory.getTraits():get(i);
        if trait:getCost() >= 0 then
            if not pl:HasTrait(trait:getType()) then pl:getTraits():add(trait:getType()) end
        else
            if pl:HasTrait(trait:getType()) then  pl:getTraits():remove(trait:getType()) end
        end
    end
    pl:addLineChatElement(tostring('Level Up!'))    
    getSoundManager():playUISound("GainExperienceLevel")
end

function ParadiseZ.DespawnBodies()
    local count = 0
    local rad = SandboxVars.ParadiseZ.ClearRadius or 15
    local pl = getPlayer()
    local cell = pl:getCell()
    local x, y, z = pl:getX(), pl:getY(), pl:getZ()
    for xDelta = -rad, rad do
        for yDelta = -rad, rad do
            local sq = cell:getOrCreateGridSquare(x + xDelta, y + yDelta, z)                
            if sq then
                for i = 1, sq:getStaticMovingObjects():size() do
                    local obj = sq:getStaticMovingObjects():get(i-1)
                    if instanceof(obj, "IsoDeadBody") then
                        
                        sq:removeCorpse(obj, true)
                        count = count + 1
              --[[           obj:removeFromWorld()
                        obj:removeFromSquare() ]]
                    end 
                end
            end
        end
    end
    local s = ''
    if count > 1 then
        s = 's'
    end
    pl:addLineChatElement("Removed "..tostring(count)..' Corpse'..tostring(s))
end

function ParadiseZ.StopFire()
    local rad = SandboxVars.ParadiseZ.ClearRadius or 15
    local pl = getPlayer()
    local cell = pl:getCell()
    local x, y, z = pl:getX(), pl:getY(), pl:getZ()
    for xDelta = -rad, rad do
        for yDelta = -rad, rad do
            local sq = cell:getOrCreateGridSquare(x + xDelta, y + yDelta, z)
            if sq then
                if sq:Is(IsoFlagType.burning) then
                    sq:transmitStopFire()
                    sq:stopFire()
                end		
            end
        end
    end   
    pl:addLineChatElement("Stopped Fire")
    
end


function ParadiseZ.DespawnCars()
    local count = 0
    local rad = SandboxVars.ParadiseZ.ClearRadius or 15
    local pl = getPlayer()
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
    local s = ''
    if count > 1 then
        s = 's'
    end
    pl:addLineChatElement("Removed "..tostring(count)..' Vehicle'..tostring(s))
end

function ParadiseZ.DespawnPlants()
    local pl = getPlayer() 
    local x, y, z = pl:getX(), pl:getY(), pl:getZ()
    local rad = SandboxVars.ParadiseZ.ClearRadius or 15
    for xx = -rad, rad do
        for yy = -rad, rad do
            local sq = pl:getCell():getGridSquare(x + xx, y + yy, z)
            if sq then
                for i = sq:getObjects():size()-1, 0, -1 do
                    local obj = sq:getObjects():get(i)
                    --  bushes
                    if obj:getSprite() and obj:getSprite():getProperties() and obj:getSprite():getProperties():Is(IsoFlagType.canBeCut) then
                        sledgeDestroy(obj)
                        obj:getSquare():transmitRemoveItemFromSquare(obj)
                    --  grass
                    elseif obj:getSprite() and obj:getSprite():getProperties() and obj:getSprite():getProperties():Is(IsoFlagType.canBeRemoved) then
                        sledgeDestroy(obj)
                        obj:getSquare():transmitRemoveItemFromSquare(obj)
                    --  wall vines
                    else
                        local attached = obj:getAttachedAnimSprite()
                        if attached then
                            for n=1, attached:size() do
                                local sprite = attached:get(n-1)
                                if sprite and sprite:getParentSprite() and sprite:getParentSprite():getName() and
                                    luautils.stringStarts(sprite:getParentSprite():getName(), "f_wallvines_") then
                                    obj:RemoveAttachedAnims();
                                    if isClient() then
                                        obj:transmitUpdatedSpriteToServer() 
                                    end
    
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    targ:addLineChatElement(tostring("Removed grass, bushes and vines"))
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
    pl:addLineChatElement("Stopped Weather")
    
end
        
function ParadiseZ.ClearTrees()
    local rad = SandboxVars.ParadiseZ.ClearRadius or 15       
    local pl = getPlayer() 
    local count = 0
    local cell = pl:getCell()
    local x, y, z = pl:getX(), pl:getY(), pl:getZ()
    for xDelta = -rad, rad do
        for yDelta = -rad, rad do
            local sq = cell:getOrCreateGridSquare(x + xDelta, y + yDelta, z)
            for i=0, sq:getObjects():size()-1 do
                local obj = sq:getObjects():get(i)
                if instanceof(obj, "IsoTree") then
                    count = count + 1
                    if isClient() then
                        sledgeDestroy(obj)
                        obj:getSquare():transmitRemoveItemFromSquare(obj)
                    else
                        sq:RemoveTileObject(obj);
                        sq:getSpecialObjects():remove(obj);
                        sq:getObjects():remove(obj);
                        obj:getSquare():transmitRemoveItemFromSquare(obj)
                    end
                end
            end
        end
    end
    local s = ''
    if count > 1 then
        s = 's'
    end
    pl:addLineChatElement("Removed "..tostring(count)..' Tree'..tostring(s))
end

function ParadiseZ.ClearMap()
    WorldMapVisited.getInstance():forget()
    getPlayer():addLineChatElement("Map Records Deleted")    
end