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
function ParadiseZ.runSpawnCycle(x, y, z, clearX, clearY, clearZ, clearRadius, fixedSpawn, startFit, fits, mult)
    local sq = getCell():getOrCreateGridSquare(x, y, z)

    local t = mult
    local toSpawn = fixedSpawn
    local count = 0

    getSoundManager():PlayWorldSound('ZombieSurprisedPlayer', sq, 0, 5, 5, false)
    ParadiseZ.spawnZedEvent(x, y, z, startFit, toSpawn)

    for i = 1, #fits do
        ParadiseZ.pause(t - 120, function()
            ParadiseZ.delZeds(clearX, clearY, clearZ, clearRadius)
            count = ParadiseZ.countDead(clearX, clearY, clearZ, clearRadius)
            ParadiseZ.pause(2, function()
                ParadiseZ.delBodies(clearX, clearY, clearZ, clearRadius)
            end)
        end)

        local sub = fixedSpawn - count
        toSpawn = fixedSpawn + sub
        local fit = fits[i]

        ParadiseZ.pause(t, function()
            getSoundManager():PlayWorldSound('ZombieSurprisedPlayer', sq, 0, 5, 5, false)
            ParadiseZ.spawnZedEvent(x, y, z, fit, toSpawn)
        end)

        t = t + mult
        count = 0
    end
end

function ParadiseZ.triggerGauntlet()
    ParadiseZ.runSpawnCycle(
        8311, 6002, 0,
        8299, 6021, 0, 30,
        200,
        "Doctor",
        {
            "Farmer",
            "Cyclist",
            "Bedroom",
            "Bathrobe",
            "Camper",
        },
        480
    )
end
--[[ 
-----------------------            ---------------------------
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

ParadiseZ.isUtilityTiles = {
    ["industry_01_Simon_MD_119"] = true,
    ["industry_01_Simon_MD_84"] = true,
    ["industry_02_Simon_MD_53"] = true,
}

ParadiseZ.UtilityCoords = {
    ['Valves'] = {
        {sprName = "industry_01_Simon_MD_119", x = 12496, y = 4646, z = 0 },
        {sprName = "industry_01_Simon_MD_119", x = 12496, y = 4636, z = 0 },
        {sprName = "industry_01_Simon_MD_119", x = 12496, y = 4626, z = 0 },
        {sprName = "industry_01_Simon_MD_119", x = 12496, y = 4616, z = 0 },
        {sprName = "industry_01_Simon_MD_84", x = 12499, y = 4610, z = 2 },
    },

    ['Pumps'] = {
        {sprName = "industry_02_53", x = 12495, y = 4659, z = 4 },
        {sprName = "industry_02_53", x = 12497, y = 4659, z = 4 },
        {sprName = "industry_02_53", x = 12497, y = 4655, z = 4 },
        {sprName = "industry_02_53", x = 12495, y = 4655, z = 4 },
    },
}

function ParadiseZ.isCanRepairPumps()
    local inv = getPlayer():getInventory() 
    return inv:getItemCount("Base.ScrapMetal") >= 25
end

function ParadiseZ.deleteItems(toDel)
    local pl = getPlayer() 
    local plNum = pl:getPlayerNum() 
    for i, item in ipairs(toDel) do
        ISRemoveItemTool.removeItem(item, plNum)
    end  
end

function ParadiseZ.isActive(utilObj)
    
end

if ParadiseZ.isCanRepairPumps() then
    
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
				if ParadiseZ.isValveTiles[sprCheck] then
					obj = check
					sprName = sprCheck
                    break
				end
			end
		end
	end
    
	if not obj then return end
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

	local iconPath = "media/ui/chop_tree.png"
	--context:setOptionChecked(optTip, isCheck)
	ParadiseZ.addTip(pl, context, opt, optTip, desc, iconPath)
    
	if shouldHide then
		context:removeOptionByName(mainMenu)
	end
end
Events.OnFillWorldObjectContextMenu.Remove(ParadiseZ.context)
Events.OnFillWorldObjectContextMenu.Add(ParadiseZ.context)
 ]]