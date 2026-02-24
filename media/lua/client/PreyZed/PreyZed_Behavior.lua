
PreyZed = PreyZed or {}
ParadiseZ = ParadiseZ or {}

PreyZed.fleeRange = 20
PreyZed.fleeDist  = 15
PreyZed.fleeCD    = 3

function PreyZed.moveRandLoc(zed)
    local x, y, z = round(zed:getX()), round(zed:getY()), zed:getZ() or 0
    for _ = 1, 10 do
        local nx = ZombRand(x - PreyZed.fleeDist, x + PreyZed.fleeDist)
        local ny = ZombRand(y - PreyZed.fleeDist, y + PreyZed.fleeDist)
        local sq = getCell():getOrCreateGridSquare(nx, ny, z)
        if sq then
            PreyZed.moveToXYZ(zed, nx, ny, z)
            return
        end
    end
end

function PreyZed.moveToXYZ(zed, x, y, z)
    if not zed then return end
    local sq = getCell():getGridSquare(x, y, z)
    if sq then
        if ParadiseZ.isWithinRange(zed, sq, 2) then
            return sq
        else
            zed:pathToLocation(sq:getX(), sq:getY(), sq:getZ())
            if not sq:TreatAsSolidFloor() and sq:getZ() == zed:getSquare():getZ() then
                zed:setVariable("bPathfind", false)
                zed:setVariable("bMoving", true)
            end
        end
    end
end

function PreyZed.isClosestPl(pl, zed)
    local plDist = ParadiseZ.checkDist(pl, zed)
    local compare = round(zed:distToNearestCamCharacter())
    return plDist == compare
end

function PreyZed.isAimedAt(pl, zed)
    if not zed or not pl then return false end
    local dir = (pl:getDirectionAngle() + 360) % 360
    local dx = zed:getX() - pl:getX()
    local dy = zed:getY() - pl:getY()
    local targDir = (math.deg(math.atan2(dy, dx)) + 360) % 360
    local diff = (targDir - dir + 360) % 360
    local fov = 90
    local div = 9
    return (diff <= fov / div or diff >= 360 - fov / div) and pl:isAiming()
end

function PreyZed.Behavior(zed)
    if not zed then return end
    if not PreyZed.isPrey(zed) then return end

    local pl = getPlayer()
    if not pl then return end
    if not PreyZed.isClosestPl(pl, zed) then
        if zed:isUseless() then
            zed:setCanWalk(true)
            zed:setUseless(false)
            zed:setFakeDead(false)
        end
        return
    end

    local md = zed:getModData()
    local dist = ParadiseZ.checkDist(pl, zed)

    if PreyZed.isAimedAt(pl, zed) then
        zed:setFakeDead(true)
        zed:setUseless(true)
        zed:setCanWalk(false)
        md.Prey_Frozen = true
        md.Prey_Move = nil
        return
    end

    if md.Prey_Frozen then
        zed:setFakeDead(false)
        zed:setCanWalk(true)
        zed:setUseless(false)
        md.Prey_Frozen = nil
    end

    if dist <= PreyZed.fleeRange then
        if zed:getTarget() then zed:setTarget(nil) end
        zed:setUseless(true)
        zed:setCanWalk(true)
        if not md.Prey_Move then
            md.Prey_Move = true
            PreyZed.moveRandLoc(zed)
            timer:Simple(PreyZed.fleeCD, function()
                if zed and not zed:isDead() then
                    md.Prey_Move = nil
                end
            end)
        end
    else
        if zed:isUseless() then
            zed:setCanWalk(true)
            zed:setUseless(false)
        end
    end
end

Events.OnZombieUpdate.Remove(PreyZed.Behavior)
Events.OnZombieUpdate.Add(PreyZed.Behavior)