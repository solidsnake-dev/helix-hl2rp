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
--
-- NOTE: "pistol", "smg1", "shotgun", "357", "ar2" below are your edited
-- stock items (now pointing at TFA classes). "tfa_osips", "weapon_csniper_tfa2"
-- and "tfa_ocipr" are still separate new items with no stock equivalent.
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
local RANK_BODYGROUPS = {
	["OWG"] = {["Chest"] = 1, ["Knee Armor"] = 1, ["Shoulder Armor"] = 1}
}

-- Full item set per rank, using your ACTUAL item uniqueIDs.
local RANK_ITEMS = {
	["OWG"] = {"tfa_osips", "pistol"},
	["OWS"] = {"smg1", "pistol", "grenade"},
	["OWR"] = {"weapon_csniper_tfa2", "pistol"},
	["EOWS"] = {"ar2", "pistol", "grenade"},
	["EOS"] = {"shotgun", "357", "grenade", "grenade"}, -- 2x grenade as requested
	["EOW"] = {"ar2", "357", "grenade"},
	["ORD"] = {"tfa_ocipr", "pistol", "grenade"}
}

-- Every item that appears anywhere above, so a promotion/demotion can wipe old rank gear
-- before granting the new set instead of it stacking up.
local ALL_TRACKED_ITEMS = {
	"tfa_osips", "pistol", "smg1", "weapon_csniper_tfa2",
	"ar2", "shotgun", "357", "tfa_ocipr", "grenade"
}

local function ApplyRankBodygroups(client, rankCode)
	local groups = RANK_BODYGROUPS[rankCode]

	if (!groups) then
		return -- no override for this rank, leave the model's own default bodygroups alone
	end

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
