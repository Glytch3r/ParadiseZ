
ParadiseZ = ParadiseZ or {}


--[[ 
    ISWorldMap.ShowWorldMap(0)
    ISFastTeleportMove.cheat = true
    pl:setBuildCheat(true)

	SendCommandToServer("/setaccesslevel Glytch3r admin")
]]

function whereami()
	local pl = getPlayer(); if not pl then return end
	local whereVar = math.floor(pl:getX()) ..', '.. math.floor(pl:getY()) ..', '.. math.floor(pl:getZ());
	Clipboard.setClipboard(whereVar);
	print('Clipboard Saved: ' ..whereVar)
	pl:Say(tostring(whereVar))
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
	if sq == nil then sq = getPlayer():getSquare()  end
	if sq then
		local mark  = getWorldMarkers():addGridSquareMarker("circle_center", "circle_only_highlight", sq, 1, 0, 0, true, 0.75);
		timer:Simple(6, function()
			mark:remove()
			mark = nil
		end)
		local mark2  = getWorldMarkers():addGridSquareMarker("circle_center", "circle_only_highlight", sq, 1, 0.5, 0.5, true, 0.75);
		timer:Simple(4, function()
			mark2:remove()
			mark2 = nil
		end)
		local mark3  = getWorldMarkers():addGridSquareMarker("circle_center", "circle_only_highlight", sq, 1, 1, 1, true, 0.75);
		timer:Simple(2, function()
			mark3:remove()
			mark3 = nil
		end)
	end
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
