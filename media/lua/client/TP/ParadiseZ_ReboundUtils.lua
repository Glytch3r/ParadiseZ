--ParadiseZ_Rebound.lua
ParadiseZ = ParadiseZ or {}

function ParadiseZ.forceExitCar()
   
    ISVehicleMenu.onExit(getPlayer())
    
    local pl = getPlayer()
    if not pl then return end
    local car = pl:getVehicle()
    if not car then return end
    
    local seat = car:getSeat(pl)
    car:exit(pl)
    if seat then
        car:setCharacterPosition(pl, seat, tostring(SandboxVars.ParadiseZ.OutsideStr))
    end
    
    pl:PlayAnim("Idle")
    triggerEvent("OnExitVehicle", pl)
    car:updateHasExtendOffsetForExitEnd(pl)
end

ParadiseZ.teleporting = false

--[[
    B41 transport fix.

    Directly setting X/Y/Z is not enough for long-distance teleports in MP.
    The player's raw position can change while getCurrentSquare() remains in the
    old loaded chunk, causing the engine/server to correct the player back. This
    breaks long cage sends, PvP exile, and spawn/rebound correction when a player
    appears inside a restricted zone.

    The safe approach tested in live debug is:
      1. center the target tile,
      2. get/create the destination square to prime loading,
      3. set X/Y/Z and Lx/Ly/Lz,
      4. repeat the raw set briefly until getCurrentSquare() catches the target.

    Do not call setCurrent(), setCurrentSquare(), ensureOnTile(), or update() here.
    Those calls produced Java-side console spam in testing.
]]
ParadiseZ.TpTransportCfg = ParadiseZ.TpTransportCfg or {
    shortDist = 4.0,        -- border/rebound nudges inside this distance
    shortMax = 2,           -- short cage-border rebounds only need 1-2 ticks
    longMax = 15,           -- long cage/exile/restricted-zone sends get more time
    stableNeed = 2,         -- consecutive ticks with current square at target
    shortCooldown = 12,     -- suppress same-target border spam for this many ticks
    repeatRadius = 1.15     -- only suppress if still basically at the target
}

ParadiseZ.TpTransport = ParadiseZ.TpTransport or {
    tick = 0,
    active = nil,
    last = { x = nil, y = nil, z = nil, untilTick = 0 }
}

function ParadiseZ.tpCenter(v)
    v = tonumber(v)
    if not v then return nil end
    return math.floor(v) + 0.5
end

function ParadiseZ.tpDist(x1, y1, x2, y2)
    x1, y1, x2, y2 = tonumber(x1), tonumber(y1), tonumber(x2), tonumber(y2)
    if not x1 or not y1 or not x2 or not y2 then return -1 end
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt((dx * dx) + (dy * dy))
end

function ParadiseZ.tpPrimeSquare(x, y, z)
    x = ParadiseZ.tpCenter(x)
    y = ParadiseZ.tpCenter(y)
    z = tonumber(z) or 0
    if not x or not y then return false end

    local ok, sq = pcall(function()
        return getCell():getOrCreateGridSquare(math.floor(x), math.floor(y), z)
    end)

    return ok and sq ~= nil
end

function ParadiseZ.tpRawSet(pl, x, y, z)
    if not pl then return false end

    x = ParadiseZ.tpCenter(x)
    y = ParadiseZ.tpCenter(y)
    z = tonumber(z) or 0
    if not x or not y then return false end

    pl:setX(x)
    pl:setY(y)
    pl:setZ(z)

    if isClient() then
        pl:setLx(x)
        pl:setLy(y)
        pl:setLz(z)
    end

    return true
end

function ParadiseZ.tpIsSameLastTarget(x, y, z)
    local tr = ParadiseZ.TpTransport
    local last = tr and tr.last
    if not last then return false end

    x = ParadiseZ.tpCenter(x)
    y = ParadiseZ.tpCenter(y)
    z = tonumber(z) or 0

    return last.x == x and last.y == y and last.z == z
end

function ParadiseZ.tpShouldSuppress(pl, x, y, z, distToTarget)
    local cfg = ParadiseZ.TpTransportCfg
    local tr = ParadiseZ.TpTransport
    if not cfg or not tr or not pl then return false end
    if not ParadiseZ.tpIsSameLastTarget(x, y, z) then return false end
    if tr.tick > (tr.last.untilTick or 0) then return false end
    if distToTarget > cfg.repeatRadius then return false end

    local sq = pl:getCurrentSquare()
    if not sq then return false end

    x = ParadiseZ.tpCenter(x)
    y = ParadiseZ.tpCenter(y)
    if not x or not y then return false end

    local dx = math.abs(sq:getX() - math.floor(x))
    local dy = math.abs(sq:getY() - math.floor(y))

    return dx <= 1 and dy <= 1
end

function ParadiseZ.tpStartSettle(pl, x, y, z, reason, distToTarget)
    if not pl then return false end

    local cfg = ParadiseZ.TpTransportCfg
    local tr = ParadiseZ.TpTransport

    x = ParadiseZ.tpCenter(x)
    y = ParadiseZ.tpCenter(y)
    z = tonumber(z) or 0
    if not x or not y then return false end

    distToTarget = tonumber(distToTarget) or ParadiseZ.tpDist(pl:getX(), pl:getY(), x, y)

    local isShort = distToTarget >= 0 and distToTarget <= cfg.shortDist
    local maxReps = isShort and cfg.shortMax or cfg.longMax

    ParadiseZ.tpPrimeSquare(x, y, z)
    ParadiseZ.tpRawSet(pl, x, y, z)

    tr.active = {
        x = x,
        y = y,
        z = z,
        tx = math.floor(x),
        ty = math.floor(y),
        tz = z,
        done = 0,
        stable = 0,
        max = maxReps,
        isShort = isShort,
        reason = tostring(reason or "ParadiseZ.doTp")
    }

    tr.last.x = x
    tr.last.y = y
    tr.last.z = z
    tr.last.reason = tostring(reason or "ParadiseZ.doTp")
    tr.last.untilTick = isShort and (tr.tick + cfg.shortCooldown) or tr.tick

    return true
end

function ParadiseZ.tpTransportTick()
    local tr = ParadiseZ.TpTransport
    local cfg = ParadiseZ.TpTransportCfg
    if not tr or not cfg then return end

    tr.tick = (tr.tick or 0) + 1

    local s = tr.active
    if not s then return end

    local pl = getPlayer()
    if not pl then
        tr.active = nil
        return
    end

    s.done = s.done + 1

    -- Short border rebounds are already in loaded terrain; long jumps get
    -- one extra prime pass while the destination chunk/square catches up.
    if s.done == 1 or (not s.isShort and s.done == 5) then
        ParadiseZ.tpPrimeSquare(s.x, s.y, s.z)
    end

    ParadiseZ.tpRawSet(pl, s.x, s.y, s.z)

    local sq = pl:getCurrentSquare()
    if sq and sq:getX() == s.tx and sq:getY() == s.ty and sq:getZ() == s.tz then
        s.stable = s.stable + 1
    else
        s.stable = 0
    end

    if s.stable >= cfg.stableNeed or s.done >= s.max then
        tr.active = nil
    end
end

if ParadiseZ._tpTransportTickHook then
    Events.OnTick.Remove(ParadiseZ._tpTransportTickHook)
end
ParadiseZ._tpTransportTickHook = function()
    ParadiseZ.tpTransportTick()
end
Events.OnTick.Add(ParadiseZ._tpTransportTickHook)

function ParadiseZ.doTp(pl, x, y, z)
    pl = pl or getPlayer()
    if not pl then return false end
    if not x or not y or not z then return false end

    -- Leave B42 on the engine teleport path until this transport is separately
    -- validated there. The bug fixed here was reproduced on B41 multiplayer.
    if luautils.stringStarts(getCore():getVersion(), "42") then
        pl:teleportTo(x, y, z)
        return true
    end

    local cx = ParadiseZ.tpCenter(x)
    local cy = ParadiseZ.tpCenter(y)
    local cz = tonumber(z) or 0
    if not cx or not cy then return false end

    local distToTarget = ParadiseZ.tpDist(pl:getX(), pl:getY(), cx, cy)

    if ParadiseZ.tpShouldSuppress(pl, cx, cy, cz, distToTarget) then
        return true
    end

    return ParadiseZ.tpStartSettle(pl, cx, cy, cz, "ParadiseZ.doTp", distToTarget)
end

function ParadiseZ.carTp(pl, vehicle, x, y, z)
    if not vehicle or not pl then return false end
    local lx, ly, lz = x, y, z
    if lx == nil or ly == nil or lz == nil then
        ParadiseZ.forceExitCar()
        return false
    end
    
    local sq = getCell():getOrCreateGridSquare(math.floor(lx), math.floor(ly), lz)
    if sq and ParadiseZ.checkDist(pl, sq) >= 200 then
        ParadiseZ.forceExitCar()
        return false
    end
    
    local curX, curY = pl:getX(), pl:getY()
    local md = pl:getModData()
    local rebound = md and md['Rebound'] or nil
    local tx, ty = lx, ly
    if type(rebound) == 'table' and rebound.ax and rebound.ay then
        tx, ty = rebound.ax, rebound.ay
    end

    local dx, dy = curX - tx, curY - ty
    local len = math.sqrt(dx * dx + dy * dy)
    if len == 0 then return false end

    dx, dy = dx / len, dy / len
    local dist = 5
    local px, py = dx * dist, dy * dist

    local fieldCount = getNumClassFields(vehicle)
    local transField
    local fieldName = 'public final zombie.core.physics.Transform zombie.vehicles.BaseVehicle.jniTransform'

    for i = 0, fieldCount - 1 do
        local field = getClassField(vehicle, i)
        if tostring(field) == fieldName then
            transField = field
            break
        end
    end
    if not transField then return false end

    local v_transform = getClassFieldVal(vehicle, transField)
    local w_transform = vehicle:getWorldTransform(v_transform)
    local origin_field = getClassField(w_transform, 1)
    local origin = getClassFieldVal(w_transform, origin_field)
    origin:set(origin:x() - px, origin:y(), origin:z() - py)
    vehicle:setWorldTransform(w_transform)
    
    if isClient() then
        pcall(vehicle.update, vehicle)
        pcall(vehicle.updateControls, vehicle)
        pcall(vehicle.updateBulletStats, vehicle)
        pcall(vehicle.updatePhysics, vehicle)
        pcall(vehicle.updatePhysicsNetwork, vehicle)
    end
    return true
end