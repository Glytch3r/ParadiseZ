-----------------------            ---------------------------
--client/ParadiseZ_ClientData.lua
ParadiseZ = ParadiseZ or {}

function ParadiseZ.isAdm()
    local pl = getPlayer()
    return ((pl and string.lower(pl:getAccessLevel()) == "admin") or (isClient() and isAdmin())) 
end

function ParadiseZ.saveZoneData(data)
    if not data then return end    
	if isClient() then 
		sendClientCommand("ParadiseZ", "Sync", {  data = data })
	end	
end
function ParadiseZ.saveScoreboard(data, user)
    if not data then return end    
	if isClient() then 
		sendClientCommand("ParadiseZ", "Scoreboard", { data = data, user = user })
	end	
end
function ParadiseZ.saveUtilityData(data)
    if not data then return end
	if isClient() then 
		sendClientCommand("ParadiseZ", "Utility", { data = data })
	end	
end
-----------------------            ---------------------------


function ParadiseZ.recordGifted(user)
    if not user then
        local pl = getPlayer() 
        user = pl:getUsername() 
    end
    if not user then return end
	if isClient() then 
		sendClientCommand("ParadiseZ", "Gift", {  user = user })
	end	
end


function ParadiseZ.isGiftRecieved(user)
    if not user then
        local pl = getPlayer() 
        user = pl:getUsername() 
    end
    if not user then return end
    return ParadiseZ_Gift[user]
end

-----------------------            ---------------------------

function ParadiseZ.ClientSync(module, command, args)
    if module ~= "ParadiseZ" then return end

    if command == "Sync" and args.data then
        for k, _ in pairs(ParadiseZ.ZoneData) do 
            ParadiseZ.ZoneData[k] = nil 
        end

        for k, v in pairs(args.data) do
            ParadiseZ.ZoneData[k] = v
        end
        
        print("ParadiseZ: Client synced.")
		if ParadiseZ.ZoneEditorWindow and ParadiseZ.ZoneEditorWindow.instance then
			ParadiseZ.ZoneEditorWindow.instance:refreshList()
		end
 
    elseif command == "Gift" and args.user then        
        ParadiseZ_Gift[args.user] = true
    elseif command == "Scoreboard" and args.data then   
        if  args.user then
            ParadiseZ.Scoreboard[args.user] = args.data
        else
            print("ParadiseZ: Scoreboard synced.")
        
            ParadiseZ.initScoreboardPlayerData()
        end
        if ParadiseZ.ScoreboardUI and ParadiseZ.ScoreboardUI.instance then
            ParadiseZ.ScoreboardUI.instance:updatePlayerList()
        end  
    end
end
Events.OnServerCommand.Add(ParadiseZ.ClientSync)

function ParadiseZ.DataInit()
    --if ModData.exists("ParadiseZ_UtilityData") then ModData.remove("ParadiseZ_UtilityData"); end
    if ModData.exists("ParadiseZ_ZoneData") then ModData.remove("ParadiseZ_ZoneData"); end
    if ModData.exists("ParadiseZ_Gift") then ModData.remove("ParadiseZ_Gift"); end
    if ModData.exists("ParadiseZ_Scoreboard") then ModData.remove("ParadiseZ_Gift"); end

    --ParadiseZ.UtilityData = ModData.getOrCreate("ParadiseZ_UtilityData");
    ParadiseZ.ZoneData = ModData.getOrCreate("ParadiseZ_ZoneData");
	ParadiseZ_Gift = ModData.getOrCreate("ParadiseZ_Gift")
	ParadiseZ.Scoreboard = ModData.getOrCreate("ParadiseZ_Scoreboard")

    --ModData.request("ParadiseZ_UtilityData");
    ModData.request("ParadiseZ_ZoneData");
    ModData.request("ParadiseZ_Gift");
    ModData.request("ParadiseZ_Scoreboard");
end

Events.OnInitGlobalModData.Add(ParadiseZ.DataInit)

function ParadiseZ.RecieveData(key, data)
    if key == "ParadiseZ_ZoneData" then
        if ModData.exists("ParadiseZ_ZoneData") then ModData.remove("ParadiseZ_ZoneData"); end
        ModData.add("ParadiseZ_ZoneData", data) 
        ParadiseZ.ZoneData = data
--[[     elseif key == "ParadiseZ_UtilityData" then
        if ModData.exists("ParadiseZ_UtilityData") then ModData.remove("ParadiseZ_UtilityData"); end
        ModData.add("ParadiseZ_UtilityData", data) 
        ParadiseZ.UtilityData = data ]]
    elseif key == "ParadiseZ_Gift" then
        if ModData.exists("ParadiseZ_Gift") then ModData.remove("ParadiseZ_Gift"); end
        ModData.add("ParadiseZ_Gift", data) 
        ParadiseZ_Gift = data
    elseif key == "ParadiseZ_Scoreboard" then
        if ModData.exists("ParadiseZ_Scoreboard") then ModData.remove("ParadiseZ_Scoreboard"); end
        ModData.add("ParadiseZ_Scoreboard", data) 
        ParadiseZ.Scoreboard = data
    end
end
Events.OnReceiveGlobalModData.Add(ParadiseZ.RecieveData)

-----------------------            ---------------------------

function ParadiseZ.Clone_ZoneData(t1, t2)
    if not t1 or not t2 then return end
    
    for key, value in pairs(t2) do
        t1[key] = value
    end
    for key, _ in pairs(t1) do
        if not t2[key] then
            t1[key] = nil
        end
    end
end
-----------------------            ---------------------------
function ParadiseZ.deathCounter(targ)
    local pl = getPlayer()
    if targ == pl then
        local user = pl:getUsername() 
        ParadiseZ.Scoreboard[user] = ParadiseZ.Scoreboard[user] or {}      
        ParadiseZ.Scoreboard[user].deathCount = ParadiseZ.Scoreboard[user].deathCount or 0
        ParadiseZ.Scoreboard[user].deathCount = ParadiseZ.Scoreboard[user].deathCount + 1
        if not ParadiseZ.Scoreboard[user].timeAlive then
            ParadiseZ.Scoreboard[user].timeAlive = pl:getTimeSurvived()
        else
            ParadiseZ.Scoreboard[user].timeAlive = ParadiseZ.Scoreboard[user].timeAlive + pl:getTimeSurvived()
        end
        ParadiseZ.saveScoreboard(ParadiseZ.Scoreboard[user], user)
    end
end
Events.OnPlayerDeath.Add(ParadiseZ.deathCounter)

function ParadiseZ.initScoreboardPlayerData()
    local pl = getPlayer()
    if pl then
        local user = pl:getUsername() 
        ParadiseZ.Scoreboard[user] = ParadiseZ.Scoreboard[user] or {}      
        ParadiseZ.Scoreboard[user].user = ParadiseZ.Scoreboard[user].user or user
        ParadiseZ.Scoreboard[user].deathCount = ParadiseZ.Scoreboard[user].deathCount or 0
        ParadiseZ.Scoreboard[user].pvpKillCount = ParadiseZ.Scoreboard[user].pvpKillCount or 0
        ParadiseZ.Scoreboard[user].timeAlive= ParadiseZ.Scoreboard[user].timeAlive or pl:getTimeSurvived()
        --ParadiseZ.Scoreboard[user].lastLogin = ParadiseZ.Scoreboard[user].lastLogin or 
        ParadiseZ.saveScoreboard(ParadiseZ.Scoreboard[user], user)
    end
end
Events.OnCreatePlayer.Add(ParadiseZ.initScoreboardPlayerData)
