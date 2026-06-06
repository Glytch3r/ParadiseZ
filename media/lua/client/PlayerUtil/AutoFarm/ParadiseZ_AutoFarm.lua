
do
    pcall(require, "TimedActions/ISBaseTimedAction")
    pcall(require, "TimedActions/ISWalkToTimedAction")
    pcall(require, "TimedActions/ISInventoryTransferAction")
    pcall(require, "TimedActions/ISEquipWeaponAction")
    pcall(require, "Farming/ISUI/ISFarmingMenu")
    pcall(require, "Farming/TimedActions/ISWaterPlantAction")
    pcall(require, "Farming/TimedActions/ISCureMildewAction")
    pcall(require, "Farming/TimedActions/ISCureFliesAction")
    pcall(require, "Farming/TimedActions/ISHarvestPlantAction")
    pcall(require, "Farming/TimedActions/ISSeedAction")
    pcall(require, "Farming/TimedActions/ISPlowAction")
    pcall(require, "Farming/TimedActions/ISShovelAction")
    pcall(require, "Farming/farming_vegetableconf")
    pcall(require, "ISUI/ISCollapsableWindow")
    pcall(require, "ISUI/ISButton")
    pcall(require, "ISUI/ISComboBox")
    pcall(require, "ISUI/ISLabel")

    ParadiseZ_AutoFarm = {
        VERSION = "ParadiseZ_AutoFarm",

        ENABLED = true,
        SANDBOX_ROOT = "ParadiseZ",

        CROP_RADIUS = 5,
        WATER_SOURCE_RADIUS = 15,
        ENABLE_WATER_TILE_FALLBACK = true,
        WATER_TILE_FALLBACK_ONLY_IF_NO_OBJECT_SOURCES = true,
        WATER_TILE_TAINTED = true,

        INDEX_TOTAL_TIME = 120,
        INDEX_SQUARES_PER_UPDATE = 5,

        EMPTY_CAN = "farming.WateredCan",
        FULL_CAN = "farming.WateredCanFull",

        MILDEW_SPRAY = "farming.GardeningSprayMilk",
        FLIES_SPRAY = "farming.GardeningSprayCigarettes",
        EMPTY_SPRAY = "farming.GardeningSprayEmpty",

        NORMAL_TARGET = 100,
        NORMAL_SKIP_AT = 95,
        SENSITIVE_TARGET = 75,
        SENSITIVE_SKIP_AT = 71,
        EMPTY_PLOT_TARGET = 70,
        EMPTY_PLOT_SKIP_AT = 66,
        DEVIL_WATER_ONLY_AT_OR_BELOW = 54,
        DEVIL_TARGET = 59,
        DEVIL_SKIP_AT = 55,

        WATER_MAX_USE_PER_ACTION = 20,
        CAN_RESERVE_USES = 1,
        DEFAULT_EMPTY_CAN_MAX_USES = 40,
        REFILL_TIME_PER_USE = 5,
        MIN_ACTION_TIME = 30,

        TREAT_INCREMENT = 5,
        EXACT_DISEASE_LEVEL = 10,
        LOW_KNOWLEDGE_TREAT_USES = 1,
        MAX_TREAT_ATTEMPTS_PER_CROP_FIELD = 4,
        RECHECK_TIME = 20,

        FURROW_RADIUS = 5,
        FURROW_TIME = 100,

        INTERRUPT_CANCEL_MS = 9000,
        WATCHDOG_TICKS = 240,
        WATCHDOG_STALL_MS = 36000,
        WATCHDOG_LOG_ACTIVE = false,
        HARVEST_QUEUE_GAP_RESUME_MS = 8000,
        HARVEST_QUEUE_GAP_CANCEL_DIST = 8,

        TEND_INCLUDE_DIG_DEFAULT = false,
        TEND_INCLUDE_TREAT_DEFAULT = true,
        TEND_INCLUDE_WATER_DEFAULT = true,
        TRUST_QUEUED_ACTIONS = true,

        SOFT_EQUIP_WATER_CAN = true,
        WATER_LOCAL_MARK = true,

        OPTION_ROOT = "Auto-Farm",

        FURROW_PATTERN_FULL_SPACED = "Full Spaced",
        FURROW_PATTERN_CHECKER = "Checker Board",
        FURROW_PATTERN_NS_ROWS = "N/S Rows",
        FURROW_PATTERN_EW_ROWS = "E/W Rows",
        FURROW_PATTERN_FULL = "Full",

        currentFurrowPattern = "Full Spaced",
        showAutoFarmHighlight = true,
        highlightCollector = nil,
        highlightWindow = nil,
        highlightLineFailed = false,

        job = nil,
        watchTicks = 0,
        lastStepMs = 0,
        lastStepLabel = "install"
    }

    local AW = ParadiseZ_AutoFarm

    function AW.boolSetting(vars, name, default)
        local value = vars and vars[name]
        if value == nil then return default end
        return value == true
    end

    function AW.intSetting(vars, name, default, minValue, maxValue)
        local value = tonumber(vars and vars[name]) or default
        value = math.floor(value)
        if minValue ~= nil and value < minValue then value = minValue end
        if maxValue ~= nil and value > maxValue then value = maxValue end
        return value
    end

    function AW.farmRadiusFromSetting(value)
        local v = tonumber(value)
        if v == 1 then return 3 end
        if v == 2 then return 5 end
        if v == 3 then return 7 end
        if v == 5 then return 5 end
        if v == 7 then return 7 end
        return 5
    end

    function AW.applySandboxSettings()
        local vars = SandboxVars and SandboxVars[AW.SANDBOX_ROOT or "ParadiseZ"]
        if not vars then return end
        AW.ENABLED = AW.boolSetting(vars, "AutoFarmEnabled", true)
        AW.CROP_RADIUS = AW.farmRadiusFromSetting(vars.AutoFarmCropRadius)
        AW.FURROW_RADIUS = AW.CROP_RADIUS
        AW.WATER_SOURCE_RADIUS = AW.intSetting(vars, "AutoFarmWaterSourceRadius", 15, 5, 25)
        AW.ENABLE_WATER_TILE_FALLBACK = AW.boolSetting(vars, "AutoFarmWaterTileFallback", true)
        AW.FEATURE_AUTO_REPLANT = not AW.boolSetting(vars, "AutoFarmDisableAutoReplant", false)
        AW.FEATURE_AUTO_DIG = not AW.boolSetting(vars, "AutoFarmDisableAutoDig", false)
        AW.FEATURE_AUTO_TREAT = not AW.boolSetting(vars, "AutoFarmDisableAutoTreat", false)
        AW.FEATURE_AUTO_HARVEST = not AW.boolSetting(vars, "AutoFarmDisableAutoHarvest", false)
        AW.FEATURE_AUTO_CLEAR_RECEDING = not AW.boolSetting(vars, "AutoFarmDisableAutoClearReceding", false)
        if AW.refreshAutoFarmRangeSettings then AW.refreshAutoFarmRangeSettings() end
    end

    AW.applySandboxSettings()

    AW.furrowPatternNames = {
        AW.FURROW_PATTERN_FULL_SPACED,
        AW.FURROW_PATTERN_CHECKER,
        AW.FURROW_PATTERN_NS_ROWS,
        AW.FURROW_PATTERN_EW_ROWS,
        AW.FURROW_PATTERN_FULL
    }

    function AW.nowMs()
        if getTimestampMs then return getTimestampMs() end
        if os and os.time then return os.time() * 1000 end
        return 0
    end

    function AW.num(v, default)
        local n = tonumber(v)
        if n == nil then return default end
        return n
    end


    function AW.touch(label)
        AW.lastStepMs = AW.nowMs()
        AW.lastStepLabel = tostring(label or "step")
    end

    function AW.startsWithText(s, prefix)
        s = tostring(s or "")
        prefix = tostring(prefix or "")
        return string.sub(s, 1, string.len(prefix)) == prefix
    end

    function AW.isQueuedJobLabel(label)
        return AW.startsWithText(tostring(label or ""), "queued-")
    end

    function AW.player(playerNum)
        return getSpecificPlayer(playerNum or 0) or getPlayer()
    end

    function AW.ft(item) if not item then return "" end return tostring(item:getFullType() or "") end
    function AW.ty(item) if not item then return "" end return tostring(item:getType() or "") end
    function AW.dn(item) if not item then return "" end return tostring(item:getDisplayName() or "") end
    function AW.itemText(item) return string.lower(AW.ft(item) .. " " .. AW.ty(item) .. " " .. AW.dn(item)) end

    function AW.isDrainable(item)
        if not item or not instanceof then return false end
        return instanceof(item, "DrainableComboItem") == true
    end

    function AW.itemUses(item)
        if not AW.isDrainable(item) then return 0 end
        local usedDelta = AW.num(item:getUsedDelta(), 0)
        local useDelta = AW.num(item:getUseDelta(), 0)
        if useDelta <= 0 then return 0 end
        return math.max(0, math.floor((usedDelta / useDelta) + 0.00001))
    end

    function AW.itemMaxUses(item)
        if not AW.isDrainable(item) then return 0 end
        local useDelta = AW.num(item:getUseDelta(), 0)
        if useDelta <= 0 then return 0 end
        return math.max(1, math.floor((1 / useDelta) + 0.00001))
    end

    function AW.setItemUses(item, uses)
        if not AW.isDrainable(item) then return false end
        local useDelta = AW.num(item:getUseDelta(), 0)
        if useDelta <= 0 then return false end
        item:setUsedDelta(math.max(0, math.min(1, math.floor(AW.num(uses, 0)) * useDelta)))
        return true
    end

    function AW.copyCondition(fromItem, toItem)
        if not fromItem or not toItem then return end
        local condition = fromItem:getCondition()
        if condition ~= nil then toItem:setCondition(condition) end
    end

    function AW.isEmptyCan(item) return item ~= nil and AW.ft(item) == AW.EMPTY_CAN end
    function AW.isFullCan(item) return item ~= nil and AW.ft(item) == AW.FULL_CAN and AW.isDrainable(item) end

    function AW.isWateringCan(item)
        if AW.isEmptyCan(item) or AW.isFullCan(item) then return true end
        local text = AW.itemText(item)
        return string.find(text, "watering", 1, true) and string.find(text, "can", 1, true)
    end

    function AW.canUses(item) if not AW.isFullCan(item) then return 0 end return AW.itemUses(item) end

    function AW.canMaxUses(item)
        if not AW.isFullCan(item) then return AW.DEFAULT_EMPTY_CAN_MAX_USES end
        local maxUses = AW.itemMaxUses(item)
        if maxUses <= 0 then return AW.DEFAULT_EMPTY_CAN_MAX_USES end
        return maxUses
    end

    function AW.setCanUses(item, uses) if not AW.isFullCan(item) then return false end return AW.setItemUses(item, uses) end
    function AW.isTainted(item) if not AW.isFullCan(item) then return false end return item:isTaintedWater() == true end
    function AW.setTainted(item, tainted) if not AW.isFullCan(item) then return false end item:setTaintedWater(tainted == true) return true end

    function AW.canSummary(item)
        if not item then return "nil" end
        return AW.ft(item) ..
            " uses=" .. tostring(AW.canUses(item)) .. "/" .. tostring(AW.canMaxUses(item)) ..
            " tainted=" .. tostring(AW.isTainted(item)) ..
            " empty=" .. tostring(AW.isEmptyCan(item)) ..
            " full=" .. tostring(AW.isFullCan(item))
    end

    function AW.invItemsRecursive(inv, predicate)
        local out = {}
        local ok, list = pcall(function()
            return inv:getAllEvalRecurse(function(item) return predicate(item) end)
        end)
        if ok and list then
            for i = 0, list:size() - 1 do table.insert(out, list:get(i)) end
            return out
        end
        local items = inv:getItems()
        for i = 0, items:size() - 1 do
            local item = items:get(i)
            if predicate(item) then table.insert(out, item) end
        end
        return out
    end

    function AW.getWateringCans(playerObj) return AW.invItemsRecursive(playerObj:getInventory(), AW.isWateringCan) end

    function AW.findCanWithMostWater(playerObj)
        local best, bestUses = nil, 0
        for _, can in ipairs(AW.getWateringCans(playerObj)) do
            local uses = AW.canUses(can)
            if AW.isFullCan(can) and uses > bestUses then
                best, bestUses = can, uses
            end
        end
        return best, bestUses
    end

    function AW.getFillableCans(playerObj)
        local out = {}
        for _, can in ipairs(AW.getWateringCans(playerObj)) do
            if AW.isEmptyCan(can) then
                table.insert(out, can)
            elseif AW.isFullCan(can) and AW.canUses(can) < AW.canMaxUses(can) then
                table.insert(out, can)
            end
        end
        table.sort(out, function(a, b)
            local ae, be = AW.isEmptyCan(a), AW.isEmptyCan(b)
            if ae ~= be then return ae end
            return AW.canUses(a) < AW.canUses(b)
        end)
        return out
    end

    function AW.hasFillableCan(playerObj) return #AW.getFillableCans(playerObj) > 0 end

    function AW.findPreferredCan(playerObj)
        if AW.job and AW.job.preferredWaterCan then
            local can = AW.job.preferredWaterCan
            if AW.isFullCan(can) and AW.canUses(can) > AW.CAN_RESERVE_USES then
                return can, AW.canUses(can)
            end
            AW.job.preferredWaterCan = nil
        end
        local can, uses = AW.findCanWithMostWater(playerObj)
        if AW.job then AW.job.preferredWaterCan = can end
        return can, uses
    end

    function AW.squareObjects(square, fn)
        if not square then return end
        local objects = square:getObjects()
        if not objects then return end
        for i = 0, objects:size() - 1 do fn(objects:get(i)) end
    end

    function AW.objWaterAmount(obj)
        if not obj then return 0 end
        local ok, value = pcall(function() return obj:getWaterAmount() end)
        if ok then return AW.num(value, 0) end
        return 0
    end

    function AW.objWaterMax(obj)
        if not obj then return 0 end
        local ok, value = pcall(function() return obj:getWaterMax() end)
        if ok then return AW.num(value, 0) end
        return 0
    end

    function AW.objNameText(obj)
        if not obj then return "" end
        local s = ""
        local okObjName, objectName = pcall(function() return obj:getObjectName() end)
        if okObjName and objectName then s = s .. " " .. tostring(objectName) end
        local okName, name = pcall(function() return obj:getName() end)
        if okName and name then s = s .. " " .. tostring(name) end
        local okSprite, sprite = pcall(function() return obj:getSprite() end)
        if okSprite and sprite then
            local okSpriteName, spriteName = pcall(function() return sprite:getName() end)
            if okSpriteName and spriteName then s = s .. " " .. tostring(spriteName) end
        end
        return string.lower(s)
    end

    function AW.isWaterObject(obj)
        if not obj then return false end
        return AW.objWaterMax(obj) > 0 or AW.objWaterAmount(obj) > 0
    end

    function AW.isWaterCollector(obj)
        if not AW.isWaterObject(obj) then return false end
        local text = AW.objNameText(obj)
        if string.find(text, "rain", 1, true) then return true end
        if string.find(text, "collector", 1, true) then return true end
        if string.find(text, "barrel", 1, true) then return true end
        if string.find(text, "water", 1, true) then return true end
        if string.find(text, "sink", 1, true) then return true end
        if string.find(text, "faucet", 1, true) then return true end
        if string.find(text, "well", 1, true) then return true end
        if string.find(text, "dispenser", 1, true) then return true end
        if string.find(text, "toilet", 1, true) then return true end
        if string.find(text, "bath", 1, true) then return true end
        if string.find(text, "tub", 1, true) then return true end
        return false
    end

    function AW.isRefillSourceObject(obj)
        if not obj then return false end
        if AW.objWaterAmount(obj) <= 0 then return false end
        return AW.isWaterCollector(obj)
    end

    function AW.objKey(obj)
        if not obj then return "nil" end
        return tostring(math.floor(AW.num(obj:getX(), 0))) .. "," ..
            tostring(math.floor(AW.num(obj:getY(), 0))) .. "," ..
            tostring(math.floor(AW.num(obj:getZ(), 0)))
    end

    function AW.squareKey(square)
        if not square then return "nil" end
        return tostring(square:getX()) .. "," .. tostring(square:getY()) .. "," .. tostring(square:getZ())
    end

    function AW.sourceKey(source)
        if not source then return "nil" end
        if source.kind == "waterTile" then return "waterTile@" .. AW.squareKey(source.square) end
        return tostring(source.kind) .. "@" .. AW.objKey(source.obj)
    end

    function AW.sourceSquare(source)
        if not source then return nil end
        if source.kind == "waterTile" then return source.square end
        if source.obj then return source.obj:getSquare() end
        return nil
    end

    function AW.sourceWater(source)
        if not source then return 0 end
        if source.kind == "waterTile" then return 999999 end
        return AW.objWaterAmount(source.obj)
    end

    function AW.sourceTainted(source)
        if not source then return false end
        if source.kind == "waterTile" then return AW.WATER_TILE_TAINTED == true end
        local ok, value = pcall(function() return source.obj:isTaintedWater() end)
        if ok then return value == true end
        return false
    end

    function AW.sourceSummary(source)
        if not source then return "nil" end
        if source.kind == "waterTile" then
            return "waterTile@" .. AW.squareKey(source.square) ..
                " water=infinite tainted=" .. tostring(AW.sourceTainted(source)) ..
                " reason={" .. tostring(source.reason or "unknown") .. "}"
        end
        return tostring(source.kind) .. "@" .. AW.objKey(source.obj) ..
            " water=" .. tostring(AW.sourceWater(source)) .. "/" .. tostring(AW.objWaterMax(source.obj)) ..
            " tainted=" .. tostring(AW.sourceTainted(source)) ..
            " name={" .. AW.objNameText(source.obj) .. "}"
    end

    function AW.makeSourceFromObject(obj)
        if not AW.isRefillSourceObject(obj) then return nil end
        return { kind = AW.isWaterCollector(obj) and "collector" or "waterObject", obj = obj }
    end

    function AW.useSourceWater(source, units)
        units = math.max(0, math.floor(AW.num(units, 0)))
        if not source or units <= 0 then return 0 end
        if source.kind == "waterTile" then return units end
        local before = AW.sourceWater(source)
        local used = math.min(before, units)
        if used <= 0 then return 0 end
        local okUse = pcall(function() source.obj:useWater(used) end)
        if okUse then return used end
        local okSet = pcall(function() source.obj:setWaterAmount(math.max(0, before - used)) end)
        if okSet then return used end

        return 0
    end

    function AW.isSafeWaterTile(square)
        if not square then return false, "missing square" end
        local okProps, props = pcall(function() return square:getProperties() end)
        if okProps and props then
            if IsoFlagType and IsoFlagType.water then
                local okFlag, flagResult = pcall(function() return props:Is(IsoFlagType.water) end)
                if okFlag and flagResult == true then return true, "square property IsoFlagType.water" end
            end
            local okStringWater, stringWater = pcall(function() return props:Is("water") end)
            if okStringWater and stringWater == true then return true, "square property water" end
            local okStringWaterCap, stringWaterCap = pcall(function() return props:Is("Water") end)
            if okStringWaterCap and stringWaterCap == true then return true, "square property Water" end
        end
        local okFloor, floor = pcall(function() return square:getFloor() end)
        if okFloor and floor then
            local okSprite, sprite = pcall(function() return floor:getSprite() end)
            if okSprite and sprite then
                local okName, name = pcall(function() return sprite:getName() end)
                if okName and name then
                    local lower = string.lower(tostring(name))
                    if string.find(lower, "water", 1, true) then return true, "floor sprite contains water: " .. tostring(name) end
                end
                local okSpriteProps, spriteProps = pcall(function() return sprite:getProperties() end)
                if okSpriteProps and spriteProps then
                    if IsoFlagType and IsoFlagType.water then
                        local okFlag, flagResult = pcall(function() return spriteProps:Is(IsoFlagType.water) end)
                        if okFlag and flagResult == true then return true, "floor sprite property IsoFlagType.water" end
                    end
                    local okString, stringResult = pcall(function() return spriteProps:Is("water") end)
                    if okString and stringResult == true then return true, "floor sprite property water" end
                end
            end
        end
        return false, "not detected as safe water tile"
    end

    function AW.scanWaterTileFallback(centerObj)
        local found, seen = {}, {}
        if not AW.ENABLE_WATER_TILE_FALLBACK then

            return found
        end
        local cx = math.floor(AW.num(centerObj:getX(), 0))
        local cy = math.floor(AW.num(centerObj:getY(), 0))
        local cz = math.floor(AW.num(centerObj:getZ(), 0))
        local cell = getCell()
        for y = cy - AW.WATER_SOURCE_RADIUS, cy + AW.WATER_SOURCE_RADIUS do
            for x = cx - AW.WATER_SOURCE_RADIUS, cx + AW.WATER_SOURCE_RADIUS do
                local square = cell:getGridSquare(x, y, cz)
                if square then
                    local ok, reason = AW.isSafeWaterTile(square)
                    if ok then
                        local source = { kind = "waterTile", square = square, reason = reason }
                        local key = AW.sourceKey(source)
                        if not seen[key] then
                            seen[key] = true
                            table.insert(found, source)

                        end
                    end
                end
            end
        end

        return found
    end

    function AW.addWaterTileFallbackIfNeeded(sources, centerObj)
        sources = sources or {}
        if #sources > 0 and AW.WATER_TILE_FALLBACK_ONLY_IF_NO_OBJECT_SOURCES then

            return sources
        end
        local fallbackSources = AW.scanWaterTileFallback(centerObj)
        for _, source in ipairs(fallbackSources) do table.insert(sources, source) end
        if #fallbackSources > 0 then

        else

        end
        return sources
    end

    function AW.findCollectorFromWorldObjects(worldobjects)
        local found = nil
        for _, obj in ipairs(worldobjects or {}) do
            if AW.isWaterCollector(obj) then return obj end
            local square = nil
            pcall(function() square = obj:getSquare() end)
            if square then
                AW.squareObjects(square, function(o)
                    if not found and AW.isWaterCollector(o) then found = o end
                end)
            end
            if found then return found end
        end
        return nil
    end

    function AW.totalSourceWater()
        if not AW.job or not AW.job.sources then return 0 end
        local total = 0
        for _, source in ipairs(AW.job.sources or {}) do
            local water = AW.sourceWater(source)
            if water >= 999999 then return 999999 end
            total = total + water
        end
        return total
    end

    function AW.bestSource(playerObj)
        if not AW.job then return nil end
        local px, py = math.floor(playerObj:getX()), math.floor(playerObj:getY())
        local best, bestDist = nil, 999999
        for _, source in ipairs(AW.job.sources or {}) do
            if AW.sourceWater(source) > 0 then
                local square = AW.sourceSquare(source)
                if square then
                    local d = math.abs(square:getX() - px) + math.abs(square:getY() - py)
                    if d < bestDist then best, bestDist = source, d end
                end
            end
        end
        if best then  end
        return best
    end

    function AW.plantAt(x, y, z)
        if not CFarmingSystem or not CFarmingSystem.instance then return nil end
        return CFarmingSystem.instance:getLuaObjectAt(x, y, z)
    end

    function AW.isEmptyPlot(plant)
        if not plant then return false end
        local state = string.lower(tostring(plant.state or ""))
        local seed = string.lower(tostring(plant.typeOfSeed or ""))
        if state == "plow" then return true end
        if seed == "none" or seed == "no seed" then return true end
        if seed == "nil" and state == "plow" then return true end
        return false
    end

    function AW.isRecedingPlant(plant)
        if not plant then return false end
        if AW.isEmptyPlot(plant) then return false end

        local state = string.lower(tostring(plant.state or ""))
        if state == "dry" or state == "dead" or state == "rotten" or
           state == "destroyed" or state == "destroy" or state == "receding" then
            return true
        end

        local health = AW.num(plant.health, nil)
        if health ~= nil and health <= 0 then return true end

        return false
    end

    function AW.isSeededPlant(plant)
        if not plant then return false end
        if AW.isEmptyPlot(plant) then return false end
        local seed = tostring(plant.typeOfSeed or "")
        return seed ~= "" and seed ~= "nil" and seed ~= "none" and seed ~= "no seed"
    end

    function AW.invalidPlant(plant)
        if not plant then return true end
        local state = string.lower(tostring(plant.state or ""))
        if state == "rotten" or state == "destroyed" or state == "destroy" then return true end
        if AW.isEmptyPlot(plant) then return false end
        if plant.typeOfSeed == nil or tostring(plant.typeOfSeed) == "" then return true end
        return false
    end

    function AW.field(tbl, names)
        for _, name in ipairs(names or {}) do
            if tbl[name] ~= nil then return name, AW.num(tbl[name], 0) end
        end
        return nil, 0
    end

    function AW.diseaseInfo(plant)
        if not plant then return { mildewField = nil, mildew = 0, fliesField = nil, flies = 0, devilField = nil, devil = 0 } end
        local mildewField, mildew = AW.field(plant, { "mildewLvl", "mildewLevel", "mildew" })
        local fliesField, flies = AW.field(plant, { "fliesLvl", "flyLvl", "pestFliesLvl", "pestFlyLvl", "flies", "fly" })
        local devilField, devil = AW.field(plant, { "aphidLvl", "aphidsLvl", "aphidLevel", "aphidsLevel", "aphid", "aphids" })
        return { mildewField = mildewField, mildew = mildew, fliesField = fliesField, flies = flies, devilField = devilField, devil = devil }
    end

    function AW.rawDisease(plant)
        local out = {}
        for k, v in pairs(plant) do
            local s = string.lower(tostring(k))
            if string.find(s, "mildew", 1, true) or string.find(s, "flies", 1, true) or
               string.find(s, "fly", 1, true) or string.find(s, "aphid", 1, true) or
               string.find(s, "fungus", 1, true) or string.find(s, "water", 1, true) then
                table.insert(out, tostring(k) .. "=" .. tostring(v))
            end
        end
        if #out == 0 then return "none" end
        table.sort(out)
        return table.concat(out, ",")
    end

    function AW.cropConfig(seed)
        if farming_vegetableconf and farming_vegetableconf.props then return farming_vegetableconf.props[seed] end
        return nil
    end

    function AW.isSensitiveBase(seed, maxSafe)
        local s = string.lower(tostring(seed or ""))
        if string.find(s, "carrot", 1, true) then return true end
        if string.find(s, "radish", 1, true) then return true end
        if AW.num(maxSafe, 100) < 100 then return true end
        return false
    end

    function AW.cropPlan(plant, cropKey)
        if AW.invalidPlant(plant) then return false, 0, 0, 0, 0, "invalid", false, false, 100 end
        local current = AW.num(plant.waterLvl, 0)
        local seed = tostring(plant.typeOfSeed or "")
        local config = AW.cropConfig(seed)
        local maxSafe = AW.num(plant.waterNeededMax, nil)
        if maxSafe == nil and config then maxSafe = AW.num(config.waterLvlMax, nil) end
        if maxSafe == nil or maxSafe <= 0 then maxSafe = 100 end

        local disease = AW.diseaseInfo(plant)
        local devil = disease.devil and disease.devil > 0
        local emptyPlot = AW.isEmptyPlot(plant)
        local sensitive = emptyPlot or AW.isSensitiveBase(seed, maxSafe) or devil
        local target, skipAt = AW.NORMAL_TARGET, AW.NORMAL_SKIP_AT

        if emptyPlot then
            target, skipAt = AW.EMPTY_PLOT_TARGET, AW.EMPTY_PLOT_SKIP_AT
            if seed == "" then seed = "none" end
        elseif devil then
            target, skipAt = AW.DEVIL_TARGET, AW.DEVIL_SKIP_AT
        elseif sensitive then
            target, skipAt = AW.SENSITIVE_TARGET, AW.SENSITIVE_SKIP_AT
        end

        if AW.job and AW.job.localWater and cropKey and AW.job.localWater[cropKey] ~= nil then
            local predicted = AW.num(AW.job.localWater[cropKey], current)
            if predicted > current then current = predicted end
        end

        if devil then
            if current > AW.DEVIL_WATER_ONLY_AT_OR_BELOW then return false, 0, current, target, skipAt, seed, true, true, maxSafe end
            if current >= skipAt then return false, 0, current, target, skipAt, seed, true, true, maxSafe end
            return true, math.max(1, math.ceil(target - current)), current, target, skipAt, seed, true, true, maxSafe
        end

        if current >= skipAt then return false, 0, current, target, skipAt, seed, sensitive, false, maxSafe end
        return true, math.max(1, math.ceil(target - current)), current, target, skipAt, seed, sensitive, false, maxSafe
    end

    function AW.routeGreedy(crops, playerObj)
        local remaining, ordered = {}, {}
        for _, crop in ipairs(crops or {}) do table.insert(remaining, crop) end
        local px, py = math.floor(playerObj:getX()), math.floor(playerObj:getY())
        while #remaining > 0 do
            local bestIndex, bestDist = 1, 999999
            for i, crop in ipairs(remaining) do
                local d = math.abs(crop.x - px) + math.abs(crop.y - py)
                if d < bestDist then bestDist, bestIndex = d, i end
            end
            local crop = table.remove(remaining, bestIndex)
            table.insert(ordered, crop)
            px, py = crop.x, crop.y
        end

        return ordered
    end

    function AW.farmingLevel(playerObj) return AW.num(playerObj:getPerkLevel(Perks.Farming), 0) end
    function AW.canSeeExactDisease(playerObj) return AW.farmingLevel(playerObj) >= AW.EXACT_DISEASE_LEVEL end

    function AW.treatmentType(item)
        if not item then return nil end
        local fullType, itemType, text = AW.ft(item), AW.ty(item), AW.itemText(item)
        if fullType == AW.MILDEW_SPRAY or itemType == "GardeningSprayMilk" then return "mildew" end
        if fullType == AW.FLIES_SPRAY or itemType == "GardeningSprayCigarettes" then return "flies" end
        if string.find(text, "mildew", 1, true) or string.find(text, "milk", 1, true) then return "mildew" end
        if string.find(text, "flies", 1, true) or string.find(text, "fly", 1, true) or string.find(text, "cigarette", 1, true) then return "flies" end
        return nil
    end

    function AW.isUsableTreatment(item, diseaseType)
        if not item then return false end
        if AW.ft(item) == AW.EMPTY_SPRAY then return false end
        local itemDiseaseType = AW.treatmentType(item)
        if not itemDiseaseType then return false end
        if diseaseType and itemDiseaseType ~= diseaseType then return false end
        if AW.isDrainable(item) and AW.itemUses(item) <= 0 then return false end
        return true
    end

    function AW.findTreatmentItem(playerObj, diseaseType)
        local items = AW.invItemsRecursive(playerObj:getInventory(), function(item) return AW.isUsableTreatment(item, diseaseType) end)
        table.sort(items, function(a, b) return AW.itemUses(a) > AW.itemUses(b) end)
        return items[1]
    end

    function AW.treatmentSummary(item)
        if not item then return "nil" end
        return AW.ft(item) .. " name=" .. AW.dn(item) .. " type=" .. tostring(AW.treatmentType(item)) ..
            " drainable=" .. tostring(AW.isDrainable(item)) .. " uses=" .. tostring(AW.itemUses(item)) .. "/" .. tostring(AW.itemMaxUses(item))
    end

    function AW.roundTreatmentAmount(value, exact)
        local v = math.max(1, AW.num(value, 1))
        if not exact then return AW.TREAT_INCREMENT, AW.LOW_KNOWLEDGE_TREAT_USES end
        local amount = math.ceil(v / AW.TREAT_INCREMENT) * AW.TREAT_INCREMENT
        local uses = math.max(1, math.ceil(amount / AW.TREAT_INCREMENT))
        return amount, uses
    end

    function AW.nextTreatment(playerObj, plant, crop)
        local disease = AW.diseaseInfo(plant)
        if disease.devil and disease.devil > 0 then

        end
        if disease.mildew and disease.mildew > 0 then
            local item = AW.findTreatmentItem(playerObj, "mildew")
            if item then return "mildew", disease.mildewField, disease.mildew, item end

        end
        if disease.flies and disease.flies > 0 then
            local item = AW.findTreatmentItem(playerObj, "flies")
            if item then return "flies", disease.fliesField, disease.flies, item end

        end
        return nil
    end

    function AW.queueWalkAdj(playerObj, square)
        if not square then return false end
        if ISFarmingMenu and ISFarmingMenu.walkToPlant then
            local ok, result = pcall(function() return ISFarmingMenu.walkToPlant(playerObj, square) end)
            if ok then return result ~= false end

        end
        if luautils and luautils.walkAdj then
            local ok, result = pcall(function() return luautils.walkAdj(playerObj, square) end)
            if ok then return result ~= false end

        end
        if ISWalkToTimedAction then
            ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, square))
            return true
        end
        return false
    end

    function AW.queueTransferIfNeeded(playerObj, item)
        if not item or not ISInventoryTransferAction then return end
        local inv = playerObj:getInventory()
        local container = item:getContainer()
        if container and container ~= inv then

            ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, item, container, inv))
        end
    end

    function AW.waterUsesForPlan(current, target, sensitive, devil, availableUses)
        current = AW.num(current, 0)
        target = AW.num(target, 100)
        availableUses = math.max(0, math.floor(AW.num(availableUses, 0)))
        local neededWater = math.max(0, target - current)
        if neededWater <= 0 or availableUses <= 0 then return 0 end
        local uses
        if sensitive or devil then uses = math.floor(neededWater / 5) else uses = math.ceil(neededWater / 5) end
        if uses <= 0 then return 0 end
        return math.max(0, math.min(uses, availableUses, AW.WATER_MAX_USE_PER_ACTION))
    end

    ParadiseZ_AutoFarm_NextAction = ISBaseTimedAction:derive("ParadiseZ_AutoFarm_NextAction")
    function ParadiseZ_AutoFarm_NextAction:isValid() return true end
    function ParadiseZ_AutoFarm_NextAction:update() end
    function ParadiseZ_AutoFarm_NextAction:start() end
    function ParadiseZ_AutoFarm_NextAction:stop() ISBaseTimedAction.stop(self) end
    function ParadiseZ_AutoFarm_NextAction:perform()
        ISBaseTimedAction.perform(self)
        if ParadiseZ_AutoFarm and ParadiseZ_AutoFarm.step then ParadiseZ_AutoFarm.touch("next-action") ParadiseZ_AutoFarm.step() end
    end
    function ParadiseZ_AutoFarm_NextAction:new(character, time)
        local o = {}; setmetatable(o, self); self.__index = self
        o.character = character; o.maxTime = time or 1
        o.stopOnWalk = false; o.stopOnRun = false; o.stopOnAim = false
        return o
    end

    ParadiseZ_AutoFarm_PostWaterAction = ISBaseTimedAction:derive("ParadiseZ_AutoFarm_PostWaterAction")
    function ParadiseZ_AutoFarm_PostWaterAction:isValid() return true end
    function ParadiseZ_AutoFarm_PostWaterAction:update() end
    function ParadiseZ_AutoFarm_PostWaterAction:start() end
    function ParadiseZ_AutoFarm_PostWaterAction:stop() ISBaseTimedAction.stop(self) end
    function ParadiseZ_AutoFarm_PostWaterAction:perform()
        local AW2 = ParadiseZ_AutoFarm
        if AW2 and AW2.WATER_LOCAL_MARK and self.crop then
            local plant = AW2.plantAt(self.crop.x, self.crop.y, self.crop.z)
            if plant and not AW2.invalidPlant(plant) then
                local before = AW2.num(plant.waterLvl, 0)
                local cap = AW2.num(self.targetCap, 100)
                local after = math.min(cap, before + (math.max(0, AW2.num(self.uses, 0)) * 5))
                plant.waterLvl = after
                if AW2.job then
                    AW2.job.localWater = AW2.job.localWater or {}
                    AW2.job.localWater[self.crop.key] = after
                end

            end
        end
        ISBaseTimedAction.perform(self)
        if AW2 and AW2.step then AW2.touch("post-water-step") AW2.step() end
    end
    function ParadiseZ_AutoFarm_PostWaterAction:new(character, crop, uses, targetCap)
        local o = {}; setmetatable(o, self); self.__index = self
        o.character = character; o.crop = crop; o.uses = uses or 0; o.targetCap = targetCap or 100; o.maxTime = 1
        o.stopOnWalk = false; o.stopOnRun = false; o.stopOnAim = false
        return o
    end

    ParadiseZ_AutoFarm_FillCanAction = ISBaseTimedAction:derive("ParadiseZ_AutoFarm_FillCanAction")
    function ParadiseZ_AutoFarm_FillCanAction:isValid()
        return self.character ~= nil and self.item ~= nil and self.source ~= nil and AW.isWateringCan(self.item) and AW.sourceWater(self.source) > 0
    end
    function ParadiseZ_AutoFarm_FillCanAction:update()
        local square = AW.sourceSquare(self.source)
        if square then self.character:faceLocation(square:getX(), square:getY()) end
    end
    function ParadiseZ_AutoFarm_FillCanAction:start()

    end
    function ParadiseZ_AutoFarm_FillCanAction:stop()

        ISBaseTimedAction.stop(self)
    end
    function ParadiseZ_AutoFarm_FillCanAction:perform()
        local playerObj, inv, item, source = self.character, self.character:getInventory(), self.item, self.source
        local beforeSource = AW.sourceWater(source)
        local sourceTainted = AW.sourceTainted(source)
        local resultItem, filled = item, 0
        if AW.isFullCan(item) then
            local cur, max = AW.canUses(item), AW.canMaxUses(item)
            local units = math.min(math.max(0, max - cur), beforeSource)
            if units > 0 then
                AW.setCanUses(item, cur + units)
                AW.setTainted(item, sourceTainted or AW.isTainted(item))
                filled = AW.useSourceWater(source, units)
                resultItem = item
            end
        elseif AW.isEmptyCan(item) then
            local newItem = inv:AddItem(AW.FULL_CAN)
            if newItem then
                AW.copyCondition(item, newItem)
                local units = math.min(AW.canMaxUses(newItem), beforeSource)
                AW.setCanUses(newItem, units)
                AW.setTainted(newItem, sourceTainted)
                filled = AW.useSourceWater(source, units)
                resultItem = newItem
                local previousContainer = item:getContainer()
                if previousContainer then previousContainer:Remove(item) else inv:Remove(item) end
            else

            end
        end
        if AW.job then AW.job.preferredWaterCan = nil end

        ISBaseTimedAction.perform(self)
    end
    function ParadiseZ_AutoFarm_FillCanAction:new(character, item, source, time)
        local o = {}; setmetatable(o, self); self.__index = self
        o.character = character; o.item = item; o.source = source; o.maxTime = time or 60
        o.stopOnWalk = true; o.stopOnRun = true; o.stopOnAim = true
        return o
    end

    ParadiseZ_AutoFarm_IndexAction = ISBaseTimedAction:derive("ParadiseZ_AutoFarm_IndexAction")
    function ParadiseZ_AutoFarm_IndexAction:isValid() return self.character ~= nil and self.collector ~= nil and self.mode ~= nil end
    function ParadiseZ_AutoFarm_IndexAction:buildCoords()
        local cx = math.floor(AW.num(self.collector:getX(), 0))
        local cy = math.floor(AW.num(self.collector:getY(), 0))
        local cz = math.floor(AW.num(self.collector:getZ(), 0))
        self.sourceCoords, self.cropCoords = {}, {}
        for y = cy - AW.WATER_SOURCE_RADIUS, cy + AW.WATER_SOURCE_RADIUS do
            for x = cx - AW.WATER_SOURCE_RADIUS, cx + AW.WATER_SOURCE_RADIUS do table.insert(self.sourceCoords, { x = x, y = y, z = cz }) end
        end
        for y = cy - AW.CROP_RADIUS, cy + AW.CROP_RADIUS do
            for x = cx - AW.CROP_RADIUS, cx + AW.CROP_RADIUS do table.insert(self.cropCoords, { x = x, y = y, z = cz }) end
        end
        self.sourceIndex, self.cropIndex = 1, 1
        self.sources, self.sourceSeen, self.crops = {}, {}, {}
        self.prepared = true

    end
    function ParadiseZ_AutoFarm_IndexAction:processSourceSquare(coord)
        local square = getCell():getGridSquare(coord.x, coord.y, coord.z)
        if not square then return end
        AW.squareObjects(square, function(obj)
            local source = AW.makeSourceFromObject(obj)
            if source then
                local key = AW.sourceKey(source)
                if not self.sourceSeen[key] then
                    self.sourceSeen[key] = true
                    table.insert(self.sources, source)
                end
            end
        end)
    end
    function ParadiseZ_AutoFarm_IndexAction:processCropSquare(coord)
        local square = getCell():getGridSquare(coord.x, coord.y, coord.z)
        if not square then return end
        local plant = AW.plantAt(coord.x, coord.y, coord.z)
        if plant and not AW.invalidPlant(plant) then
            local key = tostring(coord.x) .. "," .. tostring(coord.y) .. "," .. tostring(coord.z)
            local needs, needed, current, target, skipAt, seed, sensitive, devil, maxSafe = AW.cropPlan(plant, key)
            local disease = AW.diseaseInfo(plant)
            table.insert(self.crops, { x = coord.x, y = coord.y, z = coord.z, key = key, seed = seed })

        end
    end
    function ParadiseZ_AutoFarm_IndexAction:processSome()
        if not self.prepared then self:buildCoords() end
        local budget = AW.INDEX_SQUARES_PER_UPDATE or 5
        while budget > 0 and self.sourceIndex <= #self.sourceCoords do
            self:processSourceSquare(self.sourceCoords[self.sourceIndex])
            self.sourceIndex = self.sourceIndex + 1
            budget = budget - 1
        end
        while budget > 0 and self.cropIndex <= #self.cropCoords do
            self:processCropSquare(self.cropCoords[self.cropIndex])
            self.cropIndex = self.cropIndex + 1
            budget = budget - 1
        end
    end
    function ParadiseZ_AutoFarm_IndexAction:update()
        self:processSome()
        self.character:faceLocation(self.collector:getX(), self.collector:getY())
    end
    function ParadiseZ_AutoFarm_IndexAction:start()

        self:buildCoords()
    end
    function ParadiseZ_AutoFarm_IndexAction:stop()

        ISBaseTimedAction.stop(self)
    end
    function ParadiseZ_AutoFarm_IndexAction:perform()
        while self.sourceIndex <= #self.sourceCoords or self.cropIndex <= #self.cropCoords do self:processSome() end
        self.sources = AW.addWaterTileFallbackIfNeeded(self.sources, self.collector)

        for i, source in ipairs(self.sources) do  end

        local playerObj = self.character
        local crops = AW.routeGreedy(self.crops, playerObj)
        if #crops <= 0 then
            playerObj:Say(AW.noneFoundText and AW.noneFoundText(self.mode) or "Nothing needs attention here.")

            local carry = AW.job and AW.job.chainQueue or nil
            if AW.job then AW.job.active = false end
            ISBaseTimedAction.perform(self)
            if carry and #carry > 0 then
                local nextJob = table.remove(carry, 1)
                AW.pendingChainCarry = carry
                if nextJob.pattern then AW.currentFurrowPattern = nextJob.pattern end

                AW.start(self.playerNum or 0, self.collector, nextJob.mode)
            end
            return
        end
        AW.job.sources = self.sources
        AW.job.pending = crops
        AW.job.treatAttempts = {}
        AW.job.devilWatering = {}
        AW.job.preferredWaterCan = nil
        AW.job.localWater = {}
        AW.job.watchdogRetries = 0
        AW.job.lastQueuedKind = nil
        AW.job.lastQueuedCropKey = nil
        playerObj:Say(AW.foundText and AW.foundText(self.mode, #crops) or "Crops need attention.")

        ISBaseTimedAction.perform(self)
        AW.touch("staged-index-complete")
        AW.step()
    end
    function ParadiseZ_AutoFarm_IndexAction:new(character, collector, mode, playerNum)
        local o = {}; setmetatable(o, self); self.__index = self
        o.character = character; o.collector = collector; o.mode = mode; o.playerNum = playerNum or 0
        o.maxTime = AW.INDEX_TOTAL_TIME or 120
        o.stopOnWalk = true; o.stopOnRun = true; o.stopOnAim = true
        o.prepared = false; o.sourceCoords = {}; o.cropCoords = {}; o.sources = {}; o.sourceSeen = {}; o.crops = {}; o.sourceIndex = 1; o.cropIndex = 1
        return o
    end

    function AW.queueRefillAll(playerObj, reason)
        if not AW.job then  return false end
        AW.job.preferredWaterCan = nil
        local source = AW.bestSource(playerObj)
        if not source then

            return false
        end
        local cans = AW.getFillableCans(playerObj)

        for i, can in ipairs(cans) do  end
        if #cans <= 0 then  return false end
        local square = AW.sourceSquare(source)
        if not square then  return false end
        if not AW.queueWalkAdj(playerObj, square) then  return false end
        local budget, queued = AW.sourceWater(source), 0
        for _, can in ipairs(cans) do
            if budget <= 0 then break end
            local planned
            if AW.isEmptyCan(can) then planned = AW.DEFAULT_EMPTY_CAN_MAX_USES else planned = math.max(0, AW.canMaxUses(can) - AW.canUses(can)) end
            planned = math.min(planned, budget)
            if planned > 0 then
                AW.queueTransferIfNeeded(playerObj, can)
                ISTimedActionQueue.add(ParadiseZ_AutoFarm_FillCanAction:new(playerObj, can, source, math.max(AW.MIN_ACTION_TIME, planned * AW.REFILL_TIME_PER_USE)))
                queued = queued + 1
                if budget < 999999 then budget = budget - planned end

            end
        end
        if queued <= 0 then  return false end
        ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, 1))
        AW.job.lastQueuedKind = "t16-refill"
        AW.job.lastQueuedCropKey = nil
        AW.job.watchdogRetries = 0
        AW.touch("queued-t16-refill")
        return true
    end

    function AW.queueVanillaWater(playerObj, crop, square, can, uses, targetCap)
        if not can or not square or uses <= 0 then return false end
        AW.queueTransferIfNeeded(playerObj, can)
        if AW.SOFT_EQUIP_WATER_CAN and playerObj:getPrimaryHandItem() ~= can then
            pcall(function() playerObj:setPrimaryHandItem(can) end)

        end
        if not AW.queueWalkAdj(playerObj, square) then  return false end
        local time = 20 + (6 * uses)
        local ok, action = pcall(function() return ISWaterPlantAction:new(playerObj, can, uses, square, time) end)
        if not ok or not action then  return false end

        ISTimedActionQueue.add(action)
        ISTimedActionQueue.add(ParadiseZ_AutoFarm_PostWaterAction:new(playerObj, crop, uses, targetCap))
        return true
    end

    function AW.queueWater(playerObj, crop, plant)
        local needs, neededWater, current, target, skipAt, seed, sensitive, devil = AW.cropPlan(plant, crop.key)
        crop.seed = seed
        if not needs then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
            return true
        end
        local can, available = AW.findPreferredCan(playerObj)
        local sourceWater = AW.totalSourceWater()
        if not can or available <= AW.CAN_RESERVE_USES then

            if sourceWater > 0 and AW.hasFillableCan(playerObj) then return AW.queueRefillAll(playerObj, "no usable can water") end

            AW.cancel("out of usable water")
            return false
        end
        local square = getCell():getGridSquare(crop.x, crop.y, crop.z)
        if not square then
            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
            return true
        end
        local safeAvailable = math.max(0, available - AW.CAN_RESERVE_USES)
        local actionUses = AW.waterUsesForPlan(current, target, sensitive, devil, safeAvailable)
        if actionUses <= 0 then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
            return true
        end

        if not AW.queueVanillaWater(playerObj, crop, square, can, actionUses, target) then return false end
        AW.job.lastQueuedKind = "t16-water"
        AW.job.lastQueuedCropKey = crop.key
        AW.job.watchdogRetries = 0
        AW.touch("queued-t16-water")
        return true
    end

    function AW.queueVanillaMenuTreatment(playerObj, crop, diseaseType, square, item, uses)
        if not ISFarmingMenu then  return false end
        if diseaseType == "mildew" then
            if not ISFarmingMenu.onMildewCure then  return false end
            ISFarmingMenu.GardeningSprayMilk = item

            local ok, err = pcall(function() ISFarmingMenu.onMildewCure({}, uses, square, playerObj) end)
            if not ok then  return false end
            return true
        end
        if diseaseType == "flies" then
            if not ISFarmingMenu.onFliesCure then  return false end
            ISFarmingMenu.GardeningSprayCigarettes = item

            local ok, err = pcall(function() ISFarmingMenu.onFliesCure({}, uses, square, playerObj) end)
            if not ok then  return false end
            return true
        end

        return false
    end

    function AW.queueTreatment(playerObj, crop, diseaseType, field, value, item)
        local square = getCell():getGridSquare(crop.x, crop.y, crop.z)
        if not square then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
            return true
        end
        local key = crop.key .. ":" .. tostring(field)
        AW.job.treatAttempts[key] = (AW.job.treatAttempts[key] or 0) + 1
        if AW.job.treatAttempts[key] > AW.MAX_TREAT_ATTEMPTS_PER_CROP_FIELD then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
            return true
        end
        local exact = AW.canSeeExactDisease(playerObj)
        local treatmentAmount, sprayUses = AW.roundTreatmentAmount(value, exact)
        local availableUses = AW.itemUses(item)
        if availableUses <= 0 then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
            return true
        end
        sprayUses = math.min(sprayUses, availableUses)
        treatmentAmount = sprayUses * AW.TREAT_INCREMENT

        local ok = AW.queueVanillaMenuTreatment(playerObj, crop, diseaseType, square, item, sprayUses)
        if not ok then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
            return true
        end
        ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
        AW.job.lastQueuedKind = "treat"
        AW.job.lastQueuedCropKey = crop.key
        AW.job.watchdogRetries = 0
        AW.touch("queued-treatment")
        return true
    end

    function AW.harvestStage(plant) return math.floor(AW.num(plant and plant.nbOfGrow, 0)) end
    function AW.canHarvestPlant(plant)
        if AW.invalidPlant(plant) then return false end
        local ok, result = pcall(function() return plant:canHarvest() end)
        return ok and result == true
    end
    function AW.isSeedBearingHarvest(plant) if not AW.canHarvestPlant(plant) then return false end return AW.harvestStage(plant) >= 7 end

    function AW.scanHarvestPlants(centerObj, seedOnly)
        local cx = math.floor(AW.num(centerObj:getX(), 0))
        local cy = math.floor(AW.num(centerObj:getY(), 0))
        local cz = math.floor(AW.num(centerObj:getZ(), 0))
        local cell = getCell()
        local crops = {}
        for y = cy - AW.CROP_RADIUS, cy + AW.CROP_RADIUS do
            for x = cx - AW.CROP_RADIUS, cx + AW.CROP_RADIUS do
                local square = cell:getGridSquare(x, y, cz)
                if square then
                    local plant = AW.plantAt(x, y, cz)
                    if plant and not AW.invalidPlant(plant) then
                        local canHarvest = AW.canHarvestPlant(plant)
                        local seedBearing = AW.isSeedBearingHarvest(plant)
                        if canHarvest and ((not seedOnly) or seedBearing) then
                            local key = tostring(x) .. "," .. tostring(y) .. "," .. tostring(cz)
                            table.insert(crops, { x = x, y = y, z = cz, key = key, seed = tostring(plant.typeOfSeed or "unknown") })

                        end
                    end
                end
            end
        end

        return crops
    end

    function AW.queueHarvest(playerObj, crop, plant)
        local square = getCell():getGridSquare(crop.x, crop.y, crop.z)
        if AW.job and crop then
            AW.job.lastActionTargetX = crop.x
            AW.job.lastActionTargetY = crop.y
            AW.job.lastActionTargetZ = crop.z
        end
        if not square or not plant then
            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
            return true
        end
        if not AW.canHarvestPlant(plant) then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
            return true
        end

        if not AW.queueWalkAdj(playerObj, square) then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
            return true
        end
        if AW.TRUST_QUEUED_ACTIONS and AW.job then
            AW.job.queuedHarvestKeys = AW.job.queuedHarvestKeys or {}
            AW.job.queuedHarvestKeys[crop.key] = true
        end

        ISTimedActionQueue.add(ISHarvestPlantAction:new(playerObj, plant, 100))
        ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
        AW.job.lastQueuedKind = "harvest"
        AW.job.lastQueuedCropKey = crop.key
        AW.job.watchdogRetries = 0
        AW.touch("queued-harvest")
        return true
    end

    function AW.removeModeMatchesPlant(mode, plant)
        if not plant then return false end

        if mode == "removePlots" then
            return AW.isEmptyPlot(plant)
        end

        if mode == "removeReceding" then
            return AW.isRecedingPlant(plant)
        end

        if mode == "removePlants" then
            return AW.isSeededPlant(plant)
        end

        return false
    end

    function AW.removeModeLabel(mode)
        if mode == "removePlots" then return "plots" end
        if mode == "removeReceding" then return "receding plants" end
        if mode == "removePlants" then return "plants" end
        return tostring(mode or "remove")
    end

    function AW.scanRemoveTargets(centerObj, mode)
        local cx = math.floor(AW.num(centerObj:getX(), 0))
        local cy = math.floor(AW.num(centerObj:getY(), 0))
        local cz = math.floor(AW.num(centerObj:getZ(), 0))
        local cell = getCell()
        local out = {}

        for y = cy - AW.CROP_RADIUS, cy + AW.CROP_RADIUS do
            for x = cx - AW.CROP_RADIUS, cx + AW.CROP_RADIUS do
                local square = cell:getGridSquare(x, y, cz)
                if square then
                    local plant = AW.plantAt(x, y, cz)
                    if plant and AW.removeModeMatchesPlant(mode, plant) then
                        local key = tostring(x) .. "," .. tostring(y) .. "," .. tostring(cz)
                        table.insert(out, {
                            x = x, y = y, z = cz, key = key,
                            seed = tostring(plant.typeOfSeed or "none"),
                            state = tostring(plant.state or "unknown")
                        })

                    end
                end
            end
        end


        return out
    end

    function AW.findRemoveTool(playerObj)
        if ISFarmingMenu and ISFarmingMenu.getShovel then
            local ok, tool = pcall(function() return ISFarmingMenu.getShovel(playerObj) end)
            if ok and tool then return tool end
        end
        return AW.findDigTool(playerObj)
    end

    function AW.queueRemovePlant(playerObj, crop, plant)
        local square = getCell():getGridSquare(crop.x, crop.y, crop.z)
        if AW.job and crop then
            AW.job.lastActionTargetX = crop.x
            AW.job.lastActionTargetY = crop.y
            AW.job.lastActionTargetZ = crop.z
        end

        if not square or not plant then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
            return true
        end

        if not AW.removeModeMatchesPlant(AW.job.mode, plant) then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
            return true
        end

        local tool = AW.findRemoveTool(playerObj)
        if not tool then
            playerObj:Say("No shovel/trowel found for removal.")

            AW.cancel("no remove tool")
            return false
        end


        AW.queueDigToolEquip(playerObj, tool)

        if not AW.queueWalkAdj(playerObj, square) then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
            return true
        end

        local ok, action = pcall(function()
            return ISShovelAction:new(playerObj, tool, plant, 40)
        end)

        if not ok or not action then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
            return true
        end

        if AW.TRUST_QUEUED_ACTIONS and AW.job then
            AW.job.queuedRemoveKeys = AW.job.queuedRemoveKeys or {}
            AW.job.queuedRemoveKeys[crop.key] = true
        end

        ISTimedActionQueue.add(action)
        ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))

        AW.job.lastQueuedKind = "remove-plant"
        AW.job.lastQueuedCropKey = crop.key
        AW.job.watchdogRetries = 0
        AW.touch("queued-remove-plant")
        return true
    end

    function AW.startsWith(s, prefix)
        s = tostring(s or "")
        prefix = tostring(prefix or "")
        return string.sub(s, 1, string.len(prefix)) == prefix
    end

    function AW.furrowPattern(centerObj, patternName)
        local cx = math.floor(AW.num(centerObj:getX(), 0))
        local cy = math.floor(AW.num(centerObj:getY(), 0))
        local cz = math.floor(AW.num(centerObj:getZ(), 0))
        local pattern = patternName or AW.currentFurrowPattern or AW.FURROW_PATTERN_FULL_SPACED
        local points = {}

        for dy = -AW.FURROW_RADIUS, AW.FURROW_RADIUS do
            for dx = -AW.FURROW_RADIUS, AW.FURROW_RADIUS do
                local include = false
                if not (dx == 0 and dy == 0) then
                    if pattern == AW.FURROW_PATTERN_FULL_SPACED then
                        include = (math.abs(dx) % 2 == 1) and (math.abs(dy) % 2 == 1)
                    elseif pattern == AW.FURROW_PATTERN_CHECKER then
                        include = ((dx + dy) % 2 == 0)
                    elseif pattern == AW.FURROW_PATTERN_NS_ROWS then
                        include = (math.abs(dx) % 2 == 1)
                    elseif pattern == AW.FURROW_PATTERN_EW_ROWS then
                        include = (math.abs(dy) % 2 == 1)
                    elseif pattern == AW.FURROW_PATTERN_FULL then
                        include = true
                    else
                        include = (math.abs(dx) % 2 == 1) and (math.abs(dy) % 2 == 1)
                    end
                end
                if include then
                    table.insert(points, { x = cx + dx, y = cy + dy, z = cz, key = tostring(cx + dx) .. "," .. tostring(cy + dy) .. "," .. tostring(cz), dx = dx, dy = dy, pattern = pattern })
                end
            end
        end
        return points
    end

    function AW.isNaturalFurrowFloor(square)
        if not square then return false, "missing square" end
        local objects = square:getObjects()
        if not objects then return false, "no objects list" end
        for i = 0, objects:size() - 1 do
            local obj = objects:get(i)
            local tex = obj and obj:getTextureName()
            if tex and (AW.startsWith(tex, "floors_exterior_natural") or AW.startsWith(tex, "blends_natural_01")) then
                return true, "natural texture=" .. tostring(tex)
            end
        end
        return false, "not natural exterior/blends floor"
    end

    function AW.isFurrowAcceptableSquare(square)
        if not square then return false, "missing square" end
        if CFarmingSystem and CFarmingSystem.instance then
            local existing = CFarmingSystem.instance:getLuaObjectOnSquare(square)
            if existing then return false, "existing farming object state=" .. tostring(existing.state) .. " seed=" .. tostring(existing.typeOfSeed) end
        end
        return AW.isNaturalFurrowFloor(square)
    end

    function AW.isDigTool(item)
        if not item then return false end
        local okBroken, broken = pcall(function() return item:isBroken() end)
        if okBroken and broken then return false end
        local okTag, hasTag = pcall(function() return item:hasTag("DigPlow") end)
        if okTag and hasTag then return true end
        local t = tostring(item:getType() or "")
        if t == "Shovel" or t == "HandShovel" or t == "Trowel" or t == "HandFork" or t == "GardenHoe" or t == "PickAxe" then return true end
        local text = string.lower(tostring(item:getFullType() or "") .. " " .. tostring(item:getDisplayName() or ""))
        if string.find(text, "shovel", 1, true) then return true end
        if string.find(text, "trowel", 1, true) then return true end
        return false
    end

    function AW.findDigTool(playerObj)
        local primary = playerObj:getPrimaryHandItem()
        if AW.isDigTool(primary) then return primary end
        local inv = playerObj:getInventory()
        local ok, item = pcall(function() return inv:getFirstEvalRecurse(function(candidate) return AW.isDigTool(candidate) end) end)
        if ok and item then return item end
        local items = inv:getItems()
        for i = 0, items:size() - 1 do
            local candidate = items:get(i)
            if AW.isDigTool(candidate) then return candidate end
        end
        return nil
    end

    function AW.handsCanDig(playerObj)
        local ok, result = pcall(function()
            local bd = playerObj:getBodyDamage()
            local left = bd:getBodyPart(BodyPartType.Hand_L)
            local right = bd:getBodyPart(BodyPartType.Hand_R)
            return not left:HasInjury() and not right:HasInjury()
        end)
        return ok and result == true
    end

    function AW.scanFurrowPlan(centerObj)
        local cell, out, rejected = getCell(), {}, 0
        local points = AW.furrowPattern(centerObj, AW.currentFurrowPattern)
        for _, point in ipairs(points) do
            local square = cell:getGridSquare(point.x, point.y, point.z)
            local ok, reason = AW.isFurrowAcceptableSquare(square)
            if ok then
                table.insert(out, point)

            else
                rejected = rejected + 1

            end
        end

        return out
    end

    function AW.queueDigToolEquip(playerObj, tool)
        if not tool then return true end
        AW.queueTransferIfNeeded(playerObj, tool)
        if playerObj:getPrimaryHandItem() == tool then  return true end
        if ISEquipWeaponAction then
            local ok, action = pcall(function() return ISEquipWeaponAction:new(playerObj, tool, 50, true) end)
            if ok and action then

                ISTimedActionQueue.add(action)
                return true
            end
        end
        playerObj:setPrimaryHandItem(tool)
        return true
    end

    function AW.queuePlowSquare(playerObj, point)
        local square = getCell():getGridSquare(point.x, point.y, point.z)
        local okSquare, reason = AW.isFurrowAcceptableSquare(square)
        if not okSquare then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
            return true
        end
        local tool = AW.findDigTool(playerObj)
        local usingHands = false
        if not tool then
            if not AW.handsCanDig(playerObj) then
                playerObj:Say("No shovel/trowel, and hands are injured.")
                AW.cancel("no dig tool and injured hands")
                return false
            end
            usingHands = true
        end

        AW.queueDigToolEquip(playerObj, tool)
        if not AW.queueWalkAdj(playerObj, square) then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
            return true
        end
        local ok, action = pcall(function() return ISPlowAction:new(playerObj, square, tool, AW.FURROW_TIME) end)
        if not ok or not action then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
            return true
        end
        if AW.TRUST_QUEUED_ACTIONS and AW.job then
            AW.job.queuedDigKeys = AW.job.queuedDigKeys or {}
            AW.job.queuedDigKeys[point.key] = true
        end

        ISTimedActionQueue.add(action)
        ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
        AW.job.lastQueuedKind = "dig-furrow"
        AW.job.lastQueuedCropKey = point.key
        AW.job.watchdogRetries = 0
        AW.touch("queued-dig-furrow")
        return true
    end

    AW.HIGHLIGHT_CURSOR_TEX = "media/ui/FloorTileCursor.png"

    AW.showFurrowHighlight = true
    AW.showAutoFarmHighlight = true
    AW.highlightFurrowOffsetX = -3
    AW.highlightFurrowOffsetY = -3
    AW.HIGHLIGHT_FURROW_SIZE = 1.00
    AW.HIGHLIGHT_DO_ALPHA = false

    AW.HIGHLIGHT_REFRESH_TICKS = 120
    AW.highlightRefreshCounter = 0
    AW.highlightMarkers = {}
    AW.highlightMarkerKeys = {}
    AW.highlightMarkerFailed = false

    function AW.removeAutoFarmMarkers()
        if AW.highlightMarkers then
            for _, marker in ipairs(AW.highlightMarkers) do
                pcall(function()
                    if getWorldMarkers and getWorldMarkers().removeGridSquareMarker then
                        getWorldMarkers():removeGridSquareMarker(marker)
                    end
                end)
                pcall(function()
                    if marker and marker.remove then marker:remove() end
                end)
            end
        end

        AW.highlightMarkers = {}
        AW.highlightMarkerKeys = {}
    end

    function AW.clearBadHighlightArtifacts()
        if AW.highlightSquares then
            for _, entry in ipairs(AW.highlightSquares) do
                local sq = entry and entry.square
                if sq then
                    pcall(function()
                        local floor = sq:getFloor()
                        if floor then floor:setHighlighted(false) end
                    end)
                    pcall(function() sq:setHighlighted(false) end)
                    pcall(function() sq:setHighlighted(false, false) end)
                end
            end
        end
        AW.highlightSquares = {}
        AW.highlightSquareKeys = {}
    end

    function AW.markerKey(prefix, square)
        if not square then return nil end
        return tostring(prefix) .. ":" ..
            tostring(square:getX()) .. "," ..
            tostring(square:getY()) .. "," ..
            tostring(square:getZ())
    end

    function AW.addFloorTileCursorMarker(square, prefix, size)
        if AW.highlightMarkerFailed then return nil end
        if not square or not getWorldMarkers then return nil end

        local key = AW.markerKey(prefix, square)
        if key and AW.highlightMarkerKeys[key] then return nil end

        local wm = getWorldMarkers()
        if not wm or not wm.addGridSquareMarker then
            AW.highlightMarkerFailed = true

            return nil
        end

        local ok, marker = pcall(function()
            return wm:addGridSquareMarker(
                AW.HIGHLIGHT_CURSOR_TEX,
                AW.HIGHLIGHT_CURSOR_TEX,
                square,
                0.0, 1.0, 0.0,
                AW.HIGHLIGHT_DO_ALPHA == true,
                size or 1.0
            )
        end)

        if not ok or not marker then
            AW.highlightMarkerFailed = true

            return nil
        end

        if key then AW.highlightMarkerKeys[key] = true end
        table.insert(AW.highlightMarkers, marker)
        return marker
    end

    function AW.roundSliderValue(v, minVal, maxVal, step)
        v = tonumber(v) or 0
        minVal = tonumber(minVal) or -10
        maxVal = tonumber(maxVal) or 10
        step = tonumber(step) or 1
        if step > 0 then v = math.floor((v / step) + 0.5) * step end
        if v < minVal then v = minVal end
        if v > maxVal then v = maxVal end
        return v
    end

    function AW.rebuildAutoFarmFloorTileHighlight(reason)
        AW.removeAutoFarmMarkers()
        AW.clearBadHighlightArtifacts()
        AW.highlightMarkerFailed = false
        AW.showAutoFarmHighlight = AW.showFurrowHighlight == true

        if AW.showAutoFarmHighlight == false then

            return
        end

        local collector = AW.highlightCollector
        if not collector then

            return
        end

        local cell = getCell()
        if not cell then

            return
        end

        local fx = math.floor(AW.num(AW.highlightFurrowOffsetX, 0))
        local fy = math.floor(AW.num(AW.highlightFurrowOffsetY, 0))
        local furrowCount = 0

        local points = AW.furrowPattern(collector, AW.currentFurrowPattern)
        for _, point in ipairs(points or {}) do
            if not (point.dx == 0 and point.dy == 0) then
                local square = cell:getGridSquare(point.x + fx, point.y + fy, point.z)
                if square then
                    if AW.addFloorTileCursorMarker(square, "furrow", AW.HIGHLIGHT_FURROW_SIZE or 1.0) then
                        furrowCount = furrowCount + 1
                    end
                end
            end
        end
    end

    function AW.setHighlightTarget(collector, patternName, show)
        AW.highlightCollector = collector
        AW.currentFurrowPattern = patternName or AW.currentFurrowPattern or AW.FURROW_PATTERN_FULL_SPACED
        AW.showFurrowHighlight = show ~= false
        AW.showAutoFarmHighlight = AW.showFurrowHighlight == true
        AW.rebuildAutoFarmFloorTileHighlight("set-target")
    end

    function AW.clearAutoFarmHighlight()
        AW.removeAutoFarmMarkers()
        AW.clearBadHighlightArtifacts()
        AW.highlightCollector = nil
        AW.highlightWindow = nil
    end

    function AW.refreshAutoFarmHighlightNow()
        AW.rebuildAutoFarmFloorTileHighlight("manual-refresh")
    end

    function AW.setHighlightRefreshTicks(ticks)
        ticks = math.floor(AW.num(ticks, 0))
        if ticks < 0 then ticks = 0 end
        AW.HIGHLIGHT_REFRESH_TICKS = ticks
        AW.highlightRefreshCounter = 0
        if Events.OnTick then
            pcall(function() Events.OnTick.Remove(AW.onHighlightRefreshTick) end)
            if ticks > 0 then
                Events.OnTick.Add(AW.onHighlightRefreshTick)
            end
        end
    end

    function AW.onHighlightRefreshTick()
        if not ParadiseZ_AutoFarm then return end
        if not AW.highlightCollector or not AW.showFurrowHighlight then return end
        local ticks = math.floor(AW.num(AW.HIGHLIGHT_REFRESH_TICKS, 0))
        if ticks <= 0 then return end
        AW.highlightRefreshCounter = (AW.highlightRefreshCounter or 0) + 1
        if AW.highlightRefreshCounter % ticks ~= 0 then return end
        AW.rebuildAutoFarmFloorTileHighlight("tick-refresh")
    end

    AW.setHighlightRefreshTicks(AW.HIGHLIGHT_REFRESH_TICKS or 120)

    function AW.step()
        local job = AW.job
        if not job or not job.active then return end
        AW.touch("step")
        local playerObj = AW.player(job.playerNum)
        if not playerObj then AW.cancel("player missing") return end
        if playerObj:isDead() then AW.cancel("player dead") return end

        while #job.pending > 0 do
            local crop = job.pending[1]
            local plant = AW.plantAt(crop.x, crop.y, crop.z)
            if job.mode == "digFurrows" then
                if job.queuedDigKeys and job.queuedDigKeys[crop.key] then

                    table.remove(job.pending, 1)
                    job.watchdogRetries = 0
                else
                    local square = getCell():getGridSquare(crop.x, crop.y, crop.z)
                    local okSquare, reason = AW.isFurrowAcceptableSquare(square)
                    if not okSquare then

                        table.remove(job.pending, 1)
                        job.watchdogRetries = 0
                    else
                        return AW.queuePlowSquare(playerObj, crop)
                    end
                end

            elseif job.mode == "removePlots" or job.mode == "removeReceding" or job.mode == "removePlants" then
                if job.queuedRemoveKeys and job.queuedRemoveKeys[crop.key] then

                    table.remove(job.pending, 1)
                    job.watchdogRetries = 0
                elseif not plant then

                    table.remove(job.pending, 1)
                    job.watchdogRetries = 0
                elseif not AW.removeModeMatchesPlant(job.mode, plant) then

                    table.remove(job.pending, 1)
                    job.watchdogRetries = 0
                else
                    return AW.queueRemovePlant(playerObj, crop, plant)
                end

            elseif job.mode == "harvest" or job.mode == "harvestSeed" then
                if job.queuedHarvestKeys and job.queuedHarvestKeys[crop.key] then

                    table.remove(job.pending, 1)
                    job.watchdogRetries = 0
                elseif AW.invalidPlant(plant) then

                    table.remove(job.pending, 1)
                elseif job.mode == "harvestSeed" and not AW.isSeedBearingHarvest(plant) then

                    table.remove(job.pending, 1)
                elseif not AW.canHarvestPlant(plant) then

                    table.remove(job.pending, 1)
                else
                    return AW.queueHarvest(playerObj, crop, plant)
                end

            elseif AW.invalidPlant(plant) then

                table.remove(job.pending, 1)

            else
                if job.mode ~= "water" then
                    local diseaseType, field, value, item = AW.nextTreatment(playerObj, plant, crop)
                    if diseaseType and field and value and value > 0 and item then return AW.queueTreatment(playerObj, crop, diseaseType, field, value, item) end
                end
                if job.mode ~= "treat" then
                    local needs = AW.cropPlan(plant, crop.key)
                    if needs then return AW.queueWater(playerObj, crop, plant) end
                end
                local disease = AW.diseaseInfo(plant)
                local needs, needed, current, target, skipAt, seed, sensitive, devil = AW.cropPlan(plant, crop.key)

                table.remove(job.pending, 1)
                job.watchdogRetries = 0
            end
        end


        job.active = false

        if job.chainQueue and #job.chainQueue > 0 and job.center then
            local nextJob = table.remove(job.chainQueue, 1)
            local remaining = job.chainQueue

            AW.pendingChainCarry = remaining
            if nextJob.pattern then AW.currentFurrowPattern = nextJob.pattern end
            AW.start(job.playerNum or 0, job.center, nextJob.mode)
        end
    end

    function AW.continueChainOrFinish(playerObj, playerNum, collector, carry, emptyMode)
        if carry and #carry > 0 then
            local nextJob = table.remove(carry, 1)
            AW.pendingChainCarry = carry
            if nextJob.pattern then AW.currentFurrowPattern = nextJob.pattern end

            AW.start(playerNum or 0, collector, nextJob.mode)
            return true
        end
        return false
    end

    function AW.buildTendChain(plan)
        plan = plan or {}
        local chain = {
            { mode = "harvestSeed" },
            { mode = "removeReceding" }
        }

        if plan.includeDig == true then
            table.insert(chain, { mode = "digFurrows", pattern = AW.currentFurrowPattern })
        end
        if plan.includeTreat ~= false then
            table.insert(chain, { mode = "treat" })
        end
        if plan.includeWater ~= false then
            table.insert(chain, { mode = "water" })
        end
        return chain
    end

    function AW.start(playerNum, collector, mode)
        mode = mode or "tend"
        local playerObj = AW.player(playerNum)
        if not playerObj then  return end
        if not AW.isWaterCollector(collector) then  return end

        if AW.job and AW.job.active then
            playerObj:Say("Auto-Farm is already running.")

            return
        end

        if ISTimedActionQueue and getPlayer() then pcall(function() ISTimedActionQueue.clear(getPlayer()) end) end

        if mode ~= "tend" and AW.pendingChainCarry == nil then
            AW.pendingMatchPattern = false
            AW.pendingReplantActive = false
        end

        if mode == "tend" then
            local plan = AW.pendingTendPlan or {
                includeDig = false,
                includeTreat = true,
                includeWater = true
            }
            AW.pendingTendPlan = nil

            local chain = AW.buildTendChain(plan)
            local first = table.remove(chain, 1)
            AW.pendingChainCarry = chain


            if first then
                AW.start(playerNum or 0, collector, first.mode)
            end
            return
        end

        local carry = AW.pendingChainCarry
        AW.pendingChainCarry = nil

        if mode == "harvest" or mode == "harvestSeed" then

            local crops = AW.routeGreedy(AW.scanHarvestPlants(collector, mode == "harvestSeed"), playerObj)
            if #crops <= 0 then
                playerObj:Say(mode == "harvestSeed" and "No seed-bearing crops nearby." or "No harvestable crops nearby.")

                AW.continueChainOrFinish(playerObj, playerNum, collector, carry, mode)
                return
            end
            AW.job = {
                active = true, mode = mode, playerNum = playerNum or 0, center = collector,
                sources = {}, pending = crops, treatAttempts = {}, devilWatering = {}, localWater = {}, preferredWaterCan = nil,
                watchdogRetries = 0, lastQueuedKind = nil, lastQueuedCropKey = nil, chainQueue = carry or {},
                queuedHarvestKeys = {}
            }
            playerObj:Say(AW.foundText and AW.foundText(mode, #crops) or "Crops need attention.")
            AW.step()
            return
        end

        if mode == "removePlots" or mode == "removeReceding" or mode == "removePlants" then
            if playerObj:getVehicle() then playerObj:Say("Exit the vehicle first.")  return end
            local tool = AW.findRemoveTool(playerObj)
            if not tool then
                playerObj:Say("No shovel/trowel found for removal.")

                AW.continueChainOrFinish(playerObj, playerNum, collector, carry, mode)
                return
            end


            local targets = AW.routeGreedy(AW.scanRemoveTargets(collector, mode), playerObj)
            if #targets <= 0 then
                playerObj:Say("No " .. AW.removeModeLabel(mode) .. " nearby.")

                AW.continueChainOrFinish(playerObj, playerNum, collector, carry, mode)
                return
            end

            AW.job = {
                active = true, mode = mode, playerNum = playerNum or 0, center = collector,
                sources = {}, pending = targets, treatAttempts = {}, devilWatering = {}, localWater = {}, preferredWaterCan = nil,
                watchdogRetries = 0, lastQueuedKind = nil, lastQueuedCropKey = nil, chainQueue = carry or {},
                queuedRemoveKeys = {}
            }
            playerObj:Say(AW.foundText and AW.foundText(mode, #targets) or "Farm clearing needed.")
            AW.step()
            return
        end

        if mode == "digFurrows" then
            if playerObj:getVehicle() then playerObj:Say("Exit the vehicle first.")  return end
            local tool = AW.findDigTool(playerObj)
            if not tool and not AW.handsCanDig(playerObj) then
                playerObj:Say("No shovel/trowel, and hands are injured.")

                AW.continueChainOrFinish(playerObj, playerNum, collector, carry, mode)
                return
            end

            local points = AW.routeGreedy(AW.scanFurrowPlan(collector), playerObj)
            if #points <= 0 then
                playerObj:Say("No acceptable furrow tiles nearby.")

                AW.continueChainOrFinish(playerObj, playerNum, collector, carry, mode)
                return
            end
            AW.job = {
                active = true, mode = "digFurrows", playerNum = playerNum or 0, center = collector,
                sources = {}, pending = points, treatAttempts = {}, devilWatering = {}, localWater = {}, preferredWaterCan = nil,
                watchdogRetries = 0, lastQueuedKind = nil, lastQueuedCropKey = nil, chainQueue = carry or {},
                queuedDigKeys = {}
            }
            playerObj:Say(AW.foundText and AW.foundText("digFurrows", #points) or "Furrows need digging.")
            AW.step()
            return
        end


        local cans = AW.getWateringCans(playerObj)

        for i, can in ipairs(cans) do  end
        if mode ~= "treat" and #cans <= 0 then
            playerObj:Say("No watering cans found.")
            AW.continueChainOrFinish(playerObj, playerNum, collector, carry, mode)
            return
        end
        AW.job = {
            active = true, mode = mode, playerNum = playerNum or 0, center = collector,
            sources = {}, pending = {}, treatAttempts = {}, devilWatering = {}, localWater = {}, preferredWaterCan = nil,
            watchdogRetries = 0, lastQueuedKind = "index", lastQueuedCropKey = nil, chainQueue = carry or {}
        }
        AW.touch("queued-staged-index")
        ISTimedActionQueue.add(ParadiseZ_AutoFarm_IndexAction:new(playerObj, collector, mode, playerNum or 0))
        playerObj:Say("Auto-Farm " .. tostring(mode) .. ": indexing...")
    end

    function AW.cancel(reason)
        if AW.job then AW.job.active = false end
        AW.pendingChainCarry = nil
        AW.pendingTendPlan = nil
        if ISTimedActionQueue and getPlayer() then pcall(function() ISTimedActionQueue.clear(getPlayer()) end) end

    end

    function AW.isDoingAction(playerObj)
        local result = nil
        if ISTimedActionQueue and ISTimedActionQueue.isPlayerDoingAction then
            local ok, value = pcall(function() return ISTimedActionQueue.isPlayerDoingAction(playerObj) end)
            if ok then result = value end
        end
        if result ~= nil then return result == true end
        local actions = playerObj:getCharacterActions()
        if actions then return not actions:isEmpty() end
        return nil
    end

    function AW.distanceToLastTarget(playerObj)
        if not AW.job then return 999999 end
        local tx, ty = AW.job.lastActionTargetX, AW.job.lastActionTargetY
        if not tx or not ty then return 999999 end
        return math.abs(math.floor(playerObj:getX()) - tx) + math.abs(math.floor(playerObj:getY()) - ty)
    end

    function AW.onPlayerUpdate(playerObj)
        if playerObj ~= getPlayer() then return end
        if not AW.job or not AW.job.active then return end
        local doing = AW.isDoingAction(playerObj)
        local msSince = AW.nowMs() - AW.lastStepMs
        local mode = AW.job.mode
        local lastLabel = tostring(AW.lastStepLabel or "")

        if doing == false and AW.isQueuedJobLabel(lastLabel) then
            local dist = AW.distanceToLastTarget(playerObj)

            if dist > AW.HARVEST_QUEUE_GAP_CANCEL_DIST and msSince >= AW.INTERRUPT_CANCEL_MS then

                AW.cancel("interrupted")
                return
            end

            if msSince < AW.WATCHDOG_STALL_MS then
                return
            end


            AW.touch("watchdog-gap-resume")
            AW.step()
            return
        end

        AW.watchTicks = AW.watchTicks + 1
        if AW.watchTicks % AW.WATCHDOG_TICKS ~= 0 then return end
        if AW.WATCHDOG_LOG_ACTIVE == true then

        end
        if doing == false and msSince >= AW.WATCHDOG_STALL_MS then

            AW.cancel("watchdog stalled/cleared")
        end
    end

    ParadiseZ_AutoFarm_ConfirmWindow = ISCollapsableWindow:derive("ParadiseZ_AutoFarm_ConfirmWindow")

    function ParadiseZ_AutoFarm_ConfirmWindow:new(x, y, width, height, message, yesFn, noFn)
        local o = ISCollapsableWindow:new(x, y, width, height)
        setmetatable(o, self)
        self.__index = self

        o.title = "Confirm"
        o.resizable = false
        o.pin = true
        o.message = message or "Are you sure?"
        o.yesFn = yesFn
        o.noFn = noFn

        return o
    end

    function ParadiseZ_AutoFarm_ConfirmWindow:createChildren()
        if ISCollapsableWindow.createChildren then ISCollapsableWindow.createChildren(self) end

        local x = 12
        local y = 32
        local w = self.width - 24

        if ISLabel then
            local label = ISLabel:new(x, y, 20, self.message, 1, 1, 1, 1, UIFont.Small, true)
            label:initialise()
            self:addChild(label)
        end

        y = y + 34

        local bw = math.floor((w - 8) / 2)
        local yes = ISButton:new(x, y, bw, 24, "Yes", self, ParadiseZ_AutoFarm_ConfirmWindow.onButton)
        yes.internal = "yes"
        yes:initialise()
        yes:instantiate()
        self:addChild(yes)

        local no = ISButton:new(x + bw + 8, y, bw, 24, "No", self, ParadiseZ_AutoFarm_ConfirmWindow.onButton)
        no.internal = "no"
        no:initialise()
        no:instantiate()
        self:addChild(no)
    end

    function ParadiseZ_AutoFarm_ConfirmWindow:onButton(button)
        local mode = button and button.internal
        if mode == "yes" then
            if self.yesFn then pcall(self.yesFn) end
            self:removeFromUIManager()
            return
        end

        if self.noFn then pcall(self.noFn) end
        self:removeFromUIManager()
    end

    ParadiseZ_AutoFarm_AutoFarmWindow = ISCollapsableWindow:derive("ParadiseZ_AutoFarm_AutoFarmWindow")

    function ParadiseZ_AutoFarm_AutoFarmWindow:new(x, y, width, height, playerNum, collector)
        local o = ISCollapsableWindow:new(x, y, width, height)
        setmetatable(o, self); self.__index = self
        o.playerNum = playerNum or 0
        o.collector = collector
        o.title = "Auto-Farm"
        o.resizable = false
        o.pin = true
        o.includeDig = AW.TEND_INCLUDE_DIG_DEFAULT == true
        o.includeTreat = AW.TEND_INCLUDE_TREAT_DEFAULT ~= false
        o.includeWater = AW.TEND_INCLUDE_WATER_DEFAULT ~= false
        o.showFurrowHighlight = AW.showFurrowHighlight ~= false
        o.patternName = AW.currentFurrowPattern or AW.FURROW_PATTERN_FULL_SPACED
        o.buttons = {}
        return o
    end

    function ParadiseZ_AutoFarm_AutoFarmWindow:addButton(label, mode, x, y, w, h)
        local button = ISButton:new(x, y, w, h, label, self, ParadiseZ_AutoFarm_AutoFarmWindow.onButton)
        button.internal = mode
        button:initialise()
        button:instantiate()
        self:addChild(button)
        self.buttons[mode] = button
        return button
    end

    function ParadiseZ_AutoFarm_AutoFarmWindow:createChildren()
        if ISCollapsableWindow.createChildren then ISCollapsableWindow.createChildren(self) end

        local y = 26
        local x = 12
        local w = self.width - 24
        local h = 20
        local gap = 4

        local halfGap = 6
        local halfW = math.floor((w - halfGap) / 2)

        self:addButton("Tend Crops", "tend", x, y, w, h); y = y + h + gap
        self:addButton("Water Crops Only", "water", x, y, halfW, h)
        self:addButton("Treat Crops Only", "treat", x + halfW + halfGap, y, halfW, h)
        y = y + h + gap

        if ISLabel then
            local label = ISLabel:new(x, y + 3, h, "Tend Includes", 1, 1, 1, 1, UIFont.Small, true)
            label:initialise()
            self:addChild(label)
        end
        y = y + h

        local thirdGap = 5
        local thirdW = math.floor((w - (thirdGap * 2)) / 3)
        self:addButton("[ ] Dig", "toggleDig", x, y, thirdW, h)
        self:addButton("[X] Treat", "toggleTreat", x + thirdW + thirdGap, y, thirdW, h)
        self:addButton("[X] Water", "toggleWater", x + (thirdW + thirdGap) * 2, y, thirdW, h)
        y = y + h + gap

        if ISLabel then
            local label = ISLabel:new(x, y + 3, h, "Furrow Pattern", 1, 1, 1, 1, UIFont.Small, true)
            label:initialise()
            self:addChild(label)
        end
        y = y + h

        local highlightW = 92
        local comboW = w - highlightW - halfGap
        if ISComboBox then
            self.patternCombo = ISComboBox:new(x, y, comboW, h, self, ParadiseZ_AutoFarm_AutoFarmWindow.onPatternChanged)
            self.patternCombo:initialise()
            self.patternCombo:instantiate()
            for _, name in ipairs(AW.furrowPatternNames) do self.patternCombo:addOption(name) end
            for i, name in ipairs(AW.furrowPatternNames) do
                if name == self.patternName then self.patternCombo.selected = i break end
            end
            self:addChild(self.patternCombo)
            self:addButton("[X] Highlight", "toggleFurrowHighlight", x + comboW + halfGap, y, highlightW, h)
            y = y + h + gap
        else
            self:addButton("Pattern: " .. tostring(self.patternName), "cyclePattern", x, y, comboW, h)
            self:addButton("[X] Highlight", "toggleFurrowHighlight", x + comboW + halfGap, y, highlightW, h)
            y = y + h + gap
        end

        y = y + 4
        self:addButton("Close", "close", x, y, w, h); y = y + h + 14

        local rmW = math.floor((w - (thirdGap * 2)) / 3)
        local b1 = self:addButton("Remove Plots", "removePlots", x, y, rmW, h)
        local b2 = self:addButton("Remove Receding", "removeReceding", x + rmW + thirdGap, y, rmW, h)
        local b3 = self:addButton("Remove Plants", "removePlants", x + (rmW + thirdGap) * 2, y, rmW, h)
        self:makeRedButton(b1)
        self:makeRedButton(b2)
        self:makeRedButton(b3)

        self:updateCheckboxLabels()
        self:refreshHighlight()
    end

    function ParadiseZ_AutoFarm_AutoFarmWindow:makeRedButton(button)
        if not button then return end
        button.backgroundColor = { r = 0.55, g = 0.00, b = 0.00, a = 0.90 }
        button.backgroundColorMouseOver = { r = 0.75, g = 0.05, b = 0.05, a = 0.95 }
        button.borderColor = { r = 0.95, g = 0.25, b = 0.25, a = 1.00 }
        button.textColor = { r = 1.00, g = 1.00, b = 1.00, a = 1.00 }
    end

    function ParadiseZ_AutoFarm_AutoFarmWindow:getSelectedPattern()
        if self.patternCombo and self.patternCombo.options and self.patternCombo.selected then
            return self.patternCombo.options[self.patternCombo.selected] or self.patternName
        end
        return self.patternName or AW.FURROW_PATTERN_FULL_SPACED
    end

    function ParadiseZ_AutoFarm_AutoFarmWindow:onPatternChanged()
        self.patternName = self:getSelectedPattern()
        AW.currentFurrowPattern = self.patternName

        self:refreshHighlight()
    end

    function ParadiseZ_AutoFarm_AutoFarmWindow:refreshHighlight()
        AW.showFurrowHighlight = self.showFurrowHighlight == true
        AW.showAutoFarmHighlight = AW.showFurrowHighlight == true
        AW.currentFurrowPattern = self:getSelectedPattern()
        AW.highlightWindow = self
        AW.setHighlightTarget(self.collector, AW.currentFurrowPattern, AW.showAutoFarmHighlight)
    end

    function ParadiseZ_AutoFarm_AutoFarmWindow:updateCheckboxLabels()
        if self.buttons.toggleDig then
            self.buttons.toggleDig:setTitle((self.includeDig and "[X] " or "[ ] ") .. "Dig")
        end
        if self.buttons.toggleTreat then
            self.buttons.toggleTreat:setTitle((self.includeTreat and "[X] " or "[ ] ") .. "Treat")
        end
        if self.buttons.toggleWater then
            self.buttons.toggleWater:setTitle((self.includeWater and "[X] " or "[ ] ") .. "Water")
        end
        if self.buttons.toggleFurrowHighlight then
            self.buttons.toggleFurrowHighlight:setTitle((self.showFurrowHighlight and "[X] " or "[ ] ") .. "Highlight")
        end
    end

    function ParadiseZ_AutoFarm_AutoFarmWindow:openJobConfirm(mode, message)
        local sx, sy = 200, 200
        local w, h = 300, 115
        if getCore then
            local core = getCore()
            if core then
                sx = math.floor((core:getScreenWidth() - w) / 2)
                sy = math.floor((core:getScreenHeight() - h) / 2)
            end
        end

        local confirm = ParadiseZ_AutoFarm_ConfirmWindow:new(
            sx,
            sy,
            w,
            h,
            message or "Are you sure?",
            function()
                if ParadiseZ_AutoFarm and self.collector then
                    ParadiseZ_AutoFarm.start(self.playerNum or 0, self.collector, mode)
                end
            end,
            function()
                if ParadiseZ_AutoFarm then  end
            end
        )

        confirm:initialise()
        confirm:addToUIManager()
        confirm:setVisible(true)
        confirm:bringToTop()
        AW.confirmWindow = confirm
    end

    function ParadiseZ_AutoFarm_AutoFarmWindow:onButton(button)
        local AW2 = ParadiseZ_AutoFarm
        if not AW2 then self:removeFromUIManager() return end

        local mode = button and button.internal

        if mode == "close" then
            AW2.clearAutoFarmHighlight()
            self:removeFromUIManager()
            AW2.autoFarmWindow = nil
            return
        end

        if mode == "removePlots" then
            self:openJobConfirm("removePlots", "Remove all empty plots in this area?")
            return
        end

        if mode == "removeReceding" then
            self:openJobConfirm("removeReceding", "Remove all receding/dead plants in this area?")
            return
        end

        if mode == "removePlants" then
            self:openJobConfirm("removePlants", "Remove all seeded plants in this area?")
            return
        end

        if mode == "toggleDig" then
            self.includeDig = not self.includeDig
            self:updateCheckboxLabels()

            return
        end

        if mode == "toggleTreat" then
            self.includeTreat = not self.includeTreat
            self:updateCheckboxLabels()

            return
        end

        if mode == "toggleWater" then
            self.includeWater = not self.includeWater
            self:updateCheckboxLabels()

            return
        end

        if mode == "toggleFurrowHighlight" then
            self.showFurrowHighlight = not self.showFurrowHighlight
            self:updateCheckboxLabels()
            self:refreshHighlight()

            return
        end

        if mode == "cyclePattern" then
            local idx = 1
            for i, name in ipairs(AW2.furrowPatternNames) do if name == self.patternName then idx = i break end end
            idx = idx + 1
            if idx > #AW2.furrowPatternNames then idx = 1 end
            self.patternName = AW2.furrowPatternNames[idx]
            button:setTitle("Pattern: " .. tostring(self.patternName))
            self:refreshHighlight()
            return
        end

        if not self.collector then

            return
        end

        AW2.currentFurrowPattern = self:getSelectedPattern()
        AW2.pendingChainCarry = nil
        AW2.pendingTendPlan = nil

        if mode == "tend" then
            AW2.pendingTendPlan = {
                includeDig = self.includeDig == true,
                includeTreat = self.includeTreat == true,
                includeWater = self.includeWater == true
            }
        end


        AW2.start(self.playerNum or 0, self.collector, mode)
    end

    function AW.openAutoFarmUI(playerNum, collector)
        if AW.autoFarmWindow then pcall(function() AW.autoFarmWindow:removeFromUIManager() end) AW.autoFarmWindow = nil end
        AW.clearAutoFarmHighlight()

        local w, h, x, y = 340, 270, 200, 160
        if getCore then
            local core = getCore()
            if core then x = math.floor((core:getScreenWidth() - w) / 2); y = math.floor((core:getScreenHeight() - h) / 2) end
        end

        local win = ParadiseZ_AutoFarm_AutoFarmWindow:new(x, y, w, h, playerNum or 0, collector)
        win:initialise()
        win:addToUIManager()
        win:setVisible(true)
        win:bringToTop()

        AW.autoFarmWindow = win

    end

    function AW.onContext(playerNum, context, worldobjects, test)
        if test then return end
        local collector = AW.findCollectorFromWorldObjects(worldobjects)
        if not collector then return end
        context:addOption("Auto-Farm", AW, function() AW.openAutoFarmUI(playerNum, collector) end)
    end


    AW.lastStepMs = AW.nowMs()


end

do
    local AW = ParadiseZ_AutoFarm
    if not AW then
        return
    end

    pcall(require, "Farming/TimedActions/ISSeedAction")

    AW.VERSION = "ParadiseZ_AutoFarm"
    AW.INDEX_TOTAL_TIME = 90
    AW.INDEX_ROWS_PER_UPDATE = 1
    AW.TEND_INCLUDE_HARVEST_ALL_DEFAULT = false
    AW.TEND_INCLUDE_HARVEST_SEED_DEFAULT = true
    AW.TEND_INCLUDE_REPLANT_DEFAULT = false
    AW.TEND_INCLUDE_MATCH_PATTERN_DEFAULT = false
    AW.TEND_INCLUDE_CLEAR_RECEDING_DEFAULT = true
    AW.TEND_INCLUDE_DIG_DEFAULT = AW.TEND_INCLUDE_DIG_DEFAULT == true
    AW.TEND_INCLUDE_TREAT_DEFAULT = AW.TEND_INCLUDE_TREAT_DEFAULT ~= false
    AW.TEND_INCLUDE_WATER_DEFAULT = AW.TEND_INCLUDE_WATER_DEFAULT ~= false
    AW.pendingReplantRecords = {}
    AW.pendingReplantSeen = {}
    AW.pendingReplantActive = false
    AW.uiPrefsByFarm = AW.uiPrefsByFarm or {}
    AW.lastUIPrefs = AW.lastUIPrefs or nil

    local function tbool(v, default)
        if v == nil then return default == true end
        return v == true
    end

    function AW.prefKey(playerNum, collector)
        local p = AW.player(playerNum or 0)
        local name = "player" .. tostring(playerNum or 0)
        if p and p.getUsername then
            local ok, u = pcall(function() return p:getUsername() end)
            if ok and u and tostring(u) ~= "" then name = tostring(u) end
        end
        return name .. "|" .. (collector and AW.objKey(collector) or "nofarm")
    end

    function AW.defaultUIPrefs()
        return {
            includeDig = AW.TEND_INCLUDE_DIG_DEFAULT == true,
            includeTreat = AW.TEND_INCLUDE_TREAT_DEFAULT ~= false,
            includeWater = AW.TEND_INCLUDE_WATER_DEFAULT ~= false,
            includeHarvestAll = AW.TEND_INCLUDE_HARVEST_ALL_DEFAULT == true,
            includeHarvestSeed = AW.TEND_INCLUDE_HARVEST_SEED_DEFAULT ~= false,
            includeReplantHarvested = AW.TEND_INCLUDE_REPLANT_DEFAULT == true,
            includeMatchPattern = AW.TEND_INCLUDE_MATCH_PATTERN_DEFAULT == true,
            includeClearReceding = AW.TEND_INCLUDE_CLEAR_RECEDING_DEFAULT ~= false,
            showFurrowHighlight = AW.showFurrowHighlight ~= false,
            patternName = AW.currentFurrowPattern or AW.FURROW_PATTERN_FULL_SPACED
        }
    end

    function AW.copyUIPrefs(src)
        local d = AW.defaultUIPrefs()
        if src then
            for k, v in pairs(src) do d[k] = v end
        end
        return d
    end

    function AW.getPlayerPrefsTable(playerNum)
        local p = AW.player(playerNum or 0)
        if not p or not p.getModData then return nil end
        local md = p:getModData()
        if not md then return nil end
        md.ParadiseZ_AutoFarm = md.ParadiseZ_AutoFarm or {}
        md.ParadiseZ_AutoFarm.farmPrefs = md.ParadiseZ_AutoFarm.farmPrefs or {}
        return md.ParadiseZ_AutoFarm.farmPrefs
    end

    function AW.loadUIPrefs(playerNum, collector)
        local key = AW.prefKey(playerNum, collector)
        local playerPrefs = AW.getPlayerPrefsTable(playerNum)
        if playerPrefs and playerPrefs[key] then
            return AW.copyUIPrefs(playerPrefs[key])
        end
        if AW.uiPrefsByFarm and AW.uiPrefsByFarm[key] then
            return AW.copyUIPrefs(AW.uiPrefsByFarm[key])
        end
        if AW.lastUIPrefs then
            return AW.copyUIPrefs(AW.lastUIPrefs)
        end
        return AW.defaultUIPrefs()
    end

    function AW.saveUIPrefs(playerNum, collector, prefs)
        if not prefs then return end
        local key = AW.prefKey(playerNum, collector)
        local copy = AW.copyUIPrefs(prefs)
        AW.uiPrefsByFarm[key] = copy
        AW.lastUIPrefs = AW.copyUIPrefs(copy)
        local playerPrefs = AW.getPlayerPrefsTable(playerNum)
        if playerPrefs then playerPrefs[key] = AW.copyUIPrefs(copy) end

    end

    function AW.routeGreedy(crops, playerObj)
        table.sort(crops or {}, function(a, b)
            local ay, by = AW.num(a and a.y, 0), AW.num(b and b.y, 0)
            if ay ~= by then return ay < by end
            local ax, bx = AW.num(a and a.x, 0), AW.num(b and b.x, 0)
            if ax ~= bx then return ax < bx end
            return AW.num(a and a.z, 0) < AW.num(b and b.z, 0)
        end)

        return crops or {}
    end

    function AW.patternKeySet(centerObj, patternName)
        local set = {}
        local savedPattern = AW.currentFurrowPattern
        if patternName then AW.currentFurrowPattern = patternName end
        local points = AW.furrowPattern(centerObj, patternName or AW.currentFurrowPattern)
        if savedPattern then AW.currentFurrowPattern = savedPattern end
        for _, point in ipairs(points or {}) do
            set[tostring(point.x) .. "," .. tostring(point.y) .. "," .. tostring(point.z)] = true
        end
        return set
    end

    function AW.coordMatchesPattern(set, x, y, z)
        if not set then return true end
        return set[tostring(x) .. "," .. tostring(y) .. "," .. tostring(z)] == true
    end

    ParadiseZ_AutoFarm_IndexAction = ISBaseTimedAction:derive("ParadiseZ_AutoFarm_IndexAction")
    function ParadiseZ_AutoFarm_IndexAction:isValid()
        return self.character ~= nil and self.collector ~= nil and self.mode ~= nil
    end
    function ParadiseZ_AutoFarm_IndexAction:buildRows()
        local cx = math.floor(AW.num(self.collector:getX(), 0))
        local cy = math.floor(AW.num(self.collector:getY(), 0))
        local cz = math.floor(AW.num(self.collector:getZ(), 0))
        self.cx, self.cy, self.cz = cx, cy, cz
        self.sourceRows, self.cropRows = {}, {}
        for y = cy - AW.WATER_SOURCE_RADIUS, cy + AW.WATER_SOURCE_RADIUS do
            table.insert(self.sourceRows, y)
        end
        for y = cy - AW.CROP_RADIUS, cy + AW.CROP_RADIUS do
            table.insert(self.cropRows, y)
        end
        self.sourceRowIndex, self.cropRowIndex = 1, 1
        self.sources, self.sourceSeen, self.crops = {}, {}, {}
        self.patternSet = self.matchPattern and AW.patternKeySet(self.collector, self.patternName) or nil
        self.prepared = true

    end
    function ParadiseZ_AutoFarm_IndexAction:processSourceRow(y)
        local cell = getCell()
        for x = self.cx - AW.WATER_SOURCE_RADIUS, self.cx + AW.WATER_SOURCE_RADIUS do
            local square = cell:getGridSquare(x, y, self.cz)
            if square then
                AW.squareObjects(square, function(obj)
                    local source = AW.makeSourceFromObject(obj)
                    if source then
                        local key = AW.sourceKey(source)
                        if not self.sourceSeen[key] then
                            self.sourceSeen[key] = true
                            table.insert(self.sources, source)
                        end
                    end
                end)
            end
        end
    end
    function ParadiseZ_AutoFarm_IndexAction:processCropRow(y)
        local cell = getCell()
        for x = self.cx - AW.CROP_RADIUS, self.cx + AW.CROP_RADIUS do
            if AW.coordMatchesPattern(self.patternSet, x, y, self.cz) then
                local square = cell:getGridSquare(x, y, self.cz)
                if square then
                    local plant = AW.plantAt(x, y, self.cz)
                    if plant and not AW.invalidPlant(plant) then
                        local key = tostring(x) .. "," .. tostring(y) .. "," .. tostring(self.cz)
                        local needs, needed, current, target, skipAt, seed, sensitive, devil, maxSafe = AW.cropPlan(plant, key)
                        local disease = AW.diseaseInfo(plant)
                        table.insert(self.crops, { x = x, y = y, z = self.cz, key = key, seed = seed })

                    end
                end
            end
        end
    end
    function ParadiseZ_AutoFarm_IndexAction:processSome()
        if not self.prepared then self:buildRows() end
        local budget = AW.INDEX_ROWS_PER_UPDATE or 1
        while budget > 0 and self.sourceRowIndex <= #self.sourceRows do
            self:processSourceRow(self.sourceRows[self.sourceRowIndex])
            self.sourceRowIndex = self.sourceRowIndex + 1
            budget = budget - 1
        end
        while budget > 0 and self.cropRowIndex <= #self.cropRows do
            self:processCropRow(self.cropRows[self.cropRowIndex])
            self.cropRowIndex = self.cropRowIndex + 1
            budget = budget - 1
        end
    end
    function ParadiseZ_AutoFarm_IndexAction:update()
        self:processSome()
        self.character:faceLocation(self.collector:getX(), self.collector:getY())
    end
    function ParadiseZ_AutoFarm_IndexAction:start()

        self:buildRows()
    end
    function ParadiseZ_AutoFarm_IndexAction:stop()

        ISBaseTimedAction.stop(self)
    end
    function ParadiseZ_AutoFarm_IndexAction:perform()
        while self.sourceRowIndex <= #self.sourceRows or self.cropRowIndex <= #self.cropRows do self:processSome() end
        self.sources = AW.addWaterTileFallbackIfNeeded(self.sources, self.collector)

        for i, source in ipairs(self.sources) do  end

        local playerObj = self.character
        local crops = AW.routeGreedy(self.crops, playerObj)
        if #crops <= 0 then
            playerObj:Say(AW.noneFoundText and AW.noneFoundText(self.mode) or "Nothing needs attention here.")

            local carry = AW.job and AW.job.chainQueue or nil
            if AW.job then AW.job.active = false end
            ISBaseTimedAction.perform(self)
            if carry and #carry > 0 then
                local nextJob = table.remove(carry, 1)
                AW.pendingChainCarry = carry
                if nextJob.pattern then AW.currentFurrowPattern = nextJob.pattern end

                AW.start(self.playerNum or 0, self.collector, nextJob.mode)
            end
            return
        end
        AW.job.sources = self.sources
        AW.job.pending = crops
        AW.job.treatAttempts = {}
        AW.job.devilWatering = {}
        AW.job.preferredWaterCan = nil
        AW.job.localWater = {}
        AW.job.watchdogRetries = 0
        AW.job.lastQueuedKind = nil
        AW.job.lastQueuedCropKey = nil
        playerObj:Say(AW.foundText and AW.foundText(self.mode, #crops) or "Crops need attention.")

        ISBaseTimedAction.perform(self)
        AW.touch("row-staged-index-complete")
        AW.step()
    end
    function ParadiseZ_AutoFarm_IndexAction:new(character, collector, mode, playerNum)
        local o = {}; setmetatable(o, self); self.__index = self
        o.character = character; o.collector = collector; o.mode = mode; o.playerNum = playerNum or 0
        o.maxTime = AW.INDEX_TOTAL_TIME or 90
        o.stopOnWalk = true; o.stopOnRun = true; o.stopOnAim = true
        o.prepared = false
        o.matchPattern = AW.pendingMatchPattern == true
        o.patternName = AW.currentFurrowPattern
        return o
    end

    ParadiseZ_AutoFarm_TargetIndexAction = ISBaseTimedAction:derive("ParadiseZ_AutoFarm_TargetIndexAction")
    function ParadiseZ_AutoFarm_TargetIndexAction:isValid()
        return self.character ~= nil and self.collector ~= nil and self.mode ~= nil
    end
    function ParadiseZ_AutoFarm_TargetIndexAction:buildRows()
        local cx = math.floor(AW.num(self.collector:getX(), 0))
        local cy = math.floor(AW.num(self.collector:getY(), 0))
        local cz = math.floor(AW.num(self.collector:getZ(), 0))
        self.cx, self.cy, self.cz = cx, cy, cz
        self.rows, self.targets, self.prepared = {}, {}, true
        self.patternSet = self.matchPattern and AW.patternKeySet(self.collector, self.patternName) or nil
        if self.mode == "digFurrows" then
            local points = AW.furrowPattern(self.collector, self.patternName or AW.currentFurrowPattern)
            local byY = {}
            for _, p in ipairs(points or {}) do
                byY[p.y] = byY[p.y] or {}
                table.insert(byY[p.y], p)
            end
            for y = cy - AW.FURROW_RADIUS, cy + AW.FURROW_RADIUS do
                local row = byY[y] or {}
                table.sort(row, function(a, b) return AW.num(a.x, 0) < AW.num(b.x, 0) end)
                table.insert(self.rows, { y = y, points = row })
            end
        else
            for y = cy - AW.CROP_RADIUS, cy + AW.CROP_RADIUS do
                table.insert(self.rows, { y = y })
            end
        end
        self.rowIndex = 1

    end
    function ParadiseZ_AutoFarm_TargetIndexAction:addHarvestTarget(x, y)
        if not AW.coordMatchesPattern(self.patternSet, x, y, self.cz) then return end
        local plant = AW.plantAt(x, y, self.cz)
        if plant and not AW.invalidPlant(plant) then
            local canHarvest = AW.canHarvestPlant(plant)
            local seedBearing = AW.isSeedBearingHarvest(plant)
            local seedOnly = self.mode == "harvestSeed"
            if canHarvest and ((not seedOnly) or seedBearing) then
                local key = tostring(x) .. "," .. tostring(y) .. "," .. tostring(self.cz)
                table.insert(self.targets, { x = x, y = y, z = self.cz, key = key, seed = tostring(plant.typeOfSeed or "unknown") })

            end
        end
    end
    function ParadiseZ_AutoFarm_TargetIndexAction:addRemoveTarget(x, y)
        if not AW.coordMatchesPattern(self.patternSet, x, y, self.cz) then return end
        local plant = AW.plantAt(x, y, self.cz)
        if plant and AW.removeModeMatchesPlant(self.mode, plant) then
            local key = tostring(x) .. "," .. tostring(y) .. "," .. tostring(self.cz)
            table.insert(self.targets, { x = x, y = y, z = self.cz, key = key, seed = tostring(plant.typeOfSeed or "none"), state = tostring(plant.state or "unknown") })

        end
    end
    function ParadiseZ_AutoFarm_TargetIndexAction:addDigTarget(point)
        local square = getCell():getGridSquare(point.x, point.y, point.z)
        local ok, reason = AW.isFurrowAcceptableSquare(square)
        local key = tostring(point.x) .. "," .. tostring(point.y) .. "," .. tostring(point.z)
        if ok then
            table.insert(self.targets, { x = point.x, y = point.y, z = point.z, key = key, dx = point.dx, dy = point.dy, pattern = point.pattern })

        else

        end
    end
    function ParadiseZ_AutoFarm_TargetIndexAction:processRow(row)
        if self.mode == "digFurrows" then
            for _, point in ipairs(row.points or {}) do self:addDigTarget(point) end
            return
        end
        for x = self.cx - AW.CROP_RADIUS, self.cx + AW.CROP_RADIUS do
            if self.mode == "harvest" or self.mode == "harvestSeed" then
                self:addHarvestTarget(x, row.y)
            elseif self.mode == "removePlots" or self.mode == "removeReceding" or self.mode == "removePlants" then
                self:addRemoveTarget(x, row.y)
            end
        end
    end
    function ParadiseZ_AutoFarm_TargetIndexAction:processSome()
        if not self.prepared then self:buildRows() end
        local budget = AW.INDEX_ROWS_PER_UPDATE or 1
        while budget > 0 and self.rowIndex <= #self.rows do
            self:processRow(self.rows[self.rowIndex])
            self.rowIndex = self.rowIndex + 1
            budget = budget - 1
        end
    end
    function ParadiseZ_AutoFarm_TargetIndexAction:update()
        self:processSome()
        self.character:faceLocation(self.collector:getX(), self.collector:getY())
    end
    function ParadiseZ_AutoFarm_TargetIndexAction:start()

        self:buildRows()
    end
    function ParadiseZ_AutoFarm_TargetIndexAction:stop()

        ISBaseTimedAction.stop(self)
    end
    function ParadiseZ_AutoFarm_TargetIndexAction:perform()
        while self.rowIndex <= #self.rows do self:processSome() end
        local playerObj = self.character
        local targets = AW.routeGreedy(self.targets, playerObj)
        local carry = (AW.job and AW.job.chainQueue) or AW.pendingChainCarry
        AW.pendingChainCarry = nil
        local mode = self.mode

        if #targets <= 0 then
            if AW.job then AW.job.active = false end
            if mode == "harvestSeed" then playerObj:Say("No seed-bearing crops nearby.")
            elseif mode == "harvest" then playerObj:Say("No harvestable crops nearby.")
            elseif mode == "digFurrows" then playerObj:Say("No acceptable furrow tiles nearby.")
            elseif mode == "removePlots" or mode == "removeReceding" or mode == "removePlants" then playerObj:Say("No " .. AW.removeModeLabel(mode) .. " nearby.") end

            ISBaseTimedAction.perform(self)
            AW.continueChainOrFinish(playerObj, self.playerNum or 0, self.collector, carry, mode)
            return
        end

        if mode == "harvest" or mode == "harvestSeed" then
            AW.job = {
                active = true, mode = mode, playerNum = self.playerNum or 0, center = self.collector,
                sources = {}, pending = targets, treatAttempts = {}, devilWatering = {}, localWater = {}, preferredWaterCan = nil,
                watchdogRetries = 0, lastQueuedKind = nil, lastQueuedCropKey = nil, chainQueue = carry or {},
                queuedHarvestKeys = {}, collectReplant = AW.pendingReplantActive == true
            }
            playerObj:Say(AW.foundText and AW.foundText(mode, #targets) or "Crops need attention.")
        elseif mode == "removePlots" or mode == "removeReceding" or mode == "removePlants" then
            AW.job = {
                active = true, mode = mode, playerNum = self.playerNum or 0, center = self.collector,
                sources = {}, pending = targets, treatAttempts = {}, devilWatering = {}, localWater = {}, preferredWaterCan = nil,
                watchdogRetries = 0, lastQueuedKind = nil, lastQueuedCropKey = nil, chainQueue = carry or {},
                queuedRemoveKeys = {}
            }
            playerObj:Say(AW.foundText and AW.foundText(mode, #targets) or "Farm clearing needed.")
        elseif mode == "digFurrows" then
            AW.job = {
                active = true, mode = "digFurrows", playerNum = self.playerNum or 0, center = self.collector,
                sources = {}, pending = targets, treatAttempts = {}, devilWatering = {}, localWater = {}, preferredWaterCan = nil,
                watchdogRetries = 0, lastQueuedKind = nil, lastQueuedCropKey = nil, chainQueue = carry or {},
                queuedDigKeys = {}
            }
            playerObj:Say(AW.foundText and AW.foundText("digFurrows", #targets) or "Furrows need digging.")
        end


        ISBaseTimedAction.perform(self)
        AW.touch("target-row-index-complete")
        AW.step()
    end
    function ParadiseZ_AutoFarm_TargetIndexAction:new(character, collector, mode, playerNum)
        local o = {}; setmetatable(o, self); self.__index = self
        o.character = character; o.collector = collector; o.mode = mode; o.playerNum = playerNum or 0
        o.maxTime = AW.INDEX_TOTAL_TIME or 90
        o.stopOnWalk = true; o.stopOnRun = true; o.stopOnAim = true
        o.prepared = false
        o.matchPattern = AW.pendingMatchPattern == true
        o.patternName = AW.currentFurrowPattern
        return o
    end

    AW._AutoFarm_baseQueueHarvest = AW._AutoFarm_baseQueueHarvest or AW.queueHarvest
    function AW.queueHarvest(playerObj, crop, plant)
        if AW.job and AW.job.collectReplant and crop and plant then
            local seed = tostring(plant.typeOfSeed or crop.seed or "")
            if seed ~= "" and seed ~= "none" and seed ~= "nil" and seed ~= "no seed" then
                AW.pendingReplantRecords = AW.pendingReplantRecords or {}
                AW.pendingReplantSeen = AW.pendingReplantSeen or {}
                if not AW.pendingReplantSeen[crop.key] then
                    AW.pendingReplantSeen[crop.key] = true
                    table.insert(AW.pendingReplantRecords, { x = crop.x, y = crop.y, z = crop.z, key = crop.key, seed = seed })

                end
            end
        end
        return AW._AutoFarm_baseQueueHarvest(playerObj, crop, plant)
    end

    function AW.getSeedItems(playerObj, typeOfSeed)
        if not playerObj or not typeOfSeed then return nil, 0, nil end
        local props = farming_vegetableconf and farming_vegetableconf.props and farming_vegetableconf.props[typeOfSeed]
        if not props or not props.seedName then return nil, 0, props end
        local required = math.floor(AW.num(props.seedsRequired, 0))
        if required <= 0 then return nil, 0, props end
        local inv = playerObj:getInventory()
        if not inv then return nil, 0, props end
        local count = inv:getCountTypeRecurse(props.seedName)
        if AW.num(count, 0) < required then return nil, AW.num(count, 0), props end
        local items = inv:getSomeTypeRecurse(props.seedName, required)
        if not items or items:size() < required then return nil, AW.num(count, 0), props end
        local seeds = {}
        for i = 1, required do table.insert(seeds, items:get(i - 1)) end
        return seeds, AW.num(count, 0), props
    end

    function AW.scanReplantHarvested(centerObj)
        local records = AW.pendingReplantRecords or {}
        local targets = {}
        local patternSet = AW.pendingMatchPattern and AW.patternKeySet(centerObj, AW.currentFurrowPattern) or nil
        for _, rec in ipairs(records) do
            if rec and AW.coordMatchesPattern(patternSet, rec.x, rec.y, rec.z) then
                local plant = AW.plantAt(rec.x, rec.y, rec.z)
                if plant and AW.isEmptyPlot(plant) then
                    table.insert(targets, { x = rec.x, y = rec.y, z = rec.z, key = rec.key, seed = rec.seed })

                else

                end
            end
        end

        return AW.routeGreedy(targets, AW.player(0) or getPlayer())
    end

    function AW.queueReplant(playerObj, crop, plant)
        local square = getCell():getGridSquare(crop.x, crop.y, crop.z)
        if AW.job and crop then
            AW.job.lastActionTargetX = crop.x
            AW.job.lastActionTargetY = crop.y
            AW.job.lastActionTargetZ = crop.z
        end
        if not square or not plant or not AW.isEmptyPlot(plant) then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
            return true
        end
        local seeds, count, props = AW.getSeedItems(playerObj, crop.seed)
        if not seeds or not props then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
            return true
        end
        if not AW.queueWalkAdj(playerObj, square) then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
            return true
        end

        if AW.TRUST_QUEUED_ACTIONS and AW.job then
            AW.job.queuedReplantKeys = AW.job.queuedReplantKeys or {}
            AW.job.queuedReplantKeys[crop.key] = true
        end
        ISTimedActionQueue.add(ISSeedAction:new(playerObj, seeds, props.seedsRequired, crop.seed, plant, 40))
        ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
        AW.job.lastQueuedKind = "replant"
        AW.job.lastQueuedCropKey = crop.key
        AW.job.watchdogRetries = 0
        AW.touch("queued-replant")
        return true
    end

    AW._AutoFarm_baseStep = AW._AutoFarm_baseStep or AW.step
    function AW.step()
        local job = AW.job
        if job and job.active and job.mode == "replantHarvested" then
            AW.touch("step")
            local playerObj = AW.player(job.playerNum)
            if not playerObj then AW.cancel("player missing") return end
            if playerObj:isDead() then AW.cancel("player dead") return end
            while #job.pending > 0 do
                local crop = job.pending[1]
                local plant = AW.plantAt(crop.x, crop.y, crop.z)
                if job.queuedReplantKeys and job.queuedReplantKeys[crop.key] then

                    table.remove(job.pending, 1)
                    job.watchdogRetries = 0
                elseif not plant or not AW.isEmptyPlot(plant) then

                    table.remove(job.pending, 1)
                    job.watchdogRetries = 0
                else
                    return AW.queueReplant(playerObj, crop, plant)
                end
            end

            job.active = false
            if job.chainQueue and #job.chainQueue > 0 and job.center then
                local nextJob = table.remove(job.chainQueue, 1)
                local remaining = job.chainQueue

                AW.pendingChainCarry = remaining
                if nextJob.pattern then AW.currentFurrowPattern = nextJob.pattern end
                AW.start(job.playerNum or 0, job.center, nextJob.mode)
            end
            return
        end
        return AW._AutoFarm_baseStep()
    end

    function AW.buildTendChain(plan)
        plan = plan or {}
        local chain = {}

        if plan.includeHarvestSeed == true then
            table.insert(chain, { mode = "harvestSeed" })
        end
        if plan.includeHarvestAll == true then
            table.insert(chain, { mode = "harvest" })
        end
        if plan.includeReplantHarvested == true then
            table.insert(chain, { mode = "replantHarvested" })
        end
        if plan.includeClearReceding == true then
            table.insert(chain, { mode = "removeReceding" })
        end
        if plan.includeDig == true then
            table.insert(chain, { mode = "digFurrows", pattern = AW.currentFurrowPattern })
        end
        if plan.includeTreat ~= false then
            table.insert(chain, { mode = "treat" })
        end
        if plan.includeWater ~= false then
            table.insert(chain, { mode = "water" })
        end

        return chain
    end

    AW._AutoFarm_baseStart = AW._AutoFarm_baseStart or AW.start
    function AW.start(playerNum, collector, mode)
        mode = mode or "tend"
        local playerObj = AW.player(playerNum)
        if not playerObj then  return end
        if not AW.isWaterCollector(collector) then  return end

        if AW.job and AW.job.active then
            playerObj:Say("Auto-Farm is already running.")

            return
        end

        if ISTimedActionQueue and getPlayer() then pcall(function() ISTimedActionQueue.clear(getPlayer()) end) end

        if mode ~= "tend" and AW.pendingChainCarry == nil then
            AW.pendingMatchPattern = false
            AW.pendingReplantActive = false
        end

        if mode == "tend" then
            local plan = AW.pendingTendPlan or AW.defaultUIPrefs()
            AW.pendingTendPlan = nil
            AW.pendingReplantRecords = {}
            AW.pendingReplantSeen = {}
            AW.pendingReplantActive = plan.includeReplantHarvested == true
            AW.pendingMatchPattern = plan.includeMatchPattern == true

            local chain = AW.buildTendChain(plan)
            local first = table.remove(chain, 1)
            AW.pendingChainCarry = chain


            if first then AW.start(playerNum or 0, collector, first.mode) end
            return
        end

        if mode == "removeAll" then
            AW.pendingChainCarry = { { mode = "removeReceding" }, { mode = "removePlots" } }

            AW.start(playerNum or 0, collector, "removePlants")
            return
        end

        local carry = AW.pendingChainCarry

        if mode == "replantHarvested" then
            AW.pendingChainCarry = nil
            local targets = AW.scanReplantHarvested(collector)
            if #targets <= 0 then
                playerObj:Say("No harvested plots to replant.")

                AW.continueChainOrFinish(playerObj, playerNum, collector, carry, mode)
                return
            end
            AW.job = {
                active = true, mode = "replantHarvested", playerNum = playerNum or 0, center = collector,
                sources = {}, pending = targets, treatAttempts = {}, devilWatering = {}, localWater = {}, preferredWaterCan = nil,
                watchdogRetries = 0, lastQueuedKind = nil, lastQueuedCropKey = nil, chainQueue = carry or {}, queuedReplantKeys = {}
            }
            playerObj:Say(AW.foundText and AW.foundText("replantHarvested", #targets) or "Harvested rows need replanting.")
            AW.step()
            return
        end

        if mode == "harvest" or mode == "harvestSeed" or mode == "removePlots" or mode == "removeReceding" or mode == "removePlants" or mode == "digFurrows" then
            AW.pendingChainCarry = carry
            if mode == "removePlots" or mode == "removeReceding" or mode == "removePlants" then
                if playerObj:getVehicle() then playerObj:Say("Exit the vehicle first.")  return end
                local tool = AW.findRemoveTool(playerObj)
                if not tool then
                    playerObj:Say("No shovel/trowel found for removal.")

                    AW.pendingChainCarry = nil
                    AW.continueChainOrFinish(playerObj, playerNum, collector, carry, mode)
                    return
                end

            elseif mode == "digFurrows" then
                if playerObj:getVehicle() then playerObj:Say("Exit the vehicle first.")  return end
                local tool = AW.findDigTool(playerObj)
                if not tool and not AW.handsCanDig(playerObj) then
                    playerObj:Say("No shovel/trowel, and hands are injured.")

                    AW.pendingChainCarry = nil
                    AW.continueChainOrFinish(playerObj, playerNum, collector, carry, mode)
                    return
                end

            else

            end
            AW.job = {
                active = true, mode = mode, playerNum = playerNum or 0, center = collector,
                sources = {}, pending = {}, treatAttempts = {}, devilWatering = {}, localWater = {}, preferredWaterCan = nil,
                watchdogRetries = 0, lastQueuedKind = "target-index", lastQueuedCropKey = nil, chainQueue = carry or {}
            }
            AW.touch("queued-target-row-index")
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_TargetIndexAction:new(playerObj, collector, mode, playerNum or 0))
            playerObj:Say("Auto-Farm " .. tostring(mode) .. ": indexing...")
            return
        end

        return AW._AutoFarm_baseStart(playerNum, collector, mode)
    end

    if AW.autoFarmWindow then pcall(function() AW.autoFarmWindow:removeFromUIManager() end) AW.autoFarmWindow = nil end
    if AW.onContext then pcall(function() Events.OnFillWorldObjectContextMenu.Remove(AW.onContext) end) end

    ParadiseZ_AutoFarm_AutoFarmWindow = ISCollapsableWindow:derive("ParadiseZ_AutoFarm_AutoFarmWindow")

    function ParadiseZ_AutoFarm_AutoFarmWindow:new(x, y, width, height, playerNum, collector)
        local o = ISCollapsableWindow:new(x, y, width, height)
        setmetatable(o, self); self.__index = self
        o.playerNum = playerNum or 0
        o.collector = collector
        o.title = "Auto-Farm"
        o.resizable = false
        o.pin = true
        o.buttons = {}
        local prefs = AW.loadUIPrefs(o.playerNum, collector)
        o.includeDig = tbool(prefs.includeDig, AW.TEND_INCLUDE_DIG_DEFAULT)
        o.includeTreat = tbool(prefs.includeTreat, AW.TEND_INCLUDE_TREAT_DEFAULT)
        o.includeWater = tbool(prefs.includeWater, AW.TEND_INCLUDE_WATER_DEFAULT)
        o.includeHarvestAll = tbool(prefs.includeHarvestAll, AW.TEND_INCLUDE_HARVEST_ALL_DEFAULT)
        o.includeHarvestSeed = tbool(prefs.includeHarvestSeed, AW.TEND_INCLUDE_HARVEST_SEED_DEFAULT)
        o.includeReplantHarvested = tbool(prefs.includeReplantHarvested, AW.TEND_INCLUDE_REPLANT_DEFAULT)
        o.includeMatchPattern = tbool(prefs.includeMatchPattern, AW.TEND_INCLUDE_MATCH_PATTERN_DEFAULT)
        o.includeClearReceding = tbool(prefs.includeClearReceding, AW.TEND_INCLUDE_CLEAR_RECEDING_DEFAULT)
        o.showFurrowHighlight = tbool(prefs.showFurrowHighlight, AW.showFurrowHighlight ~= false)
        o.patternName = prefs.patternName or AW.currentFurrowPattern or AW.FURROW_PATTERN_FULL_SPACED
        return o
    end

    function ParadiseZ_AutoFarm_AutoFarmWindow:addButton(label, mode, x, y, w, h)
        local button = ISButton:new(x, y, w, h, label, self, ParadiseZ_AutoFarm_AutoFarmWindow.onButton)
        button.internal = mode
        button:initialise()
        button:instantiate()
        self:addChild(button)
        self.buttons[mode] = button
        return button
    end

    function ParadiseZ_AutoFarm_AutoFarmWindow:makeRedButton(button)
        if not button then return end
        button.backgroundColor = { r = 0.55, g = 0.00, b = 0.00, a = 0.90 }
        button.backgroundColorMouseOver = { r = 0.75, g = 0.05, b = 0.05, a = 0.95 }
        button.borderColor = { r = 0.95, g = 0.25, b = 0.25, a = 1.00 }
        button.textColor = { r = 1.00, g = 1.00, b = 1.00, a = 1.00 }
    end

    function ParadiseZ_AutoFarm_AutoFarmWindow:createChildren()
        if ISCollapsableWindow.createChildren then ISCollapsableWindow.createChildren(self) end
        local y = 26
        local x = 12
        local w = self.width - 24
        local h = 20
        local gap = 4
        local thirdGap = 5
        local thirdW = math.floor((w - (thirdGap * 2)) / 3)
        local halfGap = 6
        local halfW = math.floor((w - halfGap) / 2)

        self:addButton("Tend Crops", "tend", x, y, w, h); y = y + h + gap
        self:addButton("Water Crops Only", "water", x, y, halfW, h)
        self:addButton("Treat Crops Only", "treat", x + halfW + halfGap, y, halfW, h)
        y = y + h + gap

        if ISLabel then
            local label = ISLabel:new(x, y + 3, h, "Tend Includes", 1, 1, 1, 1, UIFont.Small, true)
            label:initialise(); self:addChild(label)
        end
        y = y + h

        self:addButton("[ ] Harvest All", "toggleHarvestAll", x, y, thirdW, h)
        self:addButton("[X] Seed-bearing", "toggleHarvestSeed", x + thirdW + thirdGap, y, thirdW, h)
        self:addButton("[ ] Replant Harvested", "toggleReplantHarvested", x + (thirdW + thirdGap) * 2, y, thirdW, h)
        y = y + h + gap

        self:addButton("[ ] Match Pattern", "toggleMatchPattern", x, y, halfW, h)
        self:addButton("[X] Clear Receding", "toggleClearReceding", x + halfW + halfGap, y, halfW, h)
        y = y + h + gap

        self:addButton("[ ] Dig", "toggleDig", x, y, thirdW, h)
        self:addButton("[X] Treat", "toggleTreat", x + thirdW + thirdGap, y, thirdW, h)
        self:addButton("[X] Water", "toggleWater", x + (thirdW + thirdGap) * 2, y, thirdW, h)
        y = y + h + gap

        if ISLabel then
            local label = ISLabel:new(x, y + 3, h, "Furrow Pattern", 1, 1, 1, 1, UIFont.Small, true)
            label:initialise(); self:addChild(label)
        end
        y = y + h

        local highlightW = 96
        local comboW = w - highlightW - halfGap
        if ISComboBox then
            self.patternCombo = ISComboBox:new(x, y, comboW, h, self, ParadiseZ_AutoFarm_AutoFarmWindow.onPatternChanged)
            self.patternCombo:initialise(); self.patternCombo:instantiate()
            for _, name in ipairs(AW.furrowPatternNames) do self.patternCombo:addOption(name) end
            for i, name in ipairs(AW.furrowPatternNames) do if name == self.patternName then self.patternCombo.selected = i break end end
            self:addChild(self.patternCombo)
            self:addButton("[X] Highlight", "toggleFurrowHighlight", x + comboW + halfGap, y, highlightW, h)
            y = y + h + gap
        else
            self:addButton("Pattern: " .. tostring(self.patternName), "cyclePattern", x, y, comboW, h)
            self:addButton("[X] Highlight", "toggleFurrowHighlight", x + comboW + halfGap, y, highlightW, h)
            y = y + h + gap
        end

        y = y + 4
        self:addButton("Close", "close", x, y, w, h); y = y + h + 12

        local rmW = math.floor((w - (thirdGap * 2)) / 3)
        local b1 = self:addButton("Remove Plots", "removePlots", x, y, rmW, h)
        local b2 = self:addButton("Remove Receding", "removeReceding", x + rmW + thirdGap, y, rmW, h)
        local b3 = self:addButton("Remove Plants", "removePlants", x + (rmW + thirdGap) * 2, y, rmW, h)
        self:makeRedButton(b1); self:makeRedButton(b2); self:makeRedButton(b3)
        y = y + h + 8

        local removeAll = self:addButton("Remove All", "removeAll", x, y, w, h)
        self:makeRedButton(removeAll)

        self:updateCheckboxLabels()
        self:refreshHighlight()
    end

    function ParadiseZ_AutoFarm_AutoFarmWindow:getSelectedPattern()
        if self.patternCombo and self.patternCombo.options and self.patternCombo.selected then
            return self.patternCombo.options[self.patternCombo.selected] or self.patternName
        end
        return self.patternName or AW.FURROW_PATTERN_FULL_SPACED
    end

    function ParadiseZ_AutoFarm_AutoFarmWindow:prefs()
        return {
            includeDig = self.includeDig == true,
            includeTreat = self.includeTreat == true,
            includeWater = self.includeWater == true,
            includeHarvestAll = self.includeHarvestAll == true,
            includeHarvestSeed = self.includeHarvestSeed == true,
            includeReplantHarvested = self.includeReplantHarvested == true,
            includeMatchPattern = self.includeMatchPattern == true,
            includeClearReceding = self.includeClearReceding == true,
            showFurrowHighlight = self.showFurrowHighlight == true,
            patternName = self:getSelectedPattern()
        }
    end

    function ParadiseZ_AutoFarm_AutoFarmWindow:savePrefs()
        AW.saveUIPrefs(self.playerNum or 0, self.collector, self:prefs())
    end

    function ParadiseZ_AutoFarm_AutoFarmWindow:onPatternChanged()
        self.patternName = self:getSelectedPattern()
        AW.currentFurrowPattern = self.patternName
        self:savePrefs()

        self:refreshHighlight()
    end

    function ParadiseZ_AutoFarm_AutoFarmWindow:refreshHighlight()
        AW.showFurrowHighlight = self.showFurrowHighlight == true
        AW.showAutoFarmHighlight = AW.showFurrowHighlight == true
        AW.currentFurrowPattern = self:getSelectedPattern()
        AW.highlightWindow = self
        AW.setHighlightTarget(self.collector, AW.currentFurrowPattern, AW.showAutoFarmHighlight)
    end

    function ParadiseZ_AutoFarm_AutoFarmWindow:updateCheckboxLabels()
        if self.buttons.toggleHarvestAll then self.buttons.toggleHarvestAll:setTitle((self.includeHarvestAll and "[X] " or "[ ] ") .. "Harvest All") end
        if self.buttons.toggleHarvestSeed then self.buttons.toggleHarvestSeed:setTitle((self.includeHarvestSeed and "[X] " or "[ ] ") .. "Seed-bearing") end
        if self.buttons.toggleReplantHarvested then self.buttons.toggleReplantHarvested:setTitle((self.includeReplantHarvested and "[X] " or "[ ] ") .. "Replant Harvested") end
        if self.buttons.toggleMatchPattern then self.buttons.toggleMatchPattern:setTitle((self.includeMatchPattern and "[X] " or "[ ] ") .. "Match Pattern") end
        if self.buttons.toggleClearReceding then self.buttons.toggleClearReceding:setTitle((self.includeClearReceding and "[X] " or "[ ] ") .. "Clear Receding") end
        if self.buttons.toggleDig then self.buttons.toggleDig:setTitle((self.includeDig and "[X] " or "[ ] ") .. "Dig") end
        if self.buttons.toggleTreat then self.buttons.toggleTreat:setTitle((self.includeTreat and "[X] " or "[ ] ") .. "Treat") end
        if self.buttons.toggleWater then self.buttons.toggleWater:setTitle((self.includeWater and "[X] " or "[ ] ") .. "Water") end
        if self.buttons.toggleFurrowHighlight then self.buttons.toggleFurrowHighlight:setTitle((self.showFurrowHighlight and "[X] " or "[ ] ") .. "Highlight") end
    end

    function ParadiseZ_AutoFarm_AutoFarmWindow:openJobConfirm(mode, message)
        local sx, sy = 200, 200
        local w, h = 330, 115
        if getCore then
            local core = getCore()
            if core then sx = math.floor((core:getScreenWidth() - w) / 2); sy = math.floor((core:getScreenHeight() - h) / 2) end
        end
        local confirm = ParadiseZ_AutoFarm_ConfirmWindow:new(
            sx, sy, w, h, message or "Are you sure?",
            function() if ParadiseZ_AutoFarm and self.collector then ParadiseZ_AutoFarm.start(self.playerNum or 0, self.collector, mode) end end,
            function() if ParadiseZ_AutoFarm then  end end
        )
        confirm:initialise(); confirm:addToUIManager(); confirm:setVisible(true); confirm:bringToTop(); AW.confirmWindow = confirm
    end

    function ParadiseZ_AutoFarm_AutoFarmWindow:onButton(button)
        local AW2 = ParadiseZ_AutoFarm
        if not AW2 then self:removeFromUIManager() return end
        local mode = button and button.internal

        if mode == "close" then
            self:savePrefs()
            AW2.clearAutoFarmHighlight()
            self:removeFromUIManager()
            AW2.autoFarmWindow = nil
            return
        end
        if mode == "removePlots" then self:openJobConfirm("removePlots", "Remove all empty plots in this area?") return end
        if mode == "removeReceding" then self:openJobConfirm("removeReceding", "Remove all receding/dead plants in this area?") return end
        if mode == "removePlants" then self:openJobConfirm("removePlants", "Remove all seeded plants in this area?") return end
        if mode == "removeAll" then self:openJobConfirm("removeAll", "Remove all plots, receding plants, and plants in this area?") return end

        local toggles = {
            toggleHarvestAll = "includeHarvestAll",
            toggleHarvestSeed = "includeHarvestSeed",
            toggleReplantHarvested = "includeReplantHarvested",
            toggleMatchPattern = "includeMatchPattern",
            toggleClearReceding = "includeClearReceding",
            toggleDig = "includeDig",
            toggleTreat = "includeTreat",
            toggleWater = "includeWater"
        }
        if toggles[mode] then
            local field = toggles[mode]
            self[field] = not self[field]
            self:updateCheckboxLabels()
            self:savePrefs()

            return
        end

        if mode == "toggleFurrowHighlight" then
            self.showFurrowHighlight = not self.showFurrowHighlight
            self:updateCheckboxLabels()
            self:savePrefs()
            self:refreshHighlight()

            return
        end

        if mode == "cyclePattern" then
            local idx = 1
            for i, name in ipairs(AW2.furrowPatternNames) do if name == self.patternName then idx = i break end end
            idx = idx + 1
            if idx > #AW2.furrowPatternNames then idx = 1 end
            self.patternName = AW2.furrowPatternNames[idx]
            button:setTitle("Pattern: " .. tostring(self.patternName))
            self:savePrefs()
            self:refreshHighlight()
            return
        end

        if not self.collector then  return end

        AW2.currentFurrowPattern = self:getSelectedPattern()
        AW2.pendingChainCarry = nil
        AW2.pendingTendPlan = nil
        self:savePrefs()

        if mode == "tend" then
            AW2.pendingTendPlan = self:prefs()
        else
            AW2.pendingMatchPattern = false
            AW2.pendingReplantActive = false
        end


        AW2.start(self.playerNum or 0, self.collector, mode)
    end

    function AW.openAutoFarmUI(playerNum, collector)
        if AW.autoFarmWindow then pcall(function() AW.autoFarmWindow:removeFromUIManager() end) AW.autoFarmWindow = nil end
        AW.clearAutoFarmHighlight()
        local w, h, x, y = 460, 332, 200, 140
        if getCore then
            local core = getCore()
            if core then x = math.floor((core:getScreenWidth() - w) / 2); y = math.floor((core:getScreenHeight() - h) / 2) end
        end
        local win = ParadiseZ_AutoFarm_AutoFarmWindow:new(x, y, w, h, playerNum or 0, collector)
        win:initialise(); win:addToUIManager(); win:setVisible(true); win:bringToTop()
        AW.autoFarmWindow = win

    end

    function AW.onContext(playerNum, context, worldobjects, test)
        if test then return end
        local collector = AW.findCollectorFromWorldObjects(worldobjects)
        if not collector then return end
        context:addOption("Auto-Farm", AW, function() AW.openAutoFarmUI(playerNum, collector) end)
    end


end

do
    local AW = ParadiseZ_AutoFarm
    if not AW then
        return
    end

    pcall(require, "Farming/TimedActions/ISSeedAction")
    pcall(require, "Farming/TimedActions/ISPlowAction")

    AW.VERSION = "ParadiseZ_AutoFarm"
    AW.WATER_SOURCE_RADIUS = 15
    AW.INTERRUPT_CANCEL_MS = 1200
    AW.activeJobToken = AW.activeJobToken or 0
    AW.cancelInProgress = false

    local function safeObjKey(obj)
        if not obj then return "nil" end
        if AW.objKey then
            local ok, value = pcall(function() return AW.objKey(obj) end)
            if ok and value then return tostring(value) end
        end
        local x, y, z = "?", "?", "?"
        pcall(function() x = math.floor(AW.num(obj:getX(), 0)) end)
        pcall(function() y = math.floor(AW.num(obj:getY(), 0)) end)
        pcall(function() z = math.floor(AW.num(obj:getZ(), 0)) end)
        return tostring(x) .. "," .. tostring(y) .. "," .. tostring(z)
    end

    function AW.sameFarm(a, b)
        return a ~= nil and b ~= nil and safeObjKey(a) == safeObjKey(b)
    end

    function AW.bumpJobToken(reason)
        AW.activeJobToken = (AW.activeJobToken or 0) + 1

        return AW.activeJobToken
    end

    function AW.currentJobToken()
        return AW.activeJobToken or 0
    end

    function AW.isTokenCurrent(token)
        return token ~= nil and token == AW.currentJobToken()
    end

    function AW.clearPlayerQueue(playerObj)
        playerObj = playerObj or getPlayer()
        if ISTimedActionQueue and playerObj then
            pcall(function() ISTimedActionQueue.clear(playerObj) end)
        end
    end

    function AW.cancel(reason)
        AW.cancelInProgress = true
        AW.bumpJobToken(reason or "cancel")

        if AW.job then
            AW.job.active = false
            AW.job.cancelled = true
            AW.job.pending = {}
            AW.job.chainQueue = {}
        end

        AW.job = nil
        AW.pendingChainCarry = nil
        AW.pendingTendPlan = nil
        AW.pendingMatchPattern = false
        AW.pendingReplantActive = false
        AW.pendingReplantRecords = {}
        AW.pendingReplantSeen = {}

        AW.clearPlayerQueue(getPlayer())
        AW.touch("cancelled")

        AW.cancelInProgress = false
    end

    function AW.sayNeedOnce(playerObj, key, text)
        if not playerObj or not text then return end
        if AW.job then
            AW.job.needSaid = AW.job.needSaid or {}
            if AW.job.needSaid[key] then

                return
            end
            AW.job.needSaid[key] = true
        end
        playerObj:Say(text)

    end

    function AW.modePrettyName(mode)
        if mode == "harvestSeed" then return "seed-bearing crops" end
        if mode == "harvest" then return "harvestable crops" end
        if mode == "replantHarvested" then return "harvested crops to replant" end
        if mode == "removeOffPattern" then return "off-pattern crops and plots" end
        if mode == "removeReceding" then return "receding plants" end
        if mode == "removePlants" then return "planted crops" end
        if mode == "removePlots" then return "empty furrows" end
        if mode == "digFurrows" then return "furrow locations" end
        if mode == "treat" then return "crops to treat" end
        if mode == "water" then return "crops to water" end
        return tostring(mode or "work")
    end

    function AW.checkingText(mode)
        return "Checking for " .. AW.modePrettyName(mode) .. "..."
    end

    function AW.noneFoundText(mode)
        if mode == "harvestSeed" then return "No seed-bearing crops are ready." end
        if mode == "harvest" then return "No crops are ready to harvest." end
        if mode == "replantHarvested" then return "No harvested crops need replanting." end
        if mode == "removeOffPattern" then return "The farm already matches this pattern." end
        if mode == "removeReceding" then return "No receding plants need clearing." end
        if mode == "removePlants" then return "No planted crops need removing." end
        if mode == "removePlots" then return "No empty furrows need removing." end
        if mode == "digFurrows" then return "No open soil is ready for furrows." end
        if mode == "treat" then return "No crop diseases need treating." end
        if mode == "water" then return "No crops need water." end
        return "Nothing needs attention here."
    end

    function AW.foundText(mode, count)
        count = tonumber(count) or 0
        if mode == "harvestSeed" then return "Found " .. count .. " seed-bearing crop" .. (count == 1 and "." or "s.") end
        if mode == "harvest" then return "Found " .. count .. " harvestable crop" .. (count == 1 and "." or "s.") end
        if mode == "replantHarvested" then return "Found " .. count .. " harvested crop" .. (count == 1 and " to replant." or "s to replant.") end
        if mode == "removeOffPattern" then return "Found " .. count .. " off-pattern farm object" .. (count == 1 and " to clear." or "s to clear.") end
        if mode == "removeReceding" then return "Found " .. count .. " receding plant" .. (count == 1 and " to clear." or "s to clear.") end
        if mode == "removePlants" then return "Found " .. count .. " planted crop" .. (count == 1 and " to remove." or "s to remove.") end
        if mode == "removePlots" then return "Found " .. count .. " empty furrow" .. (count == 1 and " to remove." or "s to remove.") end
        if mode == "digFurrows" then return "Found " .. count .. " furrow location" .. (count == 1 and "." or "s.") end
        if mode == "treat" then return "Checked crops for disease." end
        if mode == "water" then return "Found " .. count .. " crop" .. (count == 1 and " to water." or "s to water.") end
        return "Found " .. count .. " task" .. (count == 1 and "." or "s.")
    end

    function AW.sprayNeedText(diseaseType)
        if diseaseType == "mildew" then return "I need Mildew Spray for that." end
        if diseaseType == "flies" then return "I need Insecticide for that." end
        return "I need the right treatment for that."
    end

    function AW.sourceNeedMessage(playerObj)
        local sourceCount = AW.job and AW.job.sources and #AW.job.sources or 0
        local sourceWater = AW.totalSourceWater and AW.totalSourceWater() or 0
        if sourceCount <= 0 then
            AW.sayNeedOnce(playerObj, "no-water-sources", "There are no water sources available.")
            return
        end
        if sourceWater <= 0 then
            AW.sayNeedOnce(playerObj, "water-sources-empty", "All available water sources are empty.")
            return
        end
        AW.sayNeedOnce(playerObj, "cannot-use-water-source", "I can't use the available water source.")
    end

    function AW.canNeedMessage(playerObj)
        local cans = AW.getWateringCans(playerObj)
        if #cans <= 0 then
            AW.sayNeedOnce(playerObj, "no-watering-can", "I don't have a watering can.")
            return
        end
        if not AW.hasFillableCan(playerObj) then
            AW.sayNeedOnce(playerObj, "no-fillable-watering-can", "I don't have a watering can I can fill.")
            return
        end
        AW.sayNeedOnce(playerObj, "no-usable-watering-can-water", "My watering cans are empty.")
    end

    function AW.normalizeHarvestPrefs(plan, changedField)
        plan = plan or {}
        if changedField == "includeHarvestAll" and plan.includeHarvestAll == true then
            plan.includeHarvestSeed = false
        elseif changedField == "includeHarvestSeed" and plan.includeHarvestSeed == true then
            plan.includeHarvestAll = false
        elseif plan.includeHarvestAll == true and plan.includeHarvestSeed == true then
            plan.includeHarvestSeed = false
        end
        return plan
    end

    function AW.normalizeTendPlan(plan)
        return AW.normalizeHarvestPrefs(AW.copyUIPrefs and AW.copyUIPrefs(plan or AW.defaultUIPrefs()) or (plan or {}))
    end

    local _saveUIPrefs_AutoFarm = AW.saveUIPrefs
    function AW.saveUIPrefs(playerNum, collector, prefs)
        return _saveUIPrefs_AutoFarm(playerNum, collector, AW.normalizeTendPlan(prefs))
    end

    local _removeModeMatchesPlant_AutoFarm = AW.removeModeMatchesPlant
    function AW.removeModeMatchesPlant(mode, plant)
        if mode == "removeOffPattern" then return plant ~= nil end
        return _removeModeMatchesPlant_AutoFarm(mode, plant)
    end

    local _removeModeLabel_AutoFarm = AW.removeModeLabel
    function AW.removeModeLabel(mode)
        if mode == "removeOffPattern" then return "off-pattern farm objects" end
        return _removeModeLabel_AutoFarm(mode)
    end

    function AW.buildTendChain(plan)
        plan = AW.normalizeTendPlan(plan or {})
        local chain = {}

        if plan.includeHarvestAll == true then
            table.insert(chain, { mode = "harvest" })
        elseif plan.includeHarvestSeed == true then
            table.insert(chain, { mode = "harvestSeed" })
        end

        if plan.includeReplantHarvested == true then
            table.insert(chain, { mode = "replantHarvested" })
        end

        if plan.includeMatchPattern == true then
            table.insert(chain, { mode = "removeOffPattern", pattern = AW.currentFurrowPattern })
        end

        if plan.includeClearReceding == true then
            table.insert(chain, { mode = "removeReceding" })
        end

        if plan.includeDig == true then
            table.insert(chain, { mode = "digFurrows", pattern = AW.currentFurrowPattern })
        end

        if plan.includeTreat ~= false then
            table.insert(chain, { mode = "treat" })
        end

        if plan.includeWater ~= false then
            table.insert(chain, { mode = "water" })
        end

        return chain
    end

    if ParadiseZ_AutoFarm_NextAction then
        function ParadiseZ_AutoFarm_NextAction:isValid()
            return ParadiseZ_AutoFarm and ParadiseZ_AutoFarm.isTokenCurrent and ParadiseZ_AutoFarm.isTokenCurrent(self.token)
        end
        local _nextNew_AutoFarm = ParadiseZ_AutoFarm_NextAction.new
        function ParadiseZ_AutoFarm_NextAction:new(character, time)
            local o = _nextNew_AutoFarm(self, character, time)
            o.token = ParadiseZ_AutoFarm and ParadiseZ_AutoFarm.currentJobToken and ParadiseZ_AutoFarm.currentJobToken() or 0
            return o
        end
        function ParadiseZ_AutoFarm_NextAction:perform()
            local AW2 = ParadiseZ_AutoFarm
            ISBaseTimedAction.perform(self)
            if not AW2 or not AW2.isTokenCurrent(self.token) then
                if AW2 then  end
                return
            end
            if AW2.step then AW2.touch("next-action"); AW2.step() end
        end
    end

    if ParadiseZ_AutoFarm_PostWaterAction then
        local _postWaterNew_AutoFarm = ParadiseZ_AutoFarm_PostWaterAction.new
        function ParadiseZ_AutoFarm_PostWaterAction:new(character, crop, uses, targetCap)
            local o = _postWaterNew_AutoFarm(self, character, crop, uses, targetCap)
            o.token = ParadiseZ_AutoFarm and ParadiseZ_AutoFarm.currentJobToken and ParadiseZ_AutoFarm.currentJobToken() or 0
            return o
        end
        function ParadiseZ_AutoFarm_PostWaterAction:isValid()
            return ParadiseZ_AutoFarm and ParadiseZ_AutoFarm.isTokenCurrent and ParadiseZ_AutoFarm.isTokenCurrent(self.token)
        end
    end

    if ParadiseZ_AutoFarm_IndexAction then
        local _indexNew_AutoFarm = ParadiseZ_AutoFarm_IndexAction.new
        local _indexPerform_AutoFarm = ParadiseZ_AutoFarm_IndexAction.perform
        function ParadiseZ_AutoFarm_IndexAction:new(character, collector, mode, playerNum)
            local o = _indexNew_AutoFarm(self, character, collector, mode, playerNum)
            o.token = AW.currentJobToken()
            o.completed = false
            return o
        end
        function ParadiseZ_AutoFarm_IndexAction:isValid()
            return self.character ~= nil and self.collector ~= nil and self.mode ~= nil and AW.isTokenCurrent(self.token)
        end
        function ParadiseZ_AutoFarm_IndexAction:perform()
            if not AW.isTokenCurrent(self.token) then

                self.completed = true
                ISBaseTimedAction.perform(self)
                return
            end
            self.completed = true
            return _indexPerform_AutoFarm(self)
        end
        function ParadiseZ_AutoFarm_IndexAction:stop()
            if not self.completed and AW.isTokenCurrent(self.token) and not AW.cancelInProgress then

                AW.cancel("row staged index interrupted")
            end
            ISBaseTimedAction.stop(self)
        end
    end

    if ParadiseZ_AutoFarm_TargetIndexAction then
        function ParadiseZ_AutoFarm_TargetIndexAction:isValid()
            return self.character ~= nil and self.collector ~= nil and self.mode ~= nil and AW.isTokenCurrent(self.token)
        end

        function ParadiseZ_AutoFarm_TargetIndexAction:new(character, collector, mode, playerNum)
            local o = {}
            setmetatable(o, self)
            self.__index = self
            o.character = character
            o.collector = collector
            o.mode = mode
            o.playerNum = playerNum or 0
            o.maxTime = AW.INDEX_TOTAL_TIME or 90
            o.stopOnWalk = true
            o.stopOnRun = true
            o.stopOnAim = true
            o.prepared = false
            o.matchPattern = AW.pendingMatchPattern == true or mode == "removeOffPattern"
            o.patternName = AW.currentFurrowPattern
            o.token = AW.currentJobToken()
            o.completed = false
            return o
        end

        function ParadiseZ_AutoFarm_TargetIndexAction:addRemoveTarget(x, y)
            local plant = AW.plantAt(x, y, self.cz)
            if not plant then return end

            if self.mode == "removeOffPattern" then
                if AW.coordMatchesPattern(self.patternSet, x, y, self.cz) then return end
                local key = tostring(x) .. "," .. tostring(y) .. "," .. tostring(self.cz)
                table.insert(self.targets, {
                    x = x, y = y, z = self.cz, key = key,
                    seed = tostring(plant.typeOfSeed or "none"),
                    state = tostring(plant.state or "unknown"),
                    offPattern = true
                })

                return
            end

            if not AW.coordMatchesPattern(self.patternSet, x, y, self.cz) then return end
            if AW.removeModeMatchesPlant(self.mode, plant) then
                local key = tostring(x) .. "," .. tostring(y) .. "," .. tostring(self.cz)
                table.insert(self.targets, { x = x, y = y, z = self.cz, key = key, seed = tostring(plant.typeOfSeed or "none"), state = tostring(plant.state or "unknown") })

            end
        end

        function ParadiseZ_AutoFarm_TargetIndexAction:processRow(row)
            if self.mode == "digFurrows" then
                for _, point in ipairs(row.points or {}) do self:addDigTarget(point) end
                return
            end
            for x = self.cx - AW.CROP_RADIUS, self.cx + AW.CROP_RADIUS do
                if self.mode == "harvest" or self.mode == "harvestSeed" then
                    self:addHarvestTarget(x, row.y)
                elseif self.mode == "removePlots" or self.mode == "removeReceding" or self.mode == "removePlants" or self.mode == "removeOffPattern" then
                    self:addRemoveTarget(x, row.y)
                end
            end
        end

        function ParadiseZ_AutoFarm_TargetIndexAction:stop()
            if not self.completed and AW.isTokenCurrent(self.token) and not AW.cancelInProgress then

                AW.cancel("target row index interrupted")
            end
            ISBaseTimedAction.stop(self)
        end

        function ParadiseZ_AutoFarm_TargetIndexAction:perform()
            if not AW.isTokenCurrent(self.token) then

                self.completed = true
                ISBaseTimedAction.perform(self)
                return
            end
            while self.rowIndex <= #self.rows do self:processSome() end

            local playerObj = self.character
            local targets = AW.routeGreedy(self.targets, playerObj)
            local carry = (AW.job and AW.job.chainQueue) or AW.pendingChainCarry
            AW.pendingChainCarry = nil
            local mode = self.mode
            self.completed = true

            if #targets <= 0 then
                if AW.job then AW.job.active = false end
                playerObj:Say(AW.noneFoundText(mode))

                ISBaseTimedAction.perform(self)
                AW.continueChainOrFinish(playerObj, self.playerNum or 0, self.collector, carry, mode)
                return
            end

            local job = {
                token = self.token,
                active = true,
                mode = mode,
                playerNum = self.playerNum or 0,
                center = self.collector,
                sources = {},
                pending = targets,
                treatAttempts = {},
                devilWatering = {},
                localWater = {},
                preferredWaterCan = nil,
                watchdogRetries = 0,
                lastQueuedKind = nil,
                lastQueuedCropKey = nil,
                chainQueue = carry or {},
                needSaid = {}
            }

            if mode == "harvest" or mode == "harvestSeed" then
                job.queuedHarvestKeys = {}
                job.collectReplant = AW.pendingReplantActive == true
            elseif mode == "removePlots" or mode == "removeReceding" or mode == "removePlants" or mode == "removeOffPattern" then
                job.queuedRemoveKeys = {}
                job.patternSet = self.patternSet
            elseif mode == "digFurrows" then
                job.mode = "digFurrows"
                job.queuedDigKeys = {}
            end

            AW.job = job
            playerObj:Say(AW.foundText(mode, #targets))

            ISBaseTimedAction.perform(self)
            AW.touch("target-row-index-complete")
            AW.step()
        end
    end

    function AW.nextTreatment(playerObj, plant, crop)
        local disease = AW.diseaseInfo(plant)
        if disease.devil and disease.devil > 0 then

        end
        if disease.mildew and disease.mildew > 0 then
            local item = AW.findTreatmentItem(playerObj, "mildew")
            if item then return "mildew", disease.mildewField, disease.mildew, item end

            AW.sayNeedOnce(playerObj, "need-mildew-spray", "I need Mildew Spray for that.")
        end
        if disease.flies and disease.flies > 0 then
            local item = AW.findTreatmentItem(playerObj, "flies")
            if item then return "flies", disease.fliesField, disease.flies, item end

            AW.sayNeedOnce(playerObj, "need-insecticide", "I need Insecticide for that.")
        end
        return nil
    end

    local _queueTreatment_AutoFarm = AW.queueTreatment
    function AW.queueTreatment(playerObj, crop, diseaseType, field, value, item)
        if not item then

            AW.sayNeedOnce(playerObj, "need-" .. tostring(diseaseType), AW.sprayNeedText(diseaseType))
            if AW.job and AW.job.pending then table.remove(AW.job.pending, 1) end
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
            return true
        end
        if AW.isDrainable(item) and AW.itemUses(item) <= 0 then

            AW.sayNeedOnce(playerObj, "empty-" .. tostring(diseaseType), AW.sprayNeedText(diseaseType))
            if AW.job and AW.job.pending then table.remove(AW.job.pending, 1) end
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
            return true
        end
        local ok = _queueTreatment_AutoFarm(playerObj, crop, diseaseType, field, value, item)
        if ok == false then
            AW.sayNeedOnce(playerObj, "treatment-failed-" .. tostring(diseaseType), "I couldn't treat that crop.")
        end
        return ok
    end

    function AW.queueRefillAll(playerObj, reason)
        if not AW.job then return false end
        AW.job.preferredWaterCan = nil
        local source = AW.bestSource(playerObj)
        if not source then

            AW.sourceNeedMessage(playerObj)
            return false
        end
        local cans = AW.getFillableCans(playerObj)

        if #cans <= 0 then AW.canNeedMessage(playerObj); return false end
        local square = AW.sourceSquare(source)
        if not square then AW.sayNeedOnce(playerObj, "source-no-square", "I can't reach that water source."); return false end
        if not AW.queueWalkAdj(playerObj, square) then AW.sayNeedOnce(playerObj, "source-unreachable", "I can't reach that water source."); return false end

        local budget, queued = AW.sourceWater(source), 0
        for _, can in ipairs(cans) do
            if budget <= 0 then break end
            local planned
            if AW.isEmptyCan(can) then planned = AW.DEFAULT_EMPTY_CAN_MAX_USES else planned = math.max(0, AW.canMaxUses(can) - AW.canUses(can)) end
            planned = math.min(planned, budget)
            if planned > 0 then
                AW.queueTransferIfNeeded(playerObj, can)
                ISTimedActionQueue.add(ParadiseZ_AutoFarm_FillCanAction:new(playerObj, can, source, math.max(AW.MIN_ACTION_TIME, planned * AW.REFILL_TIME_PER_USE)))
                queued = queued + 1
                if budget < 999999 then budget = budget - planned end

            end
        end
        if queued <= 0 then AW.sourceNeedMessage(playerObj); return false end
        ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, 1))
        AW.job.lastQueuedKind = "refill"
        AW.job.lastQueuedCropKey = nil
        AW.job.watchdogRetries = 0
        AW.touch("queued-refill")
        return true
    end

    function AW.queueWater(playerObj, crop, plant)
        local needs, neededWater, current, target, skipAt, seed, sensitive, devil = AW.cropPlan(plant, crop.key)
        crop.seed = seed
        if not needs then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
            return true
        end
        local cans = AW.getWateringCans(playerObj)
        if #cans <= 0 then
            AW.sayNeedOnce(playerObj, "no-watering-can", "I don't have a watering can.")
            AW.cancel("missing watering can")
            return false
        end
        local can, available = AW.findPreferredCan(playerObj)
        local sourceWater = AW.totalSourceWater()
        if not can or available <= AW.CAN_RESERVE_USES then

            if sourceWater > 0 and AW.hasFillableCan(playerObj) then return AW.queueRefillAll(playerObj, "no usable can water") end
            if sourceWater <= 0 then AW.sourceNeedMessage(playerObj) else AW.canNeedMessage(playerObj) end
            AW.cancel("out of usable water")
            return false
        end
        local square = getCell():getGridSquare(crop.x, crop.y, crop.z)
        if not square then table.remove(AW.job.pending, 1); ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj)); return true end
        local safeAvailable = math.max(0, available - AW.CAN_RESERVE_USES)
        local actionUses = AW.waterUsesForPlan(current, target, sensitive, devil, safeAvailable)
        if actionUses <= 0 then table.remove(AW.job.pending, 1); ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj)); return true end

        if not AW.queueVanillaWater(playerObj, crop, square, can, actionUses, target) then
            AW.sayNeedOnce(playerObj, "water-action-failed", "I couldn't water that crop.")
            return false
        end
        AW.job.lastQueuedKind = "water"
        AW.job.lastQueuedCropKey = crop.key
        AW.job.watchdogRetries = 0
        AW.touch("queued-water")
        return true
    end

    function AW.seedDisplayName(seed)
        local s = tostring(seed or "")
        s = string.gsub(s, " plant$", "")
        if s == "" or s == "nil" or s == "none" then return "those" end
        return s
    end

    function AW.skipRemainingReplantSeed(seed)
        if not AW.job or not AW.job.pending then return 0 end
        local kept, removed = {}, 0
        for _, entry in ipairs(AW.job.pending) do
            if tostring(entry.seed) == tostring(seed) then removed = removed + 1 else table.insert(kept, entry) end
        end
        AW.job.pending = kept
        return removed
    end

    function AW.scanReplantHarvested(centerObj)
        local records = AW.pendingReplantRecords or {}
        local targets = {}
        local seen = {}
        local patternSet = AW.pendingMatchPattern and AW.patternKeySet(centerObj, AW.currentFurrowPattern) or nil
        for _, rec in ipairs(records) do
            if rec and not seen[rec.key] and AW.coordMatchesPattern(patternSet, rec.x, rec.y, rec.z) then
                seen[rec.key] = true
                local plant = AW.plantAt(rec.x, rec.y, rec.z)
                if not plant or AW.isEmptyPlot(plant) then
                    table.insert(targets, { x = rec.x, y = rec.y, z = rec.z, key = rec.key, seed = rec.seed })

                else

                end
            end
        end

        return AW.routeGreedy(targets, AW.player(0) or getPlayer())
    end

    function AW.queueReplantDig(playerObj, crop)
        local square = getCell():getGridSquare(crop.x, crop.y, crop.z)
        if not square then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
            return true
        end
        local okSquare, reason = AW.isFurrowAcceptableSquare(square)
        if not okSquare then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
            return true
        end
        local tool = AW.findDigTool(playerObj)
        local usingHands = false
        if not tool then
            if not AW.handsCanDig(playerObj) then
                AW.sayNeedOnce(playerObj, "replant-no-dig-tool", "I need a shovel, trowel, or uninjured hands to replant that.")
                table.remove(AW.job.pending, 1)
                ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
                return true
            end
            usingHands = true
        end
        AW.queueDigToolEquip(playerObj, tool)
        if not AW.queueWalkAdj(playerObj, square) then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
            return true
        end
        local ok, action = pcall(function() return ISPlowAction:new(playerObj, square, tool, AW.FURROW_TIME) end)
        if not ok or not action then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
            return true
        end
        AW.job.replantDigQueuedKeys = AW.job.replantDigQueuedKeys or {}
        AW.job.replantDigQueuedKeys[crop.key] = true
        AW.job.lastQueuedKind = "replant-dig"
        AW.job.lastQueuedCropKey = crop.key
        AW.job.watchdogRetries = 0

        ISTimedActionQueue.add(action)
        ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
        AW.touch("queued-replant-dig")
        return true
    end

    function AW.queueReplant(playerObj, crop, plant)
        local square = getCell():getGridSquare(crop.x, crop.y, crop.z)
        if AW.job and crop then
            AW.job.lastActionTargetX = crop.x
            AW.job.lastActionTargetY = crop.y
            AW.job.lastActionTargetZ = crop.z
        end
        if not square then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
            return true
        end
        if plant and not AW.isEmptyPlot(plant) then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
            return true
        end
        if not plant then
            return AW.queueReplantDig(playerObj, crop)
        end

        local seeds, count, props = AW.getSeedItems(playerObj, crop.seed)
        if not seeds or not props then
            local removed = AW.skipRemainingReplantSeed(crop.seed)
            AW.sayNeedOnce(playerObj, "no-seeds-" .. tostring(crop.seed), "No " .. AW.seedDisplayName(crop.seed) .. " seeds.")

            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
            return true
        end
        if not AW.queueWalkAdj(playerObj, square) then

            table.remove(AW.job.pending, 1)
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
            return true
        end

        AW.job.queuedReplantKeys = AW.job.queuedReplantKeys or {}
        AW.job.queuedReplantKeys[crop.key] = true
        ISTimedActionQueue.add(ISSeedAction:new(playerObj, seeds, props.seedsRequired, crop.seed, plant, 40))
        ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
        AW.job.lastQueuedKind = "replant"
        AW.job.lastQueuedCropKey = crop.key
        AW.job.watchdogRetries = 0
        AW.touch("queued-replant")
        return true
    end

    local _step_AutoFarm = AW.step
    function AW.step()
        local job = AW.job
        if not job or not job.active then return end
        if job.token == nil then job.token = AW.currentJobToken() end
        if not AW.isTokenCurrent(job.token) then return end

        if job.mode == "replantHarvested" then
            AW.touch("step")
            local playerObj = AW.player(job.playerNum)
            if not playerObj then AW.cancel("player missing") return end
            if playerObj:isDead() then AW.cancel("player dead") return end
            while #job.pending > 0 do
                local crop = job.pending[1]
                local plant = AW.plantAt(crop.x, crop.y, crop.z)
                if job.queuedReplantKeys and job.queuedReplantKeys[crop.key] then

                    table.remove(job.pending, 1)
                    job.watchdogRetries = 0
                elseif not plant then
                    if job.replantDigQueuedKeys and job.replantDigQueuedKeys[crop.key] then
                        job.replantWaits = job.replantWaits or {}
                        job.replantWaits[crop.key] = (job.replantWaits[crop.key] or 0) + 1
                        if job.replantWaits[crop.key] <= 5 then

                            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
                            AW.touch("replant-wait-furrow")
                            return true
                        end

                        table.remove(job.pending, 1)
                    else
                        return AW.queueReplantDig(playerObj, crop)
                    end
                elseif not AW.isEmptyPlot(plant) then

                    table.remove(job.pending, 1)
                    job.watchdogRetries = 0
                else
                    return AW.queueReplant(playerObj, crop, plant)
                end
            end

            job.active = false
            if job.chainQueue and #job.chainQueue > 0 and job.center then
                local nextJob = table.remove(job.chainQueue, 1)
                local remaining = job.chainQueue

                AW.pendingChainCarry = remaining
                if nextJob.pattern then AW.currentFurrowPattern = nextJob.pattern end
                AW.start(job.playerNum or 0, job.center, nextJob.mode)
            end
            return
        end

        if job.mode == "removeOffPattern" then
            AW.touch("step")
            local playerObj = AW.player(job.playerNum)
            if not playerObj then AW.cancel("player missing") return end
            if playerObj:isDead() then AW.cancel("player dead") return end
            while #job.pending > 0 do
                local crop = job.pending[1]
                local plant = AW.plantAt(crop.x, crop.y, crop.z)
                if job.queuedRemoveKeys and job.queuedRemoveKeys[crop.key] then

                    table.remove(job.pending, 1)
                    job.watchdogRetries = 0
                elseif not plant then

                    table.remove(job.pending, 1)
                    job.watchdogRetries = 0
                elseif AW.coordMatchesPattern(job.patternSet, crop.x, crop.y, crop.z) then

                    table.remove(job.pending, 1)
                    job.watchdogRetries = 0
                else
                    return AW.queueRemovePlant(playerObj, crop, plant)
                end
            end

            job.active = false
            if job.chainQueue and #job.chainQueue > 0 and job.center then
                local nextJob = table.remove(job.chainQueue, 1)
                local remaining = job.chainQueue

                AW.pendingChainCarry = remaining
                if nextJob.pattern then AW.currentFurrowPattern = nextJob.pattern end
                AW.start(job.playerNum or 0, job.center, nextJob.mode)
            end
            return
        end

        return _step_AutoFarm()
    end

    function AW.start(playerNum, collector, mode)
        mode = mode or "tend"
        local playerObj = AW.player(playerNum)
        if not playerObj then  return end
        if not AW.isWaterCollector(collector) then  return end

        local isChainStart = (AW.pendingChainCarry ~= nil and mode ~= "tend" and mode ~= "removeAll")

        if mode == "tend" then
            local plan = AW.normalizeTendPlan(AW.pendingTendPlan or AW.defaultUIPrefs())
            AW.pendingTendPlan = nil

            AW.cancel("starting Tend")
            AW.pendingReplantRecords = {}
            AW.pendingReplantSeen = {}
            AW.pendingReplantActive = plan.includeReplantHarvested == true
            AW.pendingMatchPattern = plan.includeMatchPattern == true

            local chain = AW.buildTendChain(plan)
            local first = table.remove(chain, 1)
            AW.pendingChainCarry = chain


            if first then AW.start(playerNum or 0, collector, first.mode) end
            return
        end

        if mode == "removeAll" then
            AW.cancel("starting Remove All")
            AW.pendingChainCarry = { { mode = "removeReceding" }, { mode = "removePlots" } }
            AW.pendingMatchPattern = false
            AW.pendingReplantActive = false

            playerObj:Say("Clearing the whole farm area...")
            AW.start(playerNum or 0, collector, "removePlants")
            return
        end

        if not isChainStart then
            AW.cancel("starting " .. tostring(mode))
            AW.pendingMatchPattern = false
            AW.pendingReplantActive = false
        end

        local carry = AW.pendingChainCarry

        if mode == "replantHarvested" then
            AW.pendingChainCarry = nil
            playerObj:Say(AW.checkingText(mode))
            local targets = AW.scanReplantHarvested(collector)
            if #targets <= 0 then
                playerObj:Say(AW.noneFoundText(mode))

                AW.continueChainOrFinish(playerObj, playerNum, collector, carry, mode)
                return
            end
            AW.job = {
                token = AW.currentJobToken(),
                active = true, mode = "replantHarvested", playerNum = playerNum or 0, center = collector,
                sources = {}, pending = targets, treatAttempts = {}, devilWatering = {}, localWater = {}, preferredWaterCan = nil,
                watchdogRetries = 0, lastQueuedKind = nil, lastQueuedCropKey = nil, chainQueue = carry or {}, queuedReplantKeys = {},
                replantDigQueuedKeys = {}, replantWaits = {}, needSaid = {}
            }
            playerObj:Say(AW.foundText(mode, #targets))
            AW.step()
            return
        end

        if mode == "harvest" or mode == "harvestSeed" or mode == "removePlots" or mode == "removeReceding" or mode == "removePlants" or mode == "removeOffPattern" or mode == "digFurrows" then
            AW.pendingChainCarry = carry

            if mode == "removePlots" or mode == "removeReceding" or mode == "removePlants" or mode == "removeOffPattern" then
                if playerObj:getVehicle() then playerObj:Say("Exit the vehicle first."); return end
                local tool = AW.findRemoveTool(playerObj)
                if not tool then
                    playerObj:Say("I need a shovel or trowel for that.")

                    AW.pendingChainCarry = nil
                    AW.continueChainOrFinish(playerObj, playerNum, collector, carry, mode)
                    return
                end

            elseif mode == "digFurrows" then
                if playerObj:getVehicle() then playerObj:Say("Exit the vehicle first."); return end
                local tool = AW.findDigTool(playerObj)
                if not tool and not AW.handsCanDig(playerObj) then
                    playerObj:Say("I need a shovel, trowel, or uninjured hands to dig.")

                    AW.pendingChainCarry = nil
                    AW.continueChainOrFinish(playerObj, playerNum, collector, carry, mode)
                    return
                end

            else

            end

            AW.job = {
                token = AW.currentJobToken(), active = true, mode = mode, playerNum = playerNum or 0, center = collector,
                sources = {}, pending = {}, treatAttempts = {}, devilWatering = {}, localWater = {}, preferredWaterCan = nil,
                watchdogRetries = 0, lastQueuedKind = "target-index", lastQueuedCropKey = nil, chainQueue = carry or {}, needSaid = {}
            }
            AW.touch("queued-target-row-index")
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_TargetIndexAction:new(playerObj, collector, mode, playerNum or 0))
            playerObj:Say(AW.checkingText(mode))
            return
        end


        local cans = AW.getWateringCans(playerObj)

        for i, can in ipairs(cans) do  end

        if mode ~= "treat" and #cans <= 0 then
            playerObj:Say("I don't have a watering can.")
            AW.continueChainOrFinish(playerObj, playerNum, collector, carry, mode)
            return
        end

        AW.job = {
            token = AW.currentJobToken(), active = true, mode = mode, playerNum = playerNum or 0, center = collector,
            sources = {}, pending = {}, treatAttempts = {}, devilWatering = {}, localWater = {}, preferredWaterCan = nil,
            watchdogRetries = 0, lastQueuedKind = "index", lastQueuedCropKey = nil, chainQueue = carry or {}, needSaid = {}
        }
        AW.touch("queued-row-staged-index")
        ISTimedActionQueue.add(ParadiseZ_AutoFarm_IndexAction:new(playerObj, collector, mode, playerNum or 0))
        playerObj:Say(AW.checkingText(mode))
    end

    function AW.onPlayerUpdate(playerObj)
        if playerObj ~= getPlayer() then return end
        if not AW.job or not AW.job.active then return end
        if AW.job.token ~= nil and not AW.isTokenCurrent(AW.job.token) then return end

        local doing = AW.isDoingAction(playerObj)
        local msSince = AW.nowMs() - AW.lastStepMs
        local lastLabel = tostring(AW.lastStepLabel or "")

        if doing == false and AW.isQueuedJobLabel(lastLabel) and msSince >= AW.INTERRUPT_CANCEL_MS then

            AW.cancel("interrupted / timed-action queue cleared")
            return
        end

        if doing == false and msSince >= AW.WATCHDOG_STALL_MS then
            AW.job.watchdogRetries = (AW.job.watchdogRetries or 0) + 1

            if AW.job.watchdogRetries > 2 then AW.cancel("watchdog stall"); return end
            AW.step()
        end
    end

    AW.uiTooltips = {
        tend = "Runs the selected Tend Includes in order.",
        water = "Waters eligible crops and refills watering cans from nearby sources.",
        treat = "Treats mildew and pest flies using spray cans in inventory.",
        toggleHarvestAll = "Harvests every crop that is currently harvestable.",
        toggleHarvestSeed = "Harvests only seed-bearing crops.",
        toggleReplantHarvested = "After harvesting, digs missing furrows and replants the same crop when seeds are available.",
        toggleMatchPattern = "Makes this farm match the selected pattern by removing any off-pattern crops, plots, or receding plants before digging missing pattern spots.",
        toggleClearReceding = "Clears receding/dead plants that are still inside the selected pattern.",
        toggleDig = "Digs missing furrows in the selected pattern.",
        toggleTreat = "Includes disease treatment in Tend Crops.",
        toggleWater = "Includes watering in Tend Crops.",
        toggleFurrowHighlight = "Shows or hides the selected furrow-pattern preview.",
        removePlots = "Removes empty furrow plots in this farm area.",
        removeReceding = "Removes dead or receding plants in this farm area.",
        removePlants = "Removes planted crops in this farm area.",
        removeAll = "Removes plants, receding plants, and empty plots.",
        close = "Closes this Auto-Farm window."
    }

    function AW.setTooltip(control, text)
        if not control or not text then return end
        control.tooltip = text
        if control.setTooltip then pcall(function() control:setTooltip(text) end) end
    end

    function AW.applyTooltipsToWindow(win)
        if not win or not win.buttons then return end
        for mode, text in pairs(AW.uiTooltips) do AW.setTooltip(win.buttons[mode], text) end
        if win.patternCombo then AW.setTooltip(win.patternCombo, "Choose the furrow pattern used for matching, digging, and highlighting.") end
    end

    if ParadiseZ_AutoFarm_AutoFarmWindow then
        local _newWindow_AutoFarm = ParadiseZ_AutoFarm_AutoFarmWindow.new
        function ParadiseZ_AutoFarm_AutoFarmWindow:new(x, y, width, height, playerNum, collector)
            local o = _newWindow_AutoFarm(self, x, y, width, height, playerNum, collector)
            if o.includeHarvestAll == true and o.includeHarvestSeed == true then o.includeHarvestSeed = false end
            return o
        end

        local _addButton_AutoFarm = ParadiseZ_AutoFarm_AutoFarmWindow.addButton
        function ParadiseZ_AutoFarm_AutoFarmWindow:addButton(label, mode, x, y, w, h)
            local button = _addButton_AutoFarm(self, label, mode, x, y, w, h)
            AW.setTooltip(button, AW.uiTooltips[mode])
            return button
        end

        function ParadiseZ_AutoFarm_AutoFarmWindow:enforceHarvestExclusion(changedField)
            if changedField == "includeHarvestAll" then
                if self.includeHarvestAll == true then self.includeHarvestSeed = false end
                return
            end
            if changedField == "includeHarvestSeed" then
                if self.includeHarvestSeed == true then self.includeHarvestAll = false end
                return
            end
            if self.includeHarvestAll == true and self.includeHarvestSeed == true then self.includeHarvestSeed = false end
        end

        function ParadiseZ_AutoFarm_AutoFarmWindow:prefs()
            self:enforceHarvestExclusion()
            return {
                includeDig = self.includeDig == true,
                includeTreat = self.includeTreat == true,
                includeWater = self.includeWater == true,
                includeHarvestAll = self.includeHarvestAll == true,
                includeHarvestSeed = self.includeHarvestSeed == true,
                includeReplantHarvested = self.includeReplantHarvested == true,
                includeMatchPattern = self.includeMatchPattern == true,
                includeClearReceding = self.includeClearReceding == true,
                showFurrowHighlight = self.showFurrowHighlight == true,
                patternName = self:getSelectedPattern()
            }
        end

        function ParadiseZ_AutoFarm_AutoFarmWindow:onButton(button)
            local AW2 = ParadiseZ_AutoFarm
            if not AW2 then self:removeFromUIManager() return end
            local mode = button and button.internal

            if mode == "close" then
                self:savePrefs()
                AW2.clearAutoFarmHighlight()
                self:removeFromUIManager()
                AW2.autoFarmWindow = nil
                return
            end
            if mode == "removePlots" then self:openJobConfirm("removePlots", "Remove all empty plots in this area?") return end
            if mode == "removeReceding" then self:openJobConfirm("removeReceding", "Remove all receding/dead plants in this area?") return end
            if mode == "removePlants" then self:openJobConfirm("removePlants", "Remove all seeded plants in this area?") return end
            if mode == "removeAll" then self:openJobConfirm("removeAll", "Remove all plots, receding plants, and plants in this area?") return end

            if mode == "toggleHarvestAll" then
                self.includeHarvestAll = not self.includeHarvestAll
                self:enforceHarvestExclusion("includeHarvestAll")
                self:updateCheckboxLabels()
                self:savePrefs()

                return
            end
            if mode == "toggleHarvestSeed" then
                self.includeHarvestSeed = not self.includeHarvestSeed
                self:enforceHarvestExclusion("includeHarvestSeed")
                self:updateCheckboxLabels()
                self:savePrefs()

                return
            end

            local toggles = {
                toggleReplantHarvested = "includeReplantHarvested",
                toggleMatchPattern = "includeMatchPattern",
                toggleClearReceding = "includeClearReceding",
                toggleDig = "includeDig",
                toggleTreat = "includeTreat",
                toggleWater = "includeWater"
            }
            if toggles[mode] then
                local field = toggles[mode]
                self[field] = not self[field]
                self:updateCheckboxLabels()
                self:savePrefs()

                return
            end

            if mode == "toggleFurrowHighlight" then
                self.showFurrowHighlight = not self.showFurrowHighlight
                self:updateCheckboxLabels()
                self:savePrefs()
                self:refreshHighlight()

                return
            end

            if mode == "cyclePattern" then
                local idx = 1
                for i, name in ipairs(AW2.furrowPatternNames) do if name == self.patternName then idx = i break end end
                idx = idx + 1
                if idx > #AW2.furrowPatternNames then idx = 1 end
                self.patternName = AW2.furrowPatternNames[idx]
                button:setTitle("Pattern: " .. tostring(self.patternName))
                self:savePrefs()
                self:refreshHighlight()
                return
            end

            if not self.collector then  return end

            self:enforceHarvestExclusion()
            AW2.currentFurrowPattern = self:getSelectedPattern()
            AW2.pendingChainCarry = nil
            AW2.pendingTendPlan = nil
            self:savePrefs()

            if mode == "tend" then
                AW2.pendingTendPlan = self:prefs()
                AW2.cancel("Tend button pressed")
                AW2.pendingTendPlan = self:prefs()
            else
                AW2.pendingMatchPattern = false
                AW2.pendingReplantActive = false
            end


            AW2.start(self.playerNum or 0, self.collector, mode)
        end
    end

    local _openUI_AutoFarm = AW.openAutoFarmUI
    function AW.openAutoFarmUI(playerNum, collector)
        if AW.job and AW.job.active and not AW.sameFarm(AW.job.center, collector) then
            AW.cancel("opening different farm UI")
        end
        _openUI_AutoFarm(playerNum, collector)
        if AW.autoFarmWindow then
            if AW.autoFarmWindow.enforceHarvestExclusion then
                AW.autoFarmWindow:enforceHarvestExclusion()
                AW.autoFarmWindow:updateCheckboxLabels()
                AW.autoFarmWindow:savePrefs()
            end
            AW.applyTooltipsToWindow(AW.autoFarmWindow)
        end
    end

    if AW.autoFarmWindow then
        if AW.autoFarmWindow.enforceHarvestExclusion then
            AW.autoFarmWindow:enforceHarvestExclusion()
            AW.autoFarmWindow:updateCheckboxLabels()
            AW.autoFarmWindow:savePrefs()
        end
        AW.applyTooltipsToWindow(AW.autoFarmWindow)
    end
end

do
    local AW = ParadiseZ_AutoFarm
    if AW then
        AW.REPLANT_HARVEST_SETTLE_RETRIES = 10
        AW.REPLANT_FURROW_SETTLE_RETRIES = 10
        AW.REPLANT_SETTLE_TIME = 30

        local function _s(v) return tostring(v or "") end
        local function _lower(v) return string.lower(_s(v)) end
        local function _validSeedName(seed)
            local s = _lower(seed)
            return s ~= "" and s ~= "nil" and s ~= "none" and s ~= "no seed"
        end
        local function _normSeedText(s)
            s = _lower(s)
            s = string.gsub(s, " plant$", "")
            s = string.gsub(s, "^farming%.", "")
            s = string.gsub(s, "^base%.", "")
            s = string.gsub(s, "seeds", "seed")
            s = string.gsub(s, "[%s%._%-]", "")
            s = string.gsub(s, "ies$", "y")
            s = string.gsub(s, "s$", "")
            return s
        end

        function AW.seedDisplayName(seed)
            local s = _s(seed)
            s = string.gsub(s, " plant$", "")
            if s == "" or s == "nil" or s == "none" or s == "no seed" then return "those" end
            return s
        end

        function AW.replantSayNoSeeds(playerObj, seed)
            if AW.sayNeedOnce then
                AW.sayNeedOnce(playerObj, "no-seeds-" .. _s(seed), "No '" .. AW.seedDisplayName(seed) .. "' seeds.")
            elseif playerObj then
                playerObj:Say("No '" .. AW.seedDisplayName(seed) .. "' seeds.")
            end
        end

        function AW.findReplantRecord(key)
            for _, rec in ipairs(AW.pendingReplantRecords or {}) do
                if rec and rec.key == key then return rec end
            end
            return nil
        end

        function AW.recordReplantTarget(crop, plant, reason)
            if not crop then return nil end
            local seed = _s((plant and plant.typeOfSeed) or crop.seed or "")
            if not _validSeedName(seed) then return nil end
            AW.pendingReplantRecords = AW.pendingReplantRecords or {}
            AW.pendingReplantSeen = AW.pendingReplantSeen or {}
            local rec = AW.findReplantRecord(crop.key)
            if not rec then
                rec = { x = crop.x, y = crop.y, z = crop.z, key = crop.key, seed = seed, gainedSeedTypes = {}, gainedSeedCounts = {}, reason = reason or "harvest" }
                AW.pendingReplantSeen[crop.key] = true
                table.insert(AW.pendingReplantRecords, rec)
            else
                rec.seed = rec.seed or seed
            end
            return rec
        end

        function AW.itemFullTypeSafe(item)
            local full = nil
            pcall(function() full = item:getFullType() end)
            if full and full ~= "" then return tostring(full) end
            local module, typ = nil, nil
            pcall(function() module = item:getModule() end)
            pcall(function() typ = item:getType() end)
            if module and typ then return tostring(module) .. "." .. tostring(typ) end
            if typ then return tostring(typ) end
            return nil
        end

        function AW.itemDisplayNameSafe(item)
            local name = nil
            pcall(function() name = item:getDisplayName() end)
            return tostring(name or "")
        end

        function AW.isSeedLikeItem(item, cropSeed)
            if not item then return false end
            local full = _lower(AW.itemFullTypeSafe(item))
            local name = _lower(AW.itemDisplayNameSafe(item))
            local cropNorm = _normSeedText(cropSeed)
            if string.find(full, "seed", 1, true) or string.find(name, "seed", 1, true) then return true end
            if cropNorm ~= "" and string.find(_normSeedText(full), cropNorm, 1, true) then return true end
            return false
        end

        function AW.snapshotSeedLikeInventory(playerObj, cropSeed)
            local counts = {}
            local inv = playerObj and playerObj:getInventory()
            if not inv then return counts end
            local scannedContainers = {}
            local function scanContainer(container)
                if not container or scannedContainers[container] then return end
                scannedContainers[container] = true
                local items = nil
                pcall(function() items = container:getItems() end)
                if not items then return end
                for i = 0, items:size() - 1 do
                    local item = items:get(i)
                    if item then
                        local full = AW.itemFullTypeSafe(item)
                        if full and AW.isSeedLikeItem(item, cropSeed) then counts[full] = (counts[full] or 0) + 1 end
                        local sub = nil
                        pcall(function() if item.getInventory then sub = item:getInventory() end end)
                        if sub then scanContainer(sub) end
                    end
                end
            end
            scanContainer(inv)
            return counts
        end

        function AW.applyHarvestSeedGains(cropKey, before, playerObj)
            local rec = AW.findReplantRecord(cropKey)
            if not rec then return end
            local after = AW.snapshotSeedLikeInventory(playerObj, rec.seed)
            rec.gainedSeedTypes = rec.gainedSeedTypes or {}
            rec.gainedSeedCounts = rec.gainedSeedCounts or {}
            for full, afterCount in pairs(after) do
                local beforeCount = before and before[full] or 0
                local diff = (afterCount or 0) - (beforeCount or 0)
                if diff > 0 then
                    rec.gainedSeedCounts[full] = (rec.gainedSeedCounts[full] or 0) + diff
                    local already = false
                    for _, existing in ipairs(rec.gainedSeedTypes) do if existing == full then already = true break end end
                    if not already then table.insert(rec.gainedSeedTypes, full) end
                end
            end
        end

        ParadiseZ_AutoFarm_PostHarvestReplantAction = ISBaseTimedAction:derive("ParadiseZ_AutoFarm_PostHarvestReplantAction")
        function ParadiseZ_AutoFarm_PostHarvestReplantAction:isValid()
            return ParadiseZ_AutoFarm ~= nil and ParadiseZ_AutoFarm.isTokenCurrent ~= nil and ParadiseZ_AutoFarm.isTokenCurrent(self.token)
        end
        function ParadiseZ_AutoFarm_PostHarvestReplantAction:perform()
            local AW2 = ParadiseZ_AutoFarm
            if AW2 and AW2.isTokenCurrent and AW2.isTokenCurrent(self.token) then
                AW2.applyHarvestSeedGains(self.cropKey, self.beforeSeedCounts, self.character)
                if AW2.job then
                    AW2.job.queuedHarvestKeys = AW2.job.queuedHarvestKeys or {}
                    AW2.job.queuedHarvestKeys[self.cropKey] = true
                end
            end
            ISBaseTimedAction.perform(self)
        end
        function ParadiseZ_AutoFarm_PostHarvestReplantAction:new(character, crop, beforeSeedCounts, token)
            local o = {}
            setmetatable(o, self)
            self.__index = self
            o.character = character
            o.cropKey = crop and crop.key or "nil"
            o.beforeSeedCounts = beforeSeedCounts or {}
            o.token = token or (ParadiseZ_AutoFarm and ParadiseZ_AutoFarm.currentJobToken and ParadiseZ_AutoFarm.currentJobToken() or 0)
            o.maxTime = 1
            o.stopOnWalk = false
            o.stopOnRun = false
            o.stopOnAim = false
            return o
        end

        local _queueHarvest_AutoFarm = AW.queueHarvest
        function AW.queueHarvest(playerObj, crop, plant)
            if not (AW.job and AW.job.collectReplant and crop and plant) then
                return _queueHarvest_AutoFarm(playerObj, crop, plant)
            end
            local square = getCell():getGridSquare(crop.x, crop.y, crop.z)
            if AW.job and crop then
                AW.job.lastActionTargetX = crop.x
                AW.job.lastActionTargetY = crop.y
                AW.job.lastActionTargetZ = crop.z
            end
            if not square or not plant then
                table.remove(AW.job.pending, 1)
                ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
                return true
            end
            if not AW.canHarvestPlant(plant) then
                table.remove(AW.job.pending, 1)
                ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
                return true
            end
            AW.recordReplantTarget(crop, plant, "queued-harvest")
            local beforeSeeds = AW.snapshotSeedLikeInventory(playerObj, plant.typeOfSeed or crop.seed)
            if not AW.queueWalkAdj(playerObj, square) then
                table.remove(AW.job.pending, 1)
                ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj))
                return true
            end
            ISTimedActionQueue.add(ISHarvestPlantAction:new(playerObj, plant, 100))
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_PostHarvestReplantAction:new(playerObj, crop, beforeSeeds, AW.currentJobToken()))
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
            AW.job.lastQueuedKind = "harvest"
            AW.job.lastQueuedCropKey = crop.key
            AW.job.watchdogRetries = 0
            AW.touch("queued-harvest-replant-safe")
            return true
        end

        local _baseGetSeedItems_AutoFarm = AW.getSeedItems
        function AW.addUniqueSeedCandidate(list, fullType)
            if not fullType or fullType == "" then return end
            for _, existing in ipairs(list) do if existing == fullType then return end end
            table.insert(list, fullType)
        end

        function AW.findSeedLikeCandidates(playerObj, crop)
            local list = {}
            local seed = crop and crop.seed or nil
            local props = farming_vegetableconf and farming_vegetableconf.props and farming_vegetableconf.props[seed]
            if props and props.seedName then AW.addUniqueSeedCandidate(list, props.seedName) end
            local rec = crop and AW.findReplantRecord(crop.key)
            if rec and rec.gainedSeedTypes then
                for _, full in ipairs(rec.gainedSeedTypes) do AW.addUniqueSeedCandidate(list, full) end
            end
            if playerObj and playerObj:getInventory() then
                local snapshot = AW.snapshotSeedLikeInventory(playerObj, seed)
                local cropNorm = _normSeedText(seed)
                for full, count in pairs(snapshot) do
                    if count and count > 0 then
                        local fullNorm = _normSeedText(full)
                        if cropNorm ~= "" and string.find(fullNorm, cropNorm, 1, true) then AW.addUniqueSeedCandidate(list, full) end
                    end
                end
            end
            return list, props
        end

        function AW.getSeedItemsForCrop(playerObj, crop)
            if not playerObj or not crop then return nil, 0, nil end
            local seed = crop.seed
            local props = farming_vegetableconf and farming_vegetableconf.props and farming_vegetableconf.props[seed]
            local required = 1
            if props and props.seedsRequired then required = math.max(1, math.floor(AW.num(props.seedsRequired, 1))) end
            local candidates = AW.findSeedLikeCandidates(playerObj, crop)
            local inv = playerObj:getInventory()
            if not inv then return nil, 0, props end
            local bestCount = 0
            for _, fullType in ipairs(candidates or {}) do
                local count = AW.num(inv:getCountTypeRecurse(fullType), 0)
                if count > bestCount then bestCount = count end
                if count >= required then
                    local items = inv:getSomeTypeRecurse(fullType, required)
                    if items and items:size() >= required then
                        local seeds = {}
                        for i = 1, required do table.insert(seeds, items:get(i - 1)) end
                        local useProps = props or { seedName = fullType, seedsRequired = required }
                        return seeds, count, useProps
                    end
                end
            end
            return nil, bestCount, props
        end

        function AW.getSeedItems(playerObj, typeOfSeed, crop)
            if crop then return AW.getSeedItemsForCrop(playerObj, crop) end
            return _baseGetSeedItems_AutoFarm(playerObj, typeOfSeed)
        end

        function AW.scanReplantHarvested(centerObj)
            local records = AW.pendingReplantRecords or {}
            local targets = {}
            local seen = {}
            local patternSet = AW.pendingMatchPattern and AW.patternKeySet(centerObj, AW.currentFurrowPattern) or nil
            for _, rec in ipairs(records) do
                if rec and rec.key and not seen[rec.key] and AW.coordMatchesPattern(patternSet, rec.x, rec.y, rec.z) then
                    seen[rec.key] = true
                    table.insert(targets, { x = rec.x, y = rec.y, z = rec.z, key = rec.key, seed = rec.seed, gainedSeedTypes = rec.gainedSeedTypes })
                end
            end
            return AW.routeGreedy(targets, AW.player(0) or getPlayer())
        end

        function AW.skipRemainingReplantSeed(seed)
            if not AW.job or not AW.job.pending then return 0 end
            local kept, removed = {}, 0
            for _, entry in ipairs(AW.job.pending) do
                if _s(entry.seed) == _s(seed) then removed = removed + 1 else table.insert(kept, entry) end
            end
            AW.job.pending = kept
            return removed
        end

        function AW.queueReplant(playerObj, crop, plant)
            local square = getCell():getGridSquare(crop.x, crop.y, crop.z)
            if AW.job and crop then
                AW.job.lastActionTargetX = crop.x
                AW.job.lastActionTargetY = crop.y
                AW.job.lastActionTargetZ = crop.z
            end
            if not square then
                table.remove(AW.job.pending, 1)
                ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
                return true
            end
            if not plant then return AW.queueReplantDig(playerObj, crop) end
            if not AW.isEmptyPlot(plant) then
                table.remove(AW.job.pending, 1)
                ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
                return true
            end
            local seeds, count, props = AW.getSeedItemsForCrop(playerObj, crop)
            if not seeds or not props then
                AW.skipRemainingReplantSeed(crop.seed)
                AW.replantSayNoSeeds(playerObj, crop.seed)
                ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
                return true
            end
            if not AW.queueWalkAdj(playerObj, square) then
                table.remove(AW.job.pending, 1)
                ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
                return true
            end
            AW.job.queuedReplantKeys = AW.job.queuedReplantKeys or {}
            AW.job.queuedReplantKeys[crop.key] = true
            ISTimedActionQueue.add(ISSeedAction:new(playerObj, seeds, props.seedsRequired, crop.seed, plant, 40))
            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.RECHECK_TIME))
            AW.job.lastQueuedKind = "replant"
            AW.job.lastQueuedCropKey = crop.key
            AW.job.watchdogRetries = 0
            AW.touch("queued-replant")
            return true
        end

        local _step_AutoFarm_replant_fix = AW.step
        function AW.step()
            local job = AW.job
            if not job or not job.active then return end
            if job.token == nil then job.token = AW.currentJobToken() end
            if not AW.isTokenCurrent(job.token) then return end
            if job.mode ~= "replantHarvested" then return _step_AutoFarm_replant_fix() end
            AW.touch("step")
            local playerObj = AW.player(job.playerNum)
            if not playerObj then AW.cancel("player missing") return end
            if playerObj:isDead() then AW.cancel("player dead") return end
            while #job.pending > 0 do
                local crop = job.pending[1]
                local plant = AW.plantAt(crop.x, crop.y, crop.z)
                if job.queuedReplantKeys and job.queuedReplantKeys[crop.key] then
                    table.remove(job.pending, 1)
                    job.watchdogRetries = 0
                elseif plant and not AW.isEmptyPlot(plant) then
                    job.replantHarvestSettleWaits = job.replantHarvestSettleWaits or {}
                    local waits = (job.replantHarvestSettleWaits[crop.key] or 0) + 1
                    job.replantHarvestSettleWaits[crop.key] = waits
                    if waits <= AW.REPLANT_HARVEST_SETTLE_RETRIES then
                        ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.REPLANT_SETTLE_TIME))
                        AW.touch("replant-wait-harvest-settle")
                        return true
                    end
                    table.remove(job.pending, 1)
                    job.watchdogRetries = 0
                elseif not plant then
                    if job.replantDigQueuedKeys and job.replantDigQueuedKeys[crop.key] then
                        job.replantFurrowWaits = job.replantFurrowWaits or {}
                        local waits = (job.replantFurrowWaits[crop.key] or 0) + 1
                        job.replantFurrowWaits[crop.key] = waits
                        if waits <= AW.REPLANT_FURROW_SETTLE_RETRIES then
                            ISTimedActionQueue.add(ParadiseZ_AutoFarm_NextAction:new(playerObj, AW.REPLANT_SETTLE_TIME))
                            AW.touch("replant-wait-furrow")
                            return true
                        end
                        job.replantDigQueuedKeys[crop.key] = nil
                        job.replantFurrowWaits[crop.key] = nil
                        return AW.queueReplantDig(playerObj, crop)
                    end
                    return AW.queueReplantDig(playerObj, crop)
                else
                    return AW.queueReplant(playerObj, crop, plant)
                end
            end
            job.active = false
            if job.chainQueue and #job.chainQueue > 0 and job.center then
                local nextJob = table.remove(job.chainQueue, 1)
                local remaining = job.chainQueue
                AW.pendingChainCarry = remaining
                if nextJob.pattern then AW.currentFurrowPattern = nextJob.pattern end
                AW.start(job.playerNum or 0, job.center, nextJob.mode)
            end
            return true
        end
    end
end

do
    local AW = ParadiseZ_AutoFarm
    if not AW then return end

    function AW.modePrettyName(mode)
        if mode == "harvestSeed" then return "seed-bearing crops" end
        if mode == "harvest" then return "ripe crops" end
        if mode == "replantHarvested" then return "harvested rows" end
        if mode == "removeOffPattern" then return "off-pattern crops and furrows" end
        if mode == "removeReceding" then return "receding plants" end
        if mode == "removePlants" then return "planted crops" end
        if mode == "removePlots" then return "empty furrows" end
        if mode == "digFurrows" then return "open soil" end
        if mode == "treat" then return "crop disease" end
        if mode == "water" then return "crop water levels" end
        return "the farm"
    end

    function AW.checkingText(mode)
        if mode == "harvestSeed" then return "Checking seed-bearing crops..." end
        if mode == "harvest" then return "Checking ripe crops..." end
        if mode == "replantHarvested" then return "Checking harvested rows..." end
        if mode == "removeOffPattern" then return "Checking the furrow pattern..." end
        if mode == "removeReceding" then return "Checking receding plants..." end
        if mode == "removePlants" then return "Checking planted crops..." end
        if mode == "removePlots" then return "Checking empty furrows..." end
        if mode == "digFurrows" then return "Checking open soil..." end
        if mode == "treat" then return "Checking crops for disease..." end
        if mode == "water" then return "Checking crop water levels..." end
        return "Checking the farm..."
    end

    function AW.noneFoundText(mode)
        if mode == "harvestSeed" then return "No seed-bearing crops are ready." end
        if mode == "harvest" then return "No crops are ready to harvest." end
        if mode == "replantHarvested" then return "Nothing needs replanting." end
        if mode == "removeOffPattern" then return "The farm already matches this pattern." end
        if mode == "removeReceding" then return "No receding plants need clearing." end
        if mode == "removePlants" then return "No planted crops need removing." end
        if mode == "removePlots" then return "No empty furrows need removing." end
        if mode == "digFurrows" then return "No new furrows need digging." end
        if mode == "treat" then return "No crop diseases need treating." end
        if mode == "water" then return "No crops need water." end
        return "Nothing needs attention here."
    end

    function AW.foundText(mode, count)
        count = tonumber(count) or 0
        local one = count == 1
        if mode == "harvestSeed" then return one and "One seed-bearing crop is ready." or tostring(count) .. " seed-bearing crops are ready." end
        if mode == "harvest" then return one and "One crop is ready to harvest." or tostring(count) .. " crops are ready to harvest." end
        if mode == "replantHarvested" then return one and "One harvested row needs replanting." or tostring(count) .. " harvested rows need replanting." end
        if mode == "removeOffPattern" then return one and "One off-pattern crop or furrow needs clearing." or tostring(count) .. " off-pattern crops or furrows need clearing." end
        if mode == "removeReceding" then return one and "One receding plant needs clearing." or tostring(count) .. " receding plants need clearing." end
        if mode == "removePlants" then return one and "One planted crop needs removing." or tostring(count) .. " planted crops need removing." end
        if mode == "removePlots" then return one and "One empty furrow needs removing." or tostring(count) .. " empty furrows need removing." end
        if mode == "digFurrows" then return one and "One furrow needs digging." or tostring(count) .. " furrows need digging." end
        if mode == "treat" then return "Finished checking crops for disease." end
        if mode == "water" then return one and "One crop needs water." or tostring(count) .. " crops need water." end
        return one and "One task needs attention." or tostring(count) .. " tasks need attention."
    end

    if ParadiseZ_AutoFarm_IndexAction then
        function ParadiseZ_AutoFarm_IndexAction:perform()
            if self.token and AW.isTokenCurrent and not AW.isTokenCurrent(self.token) then
                self.completed = true
                ISBaseTimedAction.perform(self)
                return
            end
            while self.sourceRowIndex <= #self.sourceRows or self.cropRowIndex <= #self.cropRows do
                self:processSome()
            end
            self.sources = AW.addWaterTileFallbackIfNeeded(self.sources, self.collector)
            local playerObj = self.character
            local crops = AW.routeGreedy(self.crops, playerObj)
            local carry = AW.job and AW.job.chainQueue or AW.pendingChainCarry
            self.completed = true
            if #crops <= 0 then
                if AW.job then AW.job.active = false end
                playerObj:Say(AW.noneFoundText(self.mode))
                ISBaseTimedAction.perform(self)
                if AW.continueChainOrFinish then
                    AW.continueChainOrFinish(playerObj, self.playerNum or 0, self.collector, carry, self.mode)
                elseif carry and #carry > 0 then
                    local nextJob = table.remove(carry, 1)
                    AW.pendingChainCarry = carry
                    if nextJob.pattern then AW.currentFurrowPattern = nextJob.pattern end
                    AW.start(self.playerNum or 0, self.collector, nextJob.mode)
                end
                return
            end
            AW.job.sources = self.sources
            AW.job.pending = crops
            AW.job.treatAttempts = {}
            AW.job.devilWatering = {}
            AW.job.preferredWaterCan = nil
            AW.job.localWater = {}
            AW.job.watchdogRetries = 0
            AW.job.lastQueuedKind = nil
            AW.job.lastQueuedCropKey = nil
            AW.job.needSaid = AW.job.needSaid or {}
            playerObj:Say(AW.foundText(self.mode, #crops))
            ISBaseTimedAction.perform(self)
            AW.touch("row-staged-index-complete")
            AW.step()
        end
    end

    if ParadiseZ_AutoFarm_TargetIndexAction then
        function ParadiseZ_AutoFarm_TargetIndexAction:perform()
            if self.token and AW.isTokenCurrent and not AW.isTokenCurrent(self.token) then
                self.completed = true
                ISBaseTimedAction.perform(self)
                return
            end
            while self.rowIndex <= #self.rows do self:processSome() end
            local playerObj = self.character
            local targets = AW.routeGreedy(self.targets, playerObj)
            local carry = (AW.job and AW.job.chainQueue) or AW.pendingChainCarry
            AW.pendingChainCarry = nil
            local mode = self.mode
            self.completed = true
            if #targets <= 0 then
                if AW.job then AW.job.active = false end
                playerObj:Say(AW.noneFoundText(mode))
                ISBaseTimedAction.perform(self)
                AW.continueChainOrFinish(playerObj, self.playerNum or 0, self.collector, carry, mode)
                return
            end
            local job = {
                token = self.token, active = true, mode = mode, playerNum = self.playerNum or 0,
                center = self.collector, sources = {}, pending = targets, treatAttempts = {},
                devilWatering = {}, localWater = {}, preferredWaterCan = nil, watchdogRetries = 0,
                lastQueuedKind = nil, lastQueuedCropKey = nil, chainQueue = carry or {}, needSaid = {}
            }
            if mode == "harvest" or mode == "harvestSeed" then
                job.queuedHarvestKeys = {}
                job.collectReplant = AW.pendingReplantActive == true
            elseif mode == "removePlots" or mode == "removeReceding" or mode == "removePlants" or mode == "removeOffPattern" then
                job.queuedRemoveKeys = {}
                job.patternSet = self.patternSet
            elseif mode == "digFurrows" then
                job.mode = "digFurrows"
                job.queuedDigKeys = {}
            end
            AW.job = job
            playerObj:Say(AW.foundText(mode, #targets))
            ISBaseTimedAction.perform(self)
            AW.touch("target-row-index-complete")
            AW.step()
        end
    end

    if AW.queueRemovePlant and not AW._QueueRemovePlantBase then
        AW._QueueRemovePlantBase = AW.queueRemovePlant
        function AW.queueRemovePlant(playerObj, crop, plant)
            if not AW.findRemoveTool(playerObj) then
                playerObj:Say("I need a shovel or trowel for that.")
                AW.cancel("no remove tool")
                return false
            end
            return AW._QueueRemovePlantBase(playerObj, crop, plant)
        end
    end

    if AW.queuePlowSquare and not AW._QueuePlowSquareBase then
        AW._QueuePlowSquareBase = AW.queuePlowSquare
        function AW.queuePlowSquare(playerObj, point)
            if not AW.findDigTool(playerObj) and not AW.handsCanDig(playerObj) then
                playerObj:Say("I need a shovel, trowel, or uninjured hands to dig.")
                AW.cancel("no dig tool and injured hands")
                return false
            end
            return AW._QueuePlowSquareBase(playerObj, point)
        end
    end

    AW.CLOSE_BUTTON_BOTTOM_PADDING = AW.CLOSE_BUTTON_BOTTOM_PADDING or 10
    function AW.moveCloseButtonToBottom(win)
        if not win or not win.buttons then return end
        local btn = win.buttons.close
        if not btn then return end
        local pad = AW.CLOSE_BUTTON_BOTTOM_PADDING or 10
        local btnH = btn.height or 20
        local newY = math.max(0, (win.height or 292) - btnH - pad)
        btn.y = newY
        if btn.setY then pcall(function() btn:setY(newY) end) end
        if btn.setVisible then pcall(function() btn:setVisible(true) end) end
        if btn.bringToTop then pcall(function() btn:bringToTop() end) end
    end

    if ParadiseZ_AutoFarm_AutoFarmWindow and not ParadiseZ_AutoFarm_AutoFarmWindow._closeBottomBaseCreateChildren then
        ParadiseZ_AutoFarm_AutoFarmWindow._closeBottomBaseCreateChildren = ParadiseZ_AutoFarm_AutoFarmWindow.createChildren
        function ParadiseZ_AutoFarm_AutoFarmWindow:createChildren()
            self:_closeBottomBaseCreateChildren()
            ParadiseZ_AutoFarm.moveCloseButtonToBottom(self)
        end
    end

    if AW.autoFarmWindow then AW.moveCloseButtonToBottom(AW.autoFarmWindow) end

    local baseStartAction = AW.start
    function AW.start(playerNum, collector, mode)
        AW.applySandboxSettings()
        if AW.ENABLED == false then
            local playerObj = AW.player and AW.player(playerNum)
            if playerObj then playerObj:Say("Auto-Farm is disabled here.") end
            return
        end
        return baseStartAction(playerNum, collector, mode)
    end

    local baseContextAction = AW.onContext
    function AW.onContext(playerNum, context, worldobjects, test)
        AW.applySandboxSettings()
        if AW.ENABLED == false then return end
        return baseContextAction(playerNum, context, worldobjects, test)
    end

    if Events.OnFillWorldObjectContextMenu then
        pcall(function() Events.OnFillWorldObjectContextMenu.Remove(baseContextAction) end)
        pcall(function() Events.OnFillWorldObjectContextMenu.Remove(AW.onContext) end)
        end
end


do
    local AW = ParadiseZ_AutoFarm
    if AW then
        AW.SANDBOX_ROOT = "ParadiseZ"
        AW.INDEX_TOTAL_TIME = 120
        AW.WATER_TILE_FALLBACK_ONLY_IF_NO_OBJECT_SOURCES = true
        AW.HIGHLIGHT_REFRESH_TICKS = AW.HIGHLIGHT_REFRESH_TICKS or 120

        function AW.farmRadiusFromSetting(value)
            local v = tonumber(value)
            if v == 1 then return 3 end
            if v == 2 then return 5 end
            if v == 3 then return 7 end
            if v == 5 then return 5 end
            if v == 7 then return 7 end
            return 5
        end

        function AW.applySandboxSettings()
            local vars = SandboxVars and SandboxVars[AW.SANDBOX_ROOT or "ParadiseZ"]
            if not vars then return end
            AW.ENABLED = AW.boolSetting(vars, "AutoFarmEnabled", true)
            AW.CROP_RADIUS = AW.farmRadiusFromSetting(vars.AutoFarmCropRadius)
            AW.FURROW_RADIUS = AW.CROP_RADIUS
            AW.WATER_SOURCE_RADIUS = AW.intSetting(vars, "AutoFarmWaterSourceRadius", 15, 5, 25)
            AW.ENABLE_WATER_TILE_FALLBACK = AW.boolSetting(vars, "AutoFarmWaterTileFallback", true)
            AW.FEATURE_AUTO_REPLANT = not AW.boolSetting(vars, "AutoFarmDisableAutoReplant", false)
            AW.FEATURE_AUTO_DIG = not AW.boolSetting(vars, "AutoFarmDisableAutoDig", false)
            AW.FEATURE_AUTO_TREAT = not AW.boolSetting(vars, "AutoFarmDisableAutoTreat", false)
            AW.FEATURE_AUTO_HARVEST = not AW.boolSetting(vars, "AutoFarmDisableAutoHarvest", false)
            AW.FEATURE_AUTO_CLEAR_RECEDING = not AW.boolSetting(vars, "AutoFarmDisableAutoClearReceding", false)
            if AW.refreshAutoFarmRangeSettings then AW.refreshAutoFarmRangeSettings() end
        end

        function AW.applyFeatureSettingsToPlan(plan)
            plan = plan or {}
            AW.applySandboxSettings()
            if AW.FEATURE_AUTO_REPLANT == false then plan.includeReplantHarvested = false end
            if AW.FEATURE_AUTO_DIG == false then plan.includeDig = false end
            if AW.FEATURE_AUTO_TREAT == false then plan.includeTreat = false end
            if AW.FEATURE_AUTO_HARVEST == false then
                plan.includeHarvestAll = false
                plan.includeHarvestSeed = false
            end
            if AW.FEATURE_AUTO_CLEAR_RECEDING == false then plan.includeClearReceding = false end
            return plan
        end

        if not AW._SandboxDefaultsBaseDefaultUIPrefs and AW.defaultUIPrefs then
            AW._SandboxDefaultsBaseDefaultUIPrefs = AW.defaultUIPrefs
            function AW.defaultUIPrefs()
                return AW.applyFeatureSettingsToPlan(AW._SandboxDefaultsBaseDefaultUIPrefs())
            end
        end

        if not AW._SandboxDefaultsBaseNormalizeTendPlan and AW.normalizeTendPlan then
            AW._SandboxDefaultsBaseNormalizeTendPlan = AW.normalizeTendPlan
            function AW.normalizeTendPlan(plan)
                return AW.applyFeatureSettingsToPlan(AW._SandboxDefaultsBaseNormalizeTendPlan(plan))
            end
        end

        if not AW._SandboxDefaultsBaseBuildTendChain and AW.buildTendChain then
            AW._SandboxDefaultsBaseBuildTendChain = AW.buildTendChain
            function AW.buildTendChain(plan)
                return AW._SandboxDefaultsBaseBuildTendChain(AW.applyFeatureSettingsToPlan(plan or AW.defaultUIPrefs()))
            end
        end

        function AW.featureAllowedForButton(mode)
            AW.applySandboxSettings()
            if mode == "toggleReplantHarvested" then return AW.FEATURE_AUTO_REPLANT ~= false end
            if mode == "toggleDig" then return AW.FEATURE_AUTO_DIG ~= false end
            if mode == "toggleTreat" or mode == "treat" then return AW.FEATURE_AUTO_TREAT ~= false end
            if mode == "toggleHarvestAll" or mode == "toggleHarvestSeed" then return AW.FEATURE_AUTO_HARVEST ~= false end
            if mode == "toggleClearReceding" then return AW.FEATURE_AUTO_CLEAR_RECEDING ~= false end
            return true
        end

        function AW.fieldAllowed(field)
            AW.applySandboxSettings()
            if field == "includeReplantHarvested" then return AW.FEATURE_AUTO_REPLANT ~= false end
            if field == "includeDig" then return AW.FEATURE_AUTO_DIG ~= false end
            if field == "includeTreat" then return AW.FEATURE_AUTO_TREAT ~= false end
            if field == "includeHarvestAll" or field == "includeHarvestSeed" then return AW.FEATURE_AUTO_HARVEST ~= false end
            if field == "includeClearReceding" then return AW.FEATURE_AUTO_CLEAR_RECEDING ~= false end
            return true
        end

        function AW.sayFeatureDisabled(playerObj)
            if playerObj then playerObj:Say("That Auto-Farm task is disabled here.") end
        end

        function AW.setControlEnabled(control, enabled)
            if not control then return end
            if control.setEnable then pcall(function() control:setEnable(enabled == true) end) end
            if control.setEnabled then pcall(function() control:setEnabled(enabled == true) end) end
            control.enable = enabled == true
        end

        function AW.applyFeatureSettingsToWindow(win)
            if not win then return end
            win.includeReplantHarvested = win.includeReplantHarvested == true and AW.fieldAllowed("includeReplantHarvested")
            win.includeDig = win.includeDig == true and AW.fieldAllowed("includeDig")
            win.includeTreat = win.includeTreat == true and AW.fieldAllowed("includeTreat")
            win.includeHarvestAll = win.includeHarvestAll == true and AW.fieldAllowed("includeHarvestAll")
            win.includeHarvestSeed = win.includeHarvestSeed == true and AW.fieldAllowed("includeHarvestSeed")
            win.includeClearReceding = win.includeClearReceding == true and AW.fieldAllowed("includeClearReceding")
            if win.enforceHarvestExclusion then win:enforceHarvestExclusion() end
            if win.updateCheckboxLabels then win:updateCheckboxLabels() end
            if win.buttons then
                AW.setControlEnabled(win.buttons.toggleReplantHarvested, AW.fieldAllowed("includeReplantHarvested"))
                AW.setControlEnabled(win.buttons.toggleDig, AW.fieldAllowed("includeDig"))
                AW.setControlEnabled(win.buttons.toggleTreat, AW.fieldAllowed("includeTreat"))
                AW.setControlEnabled(win.buttons.treat, AW.fieldAllowed("includeTreat"))
                AW.setControlEnabled(win.buttons.toggleHarvestAll, AW.fieldAllowed("includeHarvestAll"))
                AW.setControlEnabled(win.buttons.toggleHarvestSeed, AW.fieldAllowed("includeHarvestSeed"))
                AW.setControlEnabled(win.buttons.toggleClearReceding, AW.fieldAllowed("includeClearReceding"))
            end
        end

        if ParadiseZ_AutoFarm_AutoFarmWindow and not ParadiseZ_AutoFarm_AutoFarmWindow._SandboxDefaultsBaseNew then
            ParadiseZ_AutoFarm_AutoFarmWindow._SandboxDefaultsBaseNew = ParadiseZ_AutoFarm_AutoFarmWindow.new
            function ParadiseZ_AutoFarm_AutoFarmWindow:new(x, y, width, height, playerNum, collector)
                local o = self:_SandboxDefaultsBaseNew(x, y, width, height, playerNum, collector)
                AW.applyFeatureSettingsToWindow(o)
                return o
            end
        end

        if ParadiseZ_AutoFarm_AutoFarmWindow and not ParadiseZ_AutoFarm_AutoFarmWindow._SandboxDefaultsBasePrefs then
            ParadiseZ_AutoFarm_AutoFarmWindow._SandboxDefaultsBasePrefs = ParadiseZ_AutoFarm_AutoFarmWindow.prefs
            function ParadiseZ_AutoFarm_AutoFarmWindow:prefs()
                return AW.applyFeatureSettingsToPlan(self:_SandboxDefaultsBasePrefs())
            end
        end

        if ParadiseZ_AutoFarm_AutoFarmWindow and not ParadiseZ_AutoFarm_AutoFarmWindow._SandboxDefaultsBaseUpdateCheckboxLabels then
            ParadiseZ_AutoFarm_AutoFarmWindow._SandboxDefaultsBaseUpdateCheckboxLabels = ParadiseZ_AutoFarm_AutoFarmWindow.updateCheckboxLabels
            function ParadiseZ_AutoFarm_AutoFarmWindow:updateCheckboxLabels()
                self:_SandboxDefaultsBaseUpdateCheckboxLabels()
                if self.buttons then
                    AW.setControlEnabled(self.buttons.toggleReplantHarvested, AW.fieldAllowed("includeReplantHarvested"))
                    AW.setControlEnabled(self.buttons.toggleDig, AW.fieldAllowed("includeDig"))
                    AW.setControlEnabled(self.buttons.toggleTreat, AW.fieldAllowed("includeTreat"))
                    AW.setControlEnabled(self.buttons.treat, AW.fieldAllowed("includeTreat"))
                    AW.setControlEnabled(self.buttons.toggleHarvestAll, AW.fieldAllowed("includeHarvestAll"))
                    AW.setControlEnabled(self.buttons.toggleHarvestSeed, AW.fieldAllowed("includeHarvestSeed"))
                    AW.setControlEnabled(self.buttons.toggleClearReceding, AW.fieldAllowed("includeClearReceding"))
                end
            end
        end

        if ParadiseZ_AutoFarm_AutoFarmWindow and not ParadiseZ_AutoFarm_AutoFarmWindow._SandboxDefaultsBaseOnButton then
            ParadiseZ_AutoFarm_AutoFarmWindow._SandboxDefaultsBaseOnButton = ParadiseZ_AutoFarm_AutoFarmWindow.onButton
            function ParadiseZ_AutoFarm_AutoFarmWindow:onButton(button)
                local mode = button and button.internal
                if not AW.featureAllowedForButton(mode) then
                    AW.sayFeatureDisabled(AW.player and AW.player(self.playerNum or 0) or getPlayer())
                    AW.applyFeatureSettingsToWindow(self)
                    return
                end
                local result = self:_SandboxDefaultsBaseOnButton(button)
                AW.applyFeatureSettingsToWindow(self)
                return result
            end
        end

        if AW.uiTooltips then
            AW.uiTooltips.toggleHarvestAll = "Harvests every crop that is currently harvestable."
            AW.uiTooltips.toggleHarvestSeed = "Harvests only seed-bearing crops."
            AW.uiTooltips.toggleReplantHarvested = "Replants harvested crops when matching seeds are available."
            AW.uiTooltips.toggleDig = "Digs missing furrows in the selected pattern."
            AW.uiTooltips.toggleTreat = "Includes disease treatment in Tend Crops."
            AW.uiTooltips.toggleClearReceding = "Clears receding/dead plants inside the selected pattern."
        end

        if not AW._SandboxDefaultsBaseOpenAutoFarmUI and AW.openAutoFarmUI then
            AW._SandboxDefaultsBaseOpenAutoFarmUI = AW.openAutoFarmUI
            function AW.openAutoFarmUI(playerNum, collector)
                AW.applySandboxSettings()
                AW._SandboxDefaultsBaseOpenAutoFarmUI(playerNum, collector)
                AW.applyFeatureSettingsToWindow(AW.autoFarmWindow)
                if AW.autoFarmWindow and AW.autoFarmWindow.refreshHighlight then AW.autoFarmWindow:refreshHighlight() end
            end
        end

        if not AW._SandboxDefaultsBaseStart and AW.start then
            AW._SandboxDefaultsBaseStart = AW.start
            function AW.start(playerNum, collector, mode)
                AW.applySandboxSettings()
                if AW.ENABLED == false then
                    local playerObj = AW.player and AW.player(playerNum)
                    if playerObj then playerObj:Say("Auto-Farm is disabled here.") end
                    return
                end
                if mode == "treat" and AW.FEATURE_AUTO_TREAT == false then
                    AW.sayFeatureDisabled(AW.player and AW.player(playerNum) or getPlayer())
                    return
                end
                return AW._SandboxDefaultsBaseStart(playerNum, collector, mode)
            end
        end

        AW.applySandboxSettings()
    end
end

-- Production Auto-Farm range, water, and context behavior.
do
    local AW = ParadiseZ_AutoFarm
    local WindowClass = ParadiseZ_AutoFarm_AutoFarmWindow
    if AW and WindowClass then
        AW.EMPTY_PLOT_TARGET = 50
        AW.EMPTY_PLOT_SKIP_AT = 50
        AW.DEVIL_HEALING_MAX = 48
        AW.DEVIL_TARGET = 48
        AW.DEVIL_SKIP_AT = 48
        AW.WATER_INCREMENT = 5

        local function toNumber(value, default)
            local number = tonumber(value)
            if number == nil then return default end
            return number
        end

        local function clamp(value, low, high)
            value = toNumber(value, low or 0)
            if low ~= nil and value < low then value = low end
            if high ~= nil and value > high then value = high end
            return value
        end

        local function firstNumber(a, b, c, d, e, f)
            local value = toNumber(a, nil)
            if value ~= nil then return value end
            value = toNumber(b, nil)
            if value ~= nil then return value end
            value = toNumber(c, nil)
            if value ~= nil then return value end
            value = toNumber(d, nil)
            if value ~= nil then return value end
            value = toNumber(e, nil)
            if value ~= nil then return value end
            value = toNumber(f, nil)
            if value ~= nil then return value end
            return nil
        end

        local function playerFor(playerNum)
            if AW.player then
                local playerObj = AW.player(playerNum)
                if playerObj then return playerObj end
            end
            return getSpecificPlayer(playerNum or 0) or getPlayer()
        end

        local function objectXY(object)
            local x, y = 0, 0
            pcall(function() x = object:getX() end)
            pcall(function() y = object:getY() end)
            return x, y
        end

        local function distanceToCollector(playerObj, collector)
            if not playerObj or not collector then return 999999 end
            local x, y = objectXY(collector)
            local dx = playerObj:getX() - x
            local dy = playerObj:getY() - y
            return math.sqrt((dx * dx) + (dy * dy))
        end

        function AW.autoFarmUseRange()
            local waterRange = toNumber(AW.WATER_SOURCE_RADIUS, 15)
            return math.max(1, waterRange + 1)
        end

        function AW.refreshAutoFarmRangeSettings()
            local range = AW.autoFarmUseRange()
            AW.IDLE_WINDOW_CLOSE_DISTANCE = range
            return range
        end

        function AW.isPlayerInAutoFarmRange(playerObj, collector)
            return distanceToCollector(playerObj, collector) <= AW.autoFarmUseRange()
        end

        local applySandboxSettingsCurrent = AW.applySandboxSettings
        function AW.applySandboxSettings()
            if applySandboxSettingsCurrent then applySandboxSettingsCurrent() end
            AW.refreshAutoFarmRangeSettings()
        end

        function AW.cropWaterBounds(plant, config, seed)
            local rule = AW.getCustomWaterRule and AW.getCustomWaterRule(seed) or nil
            local minWater = rule and rule.minWater or nil
            local maxWater = rule and rule.maxWater or nil

            if minWater == nil then
                minWater = firstNumber(
                    plant and plant.waterNeeded,
                    plant and plant.waterNeededMin,
                    plant and plant.waterLvlMin,
                    config and config.waterLvl,
                    config and config.waterLvlMin,
                    config and config.waterNeeded
                )
            end

            if maxWater == nil then
                maxWater = firstNumber(
                    plant and plant.waterNeededMax,
                    plant and plant.waterLvlMax,
                    config and config.waterLvlMax,
                    config and config.waterNeededMax,
                    nil,
                    nil
                )
            end

            if minWater ~= nil then minWater = clamp(minWater, 0, 100) end
            if maxWater ~= nil then maxWater = clamp(maxWater, 1, 100) end
            return minWater, maxWater, rule
        end

        function AW.safeWaterUses(current, target, availableUses)
            current = toNumber(current, 0)
            target = toNumber(target, 100)
            availableUses = math.max(0, math.floor(toNumber(availableUses, 0)))
            if availableUses <= 0 then return 0 end
            if current >= target then return 0 end
            local step = AW.WATER_INCREMENT or 5
            local safeUses = math.floor((target - current) / step)
            if safeUses <= 0 then return 0 end
            return math.max(0, math.min(safeUses, availableUses, AW.WATER_MAX_USE_PER_ACTION or safeUses))
        end

        function AW.waterUsesForPlan(current, target, sensitive, devil, availableUses)
            return AW.safeWaterUses(current, target, availableUses)
        end

        function AW.cropPlan(plant, cropKey)
            if AW.invalidPlant(plant) then
                return false, 0, 0, 0, 0, "invalid", false, false, 100
            end

            local current = AW.num(plant.waterLvl, 0)
            local seed = tostring(plant.typeOfSeed or "")
            local config = AW.cropConfig(seed)
            local minWater, maxWater, rule = AW.cropWaterBounds(plant, config, seed)
            local disease = AW.diseaseInfo(plant)
            local devil = disease.devil and disease.devil > 0
            local emptyPlot = AW.isEmptyPlot(plant)

            if AW.job and AW.job.localWater and cropKey and AW.job.localWater[cropKey] ~= nil then
                local predicted = AW.num(AW.job.localWater[cropKey], current)
                if predicted > current then current = predicted end
            end

            local target
            local skipAt
            local bounded = false

            if emptyPlot then
                if seed == "" then seed = "none" end
                target = AW.EMPTY_PLOT_TARGET or 50
                skipAt = target
                bounded = true
            elseif devil then
                target = AW.DEVIL_HEALING_MAX or AW.DEVIL_TARGET or 48
                if rule and rule.devilTarget then target = rule.devilTarget end
                if maxWater ~= nil then target = math.min(target, maxWater) end
                target = clamp(target, 0, 100)
                skipAt = target
                bounded = true
            elseif rule and rule.targetWater then
                local cap = maxWater or 100
                target = clamp(rule.targetWater, 0, cap)
                skipAt = target
                bounded = true
            elseif maxWater ~= nil then
                target = maxWater
                skipAt = maxWater
                bounded = true
            elseif AW.isSensitiveBase(seed, maxWater) then
                target = AW.SENSITIVE_TARGET or 75
                skipAt = AW.SENSITIVE_SKIP_AT or 71
                bounded = true
            else
                target = AW.NORMAL_TARGET or 100
                skipAt = AW.NORMAL_SKIP_AT or 95
            end

            target = clamp(target, 0, 100)
            skipAt = clamp(skipAt or target, 0, 100)

            if current >= skipAt then
                return false, 0, current, target, skipAt, seed, bounded, devil, maxWater or 100
            end

            local safeUses = AW.safeWaterUses(current, target, 999999)
            if safeUses <= 0 then
                return false, 0, current, target, skipAt, seed, bounded, devil, maxWater or 100
            end

            return true, math.max(1, math.ceil(target - current)), current, target, skipAt, seed, bounded, devil, maxWater or 100
        end

        function AW.filterWaterTargets(crops)
            local filtered = {}
            for _, crop in ipairs(crops or {}) do
                local plant = AW.plantAt(crop.x, crop.y, crop.z)
                if plant and not AW.invalidPlant(plant) then
                    local needs, amount, current, target, skipAt, seed, bounded, devil = AW.cropPlan(plant, crop.key)
                    if needs and AW.waterUsesForPlan(current, target, bounded, devil, 999999) > 0 then
                        crop.seed = seed or crop.seed
                        table.insert(filtered, crop)
                    end
                end
            end
            return filtered
        end

        if ParadiseZ_AutoFarm_IndexAction then
            function ParadiseZ_AutoFarm_IndexAction:processCropRow(y)
                local cell = getCell()
                for x = self.cx - AW.CROP_RADIUS, self.cx + AW.CROP_RADIUS do
                    if AW.coordMatchesPattern(self.patternSet, x, y, self.cz) then
                        local square = cell:getGridSquare(x, y, self.cz)
                        if square then
                            local plant = AW.plantAt(x, y, self.cz)
                            if plant and not AW.invalidPlant(plant) then
                                local key = tostring(x) .. "," .. tostring(y) .. "," .. tostring(self.cz)
                                local include = true
                                local seed = tostring(plant.typeOfSeed or "")
                                if self.mode == "water" then
                                    local needs, amount, current, target, skipAt, plannedSeed, bounded, devil = AW.cropPlan(plant, key)
                                    include = needs and AW.waterUsesForPlan(current, target, bounded, devil, 999999) > 0
                                    seed = plannedSeed or seed
                                end
                                if include then
                                    table.insert(self.crops, { x = x, y = y, z = self.cz, key = key, seed = seed })
                                end
                            end
                        end
                    end
                end
            end

            function ParadiseZ_AutoFarm_IndexAction:perform()
                if self.token and AW.isTokenCurrent and not AW.isTokenCurrent(self.token) then
                    self.completed = true
                    ISBaseTimedAction.perform(self)
                    return
                end

                while self.sourceRowIndex <= #self.sourceRows or self.cropRowIndex <= #self.cropRows do
                    self:processSome()
                end

                self.sources = AW.addWaterTileFallbackIfNeeded(self.sources, self.collector)
                local playerObj = self.character
                local crops = self.crops
                if self.mode == "water" then crops = AW.filterWaterTargets(crops) end
                crops = AW.routeGreedy(crops, playerObj)
                local carry = AW.job and AW.job.chainQueue or AW.pendingChainCarry
                self.completed = true

                if #crops <= 0 then
                    if AW.job then AW.job.active = false end
                    playerObj:Say(AW.noneFoundText(self.mode))
                    ISBaseTimedAction.perform(self)
                    if AW.continueChainOrFinish then
                        AW.continueChainOrFinish(playerObj, self.playerNum or 0, self.collector, carry, self.mode)
                    end
                    return
                end

                AW.job.sources = self.sources
                AW.job.pending = crops
                AW.job.treatAttempts = {}
                AW.job.devilWatering = {}
                AW.job.preferredWaterCan = nil
                AW.job.localWater = {}
                AW.job.watchdogRetries = 0
                AW.job.lastQueuedKind = nil
                AW.job.lastQueuedCropKey = nil
                AW.job.needSaid = AW.job.needSaid or {}
                playerObj:Say(AW.foundText(self.mode, #crops))
                ISBaseTimedAction.perform(self)
                AW.touch("row-staged-index-complete")
                AW.step()
            end
        end

        local continueChainOrFinishCurrent = AW.continueChainOrFinish
        function AW.continueChainOrFinish(playerObj, playerNum, collector, carry, emptyMode)
            if carry and #carry > 0 then
                if continueChainOrFinishCurrent then
                    return continueChainOrFinishCurrent(playerObj, playerNum, collector, carry, emptyMode)
                end
                return false
            end
            if AW.tendChainActive then
                AW.tendChainActive = false
                if playerObj then playerObj:Say("Finished tending crops.") end
            end
            return false
        end

        local startCurrent = AW.start
        function AW.start(playerNum, collector, mode)
            AW.applySandboxSettings()
            if mode == "tend" then AW.tendChainActive = true end
            return startCurrent(playerNum, collector, mode)
        end

        function AW.closeAutoFarmWindow(win)
            win = win or AW.autoFarmWindow
            if win and win.savePrefs then pcall(function() win:savePrefs() end) end
            pcall(function()
                if AW.clearAutoFarmHighlight then
                    AW.clearAutoFarmHighlight()
                elseif AW.removeAutoFarmMarkers then
                    AW.removeAutoFarmMarkers()
                end
            end)
            if AW.autoFarmWindow == win then AW.autoFarmWindow = nil end
            if AW.highlightWindow == win then AW.highlightWindow = nil end
            if win then
                local removeBase = WindowClass._AutoFarmRemoveFromUIManager
                if removeBase then
                    return removeBase(win)
                end
                if ISCollapsableWindow and ISCollapsableWindow.removeFromUIManager then
                    return ISCollapsableWindow.removeFromUIManager(win)
                end
            end
        end

        if not WindowClass._AutoFarmClose then
            WindowClass._AutoFarmClose = WindowClass.close
        end
        function WindowClass:close()
            return AW.closeAutoFarmWindow(self)
        end

        if not WindowClass._AutoFarmRemoveFromUIManager then
            WindowClass._AutoFarmRemoveFromUIManager = WindowClass.removeFromUIManager
        end
        function WindowClass:removeFromUIManager()
            return AW.closeAutoFarmWindow(self)
        end

        function WindowClass:addButtonRow(items, x, y, w, h, gap)
            local count = #items
            if count <= 0 then return y end
            local buttonWidth = math.floor((w - (gap * (count - 1))) / count)
            for index, item in ipairs(items) do
                local buttonX = x + ((buttonWidth + gap) * (index - 1))
                self:addButton(item.label, item.mode, buttonX, y, buttonWidth, h)
            end
            return y + h + 4
        end

        local function featureAllowed(field)
            if AW.fieldAllowed then return AW.fieldAllowed(field) end
            AW.applySandboxSettings()
            if field == "includeReplantHarvested" then return AW.FEATURE_AUTO_REPLANT ~= false end
            if field == "includeDig" then return AW.FEATURE_AUTO_DIG ~= false end
            if field == "includeTreat" then return AW.FEATURE_AUTO_TREAT ~= false end
            if field == "includeHarvestAll" or field == "includeHarvestSeed" then return AW.FEATURE_AUTO_HARVEST ~= false end
            if field == "includeClearReceding" then return AW.FEATURE_AUTO_CLEAR_RECEDING ~= false end
            return true
        end

        function WindowClass:createChildren()
            if ISCollapsableWindow.createChildren then ISCollapsableWindow.createChildren(self) end
            self.buttons = {}
            AW.applySandboxSettings()
            local y = 26
            local x = 12
            local w = self.width - 24
            local h = 20
            local gap = 5

            self:addButton("Tend Crops", "tend", x, y, w, h)
            y = y + h + 4

            local main = { { label = "Water Crops Only", mode = "water" } }
            if featureAllowed("includeTreat") then table.insert(main, { label = "Treat Crops Only", mode = "treat" }) end
            y = self:addButtonRow(main, x, y, w, h, gap) + 4

            if ISLabel then
                local label = ISLabel:new(x, y + 3, h, "Tend Includes", 1, 1, 1, 1, UIFont.Small, true)
                label:initialise()
                self:addChild(label)
            end
            y = y + h

            local includeItems = {}
            if featureAllowed("includeHarvestAll") then
                table.insert(includeItems, { label = "[ ] Harvest All", mode = "toggleHarvestAll" })
                table.insert(includeItems, { label = "[X] Seed-bearing", mode = "toggleHarvestSeed" })
            end
            if featureAllowed("includeReplantHarvested") then table.insert(includeItems, { label = "[ ] Replant", mode = "toggleReplantHarvested" }) end
            table.insert(includeItems, { label = "[ ] Match Pattern", mode = "toggleMatchPattern" })
            if featureAllowed("includeClearReceding") then table.insert(includeItems, { label = "[X] Clear Receding", mode = "toggleClearReceding" }) end
            if featureAllowed("includeDig") then table.insert(includeItems, { label = "[ ] Dig", mode = "toggleDig" }) end
            if featureAllowed("includeTreat") then table.insert(includeItems, { label = "[X] Treat", mode = "toggleTreat" }) end
            table.insert(includeItems, { label = "[X] Water", mode = "toggleWater" })

            local row = {}
            for _, item in ipairs(includeItems) do
                table.insert(row, item)
                if #row == 3 then
                    y = self:addButtonRow(row, x, y, w, h, gap)
                    row = {}
                end
            end
            if #row > 0 then y = self:addButtonRow(row, x, y, w, h, gap) end
            y = y + 4

            if ISLabel then
                local label = ISLabel:new(x, y + 3, h, "Furrow Pattern", 1, 1, 1, 1, UIFont.Small, true)
                label:initialise()
                self:addChild(label)
            end
            y = y + h

            local highlightWidth = 96
            local comboWidth = w - highlightWidth - gap
            if ISComboBox then
                self.patternCombo = ISComboBox:new(x, y, comboWidth, h, self, WindowClass.onPatternChanged)
                self.patternCombo:initialise()
                self.patternCombo:instantiate()
                for _, name in ipairs(AW.furrowPatternNames) do self.patternCombo:addOption(name) end
                for index, name in ipairs(AW.furrowPatternNames) do
                    if name == self.patternName then self.patternCombo.selected = index end
                end
                self:addChild(self.patternCombo)
                self:addButton("[X] Highlight", "toggleFurrowHighlight", x + comboWidth + gap, y, highlightWidth, h)
            else
                self:addButton("Pattern: " .. tostring(self.patternName), "cyclePattern", x, y, comboWidth, h)
                self:addButton("[X] Highlight", "toggleFurrowHighlight", x + comboWidth + gap, y, highlightWidth, h)
            end
            y = y + h + 10

            local thirdGap = 5
            local thirdWidth = math.floor((w - (thirdGap * 2)) / 3)
            local removePlots = self:addButton("Remove Plots", "removePlots", x, y, thirdWidth, h)
            local removeReceding = self:addButton("Remove Receding", "removeReceding", x + thirdWidth + thirdGap, y, thirdWidth, h)
            local removePlants = self:addButton("Remove Plants", "removePlants", x + (thirdWidth + thirdGap) * 2, y, thirdWidth, h)
            self:makeRedButton(removePlots)
            self:makeRedButton(removeReceding)
            self:makeRedButton(removePlants)
            y = y + h + 8

            local removeAll = self:addButton("Remove All", "removeAll", x, y, w, h)
            self:makeRedButton(removeAll)
            y = y + h + 12

            self:addButton("Close", "close", x, y, w, h)
            y = y + h + 10
            self.height = math.max(205, y)
            if self.setHeight then pcall(function() self:setHeight(self.height) end) end
            if self.resizeWidget then pcall(function() self.resizeWidget:setVisible(false) end) end
            self:updateCheckboxLabels()
            self:refreshHighlight()
            if AW.applyTooltipsToWindow then AW.applyTooltipsToWindow(self) end
        end

        local openAutoFarmUICurrent = AW.openAutoFarmUI
        function AW.openAutoFarmUI(playerNum, collector)
            AW.applySandboxSettings()
            local playerObj = playerFor(playerNum)
            if not AW.isPlayerInAutoFarmRange(playerObj, collector) then
                if playerObj then playerObj:Say("I need to get closer to the farm.") end
                return
            end
            return openAutoFarmUICurrent(playerNum, collector)
        end

        local function tooltipFor(text)
            local tooltip = nil
            if ISWorldObjectContextMenu and ISWorldObjectContextMenu.addToolTip then
                pcall(function() tooltip = ISWorldObjectContextMenu.addToolTip() end)
            end
            if not tooltip and ISToolTip then
                tooltip = ISToolTip:new()
                tooltip:initialise()
                tooltip:setVisible(false)
            end
            if tooltip then tooltip.description = text end
            return tooltip
        end

        local function markUnavailable(option)
            if not option then return end
            option.notAvailable = true
            local tooltip = tooltipFor("Get closer to the water collector to use Auto-Farm.")
            option.toolTip = tooltip
            option.tooltip = tooltip
            option.color = { r = 1.0, g = 0.1, b = 0.1, a = 1.0 }
            option.textColor = { r = 1.0, g = 0.1, b = 0.1, a = 1.0 }
        end

        function AW.addBlockedAutoFarmOption(playerNum, context, collector)
            local option = context:addOption("Auto-Farm", AW, function()
                local playerObj = playerFor(playerNum)
                if playerObj then playerObj:Say("I need to get closer to the farm.") end
            end)
            markUnavailable(option)
            if context.getNew and context.addSubMenu then
                local subMenu = context:getNew(context)
                context:addSubMenu(option, subMenu)
                local closer = subMenu:addOption("Get closer", nil, function()
                    local playerObj = playerFor(playerNum)
                    if playerObj then playerObj:Say("I need to get closer to the farm.") end
                end)
                markUnavailable(closer)
            end
            return option
        end

        local contextCurrent = AW.onContext
        if Events and Events.OnFillWorldObjectContextMenu then
            pcall(function() Events.OnFillWorldObjectContextMenu.Remove(contextCurrent) end)
        end
        function AW.onContext(playerNum, context, worldobjects, isTest)
            if isTest then return end
            AW.applySandboxSettings()
            if AW.ENABLED == false then return end
            local collector = AW.findCollectorFromWorldObjects and AW.findCollectorFromWorldObjects(worldobjects) or nil
            if not collector then return end
            local playerObj = playerFor(playerNum)
            if not AW.isPlayerInAutoFarmRange(playerObj, collector) then
                AW.addBlockedAutoFarmOption(playerNum, context, collector)
                return
            end
            context:addOption("Auto-Farm", AW, function() AW.openAutoFarmUI(playerNum, collector) end)
        end
        if Events and Events.OnFillWorldObjectContextMenu then
            Events.OnFillWorldObjectContextMenu.Add(AW.onContext)
        end

        local playerUpdateCurrent = AW.onPlayerUpdate
        if Events and Events.OnPlayerUpdate then
            pcall(function() Events.OnPlayerUpdate.Remove(playerUpdateCurrent) end)
        end
        function AW.onPlayerUpdate(playerObj)
            if playerUpdateCurrent then playerUpdateCurrent(playerObj) end
            if playerObj ~= getPlayer() then return end
            if AW.job and AW.job.active then return end
            local win = AW.autoFarmWindow
            if not win or not win.collector then return end
            if distanceToCollector(playerObj, win.collector) > AW.autoFarmUseRange() then
                AW.closeAutoFarmWindow(win)
            end
        end
        if Events and Events.OnPlayerUpdate then Events.OnPlayerUpdate.Add(AW.onPlayerUpdate) end
        AW.applySandboxSettings()
    end
end

ParadiseZ = ParadiseZ or {}
ParadiseZ.PlayerUtil = ParadiseZ.PlayerUtil or {}
ParadiseZ.PlayerUtil.AutoFarm = ParadiseZ_AutoFarm
