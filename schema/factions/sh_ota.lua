FACTION.name = "Overwatch Transhuman Arm"
FACTION.description = "A transhuman Overwatch soldier produced by the Combine."
FACTION.color = Color(150, 50, 50, 255)
FACTION.pay = 40
FACTION.isDefault = false
FACTION.isGloballyRecognized = true
FACTION.runSounds = {[0] = "NPC_CombineS.RunFootstepLeft", [1] = "NPC_CombineS.RunFootstepRight"}

-- ===================================================================
-- Custom rank progression, same approach as Metropolice - ranks are read
-- from the character's name, e.g. "OTA-EOS.00042" = rank "EOS".
-- ===================================================================

local RANK_ORDER = {"OWG", "OWS", "OWR", "EOWS", "EOS", "EOW", "ORD"}

local RANK_MODELS = {
	["OWG"] = "models/willardplayer/willardnetworks/combine/antibody.mdl",
	["OWS"] = "models/willardplayer/wn/ota_soldier.mdl",
	["OWR"] = "models/willardplayer/wn/ota_commander.mdl",
	["EOWS"] = "models/willardplayer/wn/ota_soldier.mdl",
	["EOS"] = "models/willardplayer/wn/ota_shotgunner.mdl",
	["EOW"] = "models/willardplayer/wn/ota_elite_summit.mdl",
	["ORD"] = "models/willardplayer/wn/ordinal.mdl"
}

FACTION.models = {RANK_MODELS.OWG}

-- Only OWG had bodygroup instructions, so it's the only rank listed here - every other
-- rank is left at whatever its model's own default bodygroups are (nothing gets reset).
-- Add an entry the same way (bodygroup name -> value) if another rank needs one too.
local RANK_BODYGROUPS = {
	["OWG"] = {["Chest"] = 1, ["Knee Armor"] = 1, ["Shoulder Armor"] = 1}
}

-- Full item set per rank. "grenade" is the frag grenade item that already exists in the
-- schema (schema/items/weapons/sh_grenade.lua) - it currently only allows CLASS_EOW to use
-- it, which will block most of these ranks, so that restriction needs loosening separately.
-- Everything else here needs a real Helix item file - see the new item files alongside this.
local RANK_ITEMS = {
	["OWG"] = {"tfa_osips", "tfa_hl2r_pistol"},
	["OWS"] = {"tfa_hl2r_smg1", "tfa_hl2r_pistol", "grenade"},
	["OWR"] = {"weapon_csniper_tfa2", "tfa_hl2r_pistol"},
	["EOWS"] = {"tfa_hl2r_ar2", "tfa_hl2r_pistol", "grenade"},
	["EOS"] = {"tfa_hl2r_shotgun", "tfa_hl2r_357", "grenade", "grenade"}, -- 2x grenade as requested
	["EOW"] = {"tfa_hl2r_ar2", "tfa_hl2r_357", "grenade"},
	["ORD"] = {"tfa_ocipr", "tfa_hl2r_pistol", "grenade"}
}

-- Every item that appears anywhere above, so a promotion/demotion can wipe old rank gear
-- before granting the new set instead of it stacking up.
local ALL_TRACKED_ITEMS = {
	"tfa_osips", "tfa_hl2r_pistol", "tfa_hl2r_smg1", "weapon_csniper_tfa2",
	"tfa_hl2r_ar2", "tfa_hl2r_shotgun", "tfa_hl2r_357", "tfa_ocipr", "grenade"
}

local function ApplyRankBodygroups(client, rankCode)
	local groups = RANK_BODYGROUPS[rankCode]

	if (!groups) then
		return -- no override for this rank, leave the model's own default bodygroups alone
	end

	-- reads the CURRENT model's real bodygroup list at runtime instead of a hardcoded name
	-- list, so this works correctly no matter which of the 7 models is active
	for _, info in ipairs(client:GetBodyGroups()) do
		client:SetBodygroup(info.id, groups[info.name] or 0)
	end
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

-- "EOWS" contains both "OWS" and "EOW" as substrings, so a plain first-match search would
-- misfire on it. Always preferring the LONGEST matching code fixes that without renaming
-- anything - "EOWS" (4 chars) always wins over "OWS"/"EOW" (3 chars) when it's really present.
local function DetectRank(name)
	local best, bestLength = nil, 0

	for _, code in ipairs(RANK_ORDER) do
		if (Schema:IsCombineRank(name, code) and #code > bestLength) then
			best = code
			bestLength = #code
		end
	end

	return best
end

function FACTION:GetDefaultName(client)
	return "OTA-OWG." .. Schema:ZeroNumber(math.random(1, 99999), 5), true
end

function FACTION:OnTransferred(character)
	character:SetName(self:GetDefaultName())
	character:SetModel(RANK_MODELS.OWG)

	local client = character:GetPlayer()

	if (IsValid(client)) then
		ApplyRankBodygroups(client, "OWG")
	end

	ApplyRankLoadout(character, "OWG")
end

function FACTION:OnNameChanged(client, oldValue, value)
	local character = client:GetCharacter()
	local oldRank = DetectRank(oldValue)
	local newRank = DetectRank(value)

	if (newRank and newRank != oldRank) then
		client:SetModel(RANK_MODELS[newRank])
		ApplyRankBodygroups(client, newRank)
		ApplyRankLoadout(character, newRank)
	end
end

FACTION_OTA = FACTION.index
