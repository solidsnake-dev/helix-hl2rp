PLUGIN.name = "Willard Clothing"
PLUGIN.author = "You"
PLUGIN.description = "Bulk-registers PAC3-attached clothing items from Willard Networks V1 Models."

local MODEL_PATH = "models/willardnetworks/clothingitems/"

-- Default bone per clothing category - these are guesses at standard Source biped bone
-- names. If a piece sits wrong or doesn't attach at all in-game, this bone name (or the
-- Position/Angles below) is the first thing to check/adjust via PAC3's own editor.
local CATEGORY_BONES = {
	torso = "ValveBiped.Bip01_Spine2",
	legs = "ValveBiped.Bip01_Pelvis",
	shoes = "ValveBiped.Bip01_Pelvis",
	head = "ValveBiped.Bip01_Head1",
	hands = "ValveBiped.Bip01_L_Hand",
	accessory = "ValveBiped.Bip01_Spine2",
}

local function BuildPacData(model, bone)
	return {
		[1] = {
			["children"] = {
				[1] = {
					["children"] = {},
					["self"] = {
						["ClassName"] = "model",
						["UniqueID"] = tostring(math.random(100000000, 999999999)),
						["Model"] = model,
						["Bone"] = bone,
						["Position"] = Vector(0, 0, 0),
						["Angles"] = Angle(0, 0, 0),
						["Size"] = 1,
					},
				},
			},
			["self"] = {
				["ClassName"] = "group",
				["UniqueID"] = tostring(math.random(100000000, 999999999)),
				["EditorExpand"] = true,
			},
		},
	}
end

-- {uniqueID, display name, model filename, category}
local CLOTHING_ITEMS = {
	-- Accessories
	{"backpack", "Backpack", "backpack.mdl", "accessory"},
	{"glasses", "Glasses", "glasses.mdl", "head"},
	{"satchel", "Satchel", "satchel.mdl", "accessory"},
	{"gloves", "Gloves", "hands_glove.mdl", "hands"},
	{"gloves_fingerless", "Fingerless Gloves", "hands_glove_fingerless.mdl", "hands"},

	-- Head
	{"beanie_blue", "Blue Beanie", "head_beanie_blue.mdl", "head"},
	{"beanie_green", "Green Beanie", "head_beanie_green.mdl", "head"},
	{"boonie_hat", "Boonie Hat", "head_boonie.mdl", "head"},
	{"chef_hat", "Chef's Hat", "head_chefhat.mdl", "head"},
	{"confederate_hat", "Confederate Hat", "head_confederatehat.mdl", "head"},
	{"facewrap", "Face Wrap", "head_facewrap.mdl", "head"},
	{"gasmask_civ", "Gas Mask", "head_gasmask.mdl", "head"},
	{"hat1", "Hat", "head_hat.mdl", "head"},
	{"hat2", "Hat", "head_hat2.mdl", "head"},
	{"helmet_civ", "Helmet", "head_helmet.mdl", "head"},

	-- Legs
	{"legs_ca1", "Combine Authority Pants", "legs_ca_1.mdl", "legs"},
	{"legs_ca2", "Combine Authority Pants", "legs_ca_2.mdl", "legs"},
	{"legs_ca3", "Combine Authority Pants", "legs_ca_3.mdl", "legs"},
	{"legs_citizen0", "Citizen Pants", "legs_citizen0.mdl", "legs"},
	{"legs_citizen1", "Citizen Pants", "legs_citizen1.mdl", "legs"},
	{"legs_citizen2", "Citizen Pants", "legs_citizen2.mdl", "legs"},
	{"legs_citizen3", "Citizen Pants", "legs_citizen3.mdl", "legs"},
	{"legs_rebel1", "Resistance Pants", "legs_rebel1.mdl", "legs"},
	{"legs_rebel2", "Resistance Pants", "legs_rebel2.mdl", "legs"},
	{"legs_rebel3", "Resistance Pants", "legs_rebel3.mdl", "legs"},

	-- Shoes
	{"shoes_black", "Black Shoes", "shoes_black.mdl", "shoes"},
	{"shoes_blue", "Blue Shoes", "shoes_blue.mdl", "shoes"},
	{"shoes_booties", "Booties", "shoes_booties.mdl", "shoes"},
	{"shoes_boots", "Boots", "shoes_boots.mdl", "shoes"},
	{"shoes_brown", "Brown Shoes", "shoes_brown.mdl", "shoes"},
	{"shoes_formal", "Formal Shoes", "shoes_formal.mdl", "shoes"},
	{"shoes_military", "Military Boots", "shoes_military.mdl", "shoes"},

	-- Torso
	{"alyxcoat1", "Coat", "torso_alyxcoat1.mdl", "torso"},
	{"alyxcoat2", "Coat", "torso_alyxcoat2.mdl", "torso"},
	{"alyxcoat3", "Coat", "torso_alyxcoat3.mdl", "torso"},
	{"alyxcoat_black", "Black Coat", "torso_alyxcoat7_black.mdl", "torso"},
	{"alyxcoat_blue", "Blue Coat", "torso_alyxcoat7_blue.mdl", "torso"},
	{"alyxcoat_white", "White Coat", "torso_alyxcoat7_white.mdl", "torso"},
	{"torso_ca2", "Combine Authority Jacket", "torso_ca_2.mdl", "torso"},
	{"torso_ca3", "Combine Authority Jacket", "torso_ca_3.mdl", "torso"},
	{"torso_ca4", "Combine Authority Jacket", "torso_ca_4.mdl", "torso"},
	{"torso_citizen1", "Citizen Shirt", "torso_citizen1.mdl", "torso"},
	{"torso_citizen2", "Citizen Shirt", "torso_citizen2.mdl", "torso"},
	{"torso_medic", "Medic Uniform", "torso_citizen_medic.mdl", "torso"},
	{"torso_refugee", "Refugee Clothes", "torso_citizen_refugee.mdl", "torso"},
	{"torso_loyalist", "Loyalist Attire", "torso_loyalist.mdl", "torso"},
	{"torso_rebel1", "Resistance Jacket", "torso_rebel01.mdl", "torso"},
	{"torso_rebel2", "Resistance Jacket", "torso_rebel02.mdl", "torso"},
	{"torso_rebel_medic", "Resistance Medic Uniform", "torso_rebelmedic.mdl", "torso"},
	{"torso_refugee_coat", "Refugee Coat", "torso_refugee_coat.mdl", "torso"},
	{"torso_worker1", "Worker Uniform", "torso_worker1.mdl", "torso"},
	{"torso_worker2", "Worker Uniform", "torso_worker2.mdl", "torso"},

	-- update_items (newer additions in the pack)
	{"armor_vest1", "Armored Vest", "../update_items/armor01_item.mdl", "torso"},
	{"armor_vest3", "Armored Vest", "../update_items/armor03_item.mdl", "torso"},
	{"ca_jacket1", "Combine Authority Jacket", "../update_items/cajacket1_item.mdl", "torso"},
	{"ca_jacket2", "Combine Authority Jacket", "../update_items/cajacket2_item.mdl", "torso"},
	{"fedora", "Fedora", "../update_items/fedora_item.mdl", "head"},
	{"jacket1", "Jacket", "../update_items/jacket01_item.mdl", "torso"},
	{"medic_mask", "Medic Mask", "../update_items/medicmask_item.mdl", "head"},
	{"peacoat", "Peacoat", "../update_items/peacoat_item.mdl", "torso"},
	{"redcoat", "Red Coat", "../update_items/redcoat_item.mdl", "torso"},
	{"wintercoat", "Winter Coat", "../update_items/wintercoat_item.mdl", "torso"},
	{"worker_cap", "Worker's Cap", "../update_items/workercap_item.mdl", "head"},
}

for _, data in ipairs(CLOTHING_ITEMS) do
	local uniqueID, name, model, category = data[1], data[2], data[3], data[4]
	local fullModel = MODEL_PATH .. model
	local ITEM = ix.item.Register(uniqueID, "base_pacoutfit", nil, nil, true)

	ITEM.name = name
	ITEM.description = "A piece of clothing - " .. name:lower() .. "."
	ITEM.category = "Clothing"
	ITEM.outfitCategory = category
	ITEM.pacData = BuildPacData(fullModel, CATEGORY_BONES[category])
end
