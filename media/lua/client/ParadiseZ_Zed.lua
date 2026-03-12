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
function ParadiseZ.ZedReactToScareCrow(zed)
    local targ = zed:getTarget()
    if targ then
        if targ:getVariableBoolean('isScareCrow') == true then
            zed:setTarget(nil)
        end
    end
end
--Events.OnZombieUpdate.Remove(ParadiseZ.ZedReactToScareCrow)
--Events.OnZombieUpdate.Add(ParadiseZ.ZedReactToScareCrow)

function ParadiseZ.getWalkType(zed)
	return tostring(zed:getVariableString("zombieWalkType"))
end
function ParadiseZ.getWalkNum(zed)
	local walk = ParadiseZ.getWalkType(zed)
	return tonumber(walk:match("%d+"))
end

function ParadiseZ.moveToXYZ(zed, x, y, z)
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

function ParadiseZ.findzedID(int)
	local zombies = getCell():getObjectList()
	for i=zombies:size(),1,-1 do
		local zed = zombies:get(i-1)
		if instanceof(zed, "IsoZombie") then
			local zedID=zed:getOnlineID()
			if zedID and zedID == int then return zed end
		end
	end
	return nil
end

function ParadiseZ.setSprinter(zed, num)
	local sandOpt = getSandboxOptions()
	local zSpeed = sandOpt:getOptionByName("ZombieLore.Speed"):getValue()
    num = num or 1
    
	zed:setWalkType("sprint"..tostring(num))
	sandOpt:set("ZombieLore.Speed", 1)
	zed:makeInactive(true)
	zed:makeInactive(false)
	zed:DoZombieStats()
	sandOpt:set("ZombieLore.Speed", zSpeed)
end

function ParadiseZ.isSprinter(zed)
	local walk = ParadiseZ.getWalkType(zed)
	if walk then
		if tostring(walk:contains('sprint')) or luautils.stringStarts(walk, "sprint") then
			return true
		end
	end
	return false
end
function ParadiseZ.isSprintZoneFromSquare(sq)
    if not sq then return false end
    local zoneName = ParadiseZ.getZoneName(sq)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isSprint == true
end

function ParadiseZ.sprinterHandler(zed)   
    local pl = getPlayer() 
    if not pl then return end
    if zed and zed:isAlive() and not ParadiseZ.isSprinter(zed) then
        if ParadiseZ.isClosestPl(pl, zed) then
            ParadiseZ.setSprinter(zed, ZombRand(1,6))
        end
    end
end
Events.OnZombieUpdate.Add(ParadiseZ.sprinterHandler)

