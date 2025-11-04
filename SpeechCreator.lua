
--- This script was made to test out the new roblox speech to text feature! 
--- Script as localscript in starterplayerscripts, audiostt component under script along with a wire 

--- after testing i had concluded audiospeechtotext is only accessable localside and ended up with a small local script :)


local player = game.Players.LocalPlayer
local playergui = player:WaitForChild("PlayerGui")
local screenGui = playergui:WaitForChild("ScreenGui")
local frame = screenGui:WaitForChild("Frame")
local textframe = frame:WaitForChild("PlayerText")
local mindtext = frame:WaitForChild("Mindtext")

local stt = script:WaitForChild("AudioSpeechToText")
local wire = stt:WaitForChild("Wire")

local input = player:WaitForChild("AudioDeviceInput", 3) or Instance.new("AudioDeviceInput", player)

stt.Enabled = true

wire.SourceInstance = input
wire.TargetInstance = stt


local function checkrespondse(text)
	local text = string.lower(text)
	if string.find(text, "hello" or "hi") then
		mindtext.Text = "hi :D"

	end
end

stt:GetPropertyChangedSignal("Text"):Connect(function()
	if stt.Text ~= "" then
		print("Text changed to:", stt.Text)
		textframe.Text = stt.Text
		checkrespondse(stt.Text)
		stt.Text = ""
	end
end)
