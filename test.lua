local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- your existing UI setup
local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()
local win = DiscordLib:Window("discord library")

local serv = win:Server("Main", "http://www.roblox.com/asset/?id=6031075938")

-- Dev-only channel
if player.UserId == 1832635191 then
    local devChannel = serv:Channel("Dev Channel")

    devChannel:Button("Simple Spy", function()
        loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpyBeta.lua"))()
        DiscordLib:Notification("Notification", "Simple Spy loaded successfully!", "Okay!")
    end)

    devChannel:Button("Quick RJ", function()
        loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/bruhbruhbruhbr/que/refs/heads/main/QRJ"))()
        DiscordLib:Notification("Notification", "L To Rejoin", "Okay!")
    end)
end


local tgls = serv:Channel("Auto")

------------------------------------------------------
-- AUTO COLLECT SYSTEM
------------------------------------------------------

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

tgls:Button("Remove Collect UI", function()
    local player = game:GetService("Players").LocalPlayer
    local popup = player:WaitForChild("PlayerGui"):FindFirstChild("PopupDrop")

    if popup then
        popup:Destroy()
        DiscordLib:Notification("Notification", "UI removed!", "Okay!")
    else
        DiscordLib:Notification("Notification", "UI not found.", "Okay!")
    end
end)

------------------------------------------------------
-- AUTO BUY FOODS SYSTEM (with whitelist + select all)
------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage:WaitForChild("Remote")
local FoodStoreRE = Remote:WaitForChild("FoodStoreRE")

local foods = {
    "Pear",
    "Pineapple",
    "DragonFruit",
    "GoldMango",
    "BloodstoneCycad",
    "ColossalPinecone",
    "VoltGinkgo",
    "CandyCorn",
    "Durian",
    "DeepseaPearlFruit",
    "Pumpkin"
}

local autoBuy = false
local buyInterval = 3
local whitelist = {}

tgls:Toggle("Auto Buy Foods", false, function(bool)
	autoBuy = bool
	if bool then
		DiscordLib:Notification("Auto Buy", "Started buying foods automatically!", "Okay!")
	else
		DiscordLib:Notification("Auto Buy", "Stopped auto-buying foods.", "Okay!")
	end
end)

tgls:Textbox("Buy Interval (seconds)", "e.g. 3", true, function(t)
	local num = tonumber(t)
	if num and num > 0 then
		buyInterval = num
		DiscordLib:Notification("Auto Buy", "Interval set to " .. num .. " seconds", "Okay!")
	else
		DiscordLib:Notification("Error", "Please enter a valid number.", "Got it")
	end
end)

-- Dropdown for whitelist
tgls:Dropdown("Add/Remove Whitelist", foods, function(selected)
	if whitelist[selected] then
		whitelist[selected] = nil
		DiscordLib:Notification("Whitelist", selected .. " removed from whitelist.", "Okay!")
	else
		whitelist[selected] = true
		DiscordLib:Notification("Whitelist", selected .. " added to whitelist.", "Okay!")
	end
end)

-- Select all or deselect all
tgls:Button("Select/Deselect All", function()
	local allSelected = true
	for _, foodName in ipairs(foods) do
		if not whitelist[foodName] then
			allSelected = false
			break
		end
	end

	if allSelected then
		whitelist = {}
		DiscordLib:Notification("Whitelist", "All foods deselected.", "Okay!")
	else
		for _, foodName in ipairs(foods) do
			whitelist[foodName] = true
		end
		DiscordLib:Notification("Whitelist", "All foods selected.", "Okay!")
	end
end)

tgls:Button("Show Whitelist", function()
	local list = {}
	for foodName in pairs(whitelist) do
		table.insert(list, foodName)
	end
	if #list == 0 then
		DiscordLib:Notification("Whitelist", "No foods selected.", "Okay!")
	else
		DiscordLib:Notification("Whitelist", "Currently selected: " .. table.concat(list, ", "), "Okay!")
	end
end)

-- Auto-buy loop
task.spawn(function()
	while task.wait(0.1) do
		if autoBuy then
			for foodName in pairs(whitelist) do
				local args = { foodName }
				pcall(function()
					FoodStoreRE:FireServer(unpack(args))
				end)
			end
			task.wait(buyInterval)
		end
	end
end)
