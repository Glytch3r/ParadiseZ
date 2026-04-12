BurstAnim = BurstAnim or {}
ParadiseZ = ParadiseZ or {}

local Commands = {}
Commands.BurstAnim = {}

Commands.BurstAnim.triggerPlStagger = function(args)
    sendServerCommand("BurstAnim", "triggerPlStagger", args)
end

Commands.BurstAnim.triggerZKnockDown = function(args)
    sendServerCommand("BurstAnim", "triggerZKnockDown", args)
end

Commands.BurstAnim.triggerBurst = function(args)
    local dir = args.dir or nil
    sendServerCommand("BurstAnim", "triggerBurst", {x = args.x, y = args.y, z = args.z, dir = dir})
end


Events.OnClientCommand.Add(function(module, command, player, args)
	if Commands[module] and Commands[module][command] then
	    Commands[module][command](player, args)
	end
end)

