
--server/ParadiseZ_ServerData.lua
if isClient() then return end

ParadiseZ = ParadiseZ or {}

function ParadiseZ.OnClientCommand(module, command, player, args)
    if module ~= "ParadiseZ" then return end

    if command == "Sync" and args.data then
        for k, _ in pairs(ParadiseZ.ZoneData) do ParadiseZ.ZoneData[k] = nil end
        for k, v in pairs(args.data) do ParadiseZ.ZoneData[k] = v end
        sendServerCommand("ParadiseZ", "Sync", { data = ParadiseZ.ZoneData  })
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

