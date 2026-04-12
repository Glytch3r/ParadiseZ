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


function BurstAnim.isSqInFront(targ, sq)
    if not targ or not sq then return false end
    local px, py = targ:getX(), targ:getY()
    local sx, sy = sq:getX(), sq:getY()
    local dx, dy = sx - px, sy - py
    local len = math.sqrt(dx * dx + dy * dy)
    if len == 0 then return false end
    dx, dy = dx / len, dy / len
    local fx, fy = 0, 0
    local dir = targ:getDir()
    if dir == IsoDirections.N then fy = -1
    elseif dir == IsoDirections.S then fy = 1
    elseif dir == IsoDirections.E then fx = 1
    elseif dir == IsoDirections.W then fx = -1
    elseif dir == IsoDirections.NE then fx = 1 fy = -1
    elseif dir == IsoDirections.NW then fx = -1 fy = -1
    elseif dir == IsoDirections.SE then fx = 1 fy = 1
    elseif dir == IsoDirections.SW then fx = -1 fy = 1
    end
    local fl = math.sqrt(fx * fx + fy * fy)
    if fl == 0 then return false end
    fx, fy = fx / fl, fy / fl
    return (dx * fx + dy * fy) >= 0
end

function BurstAnim.doExplosionDamage(x, y, z)
    local rad = SandboxVars.BurstAnim.ExplosionRadius or 2
    local cell = getCell()
    local sq = cell:getOrCreateGridSquare(x, y, z) 
    local pl = getPlayer() 
    if sq then
        if pl then
            addSound(pl, x, y, z, 35, 50)
        end
        getSoundManager():PlayWorldSound('PipeBombExplode', sq, 0, 5, 5, false)
        getSoundManager():PlayWorldSound('BurnedObjectExploded', sq, 0, 5, 5, false)
    end
    for dx = -rad, rad do
        for dy = -rad, rad do
            local tsq = cell:getGridSquare(x + dx, y + dy, z)
            if tsq then
                local moving = tsq:getMovingObjects()
                if moving then
                    for i = 0, moving:size() - 1 do
                        local obj = moving:get(i)
                        local dmg = 0
                        local isFront = false
                        local isZed = instanceof(obj, "IsoZombie")
                        local isPl = instanceof(obj, "IsoPlayer")

                        if isZed or isPl then
                            local maxDmg = SandboxVars.BurstAnim.BurstDmg or 50
                            dmg = ZombRand(maxDmg / 2, maxDmg + 1)
                            isFront = BurstAnim.isSqInFront(obj, getCell():getGridSquare(x, y, z))
                            if isZed and obj:isAlive() then
                                local isKnockDown = ParadiseZ.doRoll(SandboxVars.BurstAnim.ZedCrawlerPercent or 0)
                                local isCrawler = ParadiseZ.doRoll(SandboxVars.BurstAnim.ZedCrawlerPercent or 0)

                                if dmg > 0 then
                                    local newHealth = math.max(0, obj:getHealth() - dmg)
                                    obj:setHealth(newHealth)
                                    obj:update()
                                end

                                if isKnockDown then
                                    if isClient() then
                                        sendClientCommand("BurstAnim", "triggerZKnockDown", { zId = obj:getOnlineID(), isFront = isFront, isCrawler = isCrawler })
                                    else
                                        BurstAnim.zKnockDown(obj, isFront, isCrawler)
                                    end
                                end

                            elseif isPl and obj:isAlive() then
                                local isStagger = ParadiseZ.doRoll(SandboxVars.BurstAnim.PlayerStaggerPercent or 0)

                                if isClient() then
                                    sendClientCommand("BurstAnim", "triggerPlStagger", { pId = obj:getOnlineID(), isFront = isFront, dmg = dmg, isStagger = isStagger })
                                else
                                    BurstAnim.plDmg(obj, isFront, dmg, isStagger)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
