
--server/ParadiseZ_ServerData.lua
if isClient() then return end
ParadiseZ = ParadiseZ or {}

function ParadiseZ.initServer()
    ParadiseZ.ZoneData = ModData.getOrCreate("ParadiseZ_ZoneData")
	ParadiseZ_Gift = ModData.getOrCreate("ParadiseZ_Gift")
end
Events.OnInitGlobalModData.Add(ParadiseZ.initServer)

function ParadiseZ.doServerSave(data)
    if data then
        for dataKey, value in pairs(data) do
            ParadiseZ.ZoneData[dataKey] = value
        end
        for dataKey, _ in pairs(ParadiseZ.ZoneData) do
            if data[dataKey] == nil then
                ParadiseZ.ZoneData[dataKey] = nil
            end
        end
        return ParadiseZ.ZoneData
    end
end

function ParadiseZ.sSync(key, data)
    if key == "ParadiseZ_ZoneData" then
        ParadiseZ.doServerSave(data)
        ModData.transmit("ParadiseZ_ZoneData")
    end
end
Events.OnReceiveGlobalModData.Add(ParadiseZ.sSync)

function ParadiseZ.sync(module, command, player, args)
    if module ~= "ParadiseZ" then return end

    if command == "Sync" and args.data then
        ParadiseZ.doServerSave(args.data)
        ModData.transmit("ParadiseZ_ZoneData")
    elseif command == "Gift" and args.user then
        sendServerCommand("ParadiseZ", "Gift", { user = args.user })
    end
end
Events.OnClientCommand.Add(ParadiseZ.sync)


--[[ 

--server/ParadiseZ_Server.lua
if isClient() then return end

ParadiseZ = ParadiseZ or {}

function ParadiseZ.OnClientCommand(module, command, player, args)
    if module ~= "ParadiseZ" then return end

    if command == "Sync" and args.data then
        --for k, _ in pairs(ParadiseZ.ZoneData) do ParadiseZ.ZoneData[k] = nil end
        --for k, v in pairs(args.data) do ParadiseZ.ZoneData[k] = v end
        --sendServerCommand("ParadiseZ", "Sync", { data = args.data  })
        ModData.add("ParadiseZ_ZoneData", args.data)
        ModData.transmit("ParadiseZ_ZoneData")

    elseif command == "Gift" and args.user then
        sendServerCommand("ParadiseZ", "Gift", { user = args.user  })
    end
end
Events.OnClientCommand.Add(ParadiseZ.OnClientCommand)


function ParadiseZ.DataInit()
	ParadiseZ.ZoneData = ModData.getOrCreate("ParadiseZ_ZoneData")
	ParadiseZ_Gift = ModData.getOrCreate("ParadiseZ_Gift")
end
Events.OnInitGlobalModData.Add(ParadiseZ.DataInit)


 ]]


--[[ 

function ParadiseZ.OnReceiveGlobalModData(key, data)
    if key == 'ParadiseZ_ZoneData' then
        ModData.add("ParadiseZ_ZoneData", data)
    end
end
Events.OnReceiveGlobalModData.Add(ParadiseZ.OnReceiveGlobalModData)
 ]]



