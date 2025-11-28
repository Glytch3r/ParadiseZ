ParadiseZ = ParadiseZ or {}

function ParadiseZ.setTrailingLightMode(activate, pl)
    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return end
    if string.lower(pl:getAccessLevel()) == "admin" then
        if activate ~= nil then
            pl:getModData().isTrailLight = activate
        end
    end
end

function ParadiseZ.toggleTrailingLightMode(pl, activate)
    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return end
    if string.lower(pl:getAccessLevel()) ~= "admin" then return end
    local md = pl:getModData()
    if activate ~= nil then
        md.isTrailLight = activate
    else
        md.isTrailLight = not (md.isTrailLight or false)
    end
end

function ParadiseZ.isTrailingLightMode(pl)
    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return end
    local md = pl:getModData()
    md.isTrailLight = md.isTrailLight or false
    return md.isTrailLight
end

local ticks = 0

function ParadiseZ.TrailingLight(pl)
    ticks = ticks + 1
    if ticks % 4 ~= 0 then return end

    if not pl then return end
    local cell = pl:getCell()

    local function removeTrail()
        if ParadiseZ.TrailLight then
            cell:removeLamppost(ParadiseZ.TrailLight)
            ParadiseZ.TrailLight = nil
        end
        if ParadiseZ.TrailingMarker then
            ParadiseZ.TrailingMarker:remove()
            ParadiseZ.TrailingMarker = nil
        end
    end

    if string.lower(pl:getAccessLevel()) ~= "admin" then return end

    if not ParadiseZ.isTrailingLightMode(pl) then
        removeTrail()
        return
    end

    local csq = pl:getCurrentSquare()
    if not csq then
        removeTrail()
        return
    end

    if ParadiseZ.trailX and ParadiseZ.trailY and ParadiseZ.trailZ then
        if ParadiseZ.trailX ~= round(csq:getX()) or
           ParadiseZ.trailY ~= round(csq:getY()) or
           ParadiseZ.trailZ ~= round(csq:getZ()) then

            if not pl:isAlive() then
                removeTrail()
                return
            end

            local x, y = ParadiseZ.getXY(pl)
            if not x or not y then
                removeTrail()
                return
            end

            local z = pl:getZ()
            if not z then
                removeTrail()
                return
            end

            if ParadiseZ.TrailLight then
                cell:removeLamppost(ParadiseZ.TrailLight)
                ParadiseZ.TrailLight = nil
            end

            local rad = 5
            ParadiseZ.TrailLight = IsoLightSource.new(x, y, z, 255, 255, 255, 255, rad)
            cell:addLamppost(ParadiseZ.TrailLight)

            ParadiseZ.trailX = x
            ParadiseZ.trailY = y
            ParadiseZ.trailZ = z

            ParadiseZ.glowingMarker(pl, csq)
        end
    else
        ParadiseZ.trailX = round(csq:getX())
        ParadiseZ.trailY = round(csq:getY())
        ParadiseZ.trailZ = round(csq:getZ())
    end
end

Events.OnPlayerUpdate.Remove(ParadiseZ.TrailingLight)
Events.OnPlayerUpdate.Add(ParadiseZ.TrailingLight)

function ParadiseZ.initTrailingLight()
    local pl = getPlayer()
    local x, y, z = round(pl:getX()), round(pl:getY()), pl:getZ()
    ParadiseZ.trailX = x
    ParadiseZ.trailY = y
    ParadiseZ.trailZ = z
end

Events.OnCreatePlayer.Remove(ParadiseZ.initTrailingLight)
Events.OnCreatePlayer.Add(ParadiseZ.initTrailingLight)

function ParadiseZ.randFloat()
    return ZombRand(0,101) / 100
end

function ParadiseZ.glowingMarker(pl, csq)
    if not SandboxVars.ParadiseZ.showTrailingMarkers then return end
    pl = pl or getPlayer()
    if ParadiseZ.TrailingMarker then
        ParadiseZ.TrailingMarker:remove()
        ParadiseZ.TrailingMarker = nil
    end
    csq = csq or pl:getCurrentSquare()
    local r = ParadiseZ.randFloat()
    ParadiseZ.TrailingMarker = getWorldMarkers():addGridSquareMarker(
        "circle_center", "circle_only_highlight", csq, r, r, r, true, r
    )
end
