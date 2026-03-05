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
ParadiseZ.mineList = {
   ["ParadiseTiles_6"]=true,
   ["ParadiseTiles_7"]=true,

}

function ParadiseZ.isMineSq(sprName)
    return ParadiseZ.mineList[sprName] or false
end

function ParadiseZ.steppedOnTrap(char)
    if not char then return end

    local sq = getCell():getGridSquare(char:getX(), char:getY(), char:getZ())
    if not sq then return end

    local objects = sq:getObjects()

    for i = 1, objects:size() do
        local obj = objects:get(i-1)

        if obj then
            local spr = obj:getSprite()

            if spr then
                local sprName = spr:getName()

                if sprName and ParadiseZ.isMineSq(sprName)  then

                    doSledge(obj)

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
                    local isStagger = SandboxVars.BurstAnim.PlayerStaggerPercent
                    local isCrawler = SandboxVars.BurstAnim.ZedCrawlerPercent
                    local dmg = ZombRand(SandboxVars.BurstAnim.BurstDmg/2, SandboxVars.BurstAnim.BurstDmg+1) 

                    if instanceof(char, "IsoPlayer") then    
                        BurstAnim.plDmg(pl, isFront, dmg, BurstAnim.doRoll(isStagger))         
                    elseif instanceof(char, "IsoZombie") then
                        BurstAnim.zKnockDown(zed, isFront, BurstAnim.doRoll(isCrawler))              
                    end
                    
                    if isClient() then
                        timer:Simple(1, function()
                            local args = { x = char:getX(), y = char:getY(), z = char:getZ() }

                            sendClientCommand(char, 'object', 'addExplosionOnSquare', args)

                            if dug then
                                dug:transmitCompleteItemToServer()
                            end

                            if dug2 then
                                dug2:transmitCompleteItemToServer()
                            end
                        end)
                    end

                    return
                end
            end
        end
    end
end

Events.OnPlayerUpdate.Add(ParadiseZ.steppedOnTrap)
Events.OnZombieUpdate.Add(ParadiseZ.steppedOnTrap)


