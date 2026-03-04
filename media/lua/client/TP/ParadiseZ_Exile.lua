ParadiseZ = ParadiseZ or {}

ParadiseZ.ExileStress = ParadiseZ.ExileStress or {
    delaySeconds = 1,
    repeatSeconds = 2,
    returnWaitSeconds = 10,
    task = nil,
}

local function PZ_ms()
    return getTimestampMs and getTimestampMs() or (os.time() * 1000)
end

local function PZ_cmdTp(x, y, z)
    x, y, z = math.floor(x), math.floor(y), math.floor(z or 0)
    SendCommandToServer(string.format("/teleportto %d,%d,%d", x, y, z))
end

function ParadiseZ.doExile(pl)
    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return end

    local x, y, z = ParadiseZ.parseExileCoords()
    if not x or not y or not z then return end

    local ox, oy, oz = pl:getX(), pl:getY(), pl:getZ()


    ParadiseZ.ExileStress.task = {
        phase = 0,
        startAt = PZ_ms() + (ParadiseZ.ExileStress.delaySeconds * 1000),
        endSpamAt = nil,
        returnAt = nil,
        ox = ox, oy = oy, oz = oz,
        tx = x,  ty = y,  tz = z,
        nextPrintAt = nil,
        lastShown = nil,
    }
end

function ParadiseZ.exileStressUpdater(pl)
    local t = ParadiseZ.ExileStress.task
    if not t then return end

    local now = PZ_ms()

    if t.phase == 0 then
        if now < t.startAt then return end
        t.phase = 1
        t.endSpamAt = now + (ParadiseZ.ExileStress.repeatSeconds * 1000)
        return
    end

    if t.phase == 1 then
        if now <= t.endSpamAt then
            PZ_cmdTp(t.tx, t.ty, t.tz)
            return
        end
        t.phase = 2
        t.returnAt = now + (ParadiseZ.ExileStress.returnWaitSeconds * 1000)
        t.nextPrintAt = now
        return
    end

    if t.phase == 2 then
        local remaining = math.max(0, math.ceil((t.returnAt - now) / 1000))
        if now >= t.nextPrintAt then
            if t.lastShown ~= remaining then
                print("Returning in "..remaining)
                t.lastShown = remaining
            end
            t.nextPrintAt = now + 1000
        end
        if now >= t.returnAt then
            t.phase = 3
        else
            return
        end
    end

    if t.phase == 3 then
        PZ_cmdTp(t.ox, t.oy, t.oz)
        ParadiseZ.ExileStress.task = nil
    end
end

Events.OnPlayerUpdate.Remove(ParadiseZ.exileStressUpdater)
Events.OnPlayerUpdate.Add(ParadiseZ.exileStressUpdater)