
ParadiseZ = ParadiseZ or {}

local Commands = {};
Commands.ParadiseZ = {};
--[[ 
print(ParadiseZ.isScareCrow(getPlayer()))
print(getPlayer():getVariableBoolean("isScareCrow"))
print(getPlayer():getModData()['isScareCrow'] )
 ]]
function ParadiseZ.ScareCrow()
    if not isIngameState() then return end    
    local pl = getPlayer() 
    if not pl then return end   
    isScareCrow = ParadiseZ.isScareCrow(pl)
    if isScareCrow then
        pl:setVariable("isScareCrow", true)
        if isClient() then
            sendClientCommand("ParadiseZ", "isScareCrow", {isScareCrow = true, })
        end
    elseif not isScareCrow then
        pl:setVariable("isScareCrow", false)
        if isClient() then
            sendClientCommand("ParadiseZ", "isScareCrow", {isScareCrow = false, })
        end
    end
end
Events.OnWeaponSwing.Add(ParadiseZ.ScareCrow)
Events.OnMiniScoreboardUpdate.Add(ParadiseZ.ScareCrow)
Events.OnScoreboardUpdate.Add(ParadiseZ.ScareCrow)
Events.OnClothingUpdated.Add(ParadiseZ.ScareCrow)


--[[ 
Events.OnClothingUpdated.Add(ParadiseZ.ScareCrow)

Events.OnDisconnect.Add(ParadiseZ.ScareCrow)
Events.OnMiniScoreboardUpdate.Add(ParadiseZ.ScareCrow)
Events.OnCreatePlayer.Add(ParadiseZ.ScareCrow)

 ]]


Commands.ParadiseZ.isScareCrow = function(args)
    local source = getPlayer();
    local player = getPlayerByOnlineID(args.id)
    if source ~= player then
        if args.isScareCrow then
            player:setVariable('isScareCrow', true);
        else
            player:setVariable('isScareCrow', false);
        end
    end
end

Events.OnServerCommand.Add(function(module, command, args)
	if Commands[module] and Commands[module][command] then
		Commands[module][command](args)
	end
end)