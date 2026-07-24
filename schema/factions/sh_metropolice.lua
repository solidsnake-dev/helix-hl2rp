FACTION.name = "Metropolice Force"
FACTION.description = "A metropolice unit working as Civil Protection."
FACTION.color = Color(50, 100, 150)
FACTION.pay = 10
FACTION.models = {"models/z1zackmpf/male04/willardmetrocop.mdl"}
FACTION.weapons = {"ix_stunstick"}
FACTION.isDefault = false
FACTION.isGloballyRecognized = true
FACTION.runSounds = {[0] = "NPC_MetroPolice.RunFootstepLeft", [1] = "NPC_MetroPolice.RunFootstepRight"}

-- ===================================================================
-- Custom rank progression. Ranks are read from the character's name,
-- e.g. "MPF-60.00042" = rank "60". GetDefaultName/OnTransferred below
-- put new recruits at rank "00" automatically.
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

-- Every bodygroup name that exists on the model, so we can zero out anything not set above.
local ALL_BODYGROUPS = {"Base", "Cp Body", "Cp Head", "Cp Armor", "Cp Belt", "Cp Pants", "Cp Bag", "Satchel"}

-- TFA items each rank should have equipped, IN ADDITION to the base pistol/pistolammo/stunstick
-- every MPF member already gets (those are handled elsewhere and never touched here).
-- These uniqueIDs must match real Helix item files you've created (e.g. from the tfa_weapons plugin) -
-- if an item doesn't exist yet, inventory:Add() just silently does nothing, it won't error.
local RANK_ITEMS = {
	["00"] = {},
	["20"] = {"tfa_hl2r_pistol"},
	["40"] = {"tfa_hl2r_pistol"},
	["60"] = {"tfa_hl2r_pistol", "tfa_hl2r_smg1"},
	["80"] = {"tfa_hl2r_pistol", "tfa_hl2r_shotgun"}, -- written as "same as 20 + shotgun" - change to
	                                                    -- {"tfa_hl2r_pistol", "tfa_hl2r_smg1", "tfa_hl2r_shotgun"}
	                                                    -- if 80 should keep the SMG from 60 too
	["RL"] = {"tfa_hl2r_357", "tfa_hl2r_shotgun"},
	["RC"] = {"tfa_hl2r_357", "tfa_hl2_oicw"}
}

-- Every TFA item that appears ANYWHERE above, so promotions/demotions can wipe old rank gear
-- before granting the new set (prevents gear from stacking up across promotions).
local ALL_TRACKED_ITEMS = {"tfa_hl2r_pistol", "tfa_hl2r_smg1", "tfa_hl2r_shotgun", "tfa_hl2r_357", "tfa_hl2_oicw"}

local function ApplyRankBodygroups(client, rankCode)
	local groups = RANK_BODYGROUPS[rankCode] or {}

	for _, name in ipairs(ALL_BODYGROUPS) do
		local index = client:FindBodygroupByName(name)

		if (index != -1) then
			client:SetBodygroup(index, groups[name] or 0)
		end
	end
end

local function ApplyRankLoadout(character, rankCode)
	local inventory = character:GetInventory()
	local client = character:GetPlayer()
	local target = RANK_ITEMS[rankCode] or {}

	-- strip every tracked TFA item first, so re-promoting/demoting never stacks duplicates
	for _, uniqueID in ipairs(ALL_TRACKED_ITEMS) do
		for _, item in ipairs(inventory:GetItemsByUniqueID(uniqueID, true)) do
			if (item:GetData("equip")) then
				item:Unequip(client, false, true) -- strips the weapon AND removes the item
			else
				item:Remove()
			end
		end
	end

	-- then grant exactly what this rank should carry
	for _, uniqueID in ipairs(target) do
		inventory:Add(uniqueID, 1)
	end
end

function FACTION:OnCharacterCreated(client, character)
	local inventory = character:GetInventory()

	inventory:Add("pistol", 1)
	inventory:Add("pistolammo", 2)
end

function FACTION:GetDefaultName(client)
	return "MPF-00." .. Schema:ZeroNumber(math.random(1, 99999), 5), true
end

function FACTION:OnTransferred(character)
	character:SetName(self:GetDefaultName())
	character:SetModel(self.models[1])

	local client = character:GetPlayer()

	if (IsValid(client)) then
		ApplyRankBodygroups(client, "00")
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
		ApplyRankLoadout(character, newRank)
	end
end

FACTION_MPF = FACTION.index
