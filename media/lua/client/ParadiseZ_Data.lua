
ParadiseZ = ParadiseZ or {}

function ParadiseZ.saveZoneData()
    if isClient() then
        sendClientCommand("ParadiseZ", "saveZoneData", {zoneData = ParadiseZ.ZoneData})
    else
        local gameModData = ModData.getOrCreate("ParadiseZ_ZoneData")
        for k in pairs(gameModData) do gameModData[k] = nil end
        for k, v in pairs(ParadiseZ.ZoneData) do
            gameModData[k] = v
        end
    end
end

function ParadiseZ.loadZoneData()
    local gameModData = ModData.getOrCreate("ParadiseZ_ZoneData")
    if next(gameModData) == nil then
        for k, v in pairs(ParadiseZ.ZoneDataBackup) do
            local zone = {}
            for key, val in pairs(v) do
                zone[key] = val
            end
            gameModData[k] = zone
        end
    end
    ParadiseZ.ZoneData = gameModData
end

function ParadiseZ.onReceiveGlobalModData(key, modData)
    if key == "ParadiseZ_ZoneData" then
        ParadiseZ.ZoneData = modData
        if ParadiseZ.ZoneEditorWindow.instance then
            ParadiseZ.ZoneEditorWindow.instance:refreshList()
        end
    end
end
Events.OnReceiveGlobalModData.Add(ParadiseZ.onReceiveGlobalModData)

function ParadiseZ.onServerCommand(module, command, args)
    if module ~= "ParadiseZ" then return end
    if command == "syncZoneData" then
        ParadiseZ.ZoneData = args.zoneData
        if ParadiseZ.ZoneEditorWindow.instance then
            ParadiseZ.ZoneEditorWindow.instance:refreshList()
        end
    end
end
Events.OnServerCommand.Add(ParadiseZ.onServerCommand)

function ParadiseZ.onClientCommand(module, command, player, args)
    if module ~= "ParadiseZ" then return end
    if command == "saveZoneData" then
        local gameModData = ModData.getOrCreate("ParadiseZ_ZoneData")
        for k in pairs(gameModData) do gameModData[k] = nil end
        for k, v in pairs(args.zoneData) do
            gameModData[k] = v
        end
        ParadiseZ.ZoneData = gameModData
        sendServerCommand("ParadiseZ", "syncZoneData", {zoneData = ParadiseZ.ZoneData})
    elseif command == "requestZoneData" then
        ParadiseZ.loadZoneData()
        sendServerCommand(player, "ParadiseZ", "syncZoneData", {zoneData = ParadiseZ.ZoneData})
    end
end
Events.OnClientCommand.Add(ParadiseZ.onClientCommand)

function ParadiseZ.onGameStart()
    ParadiseZ.loadZoneData()
    if isClient() then
        ModData.request("ParadiseZ_ZoneData")
        sendClientCommand("ParadiseZ", "requestZoneData", {})
    end
end
Events.OnGameStart.Add(ParadiseZ.onGameStart)
