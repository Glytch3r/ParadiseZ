--client/TheRange_Context.lua

TheRange = TheRange or {}
ParadiseZ = ParadiseZ or {}
-----------------------            --------------------------------

function TheRange.isVendo(sprName)
    if not sprName then return end
    local tab = {
        ["ParadiseTiles_12"] = true,
        ["ParadiseTiles_13"] = true,
        ["ParadiseTiles_14"] = true,
        ["ParadiseTiles_15"] = true,
    }
    return tab[sprName]
end

function TheRange.context(plNum, context, worldobjects, test)
	local pl = getSpecificPlayer(plNum)
	local obj = nil

    local sq = luautils.stringStarts(getCore():getVersion(), "42") and ISWorldObjectContextMenu.fetchVars.clickedSquare or clickedSquare
    if not sq then return end
    local sprName = nil

	for i=0, sq:getObjects():size()-1 do
		local check = sq:getObjects():get(i)
		if instanceof(check, "IsoObject") then
			local sprCheck = ParadiseZ.getSprName(check)
			if sprCheck and TheRange.isVendo(sprCheck) then
				obj = check
				sprName = sprCheck
			end
		end
	end
    if not obj or not sprName then return end

    local mainMenu = "The Range"
    local Main = context:addOptionOnTop(mainMenu)
    Main.iconTexture = getTexture("media/ui/TheRangeMachine.png")
    local opt = ISContextMenu:getNew(context)
    context:addSubMenu(Main, opt)
    
    if string.lower(pl:getAccessLevel()) == "admin" or TheRange.isStaff(pl) then
        local amt = TheRange.getEarnings(obj) or 0
        opt:addOption("Earnings: "..tostring(amt), worldobjects, nil)

        opt:addOption("Withdraw", worldobjects, function()
            if luautils.walkAdj(pl, sq) then
                TheRange.withdrawPrompt(pl, obj)
            end
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
    end

    if TheRange.isMember(pl) then 
        local card = TheRange.getMembershipCard(pl)
        if card then 
            local pts = TheRange.getPoints(card) or 0
            opt:addOption("Points: "..tostring(pts), worldobjects, nil)
            
            opt:addOption("Points Exchange", worldobjects, function()
                if luautils.walkAdj(pl, sq) then
                    TheRange.pointsExchangePrompt(pl)
                end
                getSoundManager():playUISound("UIActivateMainMenuItem")
                context:hideAndChildren()
            end)
        end
    end
end
-----------------------            ---------------------------