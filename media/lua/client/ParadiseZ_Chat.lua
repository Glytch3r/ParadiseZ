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
ParadiseZ = ParadiseZ or {}

function ParadiseZ.parseCoords()
    if ParadiseZ.coords then
        return ParadiseZ.coords[1], ParadiseZ.coords[2], ParadiseZ.coords[3]
    end
    
    local strList = SandboxVars.ParadiseZ.Coords
    local tx, ty, tz = strList:match("^(-?%d+)[;:](-?%d+)[;:](-?%d+)")
    tx, ty, tz = tonumber(tx), tonumber(ty), tonumber(tz)

    ParadiseZ.coords = { tx, ty, tz }
    
    return tx, ty, tz
end

LuaEventManager.AddEvent("OnChatCmd")
local hook = ISChat.logChatCommand
function ISChat:logChatCommand(command)
    self.chatText.logIndex = 0
    print(command)
    triggerEvent("OnChatCmd", command)
    hook(self, command)
end

function ParadiseZ.chatCmd(cmd)
    local pl = getPlayer()
    if not pl then return end

    local dbg = getCore():getDebug()
    if cmd == "/stuck" then
        ParadiseZ.ReboundCount:start(pl, 10) 

      --[[   --ISWorldObjectContextMenu.onTeleport()    
        local x, y, z =  ParadiseZ.parseCoords()
        if not (x and y and z) then return end
        ParadiseZ.tp(pl, x, y, z)

        timer:Simple(1.5, function() 
            pl:setBumpType("stagger")
            pl:setBumpFall(true)
            pl:setVariable("BumpFallType", "pushedFront")
            pl:setBumpDone(true)
            pl:reportEvent("wasBumped")
        end) ]]
    elseif cmd == "/scare" then
        if dbg then
            getSoundManager():PlayWorldSound("ZombieSurprisedPlayer", pl:getSquare(), 0, 5, 5, false)
        end
    end
end

Events.OnChatCmd.Remove(ParadiseZ.chatCmd)
Events.OnChatCmd.Add(ParadiseZ.chatCmd)

ParadiseZ.ReboundCount = setmetatable({}, {
    __index = {
        tick = 0,
        pl = nil,
        staggered = false,
        inTransit = false,
        countdown = 0,

        reset = function(self)
            self.tick = 0
            self.pl = nil
            self.staggered = false
            self.inTransit = false
            self.countdown = 0
        end,

        start = function(self, player, seconds)
            if self.inTransit then return end
            self.inTransit = true

            player = player or getPlayer()
            self.pl = player
            self.countdown = seconds or 10
            self.staggered = false
            self.tick = 0

            Events.OnTick.Add(self.handler)
        end,

        handler = function()
            local rebound = ParadiseZ.Rebound
            local pl = rebound.pl
            if not pl then
                Events.OnTick.Remove(rebound.handler)
                rebound:reset()
                return
            end

            rebound.tick = rebound.tick + 1

            if rebound.tick % 20 == 0 then
                if rebound.countdown > 0 then
                    pl:addLineChatElement(tostring(rebound.countdown))
                    rebound.countdown = rebound.countdown - 1
                else
                    Events.OnTick.Remove(rebound.handler)
                    local x, y, z = ParadiseZ.parseCoords()
                    if x and y and z then
                        ParadiseZ.tp(pl, x, y, z)

                        timer:Simple(1.5, function()
                            pl:setBumpType("stagger")
                            pl:setBumpFall(true)
                            pl:setVariable("BumpFallType", "pushedFront")
                            pl:setBumpDone(true)
                            pl:reportEvent("wasBumped")
                        end)
                    end

                    rebound:reset()
                end
            end
        end
    }
})
