ParadiseZ = ParadiseZ or {}

local Commands = {}
Commands.ParadiseZ = {}

function ParadiseZ.preventThumpDamageHandler(char, wpn, obj)
    local sq = obj:getSquare()
    if not ParadiseZ.isSafePlorSq(char, sq) then return end

    local args = {
        objIndex = obj:getObjectIndex(),
        x = sq:getX(),
        y = sq:getY(),
        z = sq:getZ()
    }

    if isClient() then
        sendClientCommand("ParadiseZ", "preventThumpDamage", args)
    else
        obj:setHealth(obj:getMaxHealth())
        --sendServerCommand("ParadiseZ", "syncHealth", args)
    end
end


Events.OnWeaponHitThumpable.Remove(ParadiseZ.preventThumpDamageHandler)
Events.OnWeaponHitThumpable.Add(ParadiseZ.preventThumpDamageHandler)

Commands.ParadiseZ.syncThumpHealth = function(args)
    local sq = getCell():getGridSquare(args.x, args.y, args.z)
    if not sq then return end
    local objs = sq:getObjects()
    local obj = objs:get(args.objIndex)
    obj:setHealth(obj:getMaxHealth())
    if getCore():getDebug() then
        print(obj:getHealth())
        getPlayer():addLineChatElement(tostring(obj:getHealth()))        
    end
end

Events.OnServerCommand.Add(function(module, command, args)
    if Commands[module] and Commands[module][command] then
        Commands[module][command](args)
    end
end)
