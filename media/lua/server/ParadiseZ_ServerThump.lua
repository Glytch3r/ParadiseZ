ParadiseZ = ParadiseZ or {}
if isClient() then return end

local Commands = {}
Commands.ParadiseZ = {}

Commands.ParadiseZ.preventThumpDamage = function(player, args)
    local sq = getCell():getGridSquare(args.x, args.y, args.z)
    if not sq then return end

    local objs = sq:getObjects()
    local obj = objs:get(args.objIndex)

    --if not (obj and instanceof(obj, "IsoThumpable")) then return end

    obj:setHealth(obj:getMaxHealth())
    sendServerCommand("ParadiseZ", "syncThumpHealth", args)
end

Events.OnClientCommand.Add(function(module, command, player, args)
    if Commands[module] and Commands[module][command] then
        Commands[module][command](player, args)
    end
end)
