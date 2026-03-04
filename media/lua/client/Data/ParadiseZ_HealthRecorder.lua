ParadiseZ = ParadiseZ or {}
function ParadiseZ.saveHealthStats(pl)
    pl = pl or getPlayer()
    if not pl then return end
    local body = pl:getBodyDamage()
    local stats = pl:getStats()
    local nutrition = pl:getNutrition()
    local data = pl:getModData()
    local record = {}

    record.Hunger = stats:getHunger()
    record.Thirst = stats:getThirst()
    record.Fatigue = stats:getFatigue()
    record.Endurance = stats:getEndurance()
    record.Fitness = pl:getPerkLevel(Perks.Fitness)
    record.Drunkenness = stats:getDrunkenness()
    record.Pain = stats:getPain()
    record.Panic = stats:getPanic()
    record.Stress = stats:getStress()
    record.StressFromCigarettes = stats:getStressFromCigarettes()
    record.TimeSinceLastSmoke = pl:getTimeSinceLastSmoke()
    record.BoredomLevel = body:getBoredomLevel()
    record.UnhappynessLevel = body:getUnhappynessLevel()
    record.OverallBodyHealth = body:getOverallBodyHealth()
    record.Sickness = stats:getSickness()
    record.InfectionLevel = body:getInfectionLevel()
    record.FakeInfectionLevel = body:getFakeInfectionLevel()
    record.FoodSicknessLevel = body:getFoodSicknessLevel()
    record.Calories = nutrition:getCalories()
    record.Weight = nutrition:getWeight()
    record.IsInfected = body:IsInfected()
    record.IsFakeInfected = body:IsFakeInfected()
    record.IsOnFire = body:IsOnFire()

    data["HealthRecord"] = data["HealthRecord"] or {}
    data["HealthRecord"].Stats = record
end

function ParadiseZ.saveHealthInjury(pl)
    pl = pl or getPlayer()
    local modData = pl:getModData()
    modData.HealthRecord = modData.HealthRecord or {}
    modData.HealthRecord.Injuries = {}

    local bodyParts = pl:getBodyDamage():getBodyParts()
    for i = 0, bodyParts:size() - 1 do
        local part = bodyParts:get(i)
        if ParadiseZ.hasInjury(part) then
            local bpData = {}
            bpData.Bandaged = part:bandaged() and true or nil
            bpData.Stitched = part:stitched() and true or nil
            bpData.SplintFactor = part:getSplintFactor() or nil
            bpData.AdditionalPain = part:getAdditionalPain() or nil
            bpData.Stiffness = part:getStiffness() or nil
            bpData.ScratchTime = part:getScratchTime() or nil
            bpData.Cut = part:isCut() and true or nil
            bpData.DeepWounded = part:isDeepWounded() and true or nil
            bpData.DeepWoundTime = part:getDeepWoundTime() or nil
            bpData.Bitten = part:bitten() and true or nil
            bpData.InfectedWound = part:isInfectedWound() and true or nil
            bpData.FakeInfected = part:IsFakeInfected() and true or nil
            bpData.BleedingTime = part:getBleedingTime() or nil
            bpData.InfectedWound = part:isInfectedWound() and true or nil
            bpData.HaveBullet = part:haveBullet() and true or nil
            bpData.HaveGlass = part:haveGlass() and true or nil
            bpData.FractureTime = part:getFractureTime() or nil
            bpData.BurnTime = part:getBurnTime() or nil

            modData.HealthRecord.Injuries[part:getType()] = bpData
        end
    end
end

-----------------------            ---------------------------

function ParadiseZ.restoreHealthInjury(pl)
    pl = pl or getPlayer()
    local modData = pl:getModData()
    if not modData.HealthRecord or not modData.HealthRecord.Injuries then return end

    local bodyParts = pl:getBodyDamage():getBodyParts()
    for i = 0, bodyParts:size() - 1 do
        local part = bodyParts:get(i)
        local saved = modData.HealthRecord.Injuries[part:getType()]
        if saved then
            if saved.Bandaged then part:setBandaged(true) end
            if saved.Stitched then part:setStitched(true) end
            if saved.SplintFactor then part:setSplintFactor(saved.SplintFactor) end
            if saved.AdditionalPain then part:setAdditionalPain(saved.AdditionalPain) end
            if saved.Stiffness then part:setStiffness(saved.Stiffness) end
            if saved.ScratchTime then
                part:setScratched(true, true)
                part:setScratchTime(saved.ScratchTime)
            end
            if saved.Cut then
                part:setCut(true)
                part:setCutTime(saved.CutTime or 0)
            end
            if saved.DeepWounded then
                part:setDeepWounded(true)
                part:setDeepWoundTime(saved.DeepWoundTime or 0)
            end
            if saved.Bitten ~= nil then part:SetBitten(saved.Bitten) end
            if saved.InfectedWound ~= nil then part:SetInfected(saved.InfectedWound) end
            if saved.FakeInfected ~= nil then part:SetFakeInfected(saved.FakeInfected) end
            if saved.BleedingTime then part:setBleedingTime(saved.BleedingTime) end
            if saved.HaveBullet then part:setHaveBullet(saved.HaveBullet, 0) end
            if saved.HaveGlass then part:setHaveGlass(saved.HaveGlass) end
            if saved.FractureTime then part:setFractureTime(saved.FractureTime) end
            if saved.BurnTime then part:setBurnTime(saved.BurnTime) end
        end
    end
end


function ParadiseZ.restoreHealthStats(pl)
     pl = pl or getPlayer()

    if not pl then return end
    local data = pl:getModData()
    local record = data["HealthRecord"]
    if not record then return end

    local body = pl:getBodyDamage()
    local stats = pl:getStats()
    local nutrition = pl:getNutrition()

    if record.Stats then
        local s = record.Stats
        stats:setHunger(s.Hunger or 0)
        stats:setThirst(s.Thirst or 0)
        stats:setFatigue(s.Fatigue or 0)
        stats:setEndurance(s.Endurance or 0)
        pl:setPerkLevelDebug(Perks.Fitness, s.Fitness or 0)
        stats:setDrunkenness(s.Drunkenness or 0)
        stats:setPain(s.Pain or 0)
        stats:setPanic(s.Panic or 0)
        stats:setStress(s.Stress or 0)
        stats:setStressFromCigarettes(s.StressFromCigarettes or 0)
        pl:setTimeSinceLastSmoke(s.TimeSinceLastSmoke or 0)
        body:setBoredomLevel(s.BoredomLevel or 0)
        body:setUnhappynessLevel(s.UnhappynessLevel or 0)
        body:AddGeneralHealth((s.OverallBodyHealth or 100) - body:getOverallBodyHealth())
        stats:setSickness(s.Sickness or 0)
        body:setInfectionLevel(s.InfectionLevel or 0)
        body:setFakeInfectionLevel(s.FakeInfectionLevel or 0)
        body:setFoodSicknessLevel(s.FoodSicknessLevel or 0)
        nutrition:setCalories(s.Calories or 0)
        nutrition:setWeight(s.Weight or 80)
        body:setInfected(s.IsInfected or false)
        body:setIsFakeInfected(s.IsFakeInfected or false)
        body:setIsOnFire(s.IsOnFire or false)
    end
end

-----------------------            ---------------------------

function ParadiseZ.dopRecordHealth(pl)
    pl = pl or getPlayer()
    if not pl then return end
    ParadiseZ.saveHealthStats(pl)
    ParadiseZ.saveHealthInjury(pl)    
end

function ParadiseZ.doRestoreHealth(pl)
    pl = pl or getPlayer()
    if not pl then return end
    if ParadiseZ.hasHealthRecord(pl) then
        ParadiseZ.restoreHealthStats(pl)
        ParadiseZ.restoreHealthInjury(pl)
        ParadiseZ.clearHealthRecord(pl)
    else
        print('has no Health Record')
    end
    
end


function ParadiseZ.clearHealthRecord(pl)
    pl = pl or getPlayer()
    if not pl then return end
    pl:getModData()["HealthRecord"] = nil
end

function ParadiseZ.hasHealthRecord(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    local data = pl:getModData()
    return data["HealthRecord"] ~= nil 
end