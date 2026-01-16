ParadiseZ = ParadiseZ or {}


function ParadiseZ.isAdm()
    return string.lower(getPlayer():getAccessLevel()) == "admin"
end

Events.OnGameStart.Add(function()
    
    ParadiseZ.ISServerSandboxOptionsUIonButtonApply = ISServerSandboxOptionsUI.onButtonApply
    function ISServerSandboxOptionsUI:onButtonApply()
        self:settingsFromUI(self.options)
        ParadiseZ.echo("SandboxOptions Updated")
        self.options:sendToServer()
        getSandboxOptions():toLua()
        self:destroy()
    end
--[[ 
    ParadiseZ.ISBuildMenucanBuild = ISBuildMenu.canBuild
    ISBuildMenu.canBuild = function(plankNb, nailsNb, hingeNb, doorknobNb, baredWireNb, carpentrySkill, option, player)
    function ISBuildMenu.canBuild(player, recipe, square)
        if ParadiseZ.isSafePlorSq(player, square) then 
            return false
        end
        return ParadiseZ.ISBuildMenucanBuild(player, recipe, square)
    end
 ]]
    -----------------------            ---------------------------
    ParadiseZ.ISRadialMenuonMouseDown = ISRadialMenu.onMouseDown
    function ISRadialMenu:onMouseDown(x, y)
        if SandboxVars.ParadiseZ.isSafeAllowActions and ParadiseZ.isAdm() then 
            return ParadiseZ.ISRadialMenuonMouseDown(self, x, y) 
        end
        if self.joyfocus then return end
        local pl = getPlayer() 
        local sq = pl:getSquare() 
        if ParadiseZ.isSafePlorSq(pl, sq) then
            self:undisplay()
            return
        end
        return ParadiseZ.ISRadialMenuonMouseDown(self, x, y)
    end
    -----------------------            ---------------------------

    ParadiseZ.ISBuildMenuisMultiStageValid = ISBuildMenu.isMultiStageValid
    function ISBuildMenu.isMultiStageValid()
        if SandboxVars.ParadiseZ.isSafeAllowActions and ParadiseZ.isAdm() then 
            return ParadiseZ.ISBuildMenuisMultiStageValid()
        end
        if not ISBuildMenu.cursor or not ISBuildMenu.cursor.sq then
            return false
        end
        if ParadiseZ.isSafePlorSq(getPlayer(), ISBuildMenu.cursor.sq) then
            return false
        end
        return ParadiseZ.ISBuildMenuisMultiStageValid()
    end
    
    ParadiseZ.ISBuildCursorMouserender = ISBuildCursorMouse.render
    function ISBuildCursorMouse:render(x, y, z, square)
        if SandboxVars.ParadiseZ.isSafeAllowActions and ParadiseZ.isAdm() then 
            return ParadiseZ.ISBuildCursorMouserender(self, x, y, z, square)
        end
        self.sq = square;
        if self.sprite or self.previousSprite then
            if not self.sprite then
                self.sprite = self.previousSprite;
            end
            self.previousSprite = self.sprite;
            ISBuildCursorMouse.spriteRender = IsoSprite.new()
            ISBuildCursorMouse.spriteRender:LoadFramesNoDirPageSimple(self.sprite)
            local r,g,b,a = 0.0,1.0,0.0,0.8
            if not self:isValid(square) or ParadiseZ.isSafePlorSq(self.character, square)  then
                r = 1.0
                g = 0.0
            end
            ISBuildCursorMouse.spriteRender:RenderGhostTileColor(x, y, z, r, g, b, a)
        end      
        self:renderTooltip();
    end


    ParadiseZ.ISBuildCursorMousecreate = ISBuildCursorMouse.create
    function ISBuildCursorMouse:create(x, y, z, north, sprite)
        if SandboxVars.ParadiseZ.isSafeAllowActions and ParadiseZ.isAdm() then 
            return ParadiseZ.ISBuildCursorMousecreate(self, x, y, z, north, sprite)
        end
        local sq = getWorld():getCell():getGridSquare(x, y, z)
        if ParadiseZ.isSafePlorSq(self.character, sq) then
            return
        end
        ParadiseZ.ISBuildCursorMousecreate(self, x, y, z, north, sprite)
        --self:hideTooltip();
        --self:onSquareSelected(getWorld():getCell():getGridSquare(x, y, z))
    end


    ParadiseZ.ISBuildMenucanBuild = ISBuildMenu.canBuild
    function ISBuildMenu.canBuild(plankNb, nailsNb, hingeNb, doorknobNb, baredWireNb, carpentrySkill, option, player)
        if SandboxVars.ParadiseZ.isSafeAllowActions and ParadiseZ.isAdm() then 
            return ParadiseZ.ISBuildMenucanBuild(self, plankNb, nailsNb, hingeNb, doorknobNb, baredWireNb, carpentrySkill, option, player)
        end
        local tooltip = ParadiseZ.ISBuildMenucanBuild(
            plankNb,
            nailsNb,
            hingeNb,
            doorknobNb,
            baredWireNb,
            carpentrySkill,
            option,
            player
        )

        if not option or not player then
            return tooltip
        end

        local pl = getSpecificPlayer(player)
        if not pl then
            return tooltip
        end

        local sq = pl:getSquare()
        if ParadiseZ.isSafePlorSq(pl, sq) then
            option.onSelect = nil
            option.notAvailable = true

            if tooltip then
                tooltip.description = "<LINE><RGB:1,0,0>Protected Zone<LINE>"
            end
        end

        return tooltip
    end


    ParadiseZ.ISMoveableCursorisValid = ISMoveableCursor.isValid
    function ISMoveableCursor:isValid(sq)
        if SandboxVars.ParadiseZ.isSafeAllowActions and ParadiseZ.isAdm() then 
            return ParadiseZ.ISMoveableCursorisValid(self, sq)
        end
        if ParadiseZ.isSafePlorSq(self.character, sq) then 
            return false
        end
        return ParadiseZ.ISMoveableCursorisValid(self, sq)
    end

    ParadiseZ.ISMoveablesActionisValidObject = ISMoveablesAction.isValidObject
    function ISMoveablesAction:isValidObject()
        if SandboxVars.ParadiseZ.isSafeAllowActions and ParadiseZ.isAdm() then 
            return ParadiseZ.ISMoveablesActionisValidObject(self)
        end
        if (not self.square) then return false; end;
        if ParadiseZ.isSafePlorSq(self.character, self.square) then 
            return false
        end
        return ParadiseZ.ISMoveablesActionisValidObject(self)
    end
    

    ParadiseZ.ISUnbarricadeActionisValid = ISUnbarricadeAction.isValid
    function ISUnbarricadeAction:isValid()
        if SandboxVars.ParadiseZ.isSafeAllowActions and ParadiseZ.isAdm() then 
            return ParadiseZ.ISUnbarricadeActionisValid(self)
        end
        if self.character and self.item and ParadiseZ.isSafePlorSq(self.character, self.item:getSquare()) then
            return false
        end
        return ParadiseZ.ISUnbarricadeActionisValid(self)
    end

    ParadiseZ.ISDestroyCursorisValid = ISDestroyCursor.isValid
    function ISDestroyCursor:isValid(sq)
        if SandboxVars.ParadiseZ.isSafeAllowActions and ParadiseZ.isAdm() then 
            return ParadiseZ.ISDestroyCursorisValid(self, sq)
        end
        if ParadiseZ.isSafePlorSq(self.character, sq) then 
            return false
        end
        return ParadiseZ.ISDestroyCursorisValid(self, sq)
    end

    ParadiseZ.ISDestroyCursorcanDestroy = ISDestroyCursor.canDestroy
    function ISDestroyCursor:canDestroy(obj)
        if SandboxVars.ParadiseZ.isSafeAllowActions and ParadiseZ.isAdm() then 
            return ParadiseZ.ISDestroyCursorcanDestroy(self, obj)
        end
        if ParadiseZ.isAdm() then
            return ParadiseZ.ISDestroyCursorcanDestroy(self, obj)
        end
        local sq = obj:getSquare()
        if obj and sq and ParadiseZ.isSafePlorSq(self.character, sq) then
            return false
        end
        return ParadiseZ.ISDestroyCursorcanDestroy(self, obj)
    end
    
    ParadiseZ.ISMoveablesActionisValid = ISMoveablesAction.isValid
    function ISMoveablesAction:isValid()
        if SandboxVars.ParadiseZ.isSafeAllowActions and ParadiseZ.isAdm() then 
            return ParadiseZ.ISMoveablesActionisValid(self)
        end
        if ParadiseZ.isAdm() or not self.moveProps or (self.mode and not (self.mode == "scrap" or self.mode == "pickup")) then
            return ParadiseZ.ISMoveablesActionisValid(self)
        end
        if ParadiseZ.isSafePlorSq(self.character, self.square) then 
            return false
        end
        return ParadiseZ.ISMoveablesActionisValid(self)
    end
end)
-----------------------            ---------------------------
function ParadiseZ.hookSafety()
    function ISSafetyUI:onMouseUp(x, y)
        ParadiseZ.doToggle()
    end
    Events.OnKeyPressed.Remove(ISSafetyUI.onKeyPressed);
    function ISSafetyUI.onKeyPressed(key)
        if key == getCore():getKey("Toggle Safety") then
            ParadiseZ.doToggle()                
        end
    end
    Events.OnKeyPressed.Add(ISSafetyUI.onKeyPressed);
    ParadiseZ.CheckSafetyHook = true
end
Events.OnInitGlobalModData.Add(ParadiseZ.hookSafety)


--[[ ParadiseZ.getIngameDateTime()
ParadiseZ.getServerRealWorldDateTime() ]]