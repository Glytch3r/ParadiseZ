local Commands = {}
Commands.Guantlet = {}

Guantlet = Guantlet or {}

function Guantlet.storeData(data)
    if not data then return end
    for id, entry in pairs(data) do
        GuantletData[tostring(id)] = entry
    end
end

Commands.Guantlet.doSpawn = function(player, args)
    local x, y, z, fit, fChance, isDown = args.x, args.y, args.z, args.fit, args.fChance, args.isDown
    local zed = addZombiesInOutfit(math.floor(x), math.floor(y), math.floor(z), 1, tostring(fit), tonumber(fChance), isDown, false, isDown, isDown, 1.0)
    if zed and isDown and not zed:isOnFloor() then
        zed:knockDown(true)
    end
end

Commands.Guantlet.sSync = function(player, args)
    local GuantletId = args.GuantletId
    if not GuantletId then return end
    local data = args.data
    if data then
        Guantlet.storeData(data)
        sendServerCommand("Guantlet", "cSync", {id = player:getOnlineID(), GuantletId = GuantletId, data = data})
    else
        GuantletData[GuantletId] = nil
        sendServerCommand("Guantlet", "cSync", {id = player:getOnlineID(), GuantletId = GuantletId})
    end
    ModData.transmit("GuantletData")
end

Events.OnClientCommand.Add(function(module, command, player, args)
    if Commands[module] and Commands[module][command] then
        Commands[module][command](player, args)
    end
end)