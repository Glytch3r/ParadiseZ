EnvColor = EnvColor or {}
ParadiseZ = ParadiseZ or {}
function ParadiseZ.isBlazeZoneFromSquare(sq)
    if not sq then return false end
    local zoneName = ParadiseZ.getZoneName(sq)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isBlaze == true
end
function ParadiseZ.isFrostZoneFromSquare(sq)
    if not sq then return false end
    local zoneName = ParadiseZ.getZoneName(sq)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isFrost == true
end
function ParadiseZ.getCliColor(sq)
    if sq then        

        local isColRed = ParadiseZ.isBlazeZone(sq) and EnvColor.isDay()
        local isColBlue = ParadiseZ.isFrostZone(sq) and EnvColor.isNight()
        if isColRed then
            return 0.2,0,0,0.3
        elseif isColBlue then
            return 0,0,0.2,0.3
        end
    end
    return 0,0,0,0
end

function ParadiseZ.cliHandler(pl)
    if SandboxVars.ParadiseZ.TempColors then
        if not pl then return end
        local sq = pl:getCurrentSquare()
        if not sq then return end
        local isColRed = ParadiseZ.isBlazeZone(sq) and EnvColor.isDay()
        local isColBlue = ParadiseZ.isFrostZone(sq) and EnvColor.isNight()
        local hot = SandboxVars.ParadiseZ.BlazeTemp
        local cold = SandboxVars.ParadiseZ.FrostTemp        
        EnvColor.setWorldColor(isColRed or isColBlue)
        if isColRed then
        elseif isColBlue then
        end
    end
end
Events.OnPlayerUpdate.Add(ParadiseZ.cliHandler)

function ParadiseZ.getCliStr(sq)
    sq = sq or getPlayer():getSquare() 
    if ParadiseZ.isBlazeZoneFromSquare(sq) and EnvColor.isDay() then
        return "Hot"
    elseif ParadiseZ.isFrostZoneFromSquare(sq) and EnvColor.isNight() then
        return "Cold"
    end
    return "Normal"
end
TrailingTemp = TrailingTemp or {}
TrailingTemp.ticks = 0
function TrailingTemp.delTemp()
    if TrailingTemp.HeatSource then
        getCell():removeHeatSource(TrailingTemp.HeatSource)
        TrailingTemp.HeatSource = nil
    end
end

function TrailingTemp.addTemp(pl, isHot, isCold)
    TrailingTemp.delTemp()
    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return end
    local sq = pl:getCurrentSquare()
    if not sq then return end
    local temp

    if isHot then
        temp = math.floor(SandboxVars.ParadiseZ.BlazeTemp)
    elseif isCold then
        temp = math.floor(SandboxVars.ParadiseZ.FrostTemp)
    end
    --IsoHeatSource(int x, int y, int z, int radius, int temperature)
    if temp then
        TrailingTemp.HeatSource = IsoHeatSource.new(
            sq:getX(),
            sq:getY(),
            sq:getZ(),
            SandboxVars.ParadiseZ.TempRad,
            temp
        )
        getCell():addHeatSource(TrailingTemp.HeatSource)
    end
end

function TrailingTemp.update(pl)
    TrailingTemp.ticks = TrailingTemp.ticks + 1
    if TrailingTemp.ticks % 360 ~= 0 then return end
    if not pl then return end
    local sq = pl:getCurrentSquare()
    if not sq then return end
    local isHot = ParadiseZ.isBlazeZone(sq) and EnvColor.isDay()
    local isCold = ParadiseZ.isFrostZone(sq) and EnvColor.isNight()
    if TrailingTemp.HeatSource then
        TrailingTemp.delHeat()
    end
    if not isHot and not isCold then        
        return
    end
    TrailingTemp.addTemp(pl, isHot, isCold)
end

Events.OnPlayerUpdate.Remove(TrailingTemp.update)
Events.OnPlayerUpdate.Add(TrailingTemp.update)

function TrailingTemp.dbg(pl)
    local isColRed = ParadiseZ.isBlazeZone(pl) and EnvColor.isDay()
    print(isColRed)
    local isColBlue = ParadiseZ.isFrostZone(pl) and EnvColor.isNight()
    print(isColBlue)
end