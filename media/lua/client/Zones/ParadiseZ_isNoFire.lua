
function ParadiseZ.isNoFire(sq)
    if not sq then return false end
    local zoneName = ParadiseZ.getZoneName(sq)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isNoFire == true
end

local ticks = 0
function ParadiseZ.StopFire(pl)
    ticks = ticks + 1
    if ticks % 10 == 0 then
        pl = pl or getPlayer() 
        if not pl then return end
        
        local rad = SandboxVars.ParadiseZ.ClearFireRadius or 50
        local cell = pl:getCell()
        local sq = pl:getCurrentSquare()
        if not cell or not sq then return end
        local x, y, z = sq:getX(), sq:getY(), sq:getZ()
        
        for xDelta = -rad, rad do
            for yDelta = -rad, rad do
                local targetSq = cell:getOrCreateGridSquare(x + xDelta, y + yDelta, z)
                if targetSq and targetSq:Is(IsoFlagType.burning) and ParadiseZ.isNoFire(targetSq) then
                    targetSq:transmitStopFire()
                    targetSq:stopFire()
                end
            end
        end

    end

end
