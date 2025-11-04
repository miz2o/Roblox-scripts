local rs = game:GetService("ReplicatedStorage")
local rems = rs:WaitForChild("RemoteEvents")
local classEquipper = rems:WaitForChild("ClassEquipper")

local datastoreModule = require(script.Parent)
local classinfomodule = require(rs.ClassInfoModule)

-- Table to store cooldown states for each player
local cooldowns = {}

classEquipper.OnServerInvoke = function(plr, class)
	local userId = plr.UserId

	if cooldowns[userId] then
		return {"OnCooldown", 0}
	end

	cooldowns[userId] = true

	local data = datastoreModule.GetCurrentData(userId)
	local classes = data["Classes"]

	if classes[class] then
		print("Player owns class, equip")
		datastoreModule.EditSettings(userId, "EquippedClass", class)

		cooldowns[userId] = false
		return {"Equipped", 0}
	else
		print("Player doesnt own class, attempt purchase instead")
		local Coins = data["Coins"]
		local classinfo = classinfomodule.GetClasses()

		if classinfo[class] then
			local Cost = classinfo[class]["Cost"]

			if Coins >= Cost then
				datastoreModule.EditCoins(userId, Cost, "subtract")
				datastoreModule.EditClasses(userId, class, "add")

				cooldowns[userId] = false
				return {"Purchased", Coins - Cost}
			else
				cooldowns[userId] = false
				return {"CannotAfford", 0}
			end
		else
			warn("Class ".. tostring(class) .. " doesnt exist")
		end
	end

	cooldowns[userId] = false
end
