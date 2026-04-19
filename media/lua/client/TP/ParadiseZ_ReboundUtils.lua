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
function ParadiseZ.doTp(pl, x, y, z)
    --if not ParadiseZ.teleporting then     
        --ParadiseZ.teleporting = true
        if luautils.stringStarts(getCore():getVersion(), "42") then
            pl:teleportTo(x, y, z)
        else
            pl:setX(x)
            pl:setY(y)
            pl:setZ(z)
            if isClient() then
                pl:setLx(x)
                pl:setLy(y)
                pl:setLz(z)
            end
        end
    --end
--[[     
    timer:Simple(0.5, function() 
        ParadiseZ.teleporting = false
    end) ]]
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