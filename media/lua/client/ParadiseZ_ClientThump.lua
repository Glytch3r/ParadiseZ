ParadiseZ = ParadiseZ or {}

local Commands = {}
Commands.ParadiseZ = {}

function ParadiseZ.preventThumpDamageHandler(char, wpn, obj)
    local sq = obj:getSquare()
    if  ParadiseZ.isSafePlorSq(char, sq) then 
        local spr = obj:getSprite()

        local args = {
            objIndex = obj:getObjectIndex(),
            x = sq:getX(),
            y = sq:getY(),
            z = sq:getZ(),
            spr = spr,
        }

        obj:setHealth(obj:getMaxHealth())
        print(obj:getHealth())
        if char == getPlayer() and isClient() then
            sendClientCommand("ParadiseZ", "preventThumpDamage", args)
        end
    end
end


Events.OnWeaponHitThumpable.Remove(ParadiseZ.preventThumpDamageHandler)
Events.OnWeaponHitThumpable.Add(ParadiseZ.preventThumpDamageHandler)

Commands.ParadiseZ.syncThumpHealth = function(args)
    local sq = getCell():getOrCreateGridSquare(args.x, args.y, args.z)
    if not sq then return end
    for i=0, sq:getObjects():size()-1 do 
        local obj = sq:getObjects():get(i);
        if obj.getSprite then
            local spr = obj:getSprite()
            if spr then
                if tostring(spr) == tostring(args.spr)  then
                    obj:setHealth(obj:getMaxHealth())
                    print(obj:getHealth())
                end
            end
        end
    end 
end

Events.OnServerCommand.Add(function(module, command, args)
    if Commands[module] and Commands[module][command] then
        Commands[module][command](args)
    end
end)
