


if isClient() then return; end

local Commands = {};
Commands.ParadiseZ = {};

Commands.ParadiseZ.isScareCrow = function(player, args)
    local playerId = player:getOnlineID();
    sendServerCommand('ParadiseZ', 'isScareCrow', {id = playerId, isScareCrow = args.isScareCrow})
end

Events.OnClientCommand.Add(function(module, command, player, args)
	if Commands[module] and Commands[module][command] then
	    Commands[module][command](player, args)
	end
end)

