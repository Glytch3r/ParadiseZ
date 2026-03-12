local Commands = {};
Commands.Guantlet = {};

-- Server


-----------------------            ---------------------------

Commands.Guantlet.doSpawn = function(player, args)
    local x, y, z, count, fit, fChance, isDown = args.x,  args.y,  args.z, args.count, args.fit, args.fChance, args.isDown
    local zed = addZombiesInOutfit(math.floor(x), math.floor(y), math.floor(z), 1, tostring(fit), tonumber(fChance), isDown, false, isDown, isDown, 1.0)
    if zed then
        if isDown then
            if not zed:isOnFloor() then
                zed:knockDown(true)
            end
        end
    end
end

Commands.Guantlet.doDespawn = function(player, args)
    local zed = Guantlet.findzedID(tonumber(args.zedID))
    if zed then
        zed:removeFromWorld();
        zed:removeFromSquare();
    end
end

function Guantlet.mergeTables(dest, source)
    for key, value in pairs(source) do
        dest[key] = value
    end
    return dest
end


Commands.Guantlet.sSync = function(player, args)
    local GuantletId = args.GuantletId
    if GuantletId then
        GuantletData[GuantletId] = GuantletData[GuantletId] or {}
        local data = args.data
        if data then
            Guantlet.storeData(data)
        --[[
            for key, value in pairs(args.data) do
                GuantletData[GuantletId][key] = value
            end ]]
            sendServerCommand("Guantlet", "cSync", { id = player:getOnlineID(), GuantletId = GuantletId, data = data })
        else
            GuantletData[GuantletId] = nil
            sendServerCommand("Guantlet", "cSync", { id = player:getOnlineID(), GuantletId = GuantletId })
        end

        ModData.transmit("GuantletData")
    end
end


Events.OnClientCommand.Add(function(module, command, player, args)
	if Commands[module] and Commands[module][command] then
	    Commands[module][command](player, args)
	end
end)