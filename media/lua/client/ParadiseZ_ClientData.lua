--client/ParadiseZ_ClientData.lua
ParadiseZ = ParadiseZ or {}

function ParadiseZ.saveZoneData(data)
    if not data then return end
	if isClient() then 
		sendClientCommand("ParadiseZ", "Sync", {  data = data })
	end	
end


function ParadiseZ.recordGifted(user)
    if not user then
        local pl = getPlayer() 
        user = pl:getUsername() 
    end
    if not user then return end
	if isClient() then 
		sendClientCommand("ParadiseZ", "Gift", {  user = user })
	end	
end


function ParadiseZ.isGiftRecieved(user)
    if not user then
        local pl = getPlayer() 
        user = pl:getUsername() 
    end
    if not user then return end
    return ParadiseZ_Gift[user]
end

function ParadiseZ.isAdm()
    local pl = getPlayer()
    return ((pl and string.lower(pl:getAccessLevel()) == "admin") or (isClient() and isAdmin())) 
end

--local user = getPlayer():getUsername()
--ParadiseZ.ZoneData[user]={["test"]=123}
--ParadiseZ.saveZoneData(ParadiseZ.ZoneData) 
function ParadiseZ.ClientSync(module, command, args)
    if module ~= "ParadiseZ" then return end
    local pl = getPlayer() 
    if command == "Sync" and args.data then
        for k, _ in pairs(ParadiseZ.ZoneData) do ParadiseZ.ZoneData[k] = nil end

        for k, v in pairs(args.data) do
            ParadiseZ.ZoneData[k] = v
        end


		if ParadiseZ.ZoneEditorWindow and ParadiseZ.ZoneEditorWindow.instance then
			ParadiseZ.ZoneEditorWindow.instance:refreshList()
		end
    elseif command == "Gift" and args.user then        
        ParadiseZ_Gift[args.user] = true
    end
end
Events.OnServerCommand.Add(ParadiseZ.ClientSync)

function ParadiseZ.DataInit()
	ParadiseZ.ZoneData = ModData.getOrCreate("ParadiseZ_ZoneData")
	ParadiseZ_Gift = ModData.getOrCreate("ParadiseZ_Gift")
end

Events.OnInitGlobalModData.Add(ParadiseZ.DataInit)
