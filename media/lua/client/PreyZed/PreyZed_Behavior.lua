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

function PreyZed.fleeFromPl(zed, pl)
    local zx, zy, zz = round(zed:getX()), round(zed:getY()), zed:getZ() or 0
    local px, py = pl:getX(), pl:getY()
    local dx = zx - px
    local dy = zy - py
    local len = math.sqrt(dx * dx + dy * dy)
    if len == 0 then return end
    dx = dx / len
    dy = dy / len
    for _ = 1, 10 do
        local scatter = PreyZed.fleeDist * 0.3
        local nx = round(zx + dx * PreyZed.fleeDist + ZombRand(-scatter, scatter))
        local ny = round(zy + dy * PreyZed.fleeDist + ZombRand(-scatter, scatter))
        local sq = getCell():getOrCreateGridSquare(nx, ny, zz)
        if sq and PreyZed.isWalkable(sq) then
            zed:setTarget(nil)
           
            PreyZed.moveToXYZ(zed, nx, ny, zz)
            return
        end
    end
end
-----------------------            ---------------------------

function PreyZed.moveToXYZ(zed, x, y, z)
    if not zed or not x or not y or not z then return end
    local pl = getPlayer()
    if not pl then return end
   
    local sq = getCell():getOrCreateGridSquare(x, y, z)
    if not sq then return end
    if zed:getSquare() ~= sq then
        zed:pathToLocation(sq:getX(), sq:getY(), sq:getZ())
    end
    if sq:getZ() == zed:getSquare():getZ() then
        zed:setVariable("bPathfind", true)
        zed:setVariable("bMoving", false)
    end
end


function PreyZed.moveRandLoc(zed)
    
    local TravelLimit =  50
    local x, y, z = round(zed:getX()),  round(zed:getY()),  zed:getZ() or 0
    x = ZombRand(x - TravelLimit, x + TravelLimit)
    y = ZombRand(y - TravelLimit, y + TravelLimit)
    local sq = getCell():getOrCreateGridSquare(x, y, z) 
    if sq then
        PreyZed.moveToXYZ(zed, x, y, z)   
    else
        PreyZed.moveRandLoc(zed)
    end
end
function PreyZed.Handler(zed)
    if not zed then return end
    local isPrey = PreyZed.isPrey(zed)
    local pl = getPlayer() 
    local targ = zed:getTarget() 
    
    if isPrey then   
        if ParadiseZ.isClosestPl(pl, zed) and pl then         
            if targ and zed:isTargetVisible() then 
                zed:setUseless(true)
                zed:setTarget(nil)
            else
                if zed:isUseless() then
                    zed:setUseless(false)
                end
            end       
            if zed:getModData()['PreyZed_Move'] == nil then                  
                zed:getModData()['PreyZed_Move'] = true
                PreyZed.moveRandLoc(zed)  
                timer:Simple(2, function() 
                    zed:getModData()['PreyZed_Move'] = nil     
                    zed:setUseless(false)
                end)
            end 
        end
    end

end

Events.OnZombieUpdate.Remove(PreyZed.Handler)
Events.OnZombieUpdate.Add(PreyZed.Handler)
-----------------------            ---------------------------
--[[ 
function PreyZed.fleeFromPl(zed, pl)
    local zx, zy, zz = round(zed:getX()), round(zed:getY()), zed:getZ() or 0
    local px, py = pl:getX(), pl:getY()
    local dx = zx - px
    local dy = zy - py
    local len = math.sqrt(dx * dx + dy * dy)
    if len == 0 then        
        return
    end
    dx = dx / len
    dy = dy / len
    for _ = 1, 10 do
        local scatter = PreyZed.fleeDist * 0.3
        local nx = round(zx + dx * PreyZed.fleeDist + ZombRand(-scatter, scatter))
        local ny = round(zy + dy * PreyZed.fleeDist + ZombRand(-scatter, scatter))
        local sq = getCell():getOrCreateGridSquare(nx, ny, zz)
        if sq and PreyZed.isWalkable(sq) then
            PreyZed.moveToXYZ(zed, nx, ny, zz)
            return
        end
    end    
end ]]

function PreyZed.turnAround(targ)
	local x = targ:getX()
	local y = targ:getY()
	local offsetX = targ:getForwardDirection():getX() * 2
	local offsetY = targ:getForwardDirection():getY() * 2
	targ:faceLocation(x - offsetX, y - offsetY)
end

function PreyZed.getNearBldg(zed)
    local nearSq
    local nearDist = math.huge

    local sq = zed:getSquare()
    if not sq then
        return nil
    end
    local gridSize = 30
    for dx = -gridSize, gridSize do
        for dy = -gridSize, gridSize do
            local targSq = getCell():getGridSquare(sq:getX() + dx, sq:getY() + dy, sq:getZ())
            if targSq and targSq:isInARoom() and not targSq:isOutside() then
                local dist = IsoUtils.DistanceTo(sq:getX(), sq:getY(), targSq:getX(), targSq:getY())
                if dist < nearDist then
                    nearDist = dist
                    nearSq = targSq
                end
            end
        end
    end
    return nearSq:getBuilding()
end

function PreyZed.BreakBlocker(zed)
    local obj = zed:getThumpTarget()
    if obj then

        if instanceof(obj, "IsoDoor") or (instanceof(obj, "IsoThumpable") and obj:isDoor()) then
            doSledge(obj)

            return true
        elseif instanceof(obj, "IsoWindow") or (instanceof(obj, "IsoThumpable") and obj:isWindow()) then

            doSledge(obj)

            return true
        end
    end
    return false
end

function PreyZed.goIndoor(zed)
    if tonumber(PreyZed.getZedCognition(zed)) ~= 1 then
        PreyZed.setCognition(zed)
    end
    if  zed:isUseless() then
        zed:setUseless(false)
    end

    local targSq=PreyZed.getNearBldg(zed):getRandomRoom():getRandomSquare()
    if targSq then

        local x,y,z = round(targSq:getX()), round(targSq:getY()), targSq:getZ()
        zed:pathToLocationF(x, y, z)
        if not targSq:TreatAsSolidFloor() and targSq:getZ() == zed:getCurrentSquare():getZ() then
            zed:setVariable("bPathfind", false)
            zed:setVariable("bMoving", true)
        end

        if getCore():getDebug() then
            zed:addLineChatElement(tostring("Pathfinding"))
        end

        if PreyZed.BreakBlocker(zed) then
            zed:getPathFindBehavior2():pathToLocation(x,y,z)
            zed:pathToSound(x, y ,z);
            if getCore():getDebug() then
                zed:addLineChatElement(tostring("Pathfinding 2"))
            end
        end


        

        if targSq == zed:getCurrentSquare()  then
            zed:addLineChatElement(tostring("Resting"))
            if not zed:isUseless() then
                zed:setUseless(true)
            end
        end
    end

end

function PreyZed.isSameRoom(zed, targ)
    if zed and targ then
        local targSq = targ:getSquare();
        local sq = zed:getSquare();
        if targSq and sq and not (targ:isInvisible() or targ:isGhostMode()) then
           return sq:getRoomID() == targSq:getRoomID()
        end
    end
    return false
end
-----------------------            ---------------------------

function PreyZed.isWalkable(sq)
    if not sq then return false end
    if sq:isSolid() then return false end
    if sq:isSolidTrans() then return false end
    if sq:Is(IsoFlagType.water) then return false end
    --if not square:isNotBlocked(false) then return false end
    return true
end

function PreyZed.stopWalking(targ)
	targ:getPathFindBehavior2():reset();
end



function PreyZed.isStepped(zed)
	return zed:isBeingSteppedOn()
end



function PreyZed.setFakeDead(zed, bool)
	if bool == nil then bool = false end
	if bool then
		zed:knockDown(bool)
		zed:setFakeDead(bool);
		zed:setForceFakeDead(bool);
		zed:Hit(nil, getPlayer(), 0, bool, 0)
	else
		PreyZed.setStand(zed)
	end
	zed:setShootable(not bool)
	zed:setCollidable(not bool)
end

function PreyZed.isShouldStand(zed)
	if not zed:isBeingSteppedOn() then
		if zed:isCanWalk() then return true end
		if zed:isFakeDead() then return true end
		if zed:isForceEatingAnimation() then return true end
		if zed:isOnFloor() then return true end
		if zed:isCrawling() then return true end
		if zed:isUseless() then return true end
		if zed:isSitAgainstWall() then return true end
	end
    return false
end

function PreyZed.setStand(zed)
	zed:setOnFloor(false);
    if not zed:isCanWalk() then
        zed:setCanWalk(true)
    end
    if zed:isFakeDead() or zed:isCurrentState(FakeDeadZombieState.instance())  then
        zed:setFakeDead(false)
		zed:setForceFakeDead(false);
    end
    if zed:isForceEatingAnimation() then
        zed:setForceEatingAnimation(false)
    end
    if zed:isSitAgainstWall() then
        zed:setSitAgainstWall(false)
    end
    if zed:isCrawling() then
        zed:toggleCrawling()
		zed:setCrawler(false)
    end
	if zed:isOnFloor() then
		zed:knockDown(false)
		zed:changeState(ZombieGetUpState.instance())
	end
	if zed:isUseless() then
		zed:setUseless(false)
	end

end


function PreyZed.checkWalkableSq()
	local pl = getPlayer()
	local plSq = pl:getSquare()
	local rmSqs = plSq:getRoom():getSquares()
	if not pl:isOutside() then
		for i=0, rmSqs:size()-1 do
			local rmSq = rmSqs:get(i)
			local tab = {
				rmSq:getN(),
				rmSq:getS(),
				rmSq:getE(),
				rmSq:getW(),
			}
			for _, testSq in ipairs(tab) do
				if testSq  then
					local isGood = false
					if PreyZed.isWalkable(testSq) then
						isGood = true
					end
				end
			end
		end
	end
end
