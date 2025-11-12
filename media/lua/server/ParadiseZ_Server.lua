


if isClient() then return; end

local Commands = {};
Commands.ParadiseZ = {};

Commands.ParadiseZ.isScareCrow = function(player, args)
    local playerId = player:getOnlineID();
    sendServerCommand('ParadiseZ', 'isScareCrow', {id = playerId, isScareCrow = args.isScareCrow})
end
Commands.ParadiseZ.knockDownZed = function(player, args)
    local playerId = player:getOnlineID();
    sendServerCommand('ParadiseZ', 'knockDownZed', {id = playerId, zedID = args.zedID})
end

Commands.ParadiseZ.speedUp = function(player, args)
    local playerId = player:getOnlineID();
    sendServerCommand('ParadiseZ', 'speedUp', {id = playerId, zedID = args.zedID})
end



Events.OnClientCommand.Add(function(module, command, player, args)
	if Commands[module] and Commands[module][command] then
	    Commands[module][command](player, args)
	end
end)

