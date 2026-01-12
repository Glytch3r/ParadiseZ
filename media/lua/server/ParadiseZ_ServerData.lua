
--server/ParadiseZ_ServerData.lua
if isClient() then return end

ParadiseZ = ParadiseZ or {}

function ParadiseZ.OnClientCommand(module, command, player, args)
    if module ~= "ParadiseZ" then return end

    if command == "Sync" and args.data then
        local md = ModData.getOrCreate("ParadiseZ_ZoneData")

        for k in pairs(md) do
            md[k] = nil
        end

        for k, v in pairs(args.data) do
            md[k] = v
        end

        ParadiseZ.ZoneData = md
        ModData.transmit("ParadiseZ_ZoneData")
        sendServerCommand("ParadiseZ", "Sync", { data = md })

    elseif command == "Gift" and args.user then
        ParadiseZ_Gift[args.user] = true
        ModData.transmit("ParadiseZ_Gift")
        sendServerCommand("ParadiseZ", "Gift", { user = args.user })
    end
end
Events.OnClientCommand.Add(ParadiseZ.OnClientCommand)

function ParadiseZ.DataInit()
	ParadiseZ.ZoneData = ModData.getOrCreate("ParadiseZ_ZoneData")
	ParadiseZ_Gift = ModData.getOrCreate("ParadiseZ_Gift")

end

Events.OnInitGlobalModData.Add(ParadiseZ.DataInit)


