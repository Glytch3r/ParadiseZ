
ParadiseZ = ParadiseZ or {}


-----------------------            ---------------------------
function ParadiseZ.dbgKeys(key)
    if not getCore():getDebug() then return end
	local pl = getPlayer()
	if not pl then return end
	
	if (key == getCore():getKey("Equip/Turn On/Off Light Source")) then
		local pl = getPlayer()
        local sq = ParadiseZ.getPointer()
		if sq and sq:getFloor() then
			sq:getFloor():setHighlighted(true)
			pl:faceLocation(sq:getX(), sq:getY())
			pl:setX(sq:getX());
			pl:setY(sq:getY());
			pl:setZ(sq:getZ());
			pl:getCell():addLamppost(IsoLightSource.new(pl:getX(), pl:getY(), pl:getZ(), 255, 255, 255, 255))
		end

	end
--[[ 
	if key == getCore():getKey("ReloadWeapon") then
        local sq = ParadiseZ.getPointer()
        if sq then

            local car = ParadiseZ.getCar() or ParadiseZ.pickCar(sq)
            if car then
                local name = car:getScript():getFullName()
                if isClient() then	sendClientCommand(pl, "vehicle", "remove", { vehicle = car:getId() }) end
                car:permanentlyRemove()
                pl:Say('car despawned: '..tostring(name))
                print(car:getId())
            end
        end
    end
 ]]
	return key
end
Events.OnKeyPressed.Remove(ParadiseZ.dbgKeys);
Events.OnKeyPressed.Add(ParadiseZ.dbgKeys);

--[[ 


local count = 0
local rad = 80
local pl = getPlayer()
local cell = pl:getCell()
local x, y, z = pl:getX(), pl:getY(), pl:getZ()
for xDelta = -rad, rad do
	for yDelta = -rad, rad do
		local sq = cell:getOrCreateGridSquare(x + xDelta, y + yDelta, z)
        local car = ParadiseZ.pickCar(sq)
        if car then
			local name = car:getScript():getFullName()
			if isClient() then	sendClientCommand(pl, "vehicle", "remove", { vehicle = car:getId() }) end
			car:permanentlyRemove()
			pl:Say('car despawned: '..tostring(name))
			print(car:getId())
		end
	end
end


local whereVar = math.floor(getPlayer():getX()) ..', '.. math.floor(getPlayer():getY()) ..', '.. math.floor(getPlayer():getZ()); Clipboard.setClipboard(whereVar); print('Clipboard Saved: ' ..whereVar) 
]]