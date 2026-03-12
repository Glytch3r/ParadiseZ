-- Client

Guantlet = Guantlet or {}

function Guantlet.initReturn()
    if not isIngameState() then return end
    pl = getPlayer()
    LuaEventManager.AddEvent("OnClockUpdate")
    local prevSec = PZCalendar.getInstance():get(Calendar.SECOND)
    Events.OnTick.Add(function()
        local curSec = PZCalendar.getInstance():get(Calendar.SECOND)
        if prevSec < curSec or (curSec == 1 and prevSec > curSec) then
            triggerEvent("OnClockUpdate")
            prevSec = curSec
        end
    end)
    Guantlet.isClockActive = true
    Events.OnClockUpdate.Add(Guantlet.requestSync)
    Events.OnClockUpdate.Add(Guantlet.waveTick)
    Events.OnPlayerUpdate.Remove(Guantlet.initReturn)
end
Events.OnPlayerUpdate.Add(Guantlet.initReturn)

function Guantlet.getGuantlet(GuantletId)
    return GuantletData and GuantletData[tostring(GuantletId)] or nil
end

function Guantlet.getGuantletIdFromSq(sq)
    if not sq then return end
    if not GuantletData then return end
    for GuantletId, _ in pairs(GuantletData) do
        if GuantletId then
            local data = GuantletData[tostring(GuantletId)]
            if data then
                if data.EntranceX == math.floor(sq:getX()) and
                   data.EntranceY == math.floor(sq:getY()) and
                   data.EntranceZ == math.floor(sq:getZ()) then
                    return GuantletId
                end
            end
        end
    end
    return nil
end

function Guantlet.doDespawn(zed)
    zed:setAvoidDamage(false)
    zed:changeState(ZombieOnGroundState.instance())
    zed:setAttackedBy(getCell():getFakeZombieForHit())
    zed:becomeCorpse()
    zed:removeFromWorld()
    zed:removeFromSquare()
end

function Guantlet.getSpawnRandomZedInfo(fit)
    local maleOutfits = getAllOutfits(false)
    local femaleOutfits = getAllOutfits(true)
    local allOutfits = {}
    for i = 0, maleOutfits:size() - 1 do
        table.insert(allOutfits, maleOutfits:get(i))
    end
    for i = 0, femaleOutfits:size() - 1 do
        table.insert(allOutfits, femaleOutfits:get(i))
    end
    if not fit or fit == '' then
        fit = allOutfits[ZombRand(#allOutfits) + 1]
    end
    local outfitExists = false
    for _, outfit in ipairs(allOutfits) do
        if outfit == fit then
            outfitExists = true
            break
        end
    end
    if not outfitExists then
        fit = allOutfits[ZombRand(#allOutfits) + 1]
    end
    if maleOutfits:contains(fit) and femaleOutfits:contains(fit) then
        return fit, 0
    elseif femaleOutfits:contains(fit) then
        return fit, 100
    else
        return fit, 0
    end
end

function Guantlet.requestSync()
    ModData.request("GuantletData")
end

function Guantlet.checkDist(pl, sq)
    local dist = pl:DistTo(sq:getX(), sq:getY())
    return math.floor(dist)
end

function Guantlet.isWithinRange(pl, zed, range)
    local dist = pl:DistTo(zed:getX(), zed:getY())
    return dist <= range
end

function Guantlet.getClosestPlayerToSq(sq)
    local closestPlayer = nil
    local closestDistance = 15
    local onlinePlayers = getOnlinePlayers()
    for i = 0, onlinePlayers:size() - 1 do
        local pl = onlinePlayers:get(i)
        if pl then
            local plSq = pl:getSquare()
            if plSq then
                local distance = sq:DistTo(plSq)
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = pl
                end
            end
        end
    end
    return closestPlayer
end