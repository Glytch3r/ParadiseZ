

Events.OnGameBoot.Add(function()
	TraitFactory.addTrait("TheRangeStaff", getText("UI_trait_TheRangeStaff"), 0, getText("UI_trait_TheRangeStaff_desc"), true) 

	local traitStr = "PvE"
	TraitFactory.addTrait(traitStr, getText("UI_trait_"..traitStr), -1, getText("UI_trait_"..traitStr.."Desc"), false)
	TraitFactory.sortList()
	local traits = TraitFactory.getTraits()
	for i=0, traits:size()-1 do
		local trait = traits:get(i)
		BaseGameCharacterDetails.SetTraitDescription(trait)
	end
end)