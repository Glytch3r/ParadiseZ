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
require "lua_timers"

ParadiseZ = ParadiseZ or {}

ParadiseZ.List = {
   ["ParadiseTiles_48"]=true,
   ["ParadiseTiles_49"]=true,
   ["ParadiseTiles_50"]=true,
   ["ParadiseTiles_51"]=true,
}

ParadiseZ.Frames = {  
   ["48"]="49",
   ["49"]="50",
   ["50"]="51",
   ["51"]="49",
}

ParadiseZ.mineList = {
   ["ParadiseTiles_6"]=true,
   ["ParadiseTiles_7"]=true,
}

function ParadiseZ.getRandFloat()
    return ZombRand(0, 101)/100
end

function ParadiseZ.doRoll(percent)
	if percent <= 0 then return false end
	if percent >= 100 then return true end
	return percent >= ZombRand(1, 101)
end

function ParadiseZ.getSpr(obj)
    if not obj or not obj.getSprite then return nil end
    return obj:getSprite()
end

function ParadiseZ.getSprName(obj)
    local spr = ParadiseZ.getSpr(obj)
    return spr and spr:getName() or nil
end

function ParadiseZ.getSprNum(sprName)
    if not sprName then return nil end
    local num = sprName:match("(%d+)$")
    return tonumber(num)
end

function ParadiseZ.isSpr(obj, prefix)
    local sprName = ParadiseZ.getSprName(obj)
    if not sprName then return false end
    return prefix and luautils.stringStarts(sprName, prefix) or false
end

function ParadiseZ.setSpr(obj, targSpr)
    local spr = obj:getSprite()
    if spr then
        local sprName = spr:getName()
        if sprName ~= targSpr then
            obj:setSprite(targSpr)
            obj:getSprite():setName(targSpr)
            obj:setSpriteFromName(targSpr)
            getPlayerLoot(0):refreshBackpacks()
        end
    end
end

function ParadiseZ.doSledge(obj)
    if isClient() then
        sledgeDestroy(obj)
    else
        local sq = obj:getSquare()
        if sq then
            sq:RemoveTileObject(obj)
            sq:getSpecialObjects():remove(obj)
            sq:getObjects():remove(obj)
            sq:transmitRemoveItemFromSquare(obj)
        end
    end
end

function ParadiseZ.getSprObj(sq, prefix)
    if not sq then return nil end
    for i = 0, sq:getObjects():size() - 1 do
        local obj = sq:getObjects():get(i)
        if ParadiseZ.isSpr(obj, prefix) then
            return obj
        end
    end
    return nil
end

local ticks = 0
function ParadiseZ.sprHandler(pl)
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
                    if obj and ParadiseZ.isSpr(obj, "ParadiseTiles") then
                        local sprName = ParadiseZ.getSprName(obj)
                        if sprName and ParadiseZ.List[sprName] then
                            local sprNum = ParadiseZ.getSprNum(sprName)
                            if sprNum then
                                if obj:isActivated() then
                                    local nextSprNum = ParadiseZ.Frames[tostring(sprNum)]
                                    if nextSprNum then
                                        ParadiseZ.setSpr(obj, "ParadiseTiles_" .. nextSprNum)
                                    end
                                else
                                    if sprNum ~= 48 then
                                        ParadiseZ.setSpr(obj, "ParadiseTiles_48")
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

function ParadiseZ.isMineSq(sprName)
    return ParadiseZ.mineList[sprName] or false
end

function ParadiseZ.steppedOnTrap(char)
    if not char then return end
    if not ParadiseZ.isMineZone or not ParadiseZ.isMineZone(char) then return end

    local sq = getCell():getGridSquare(char:getX(), char:getY(), char:getZ())
    if not sq then return end

    local objects = sq:getObjects()

    for i = 1, objects:size() do
        local obj = objects:get(i-1)

        if obj then
            local spr = obj:getSprite()
            if spr then
                local sprName = spr:getName()

                if sprName and ParadiseZ.isMineSq(sprName) then

                    ParadiseZ.doSledge(obj)

                    getSoundManager():PlayWorldSound('PipeBombExplode', sq, 0, 5, 5, false)
                    getSoundManager():PlayWorldSound('BurnedObjectExploded', sq, 0, 5, 5, false)

                    addSound(char, sq:getX(), sq:getY(), sq:getZ(), 5, 1)

                    local dug
                    local dug2

                    if ParadiseZ.doRoll(5) then
                        dug = IsoObject.new(sq, "floors_burnt_01_" .. ZombRand(2,3), "", false)
                        sq:AddTileObject(dug)
                    end

                    if ParadiseZ.doRoll(10) then
                        dug2 = IsoObject.new(sq, "floors_burnt_01_" .. ZombRand(2,3), "", false)
                        sq:AddTileObject(dug2)
                    end

                    BurstAnim.triggerBurst(char)

                    local isFront = BurstAnim.isSqInFront(char, sq)
                    local isCrawler = SandboxVars.BurstAnim.ZedCrawlerPercent
                    local dmg = ZombRand(SandboxVars.BurstAnim.BurstDmg/2, SandboxVars.BurstAnim.BurstDmg+1)

                    if instanceof(char, "IsoPlayer") then    
                        if not char:isGodMod() then 
                            BurstAnim.plDmg(char, isFront, dmg) 
                        end                                
                    elseif instanceof(char, "IsoZombie") then
                        BurstAnim.zKnockDown(char, isFront, ParadiseZ.doRoll(isCrawler))              
                    end
                    
                    if isClient() then
                        timer:Simple(1, function()
                            local args = { x = char:getX(), y = char:getY(), z = char:getZ() }
                            sendClientCommand(char, 'object', 'addExplosionOnSquare', args)

                            if dug then dug:transmitCompleteItemToServer() end
                            if dug2 then dug2:transmitCompleteItemToServer() end
                        end)
                    end

                    return
                end
            end
        end
    end
end

Events.OnPlayerUpdate.Remove(ParadiseZ.sprHandler)
Events.OnPlayerUpdate.Add(ParadiseZ.sprHandler)

Events.OnPlayerUpdate.Add(ParadiseZ.steppedOnTrap)
Events.OnZombieUpdate.Add(ParadiseZ.steppedOnTrap)