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

local Commands = {}
Commands.BurstAnim = {}


function BurstAnim.doRoll(percent)
    percent = percent or 50

	if percent <= 0 then return false end
	if percent >= 100 then return true end
	return percent >= ZombRand(1, 101)
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

function BurstAnim.zKnockDown(zed, isFront, isCrawler)
    isFront = isFront or true
    isCrawler = isCrawler or false
    zed:setKnockedDown(true)
    zed:setCrawler(isCrawler)
    zed:setCanCrawlUnderVehicle(isCrawler)
    zed:setFallOnFront(isFront)
    zed:setCanWalk(not isCrawler)
end

function BurstAnim.plDmg(pl, isFront, dmg, isStagger)
    isStagger = isStagger or false
    if isStagger then
        isFront = isFront or true
        pl:setBumpType("stagger")
        pl:setVariable("BumpDone", true)
        pl:setVariable("BumpFall", true)
        pl:setVariable("BumpFallType", isFront and "pushedFront" or "pushedBehind")
        pl:reportEvent("wasBumped")
    end
    if pl == getPlayer() then
        dmg = dmg or 25
        pl:getBodyDamage():ReduceGeneralHealth(dmg)
    end
end

Commands.BurstAnim.triggerPlStagger = function(args)
    local targ = getPlayerByOnlineID(args.pId)
    if not targ then return end
    local isFront = args.isFront
    local dmg = args.dmg
    local isStagger = args.isStagger
    BurstAnim.plDmg(targ, isFront, dmg, isStagger) 
end

Commands.BurstAnim.triggerZKnockDown = function(args)
    local zed = BurstAnim.findZedByID(args.zId)
    if not zed then return end
    local isFront = args.isFront
    local isCrawler = args.isCrawler
    BurstAnim.zKnockDown(zed, isFront, isCrawler)
end

Commands.BurstAnim.triggerBurst = function(args)
    BurstAnim.doBurst(args.x, args.y, args.z, args.dir)
end

Events.OnServerCommand.Add(function(module, command, args)
    if Commands[module] and Commands[module][command] then
        Commands[module][command](args)
    end
end)