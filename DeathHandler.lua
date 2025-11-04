----------- SERVICES --------------
local rs = game:GetService("ReplicatedStorage")
local ts = game:GetService("TeleportService")

--------- MODULES -----------
local dataStoreModule = require(script.Parent.DatastoreConnect.DatastoreModule)

-------- REMOTES ----------------
local deathScreenRemote = rs:WaitForChild("Remotes"):WaitForChild("DeathScreen")
local golobbyremote = rs:WaitForChild("Remotes"):WaitForChild("GoToLobby")
local MarketplaceService = game:GetService("MarketplaceService")


----------- VALUES ---------------
local deathearnings = script:WaitForChild("Deathearnings").Value
local winearnings = script:WaitForChild("WinEarnings").Value

local deadPlayers = {}
local deathPositions = {}

local PlaceID = 124715318246681
local ProductID = 3419170458

------- FUNCTIONS ----------

game.Players.CharacterAutoLoads = false

local function giveForcefield(player, duration)
	local character = player.Character
	if character then
		local forceField = Instance.new("ForceField")
		forceField.Visible = true
		forceField.Parent = character
		if duration then
			task.delay(duration, function()
				if forceField then
					forceField:Destroy()
				end
			end)
		end
	end
end

local function teleportPlayer(player)
	ts:Teleport(PlaceID, player)
end


local function setupCharacter(player, character)
	print("Setting up character for:", player.Name)

	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then
		print("No humanoid found for:", player.Name)
		return
	end

	print("Humanoid found for:", player.Name)

	humanoid.Died:Connect(function()
		print(player.Name .. " has died!")
		local humRoot = character:WaitForChild("HumanoidRootPart", 3)
		if humRoot then
			deathPositions[player] = humRoot.CFrame
		end
		deadPlayers[player] = true
		player:SetAttribute("Dead", true)
		deathScreenRemote:FireClient(player, 25)
	end)
end

game.Players.PlayerAdded:Connect(function(player)
	print("Player joined:", player.Name)

	player:SetAttribute("Dead", false)

	player.CharacterAdded:Connect(function(character)
		print("Character added for:", player.Name)
		setupCharacter(player, character)
	end)

	player:LoadCharacter()
end)

golobbyremote.OnServerEvent:Connect(function(plr)
	dataStoreModule.EditCoins(plr.UserId, 25, "add")
	teleportPlayer(plr)
	print("teleported")

end)




MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if receiptInfo.ProductId == ProductID then
		print(player.Name .. " Revived!")
	end
	player:SetAttribute("Dead", false)
	player:LoadCharacter()
	giveForcefield(player, 5)
	if deathPositions[player] then
		player.Character.HumanoidRootPart.CFrame = deathPositions[player]
	end
	return Enum.ProductPurchaseDecision.PurchaseGranted
end