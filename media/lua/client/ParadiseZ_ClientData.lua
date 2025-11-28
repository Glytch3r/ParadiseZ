--client/ParadiseZ_ClientData.lua
ParadiseZ = ParadiseZ or {}

function ParadiseZ.saveZoneData(newData)
    local key = "ParadiseZ_ZoneData"
    ParadiseZ.ZoneData = ModData.getOrCreate(key)
    
    for k, v in pairs(newData) do 
        store[k] = v 
    end
    
    for k, _ in pairs(store) do
        if newData[k] == nil then 
            ParadiseZ.ZoneData[k] = nil 
        end
    end
    
    ModData.transmit("ParadiseZ_ZoneData")
end

function ParadiseZ.loadZoneData()
    ModData.request("ParadiseZ_ZoneData")
end
Events.OnInitGlobalModData.Add(ParadiseZ.loadZoneData)

function ParadiseZ.onReceiveData(key, data)
    if key ~= "ParadiseZ_ZoneData" then return end
    ModData.add(key, data)
    print('ParadiseZ_ZoneData synced')
    if ParadiseZ.ZoneEditorWindow and ParadiseZ.ZoneEditorWindow.instance then
        ParadiseZ.ZoneEditorWindow.instance:refreshList()
    end
    
    ParadiseZ.updated = true
end
Events.OnReceiveGlobalModData.Add(ParadiseZ.onReceiveData)

