--server/ParadiseZ_ServerData.lua
if isClient() then return end

ParadiseZ = ParadiseZ or {}

function ParadiseZ.OnClientCommand(module, command, player, args)
    if module ~= "ParadiseZ" then return end

    if command == "Sync" and args.data then
       ParadiseZ.ZoneData = ModData.getOrCreate("ParadiseZ_ZoneData")

        for k in pairs(ParadiseZ.ZoneData) do
            ParadiseZ.ZoneData[k] = nil
        end

        for k, v in pairs(args.data) do
            ParadiseZ.ZoneData[k] = v
        end

        ModData.transmit("ParadiseZ_ZoneData")
        sendServerCommand("ParadiseZ", "Sync", { data = ParadiseZ.ZoneData })        
    elseif command == "Gift" and args.user then
        ParadiseZ_Gift[args.user] = true
        ModData.transmit("ParadiseZ_Gift")
        sendServerCommand("ParadiseZ", "Gift", { user = args.user })
    elseif command == "Scoreboard" and args.data then
       ParadiseZ.Scoreboard = ModData.getOrCreate("ParadiseZ_Scoreboard")

        if args.user then
            ParadiseZ.Scoreboard[args.user] = args.data
        else
            for k in pairs(ParadiseZ.Scoreboard) do
                ParadiseZ.Scoreboard[k] = nil
            end

            for k, v in pairs(args.data) do
                ParadiseZ.Scoreboard[k] = v
            end
        end
        ModData.transmit("ParadiseZ_Scoreboard")
        sendServerCommand("ParadiseZ", "Scoreboard", { user = args.user or nil , data = args.data })
    end
end
Events.OnClientCommand.Add(ParadiseZ.OnClientCommand)

function ParadiseZ.DataInit()
	ParadiseZ.ZoneData = ModData.getOrCreate("ParadiseZ_ZoneData")
	ParadiseZ_Gift = ModData.getOrCreate("ParadiseZ_Gift")
	ParadiseZ.Scoreboard = ModData.getOrCreate("ParadiseZ_Scoreboard")

end

Events.OnInitGlobalModData.Add(ParadiseZ.DataInit)


--[[ 
function ParadiseZ.parseZone(strList)
    strList = strList or SandboxVars.ParadiseZ.BlockedList

    for k,v in pairs(ParadiseZ.ZoneData) do
        v.isBlocked = false
    end

    for str in string.gmatch(strList, "[^;]+") do
        str = str:match("^%s*(.-)%s*$")
        if ParadiseZ.ZoneData[str] then
            ParadiseZ.ZoneData[str].isBlocked = true
        end
    end
end



function ParadiseZ.init()
    ParadiseZ.parseZone()
end
Events.OnCreatePlayer.Remove(ParadiseZ.init)
Events.OnCreatePlayer.Add(ParadiseZ.init)
 ]]