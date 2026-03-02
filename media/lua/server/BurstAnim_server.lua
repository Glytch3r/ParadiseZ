
--server
if isClient() then return; end

local Commands = {};
Commands.BurstAnim = {};


Commands.BurstAnim.relayBurst = function(player, args)
	sendServerCommand("BurstAnim", "relayBurst", args)
end

Events.OnClientCommand.Add(function(module, command, player, args)
	if Commands[module] and Commands[module][command] then
	    Commands[module][command](player, args)
	end
end)

