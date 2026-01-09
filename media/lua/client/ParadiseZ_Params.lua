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

ParadiseZ.defaultShotguns = {
    ["Base.Shotgun"] = true,
    ["Base.Spas12"] = true,
    ["Base.Spas12Folded"] = true,
    ["Base.ShotgunSemi"] = true,
    ["Base.Shotgun2"] = true,
    ["Base.ShotgunSawnoff"] = true,
    ["Base.ShotgunSawnoffNoStock"] = true,
    ["Base.DoubleBarrelShotgun"] = true,
    ["Base.DoubleBarrelShotgunSawnoff"] = true,
    ["Base.DoubleBarrelShotgunSawnoffNoStock"] = true,
    ["SpoonEngineerStuff.ScrappyBlunderbuss"] = true,
    ["Base.AssaultRifleMasterkeyShotgun"] = true,
    ["Base.M2400_Shotgun"] = true,
}

function ParadiseZ.getShotgunTable()
    local strList = SandboxVars.ParadiseZ and SandboxVars.ParadiseZ.ShotgunList
    if not strList or strList == "" then
        return ParadiseZ.defaultShotguns
    end
    local t = {}
    for item in string.gmatch(strList, "[^;]+") do
        t[item] = true
    end
    return t
end

function ParadiseZ.isFirearm(item)
    if not item then return false end
    local si = item:getScriptItem()
    return si and si:isRanged()
end

function ParadiseZ.resolveGunParams(scriptItem, fType, shotgunTable)
    local scale = SandboxVars.ParadiseZ.PerkModifierScale or 1000
    local perk
    local minAngle
    local class

    if scriptItem.getSwingAnim and scriptItem:getSwingAnim() == "Rifle" then
        if shotgunTable[fType] then
            class = "Shotgun"
            perk = (SandboxVars.ParadiseZ.PerkModifierShotgun or 2) / scale
            minAngle = SandboxVars.ParadiseZ.MinAngleShotgun
        else
            class = "Rifle"
            perk = (SandboxVars.ParadiseZ.PerkModifierRifle or 1) / scale
            minAngle = SandboxVars.ParadiseZ.MinAngleRifle
        end
    else
        class = "Pistol"
        perk = (SandboxVars.ParadiseZ.PerkModifierPistol or 1) / scale
        minAngle = SandboxVars.ParadiseZ.MinAnglePistol
    end

    return class, perk, minAngle
end
-----------------------            ---------------------------
function ParadiseZ.applyGunParams(shouldPrint)
    local sm = ScriptManager.instance
    local allItems = sm:getAllItems()
    local shotgunTable = ParadiseZ.getShotgunTable()
    local angleFalloff = SandboxVars.ParadiseZ.AngleFalloff
    local gunKey = SandboxVars.ParadiseZ.GunVersionKey
    local gunTip = SandboxVars.ParadiseZ.GunTooltip or ""
    local res = ""

    for i = 0, allItems:size() - 1 do
        local item = allItems:get(i)
        local fType = item:getModuleName() .. "." .. item:getName()
        local wpn = sm:getItem(fType)

        if wpn and wpn:isRanged() then
            local class, perk, minAngle = ParadiseZ.resolveGunParams(wpn, fType, shotgunTable)

            if angleFalloff ~= nil then
                wpn:DoParam("AngleFalloff = " .. tostring(angleFalloff))
            end

            if perk and minAngle then
                wpn:DoParam("AimingPerkMinAngleModifier = " .. tostring(perk))
                wpn:DoParam("MinAngle = " .. tostring(minAngle))
                if gunKey then
                    wpn:DoParam("ParadiseGun = " .. tostring(gunKey))
                end
                if gunTip ~= "" and gunKey then
                    wpn:DoParam("Tooltip = " .. gunTip .. " " .. tostring(gunKey))
                end
                res = res .. "\nModified: " .. class .. " : " .. fType
            end
        end
    end

    if shouldPrint then
        print(res)
    end
end

Events.OnCreatePlayer.Add(function()
    ParadiseZ.applyGunParams()
end)

-----------------------            ---------------------------

function ParadiseZ.updateExistingGun(item)
    local si = item:getScriptItem()
    if not si then return end

    local fType = item:getFullType()
    local shotgunTable = ParadiseZ.getShotgunTable()
    local angleFalloff = SandboxVars.ParadiseZ.AngleFalloff
    local gunKey = SandboxVars.ParadiseZ.GunVersionKey
    local gunTip = SandboxVars.ParadiseZ.GunTooltip or ""

    local _, perk, minAngle = ParadiseZ.resolveGunParams(si, fType, shotgunTable)

    if angleFalloff ~= nil then
        item:setAngleFalloff(angleFalloff)
    end

    if perk and minAngle then
        item:setAimingPerkMinAngleModifier(perk)
        item:setMinAngle(minAngle)
    end

    if gunKey then
        item:getModData().GunVersionKey = tostring(gunKey)
    end

    if gunTip ~= "" and gunKey then
        item:setTooltip(gunTip .. " " .. tostring(gunKey))
    end
end

function ParadiseZ.updatePlayerGuns()
    local pl = getPlayer()
    if not pl then return end

    local items = pl:getInventory():getItems()
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if ParadiseZ.isFirearm(item) then
            ParadiseZ.updateExistingGun(item)
        end
    end
end

Events.OnEquipPrimary.Add(ParadiseZ.updatePlayerGuns)
Events.OnClothingUpdated.Add(ParadiseZ.updatePlayerGuns)

-----------------------            ---------------------------
--[[ ParadiseZ = ParadiseZ or {}
ParadiseZ.defaultShotguns = {
    ["Base.Shotgun"] = true, 
    ["Base.Spas12"] = true, 
    ["Base.Spas12Folded"] = true, 
    ["Base.ShotgunSemi"] = true, 
    ["Base.Shotgun2"] = true, 
    ["Base.ShotgunSawnoff"] = true, 
    ["Base.ShotgunSawnoffNoStock"] = true, 
    ["Base.DoubleBarrelShotgun"] = true, 
    ["Base.DoubleBarrelShotgunSawnoff"] = true, 
    ["Base.DoubleBarrelShotgunSawnoffNoStock"] = true, 
    ["SpoonEngineerStuff.ScrappyBlunderbuss"] = true, 
    ["Base.AssaultRifleMasterkeyShotgun"] = true, 
    ["Base.M2400_Shotgun"] = true,
}

function ParadiseZ.getShotgunTable()
    local strList = SandboxVars.ParadiseZ.ShotgunList 
    local t = {}
    for item in string.gmatch(strList, "[^;]+") do
        t[item] = true
    end
    return t
end

function ParadiseZ.isFirearm(item)
    if not item then return false end
    local scriptItem = item.getScriptItem and item:getScriptItem()
    return scriptItem and scriptItem.isRanged and scriptItem:isRanged()
end

function ParadiseZ.applyGunParams(shouldPrint)    
    local GunVersionKey = SandboxVars.ParadiseZ and SandboxVars.ParadiseZ.GunVersionKey or 0
    local GunTooltip = SandboxVars.ParadiseZ and SandboxVars.ParadiseZ.GunTooltip or ""
    local allItems = getScriptManager():getAllItems()
    local sm = ScriptManager.instance
    local res = ""
    local shotgunTable = ParadiseZ.getShotgunTable()
    
    for i = 1, allItems:size() do
        local item = allItems:get(i - 1)
        local fType = item:getModuleName() .. '.' .. item:getName()
        if fType then
            local wpn = sm:getItem(fType)
            local wpnClass = "Pistol"
            local PerkModifier
            local MinAngle
            if wpn and wpn.isRanged and wpn:isRanged() then
                if wpn.getSwingAnim and wpn:getSwingAnim() == "Rifle" then
                    if shotgunTable[fType] == true then
                        wpnClass = "Shotgun"
                        PerkModifier = SandboxVars.ParadiseZ.PerkModifierShotgun 
                        MinAngle = SandboxVars.ParadiseZ.MinAngleShotgun 
                    else
                        wpnClass = "Rifle "
                        PerkModifier = SandboxVars.ParadiseZ.PerkModifierRifle 
                        MinAngle = SandboxVars.ParadiseZ.MinAngleRifle 
                    end    
                else
                    wpnClass = "Pistol "
                    PerkModifier = SandboxVars.ParadiseZ.PerkModifierPistol
                    MinAngle = SandboxVars.ParadiseZ.MinAnglePistol
                end
            end
            if PerkModifier and MinAngle then
                res = res.."\nModified: "..tostring(wpnClass).."  :  "..tostring(fType)
                wpn:DoParam("AimingPerkMinAngleModifier = " .. tostring(PerkModifier))
                wpn:DoParam("MinAngle = " .. tostring(MinAngle))
                wpn:DoParam("AngleFalloff = true")
                wpn:DoParam("ParadiseGun = " .. tostring(GunVersionKey))
                wpn:DoParam("Tooltip = " .. tostring(GunTooltip)..' '..tostring(GunVersionKey))
            end
        end
    end
    if shouldPrint then print(res) end
end

Events.OnCreatePlayer.Add(function()
    ParadiseZ.applyGunParams()
end)


function ParadiseZ.oldGunDespawner()
    local GunUpdater = SandboxVars.ParadiseZ.GunUpdater
    if not GunUpdater then return end
    local GunVersionKey = SandboxVars.ParadiseZ.GunVersionKey
    local pl = getPlayer()
    if not pl then return end
    
    local inv = pl:getInventory() 
    for i = inv:getItems():size(), 1, -1 do
        local item = inv:getItems():get(i-1)
        if ParadiseZ.isFirearm(item) then
            local md = item:getModData()
            local data = md.GunVersionKey
            if not data or (tostring(data) and data ~= tostring(GunVersionKey)) then
                ParadiseZ.updateGun(item)
            end
        end
    end
end
Events.OnEquipPrimary.Add(ParadiseZ.oldGunDespawner)
Events.OnClothingUpdated.Add(ParadiseZ.oldGunDespawner)

function ParadiseZ.updateGun(item)
    if not item then return end
    local pl = getPlayer()
    if not pl then return end
    local inv = pl:getInventory()
    if not inv then return end
    
    local fType = item:getFullType()
    if not fType then return end
    
    local GunTooltip = SandboxVars.ParadiseZ.GunTooltip
    local curKey = SandboxVars.ParadiseZ.GunVersionKey
    local md = item:getModData()
    local itemKey = md and md.GunVersionKey
    
    if not itemKey or itemKey ~= curKey then
        local pr = pl:getPrimaryHandItem()
        local sc = pl:getSecondaryHandItem()
        
        if (pr and pr == item) or (sc and sc == item) then
            pl:removeFromHands(item)
        end
        
        local toSpawn = inv:AddItem(fType)
        if not toSpawn then return end
        
        if getCore():getDebug() then 
            local msg = 'GunVersionKey Update [' .. tostring(fType)..']: '..tostring(itemKey)..' ====> '.. tostring(curKey)
            if not itemKey then
                msg = 'GunVersionKey Update [' .. tostring(fType)..']: '.. tostring(curKey)
            end
            pl:addLineChatElement(tostring(msg))
        end
        
        toSpawn:setCurrentAmmoCount(item:getCurrentAmmoCount())
        toSpawn:setRoundChambered(item:isRoundChambered())
        
        local mag = item:isContainsClip()
        if toSpawn:isContainsClip() ~= mag then
            toSpawn:setContainsClip(mag)
        end
        
        local part = item:getScope()
        if part then
            item:detachWeaponPart(part)
            toSpawn:attachWeaponPart(part)
        end
        part = item:getClip()
        if part then
            item:detachWeaponPart(part)
            toSpawn:attachWeaponPart(part)
        end
        part = item:getSling()
        if part then
            item:detachWeaponPart(part)
            toSpawn:attachWeaponPart(part)
        end
        part = item:getStock()
        if part then
            item:detachWeaponPart(part)
            toSpawn:attachWeaponPart(part)
        end
        part = item:getCanon()
        if part then
            item:detachWeaponPart(part)
            toSpawn:attachWeaponPart(part)
        end
        part = item:getRecoilpad()
        if part then
            item:detachWeaponPart(part)
            toSpawn:attachWeaponPart(part)
        end
        
        local cond = item.getCondition and item:getCondition()
        if cond then toSpawn:setCondition(cond) end
        
        local haveBeenRepaired = item.getHaveBeenRepaired and item:getHaveBeenRepaired()
        if haveBeenRepaired then toSpawn:setHaveBeenRepaired(haveBeenRepaired) end
        
        local isBroken = item.isBroken and item:isBroken()
        if isBroken then toSpawn:setBroken(isBroken) end
        
        local spawnMd = toSpawn:getModData()
        spawnMd.GunVersionKey = tostring(curKey)
        
        if GunTooltip and curKey then
            local newTip = GunTooltip..' '..curKey
            toSpawn:setTooltip(newTip)
        end
        
        inv:Remove(item)
        ISInventoryPage.dirtyUI()
    end
end ]]