--server/ParadiseZ_ServerData.lua
ParadiseZ = ParadiseZ or {}

if isClient() then return end

function ParadiseZ.loadZoneData()
    local modData = ModData.getOrCreate("ParadiseZ_ZoneData")
    
    local isEmpty = true
    for _ in pairs(modData) do
        isEmpty = false
        break
    end
    
    if isEmpty then
        for k, v in pairs(ParadiseZ.ZoneDataBackup) do
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

function ParadiseZ.serverSync(key, data)
    if key ~= 'ParadiseZ_ZoneData' then return end    
    ParadiseZ.ZoneData = data
end

Events.OnReceiveGlobalModData.Add(ParadiseZ.serverSync)