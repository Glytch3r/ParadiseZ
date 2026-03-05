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


function BurstAnim.triggerBurst(pl)
    pl = pl or getPlayer()
    if not pl then return end

    local sq = pl:getCurrentSquare()
    if not sq then return end

    local x, y, z = sq:getX(), sq:getY(), sq:getZ()
    local dir = tostring(pl:getDir())



    local rad = SandboxVars.BurstAnim.ExplosionRadius or 2
    local cell = getCell()

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

                        if instanceof(obj, "IsoZombie") or instanceof(obj, "IsoPlayer") then
                            local maxDmg = SandboxVars.BurstAnim.BurstDmg or 50
                            dmg = ZombRand(maxDmg / 2, maxDmg + 1)
                            isFront = BurstAnim.isSqInFront(obj, sq)
                        end

                        if instanceof(obj, "IsoZombie") then
                            local isKnockDown = BurstAnim.doRoll(SandboxVars.BurstAnim.ZedKnockDownPercent or 0)
                            local isCrawler = BurstAnim.doRoll(SandboxVars.BurstAnim.ZedKnockDownPercent or 0)

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

                        elseif instanceof(obj, "IsoPlayer") then
                            local isStagger = BurstAnim.doRoll(SandboxVars.BurstAnim.PlayerStaggerPercent or 0)

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

    if isClient() then
        sendClientCommand("BurstAnim", "triggerBurst", {
            x = x,
            y = y,
            z = z,
            dir = dir,
        })
    else
        BurstAnim.doBurst(x, y, z, dir)
    end
end