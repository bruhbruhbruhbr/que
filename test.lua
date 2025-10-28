--// LOAD UI LIBRARY
local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()

--// MAIN WINDOW
local win = DiscordLib:Window("discord library")
local serv = win:Server("Main", "http://www.roblox.com/asset/?id=6031075938")

--// BUTTONS
--[[
local btns = serv:Channel("Buttons")

btns:Button("Kill all", function()
	DiscordLib:Notification("Notification", "Killed everyone!", "Okay!")
end)

btns:Seperator()

btns:Button("Get max level", function()
	DiscordLib:Notification("Notification", "Max level!", "Okay!")
end)
--]]

--// TOGGLES
local tgls = serv:Channel("Toggles")

tgls:Toggle("Auto-Farm", false, function(bool)
	print("Auto-Farm:", bool)
end)

--// AUTO COLLECT SYSTEM
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PetsFolder = workspace:WaitForChild("Pets")
local CLAIM_ARGS = { "Claim" }
local autoCollect = false
local collectInterval = 1 -- default seconds
local PopupDrop = PlayerGui:WaitForChild("PopupDrop", 10)

local function findRemoteForPet(pet)
	local r = pet:FindFirstChild("RE")
	if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then
		return r
	end
	for _, child in ipairs(pet:GetChildren()) do
		if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
			return child
		end
	end
	for _, desc in ipairs(pet:GetDescendants()) do
		if (desc.Name == "RE" or desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction")) then
			return desc
		end
	end
	return nil
end

local function claimAllPets()
	if PopupDrop then PopupDrop.Enabled = false end
	for _, pet in ipairs(PetsFolder:GetChildren()) do
		if typeof(pet) == "Instance" then
			local remote = findRemoteForPet(pet)
			if remote and type(remote.FireServer) == "function" then
				pcall(function()
					remote:FireServer(unpack(CLAIM_ARGS))
				end)
			end
		end
	end
	if PopupDrop then PopupDrop.Enabled = true end
end

-- background loop
task.spawn(function()
	while task.wait(0.1) do
		if autoCollect then
			claimAllPets()
			task.wait(collectInterval)
		end
	end
end)

tgls:Toggle("Auto Collect", false, function(bool)
	autoCollect = bool
	if bool then
		if PopupDrop then PopupDrop.Enabled = false end
		DiscordLib:Notification("Auto Collect", "Enabled auto-collecting pets!", "Okay!")
	else
		if PopupDrop then PopupDrop.Enabled = true end
		DiscordLib:Notification("Auto Collect", "Disabled auto-collecting pets!", "Okay!")
	end
end)

tgls:Textbox("Collect Interval (seconds)", "e.g. 1.5", true, function(t)
	local num = tonumber(t)
	if num and num > 0 then
		collectInterval = num
		DiscordLib:Notification("Auto Collect", "Interval set to " .. num .. " seconds", "Okay!")
	else
		DiscordLib:Notification("Error", "Please enter a valid number.", "Got it")
	end
end)

--[[
--// SLIDERS
local sldrs = serv:Channel("Sliders")

local sldr = sldrs:Slider("Slide me!", 0, 1000, 400, function(t)
	print(t)
end)

sldrs:Button("Change to 50", function()
	sldr:Change(50)
end)

--// DROPDOWNS
local drops = serv:Channel("Dropdowns")

local drop = drops:Dropdown("Pick me!", {"Option 1","Option 2","Option 3","Option 4","Option 5"}, function(bool)
	print(bool)
end)

drops:Button("Clear", function()
	drop:Clear()
end)

drops:Button("Add option", function()
	drop:Add("Option")
end)

--// COLORPICKERS
local clrs = serv:Channel("Colorpickers")

clrs:Colorpicker("ESP Color", Color3.fromRGB(255,1,1), function(t)
	print(t)
end)

--// TEXTBOXES
local textbs = serv:Channel("Textboxes")

textbs:Textbox("Gun power", "Type here!", true, function(t)
	print(t)
end)

--// LABELS
local lbls = serv:Channel("Labels")

lbls:Label("This is just a label.")

--// BINDS
local bnds = serv:Channel("Binds")

bnds:Bind("Kill bind", Enum.KeyCode.RightShift, function()
	print("Killed everyone!")
end)
--]]

