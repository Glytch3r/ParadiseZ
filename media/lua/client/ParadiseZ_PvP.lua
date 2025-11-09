----------------------------------------------------------------
-----  ▄▄▄   ▄    ▄   ▄  ▄▄▄▄▄   ▄▄▄   ▄   ▄   ▄▄▄    ▄▄▄  -----
----- █   ▀  █    █▄▄▄█    █    █   ▀  █▄▄▄█  ▀  ▄█  █ ▄▄▀ -----
----- █  ▀█  █      █      █    █   ▄  █   █  ▄   █  █   █ -----
-----  ▀▀▀▀  ▀▀▀▀   ▀      ▀     ▀▀▀   ▀   ▀   ▀▀▀   ▀   ▀ -----
----------------------------------------------------------------
--                                                            --
--   Project Zomboid Modding Commissions                      --
--   https://steamcommunity.com/id/glytch3r/myworkshopfiles   --
--                                                            --
--   ▫ Discord  ꞉   glytch3r                                  --
--   ▫ Support  ꞉   https://ko-fi.com/glytch3r                --
--   ▫ Youtube  ꞉   https://www.youtube.com/@glytch3r         --
--   ▫ Github   ꞉   https://github.com/Glytch3r               --
--                                                            --
----------------------------------------------------------------
----- ▄   ▄   ▄▄▄   ▄   ▄   ▄▄▄     ▄      ▄   ▄▄▄▄  ▄▄▄▄  -----
----- █   █  █   ▀  █   █  ▀   █    █      █      █  █▄  █ -----
----- ▄▀▀ █  █▀  ▄  █▀▀▀█  ▄   █    █    █▀▀▀█    █  ▄   █ -----
-----  ▀▀▀    ▀▀▀   ▀   ▀   ▀▀▀   ▀▀▀▀▀  ▀   ▀    ▀   ▀▀▀  -----
----------------------------------------------------------------

ParadiseZ = ParadiseZ or {}

function ParadiseZ.getLastCoord()
    local pl = getPlayer()
    if not pl then return nil end

    local key = pl:getID()
    if not PhunZones or not PhunZones.players or not PhunZones.players[key] then
        return nil
    end

    local last = PhunZones.players[key].last
    if not last or not last.x or not last.y or not last.z then
        return nil
    end

    return last.x, last.y, last.z
end

function ParadiseZ.getReboundXYZ(pl, vx, vy, vz)
    pl = pl or getPlayer()
    if not pl then return end

    local curSq = pl:getCurrentSquare()
    if not curSq then return end
    
    local cx, cy, cz = curSq:getX(), curSq:getY(), curSq:getZ()
    local lx, ly, lz = ParadiseZ.getLastCoord()
    if vx and vy then
        lx = ly
        ly = vy
        lz = vz
    end
    if not lx or not ly or not lz then return end
    
    local cell = getWorld():getCell()
    if not cell then return end

    local lastSq = cell:getGridSquare(math.floor(lx+0.5), math.floor(ly+0.5), lz)
    if not lastSq then lastSq = cell:getGridSquare(lx, ly, lz) end
    if not lastSq then return end
    --addTempMarker(lastSq, false)
    local sx, sy = lastSq:getX(), lastSq:getY()
    local dx, dy = cx - sx, cy - sy
    local len = math.sqrt(dx * dx + dy * dy)
    local dist = 8
    local dirX, dirY
    if len < 0.0001 then
        dirX, dirY = 0, -1
    else
        dirX, dirY = dx / len, dy / len
    end

    local targetX, targetY, targetSq
    for i = dist, dist + 6 do
        targetX = sx - dirX * i
        targetY = sy - dirY * i
        local tx = math.floor(targetX + 0.5)
        local ty = math.floor(targetY + 0.5)
        targetSq = cell:getGridSquare(tx, ty, lz)
        if targetSq then
            local sq = getCell():getOrCreateGridSquare(targetSq:getX(), targetSq:getY(), targetSq:getZ()) 
            --addTempMarker(sq, true)
            return targetSq:getX(), targetSq:getY(), targetSq:getZ()
        end
    end
    
    local fallbackTx = math.floor(sx - dirX * dist + 0.5)
    local fallbackTy = math.floor(sy - dirY * dist + 0.5)
    local fallbackSq = cell:getGridSquare(fallbackTx, fallbackTy, lz)
    if fallbackSq then
        --addTempMarker(fallbackSq, true)
        return fallbackSq:getX(), fallbackSq:getY(), fallbackSq:getZ()
    end
    
    local ssq = getCell():getOrCreateGridSquare(sx, sy, lz) 
    --addTempMarker(ssq, true)

    return sx, sy, lz
end

function ParadiseZ.doRebound(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    if not ParadiseZ.isZoneEnabled(pl) or ParadiseZ.isOutsideZone(pl) then return end

    local x, y, z = ParadiseZ.getReboundXYZ(pl)
    if not (x and y and z) then return false end
    local ssq = getCell():getOrCreateGridSquare(x, y, z) 
    --addTempMarker(ssq, true)

    if getActivatedMods():contains("phunzones") then
        local car = pl:getVehicle() or nil
        if car then
            local cx, cy, cz = ParadiseZ.getLastCoord()
            ParadiseZ.carTp(pl, car, cx, cy, cz)
            return true
        else
            ParadiseZ.tp(pl, x, y, z)
            return true
        end

        return false
    else
        ParadiseZ.tp(pl, x, y, z)
    end
end

function ParadiseZ.tp(pl, x, y, z)
    pl = pl or getPlayer()
    if not pl then return end
    z = z or 0
    if not (x and y and z) then return end
    ParadiseZ.forceExitCar()
    if luautils.stringStarts(getCore():getVersion(), "42") then
        pl:teleportTo(tonumber(x), tonumber(y), tonumber(z))
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
end

function ParadiseZ.forceExitCar()
    local pl = getPlayer()
	if not pl then return end
	local car = pl:getVehicle()
	if not car then return end
	local seat = car:getSeat(pl)
	car:exit(pl)
    if seat then
        car:setCharacterPosition(pl, seat, "outside")
    end
	pl:PlayAnim("Idle")
	triggerEvent("OnExitVehicle", pl)
    car:updateHasExtendOffsetForExitEnd(pl)
end

function ParadiseZ.carTp(player, vehicle, vx, vy, vz)
    if not vehicle then return end

    local lx, ly, lz = ParadiseZ.getLastCoord()
    if not lx or not ly or not lz then return end

    local cx, cy, cz = vehicle:getX(), vehicle:getY(), vehicle:getZ()
    local dx, dy = cx - lx, cy - ly
    local len = math.sqrt(dx * dx + dy * dy)
    if len == 0 then return end

    dx, dy = dx / len, dy / len
    local dist = 5
    local px = dx * dist
    local py = dy * dist

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
    if not transField then return end

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
end

-----------------------            ---------------------------
function ParadiseZ.initPvP()
    if getActivatedMods():contains("phunzones") then
        if not PhunZones then return end

        getServerOptions():getOptionByName("ShowSafety"):setValue(true)
        getServerOptions():getOptionByName("SafetySystem"):setValue(true)

        getCore():saveOptions();
        -----------------------            ---------------------------
        
        function PhunZones:portPlayer()
            local pl = getPlayer() 
            if string.lower(pl:getAccessLevel()) == "admin" then
                return 
            end
            return ParadiseZ.doRebound(pl)
        end

        function PhunZones:portVehicle(player, vehicle, x, y, z)
            if string.lower(player:getAccessLevel()) == "admin" then
                return 
            end
            return ParadiseZ.carTp(player, vehicle, x, y, z)
        end

        -----------------------            ---------------------------
        

        function PhunZones:ISSafetyPrerender(player)
            return
        end
    
        function PhunZones:updatePlayerUI(playerObj, info, existing)
            local zone = info or playerObj:getModData().PhunZones or {}
            local existing = existing or {}
            PhunZones.ui.welcome.OnOpenPanel(playerObj, zone)
            if self.settings.Widget then
                local panel = PhunZones.ui.widget.OnOpenPanel(playerObj)
                if panel then
                    local data = {
                        zone = {
                            title = zone.title or nil,
                            subtitle = zone.subtitle or nil
                        }
                    }
                    panel:setData(data)
                end
            end
        end
        -----------------------            ---------------------------
        Events[PhunZones.events.OnPhunZonesPlayerLocationChanged].Add(function(pl, zone, oldZone)
            if not isIngameState() then return end
            local isRestrict = ParadiseZ.isPvE(pl)
            local isKoS = zone.pvp or ParadiseZ.isKos(pl)
            if getCore():getDebug() then 
                local str = 'isRestrict '..tostring(isRestrict)..'\n isKoS '..tostring(isKoS)
                print(str)
                pl:addLineChatElement(str)
            end
            if isKoS and isRestrict then
                local adm = string.lower(pl:getAccessLevel()) == "admin" 
                if not adm then
                    ParadiseZ.doRebound(pl)
                end
            end
        end)
        
    end
end
Events.OnCreatePlayer.Add(ParadiseZ.initPvP)

function ParadiseZ.isKos(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    local md = pl:getModData()
    if not md then return false end
    local pz = md.PhunZones
    if not pz then return false end
    return pz.pvp == true
end

function ParadiseZ.isOutsideZone(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    local md = pl:getModData()
    if not md then return false end
    local pz = md.PhunZones
    if not pz then return false end
    return pz.isDefault == true
end
function ParadiseZ.isZoneEnabled(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    local md = pl:getModData()
    if not md then return false end
    local pz = md.PhunZones
    if not pz then return false end
    return pz.enabled == true
end


function ParadiseZ.pvpMode(pl)
    if not isIngameState() then return end
    local plNum = pl:getPlayerNum()
    local data = getPlayerData(plNum)
    if not data then return end

    local safe = pl:getSafety()
    local isEnabled = safe:isEnabled()
    local isKos = ParadiseZ.isKos(pl)
    local isPvE = ParadiseZ.isPvE(pl)
    local isVisible = data.safetyUI:getIsVisible()
    local adm = string.lower(pl:getAccessLevel()) == "admin" 
                
    if isPvE then
        if isVisible then
            data.safetyUI:setVisible(false)
            data.safetyUI:removeFromUIManager()
        end
        
        if isEnabled then 
            safe:toggleSafety()
        end
        return
    end
    
    if not isVisible then
        data.safetyUI:setVisible(true)
        data.safetyUI:addToUIManager()
    end

    if not ParadiseZ.isZoneEnabled(pl) or ParadiseZ.isOutsideZone(pl) then return end
    
    if isKos ~= isEnabled then
        safe:toggleSafety()
    end
end

Events.OnPlayerUpdate.Remove(ParadiseZ.pvpMode)
Events.OnPlayerUpdate.Add(ParadiseZ.pvpMode)



