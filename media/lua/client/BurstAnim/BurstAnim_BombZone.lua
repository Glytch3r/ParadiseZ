ParadiseZ = ParadiseZ or {}
BurstAnim = BurstAnim or {}

function ParadiseZ.getRandomSquare(pl)

    pl = pl or getPlayer()
    if not pl then return nil end

    local px = round(pl:getX())
    local py = round(pl:getY())
    local pz = pl:getZ() or 0

    local rad = SandboxVars.ParadiseZ.BombZoneRad
    local x = px + ZombRand(-rad, rad + 1)
    local y = py + ZombRand(-rad, rad + 1)

    return getCell():getOrCreateGridSquare(x, y, pz)
end

local ticks = 0
function ParadiseZ.BombZoneHandler(pl)
    pl = pl or getPlayer()
    if not pl then return end
    ticks = ticks + 1
    if not ParadiseZ.isBombZone(pl) then return end
    if ticks % SandboxVars.ParadiseZ.BombZoneDelay == 0 then
        if ParadiseZ.doRoll(SandboxVars.ParadiseZ.BombZoneChance) then
            local sq = ParadiseZ.getRandomSquare(pl)
            if sq then
                local x, y, z = sq:getX(), sq:getY(), sq:getZ()
                BurstAnim.doExplosionDamage(x, y, z)
                if isClient() then
                    sendClientCommand("BurstAnim", "triggerBurst", {
                        x = x,
                        y = y,
                        z = z,
                        dir = dir,
                    })
                else
                    BurstAnim.doBurst(x, y, z, dir)
                end
            end
        end
    end
end

Events.OnPlayerUpdate.Remove(ParadiseZ.BombZoneHandler)
Events.OnPlayerUpdate.Add(ParadiseZ.BombZoneHandler)


