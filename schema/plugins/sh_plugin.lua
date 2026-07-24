PLUGIN.name = "Worn Attachments"
PLUGIN.author = "You"
PLUGIN.description = "Bonemerges a model onto a player - used for MPF gas masks, reusable for anything similar later."

-- Call this from anywhere server-side, e.g. sh_metropolice.lua's OnNameChanged/OnTransferred:
--   Schema:SetPlayerAttachment(client, "mask", "models/wn7new/metropolice/n7_cp_gasmask1.mdl")
-- Pass nil as the model to remove that attachment slot.
function Schema:SetPlayerAttachment(client, slot, model)
	if (SERVER and IsValid(client)) then
		client:SetNWString("ixAttach_" .. slot, model or "")
	end
end

if (CLIENT) then
	local SLOTS = {"mask"} -- add more slot names here later (e.g. "hat") if needed
	local attachProps = {} -- [player][slot] = ClientsideModel

	local function UpdateSlot(client, slot)
		local model = client:GetNWString("ixAttach_" .. slot, "")
		attachProps[client] = attachProps[client] or {}
		local current = attachProps[client][slot]

		if (model == "") then
			if (IsValid(current)) then
				current:Remove()
			end

			attachProps[client][slot] = nil
			return
		end

		if (IsValid(current) and current:GetModel() == model) then
			return -- already correct
		end

		if (IsValid(current)) then
			current:Remove()
		end

		local prop = ClientsideModel(model, RENDERGROUP_OPAQUE)

		if (IsValid(prop)) then
			prop:SetParent(client)
			prop:AddEffects(EF_BONEMERGE)
			prop:AddEffects(EF_BONEMERGE_FASTCULL)

			attachProps[client][slot] = prop
		end
	end

	hook.Add("Think", "ixWornAttachmentsThink", function()
		for _, client in ipairs(player.GetAll()) do
			if (IsValid(client)) then
				for _, slot in ipairs(SLOTS) do
					UpdateSlot(client, slot)
				end
			end
		end
	end)

	hook.Add("EntityRemoved", "ixWornAttachmentsCleanup", function(entity)
		if (attachProps[entity]) then
			for _, prop in pairs(attachProps[entity]) do
				if (IsValid(prop)) then prop:Remove() end
			end

			attachProps[entity] = nil
		end
	end)
end
