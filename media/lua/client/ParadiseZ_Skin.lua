
ParadiseZ = ParadiseZ or {}


function glytch()
    local pl = getPlayer() 
	pl:getDescriptor():setForename("")
	pl:getDescriptor():setSurname("")
    pl:setDisplayName("")
    ParadiseZ.clean()
    ParadiseZ.buff()
    ParadiseZ.crow(true)
    sendPlayerExtraInfo(pl)
    sendPlayerStatsChange(pl);
end


function ParadiseZ.buff()
    local pl = getPlayer()
	pl:setGodMod(true)
	ISFastTeleportMove.cheat = true
	BrushToolManager.cheat = true
	ISLootZed.cheat  = true
	pl:setUnlimitedEndurance(true)
	pl:setUnlimitedCarry(true)
    ISBuildMenu.cheat = true;
    pl:setBuildCheat(true);
	pl:setFarmingCheat(true)
	pl:setHealthCheat(true)
	pl:setMechanicsCheat(true)
	pl:setMovablesCheat(true)
	getDebugOptions():setBoolean("Cheat.Recipe.KnowAll", true)
	getDebugOptions():setBoolean("Cheat.Player.UnlimitedAmmo", not getDebugOptions():getBoolean("Cheat.Player.UnlimitedAmmo"))
	pl:setCanSeeAll(true)
	pl:setNetworkTeleportEnabled(true)
    pl:setZombiesDontAttack(true)
    pl:setInvincible(true);
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
end


function ParadiseZ.doll()
    local pl = getPlayer() 
    ParadiseZ.clear()
    if pl then
        local vis = pl:getHumanVisual()
        local iVis = pl:getItemVisuals()
        local bVis = vis:getBodyVisuals()
        local skin = 'M_Mannequin_Black'
        if pl:isFemale() then skin = 'M_Mannequin_White' end
        if vis then            
            vis:setHairModel('Bald')
            vis:setSkinTextureName(tostring(skin))
            pl:resetModel()
        end
    end
end
-----------------------            ---------------------------

function ParadiseZ.clean()
	local soapList = {}
	local soapCount = 3
	for i = 1, soapCount do
		local soapItem = getPlayer():getInventory():AddItem("Base.Soap2")
		table.insert(soapList, soapItem)
	end
	local sink = IsoThumpable.new(getCell(), getPlayer():getSquare(), nil, "fixtures_sinks_01_0", false, {})
	sink:setWaterAmount(100)
	local action = ISWashYourself:new(getPlayer(), sink, soapList)
	action:perform()
end


function ParadiseZ.clean2()
    local pl = getPlayer() 
    if pl then
        local vis = pl:getHumanVisual()
        local iVis = pl:getItemVisuals()
        local bVis = vis:getBodyVisuals()    
        --local attachedItems = pl:getAttachedItems()
        if vis and iVis and bVis then
            pl:clearAttachedItems()
            vis:randomDirt()
            vis:removeBlood()
            for i=1, BloodBodyPartType.MAX:index() do
                local part = BloodBodyPartType.FromIndex(i-1)
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
                    local fType = item:getItemType()
                    if luautils.stringStarts(fType, "Base.Hat_") or luautils.stringStarts(fType, "Base.ZedDmg_") or luautils.stringStarts(fType, "Base.Wound_") or luautils.stringStarts(fType, "Base.Bandage_") or luautils.stringStarts(fType, "Base.MakeUp_") or luautils.stringStarts(fType, "Base.ParadiseZ")  then
                        vis:removeBodyVisualFromItemType(fType)
                    end
                end
            end
            pl:resetModel()
        end
    end
end

-----------------------            ---------------------------
function ParadiseZ.clear()
    local pl = getPlayer() 
    local inv = pl:getInventory() 
    pl:clearWornItems()
    inv:clear()
    pl:resetModel()    
    triggerEvent("OnClothingUpdated", pl)

end
-----------------------            ---------------------------
-- ParadiseZ.crow(false)
-- ParadiseZ.crow(true)

function ParadiseZ.crow(bool)
    bool = bool or true
    local pl = getPlayer() 
    local inv = pl:getInventory() 
    pl:getModData()['isScareCrow'] = false
    ParadiseZ.clear()
    if bool == true then
        local fType = 'Skin.ScareCrow'
        pl:getModData()['isScareCrow'] = true
        ParadiseZ.wearFit(pl, fType)
    else
        pl:getModData()['isScareCrow'] = false
        ParadiseZ.clear()
    end
    triggerEvent("OnClothingUpdated", pl)
    ParadiseZ.ScareCrow()
end
-- print(ParadiseZ.isScareCrow(pl))
function ParadiseZ.isScareCrow(pl)
	pl = pl or getPlayer()
	return ParadiseZ.wearing(pl, "Skin.ScareCrow")
end

function ParadiseZ.wearing(pl, fType)
	pl = pl or getPlayer()
	if not instanceof(pl, "IsoPlayer") then return false end
	--if not pl:isAccessLevel('admin') then return false end
	local wornItems = pl:getWornItems()
	if wornItems then
		for i=1, wornItems:size() do
			local item = wornItems:get(i-1):getItem()
			if item:getFullType() == fType  then
				return true
			end
		end
	end
	return false
end
function ParadiseZ.wearFit(pl, fType)
	pl = pl or getPlayer()
	local item = InventoryItemFactory.CreateItem(fType)
	local inv = pl:getInventory()
	local equip = inv:addItem(item);
	pl:setWornItem(equip:getBodyLocation(), equip);
	pl:resetModelNextFrame();
	triggerEvent("OnClothingUpdated", pl)
  
end
