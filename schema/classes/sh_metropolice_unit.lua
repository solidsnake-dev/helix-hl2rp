CLASS.name = "Metropolice Unit"
CLASS.faction = FACTION_MPF

function CLASS:CanSwitchTo(client)
	local name = client:Name()
	local bStatus = false

	for k, v in ipairs({ "20", "40", "60", "80" }) do
		if (Schema:IsCombineRank(name, v)) then
			bStatus = true
			break
		end
	end

	return bStatus
end

CLASS_MPU = CLASS.index
