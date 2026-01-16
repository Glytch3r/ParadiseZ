
ParadiseZ = ParadiseZ or {}
-----------------------            ---------------------------

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
	print(var)
	if isClip then
		Clipboard.setClipboard(var);
	end
end

-----------------------            ---------------------------

function whereami()
	local pl = getPlayer(); if not pl then return end
	local whvarereVar = math.floor(pl:getX()) ..', '.. math.floor(pl:getY()) ..', '.. math.floor(pl:getZ());
	ParadiseZ.echo(var, true)
end

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
