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

BurstAnim = BurstAnim or {}
ParadiseZ = ParadiseZ or {}

BurstAnim.mineList = {
   ["ParadiseTiles_6"]=true,
   ["ParadiseTiles_7"]=true,
}


function ParadiseZ.isMineSq(sprName)
    return BurstAnim.mineList[sprName] or false
end

function ParadiseZ.triggerTrapOnSquare(char, sq)    
    BurstAnim.doExplosionDamage(sq:getX(), sq:getY(), sq:getZ())
    if isClient() then
        timer:Simple(1, function()
            local args = { x = char:getX(), y = char:getY(), z = char:getZ() }
            sendClientCommand(char, 'object', 'addExplosionOnSquare', args)
        end)
    end
end


function ParadiseZ.steppedOnTrap(char)
    local pl = getPlayer() 
    if not char then return end
    if not ParadiseZ.isMineZone or not ParadiseZ.isMineZone(char) then return end
    if instanceof(char, "IsoZombie") and not ParadiseZ.isClosestPl(pl, char) then return end
    local sq = getCell():getOrCreateGridSquare(char:getX(), char:getY(), char:getZ())
    if not sq then return end

    local objs = sq:getObjects()

    for i = 1, objs:size() do
        local obj = objs:get(i-1)
        if obj then
            local spr = obj:getSprite()
            if spr then
                local sprName = spr:getName()
                if sprName and ParadiseZ.isMineSq(sprName) then
                    doSledge(obj)
                    ParadiseZ.triggerTrapOnSquare(char, sq)
                    return
                end
            end
        end
    end
end


Events.OnPlayerUpdate.Add(ParadiseZ.steppedOnTrap)
Events.OnZombieUpdate.Add(ParadiseZ.steppedOnTrap)
