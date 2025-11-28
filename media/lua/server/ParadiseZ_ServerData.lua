--server/ParadiseZ_ServerData.lua

ParadiseZ = ParadiseZ or {}
if isClient() then return end

function ParadiseZ.loadZoneData()
    ParadiseZ.ZoneData = ModData.getOrCreate("ParadiseZ_ZoneData")
    
    local isEmpty = true
    for _ in pairs(ParadiseZ.ZoneData) do
        isEmpty = false
        break
    end
    
    if isEmpty then
        for k, v in pairs(ParadiseZ.ZoneDataBackup or {}) do
            ParadiseZ.ZoneData[k] = v
        end
    end
    
end
Events.OnInitGlobalModData.Add(ParadiseZ.loadZoneData)

function ParadiseZ.onReceiveData(key, data)
    if key ~= "ParadiseZ_ZoneData" then return end
    if not data or data == false then return end
    
    local store = ModData.getOrCreate(key)
    
    for k, v in pairs(data) do
        store[k] = v
    end
    
    for k, _ in pairs(store) do
        if data[k] == nil then
            store[k] = nil
        end
    end
    
    ParadiseZ.ZoneData = store
    ModData.transmit(key)
end
Events.OnReceiveGlobalModData.Add(ParadiseZ.onReceiveData)
-----------------------            ---------------------------

function ParadiseZ.loadZoneData()
    local modData = ModData.getOrCreate("ParadiseZ_ZoneData")
    
    local isEmpty = true
    for _ in pairs(modData) do
        isEmpty = false
        break
    end
    
    if isEmpty then
        for k, v in pairs(ParadiseZ.ZoneDataBackup or {}) do
            local zone = {}
            for key, val in pairs(v) do
                zone[key] = val
            end
            modData[k] = zone
        end
        ModData.transmit('ParadiseZ_ZoneData')
    end
    
    ParadiseZ.ZoneData = modData
end
Events.OnInitGlobalModData.Add(ParadiseZ.loadZoneData)

function ParadiseZ.onClientCommand(module, command, player, args)
    if module ~= "ParadiseZ" then return end
    if command == "fetch" then
        sendServerCommand(player, 'ParadiseZ', 'fetch', {zoneData = ParadiseZ.ZoneData})
    end
end
Events.OnClientCommand.Add(ParadiseZ.onClientCommand)

function ParadiseZ.save(key, data)
    if key ~= "ParadiseZ_ZoneData" or not data then return end

    for k, v in pairs(data) do
        ParadiseZ.ZoneData[k] = v
    end
    for k, _ in pairs(ParadiseZ.ZoneData) do
        if data[k] == nil then ParadiseZ.ZoneData[k] = nil end
    end
    return ParadiseZ.ZoneData
end

function ParadiseZ.serverSync(key, data)
    if key ~= "ParadiseZ_ZoneData" then return end
    ParadiseZ.save(key, data)
    ModData.transmit("ParadiseZ_ZoneData")
end
Events.OnReceiveGlobalModData.Add(ParadiseZ.serverSync)

