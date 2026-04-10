ParadiseZ = ParadiseZ or {}

ParadiseZ.ZoneColorList = {
    HQ = { r = 0, g = 0, b = 1 },
    Outside = { r = 1, g = 0.4, b = 0 },
    Zone = { r = 1, g = 1, b = 1 },
    NonPvp = { r = 0, g = 1, b = 0 },
    PvP = { r = 0.9, g = 0.2, b = 0.2 },
    Blocked = { r = 0.13, g = 0.13, b = 0.13 },
    Protected = { r = 0.84, g = 0.76, b = 0.67 },
    Radiation = { r = 1, g = 1, b = 1 },
    Hunt = { r = 1, g = 0, b = 0 },
    Blaze = { r = 1, g = 0, b = 0 },
    Frost = { r = 0.5, g = 0.4, b = 1 },
    Bomb = { r = 1, g = 0, b = 0 },
    MineField = { r = 1, g = 0, b = 0 },
    NoCamp = { r = 0.7, g = 0.7, b = 0.7 },
    NoFire = { r = 0.8, g = 0.8, b = 0.8 },
    Cage = { r = 0.7, g = 0.7, b = 0.7 },
    Party = { r = 1, g = 1, b = 0.6 },
    Rally = { r = 0, g = 1, b = 0 },
    Special = { r = 0.9, g = 0.4, b = 0.9 },
    Trade = { r = 0, g = 1, b = 0 },
    Sprint = { r = 1, g = 0.7, b = 0.7 },
}
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

function ParadiseZ.getColor(z)
    if z.isBomb or z.isMine or z.isBlaze or z.isSprint or z.isKos or z.isRad then
        return 1,0,0,0.2
    end

    if z.isFrost or z.isCage or z.isBlocked then
        return 1,1,0,0.2
    end
    
    if z.isSafe or z.isPvE or z.isHunt or z.isNoCamp or z.isParty or z.isRally or z.isSpecial or z.isTrade or z.isNoFire then
        return 0,0,1,0.2
    end

    return 1,1,1,0.2
end

function ParadiseZ.isModActive(name)
    for i = 0, getActivatedMods():size()-1 do
        local mod = getActivatedMods():get(i):gsub("^\\+", ""):lower()
        if mod == name:lower() then
            return true
        end
    end
    return false
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

