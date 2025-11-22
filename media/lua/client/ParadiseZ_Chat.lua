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

        ParadiseZ.reboundCountdown()

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

--[[ 
local function timedFunc()
	local ticks = 0
	local count = 0
	local function doFunc()
		print("doFunc")

	end
	local function timedTick(pl)
		local limit = 3

		ticks = ticks + 1
		if ticks % 60 == 0 then
			count = count + 1
			ticks = 0
			print(count)
		end
		if count >= limit then
			print(count)
			Events.OnPlayerUpdate.Remove(timedTick)
			doFunc()
		end
	end
	Events.OnPlayerUpdate.Add(timedTick)
end
timedFunc() ]]