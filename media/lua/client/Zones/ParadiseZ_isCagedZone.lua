function ParadiseZ.parseCageCoords()
    local strList = SandboxVars.ParadiseZ.DefaultCageCoords
    local tx, ty, tz = strList:match("^(-?%d+)[;:](-?%d+)[;:](-?%d+)")
    tx, ty, tz = tonumber(tx), tonumber(ty), tonumber(tz)
    return tx, ty, tz
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

function ParadiseZ.isCaged(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    return pl:getTraits():contains("Caged")
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

function ParadiseZ.getLastCageCoord(pl)
    pl = pl or getPlayer()
    if not pl then return nil, nil, nil end
    local md = pl:getModData()
    local rebound = md['CageRebound']
    if rebound and rebound.x and rebound.y and rebound.z then
        return rebound.x, rebound.y, rebound.z
    end
    local x, y, z = ParadiseZ.parseCageCoords()
    return x, y, z
end

function ParadiseZ.doCage(pl)
    if not SandboxVars.ParadiseZ.ReboundSystem then return end
    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return end
    local x, y, z = ParadiseZ.getLastCageCoord(pl)
    if not x or not y or not z then return end
    local car = pl:getVehicle()
    if car then
        local seat = car:getSeat(pl)
        if seat and seat ~= 0 then
            ParadiseZ.forceExitCar()
            local sq = getCell():getOrCreateGridSquare(math.floor(x), math.floor(y), z)
            if sq then ParadiseZ.addTempMarker(sq) end
            return
        end
        if ParadiseZ.carTp(pl, car, x, y, z) then return end
    end
    ParadiseZ.tp(pl, x, y, z)
    local sq = getCell():getOrCreateGridSquare(math.floor(x), math.floor(y), z)
    if sq then ParadiseZ.addTempMarker(sq) end
end


local cageTicks = 0
local cageTpCooldown = false

function ParadiseZ.cageHandler(pl)
    cageTicks = cageTicks + 1
    if cageTicks % 3 == 0 then
        if not pl then return end
        if not pl:isAlive() then return end
        if not ParadiseZ.isCaged(pl) then return end
        if cageTpCooldown then return end

        local plX, plY = ParadiseZ.getXY(pl)
        if not plX or not plY then return end
        local sq = getCell():getOrCreateGridSquare(plX, plY, pl:getZ())
        if not sq then return end
        local name = ParadiseZ.getZoneName(pl) or ParadiseZ.getSqZoneName(sq)
        local x, y, z = ParadiseZ.getLastCageCoord(pl)

        --clip("isCageZone="..tostring(ParadiseZ.isCageZone(pl)).." | name="..tostring(name).." | dest="..tostring(x)..","..tostring(y)..","..tostring(z).." | pos="..tostring(plX)..","..tostring(plY))

        if not ParadiseZ.isCageZone(pl) then
            if x and y and z then
                cageTpCooldown = true
                timer:Simple(1, function()
                    ParadiseZ.doTp(pl, x, y, z)
                    timer:Simple(3, function()
                        cageTpCooldown = false
                    end)
                end)
            end
            return
        end

        if ParadiseZ.isXYZoneInner(plX, plY, name) then
            ParadiseZ.saveCageRebound(pl, name)
            if getCore():getDebug() then
                if sq then ParadiseZ.addTempMarker(sq) end
            end
        else
            if x and y and z then
                cageTpCooldown = true
                timer:Simple(1, function()
                    ParadiseZ.doTp(pl, x, y, z)
                    timer:Simple(3, function()
                        cageTpCooldown = false
                    end)
                end)
            end
        end
    end
end


Events.OnPlayerUpdate.Remove(ParadiseZ.cageHandler)
Events.OnPlayerUpdate.Add(ParadiseZ.cageHandler)