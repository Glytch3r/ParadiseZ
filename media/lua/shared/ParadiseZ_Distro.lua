require "Items/Distributions"
require "Items/ProceduralDistributions"
require "SuburbsDistributions"

local locations = {
	["CrateCostume"] = {obj = "ParadiseZ.Jacket_TheRange", rate = 4},
    ["CrateClothesRandom"] = {obj = "ParadiseZ.Jacket_TheRange", rate = 4},
	["HuntingLockers"] = {obj = "ParadiseZ.Jacket_TheRange", rate = 5},

	["BinDumpster"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 1},
	["SafehouseArmor"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 1},
	["SchoolLockers"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 1},

	["LaundryCleaning"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 15},
	["LaundryHospital"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 15},
	["LaundryLoad1"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 15},
	["LaundryLoad2"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 15},
	["LaundryLoad3"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 15},
	["LaundryLoad4"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 15},
	["LaundryLoad5"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 15},
	["LaundryLoad6"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 15},
	["LaundryLoad7"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 15},
	["LaundryLoad8"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 15},
	["GymLaundry"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 15},

	["ArmyHangarOutfit"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["ArmyStorageOutfit"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["ArmySurplusOutfit"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["BandMerchClothes"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["BathroomCabinet"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["BowlingAlleyLockers"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["CampingLockers"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["ClosetShelfGeneric"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["ClothingPoor"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["ClothingStorageAllShirts"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["ClothingStoresGloves"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["ClothingStoresShirts"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["ClothingStoresWoman"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["CrateClothesRandom"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["CrateCostume"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["CrateMetalLockers"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["DresserGeneric"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["DrugLabOutfit"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["FactoryLockers"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["FireDeptLockers"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["FireStorageOutfit"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["GolfLockers"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["GymLockers"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["HospitalLockers"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["HuntingLockers"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["LingerieStoreOutfits"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["Locker"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["LockerArmyBedroom"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["MechanicShelfOutfit"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["MedicalClinicOutfit"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["MedicalStorageOutfit"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["MorgueChemicals"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["MorgueOutfit"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["PoliceStorageOutfit"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["PoolLockers"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["PrisonGuardLockers"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["StripClubDressers"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["WardrobeChild"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["WardrobeMan"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["WardrobeManClassy"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["WardrobeRedneck"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["WardrobeWoman"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["WardrobeWomanClassy"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},
	["ZippeeClothing"] = {obj = "ParadiseZ.Shirt_ParadiseZ", rate = 5},

	["Locker"] = {obj = "ParadiseZ.HoodieDOWN_ParadiseZ", rate = 5},
	["DresserGeneric"] = {obj = "ParadiseZ.HoodieDOWN_ParadiseZ", rate = 5},
	["ClosetShelfGeneric"] = {obj = "ParadiseZ.HoodieDOWN_ParadiseZ", rate = 5},



	--ParadiseZ.Jacket_JimAdmin
}

Events.OnPostDistributionMerge.Add(function()
	for k, v in pairs(locations) do
		table.insert(ProceduralDistributions.list[k].items, tostring(v.obj))
		table.insert(ProceduralDistributions.list[k].items, v.rate)
	end
end)

