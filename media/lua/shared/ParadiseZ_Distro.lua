require "Items/Distributions"
require "Items/ProceduralDistributions"
require "SuburbsDistributions"

local locations = {
	["CrateCostume"] = {obj = "ParadiseZ.Shirt_TheRange", rate = 4},
    ["CrateClothesRandom"] = {obj = "ParadiseZ.Shirt_TheRange", rate = 4},
}

Events.OnPostDistributionMerge.Add(function()
	for k, v in pairs(locations) do
		table.insert(ProceduralDistributions.list[k].items, tostring(v.obj))
		table.insert(ProceduralDistributions.list[k].items, v.rate)
	end
end)
