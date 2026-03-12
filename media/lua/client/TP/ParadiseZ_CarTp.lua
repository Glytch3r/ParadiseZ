CarMoverBatch = {
    stepSize   = 15,     -- tiles per move on each active axis
    pauseTicks = 1,      -- ticks to wait between moves
    liftAmount = 10,     -- how high to lift during travel
    tolerance  = 0.01,

    running    = false,
    waitTicks  = 0,
    moveCount  = 0,

    targetX    = nil,
    targetZ    = nil,
    groundY    = nil,
    travelY    = nil,

    _handler   = nil
}

function CarMoverBatch.findTransField(veh)
    local want = "public final zombie.core.physics.Transform zombie.vehicles.BaseVehicle.jniTransform"
    for i = 0, getNumClassFields(veh) - 1 do
        local f = getClassField(veh, i)
        if tostring(f) == want then
            return f
        end
    end
    return nil
end

function CarMoverBatch.getCurrentVehicle()
    local pl = getPlayer()
    if not pl then
        print("[CarMoverBatch] ERROR: No local player found.")
        return nil
    end

    local v = nil
    if pl.getVehicle then
        pcall(function()
            v = pl:getVehicle()
        end)
    end

    if not v then
        print("[CarMoverBatch] ERROR: You are not in a vehicle.")
        return nil
    end

    return v
end

function CarMoverBatch.getTransformOrigin(v)
    if not v then
        return nil, nil
    end

    local tf = CarMoverBatch.findTransField(v)
    if not tf then
        print("[CarMoverBatch] ERROR: Could not find vehicle transform field.")
        return nil, nil
    end

    local vTransform = getClassFieldVal(v, tf)
    if not vTransform then
        print("[CarMoverBatch] ERROR: Could not get vehicle transform.")
        return nil, nil
    end

    local wTransform = v:getWorldTransform(vTransform)
    if not wTransform then
        print("[CarMoverBatch] ERROR: Could not get world transform.")
        return nil, nil
    end

    local originField = getClassField(wTransform, 1)
    local origin = getClassFieldVal(wTransform, originField)
    if not origin then
        print("[CarMoverBatch] ERROR: Could not get transform origin.")
        return nil, nil
    end

    return wTransform, origin
end

function CarMoverBatch.signWithTol(v, tol)
    tol = tol or 0.001
    if v > tol then
        return 1
    elseif v < -tol then
        return -1
    else
        return 0
    end
end

function CarMoverBatch.directionToAngle(dx, dz)
    local sx = CarMoverBatch.signWithTol(dx)
    local sz = CarMoverBatch.signWithTol(dz)

    -- 0   = North
    -- 45  = North-East
    -- 90  = East
    -- 135 = South-East
    -- 180 = South
    -- -135= South-West
    -- -90 = West
    -- -45 = North-West

    if sx == 0  and sz == -1 then return 0 end
    if sx == 1  and sz == -1 then return 45 end
    if sx == 1  and sz == 0  then return 90 end
    if sx == 1  and sz == 1  then return 135 end
    if sx == 0  and sz == 1  then return 180 end
    if sx == -1 and sz == 1  then return -135 end
    if sx == -1 and sz == 0  then return -90 end
    if sx == -1 and sz == -1 then return -45 end

    return nil
end

function CarMoverBatch.clampStep(delta, maxStep)
    if math.abs(delta) <= maxStep then
        return delta
    end
    if delta > 0 then
        return maxStep
    end
    return -maxStep
end

function CarMoverBatch.setAbsolute(x, y, z, angleY)
    local v = CarMoverBatch.getCurrentVehicle()
    if not v then
        return false
    end

    local wTransform, origin = CarMoverBatch.getTransformOrigin(v)
    if not origin then
        return false
    end

    x = tonumber(x) or origin:x()
    y = tonumber(y) or origin:y()
    z = tonumber(z) or origin:z()

    origin:set(x, y, z)
    v:setWorldTransform(wTransform)

    if angleY ~= nil then
        local oldX = v:getAngleX()
        local oldZ = v:getAngleZ()
        v:setAngles(oldX, angleY, oldZ)
    end

    pcall(v.updatePhysics, v)
    pcall(v.updatePhysicsNetwork, v)
    return true
end

function CarMoverBatch.getCoords()
    local v = CarMoverBatch.getCurrentVehicle()
    if not v then
        return nil
    end

    local _, origin = CarMoverBatch.getTransformOrigin(v)
    if not origin then
        return nil
    end

    return origin:x(), origin:y(), origin:z(), v:getAngleY()
end

function CarMoverBatch.landNow()
    if CarMoverBatch.groundY == nil then
        return false
    end

    local x, _, z, angleY = CarMoverBatch.getCoords()
    if not x then
        return false
    end

    return CarMoverBatch.setAbsolute(x, CarMoverBatch.groundY, z, angleY)
end

function CarMoverBatch.stop(landNow)
    if landNow == nil then
        landNow = true
    end

    if landNow and CarMoverBatch.groundY ~= nil then
        pcall(function()
            CarMoverBatch.landNow()
        end)
    end

    if CarMoverBatch._handler then
        pcall(function()
            Events.OnTick.Remove(CarMoverBatch._handler)
        end)
    end

    CarMoverBatch._handler = nil
    CarMoverBatch.running = false
    CarMoverBatch.waitTicks = 0

    print("[CarMoverBatch] Stopped.")
end

function CarMoverBatch.where()
    local x, y, z, angleY = CarMoverBatch.getCoords()
    if not x then
        return
    end

    print(string.format(
        "[CarMoverBatch] X=%.2f Z=%.2f Y(vertical)=%.2f AngleY=%.2f",
        x, z, y, angleY
    ))
end

function CarMoverBatch.moveToCoords(targetX, targetZ, stepSize, pauseTicks, liftAmount)
    local startX, startY, startZ = CarMoverBatch.getCoords()
    if not startX then
        return
    end

    targetX = tonumber(targetX)
    targetZ = tonumber(targetZ)
    stepSize = tonumber(stepSize) or CarMoverBatch.stepSize
    pauseTicks = tonumber(pauseTicks) or CarMoverBatch.pauseTicks
    liftAmount = tonumber(liftAmount) or CarMoverBatch.liftAmount

    if not targetX or not targetZ then
        print("[CarMoverBatch] ERROR: Use CarMoverBatch.moveToCoords(targetX, targetZ[, stepSize, pauseTicks, liftAmount])")
        return
    end

    if stepSize <= 0 then
        stepSize = 15
    end
    if pauseTicks < 0 then
        pauseTicks = 0
    end

    CarMoverBatch.stop(false)

    CarMoverBatch.stepSize = stepSize
    CarMoverBatch.pauseTicks = pauseTicks
    CarMoverBatch.liftAmount = liftAmount

    CarMoverBatch.targetX = targetX
    CarMoverBatch.targetZ = targetZ
    CarMoverBatch.groundY = startY
    CarMoverBatch.travelY = startY + liftAmount

    CarMoverBatch.waitTicks = 0
    CarMoverBatch.moveCount = 0
    CarMoverBatch.running = true

    local initialDx = targetX - startX
    local initialDz = targetZ - startZ
    local initialAngle = CarMoverBatch.directionToAngle(initialDx, initialDz)

    if not CarMoverBatch.setAbsolute(startX, CarMoverBatch.travelY, startZ, initialAngle) then
        print("[CarMoverBatch] ERROR: Initial lift failed.")
        CarMoverBatch.stop(false)
        return
    end

    CarMoverBatch._handler = function()
        if not CarMoverBatch.running then
            return
        end

        if CarMoverBatch.waitTicks > 0 then
            CarMoverBatch.waitTicks = CarMoverBatch.waitTicks - 1
            return
        end

        local curX, curY, curZ = CarMoverBatch.getCoords()
        if not curX then
            CarMoverBatch.stop(false)
            return
        end

        local remX = CarMoverBatch.targetX - curX
        local remZ = CarMoverBatch.targetZ - curZ

        if math.abs(remX) <= CarMoverBatch.tolerance and math.abs(remZ) <= CarMoverBatch.tolerance then
            local landed = CarMoverBatch.setAbsolute(
                CarMoverBatch.targetX,
                CarMoverBatch.groundY,
                CarMoverBatch.targetZ,
                nil
            )

            if landed then
                print(string.format(
                    "[CarMoverBatch] Reached target and landed. X=%.2f Z=%.2f Y=%.2f moves=%d",
                    CarMoverBatch.targetX,
                    CarMoverBatch.targetZ,
                    CarMoverBatch.groundY,
                    CarMoverBatch.moveCount
                ))
            else
                print("[CarMoverBatch] ERROR: Final landing failed.")
            end

            CarMoverBatch.stop(false)
            return
        end

        local dx = CarMoverBatch.clampStep(remX, CarMoverBatch.stepSize)
        local dz = CarMoverBatch.clampStep(remZ, CarMoverBatch.stepSize)
        local angleY = CarMoverBatch.directionToAngle(dx, dz)

        local finalStep = (math.abs(remX) <= CarMoverBatch.stepSize and math.abs(remZ) <= CarMoverBatch.stepSize)
        local ok = false

        if finalStep then
            ok = CarMoverBatch.setAbsolute(
                CarMoverBatch.targetX,
                CarMoverBatch.groundY,
                CarMoverBatch.targetZ,
                angleY
            )
        else
            ok = CarMoverBatch.setAbsolute(
                curX + dx,
                CarMoverBatch.travelY,
                curZ + dz,
                angleY
            )
        end

        if not ok then
            print("[CarMoverBatch] ERROR: Move failed.")
            CarMoverBatch.stop(true)
            return
        end

        CarMoverBatch.moveCount = CarMoverBatch.moveCount + 1
        CarMoverBatch.waitTicks = CarMoverBatch.pauseTicks

        print(string.format(
            "[CarMoverBatch] Move %d | step=(%.2f, %.2f) | angleY=%s | finalStep=%s",
            CarMoverBatch.moveCount,
            dx,
            dz,
            tostring(angleY),
            tostring(finalStep)
        ))
    end

    Events.OnTick.Add(CarMoverBatch._handler)

    print(string.format(
        "[CarMoverBatch] Started -> targetX=%.2f targetZ=%.2f stepSize=%.2f pauseTicks=%d liftAmount=%.2f groundY=%.2f travelY=%.2f",
        CarMoverBatch.targetX,
        CarMoverBatch.targetZ,
        CarMoverBatch.stepSize,
        CarMoverBatch.pauseTicks,
        CarMoverBatch.liftAmount,
        CarMoverBatch.groundY,
        CarMoverBatch.travelY
    ))
end