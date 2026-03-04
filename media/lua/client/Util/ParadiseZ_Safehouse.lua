ParadiseZ = ParadiseZ or {}

function ParadiseZ.isPartOfSH(sq)
    local pl = getPlayer()
    local user = pl:getUsername()
    return ParadiseZ.isOwnerOfSH(sq, user) or ParadiseZ.isMemberOfSH(sq)
end
function ParadiseZ.isMemberOfSH(sq)
    local pl = getPlayer() 
    local user = pl:getUsername()
    local house = SafeHouse.getSafeHouse(sq)
    if house then
        local members = house:getPlayers()
        if members then
            for i = 0, members:size() - 1 do 
                if tostring(members:get(i)) == tostring(user) then 
                    return true 
                end
            end
        end
    end
    return false
end
function ParadiseZ.getOwner(sq)
    local safehouse = SafeHouse.getSafeHouse(sq)
    if safehouse and safehouse:getOwner() then
        return tostring(safehouse:getOwner())
    end
    return nil
end
function ParadiseZ.isOwnerOfSH(sq, user)
    local safehouse = SafeHouse.getSafeHouse(sq)
    if safehouse and ParadiseZ.getOwner(sq) == tostring(user) then
        return true
    end
    return false
end
