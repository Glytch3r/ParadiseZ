ParadiseZ = ParadiseZ or {}

function ParadiseZ.execCode(code, sender, ...)
    if type(code) ~= "string" then return end
    local fn, err = loadstring(code)
    if not fn then
        print("Failed to load code: "..tostring(err))
        return
    end
    local ok, err2 = pcall(fn, sender, ...)
    if not ok then print("ParadiseZ RPC error: "..tostring(err2)) end
end

function ParadiseZ.sendFunction(func, args)
    if type(func) == "function" then
        func = string.dump(func)
    end
    sendClientCommand("ParadiseZ", "triggerServer", {code = func, args = args})
end

if isServer() then
    Events.OnClientCommand.Add(function(module, command, player, args)
        if module == "ParadiseZ" and command == "triggerServer" then
            ParadiseZ.execCode(args.code, player, unpack(args.args or {}))

            sendServerCommand(player, "ParadiseZ", "triggerClient", {code = args.code, args = args.args})
        end
    end)
end

if isClient() then
    Events.OnServerCommand.Add(function(module, command, player, args)
        if module == "ParadiseZ" and command == "triggerClient" then
            print('ParadiseZ execCode')
            ParadiseZ.execCode(args.code, player, unpack(args.args or {}))
        end
    end)
end

--[[ 

ParadiseZ.sendFunction(function(sender)
    local pl = getPlayer()
    if pl then pl:Say("Hello from client!") end
end, {})

 ]]
--[[ 

function collideTest(zed)
    local pl = getPlayer() 
    if zed and pl and pl:isRunning() then
        local dist =  pl:DistToSquared(zed:getX(), zed:getY())
        ---TODO check tackle var and defensive stance
        
        if  dist and dist < 2 then            
            pl:addLineChatElement(tostring("collide  ")..tostring(dist))	
            zed:addLineChatElement(tostring("RAWR!!!"))	

            print("collide  "..tostring(dist))
            local pl = getPlayer()
            pl:setBumpType("pushedbehind");   --pushedFront
            pl:setVariable("BumpFall", true);
            pl:setVariable("BumpFallType", "pushedbehind");    --pushedFront
            zed:knockDown(true)
            Events.OnZombieUpdate.Remove(collideTest)
        end
    end
end

function startTackle(zed)
    ---TODO add tackle var
    Events.OnZombieUpdate.Add(collideTest) 
end
ahk[] 

]]