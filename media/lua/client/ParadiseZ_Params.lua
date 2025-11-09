

ParadiseZ = ParadiseZ or {}

ParadiseZ.isShotgun = {
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

function ParadiseZ.applyGunParams()
    local allItems = getScriptManager():getAllItems()
    local sm = ScriptManager.instance
    for i = 1, allItems:size() do
        local item = allItems:get(i-1)
        local fType = item:getModuleName() .. '.' .. item:getName()
        if fType then
            local wpn = sm:getItem(fType)
            if wpn then
                local check = getScriptManager():FindItem(tostring(fType))
                if check then
                    if wpn.isRanged and wpn:isRanged()  then
                        if wpn.isTwoHandWeapon and wpn:isTwoHandWeapon() then
                            if ParadiseZ.isShotgun[tostring(fType)] then                            
                                print('Shotgun:   '..tostring(fType).."   modified")
                                wpn:DoParam("AimingPerkMinAngleModifier = 1.02")
                                wpn:DoParam("MinAngle = 0.99")
                            else 
                                print('Rifle:   '..tostring(fType).."   modified")
                                wpn:DoParam("AimingPerkMinAngleModifier = 1.01")
                                wpn:DoParam("MinAngle = 0.999")
                            end
                        else 
                            print('Pistol:   '..tostring(fType).."   modified")
                            wpn:DoParam("AimingPerkMinAngleModifier = 1.01")
                            wpn:DoParam("MinAngle = 0.999")
                        end
                        wpn:DoParam("AngleFalloff = TRUE")
                        wpn:DoParam("ParadiseGun = TRUE")
                    end
                end
            end
        end
    end
end

Events.OnInitGlobalModData.Add(function()
    ParadiseZ.applyGunParams()    
end)

--[[ 
local ticks = 0
function ParadiseZ.oldGunDespawner(pl)
    ticks = ticks + 1
    if ticks % 60 == 0 then
        pl = pl or getPlayer()
        local inv = pl:getInventory()
        local itemsChanged = false
        if inv then
            local items = inv:getItems()
            for i = items:size(), 1, -1 do
                local item = items:get(i-1)
                if item and item:isRanged() then
                    if not item:getModData()['ParadiseGun']  then
                        local fType = item:getFullType()
                        if fType then
                            if getCore():getDebug() then
                                pl:addLineChatElement(tostring(fType).." changed!")
                            end
                            local newItem = InventoryItemFactory.CreateItem(fType)
                            inv:AddItem(newItem)
                            inv:Remove(item)
                            itemsChanged = true
                        end
                    end
                end
            end
        end
        if itemsChanged then
            ISInventoryPage.dirtyUI()
        end
    end
end

Events.OnPlayerUpdate.Add(ParadiseZ.oldGunDespawner)
 ]]
