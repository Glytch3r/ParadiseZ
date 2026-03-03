
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

function BurstAnim.landmine()
    local pl = getPlayer() 
    if not pl then return end
    local sq = pl:getCurrentSquare() 
    if not sq then return end
    for i=1, sq:getObjects():size() do
        local obj = sq:getObjects():get(i-1)
        if obj and instanceof(obj, "IsoObject") then
            local  sprName =  ParadiseZ.getSprName(obj) 
            if sprName and BurstAnim.mineList[sprName] then 
                doSledge(obj)
                BurstAnim.triggerBurst(pl)
            end
        end
	end
end

Events.OnPlayerMove.Add(BurstAnim.landmine)

if isClient() then

    local Commands = {}
    Commands.BurstAnim = {}

    function BurstAnim.doRoll(percent)
        percent = percent or 0
        return percent > 0 and ZombRand(100) < percent
    end

    function BurstAnim.findZedByID(id)
        local list = getCell():getZombieList()
        for i = 0, list:size() - 1 do
            local z = list:get(i)
            if z and z:getOnlineID() == id then
                return z
            end
        end
        return nil
    end

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

    function BurstAnim.zKnockDown(zed, isFront)
        isFront = isFront or true
        zed:setKnockedDown(true)
        zed:setCrawler(true)
        zed:setCanCrawlUnderVehicle(true)
        zed:setFallOnFront(isFront)
        zed:setCanWalk(false)
    end

    function BurstAnim.plStagger(pl, isFront)
        isFront = isFront or true
        pl:setBumpType("stagger")
        pl:setVariable("BumpDone", true)
        pl:setVariable("BumpFall", true)
        pl:setVariable("BumpFallType", isFront and "pushedFront" or "pushedBehind")
        pl:reportEvent("wasBumped")
    end

    function BurstAnim.triggerBurst(pl)
        pl = pl or getPlayer()
        if not pl then return end

        local sq = pl:getCurrentSquare()
        if not sq then return end

        local x, y, z = sq:getX(), sq:getY(), sq:getZ()
        local dir = tostring(pl:getDir())

        BurstAnim.doBurst(x, y, z, dir)

        local rad = SandboxVars.BurstAnim.ExplosionRadius or 2
        local cell = getCell()

        local zedResults = {}
        local plResults = {}

        for dx = -rad, rad do
            for dy = -rad, rad do
                local tsq = cell:getGridSquare(x + dx, y + dy, z)
                if tsq then
                    local moving = tsq:getMovingObjects()
                    if moving then
                        for i = 0, moving:size() - 1 do
                            local obj = moving:get(i)

                            if instanceof(obj, "IsoZombie") then
                                local knock = BurstAnim.doRoll(SandboxVars.BurstAnim.ZedKnockDownPercent or 0)
                                local dmgPct = SandboxVars.BurstAnim.ZedDmg or 0
                                local dead = false

                                if dmgPct > 0 then
                                    local dmg = math.max(0, math.min(1, dmgPct / 100))
                                    obj:setHealth(obj:getHealth() - dmg)
                                    if obj:getHealth() <= 0 then dead = true end
                                    obj:update()
                                end

                                if knock and not dead then
                                    local isFront = BurstAnim.isSqInFront(obj, sq)
                                    BurstAnim.zKnockDown(obj, isFront)
                                end

                                zedResults[#zedResults + 1] = {
                                    id = obj:getOnlineID(),
                                    knock = knock,
                                    dead = dead
                                }

                            elseif instanceof(obj, "IsoPlayer") then
                                if obj:getOnlineID() ~= pl:getOnlineID() then
                                    local stagger = BurstAnim.doRoll(SandboxVars.BurstAnim.PlayerStaggerPercent or 0)
                                    local death = BurstAnim.doRoll(SandboxVars.BurstAnim.PlayerDeathPercent or 0)

                                    if stagger and not death then
                                        local isFront = BurstAnim.isSqInFront(obj, sq)
                                        BurstAnim.plStagger(obj, isFront)
                                    end

                                    if death then
                                        obj:Kill(pl)
                                    end

                                    plResults[#plResults + 1] = {
                                        id = obj:getOnlineID(),
                                        stagger = stagger,
                                        dead = death
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end

        sendClientCommand("BurstAnim", "relayBurst", {
            x = x,
            y = y,
            z = z,
            dir = dir,
            zeds = zedResults,
            players = plResults
        })
    end

    Commands.BurstAnim.relayBurst = function(args)
        BurstAnim.doBurst(args.x, args.y, args.z, args.dir)

        local sq = getCell():getGridSquare(args.x, args.y, args.z)
        if not sq then return end

        for i = 1, #(args.zeds or {}) do
            local data = args.zeds[i]
            local zed = BurstAnim.findZedByID(data.id)
            if zed then
                if data.dead then
                    zed:setHealth(0)
                    zed:update()
                elseif data.knock then
                    local isFront = BurstAnim.isSqInFront(zed, sq)
                    BurstAnim.zKnockDown(zed, isFront)
                end
            end
        end

        for i = 1, #(args.players or {}) do
            local data = args.players[i]
            local tPl = getPlayerByOnlineID(data.id)
            if tPl then
                if data.dead then
                    tPl:Kill(tPl)
                elseif data.stagger then
                    local isFront = BurstAnim.isSqInFront(tPl, sq)
                    BurstAnim.plStagger(tPl, isFront)
                end
            end
        end
    end

    Events.OnServerCommand.Add(function(module, command, args)
        if Commands[module] and Commands[module][command] then
            Commands[module][command](args)
        end
    end)
end
