

-----------------------            ---------------------------
Events.OnCreatePlayer.Add(function()    
    if not getCore():getDebug() then return end

    function BrushToolTilePickerList:onMouseDown(x, y)
        local c = math.floor(x / 64)
        local r = math.floor(y / 128)
        if c >= 0 and c < 8 and r >= 0 and r < 128 then
            if self.posToTileNameTable[r+1] ~= nil and self.posToTileNameTable[r+1][c+1] ~= nil then
                local cursor = ISBrushToolTileCursor:new(self.posToTileNameTable[r+1][c+1], self.posToTileNameTable[r+1][c+1], self.character)
                getCell():setDrag(cursor, self.character:getPlayerNum())
            end
        end
    end
    
    function ISDestroyStuffAction:isValid()
        if ISBuildMenu.cheat then return true end
        local sledgehammer = self.character:getInventory():getFirstEvalRecurse(predicateSledgehammer)
        if not sledgehammer then return false end
        --ensure the player hasn't moved too far away while the action was in queue
        local diffX = math.abs(self.item:getSquare():getX() + 0.5 - self.character:getX());
        local diffY = math.abs(self.item:getSquare():getY() + 0.5 - self.character:getY());
        return self.item:getObjectIndex() ~= -1 and (diffX <= 1.6 and diffY <= 1.6);
    end

    Events.OnPreFillWorldObjectContextMenu.Remove(smashammerMenu)
    
-----------------------            ---------------------------
    HF_PointBlank = HF_PointBlank or {}
    HF_PointBlank.SETTINGS = HF_PointBlank.SETTINGS or {}

    HF_PointBlank.SETTINGS.DEBUG = false;
    HF_PointBlank.SETTINGS.bAreLogMessagesEnabled = false;
    HF_PointBlank.SETTINGS.DEBUG_SPEAK = false
    HF_PointBlank.SETTINGS.DEBUG_LOG_CanPlayerPerformPointBlankAttack = false
    HF_PointBlank.bPrintEventMessages = false
    HF_PointBlank.POINT_BLANK_IS_ADV_TRAJ_ENABLED = false
    function HF_PointBlank.FlushPointBlankAttackCheckMessage() return end
    function HF_PointBlank.printLogMsg() return end
    function HF_PointBlank.DebugSay() return end
    function HF_PointBlank.printLogMsgWithBool() return end
    function HF_PointBlank.LogEvent_PointBlankOnWeaponSwingHitPoint() return end
    function HF_PointBlank.LogEvent_PointBlankOnPlayerDealtDamageToZombie() return end
    function HF_PointBlank.LogEvent_PointBlankOnHitZombie() return end
    function HF_PointBlank.printLogMsgWithTable() return end
    function HF_PointBlank.printPointBlankSettings() return end
    -----------------------            ---------------------------

    TOC_DEBUG = TOC_DEBUG or {}
    function TOC_DEBUG.print()
        return
    end
    function TOC_DEBUG.printTable()
        return
    end
    -----------------------            ---------------------------
    BM_Logger = BM_Logger or {}
    function BM_Logger:debug()
        return
    end
    function BM_Logger:info()
        return
    end
    function BM_Logger.warning()
        return
    end
    function BM_Logger:error()
        return
    end

    BM_Utils = BM_Utils or {}
    function BM_Utils.printPropNamesFromSprite()
        return
    end


    -----------------------            ---------------------------

    TrainingTarget = TrainingTarget or {}

    function TrainingTarget.ProcessFirearm(character, targetObject, shootPos)
        local distance = getCell():getGridSquare(character:getX(), character:getY(), character:getZ()):DistTo(shootPos)
        if distance <= 2 then
            character:Say(getText("ContextMenu_This_is_too_close"))
            return
        end
        if not TrainingTarget.IsTargetStateGood(targetObject, TrainingTarget.currentTargetType) then
            if TrainingTarget.currentTargetType == TrainingTarget.TrainingTypes.CAN_TARGET then
                character:Say(getText("ContextMenu_Target_must_be_refilled"))
            else
                character:Say(getText("ContextMenu_Target_is_damaged"))
            end
            return
        end
        local chance = ZombRand(1, ((9 - character:getPerkLevel(Perks.Aiming) * 5 + distance * 2)))
        if chance <= 10 then
            character:Say(getText("ContextMenu_Ive_hit_something"))
            TrainingTarget.SetXPForAimingPerk(character, distance, TrainingTarget.currentTargetType)
            TrainingTarget.ManageTargetState(targetObject, TrainingTarget.currentTargetType)
            TrainingTarget.PlaySoundForTrainingType(character, TrainingTarget.currentTargetType)
        else
            character:Say(getText("ContextMenu_Ive_missed"))
        end
    end

    function TrainingTarget.OnObjectAdded(object)
        if TrainingTarget.IsDummyTarget(object) then
            object:setHealth(900)
            object:setMaxHealth(900)
            object:setIsDoor(true)
        end
    end
    function TrainingTarget.GetTargetObject(shootPos)
        local targetObject = nil
        for i = 1, shootPos:getObjects():size() do
            local thisObject = shootPos:getObjects():get(i - 1)
            if thisObject ~= nil and (TrainingTarget.IsTarget(thisObject) or TrainingTarget.IsCanTarget(thisObject) or TrainingTarget.IsMobileTarget(thisObject) or TrainingTarget.IsDummyTarget(thisObject)) then
                targetObject = thisObject
            end
        end
        return targetObject
    end

end)
