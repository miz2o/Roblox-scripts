
---- Module assignment ---------
local DataStoreModule = {}

---------- SERVICES -------
local DataStoreservice = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------- DATASTORES ------------
local playerData = DataStoreservice:GetDataStore("playerData_V1")

----- Values ----
local DefaultData = {
	["Coins"] = 100,
	["Classes"] = {Goon = true},
	["Settings"] = {
		["EquippedClass"] = "Goon",
		
		["Master"] = 100,
		["SFX"] = 100,
		["MusicVolume"] = 100,
		
		["LowGraphics"] = false,
		["VFXEnabled"] = true
	}
}

local DataToSave = {} ---- Userid, Data

------- functions -----

----- only call on join ---
function DataStoreModule.LoadData(UserID)
	print("Loading data for UserID: " .. UserID)
	local success2, retrievedData = pcall(function()
		return playerData:GetAsync(UserID)
	end)

	if success2 then
		if retrievedData then
			print("Loaded player data for " .. UserID)
			print(retrievedData)
			DataToSave[UserID] = retrievedData
		else
			print("No player data, setting default for " .. UserID)
			DataToSave[UserID] = DefaultData
			playerData:SetAsync(UserID, DefaultData)
		end
	else
		warn("Failed to load data for UserID: " .. tostring(UserID))
	end
end

--- call to get current data ---
function DataStoreModule.GetCurrentData(UserID)
	return DataToSave[UserID]
end

function DataStoreModule.EditCoins(UserID, Value, WhatToDo)
	---- WhatToDo: Add, Substract, Set
	if WhatToDo == "add" then
		DataToSave[UserID]["Coins"] += Value
	elseif WhatToDo == "subtract" then
		DataToSave[UserID]["Coins"] -= Value
	elseif WhatToDo == "set" then
		DataToSave[UserID]["Coins"] = Value
	else
		warn("No WhatToDo Value Set")
	end
	print(Value .. " Coins " .. WhatToDo .. " From player " .. UserID)
	--- going to fire a remote here that visually also changes the coins
end

function DataStoreModule.EditClasses(UserID, Class, WhatToDo)
	---- WhatToDo: Add, Substract, Set
	local data = DataToSave[UserID]
	local classes = data["Classes"]
	
	if WhatToDo == "add" then
		classes[Class] = true
	elseif WhatToDo == "subtract" then
		classes[Class] = nil
	else
		warn("No WhatToDo Value Set")
	end
	print("Class " .. Class .. " " .. WhatToDo .. " from player " .. UserID)
end

function DataStoreModule.EditSettings(UserID, Setting, Value)
	DataToSave[UserID]["Settings"][Setting] = Value
	print("setting set " .. Setting .. " to " .. Value .. " from player " .. UserID)
end

function DataStoreModule.WipeData(UserID)
	DataToSave[UserID] = DefaultData
	playerData:SetAsync(UserID, DefaultData)
	print("Wiped data for UserID: " .. UserID)
end

--- only call on leave ---
function DataStoreModule.SavetoDataStore(UserID)
	print("Saving data for UserID: " .. UserID)
	local success, errorMessage = pcall(function()
		playerData:SetAsync(UserID, DataToSave[UserID])
	end)
	if success then
		print("Saved Sucessfully for " .. UserID)
	else
		print("Error saving, retrying " .. errorMessage)
		DataStoreModule.LoadData(UserID)
	end
end




return DataStoreModule
