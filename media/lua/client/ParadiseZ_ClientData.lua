--client/ParadiseZ_ClientData.lua

ParadiseZ = ParadiseZ or {}

function ParadiseZ.removeZone(key, isTransmit)
    ParadiseZ.ZoneData[key] = nil
    if isTransmit then
        sendClientCommand("ParadiseZ", "removeZone", {key=key})        
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
    
    if command == "syncZoneData" then
        ParadiseZ.ZoneData = args.zoneData        
   
    elseif command == "removeZone" and args.key then
        ParadiseZ.removeZone(args.key, false)
    end


end
Events.OnServerCommand.Add(ParadiseZ.onServerCommand)

function ParadiseZ.saveZoneData()
	ModData.transmit('ParadiseZ_ZoneData')
end


 
function ParadiseZ.clientSync(key, data)
    if key ~= 'ParadiseZ_ZoneData' then return end
    ParadiseZ.ZoneData = ModData.add(key, data)
     if ParadiseZ.ZoneEditorWindow and ParadiseZ.ZoneEditorWindow.instance then
        ParadiseZ.ZoneEditorWindow.instance:refreshList()
    end
end
Events.OnReceiveGlobalModData.Add(ParadiseZ.clientSync)
