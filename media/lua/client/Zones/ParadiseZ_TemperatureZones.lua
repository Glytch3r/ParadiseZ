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
        local isColRed = ParadiseZ.isBlazeZoneFromSquare(sq) and EnvColor.isDay()
        local isColBlue = ParadiseZ.isFrostZoneFromSquare(sq) and EnvColor.isNight()
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
        local sq = pl:getSquare() 
        if not sq then return end
        local isColRed = ParadiseZ.isBlazeZoneFromSquare(sq) and EnvColor.isDay()
        local isColBlue = ParadiseZ.isFrostZoneFromSquare(sq) and EnvColor.isNight()
        local hot = SandboxVars.ParadiseZ.BlazeTemp
        local cold = SandboxVars.ParadiseZ.FrostTemp
        
        EnvColor.setWorldColor(isColRed or isColBlue)
        if isColRed then
        elseif isColBlue then
        end
    end
end
Events.OnPlayerUpdate.Add(ParadiseZ.cliHandler)

TrailingTemp = TrailingTemp or {}
TrailingTemp.ticks = 0
function TrailingTemp.delHeat()
    if TrailingTemp.HeatSource then
        getCell():removeHeatSource(TrailingTemp.HeatSource)
        TrailingTemp.HeatSource = nil
    end
end
function TrailingTemp.addHeat(pl, isHot, isCold)
    TrailingTemp.delHeat()
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
    TrailingTemp.HeatSource = IsoHeatSource.new(
        sq:getX(),
        sq:getY(),
        sq:getZ(),
        1,
        temp
    )
    getCell():addHeatSource(TrailingTemp.HeatSource)
end

function TrailingTemp.update(pl)
    TrailingTemp.ticks = TrailingTemp.ticks + 1
    if TrailingTemp.ticks % 60 ~= 0 then return end
    if not pl then return end
    local sq = pl:getCurrentSquare()
    if not sq then return end
    local isHot = ParadiseZ.isBlazeZoneFromSquare(sq) and EnvColor.isDay()
    local isCold = ParadiseZ.isFrostZoneFromSquare(sq) and EnvColor.isNight()
    if not isHot and not isCold then
        TrailingTemp.delHeat()
        return
    end
    TrailingTemp.addHeat(pl, isHot, isCold)
end
Events.OnPlayerUpdate.Remove(TrailingTemp.update)
Events.OnPlayerUpdate.Add(TrailingTemp.update)