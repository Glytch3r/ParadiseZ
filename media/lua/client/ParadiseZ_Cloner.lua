ParadiseZ = ParadiseZ or {}

function ParadiseZ.cloneStuff(item, dest)
    local pl = getPlayer();
    local inv = pl:getInventory();
    local toSpawn = nil
    dest = dest or inv
    if instanceof(item, "InventoryItem") then
        toSpawn = dest:AddItem(item:getFullType());
        toSpawn:setName(item:getName());

        if instanceof(item, "HandWeapon") and item:isRanged() then

            toSpawn:setCurrentAmmoCount(item:getCurrentAmmoCount());
            toSpawn:setRoundChambered(item:isRoundChambered())
            local clip = item:isContainsClip()
            if toSpawn:isContainsClip() ~= clip then
                toSpawn:setContainsClip(clip)
            end

        elseif instanceof(item, "InventoryItem") and (instanceof(item, "InventoryContainer") or item:getCategory() == "Container") then
            local items = item:getInventory():getItems()
            local cont = toSpawn:getInventory()
            for i=0, items:size()-1 do
                ParadiseZ.cloneStuff(items:get(i):getFullType(), cont)
            end
        elseif item:getClothingItem() then
            toSpawn:setBloodLevel(item:getBloodLevel())
            toSpawn:setDirtyness(item:getDirtyness())
        end
        toSpawn:setHaveBeenRepaired(item:getHaveBeenRepaired())
        toSpawn:setBroken(item:isBroken())
        if toSpawn and item:hasModData() then
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
end
function ParadiseZ.cloneMultipleStuff(item, int)
	if int == nil then int = 1 end
	for i = 1, int  do
		ParadiseZ.cloneStuff(item)
	end
end

function ParadiseZ.context(player, context, items)    
    if string.lower(getPlayer():getAccessLevel()) == "admin"  then
        local duplicateOption = context:addOption("Cloner: ")
        local subMenu= ISContextMenu:getNew(context)
        context:addSubMenu(duplicateOption, subMenu)

        for i, item in ipairs(items) do
            if type(item) == "table" then
                subMenu:addOption(item.items[1]:getDisplayName(), item.items[1], ParadiseZ.cloneStuff);
				subMenu:addOption(tostring(item.items[1]:getDisplayName())..' x5', item.items[1], function() ParadiseZ.cloneMultipleStuff(item.items[1], 5) end);
				subMenu:addOption(tostring(item.items[1]:getDisplayName())..' x10', item.items[1], function() ParadiseZ.cloneMultipleStuff(item.items[1], 10) end);
            elseif instanceof(item, "InventoryItem") then
                subMenu:addOption(item:getDisplayName(), item, ParadiseZ.cloneStuff);
				subMenu:addOption(tostring(item:getDisplayName())..' x5', item, function() ParadiseZ.cloneMultipleStuff(item, 5) end);
				subMenu:addOption(tostring(item:getDisplayName())..' x10', item, function() ParadiseZ.cloneMultipleStuff(item, 10) end);
            end

        end
    end
end
Events.OnFillInventoryObjectContextMenu.Add(ParadiseZ.context);