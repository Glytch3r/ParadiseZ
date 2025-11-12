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
            zed:getTarget(nil)
        end
    end
end
Events.OnZombieUpdate.Remove(ParadiseZ.ZedReactToScareCrow)
Events.OnZombieUpdate.Add(ParadiseZ.ZedReactToScareCrow)

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


function ParadiseZ.zHit(zed, pl, part, wpn)
    if pl and pl == getPlayer() and pl:getVariableBoolean('isScareCrow') == true then
        ParadiseZ.setSprinter(zed, ZombRand(1, 3))
        local zedID=zed:getOnlineID()
        --sendClientCommand('ParadiseZ', 'knockDownZed', {zedID = zedID})
        zed:setSkeleton(true)
--[[ 
        zed:changeState(ZombieOnGroundState.instance())
        zed:setAttackedBy(getCell():getFakeZombieForHit())
        zed:becomeCorpse() ]]
    end
end
Events.OnHitZombie.Add(ParadiseZ.zHit)
