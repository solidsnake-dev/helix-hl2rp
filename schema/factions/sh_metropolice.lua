FACTION.name = "Metropolice Force"
FACTION.description = "A metropolice unit working as Civil Protection."
FACTION.color = Color(50, 100, 150)
FACTION.pay = 10
FACTION.weapons = {"ix_stunstick"}
FACTION.isDefault = false
FACTION.isGloballyRecognized = true
FACTION.runSounds = {[0] = "NPC_MetroPolice.RunFootstepLeft", [1] = "NPC_MetroPolice.RunFootstepRight"}

-- wn7new pack - unmasked faces, so masks are worn separately via the worn-attachments system
FACTION.models = {
	"models/wn7new/metropolice/male_01.mdl", "models/wn7new/metropolice/male_02.mdl",
	"models/wn7new/metropolice/male_03.mdl", "models/wn7new/metropolice/male_04.mdl",
	"models/wn7new/metropolice/male_05.mdl", "models/wn7new/metropolice/male_06.mdl",
	"models/wn7new/metropolice/male_07.mdl", "models/wn7new/metropolice/male_08.mdl",
	"models/wn7new/metropolice/male_09.mdl", "models/wn7new/metropolice/male_10.mdl",
	"models/wn7new/metropolice/female_01.mdl", "models/wn7new/metropolice/female_02.mdl",
	"models/wn7new/metropolice/female_03.mdl", "models/wn7new/metropolice/female_04.mdl",
	"models/wn7new/metropolice/female_06.mdl", "models/wn7new/metropolice/female_07.mdl",
}

-- Which gas mask variant each rank wears. My assumption: lower/mid ranks are masked (standard
-- issue), 80/RL go unmasked as a "senior officer shows their face" status thing, RC gets the
-- elite mask variant back. Flip any of these to nil/another variant if that's not what you want.
local RANK_MASKS = {
	["00"] = "models/wn7new/metropolice/n7_cp_gasmask1.mdl",
	["20"] = "models/wn7new/metropolice/n7_cp_gasmask1.mdl",
	["40"] = "models/wn7new/metropolice/n7_cp_gasmask1.mdl",
	["60"] = "models/wn7new/metropolice/n7_cp_gasmask1.mdl",
	["80"] = "models/wn7new/metropolice/n7_cp_gasmask1.mdl",
	["RL"] = "models/wn7new/metropolice/n7_cp_gasmask1.mdl",
	["RC"] = "models/wn7new/metropolice/n7_cp_gasmask1.mdl",
}

-- ===================================================================
-- Custom rank progression. Ranks are read from the character's name,
-- e.g. "MPF-60.00042" = rank "60". GetDefaultName/OnTransferred below
-- put new recruits at rank "00" automatically.
--
-- NOTE: "pistol", "smg1", "shotgun", "357" below are your edited stock
-- items (now pointing at TFA classes). Only "tfa_hl2_oicw" is still a
-- separate new item, since HL2 has no stock OICW to repurpose.
-- ===================================================================

local RANK_ORDER = {"00", "20", "40", "60", "80", "RL", "RC"}

-- Bodygroup name -> value per rank. Any bodygroup not listed here is reset to 0.
local RANK_BODYGROUPS = {
	["00"] = {},
	["20"] = {},
	["40"] = {},
	["60"] = {["Cp Body"] = 8, ["Cp Belt"] = 1},
	["80"] = {["Cp Body"] = 9, ["Cp Belt"] = 1, ["Cp Bag"] = 1, ["Base"] = 1},
	["RL"] = {["Cp Body"] = 2, ["Cp Belt"] = 1, ["Cp Bag"] = 1, ["Base"] = 1, ["Satchel"] = 1},
	["RC"] = {["Cp Body"] = 16, ["Cp Belt"] = 1, ["Cp Bag"] = 1, ["Base"] = 1}
}

-- Full item set per rank, using your ACTUAL item uniqueIDs.
local RANK_ITEMS = {
	["00"] = {"pistol"},
	["20"] = {"pistol"},
	["40"] = {"pistol"},
	["60"] = {"pistol", "smg1"},
	["80"] = {"pistol", "shotgun"},
	["RL"] = {"357", "shotgun"},
	["RC"] = {"357", "tfa_hl2_oicw"}
}

local ALL_TRACKED_ITEMS = {"pistol", "smg1", "shotgun", "357", "tfa_hl2_oicw"}

local function ApplyRankBodygroups(client, rankCode)
	local groups = RANK_BODYGROUPS[rankCode] or {}

	for _, info in ipairs(client:GetBodyGroups()) do
		client:SetBodygroup(info.id, groups[info.name] or 0)
	end
end

local function ApplyRankMask(client, rankCode)
	Schema:SetPlayerAttachment(client, "mask", RANK_MASKS[rankCode])
end

local function ApplyRankLoadout(character, rankCode)
	local inventory = character:GetInventory()
	local client = character:GetPlayer()
	local target = RANK_ITEMS[rankCode] or {}

	for _, uniqueID in ipairs(ALL_TRACKED_ITEMS) do
		for _, item in ipairs(inventory:GetItemsByUniqueID(uniqueID, true)) do
			if (item:GetData("equip")) then
				item:Unequip(client, false, true)
			else
				item:Remove()
			end
		end
	end

	for _, uniqueID in ipairs(target) do
		inventory:Add(uniqueID, 1)
	end
end

function FACTION:OnCharacterCreated(client, character)
	local inventory = character:GetInventory()

	-- "pistol" itself is granted through the rank system below (rank "00"), not here -
	-- only the ammo stays as a flat starting grant.
	inventory:Add("pistolammo", 2)
end

function FACTION:GetDefaultName(client)
	return "MPF-00." .. Schema:ZeroNumber(math.random(1, 99999), 5), true
end

function FACTION:OnTransferred(character)
	character:SetName(self:GetDefaultName())
	character:SetModel(self.models[math.random(1, #self.models)])

	local client = character:GetPlayer()

	if (IsValid(client)) then
		ApplyRankBodygroups(client, "00")
		ApplyRankMask(client, "00")
	end

	ApplyRankLoadout(character, "00")
end

function FACTION:OnNameChanged(client, oldValue, value)
	local character = client:GetCharacter()
	local oldRank, newRank

	for _, code in ipairs(RANK_ORDER) do
		if (Schema:IsCombineRank(oldValue, code)) then oldRank = code end
		if (Schema:IsCombineRank(value, code)) then newRank = code end
	end

	if (newRank and newRank != oldRank) then
		ApplyRankBodygroups(client, newRank)
		ApplyRankMask(client, newRank)
		ApplyRankLoadout(character, newRank)
	end
end

FACTION_MPF = FACTION.index
