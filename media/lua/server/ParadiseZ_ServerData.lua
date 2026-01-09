

--server/ParadiseZ_ServerData.lua

ParadiseZ = ParadiseZ or {}
if isClient() then return end


function ParadiseZ.OnClientCommand(module, command, player, args)
    if module ~= "ParadiseZ" then return end
    
    if command == "Sync" and args.data then
  --[[       for k, _ in pairs(ParadiseZ.ZoneData) do ParadiseZ.ZoneData[k] = nil end
        for k, v in pairs(args.data) do ParadiseZ.ZoneData[k] = v end ]]
        ModData.add("ParadiseZ_ZoneData", args.data)
        ModData.transmit("ParadiseZ_ZoneData")
        sendServerCommand("ParadiseZ", "Sync", { data = args.data  })
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

--[[ 
function ParadiseZ.OnClientCommand(module, command, player, args)
    if module ~= "ParadiseZ" then return end

    if command == "Sync" and args.data then
        ParadiseZ.ZoneData = {}
        for k, v in pairs(args.data) do
            ParadiseZ.ZoneData[k] = v
        end

        ModData.transmit("ParadiseZ_ZoneData")

        local win = ParadiseZ.ZoneEditorWindow.instance
        if win and win:isVisible() then
            win:refreshList()
        end

    elseif command == "Gift" and args.user then
        ParadiseZ_Gift[args.user] = true
        ModData.transmit("ParadiseZ_Gift")
    end
end
Events.OnClientCommand.Add(ParadiseZ.OnClientCommand)
 ]]

