ParadiseZ = ParadiseZ or {}
--[[ 
local function serializeFunction(func)
    return string.dump(func)
end

local function deserializeFunction(funcString)
    return load(funcString)
end

function ParadiseZ.sendToServer(callback, args)
    if type(callback) == "function" then
        callback = serializeFunction(callback)
    end
    sendClientCommand("ParadiseZ", "triggerServer", {callback = callback, args = args})
end

function ParadiseZ.sendToClient(player, callback, args)
    if type(callback) == "function" then
        callback = serializeFunction(callback)
    end
    sendServerCommand(player, "ParadiseZ", "triggerClient", {callback = callback, args = args})
end

if isClient() then
    Events.OnServerCommand.Add(function(module, command, player, args)
        if module == "ParadiseZ" and command == "triggerClient" then
            local cb = args.callback
            if type(cb) == "string" then cb = deserializeFunction(cb) end
            if cb then cb(table.unpack(args.args or {})) end
        end
    end)
end

if isServer() then
    Events.OnClientCommand.Add(function(module, command, player, args)
        if module == "ParadiseZ" and command == "triggerServer" then
            local cb = args.callback
            if type(cb) == "string" then cb = deserializeFunction(cb) end
            if cb then cb(player, table.unpack(args.args or {})) end
        end
    end)
end
 ]]
--[[ 
    local targUser = "Jim"
    local targPl = getOnlineUsername(targUser)
    local pl = getPlayer() 
    
    UniversalRPC.sendToServer(function(sender)
        local targPl = getOnlineUsername("Jim")
        local pl = getPlayer()
        if targPl == pl then
            pl:Callout()
        end
    end, {})
]]
