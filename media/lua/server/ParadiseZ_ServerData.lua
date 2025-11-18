--server/ParadiseZ_ServerData.lua
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
Events.OnClientCommand.Add(ParadiseZ.ServerData)
