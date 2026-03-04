ParadiseZ = ParadiseZ or {}
function ParadiseZ.parseExileCoords()   
    local strList = SandboxVars.ParadiseZpvp.ExileCoords
    local tx, ty, tz = strList:match("^(-?%d+)[;:](-?%d+)[;:](-?%d+)")
    tx, ty, tz = tonumber(tx), tonumber(ty), tonumber(tz)    
    return tx, ty, tz
end


function ParadiseZ.exileHandler(pl)
    pl = pl or getPlayer()
    if not pl then return end
    if not pl:isAlive() then return end
    local md = pl:getModData()
    if md.LifePoints <= 0  and SandboxVars.ParadiseZpvp.teleportPvpDeath then
        ParadiseZ.doPvPExile(pl)
    end
end
Events.OnPlayerUpdate.Add(ParadiseZ.exileHandler)

function ParadiseZ.doPvPExile(pl)
    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return end
    
    local x, y, z = ParadiseZ.parseExileCoords() 
    if not x or not y or not z then return end
    
    local car = pl:getVehicle()
    if car then
        ParadiseZ.forceExitCar()
    end
    timer:Simple(1, function() 
        ParadiseZ.tp(pl, x, y, z)
        local sq = getCell():getOrCreateGridSquare(x, y, z)
        if sq then ParadiseZ.addTempMarker(sq) end
    end)
end
