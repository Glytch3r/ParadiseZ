ParadiseZ = ParadiseZ or {}

local ticks = 0

function ParadiseZ.doCageTp(pl, x, y, z)
    local car = pl:getVehicle()
    if car then
        ParadiseZ.forceExitCar()
    end
    ParadiseZ.doTp(pl, x, y, z) 
end

function ParadiseZ.cageHandler(pl)
    if not pl then return end
    if not pl:isAlive() then return end
    ticks = ticks + 1
    if ticks % 3 == 0 then
        local isCageZone = ParadiseZ.isCageZone(pl) 
        local isCagedPl = ParadiseZ.isCagedPl(pl)
        if not isCagedPl then 
            if not isCageZone then
                ParadiseZ.saveCageReturn(pl)
            else
                local x, y, z = ParadiseZ.getCageReturn(pl)
                ParadiseZ.doCageTp(pl, x, y, z)
            end
        elseif isCagedPl then
            local plx, ply, plz = round(pl:getX()),  round(pl:getY()),  pl:getZ()
            local zName = ParadiseZ.getZoneName(plx, ply) 
            if isCageZone then
                if zName then
                    if ParadiseZ.isXYInsideZone(plx, ply, zName) then
                        ParadiseZ.saveCageRebound(pl, zName)
                    elseif ParadiseZ.isXYZoneOuter(plx, ply, zName, 3) then
                        local x, y, z = ParadiseZ.getCageRebound(pl)
                        ParadiseZ.doCageTp(pl, x, y, z)
                    end
                end
            else
                local x, y, z = ParadiseZ.parseCageCoords(false)
                ParadiseZ.doCageTp(pl, x, y, z)
            end
        end
    end
end
Events.OnPlayerUpdate.Remove(ParadiseZ.cageHandler)
Events.OnPlayerUpdate.Add(ParadiseZ.cageHandler)





function ParadiseZ.isCagedPl(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    return pl:getTraits():contains("Caged")
end

function ParadiseZ.setCaged(targUser, bool)
    if not targUser then return end
    local targPl = getPlayerFromUsername(targUser)
    if not targPl then return end
    if bool then
        targPl:getTraits():add("Caged")
    else
        targPl:getTraits():remove("Caged")
    end
    SyncXp(targPl)
end

function ParadiseZ.parseCageCoords(isReturn)
    local strList = SandboxVars.ParadiseZ.DefaultCageCoords
    if isReturn then
        strList = SandboxVars.ParadiseZ.DefaultCageReturnCoords
    end
    local tx, ty, tz = strList:match("^(-?%d+)[;:](-?%d+)[;:](-?%d+)")
    tx, ty, tz = tonumber(tx), tonumber(ty), tonumber(tz)
    return tx, ty, tz
end

function ParadiseZ.saveCageReturn(pl, name)
    pl = pl or getPlayer()
    if not pl then return nil end
    local sq = pl:getCurrentSquare()
    if not sq then return nil end
    local sx, sy = sq:getX(), sq:getY()
    name = name or ParadiseZ.getZoneName(pl)
    local md = pl:getModData()
    local tab = {
        name = name,
        x = sx + 0.5,
        y = sy + 0.5,
        z = pl:getZ(),
        ax = ParadiseZ.roundN(pl:getX(), 3),
        ay = ParadiseZ.roundN(pl:getY(), 3)
    }
    md['CageReturn'] = tab
    return tab

end


function ParadiseZ.saveCageRebound(pl, name)
    pl = pl or getPlayer()
    if not pl then return nil end
    local sq = pl:getCurrentSquare()
    if not sq then return nil end
    local sx, sy = sq:getX(), sq:getY()
    name = name or ParadiseZ.getZoneName(pl)
    local md = pl:getModData()
    if ParadiseZ.isXYZoneInner(sx, sy, name) then
        local tab = {
            name = name,
            x = sx + 0.5,
            y = sy + 0.5,
            z = pl:getZ(),
            ax = ParadiseZ.roundN(pl:getX(), 3),
            ay = ParadiseZ.roundN(pl:getY(), 3)
        }
        md['CageRebound'] = tab
        return tab
    end
    return nil
end


function ParadiseZ.isHasCageCoords(pl)
    local md = pl:getModData()
    return md['CageRebound'] ~= nil
end

function ParadiseZ.getCageRebound(pl)
    pl = pl or getPlayer()
    if not pl then return nil, nil, nil end
    local md = pl:getModData()
    local rebound = md['CageRebound']
    if rebound and rebound.x and rebound.y and rebound.z then
        return rebound.x, rebound.y, rebound.z
    end
    local x, y, z = ParadiseZ.parseCageCoords(false)
    return x, y, z
end

function ParadiseZ.getCageReturn(pl)
    pl = pl or getPlayer()
    if not pl then return nil, nil, nil end
    local md = pl:getModData()
    local rebound = md['CageReturn']
    if rebound and rebound.x and rebound.y and rebound.z then
        return rebound.x, rebound.y, rebound.z
    end
    local x, y, z = ParadiseZ.parseCageCoords(true)
    return x, y, z
end

