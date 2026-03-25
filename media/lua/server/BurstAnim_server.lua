BurstAnim = BurstAnim or {}
ParadiseZ = ParadiseZ or {}

local Commands = {}
Commands.BurstAnim = {}

Commands.BurstAnim.triggerPlStagger = function(args)
    sendClientCommand("BurstAnim", "triggerPlStagger", args)
end

Commands.BurstAnim.triggerZKnockDown = function(args)
    sendClientCommand("BurstAnim", "triggerZKnockDown", args)
end

Commands.BurstAnim.triggerBurst = function(args)
    sendClientCommand("BurstAnim", "triggerBurst", args)
end

Events.OnServerCommand.Add(function(module, command, args, player)
    if Commands[module] and Commands[module][command] then
        Commands[module][command](args, player)
    end
end)