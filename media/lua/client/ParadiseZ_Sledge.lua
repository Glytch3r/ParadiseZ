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

function doSledge(obj)
    if isClient() then
        sledgeDestroy(obj)
    else
        local sq = obj:getSquare()
        if sq then
            sq:RemoveTileObject(obj);
            sq:getSpecialObjects():remove(obj);
            sq:getObjects():remove(obj);
            sq:transmitRemoveItemFromSquare(obj)
        end
    end
end
Events.OnGameStart.Add(function()
    local hook = ISMoveablesAction.isValid
    function ISMoveablesAction:isValid()
        if isAdmin() or not self.mode or not self.moveProps then
            return hook(self)
        end
        if self.mode ~= "scrap" and self.mode ~= "pickup" then
            return hook(self)
        end
        local obj = self.moveProps.object
        if obj and ParadiseZ.isCantSledge(obj) then
            self:stop()
            return false
        end
        return hook(self)
    end

    local sledgeHook = ISDestroyCursor.canDestroy
    function ISDestroyCursor:canDestroy(obj)
        if not isAdmin() and obj and ParadiseZ.isCantSledge(obj) then
            return false
        end
        return sledgeHook(self, obj)
    end
end)

function ParadiseZ.setCantSledge(obj, bool)
    if obj then
        obj:getModData().isCantSledge = bool
        obj:transmitModData()
    end
end

function ParadiseZ.isCantSledge(obj)
    if obj then
        if getCore():getDebug() then
            print(obj:getModData().isCantSledge)
        end
        return obj:getModData().isCantSledge
    end
end
