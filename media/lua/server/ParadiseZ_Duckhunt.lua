ParadiseZ = ParadiseZ or {}

ParadiseZ.duckItems =  {
    "jim",
    "goro",
    "tenorphans",
    "glytch3r",
    "kit",
    "fooze",
}

function ParadiseZ.duckDrop(zed)
    if not zed then return end
    local inv = zed:getInventory()
    if not inv then return end
    local pl = getPlayer()
    if not pl then return end
    ---------------------------
    local killer = zed:getAttackedBy()
    if not killer or killer ~= pl then return end

    local chance = SandboxVars.ParadiseZ.DuckDropChance 
    if not chance then return end
    local half = chance * 0.5
    if pl:getTraits():contains("Lucky") then
        chance = math.min(100, math.max(0, chance + 1))
    elseif pl:getTraits():contains("Unlucky") then
        chance = math.min(100, math.max(0, chance - half))
    end

    if ParadiseZ.doRoll(chance) then
        local duckChar = ParadiseZ.getStrFromList(ParadiseZ.duckItems)
        if duckChar then
            inv:AddItem("ParadiseZ.Duckhunt_" .. tostring(duckChar))
        end
    end 
end
Events.OnZombieDead.Add(ParadiseZ.duckDrop);
