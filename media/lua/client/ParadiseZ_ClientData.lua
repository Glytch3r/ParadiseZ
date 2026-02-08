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
        for k, _ in pairs(ParadiseZ.ZoneData) do ParadiseZ.ZoneData[k] = nil end

        for k, v in pairs(args.data) do
            ParadiseZ.ZoneData[k] = v
        end

        ParadiseZ.ZoneData["Monmouth County Power Station"] = {
            name = "Monmouth County Power Station",
            x1 = 11809,
            y1 = 7876,
            x2 = 11870,
            y2 = 7943,
            isKos = SandboxVars.ParadiseZ.RadZoneisKos or false,
            isPvE = SandboxVars.ParadiseZ.RadZoneisPvE or false,
            isSafe = SandboxVars.ParadiseZ.RadZoneisSafe or false,
            isBlocked = SandboxVars.ParadiseZ.RadZoneisBlocked or false,
            isRad = true,
        }


        print("ParadiseZ: Client synced.")
		if ParadiseZ.ZoneEditorWindow and ParadiseZ.ZoneEditorWindow.instance then
			ParadiseZ.ZoneEditorWindow.instance:refreshList()
		end
  --[[   elseif command == "Utility" and args.data then
        for k, _ in pairs(ParadiseZ.UtilityData) do ParadiseZ.UtilityData[k] = nil end

        for k, v in pairs(args.data) do
            ParadiseZ.UtilityData[k] = v
        end ]]
    elseif command == "Gift" and args.user then        
        ParadiseZ_Gift[args.user] = true
    end
end
Events.OnServerCommand.Add(ParadiseZ.ClientSync)

function ParadiseZ.DataInit()
    if ModData.exists("ParadiseZ_UtilityData") then ModData.remove("ParadiseZ_UtilityData"); end
    if ModData.exists("ParadiseZ_ZoneData") then ModData.remove("ParadiseZ_ZoneData"); end
    if ModData.exists("ParadiseZ_Gift") then ModData.remove("ParadiseZ_Gift"); end
    --ParadiseZ.UtilityData = ModData.getOrCreate("ParadiseZ_UtilityData");
    ParadiseZ.ZoneData = ModData.getOrCreate("ParadiseZ_ZoneData");
	ParadiseZ_Gift = ModData.getOrCreate("ParadiseZ_Gift")

    ModData.request("ParadiseZ_UtilityData");
    ModData.request("ParadiseZ_ZoneData");
    ModData.request("ParadiseZ_Gift");
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
