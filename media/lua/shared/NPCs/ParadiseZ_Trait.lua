

Events.OnGameBoot.Add(function()

	--TraitFactory.addTrait("TheRangeStaff", getText("UI_trait_TheRangeStaff"), 0, getText("UI_trait_TheRangeStaff_desc"), true) 

	local traitStr = "TheRangeStaff"
	TraitFactory.addTrait(traitStr, getText("UI_trait_"..traitStr), 0, getText("UI_trait_"..traitStr.."_desc"), true)

	local traitStr = "PvE"
	TraitFactory.addTrait(traitStr, getText("UI_trait_"..traitStr), -1, getText("UI_trait_"..traitStr.."_desc"), false)

	local traitStr = "Caged"
	TraitFactory.addTrait(traitStr, getText("UI_trait_"..traitStr), 0, getText("UI_trait_"..traitStr.."_desc"), true)

	TraitFactory.sortList()
	local traits = TraitFactory.getTraits()
	for i=0, traits:size()-1 do
		local trait = traits:get(i)
		BaseGameCharacterDetails.SetTraitDescription(trait)
	end
end)