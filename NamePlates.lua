----- services
local sss = game:GetService("ServerScriptService")
local sstorage = game:GetService("ServerStorage")
local players = game:GetService("Players")

----- assignments

local connect = sss:WaitForChild("DatastoreConnect")
local dataStoreModule = connect:WaitForChild("DatastoreModule")

local folder = sstorage:WaitForChild("Grab", 1)

local rs = game:GetService("ReplicatedStorage")
local classinfomod = require(rs.ClassInfoModule)
local rems = rs:WaitForChild("Remotes")
local frameUpdateRem = rems:WaitForChild("UpdateFrame")

local classesinfo = {}

local classinfosgrabbed = false

local nameplates = {} ---- userid, nameplate

--- functions
local function parentFrame(head)
	if folder then
		local name = folder:WaitForChild("name", 1):Clone()
		if name then
			print("name found, parent to player")
			name.Parent = head
			return(name)
		end
	end
end
local function getclassinfos()
	local classinfo = classinfomod.GetClasses()
	classesinfo = classinfo
	classinfosgrabbed = true
end

local function setDisplayNane(textFrame, plr)
	local displayName = plr.DisplayName
	textFrame.Text = displayName
end

local function setClassName(textFrame,icon , plr)
	local data = require(dataStoreModule).GetCurrentData(plr.UserId)
	local settings = data["Settings"]
	local className = settings["EquippedClass"]
	print("player class is " .. className)
	textFrame.Text = className
	
	if classinfosgrabbed == false then
		getclassinfos()
		while classinfosgrabbed == false do
			wait()
		end
	end
	
	
	if classesinfo[className] then
		print("classname found")
		icon.Image = "rbxassetid://" .. classesinfo[className]["IconID"]
	else
		warn("class not found")
	end
end

local function Setframe(plr)
	if nameplates[plr.UserId] then
		nameplates[plr.UserId]:Destroy()
	end
	
	local char = plr.Character
	local hum = char:WaitForChild("Humanoid", 3)
	if hum then
		hum.DisplayDistanceType = "None"
		local head = char:WaitForChild("Head")
		local name = parentFrame(head)
		nameplates[plr.UserId] = name
		local classNameText = name.text_ClassName.Value
		local displayNameText = name.text_DisplayName.Value
		local classIconImg = name.img_ClassIcon.Value

		setDisplayNane(displayNameText, plr)
		setClassName(classNameText,classIconImg, plr)
	end

end
--- connects


players.PlayerAdded:Connect(function(plr) ------- fire when character gets added ofc
		plr.CharacterAdded:Connect(function(char)
			Setframe(plr)
		end)
end)

local cooldown = false
frameUpdateRem.OnServerEvent:Connect(function(plr)
	if cooldown == false then
		cooldown = true
	Setframe(plr)
	wait(.5)
	cooldown = false
	end
end)