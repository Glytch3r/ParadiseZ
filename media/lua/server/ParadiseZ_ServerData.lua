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
    end
    
    ParadiseZ.ZoneData = modData
end

Events.OnInitGlobalModData.Add(ParadiseZ.loadZoneData)

function ParadiseZ.onClientCommand(module, command, player, args)
    if module ~= "ParadiseZ" then return end
    
    if command == "saveZoneData" then
        local modData = ModData.getOrCreate("ParadiseZ_ZoneData")
        
        for k in pairs(modData) do
            modData[k] = nil
        end
        
        for k, v in pairs(args.zoneData) do
            modData[k] = v
        end
        
        ParadiseZ.ZoneData = modData
        
        sendServerCommand("ParadiseZ", "syncZoneData", {zoneData = ParadiseZ.ZoneData})
    elseif command == "removeZone" and args.key then
        ParadiseZ.ZoneData[args.key] = nil
    	ModData.transmit('ParadiseZ_ZoneData')   
    end
end

Events.OnClientCommand.Add(ParadiseZ.onClientCommand)

function ParadiseZ.serverSync(key, data)
    if key ~= 'ParadiseZ_ZoneData' then return end
    ParadiseZ.ZoneData = ModData.add(key, data)
	ModData.transmit('ParadiseZ_ZoneData')
    --sendServerCommand("ParadiseZ", "syncZoneData", {zoneData = ParadiseZ.ZoneData})
end
Events.OnReceiveGlobalModData.Add(ParadiseZ.serverSync)
