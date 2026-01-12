
ParadiseZ = ParadiseZ or {}

local Commands = {};
Commands.ParadiseZ = {};
--[[ 
print(ParadiseZ.isScareCrow(getPlayer()))
print(getPlayer():getVariableBoolean("isScareCrow"))
print(getPlayer():getModData()['isScareCrow'] )
 ]]

-----------------------            ---------------------------


function ParadiseZ.doRoll(percent)
	if percent <= 0 then return false end
	if percent >= 100 then return true end
	return percent >= ZombRand(1, 101)
end
-----------------------            ---------------------------
--[[ Commands.ParadiseZ.knockDownZed = function(args)
    local source = getPlayer();
    local player = getPlayerByOnlineID(args.id)
    local zedID = args.zedID
    if type(zedID) == "string" then zedID = tonumber(zedID) end
    local zed = ParadiseZ.findzedID(zedID)
	if source ~= player then
		if zed ~= nil then
			zed:setKnockedDown(true)
		end
	end
end
 ]]

function ParadiseZ.doKnockDownPl(targ, pushedDir)
   -- targ:setBumpType("stagger");
--[[     targ:setVariable("BumpDone", true);
    targ:setVariable("BumpFall", true);
    targ:setVariable("BumpFallType", tostring(pushedDir));
    targ:reportEvent("wasBumped") ]]
--[[     if getCore():getDebug() then 
        print('knockdown')
    end ]]
    targ:setBumpType(pushedDir)
    targ:setVariable("BumpFall", true)

end

Commands.ParadiseZ.knockDownPl = function(args)
	local targ = getPlayerByOnlineID(args.targId)
    ParadiseZ.doKnockDownPl(targ, args.pushedDir)
end

Commands.ParadiseZ.gunParams = function(args)
    ParadiseZ.applyGunParams(getCore():getDebug())   
    local pl = getPlayer() 
    if not pl then return end
end

-----------------------            ---------------------------
function ParadiseZ.doThunder() 
    getSoundManager():playUISound("Thunder")
    local pl = getPlayer() 
    if not pl then return end
    ParadiseZ.doFlash(pl)
end

Commands.ParadiseZ.thunder = function(args)
    ParadiseZ.doThunder() 
end

-----------------------            ---------------------------

--[[ 
Commands.ParadiseZ.SyncBlockedZones = function(args)
    local list = args.strList or SandboxVars.ParadiseZ.BlockedList
    ParadiseZ.parseZone(list)
    ParadiseZ.echo("Block Zones Synced")
end
 ]]

function ParadiseZ.ScareCrow()
    if not isIngameState() then return end    
    
    local pl = getPlayer() 
    if not pl then return end   
   
    local isWearing =  ParadiseZ.isScareCrow(pl)
    local isScareCrow = pl:getVariableBoolean("isScareCrow")
    if isWearing and not isScareCrow then
        pl:setVariable("isScareCrow", "true")
        if isClient() then
            sendClientCommand("ParadiseZ", "isScareCrow", {isScareCrow = true})
        end
    elseif not isWearing and isScareCrow then
        pl:setVariable("isScareCrow", "false")
        if isClient() then
            sendClientCommand("ParadiseZ", "isScareCrow", {isScareCrow = false})
        end
    end
end


Events.OnScoreboardUpdate.Add(ParadiseZ.ScareCrow)
Events.OnClothingUpdated.Add(ParadiseZ.ScareCrow)

Commands.ParadiseZ.isScareCrow = function(args)
    local source = getPlayer();
    local player = getPlayerByOnlineID(args.id)
    if source ~= player then
        if args.isScareCrow then
            if player:getVariableBoolean("isScareCrow") == false then
                player:setVariable("isScareCrow", "true");
            end
        else		
            if player:getVariableBoolean("isScareCrow")  then
                player:setVariable("isScareCrow", "false");
            end
        end
    end
end
-----------------------            ---------------------------
Events.OnServerCommand.Add(function(module, command, args)
	if Commands[module] and Commands[module][command] then
		Commands[module][command](args)
	end
end)
