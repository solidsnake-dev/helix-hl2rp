CLASS.name = "Elite Overwatch Soldier"
CLASS.faction = FACTION_OTA
CLASS.isDefault = false

function CLASS:CanSwitchTo(client)
	local name = client:Name()
	local bStatus = false

	for k, v in ipairs({ "EOWS", "EOS", "EOW", "ORD" }) do
		if (Schema:IsCombineRank(name, v)) then
			bStatus = true
			break
		end
	end

	return bStatus
end

CLASS_EOW = CLASS.index
