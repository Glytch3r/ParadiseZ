ParadiseZ = ParadiseZ or {}
function ParadiseZ.parseExileCoords()   
    local strList = SandboxVars.ParadiseZpvp.ExileCoords
    local tx, ty, tz = strList:match("^(-?%d+)[;:](-?%d+)[;:](-?%d+)")
    tx, ty, tz = tonumber(tx), tonumber(ty), tonumber(tz)    
    return tx, ty, tz
end

function ParadiseZ.exileHandler(pl)
    pl = pl or getPlayer()
    if not isIngameState() then return end
    if not pl then return end
    if not pl:isAlive() then return end
    local md = pl:getModData()
    if not md then return end
    md.LifePoints = md.LifePoints or 100
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

    if pl:HasTrait('InjuredPvP') then
        pl:getTraits():remove('InjuredPvP')
    end
    local car = pl:getVehicle()
    if car then
        ParadiseZ.forceExitCar()
    end
    ParadiseZ.doTp(pl, x, y, z) 
    local md = pl:getModData()
    md.LifePoints = md.LifePoints + 25
end

--[[ 
    local sq = getCell():getOrCreateGridSquare(x, y, z)
    if sq then ParadiseZ.addTempMarker(sq) end
]]