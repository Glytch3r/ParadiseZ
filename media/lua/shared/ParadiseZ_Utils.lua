ParadiseZ = ParadiseZ or {}

function ParadiseZ.checkDist(pl, sq)
    if not pl or not sq then return end
    local dx = pl:getX() - sq:getX()
    local dy = pl:getY() - sq:getY()
    return round(math.sqrt(dx * dx + dy * dy))
end

function ParadiseZ.isWithinRange(targ, sq, range)
	local dist = targ:DistTo(sq:getX(), sq:getY())
    return dist <= range
end

function ParadiseZ.isClosestPl(pl, zed)
	local plDist = ParadiseZ.checkDist(pl, zed)
	local compare = round(zed:distToNearestCamCharacter())
	if plDist == compare then
		return true
	end
	return false
end

function ParadiseZ.getSprName(obj)
    if not obj then return nil end
    local spr = ParadiseZ.getSpr(obj)
    local sprName = nil
    if spr and spr.getName then 
        sprName = spr:getName()         
    end
    return sprName
end

function ParadiseZ.getSpr(obj)
    if not obj then return nil end
    if not obj.getSprite then return nil end
    local spr = obj:getSprite()
    return spr
end
