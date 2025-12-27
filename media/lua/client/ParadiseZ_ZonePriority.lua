
ParadiseZ = ParadiseZ or {}


--[[ 
    local zone = ParadiseZ.getZoneData(pl)
    local name = zone.name
    local isOutsideZone = zone.isOutside
    local isKosZone = zone.isKos
    local isPveZone = zone.isPvE
    local isBlockedZone = zone.isBlocked
    local x, y = ParadiseZ.getXY(pl)
 ]]
--[[ 
function ParadiseZ.getZoneData(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then
        return {
            name = "Outside",
            isOutside = true,
            isKos = false,
            isPvE = false,
            isSafe = false,
            isBlocked = false,
            x = 0,
            y = 0
        }
    end
    
    local x, y = ParadiseZ.getXY(targ)
    if not (x and y) then
        return {
            name = "Outside",
            isOutside = true,
            isKos = false,
            isPvE = false,
            isSafe = false,
            isBlocked = false,
            x = 0,
            y = 0
        }
    end

    for i = 1, #ParadiseZ.ZoneData do
        local zone = ParadiseZ.ZoneData[i]
        if zone and x >= zone.x1 and x <= zone.x2 and y >= zone.y1 and y <= zone.y2 then
            return {
                index = i,
                name = zone.name,
                isOutside = false,
                isKos = zone.isKos == true,
                isPvE = zone.isPvE == true,
                isSafe = zone.isSafe == true,
                isBlocked = zone.isBlocked == true,
                x = x,
                y = y,
                zone = zone
            }
        end
    end

    return {
        index = math.huge,
        name = "Outside",
        isOutside = true,
        isKos = false,
        isPvE = false,
        isSafe = false,
        isBlocked = false,
        x = x,
        y = y,
        zone = nil
    }
end

function ParadiseZ.getZoneName(pl)
    local data = ParadiseZ.getZoneData(pl)
    return data and data.name or "Outside"
end

function ParadiseZ.isOutside(pl)
    local data = ParadiseZ.getZoneData(pl)
    return data and data.isOutside or true
end

function ParadiseZ.isKosZone(pl)
    local data = ParadiseZ.getZoneData(pl)
    return data and data.isKos or false
end

function ParadiseZ.isPveZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end

    if SandboxVars.ParadiseZ.VanillaNonPvpZone then
        local x, y = targ:getX(), targ:getY()
        if x and y and NonPvpZone.getNonPvpZone(x, y) then
            return true
        end
    end

    local data = ParadiseZ.getZoneData(pl)
    return data and data.isPvE and not data.isKos or false
end

function ParadiseZ.isBlockedZone(pl)
    local data = ParadiseZ.getZoneData(pl)
    return data and data.isBlocked or false
end

function ParadiseZ.isSafeZone(pl)
    local data = ParadiseZ.getZoneData(pl)
    return data and data.isSafe or false
end

function ParadiseZ.isRegularZone(pl)
    local data = ParadiseZ.getZoneData(pl)
    if not data or data.isOutside then return false end
    if (data.isKos and data.isPvE) or (not data.isKos and not data.isPvE) then
        return true
    end
    return false
end

 ]]