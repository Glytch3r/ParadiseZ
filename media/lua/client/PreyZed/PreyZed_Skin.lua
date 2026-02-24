PreyZed = PreyZed or {}
ParadiseZ = ParadiseZ or {}

function PreyZed.isPrey(zed)
    local fit = zed:getOutfitName()
    if fit then
        return fit == 'PreyZed'
    end
    return false
end

function PreyZed.skinHandler(zed)
    if not zed then return end
    if zed.isReanimatedPlayer and zed:isReanimatedPlayer() then return end
    local sq = zed:getSquare()
    if not sq then return end
    local md = zed:getModData()
    if not md then return end
    --if md.isPrey == true then return end

    local inHuntZone = ParadiseZ.isHuntZoneSq(sq)
    if not inHuntZone then return end

    if not PreyZed.isPrey(zed) then
        zed:dressInPersistentOutfit("PreyZed")
        zed:setVariable("isPrey", true)
    end
    
    local vis = zed:getHumanVisual()
    local iVis = zed:getItemVisuals()
    local bVis = vis and vis:getBodyVisuals()
    local attachedItems = zed:getAttachedItems()
    if not vis or not iVis or not bVis or not attachedItems then return end

    zed:clearAttachedItems()
    vis:randomDirt()
    vis:removeBlood()
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
                if item:getHole(part) ~= 0 then
                    item:removeHole(j)
                end
                item:setBlood(part, 0)
                item:setDirt(part, 0)
            end
            if item:getInventoryItem() then
                item:setInventoryItem(nil)
            end
        end
    end
    for j = bVis:size() - 1, 0, -1 do
        local item = bVis:get(j)
        if item then
            local iType = item:getItemType()
            if iType and (
                luautils.stringStarts(iType, "Base.Hat_") or
                luautils.stringStarts(iType, "Base.ZedDmg_") or
                luautils.stringStarts(iType, "Base.Wound_") or
                luautils.stringStarts(iType, "Base.Bandage_") or
                luautils.stringStarts(iType, "Base.MakeUp_")
            ) then
                vis:removeBodyVisualFromItemType(iType)
            end
        end
    end

    local curSkin = nil
    if vis.getSkinTexture then
        curSkin = vis:getSkinTexture()
    elseif zed.getSkinTexture then
        curSkin = zed:getSkinTexture()
    end

    if curSkin then
        local skin
        if zed:isFemale() then
            skin = (PreyZed.SkinList_F and PreyZed.SkinList_F[curSkin]) or "FemaleBody01"
        else
            skin = (PreyZed.SkinList_M and PreyZed.SkinList_M[curSkin]) or "MaleBody01"
        end
        vis:setSkinTextureName(tostring(skin))
    end

    zed:resetModel()
    --md.isPrey = true
end

Events.OnZombieUpdate.Remove(PreyZed.skinHandler)
Events.OnZombieUpdate.Add(PreyZed.skinHandler)

PreyZed.SkinList_F = {
    ["F_ZedBody01_level1"] = "FemaleBody01",
    ["F_ZedBody01_level2"] = "FemaleBody02",
    ["F_ZedBody01_level3"] = "FemaleBody03",
    ["F_ZedBody01"] = "FemaleBody04",
    ["F_ZedBody02_level1"] = "FemaleBody05",
    ["F_ZedBody02_level2"] = "FemaleBody01",
    ["F_ZedBody02_level3"] = "FemaleBody02",
    ["F_ZedBody02"] = "FemaleBody03",
    ["F_ZedBody03_level1"] = "FemaleBody04",
    ["F_ZedBody03_level2"] = "FemaleBody05",
    ["F_ZedBody03_level3"] = "FemaleBody01",
    ["F_ZedBody03"] = "FemaleBody02",
    ["F_ZedBody04_level1"] = "FemaleBody03",
    ["F_ZedBody04_level2"] = "FemaleBody04",
    ["F_ZedBody04_level3"] = "FemaleBody05",
    ["F_ZedBody04"] = "FemaleBody01",
}

PreyZed.SkinList_M = {
    ["M_ZedBody01_level1"] = "MaleBody01",
    ["M_ZedBody01_level2"] = "MaleBody01a",
    ["M_ZedBody01_level3"] = "MaleBody02",
    ["M_ZedBody01"] = "MaleBody02a",
    ["M_ZedBody02_level1"] = "MaleBody03",
    ["M_ZedBody02_level2"] = "MaleBody03a",
    ["M_ZedBody02_level3"] = "MaleBody04",
    ["M_ZedBody02"] = "MaleBody04a",
    ["M_ZedBody03_level1"] = "MaleBody05",
    ["M_ZedBody03_level2"] = "MaleBody05a",
    ["M_ZedBody03_level3"] = "MaleBody01",
    ["M_ZedBody03"] = "MaleBody01a",
    ["M_ZedBody04_level1"] = "MaleBody02",
    ["M_ZedBody04_level2"] = "MaleBody02a",
    ["M_ZedBody04_level3"] = "MaleBody03",
    ["M_ZedBody04"] = "MaleBody03a",
}

function PreyZed.zedDead(corpse)
    if corpse and instanceof(corpse, "IsoDeadBody") then
        if PreyZed.isPrey(corpse) then
            local cont = corpse:getContainer()
            if cont then

            end
        end
    end
end
Events.OnContainerUpdate.Add(PreyZed.zedDead)