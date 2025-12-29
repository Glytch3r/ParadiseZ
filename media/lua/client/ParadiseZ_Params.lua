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
    local strList = SandboxVars.ParadiseZ.ShotgunList 
    local t = {}
    for item in string.gmatch(strList, "[^;]+") do
        t[item] = true
    end
    return t
end

function ParadiseZ.isFirearm(wpn)
    if instanceof(wpn, "HandWeapon") then
        return tostring(WeaponType.getWeaponType(wpn)) == "firearm"
    elseif instanceof(wpn, "IsoPlayer") then
        return tostring(WeaponType.getWeaponType(wpn)) == 'firearm'
    elseif type(wpn) == "string"  then
        local check = ScriptManager.instance:getItem(wpn)
        if check then
            return check:isRanged()
        end
    end
    return false
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
                local item = sm:getItem(fType)
                res = res.."\nModified: "..tostring(wpnClass).."  :  "..tostring(fType)
                wpn:DoParam("AimingPerkMinAngleModifier = " .. tostring(PerkModifier))
                wpn:DoParam("MinAngle = " .. tostring(MinAngle))
                wpn:DoParam("AngleFalloff = true")
                wpn:DoParam("ParadiseGun = " .. tostring(GunVersionKey))
                wpn:DoParam("Tooltip = " .. tostring(GunTooltip))
            end
        end
    end
    if shouldPrint then print(res) end
end

Events.OnCreatePlayer.Add(function()
    ParadiseZ.applyGunParams()
end)

function ParadiseZ.isFirearm(item)
	return item and item:getScriptItem() and item:getScriptItem():isRanged()
end

function ParadiseZ.oldGunDespawner()
    local GunUpdater = SandboxVars.ParadiseZ.GunUpdater
    if not GunUpdater then return end
    local pl = getPlayer()
    if not pl then return end
    
    local GunVersionKey = SandboxVars.ParadiseZ.GunVersionKey
    
    local primaryItem = pl:getPrimaryHandItem()
    local secondaryItem = pl:getSecondaryHandItem()
    
    local itemsToCheck = {}
    if primaryItem then table.insert(itemsToCheck, primaryItem) end
    if secondaryItem then table.insert(itemsToCheck, secondaryItem) end
    
    for _, item in ipairs(itemsToCheck) do
        if ParadiseZ.isFirearm(item) then
            local md = item:getModData()
            local data = md and md.GunVersionKey
            local isUpdated = data == true or data == tostring(GunVersionKey)
            if not isUpdated then
                ParadiseZ.updateGun(item)
            end
        end
    end
end

Events.OnPlayerUpdate.Add(ParadiseZ.oldGunDespawner)


function ParadiseZ.updateGun(item)
    local pl = getPlayer()
    if not pl then return end
    local inv = pl:getInventory()
    if not inv then return end
    if not item then return end
    
    local fType = item:getFullType()
    if not fType then return end
    if getCore():getDebug() then 
        pl:addLineChatElement("Firearm Updated: "..tostring(fType))      
    end
    local wasPrimary = pl:getPrimaryHandItem() == item
    local wasSecondary = pl:getSecondaryHandItem() == item
    
    local secondaryItem = pl:getSecondaryHandItem()
    if secondaryItem == item then
        secondaryItem = nil
    end
    
    local toSpawn = inv:AddItem(fType)
    if not toSpawn then return end
    
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
    local part = item:getClip()
    if part then
        item:detachWeaponPart(part)
        toSpawn:attachWeaponPart(part)
    end
    local part = item:getSling()
    if part then
        item:detachWeaponPart(part)
        toSpawn:attachWeaponPart(part)
    end
    local part = item:getStock()
    if part then
        item:detachWeaponPart(part)
        toSpawn:attachWeaponPart(part)
    end
    local part = item:getCanon()
    if part then
        item:detachWeaponPart(part)
        toSpawn:attachWeaponPart(part)
    end
    local part = item:getRecoilpad()
    if part then
        item:detachWeaponPart(part)
        toSpawn:attachWeaponPart(part)
    end
    
    local cond
    if item.getCondition then cond = item:getCondition() end
    if cond then toSpawn:setCondition(cond) end
    local haveBeenRepaired
    if item.getHaveBeenRepaired then haveBeenRepaired = item:getHaveBeenRepaired() end
    if haveBeenRepaired then toSpawn:setHaveBeenRepaired(haveBeenRepaired) end
    local isBroken
    if item.isBroken then isBroken = item:isBroken() end
    if isBroken then toSpawn:setBroken(isBroken) end
    
    local md = toSpawn:getModData()
    md.GunVersionKey = tostring(SandboxVars.ParadiseZ.GunVersionKey)
    
    pl:removeFromHands(item)
    inv:Remove(item)
    
    if wasPrimary or wasSecondary then
        luautils.equipItems(pl, toSpawn, secondaryItem)
    end


    ISInventoryPage.dirtyUI()
end
