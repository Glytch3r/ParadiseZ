ParadiseZ = ParadiseZ or {}

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

function ParadiseZ.roundN(v, n)
    local m = 10 ^ (n or 3)
    return math.floor(v * m + 0.5) / m
end

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


function ParadiseZ.doRoll(percent)
    percent = percent or 20
    if percent == 100 then return true end
    if percent == 0 then return false end
	return percent >= ZombRand(1, 101)
end

