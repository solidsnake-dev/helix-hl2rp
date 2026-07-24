PLUGIN.name = "Scavenging"
PLUGIN.author = "You"
PLUGIN.description = "Search common world props for a chance at materials, food, medicine, or (rarely) a weapon."

-- Which prop models count as lootable containers. These are common stock HL2 trash/storage
-- paths from general knowledge - I can't verify exact filenames without your game running,
-- so treat this as a starting list. To add more: right-click any prop in the spawn menu ->
-- Copy to Clipboard to get its exact model path, then add it below (all lowercase).
local LOOTABLE_MODELS = {
	["models/props_junk/garbage_metalcan001a.mdl"] = true,
	["models/props_junk/garbage_metalcan002a.mdl"] = true,
	["models/props_junk/trashdumpster01a.mdl"] = true,
	["models/props_junk/trashdumpster02.mdl"] = true,
	["models/props_junk/wood_crate001a.mdl"] = true,
	["models/props_junk/wood_crate002a.mdl"] = true,
	["models/props_junk/cardboard_box004a.mdl"] = true,
	["models/props_c17/furniturewashingmachine001a.mdl"] = true,
	["models/props_c17/furniturefridge001a.mdl"] = true,
	["models/props_c17/lockers001a.mdl"] = true,
}

-- Seconds before a searched prop can be searched again - keeps it from being farmed instantly,
-- but lets it replenish over a session instead of being permanently emptied.
local SEARCH_COOLDOWN = 900

-- Weighted loot table. "items = nil" is an intentionally large "found nothing" tier so most
-- searches don't pay off. Adjust the chance numbers (they don't need to add to 100) to retune.
local LOOT_TABLE = {
	{chance = 50, items = nil},
	{chance = 25, items = {"scrap_metal", "cloth_scraps", "wiring"}},
	{chance = 14, items = {"apple", "bread_loaf", "cola", "soda1", "meat3"}},
	{chance = 8, items = {"shoes_black", "gloves", "hat1", "legs_citizen1", "torso_worker1", "beanie_blue", "satchel"}},
	{chance = 2, items = {"medkit_basic"}},
	{chance = 1, items = {"pistol"}},
}

local function RollLoot()
	local total = 0
	for _, tier in ipairs(LOOT_TABLE) do total = total + tier.chance end

	local roll = math.random(1, total)
	local sum = 0

	for _, tier in ipairs(LOOT_TABLE) do
		sum = sum + tier.chance

		if (roll <= sum) then
			return tier.items
		end
	end
end

-- New items this system needs that don't exist elsewhere yet. Models are placeholders -
-- swap for whatever fits once you've checked what's actually available.
local function RegisterMaterial(uniqueID, name, model, description)
	local ITEM = ix.item.Register(uniqueID, nil, nil, nil, true)
	ITEM.name = name
	ITEM.model = Model(model)
	ITEM.width = 1
	ITEM.height = 1
	ITEM.category = "Materials"
	ITEM.description = description
end

RegisterMaterial("scrap_metal", "Scrap Metal", "models/props_junk/metal_paintcan001a.mdl", "Salvaged metal, useful for crafting.")
RegisterMaterial("cloth_scraps", "Cloth Scraps", "models/props_junk/cardboard_box004a.mdl", "Torn fabric, useful for crafting.")
RegisterMaterial("wiring", "Wiring", "models/props_junk/PopCan01a.mdl", "A tangle of salvaged wire.")

do
	local ITEM = ix.item.Register("medkit_basic", nil, nil, nil, true)
	ITEM.name = "Bandages"
	ITEM.model = Model("models/items/healthkit.mdl")
	ITEM.width = 1
	ITEM.height = 1
	ITEM.category = "Consumables"
	ITEM.description = "A basic first aid wrap. Better than nothing."
	ITEM.functions.Use = {
		name = "Use",
		OnRun = function(itemTable)
			local client = itemTable.player
			client:SetHealth(math.min(client:Health() + 35, client:GetMaxHealth()))
			return true
		end
	}
end

if (SERVER) then
	function PLUGIN:PlayerUse(client, entity)
		local model = entity:GetModel()

		if (!model or !LOOTABLE_MODELS[model:lower()]) then
			return
		end

		local lastSearch = entity.ixLastSearched or 0

		if (CurTime() < lastSearch + SEARCH_COOLDOWN) then
			client:Notify("There's nothing else useful here right now.")
			return false
		end

		entity.ixLastSearched = CurTime()

		local character = client:GetCharacter()
		if (!character) then return false end

		local items = RollLoot()

		if (!items) then
			client:Notify("You search but find nothing useful.")
			return false
		end

		local uniqueID = items[math.random(1, #items)]
		local inventory = character:GetInventory()

		if (inventory:Add(uniqueID)) then
			local itemTable = ix.item.list[uniqueID]
			client:Notify("You found: " .. (itemTable and itemTable.name or uniqueID))
		end

		return false
	end
end
