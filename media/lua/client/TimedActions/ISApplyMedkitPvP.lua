
require "TimedActions/ISBaseTimedAction"

ISApplyMedkitPvP = ISBaseTimedAction:derive("ISApplyMedkitPvP");

function ISApplyMedkitPvP:isValid()
    if self.item then
        return self.character:getInventory():contains(self.item) and self.character:HasTrait('InjuredPvP')
    end
end

function ISApplyMedkitPvP:update()
    if self.item then
        self.item:setJobDelta(self:getJobDelta());
    end
    self.character:setMetabolicTarget(Metabolics.LightDomestic);
end

function ISApplyMedkitPvP:start()

    self:setActionAnim("Loot")
    self:setAnimVariable("LootPosition", "Mid");
    self.character:SetVariable("LootPosition", "Mid")
    self.character:reportEvent("EventLootItem");
    self:setOverrideHandModels(nil, nil);
    if self.item then
        self.item:setJobType(getText("ContextMenu_Apply_Bandage"));
        self.item:setJobDelta(0.0);
    end
end

function ISApplyMedkitPvP:stop()
    ISBaseTimedAction.stop(self);
    if self.item then
        self.item:setJobDelta(0.0);
    end
end

function ISApplyMedkitPvP:perform()
    ISBaseTimedAction.perform(self);
    if self.item then
        self.item:setJobDelta(0.0);
    end

    if self.character:HasTrait('InjuredPvP') then  
        self.character:getTraits():remove('InjuredPvP') 
    end
    
    local md = self.character:getModData()
    if md and md.LifePoints then
        md.LifePoints = math.min(100, md.LifePoints + SandboxVars.ParadiseZpvp.MedkitHeal)
    end
    
    self.character:getXp():AddXP(Perks.Doctor, 5);
    self.character:getInventory():Remove(self.item);
end

function ISApplyMedkitPvP:new(doctor, item)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = doctor;
    o.doctorLevel = doctor:getPerkLevel(Perks.Doctor);
	o.item = item;
	o.stopOnWalk = true
	o.stopOnRun = true;
    o.maxTime = 120 - (o.doctorLevel * 4);
    if doctor:isTimedActionInstant() then
        o.maxTime = 1;
        o.doctorLevel = 10;
    end
	return o;
end
