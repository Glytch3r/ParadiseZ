function ParadiseZ.parseCageCoords(isReturn)
    local strList = SandboxVars.ParadiseZ.DefaultCageCoords
    if isReturn then
        strList = SandboxVars.ParadiseZ.DefaultCageReturnCoords
    end
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

function ParadiseZ.getLastCageCoord(pl)
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

function ParadiseZ.getCageReturnCoord(pl)
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


local cageTicks = 0
local cageTpCooldown = false

function ParadiseZ.cageHandler(pl)
    cageTicks = cageTicks + 1

    if not pl then return end
    if not pl:isAlive() then return end

    local md = pl:getModData()
    md['CageWasInner'] = md['CageWasInner'] or false

    if cageTicks % 3000 == 0 then
        if not ParadiseZ.isCaged(pl) then 
            ParadiseZ.saveCageReturn(pl)
            return 
        end
    end

    if cageTicks % 3 ~= 0 then return end
    if not ParadiseZ.isCaged(pl) then return end
    if cageTpCooldown then return end

    local plX, plY = ParadiseZ.getXY(pl)
    if not plX or not plY then return end

    local sq = getCell():getOrCreateGridSquare(plX, plY, pl:getZ())
    if not sq then return end

    local name = ParadiseZ.getZoneName(pl) or ParadiseZ.getSqZoneName(sq)
    local x, y, z = ParadiseZ.getLastCageCoord(pl)

    if not ParadiseZ.isCageZone(pl) then
        if x and y and z then
            cageTpCooldown = true
            ParadiseZ.doTp(pl, x, y, z)
            timer:Simple(3, function() cageTpCooldown = false end)
        end
        md['CageWasInner'] = false
        return
    end

    local isInner = ParadiseZ.isXYZoneInner(plX, plY, name)

    if isInner then
        ParadiseZ.saveCageRebound(pl, name)
        md['CageWasInner'] = true

        if getCore():getDebug() then
            if sq then ParadiseZ.addTempMarker(sq) end
        end

    else
        if md['CageWasInner'] then
            if x and y and z then
                cageTpCooldown = true
                timer:Simple(1, function()
                    local car = pl:getVehicle()
                    if car then
                        ParadiseZ.forceExitCar()
                    else
                        ParadiseZ.doTp(pl, x, y, z)
                    end
                    timer:Simple(3, function()
                        cageTpCooldown = false
                    end)
                end)
            end
        end
        md['CageWasInner'] = false
    end
end

Events.OnPlayerUpdate.Remove(ParadiseZ.cageHandler)
Events.OnPlayerUpdate.Add(ParadiseZ.cageHandler)


function ParadiseZ.isCaged(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    return pl:getTraits():contains("Caged")
end

function ParadiseZ.cageSetHandler(pl)
    if not pl then return end
    local md = pl:getModData()
    md['CagedState'] = md['CagedState'] or false

    local isNow = ParadiseZ.isCaged(pl)
    local was = md['CagedState']
    
    if isNow and not was then
        ParadiseZ.saveCageReturn(pl)
        timer:Simple(3, function() pl:Say('Caged') end)
    elseif not isNow and was then
        local x, y, z = ParadiseZ.getCageReturnCoord(pl)
        if x and y and z then
            local car = pl:getVehicle()
            if car then
                ParadiseZ.forceExitCar()
            end
            ParadiseZ.doTp(pl, x, y, z)
        end
        timer:Simple(3, function() pl:Say('No Longer Caged') end)
    end

    md['CagedState'] = isNow
end
Events.OnPlayerUpdate.Remove(ParadiseZ.cageSetHandler)
Events.OnPlayerUpdate.Add(ParadiseZ.cageSetHandler)


