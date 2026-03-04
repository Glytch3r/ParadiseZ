-- client/ParadiseZ_isSafeZone.lua
ParadiseZ = ParadiseZ or {}


--[[ function ParadiseZ.isSafeZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isSafe == true 
end
 ]]


function ParadiseZ.isSafeZone(plOrSq)
    local sq
    if instanceof(plOrSq, "IsoGridSquare") then
        sq = plOrSq
    else
        local targ = ParadiseZ.getPl(plOrSq)
        if not targ then return false end
        sq = targ:getSquare()
        if not sq then return false end
    end

    local zoneName = ParadiseZ.getZoneName(sq)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end

    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end

    return zone.isSafe == true
end


function ParadiseZ.isSafePlorSq(pl, sq)
    pl = pl or getPlayer()
    sq = sq or pl:getSquare() 
    local safePl = ParadiseZ.isSafeZone(pl)
    local safeSq = ParadiseZ.isSafeZone(sq)
    return safePl or safeSq
end
-----------------------            ---------------------------
--[[ 
function ParadiseZ.ProtectThump(char, wpn, obj)
    if not char then return end
    if instanceof(char, "IsoZombie")  then return end
    if not obj then return print('obj') end
    if not obj:isThumpable() then return print('isThumpable') end
    local sq = obj:getSquare()
    if not sq then return end
    if not ParadiseZ.isSafePlorSq(char, sq) then return end
    if getCore():getDebug() then 
        print(obj:getHealth())
    end
    obj:setHealth(obj:getMaxHealth())
    if isClient() then obj:transmitCompleteItemToServer() end
end
Events.OnWeaponHitThumpable.Remove(ParadiseZ.ProtectThump)
Events.OnWeaponHitThumpable.Add(ParadiseZ.ProtectThump)
 ]]
-----------------------            ---------------------------


function ParadiseZ.getBlocks()
    local opt = SandboxVars.ParadiseZ and SandboxVars.ParadiseZ.ContextRemoveList
    if not opt or opt == "" then return {} end

    local t = {}
    for key in string.gmatch(opt, "[^;]+") do
        t[#t + 1] = key
    end
    return t
end


function ParadiseZ.removeContextOptions(plNum, context, worldobjects)
    local pl = getSpecificPlayer(plNum)
    if not pl then return end
    if clickedPlayer then
        local access = clickedPlayer:getAccessLevel()
        if access and (string.lower(access) == "admin" or clickedPlayer:isInvisible()) then
            context:removeOptionByName(getText("ContextMenu_Trade"))
        end
    end
    local sq = clickedSquare
    if not sq then return end
    if SandboxVars.ParadiseZ.isSafeAllowActions and ParadiseZ.isAdm() then return end
    if ParadiseZ.isSafePlorSq(pl, sq) then  
        local pickupText = getText("IGUI_Pickup")
        local pickupOpt = context:getOptionFromName(pickupText)
        if pickupOpt then
            context:removeOptionByName(pickupText)
            local opt = context:addOption(pickupText)
            if opt then
                opt.notAvailable = true
                local tooltip = ISToolTip:new()
                tooltip:initialise()
                tooltip.description = "Protected Zone"
                opt.toolTip = tooltip
            end
        end
        ParadiseZ.blocks = ParadiseZ.getBlocks()
        for _, key in ipairs(ParadiseZ.blocks) do
            local text = getText(key)
            local existing = context:getOptionFromName(text)
            if existing then
                context:removeOptionByName(text)
                local opt = context:addOption(text)
                if opt then
                    opt.notAvailable = true
                    local tooltip = ISToolTip:new()
                    tooltip:initialise()
                    tooltip.description = "Protected Zone"
                    opt.toolTip = tooltip
                end
            end
        end  
    end 
end
Events.OnFillWorldObjectContextMenu.Remove(ParadiseZ.removeContextOptions)
Events.OnFillWorldObjectContextMenu.Add(ParadiseZ.removeContextOptions)



Events.OnCreatePlayer.Add(function()
    ParadiseZ.SafeHousecanBeSafehouse = SafeHouse.canBeSafehouse
    function SafeHouse.canBeSafehouse(pl, square)
        local building = square and square:getBuilding()
        if building then
            local def = building:getDef()
            if def then
                local minX = def:getX()
                local minY = def:getY()
                local maxX = minX + def:getW() - 1
                local maxY = minY + def:getH() - 1
                local z = square:getZ()
                local cell = getCell()

                for x = minX, maxX do
                    for y = minY, maxY do
                        local sq = cell:getGridSquare(x, y, z)
                        if sq and ParadiseZ.isSafePlorSq(pl, sq) then
                            return false
                        end
                    end
                end
            end
        end

        return ParadiseZ.SafeHousecanBeSafehouse(pl, square)
    end
end)








-----------------------            ---------------------------
--[[ function ParadiseZ.restoreHandler(obj)    
    if not obj then return end
    local sq = obj:getSquare()
    if not sq then return end
    local x, y = sq:getX(), sq:getY()
    if not (x and y ) then return end
    if ParadiseZ.isSafeZoneFromSquare(sq) then 
        local sprName = ParadiseZ.getSprName(obj) 
        if sprName then
            local props = ISMoveableSpriteProps.new(IsoObject.new(sq, sprName):getSprite())
            props.rawWeight = 10
            props:placeMoveableInternal(sq, nil, sprName)
        end
    end
end
Events.OnTileRemoved.Remove(ParadiseZ.restoreHandler)
Events.OnTileRemoved.Add(ParadiseZ.restoreHandler) ]]
-----------------------            ---------------------------

--[[ 
function ParadiseZ.safeHouseCheck()
    local pl = getPlayer() 
    
end
Events.OnCreatePlayer.Remove(ParadiseZ.safeHouseCheck)
Events.OnCreatePlayer.Add(ParadiseZ.safeHouseCheck)

getSafeHouse()

SafeHouse.getSafeHouse(sq);

function ParadiseZ.addTip(pl, context, opt, optTip, desc, iconPath)
	local tip = ISWorldObjectContextMenu.addToolTip()
	tip.description = tostring(desc) or ""
	tip:setName("ParadiseZ: ")
	if iconPath then
		optTip.iconTexture = getTexture(iconPath)
		tip:setTexture(iconPath)
	end
	optTip.toolTip = tip
end

function ParadiseZ.context(plNum, context, worldobjects, test)
	local pl = getSpecificPlayer(plNum)
	--local targ = clickedPlayer
	local obj = nil

    local sq = luautils.stringStarts(getCore():getVersion(), "42") and ISWorldObjectContextMenu.fetchVars.clickedSquare or clickedSquare
    if not sq then return end

	for i=0, sq:getObjects():size()-1 do
		local check = sq:getObjects():get(i)
		if instanceof(check, "IsoObject") then
			local sprCheck = ParadiseZ.getSprName(obj)
			if sprCheck then
				if sprCheck == "" or luautils.stringStarts(sprCheck, "") then
					obj = check
					sprName = sprCheck
					--break
				end
			end
		end
	end
    
	--if not obj then return end
	local mainMenu = "ParadiseZ: "
	local Main = context:addOptionOnTop(mainMenu)
	Main.iconTexture = getTexture("media/ui/chop_tree.png")
	local opt = ISContextMenu:getNew(context)
	context:addSubMenu(Main, opt)
	local shouldHide = false


	local optTip = opt:addOption(tostring(sprName), worldobjects, function()

		if luautils.walkAdj(pl, sq) then
			--ISTimedActionQueue.add(ISWalkToTimedAction:new(pl, sq));
		end

		getSoundManager():playUISound("UIActivateMainMenuItem")
		context:hideAndChildren()
	end)
	if not obj then
		optTip.notAvailable = true
	end
	local iconPath = "media/ui/chop_tree.png"
	--context:setOptionChecked(optTip, isCheck)
	ParadiseZ.addTip(pl, context, opt, optTip, desc, iconPath)

	if shouldHide then
		context:removeOptionByName(mainMenu)
	end
end
Events.OnFillWorldObjectContextMenu.Remove(ParadiseZ.context)
Events.OnFillWorldObjectContextMenu.Add(ParadiseZ.context)

--<RGB:0,1,0>

cliptab(getActivatedMods())
	print(getActivatedMods():contains("SpearStance"))

    if getActivatedMods():contains("") then
        toggleModActive(getModInfoByID(""), false)
    end

    if SandboxVars.SitAnywhere.DisableLifestyleSitMenu then
        local list = {
            getText("ContextMenu_Sit_Action"),
            getText("ContextMenu_Sit_Action_Couch"),
            getText("ContextMenu_Sit_Action_Stool"),
            getText("ContextMenu_Sit_Info"),
        }


        for _, str in ipairs(list) do
            local opt2 = context:getOptionFromName(str)
            if opt2 then
                context:removeOptionByName(str)
                local opt3 =  context:addOptionOnTop(str, worldobjects, nil)
                opt3.notAvailable = true
                opt3.iconTexture = getTexture('media/ui/moodles/ComfortRed.png')
                local tooltip = ISToolTip:new();
                tooltip:initialise();
                tooltip.description = "Disabled by SitAnywhere Mod Sandbox Options"
                opt3.toolTip = tooltip
            end
        end

    end ]]