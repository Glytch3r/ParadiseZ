ParadiseZ = ParadiseZ or {}
function ParadiseZ.cloneStuff(item, dest)
    local pl = getPlayer()
    local inv = pl:getInventory()
    dest = dest or inv
    if not item then return end

    local toSpawn
    if instanceof(item, "InventoryItem") then
        toSpawn = dest:AddItem(item:getFullType())
        if not toSpawn then return end

        toSpawn:setName(item:getName())

        if instanceof(item, "HandWeapon") and item:isRanged() then
            toSpawn:setCurrentAmmoCount(item:getCurrentAmmoCount())
            toSpawn:setRoundChambered(item:isRoundChambered())
            local clip = item:isContainsClip()
            if toSpawn:isContainsClip() ~= clip then
                toSpawn:setContainsClip(clip)
            end

            local parts = { "Scope", "Clip", "Sling", "Stock", "Canon", "Recoilpad" }
            for _, partName in ipairs(parts) do
                local part = item["get"..partName](item)
                if part then
                    item:detachWeaponPart(part)
                    toSpawn:attachWeaponPart(part)
                end
            end
        elseif instanceof(item, "InventoryContainer") or item:getCategory() == "Container" then
            local items = item:getInventory():getItems()
            local cont = toSpawn:getInventory()
            for i=0, items:size()-1 do
                ParadiseZ.cloneStuff(items:get(i), cont)
            end
        elseif item:getClothingItem() then
            toSpawn:setBloodLevel(item:getBloodLevel())
            toSpawn:setDirtyness(item:getDirtyness())
        end

        if item.getCondition then
            toSpawn:setCondition(item:getCondition())
        end
        if item.getHaveBeenRepaired then
            toSpawn:setHaveBeenRepaired(item:getHaveBeenRepaired())
        end
        if item.isBroken then
            toSpawn:setBroken(item:isBroken())
        end
        if item.getTooltip then
            local tooltip = item:getTooltip()
            if tooltip then
                toSpawn:setTooltip(tooltip)
            end
        end

        if item:hasModData() then
            for k, v in pairs(item:getModData()) do
                toSpawn:getModData()[k] = v
            end
        end
    else
        local scr = getScriptManager():FindItem(item)
        if type(item) == "string" and scr then
            toSpawn = item
        end
        if toSpawn then
            dest:AddItem(toSpawn)
        end
    end
    return toSpawn
end

function ParadiseZ.cloneMultipleStuff(item, int)
	if int == nil then int = 1 end
	for i = 1, int  do
		ParadiseZ.cloneStuff(item)
	end
end

function ParadiseZ.cloner(player, context, items)    
    if string.lower(getPlayer():getAccessLevel()) == "admin"  then
        local duplicateOption = context:addOption("Paradise Item Cloner: ")
        local subMenu= ISContextMenu:getNew(context)
        context:addSubMenu(duplicateOption, subMenu)

        for i, item in ipairs(items) do
            if type(item) == "table" then
                local c1 = subMenu:addOption(item.items[1]:getDisplayName(), item.items[1], ParadiseZ.cloneStuff);
                c1.iconTexture = getTexture("media/ui/Paradise/cloner.png")
				local c2 = subMenu:addOption(tostring(item.items[1]:getDisplayName())..' x5', item.items[1], function() ParadiseZ.cloneMultipleStuff(item.items[1], 5) end);
                c2.iconTexture = getTexture("media/ui/Paradise/cloner.png")
				local c3 = subMenu:addOption(tostring(item.items[1]:getDisplayName())..' x10', item.items[1], function() ParadiseZ.cloneMultipleStuff(item.items[1], 10) end);
                c3.iconTexture = getTexture("media/ui/Paradise/cloner.png")
            elseif instanceof(item, "InventoryItem") then
                local c1 = subMenu:addOption(item:getDisplayName(), item, ParadiseZ.cloneStuff);
                c1.iconTexture = getTexture("media/ui/Paradise/cloner.png")    
                local c2 = subMenu:addOption(tostring(item:getDisplayName())..' x5', item, function() ParadiseZ.cloneMultipleStuff(item, 5) end);
                c2.iconTexture = getTexture("media/ui/Paradise/cloner.png")    
                local c3 = subMenu:addOption(tostring(item:getDisplayName())..' x10', item, function() ParadiseZ.cloneMultipleStuff(item, 10) end);
                c3.iconTexture = getTexture("media/ui/Paradise/cloner.png")    
            end
        end
    end
end
Events.OnFillInventoryObjectContextMenu.Add(ParadiseZ.cloner);