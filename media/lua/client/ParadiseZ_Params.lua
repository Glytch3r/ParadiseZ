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
-----------------------            ---------------------------

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


-----------------------            ---------------------------
function ParadiseZ.isFirearm(item)
	return item and item:getScriptItem() and item:getScriptItem():isRanged()
end

function ParadiseZ.oldGunDespawner()
    local GunUpdater = SandboxVars.ParadiseZ.GunUpdater 
    if not GunUpdater then return end

    local pl = getPlayer() 
    if not pl then return end
    local inv = pl:getInventory()
    if not inv then return end
    local items = inv:getItems()
    for i = items:size(), 1, -1 do
        local item = items:get(i-1)
        if item and  ParadiseZ.isFirearm(item) then        
            local GunVersionKey = SandboxVars.ParadiseZ.GunVersionKey 
            local isUpdated = data and data == tostring(GunVersionKey) or data == true 
            if not isUpdated then
                local inv = pl:getInventory()
                if inv and fType then ParadiseZ.updateGun(item, inv) end                        
                ISInventoryPage.dirtyUI()
            end           
        end
    end
end


Events.OnPreFillInventoryObjectContextMenu.Add(ParadiseZ.oldGunDespawner)
Events.OnClothingUpdated.Add(ParadiseZ.oldGunDespawner)
Events.OnEquipPrimary.Add(ParadiseZ.oldGunDespawner)
-----------------------            ---------------------------
function ParadiseZ.updateGun(item, inv)
    local pl = getPlayer()
    if not pl then return end

    inv = inv or pl:getInventory()
    if not inv then return end

    if not item then return end
    local fType = item:getFullType()
    if not fType then return end
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

    local plNum = pl:getPlayerNum()
    if plNum then
        ISRemoveItemTool.removeItem(item, plNum)
    end
    pl:resetEquippedHandsModels();
    ISInventoryPage.dirtyUI()
end
-----------------------            ---------------------------

--[[ 
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
function ParadiseZ.parseShotgun()
    local tab = {}
    local strList = SandboxVars.ParadiseZ.ShotgunList
    if not strList then
        strList = ParadiseZ.defaultShotguns
    end
    if strList then
        if type(strList) ~= "string" or strList == "" then
            return tab
        end

        for str in string.gmatch(strList, "[^;]+") do
            tab[str] = true
        end
    end
    return tab
end




function ParadiseZ.applyGunParams()
    local allItems = getScriptManager():getAllItems()
    local sm = ScriptManager.instance
    local GunVersionKey = SandboxVars.ParadiseZ.GunVersionKey 
    local GunTooltip = SandboxVars.ParadiseZ.GunTooltip 

    for i = 1, allItems:size() do
        local item = allItems:get(i-1)
        local fType = item:getModuleName() .. '.' .. item:getName()
        if fType then
            local wpn = sm:getItem(fType)
            if wpn then
                local check = getScriptManager():FindItem(tostring(fType))
                if check then
                    if wpn.isRanged and wpn:isRanged()  then
                        local PerkModifier
                        local MinAngle
                        if wpn.isTwoHandWeapon and wpn:isTwoHandWeapon() then
                            if ParadiseZ.isShotgun[tostring(fType)] then                            
                                print('Shotgun:   '..tostring(fType).."   modified")
                                --wpn:DoParam("AimingPerkMinAngleModifier = 0.001")
                                --wpn:DoParam("MinAngle = 0.99")
                                PerkModifier = SandboxVars.ParadiseZ.PerkModifierShotgun 
                                MinAngle = SandboxVars.ParadiseZ.MinAngleShotgun 
                            else 
                                print('Rifle:   '..tostring(fType).."   modified")
                                --wpn:DoParam("AimingPerkMinAngleModifier = 0.0005")
                                --wpn:DoParam("MinAngle = 0.999")
                                PerkModifier = SandboxVars.ParadiseZ.PerkModifierRifle 
                                MinAngle = SandboxVars.ParadiseZ.MinAngleRifle 
                            end
                        else 
                            print('Pistol:   '..tostring(fType).."   modified")
                            --wpn:DoParam("AimingPerkMinAngleModifier = 0.0005")
                            --wpn:DoParam("MinAngle = 0.999")
                            PerkModifier = SandboxVars.ParadiseZ.PerkModifierPistol 
                            MinAngle = SandboxVars.ParadiseZ.MinAnglePistol 
                        end
                        wpn:DoParam("AimingPerkMinAngleModifier = "..tostring(PerkModifier))
                        wpn:DoParam("MinAngle = "..tostring(MinAngle))

                        wpn:DoParam("AngleFalloff = true")
                        wpn:DoParam("ParadiseGun = "..tostring(GunVersionKey))
                        wpn:DoParam("Tooltip = "..tostring(GunTooltip))
                        
                    end
                end
            end
        end
    end
end
 ]]
