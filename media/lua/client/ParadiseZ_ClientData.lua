--client/ParadiseZ_ClientData.lua
ParadiseZ = ParadiseZ or {}

function ParadiseZ.removeZone(key, isTransmit)
    if ParadiseZ.ZoneData and ParadiseZ.ZoneData[key] then
        ParadiseZ.ZoneData[key] = nil
        
        if isTransmit then
            ModData.transmit('ParadiseZ_ZoneData')
        end
    end
end

function ParadiseZ.saveZoneData()
    if ParadiseZ.ZoneData then
        ModData.transmit('ParadiseZ_ZoneData')
    end
end

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
    end
    
    ParadiseZ.ZoneData = modData
end

Events.OnInitGlobalModData.Add(ParadiseZ.loadZoneData)

function ParadiseZ.onServerCommand(module, command, args)
    if module ~= "ParadiseZ" then return end
    
    if command == "fetch" and args.zoneData then        
        cliptab(args.zoneData)
        "fetch"
    end
end

Events.OnServerCommand.Add(ParadiseZ.onServerCommand)
 
function ParadiseZ.clientSync(key, data)
    if key ~= 'ParadiseZ_ZoneData' then return end
    print('ParadiseZ_ZoneData recieved')
    ParadiseZ.ZoneData = data
    if ParadiseZ.ZoneEditorWindow and ParadiseZ.ZoneEditorWindow.instance then
        ParadiseZ.updated = true
    end
end

Events.OnReceiveGlobalModData.Add(ParadiseZ.clientSync)