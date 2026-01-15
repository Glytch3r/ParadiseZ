ParadiseZ = ParadiseZ or {}
function ParadiseZ.cloneStuff(item, dest)

    if not item then return end

    local pl = getPlayer()
    if not pl then return end

    local inv = pl:getInventory()
    dest = dest or inv

    local toSpawn

    local genericProps = {
        { "getCondition", "setCondition" },
        { "getHaveBeenRepaired", "setHaveBeenRepaired" },
        { "isBroken", "setBroken" },
        { "getTooltip", "setTooltip" },
        { "getKeyId", "setKeyId" },
        { "getWetness", "setWetness" },
        { "getUsedDelta", "setUsedDelta" },

    }

    local foodProps = {
        { "getAge", "setAge" },
        { "getOffAge", "setOffAge" },
        { "getOffAgeMax", "setOffAgeMax" },
        { "isCooked", "setCooked" },
        { "isBurnt", "setBurnt" },
        { "getCalories", "setCalories" },
        { "getCarbohydrates", "setCarbohydrates" },
        { "getLipids", "setLipids" },
        { "getProteins", "setProteins" },
        { "getHungerChange", "setHungerChange" },
        { "getBaseHunger", "setBaseHunger" },
        { "getThirstChange", "setThirstChange" },
        { "getUnhappyChange", "setUnhappyChange" },
        { "getBoredomChange", "setBoredomChange" },
        { "getFoodSickness", "setFoodSickness" },
        { "getHeat", "setHeat" },
    }

    local clothingProps = {
        { "getBloodLevel", "setBloodLevel" },
        { "getDirtyness", "setDirtyness" },
    }

    if instanceof(item, "InventoryItem") then
        toSpawn = dest:AddItem(item:getFullType())
        if not toSpawn then return end

        for _, p in ipairs(genericProps) do
            local g, s = p[1], p[2]
            if item[g] and toSpawn[s] then
                local v = item[g](item)
                if v ~= nil then
                    toSpawn[s](toSpawn, v)
                end
            end
        end

        if instanceof(item, "HandWeapon") and item.isRanged and item:isRanged() then
            if item.getCurrentAmmoCount then
                toSpawn:setCurrentAmmoCount(item:getCurrentAmmoCount())
            end
            if item.isRoundChambered then
                toSpawn:setRoundChambered(item:isRoundChambered())
            end
            if item.isContainsClip then
                local clip = item:isContainsClip()
                if toSpawn:isContainsClip() ~= clip then
                    toSpawn:setContainsClip(clip)
                end
            end

            local attachmentList = { "Scope", "Clip", "Sling", "Stock", "Canon", "Recoilpad" }
            for _, p in ipairs(attachmentList) do
                local fn = item["get"..p]
                if fn then
                    local part = fn(item)
                    if part then
                        item:detachWeaponPart(part)
                        toSpawn:attachWeaponPart(part)
                    end
                end
            end
        elseif item.getCurrentAmmoCount and toSpawn.setCurrentAmmoCount then
            toSpawn:setCurrentAmmoCount(item:getCurrentAmmoCount())
        end

        if item.getFoodType then
            for _, p in ipairs(foodProps) do
                local g, s = p[1], p[2]
                if item[g] and toSpawn[s] then
                    local v = item[g](item)
                    if v ~= nil then
                        toSpawn[s](toSpawn, v)
                    end
                end
            end
        end

        if item.getClothingItem and item:getClothingItem() then
            for _, p in ipairs(clothingProps) do
                local g, s = p[1], p[2]
                if item[g] and toSpawn[s] then
                    local v = item[g](item)
                    if v ~= nil then
                        toSpawn[s](toSpawn, v)
                    end
                end
            end

            if item.getVisual and toSpawn.getVisual then
                local vis = item:getVisual()
                local newVis = toSpawn:getVisual()
                if vis and newVis then
                    if vis.getTextureChoice and newVis.setTextureChoice then
                        local texture = vis:getTextureChoice()
                        if texture then
                            newVis:setTextureChoice(texture)
                        end
                    end
                    if vis.getTint and newVis.setTint then
                        local tint = vis:getTint()
                        if tint then
                            newVis:setTint(tint)
                        end
                    end
                end
            end

            pl:resetModelNextFrame()
            triggerEvent("OnClothingUpdated", pl)
        end

        if item.hasModData and item:hasModData() then
            for k, v in pairs(item:getModData()) do
                toSpawn:getModData()[k] = v
            end
        end

        if instanceof(item, "InventoryContainer") or (item.getCategory and item:getCategory() == "Container") then
            local srcItems = item:getInventory():getItems()
            local dstInv = toSpawn:getInventory()
            for i = 0, srcItems:size() - 1 do
                ParadiseZ.cloneStuff(srcItems:get(i), dstInv)
            end
        end
    else
        local scr = type(item) == "string" and getScriptManager():FindItem(item)
        if scr then
            toSpawn = dest:AddItem(item)
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

function ParadiseZ.getIconStr(item)
	local texture = item:getTexture()
	local textureName = texture:getName()
	if textureName:find("[/\\]") then
		textureName = textureName:match("([^/\\]+)%.png$")
	else
		textureName = textureName:match("([^/\\]+)")
	end
	return textureName
end

function ParadiseZ.cloner(player, context, items)    
    if string.lower(getPlayer():getAccessLevel()) ~= "admin" then return end

    local duplicateOption = context:addOption("Paradise Item Cloner: ")
    duplicateOption.iconTexture = getTexture("media/ui/Paradise/cloner.png")
    local subMenu = ISContextMenu:getNew(context)
    context:addSubMenu(duplicateOption, subMenu)

    for _, item in ipairs(items) do
        local realItem = nil
        if type(item) == "table" and item.items and item.items[1] then
            realItem = item.items[1]
        elseif instanceof(item, "InventoryItem") then
            realItem = item
        end

        if realItem then
            local iconStr = ParadiseZ.getIconStr(realItem)
            print(iconStr)
            local texPath = "media/textures/Item_" .. tostring(realItem:getType()) 

            local c1 = subMenu:addOption(realItem:getDisplayName(), realItem, ParadiseZ.cloneStuff)
            c1.iconTexture = getTexture(texPath)

            local c2 = subMenu:addOption(realItem:getDisplayName() .. " x5", realItem, function() ParadiseZ.cloneMultipleStuff(realItem, 5) end)
            c2.iconTexture = getTexture(texPath)

            local c3 = subMenu:addOption(realItem:getDisplayName() .. " x10", realItem, function() ParadiseZ.cloneMultipleStuff(realItem, 10) end)
            c3.iconTexture = getTexture(texPath)
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(ParadiseZ.cloner)
