


ParadiseZ = ParadiseZ or {}
if isClient() then return end

function ParadiseZ.clientCmd(module, command, player, args)
    if module ~= "ParadiseZ" then return end
    if command == "saveZoneData" then
        local gameModData = ModData.getOrCreate("ParadiseZ_ZoneData")
        for k in pairs(gameModData) do gameModData[k] = nil end
        for k, v in pairs(args.zoneData) do
            gameModData[k] = v
        end
        ParadiseZ.ZoneData = gameModData
        sendServerCommand("ParadiseZ", "syncZoneData", {zoneData = ParadiseZ.ZoneData})
    elseif command == "requestZoneData" then
        ParadiseZ.loadZoneData()
        sendServerCommand(player, "ParadiseZ", "syncZoneData", {zoneData = ParadiseZ.ZoneData})
    end
end
Events.OnClientCommand.Add(ParadiseZ.clientCmd)



--[[ --server/ParadiseZ_ServerData.lua
ParadiseZ = ParadiseZ or {}
function ParadiseZ.ServerData(module, command, player, args)
	if isClient() then return end
	if module == "ParadiseZ" then
		if command == "Fetch" then
			sendServerCommand("ParadiseZ", "Fetch", { id = player:getOnlineID(), ParadiseZ = args.ParadiseZ})
		elseif command == "Save" then
			sendServerCommand("ParadiseZ", "Save", { id = player:getOnlineID(), ParadiseZ = args.ParadiseZ})
		end
		ModData.add("ParadiseZ", args.ParadiseZ)
	end

end
Events.OnClientCommand.Add(ParadiseZ.ServerData) ]]