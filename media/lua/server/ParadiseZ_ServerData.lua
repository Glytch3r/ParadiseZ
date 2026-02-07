
--server/ParadiseZ_ServerData.lua
if isClient() then return end

ParadiseZ = ParadiseZ or {}

function ParadiseZ.OnClientCommand(module, command, player, args)
    if module ~= "ParadiseZ" then return end

    if command == "Sync" and args.data then
        local md = ModData.getOrCreate("ParadiseZ_ZoneData")

        for k in pairs(ParadiseZ.ZoneData) do
            ParadiseZ.ZoneData[k] = nil
        end

        for k, v in pairs(args.data) do
            ParadiseZ.ZoneData[k] = v
        end




        ParadiseZ.ZoneData["Monmouth County Power Station"] = {
            name = "Monmouth County Power Station",
            x1 = 11809,
            y1 = 7876,
            x2 = 11870,
            y2 = 7943,
            isKos = SandboxVars.ParadiseZ.RadZoneisKos or false,
            isPvE = SandboxVars.ParadiseZ.RadZoneisPvE or false,
            isSafe = SandboxVars.ParadiseZ.RadZoneisSafe or false,
            isBlocked = SandboxVars.ParadiseZ.RadZoneisBlocked or false,
            isRad = true,
        }


        ModData.transmit("ParadiseZ_ZoneData")
        sendServerCommand("ParadiseZ", "Sync", { data = args.data })

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


