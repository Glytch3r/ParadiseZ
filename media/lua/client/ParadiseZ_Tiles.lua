
ParadiseTiles = ParadiseTiles or {}
function ParadiseTiles.getRandFloat()
    return ZombRand(0, 100+1)/100
end
function ParadiseTiles.doRoll(percent)
	if percent <= 0 then return false end
	if percent >= 100 then return true end
	return percent >= ZombRand(1, 101)
end
function ParadiseTiles.getSprName(obj) 
    if not obj then return nil end
    if not obj.getSprite then return nil end
    local spr = obj:getSprite()
    return spr and spr:getName() or nil
end
function ParadiseTiles.getSprNum(sprName)
    if not sprName then return nil end
    local num = string.match(sprName, "(%d+)$")
    return num and tonumber(num) or nil
end

function ParadiseTiles.doSledge(obj)
    if isClient() then
        sledgeDestroy(obj)
    else
        local sq = obj:getSquare()
        if sq then
            sq:RemoveTileObject(obj);
            sq:getSpecialObjects():remove(obj);
            sq:getObjects():remove(obj);
            sq:transmitRemoveItemFromSquare(obj)
        end
    end
end
-----------------------            ---------------------------
-----------------------            ---------------------------

ParadiseTiles.List = {
   ["ParadiseTiles_48"]=true,
   ["ParadiseTiles_49"]=true,
   ["ParadiseTiles_50"]=true,
   ["ParadiseTiles_51"]=true,
}
ParadiseTiles.Frames = {  
   ["48"]="49",
   ["49"]="50",
   ["50"]="51",
   ["51"]="49",
}

local ticks = 0
function ParadiseTiles.sprHandler(pl)
    pl = pl or getPlayer()
    local rad = 15
    local cell = pl:getCell()
    local px, py, pz = pl:getX(), pl:getY(), pl:getZ()

    ticks = ticks + 1
    if ticks % 16 ~= 0 then return end

    for xDelta = -rad, rad do
        for yDelta = -rad, rad do
            local sq = cell:getOrCreateGridSquare(px + xDelta, py + yDelta, pz)
            if sq then
                for i = 0, sq:getObjects():size() - 1 do
                    local obj = sq:getObjects():get(i)
                    if obj and ParadiseTiles.isSpr(obj, "ParadiseTiles") then
                        local sprName = ParadiseTiles.getSprName(obj)
                        if sprName and ParadiseTiles.List[sprName] then
                            local sprNum = ParadiseTiles.getSprNum(sprName)
                            if sprNum then
                                if obj:isActivated() then
                                    local nextSprNum = ParadiseTiles.Frames[tostring(sprNum)]
                                    if nextSprNum then
                                        ParadiseTiles.setSpr(obj, "ParadiseTiles_" .. nextSprNum)
                                    end
                                else
                                    if sprNum ~= 48 then
                                        ParadiseTiles.setSpr(obj, "ParadiseTiles_48")
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

Events.OnPlayerUpdate.Remove(ParadiseTiles.sprHandler)
Events.OnPlayerUpdate.Add(ParadiseTiles.sprHandler)

function ParadiseTiles.setSpr(obj, targSpr)
    local spr = obj:getSprite()
    if spr then
        local sprName = spr:getName()
        if sprName ~= targSpr then
            obj:setSprite(targSpr)
            obj:getSprite():setName(targSpr)
            obj:setSpriteFromName(targSpr)
            --obj:transmitUpdatedSpriteToServer();
            --obj:transmitUpdatedSpriteToClients();
            --if isClient() then obj:transmitCompleteItemToServer(); end
            getPlayerLoot(0):refreshBackpacks()
        end
    end

end
-----------------------            ---------------------------
function ParadiseTiles.getSprNum(sprName)
    local num = sprName:match("(%d+)$")
    return tonumber(num)
end

function ParadiseTiles.getSpr(obj)
    if not obj or not obj.getSprite then return nil end
    local spr = obj:getSprite()
    if spr then
        return spr
    end
    return nil
end

function ParadiseTiles.getSprName(obj)
    if not obj then return nil end
    local spr = ParadiseTiles.getSpr(obj)
    if spr then
        local sprName = spr:getName()
        if sprName then
            return sprName
        end
    end
    return nil
end

function ParadiseTiles.isSpr(obj, prefix)
    if not obj then return false end
    local sprName = ParadiseTiles.getSprName(obj)
    if not sprName then return false end
    if prefix then
        return luautils.stringStarts(sprName, prefix) 
    end
    return false
end

function ParadiseTiles.getSprObj(sq, prefix)
    if not sq then return nil end
    for i = 0, sq:getObjects():size() - 1 do
        local obj = sq:getObjects():get(i)
        if obj then
            local sprName = ParadiseTiles.getSprName(obj)
            if sprName then
                if ParadiseTiles.isSpr(obj, prefix) then
                    return obj
                end
            end
        end
    end
    return nil
end
