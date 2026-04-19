ParadiseZ = ParadiseZ or {}

ParadiseZ = ParadiseZ or {}

function ParadiseZ.doCageTp(pl, x, y, z)
    if not pl then return end
    if pl:getVehicle() then
        ParadiseZ.forceExitCar()
    end
    if not x or not y or not z then return end
    ParadiseZ.doTp(pl, x, y, z)
end

local ticks = 0

function ParadiseZ.cageHandler(pl)
    if not pl then return end
    if not pl:isAlive() then return end

    ticks = ticks + 1
    if ticks % 3 ~= 0 then return end

    if not ParadiseZ.isCagedPl(pl) then return end

    local plx, ply, plz = round(pl:getX()), round(pl:getY()), pl:getZ()
    local isCageZone = ParadiseZ.isCageZone(pl)

    if isCageZone then
        local zName = ParadiseZ.getZoneName(plx, ply)
        if not zName then return end

        if ParadiseZ.isXYInsideZone(plx, ply, zName) then
            ParadiseZ.saveCageRebound(pl, zName)
        else
            local x, y, z = ParadiseZ.getCageRebound(pl)
            ParadiseZ.doCageTp(pl, x, y, z)
        end
        return
    end

    local x, y, z = ParadiseZ.getCageRebound(pl)

    if not x or not y or not z then
        local name = ParadiseZ.getZoneName(pl)
        if name then
            local cx, cy = ParadiseZ.getZoneCenter(name)
            if cx and cy then
                ParadiseZ.doCageTp(pl, cx, cy, plz)
                return
            end
        end

        x, y, z = ParadiseZ.parseCageCoords(false)
    end

    ParadiseZ.doCageTp(pl, x, y, z)
end

Events.OnPlayerUpdate.Remove(ParadiseZ.cageHandler)
Events.OnPlayerUpdate.Add(ParadiseZ.cageHandler)

function ParadiseZ.getZoneCenter(name)
    local data = ParadiseZ.ZoneData and ParadiseZ.ZoneData[name]
    if not data then return nil, nil end

    local minX = math.min(data.x1, data.x2)
    local maxX = math.max(data.x1, data.x2)
    local minY = math.min(data.y1, data.y2)
    local maxY = math.max(data.y1, data.y2)

    return (minX + maxX) / 2, (minY + maxY) / 2
end


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