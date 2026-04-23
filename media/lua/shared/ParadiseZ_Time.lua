ParadiseZ = ParadiseZ or {}

ParadiseZ.ServerUnixTime = nil

function ParadiseZ._getServerUnixTime()
    return os.time()
end

if isServer() then
    function ParadiseZ._broadcastServerTime()
        local t = ParadiseZ._getServerUnixTime()
        sendServerCommand("ParadiseZ", "ServerTimeUpdate", { t = t })
    end

    Events.EveryOneMinute.Add(ParadiseZ._broadcastServerTime)
else
    Events.OnServerCommand.Add(function(module, command, args)
        if module == "ParadiseZ" and command == "ServerTimeUpdate" then
            ParadiseZ.ServerUnixTime = args.t
        end
    end)
end

function ParadiseZ.getServerDateTime()
    if not ParadiseZ.ServerUnixTime then return nil end
    local d = os.date("*t", ParadiseZ.ServerUnixTime)
    local months = { "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec" }
    return months[d.month] .. " " .. string.format("%02d", d.day) .. " " .. d.year .. " / " .. string.format("%02d:%02d", d.hour, d.min)
end



-----------------------            ---------------------------
--[[ 
function ParadiseZ.serverInit()
    LuaEventManager.AddEvent("OnClockUpdate")
    ParadiseZ.clock()
end
Events.OnServerStarted.Add(ParadiseZ.serverInit)


function ParadiseZ.clock()
    if not isIngameState() then return end    
    local prevSec
    local cal
    if PZCalendar then
        cal = PZCalendar.getInstance()
        if cal then
            prevSec = cal:get(Calendar.SECOND)
        end
    end
    function ParadiseZ.clockHandler()
        if not isIngameState() then return end    
        local curSec = cal:get(Calendar.SECOND)
        if prevSec < curSec or (curSec == 1 and (prevSec == 60 or prevSec > curSec)) then
            triggerEvent("OnClockUpdate", prevSec, curSec)
            prevSec = curSec
        end
    end
    Events.OnTick.Add(ParadiseZ.clockHandler)
end

function ParadiseZ.secHandler(prevSec, curSec)    
    ParadiseZ.curSec = curSec
end
Events.OnClockUpdate.Add(ParadiseZ.secHandler)

function ParadiseZ.getSec()    
    return ParadiseZ.curSec or nil
end 
]]