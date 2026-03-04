--server
if isClient() then return; end

local Commands = {};
Commands.BurstAnim = {};


Commands.BurstAnim.triggerPlStagger = function(player, args)
	sendServerCommand("BurstAnim", "triggerPlStagger", args)
end

Commands.BurstAnim.triggerZKnockDown = function(player, args)
	sendServerCommand("BurstAnim", "triggerZKnockDown", args)
end

Commands.BurstAnim.triggerBurst = function(player, args)
	sendServerCommand("BurstAnim", "triggerBurst", args)
end

Events.OnClientCommand.Add(function(module, command, player, args)
	if Commands[module] and Commands[module][command] then
	    Commands[module][command](player, args)
	end
end)