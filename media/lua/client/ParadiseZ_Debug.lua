
ParadiseZ = ParadiseZ or {}
-----------------------            ---------------------------

function ParadiseZ.coinFlip()
	return ZombRand(2) == 0
end

function ParadiseZ.getRandOutfit()
	local maleOutfits = getAllOutfits(false)
	local femaleOutfits = getAllOutfits(true)

	local pool = {}

	for i=0, maleOutfits:size()-1 do
		local fit = maleOutfits:get(i)
		pool[#pool+1] = fit
	end

	for i=0, femaleOutfits:size()-1 do
		local fit = femaleOutfits:get(i)
		if not maleOutfits:contains(fit) then
			pool[#pool+1] = fit
		end
	end

	if #pool == 0 then return nil end

	local fit = pool[ZombRand(#pool) + 1]
	ParadiseZ.echo(tostring(fit))
	return tostring(fit)
end

function ParadiseZ.spawnZedEvent(x, y, z, fit, pop)
	local pl = getPlayer()
	x = x or pl:getX()
	y = y or pl:getY()
	z = z or pl:getZ()
    pop = pop or 50
	local flip = ParadiseZ.coinFlip()
	for i=1, pop do
		local toSpawn = fit or ParadiseZ.getRandOutfit()

		SendCommandToServer(string.format(
			"/createhorde2 -x %d -y %d -z %d -count %d -radius %d -crawler %s -isFallOnFront %s -isFakeDead %s -knockedDown %s -health %s -outfit %s",
			x, y, z,
			1,
			1,
			tostring(false),
			tostring(flip),
			tostring(flip),
			tostring(flip),
			tostring(2),
			toSpawn
		))
	end
end
--  ParadiseZ.spawnZedEvent(x, y, z, fit, 1)

function ParadiseZ.killZeds(x, y, z, radius)
    radius = radius or 15
    local pl = getPlayer()
    x = x or pl:getX()
    y = y or pl:getY()
    z = z or pl:getZ()
    local cell = getCell()
    for xDelta = -radius, radius do
        for yDelta = -radius, radius do
            local sq = cell:getGridSquare(x + xDelta, y + yDelta, z)
            if sq then
                for i = sq:getMovingObjects():size(), 1, -1 do
                    local zed = sq:getMovingObjects():get(i - 1)
                    if zed and instanceof(zed, "IsoZombie") then
                        zed:changeState(ZombieOnGroundState.instance())
                        zed:setAttackedBy(cell:getFakeZombieForHit())
                        zed:becomeCorpse()
                    end
                end
            end
        end
    end
end

function ParadiseZ.delZeds(x, y, z, radius)
	local pl = getPlayer()
	radius = radius or 15
	x = x or pl:getX()
	y = y or pl:getY()
	z = z or pl:getZ()

	local r = radius + 1
	if isClient() then
		SendCommandToServer(string.format("/removezombies -x %d -y %d -z %d -radius %d", x, y, z, r))
		return
	end
	for sx = x - r, x + r do
		for sy = y - r, y + r do
			local sq = getCell():getGridSquare(sx, sy, z)
			if sq then
				for i = sq:getMovingObjects():size(), 1, -1 do
					local obj = sq:getMovingObjects():get(i - 1)
					if instanceof(obj, "IsoZombie") then
						obj:removeFromWorld()
						obj:removeFromSquare()
					end
				end
			end
		end
	end
end
function ParadiseZ.countZed(x, y, z, radius)
	local count = 0
    radius = radius or 15
    local pl = getPlayer()
    x = x or pl:getX()
    y = y or pl:getY()
    z = z or pl:getZ()
    local cell = getCell()
    for xDelta = -radius, radius do
        for yDelta = -radius, radius do
            local sq = cell:getGridSquare(x + xDelta, y + yDelta, z)
            if sq then
                for i = sq:getMovingObjects():size(), 1, -1 do
                    local zed = sq:getMovingObjects():get(i - 1)
                    if zed and instanceof(zed, "IsoZombie") then
						count = count + 1							
                    end
                end
            end
        end
    end
	ParadiseZ.echo(tostring(count))
	return count
end
function ParadiseZ.countDead(x, y, z, radius)
	local pl = getPlayer()
	radius = radius or 15
	x = x or pl:getX()
	y = y or pl:getY()
	z = z or pl:getZ()

	local r = radius + 1
	local count = 0

	local cell = getCell()
	for sx = x - r, x + r + 1 do
		for sy = y - r, y + r + 1 do
			if IsoUtils.DistanceTo(x, y, sx + 0.5, sy + 0.5) <= r then
				local sq = cell:getGridSquare(sx, sy, z)
				if sq then
					local list = sq:getStaticMovingObjects()
					for i = 0, list:size() - 1 do
						if instanceof(list:get(i), "IsoDeadBody") then
							count = count + 1
						end
					end
				end
			end
		end
	end
	ParadiseZ.echo(tostring(count))
	return count
end
function ParadiseZ.delBodies(x, y, z, radius)
	local pl = getPlayer()
	radius = radius or 15
	x = x or pl:getX()
	y = y or pl:getY()
	z = z or pl:getZ()

	local r = radius + 1
	if isClient() then
		SendCommandToServer(string.format("/removezombies -x %d -y %d -z %d -radius %d -clear true", x, y, z, r))
		return
	end
	local cell = getCell()
	for sx = x - r, x + r + 1 do
		for sy = y - r, y + r + 1 do
			if IsoUtils.DistanceTo(x, y, sx + 0.5, sy + 0.5) <= r then
				local sq = cell:getGridSquare(sx, sy, z)
				if sq then
					local list = sq:getStaticMovingObjects()
					local bodies = {}
					for i = 0, list:size() - 1 do
						local obj = list:get(i)
						if instanceof(obj, "IsoDeadBody") then
							bodies[#bodies + 1] = obj
						end
					end
					for i = 1, #bodies do
						sq:removeCorpse(bodies[i], false)
					end
				end
			end
		end
	end
end
-----------------------            ---------------------------


function ParadiseZ.runSpawnCycle(x, y, z, duration, rest, population, rounds, rad)

	local pl = getPlayer()
	rad = rad or 15
	x = x or pl:getX()
	y = y or pl:getY()
	z = z or pl:getZ()

	
	local sq = getCell():getGridSquare(sx, sy, z)

	local sec = duration * 60
	local rest = rest * 60
	local wave = population / rounds
	local toSpawn = wave
	population = population - wave
	local roundTime = sec+rest/rounds
	local interval = sec+rest/rounds

	getSoundManager():PlayWorldSound('ZombieSurprisedPlayer', sq, 0, 5, 5, false)

	ParadiseZ.spawnZedEvent(x, y, z, nil, wave)
	for i = 1, rounds do

		ParadiseZ.spawnZedEvent(x, y, z, nil, toSpawn)
		
		ParadiseZ.pause(roundTime, function()
			ParadiseZ.delZeds(x, y, z, rad)
			local remnants = ParadiseZ.countDead(x, y, z, rad)
			toSpawn = wave + wave - remnants
		end)
		local breakTime = roundTime + rest
		ParadiseZ.pause(breakTime, function()
			ParadiseZ.delBodies(x, y, z, rad)
		end)
		roundTime = breakTime + interval

	end
end

--[[ 

function ParadiseZ.runSpawnCycle(x, y, z, clearX, clearY, clearZ, clearRadius, fixedSpawn, startFit, fits, mult)
	local sq = getCell():getOrCreateGridSquare(x, y, z)

	local t = mult
	local toSpawn = fixedSpawn
	local count = 0

	getSoundManager():PlayWorldSound('ZombieSurprisedPlayer', sq, 0, 5, 5, false)
	ParadiseZ.spawnZedEvent(x, y, z, startFit, toSpawn)

	for i = 1, #fits do
		ParadiseZ.pause(t - 120, function()
			ParadiseZ.delZeds(clearX, clearY, clearZ, clearRadius)
			count = ParadiseZ.countDead(clearX, clearY, clearZ, clearRadius)
			ParadiseZ.pause(2, function()
				ParadiseZ.delBodies(clearX, clearY, clearZ, clearRadius)
			end)
		end)

		local sub = fixedSpawn - count
		toSpawn = fixedSpawn + sub
		local fit = fits[i]

		ParadiseZ.pause(t, function()
			getSoundManager():PlayWorldSound('ZombieSurprisedPlayer', sq, 0, 5, 5, false)
			ParadiseZ.spawnZedEvent(x, y, z, fit, toSpawn)

		end)

		t = t + mult
		count = 0
	end
end

function ParadiseZ.triggerGauntlet()
	ParadiseZ.runSpawnCycle(
		8311, 6002, 0,
		8299, 6021, 0, 30,
		200,
		"Doctor",
		{
			"Farmer",
			"Cyclist",
			"Bedroom",
			"Bathrobe",
			"Camper",
		},
		480
	)
end

 ]]
--[[ 
local sq = getCell():getOrCreateGridSquare(8311, 6002, 0) 
local fit = "Doctor"
local toSpawn = 200
local fixedSpawn = 200

ParadiseZ.spawnZedEvent(8311, 6002, 0, fit, toSpawn)  
getSoundManager():PlayWorldSound('ZombieSurprisedPlayer', sq, 0, 5, 5, false);

local mult = 480 
local t = 480
local count = 0
ParadiseZ.pause(t-120, function()   
	ParadiseZ.delZeds(8299, 6021, 0,  30)
	count = ParadiseZ.countDead(8299, 6021, 0, 30)	
	ParadiseZ.pause(2, function()   
		ParadiseZ.delBodies(8299, 6021, 0,  30)		
	end)   
end)
local sub = fixedSpawn - count
toSpawn = fixedSpawn + sub
fit = "Farmer"
t = t + mult
ParadiseZ.pause(t, function()        
	getSoundManager():PlayWorldSound('ZombieSurprisedPlayer', sq, 0, 5, 5, false);
    ParadiseZ.spawnZedEvent(8311, 6002, 0, fit, toSpawn)  
end)
count = 0
ParadiseZ.pause(t-120, function()      
	
	count = ParadiseZ.countDead(8299, 6021, 0, 30)	
	ParadiseZ.pause(2, function()   
		ParadiseZ.delBodies(8299, 6021, 0,  30)		
	end)   
end)

sub = fixedSpawn - count
toSpawn = fixedSpawn + sub
fit = "Cyclist"
t = t + mult
ParadiseZ.pause(t, function()        
	getSoundManager():PlayWorldSound('ZombieSurprisedPlayer', sq, 0, 5, 5, false);
    ParadiseZ.spawnZedEvent(8311, 6002, 0, fit, 200)  
end)

fit = "Bedroom"

fit = "Bathrobe"

fit = "Camper"

-----------------------            ---------------------------
t = t + 300
ParadiseZ.pause(t, function()        
	ParadiseZ.delZeds(8309, 6000, 0,  60)
end)

t = t + 180
ParadiseZ.pause(t, function()        
	ParadiseZ.delBodies(8309, 6000, 0,  60)
end)

-----------------------            ---------------------------
]]


--[[ 
    ISWorldMap.ShowWorldMap(0)
    ISFastTeleportMove.cheat = true
    pl:setBuildCheat(true)

	SendCommandToServer("/setaccesslevel Glytch3r admin")
]]
function ParadiseZ.getMidPoint(x1, y1, x2, y2)
    local midX = (x1 + x2) / 2
    local midY = (y1 + y2) / 2
    return midX, midY
end


-----------------------            ---------------------------
function ParadiseZ.echo(var, isClip)
	var = tostring(var)
	local pl = getPlayer() 
	if pl then
		pl:addLineChatElement(var)
	end
	if not getCore():getDebug() then return end

	print(var)
	if isClip then
		Clipboard.setClipboard(var);
	end
end

-----------------------            ---------------------------
--[[ 
function whereami()
	local pl = getPlayer(); if not pl then return end
	local whvarereVar = math.floor(pl:getX()) ..', '.. math.floor(pl:getY()) ..', '.. math.floor(pl:getZ());
	ParadiseZ.echo(var, true)
end
 ]]
-----------------------            ---------------------------

function ParadiseZ.CheckSafetyHook() 
    local pl = getPlayer() 
    if getCore():getDebug() then 
        local msg = 'Safety Hooked:' .. tostring(ParadiseZ.CheckSafetyHook)
		ParadiseZ.echo(msg, true)   
    end
end


function ParadiseZ.CheckSafety()
    local pl = getPlayer() 
    if getCore():getDebug() then 
        local isEnabled = pl:getSafety():isEnabled()
        local msg = tostring("Safety Toggled: "..tostring(isEnabled))
		ParadiseZ.echo(msg, true)   
    end
end

function ParadiseZ.CheckCanToggle()
    local pl = getPlayer() 
    if getCore():getDebug() then 
        local isCanToggle =  ParadiseZ.isCanToggle(pl)
        local msg = tostring("Can Toggle: "..tostring(isCanToggle))
		ParadiseZ.echo(msg, true)   
    end
end

function ParadiseZ.CheckLife()
    local pl = getPlayer() 
    if getCore():getDebug() then 	
		local msg = getPlayer():getModData()['LifePoints'] or 100
		ParadiseZ.echo(msg, true)   
    end
end



-----------------------            ---------------------------
function ParadiseZ.die()
	getPlayer():Kill(nil)
end

function ParadiseZ.boom()
    local sq = ParadiseZ.getPointer()
    if not sq then return end
	local args = { x = sq:getX(), y = sq:getY(), z = sq:getZ() }
	sendClientCommand(getPlayer(), 'object', 'addExplosionOnSquare', args)
end



function ParadiseZ.setSprCursor(sprName)
	local pl = getPlayer()
	local cursor = ISBrushToolTileCursor:new(sprName, sprName, pl)
	getCell():setDrag(cursor, pl:getPlayerNum())
end


function ParadiseZ.addTempMarker(sq)
	local pl = getPlayer() 
	if not pl then return end
	sq = sq or pl:getSquare() 

	if sq == nil then 
		sq = pl:getSquare() 
	end
	if sq then	
		if not ParadiseZ.tempPointer then
			ParadiseZ.tempPointer = getWorldMarkers():addPlayerHomingPoint(getPlayer(), sq:getX(), sq:getY(), "arrow_triangle", 1, 1, 1, 1, true, 20);
			timer:Simple(5, function()
				ParadiseZ.tempPointer:remove()
				ParadiseZ.tempPointer = nil
			end)
		end
		if not ParadiseZ.tempMark1 then
			ParadiseZ.tempMark1  = getWorldMarkers():addGridSquareMarker("circle_center", "circle_only_highlight", sq, 1, 1, 1, true, 0.75);
			timer:Simple(5, function()
				ParadiseZ.tempMark1:remove()
				ParadiseZ.tempMark1 = nil
			end)
		end

		if not ParadiseZ.tempMark2 then
			ParadiseZ.tempMark2 = getWorldMarkers():addGridSquareMarker("circle_center", "circle_only_highlight", sq, 1, 1 , 1, true, 0.75);
			timer:Simple(3, function()
				ParadiseZ.tempMark2:remove()
				ParadiseZ.tempMark2 = nil
			end)
		end

		if not ParadiseZ.tempMark3 then
			ParadiseZ.tempMark3 = getWorldMarkers():addGridSquareMarker("circle_center", "circle_only_highlight", sq, 1, 1, 1, true, 0.75);
			timer:Simple(2, function()
				ParadiseZ.tempMark3:remove()
				ParadiseZ.tempMark3 = nil
			end)
		end
	end
end

function ParadiseZ.testDmg(targ, dmg, pushedDir)
    dmg = dmg or 15
    dmg = math.min(100, dmg)
    targ = targ or getPlayer() 
    if not targ then return end
    local md = targ:getModData()
    md.LifePoints = math.max(0, md.LifePoints - dmg)
    md.LifeBarFlash = 0.4
	
    local percent = SandboxVars.ParadiseZ.pvpStaggerChance or 34
    if ParadiseZ.doRoll(percent) then
		pushedDir = pushedDir or 'pushedbehind'
--[[         targ:setBumpType(pushedDir)
        targ:setVariable("BumpFall", true) ]]
        --targ:setVariable("BumpFallType", "pushedbehind")
		sendClientCommand("ParadiseZ", "knockDownPl", { targId = targ:getOnlineID(), pushedDir = pushedDir })

    end

--[[     local recoverHP = dmg / 3
    for i = 2, 6, 2 do
        timer:Simple(i, function()
            md.LifePoints = math.min(100, md.LifePoints + recoverHP)
        end)
    end ]]
end


function ParadiseZ.isTempMarkerActive()
	if ParadiseZ.isTempMarkerActive ~= nil or ParadiseZ.tempMark1 ~= nil then
		return true
	end
	return false
end
function ParadiseZ.getCar()
	local car = nil;
	local pl = getPlayer();
	if pl:getVehicle() then
		car = pl:getVehicle();
	elseif pl:getNearVehicle() then
		car = pl:getNearVehicle();
	elseif pl:getUseableVehicle() then
		car = pl:getUseableVehicle();
	end

	return car
end

function ParadiseZ.pickCar(sq)
	local car = IsoObjectPicker.Instance:PickVehicle(getMouseXScaled(), getMouseYScaled()) 
	if car ~= nil then return car end

	sq = sq or ParadiseZ.getPointer()
	if sq then car = sq:getVehicleContainer() end
	return car
end


function ParadiseZ.getPointer()
	if not isIngameState() then return nil end
	local sq = nil
	local zPos = getPlayer():getZ() or 0
	local mx, my = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), zPos)
	if mx and my then
		local sq = getCell():getGridSquare(math.floor(mx), math.floor(my), zPos)
		--if sq and sq:getFloor() then sq:getFloor():setHighlighted(true); return sq end
		if not sq then return nil end
		local flr = sq:getFloor()
		if flr then
			flr:setHighlighted(true, true)
		end
		return sq ;
	end
	return nil
end
