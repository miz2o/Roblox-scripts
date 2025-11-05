---/// services

local rs = game:GetService("ReplicatedStorage")
local teleportservice = game:GetService("TeleportService")
local RunService = game:GetService("RunService")


-----/////// references 

local model = script.Parent
local infoUI = script:WaitForChild("infoUi").Value

local WallPart = model:WaitForChild("Wall")
local tpPoint = model:WaitForChild("tpPoint")
local outsidePoint = model:WaitForChild("outsidePoint")

local hostText = infoUI:WaitForChild("Host")
local playerCountText = infoUI:WaitForChild("Playercount")
local lobbyPrivacyText = infoUI:WaitForChild("Privacy")

local createlobbyremote = rs:WaitForChild("RemoteEvents"):WaitForChild("Lobbycreation"):WaitForChild("Createlobby")



---------///////// values ///////////---------

local placeId = 80940798429596 

local lobbyCreated = false
local lobbyHost = nil
local lobbypublic = false
local hosted = false
local lobbyPlayers = {}

local lobbyRoundRoof = 8
local maxLobbyCount = 4

local currentlyInTeleport = false

-----///////// COOLDOWNS
local touchCooldown = {}
local cooldownTime = 2 

local currentplayercount = 0

--------///// function

local function teleportPlayers()
	currentlyInTeleport = true
	local success, err = pcall(function()
		hostText.Text = lobbyHost.Name .. "'s Lobby"
		playerCountText.Text = ""
		lobbyPrivacyText.Text = "Teleporting players..."

		local group = {}
		for userId, inLobby in pairs(lobbyPlayers) do
			if inLobby then
				local plr = game.Players:GetPlayerByUserId(userId)
				if plr then
					table.insert(group, plr)
				end
			end
		end

		if #group > 0 then
			if RunService:IsStudio() then
				for _, plr in pairs(group) do
					print(plr.Name .. " teleported, but cant in studio")
				end
			else
				local privateServerId, accessCode = teleportservice:ReserveServer(placeId)
				local options = Instance.new("TeleportOptions")
				options.ShouldReserveServer = true
				options:SetTeleportData({
					expectedCount = #group,
					secret = "AUTHORIZED"
				})
				teleportservice:TeleportAsync(placeId, group, options)
			end
		end
	end)

	if not success then
		warn("Teleport failed", err)
	end

	lobbyPlayers = {}
	lobbyCreated = false
	hosted = false
	lobbyHost = nil
	lobbypublic = false
	currentplayercount = 0
	currentlyInTeleport = false

	hostText.Text = "Create lobby"
	playerCountText.Text = ""
	lobbyPrivacyText.Text = ""
end


local function bringPlayer(plr)
	if not lobbyPlayers[plr.UserId] then
		print("Adding player")
		lobbyPlayers[plr.UserId] = true
		currentplayercount += 1

		playerCountText.Text = currentplayercount .. " / " .. maxLobbyCount

		local character = plr.Character
		if character then
			local humroot = character:WaitForChild("HumanoidRootPart")
			if humroot then
				humroot.CFrame = tpPoint.CFrame
			end
		end

		if currentplayercount >= maxLobbyCount then
			print("enough players")
			teleportPlayers()
		end
	end

end

local function removePlayer(plr)
	if lobbyPlayers[plr.UserId] then
		print("Removing player")
		lobbyPlayers[plr.UserId] = false
		currentplayercount -= 1

		playerCountText.Text = currentplayercount .. " / " .. maxLobbyCount 


		local character = plr.Character
		if character then
			local humroot = character:WaitForChild("HumanoidRootPart")
			if humroot then
				humroot.CFrame = outsidePoint.CFrame
			end
		end

		if currentplayercount <= 0 then
			lobbyCreated = false
			hosted = false
			lobbyHost = nil
			lobbypublic = false
			hostText.Text = "Create lobby"
			playerCountText.Text =  ""
			lobbyPrivacyText.Text = ""
			lobbyPlayers = {}
		end
	end
end



local function makeLobby(host, privacy, count)
	if count > lobbyRoundRoof then
		count = lobbyRoundRoof
	end
	hosted = true
	lobbypublic = privacy
	lobbyHost = host
	lobbyCreated = true
	maxLobbyCount = count
	currentlyInTeleport = false


	print(host.Name .. " Created a lobby of " .. tostring(count) .. " Players, set to " .. tostring(privacy))

	hostText.Text = lobbyHost.Name .. "'s Lobby"
	playerCountText.Text =  currentplayercount .. " / " ..  maxLobbyCount 
	lobbyPrivacyText.Text = lobbypublic and "Private" or "Public"
end

local function requestCreation(player)
	print("showing lobby screen to player")
	local success, privacy, count = pcall(function()
		return createlobbyremote:InvokeClient(player)
	end)

	if success and privacy ~= nil and count ~= nil then
		makeLobby(player, privacy, count)
	else
		warn("Failed to create lobby for", player.Name)
	end
end

WallPart.Touched:Connect(function(hit)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if player then
		local userId = player.UserId
		local now = tick()

		if touchCooldown[userId] and now - touchCooldown[userId] < cooldownTime then
			return
		end
		touchCooldown[userId] = now

		print(player.Name .. " touched")


		if currentlyInTeleport == false then
			if not lobbyPlayers[userId] then
				if not hosted then
					hostText.Text = player.Name .. "'s Lobby"
					lobbyPrivacyText.Text = "Lobby being created.."
					playerCountText.Text = "0 / " .. maxLobbyCount
					lobbyHost = player
					requestCreation(player)
				end
				bringPlayer(player)
			else
				print("player already in lobby")
				removePlayer(player)
			end
		end

	end
end)


game.Players.PlayerAdded:Connect(function(plr)
	plr.CharacterRemoving:Connect(function()
		if lobbyPlayers[plr.UserId] then
			removePlayer(plr)
		end
	end)
end)