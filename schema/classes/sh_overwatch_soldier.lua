CLASS.name = "Overwatch Soldier"
CLASS.faction = FACTION_OTA
CLASS.isDefault = true

function CLASS:CanSwitchTo(client)
	local name = client:Name()

	-- check elite-track ranks FIRST and exclude them, since "OWS" is a substring of "EOWS"
	-- and would otherwise incorrectly match here too
	for _, v in ipairs({ "EOWS", "EOS", "EOW", "ORD" }) do
		if (Schema:IsCombineRank(name, v)) then
			return false
		end
	end

	for _, v in ipairs({ "OWG", "OWS", "OWR" }) do
		if (Schema:IsCombineRank(name, v)) then
			return true
		end
	end

	return false
end

CLASS_OWS = CLASS.index
