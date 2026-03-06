
function ParadiseZ.isNoFire(sq)
    if not sq then return false end
    local zoneName = ParadiseZ.getZoneName(sq)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isNoFire == true
end





local ticks = 0
function ParadiseZ.noFireHandler(pl)

    ticks = ticks + 1
    if ticks % 20 ~= 0 then return end

    pl = pl or getPlayer()
    if not pl then return end
    
    local rad = SandboxVars.ParadiseZ.ClearFireRadius or 50
    local cell = pl:getCell()
    local sq = pl:getCurrentSquare()
    if not cell or not sq then return end

    local px, py, pz = sq:getX(), sq:getY(), sq:getZ()

    for dx = -rad, rad do
        for dy = -rad, rad do

            local targetSq = cell:getGridSquare(px + dx, py + dy, pz)
            if targetSq and targetSq:Is(IsoFlagType.burning) and ParadiseZ.isNoFire(targetSq) then
                targetSq:transmitStopFire()
                targetSq:stopFire()
            end
        end
    end
end

Events.OnPlayerUpdate.Remove(ParadiseZ.noFireHandler)
Events.OnPlayerUpdate.Add(ParadiseZ.noFireHandler)