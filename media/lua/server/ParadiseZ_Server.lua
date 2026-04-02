
--server
ParadiseZ = ParadiseZ or {}

if isClient() then return; end

local Commands = {};
Commands.ParadiseZ = {};

Commands.ParadiseZ.resetSandbox = function(player, args)    
    local playerId = player:getOnlineID();
    sendServerCommand('ParadiseZ', 'resetSandbox', {id = playerId})
end

Commands.ParadiseZ.isScareCrow = function(player, args)
    local playerId = player:getOnlineID();
    sendServerCommand('ParadiseZ', 'isScareCrow', {id = playerId, isScareCrow = args.isScareCrow})
end

Commands.ParadiseZ.knockDownZed = function(player, args)
    local playerId = player:getOnlineID();
    sendServerCommand('ParadiseZ', 'knockDownZed', {id = playerId, zedID = args.zedID})
end

Commands.ParadiseZ.knockDownPl = function(player, args)    
    sendServerCommand('ParadiseZ', 'knockDownPl', {targId = args.targId, pushedDir = args.pushedDir})
end

Commands.ParadiseZ.reParams = function(player, args)
    sendServerCommand('ParadiseZ', 'reParams', {})
end


Commands.ParadiseZ.tellAll = function(player, args)
    sendServerCommand('ParadiseZ', 'tellAll', {msg = args.msg})
end



Commands.ParadiseZ.speedUp = function(player, args)
    local playerId = player:getOnlineID();
    sendServerCommand('ParadiseZ', 'speedUp', {id = playerId, zedID = args.zedID})
end
--[[ 
Commands.ParadiseZ.SyncBlockedZones = function(player, args)
    local playerId = player:getOnlineID();
    sendServerCommand('ParadiseZ', 'SyncBlockedZones', {id = playerId, strList = args.strList })
end
 ]]

Commands.ParadiseZ.thunder = function(player, args)
    local playerId = player:getOnlineID();
    sendServerCommand('ParadiseZ', 'thunder', {id = playerId})
end

Events.OnClientCommand.Add(function(module, command, player, args)
	if Commands[module] and Commands[module][command] then
	    Commands[module][command](player, args)
	end
end)

