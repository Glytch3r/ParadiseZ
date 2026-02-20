ParadiseZ = ParadiseZ or {}

function ParadiseZ.getSpr(obj)
	if not obj then return nil end
    if not spr.getSprite then return nil end
	local spr = obj:getSprite()
	return spr
end

function ParadiseZ.getSprName(obj)
    if not obj then return nil end
    local spr = ParadiseZ.getSpr(obj)
    sprName = nil
    if spr and spr.getName then 
        sprName = spr:getName()         
    end
    return sprName
end

function ParadiseZ.checkDist(pl, sq)
	local dist = pl:DistTo(sq:getX(), sq:getY())
    return math.floor(dist)
end


function ParadiseZ.isWithinRange(targ, sq, range)
	local dist = targ:DistTo(sq:getX(), sq:getY())
    return dist <= range
end
