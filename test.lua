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
    -- Eggs & Mutations (Dev)
    -- lists
        local islands = {
        ["Island 1"] = workspace.Art:FindFirstChild("Island_1"),
        ["Island 2"] = workspace.Art:FindFirstChild("Island_2"),
        ["Island 3"] = workspace.Art:FindFirstChild("Island_3"),
        ["Island 4"] = workspace.Art:FindFirstChild("Island_4"),
        ["Island 5"] = workspace.Art:FindFirstChild("Island_5"),
        ["Island 6"] = workspace.Art:FindFirstChild("Island_6")
    }
    
    local targetIsland = nil
    local eggChannel = serv:Channel("DevEggs")
    
    eggChannel:Dropdown("Select Island", {"Island 1","Island 2","Island 3","Island 4","Island 5","Island 6"}, function(selected)
        targetIsland = islands[selected]
        if targetIsland then
            local character = player.Character or player.CharacterAdded:Wait()
            local root = character:WaitForChild("HumanoidRootPart", 5)
    
            local teleportPos = nil
            local env = targetIsland:FindFirstChild("ENV")
            if env then
                local conveyor = env:FindFirstChild("Conveyor")
                if conveyor then
                    for _, model in ipairs(conveyor:GetChildren()) do
                        if model:IsA("Model") then
                            local belt = model:FindFirstChild("Belt")
                            if belt and belt:IsA("BasePart") then
                                teleportPos = belt.Position
                                break
                            end
                        end
                    end
                end
            end
    
            if not teleportPos and targetIsland.PrimaryPart then
                teleportPos = targetIsland.PrimaryPart.Position
            elseif not teleportPos then
                teleportPos = targetIsland:GetModelCFrame().p
            end
    
            if root and teleportPos then
                root.CFrame = CFrame.new(teleportPos + Vector3.new(0, 10, 0))
                DiscordLib:Notification("Teleport", "Teleported to " .. selected, "Okay!")
            else
                DiscordLib:Notification("Teleport Error", "Couldn't find a valid teleport spot for " .. selected, "Got it")
            end
        else
            DiscordLib:Notification("Error", "Could not find " .. selected, "Got it")
        end
    end)
    
    ------------------------------------------------------
    -- Egg & Mutation Whitelist
    ------------------------------------------------------
    
    local eggWhitelist = {
        "Demon Egg", "Bonedragon Egg", "Void Egg", "Bowser Egg", "Rhino Rock Egg",
        "Corn Egg", "Ultra Egg", "Saber Cub Egg", "Unicorn Egg", "General Kong Egg"
    }
    
    local mutationWhitelist = {
        "", "Golden", "Diamond", "Electric", "Fire", "Jurassic", "Snow", "Halloween"
    }
    
    local selectedEggs = { "Demon Egg" } -- default eggs
    local selectedMutations = { "Electric", "Fire", "Jurassic", "Snow", "Halloween" } -- default mutation
    
    -- Egg selection
    eggChannel:Dropdown("Select Eggs", eggWhitelist, function(selected)
        local index = table.find(selectedEggs, selected)
        if index then
            table.remove(selectedEggs, index)
            DiscordLib:Notification("Egg Selection", selected .. " removed.", "Okay!")
        else
            table.insert(selectedEggs, selected)
            DiscordLib:Notification("Egg Selection", selected .. " added.", "Okay!")
        end
    end)
    
    -- Mutation selection
    eggChannel:Dropdown("Select Mutations", mutationWhitelist, function(selected)
        local index = table.find(selectedMutations, selected)
        local msg = selected ~= "" and selected or "Normal"
        if index then
            table.remove(selectedMutations, index)
            DiscordLib:Notification("Mutation Selection", msg .. " removed.", "Okay!")
        else
            table.insert(selectedMutations, selected)
            DiscordLib:Notification("Mutation Selection", msg .. " added.", "Okay!")
        end
    end)
    
    -- View whitelists
    eggChannel:Button("View Selected Whitelist", function()
        DiscordLib:Notification("Selected Whitelist", "Check the console for the selected eggs and mutations.", "Okay!")
    
        print("[Selected Eggs]")
        for _, egg in ipairs(selectedEggs) do
            print(egg)
        end
    
        print("[Selected Mutations]")
        for _, mut in ipairs(selectedMutations) do
            print(mut ~= "" and mut or "Normal")
        end
    end)
    
    ------------------------------------------------------
    -- Function for unified EggGUI lookup
    ------------------------------------------------------
    
    local function findEggGUI(root)
        if not root then return nil end
        local eggGUI = nil
    
        local guiFolder = root:FindFirstChild("GUI")
        if guiFolder and guiFolder:FindFirstChild("EggGUI") then
            eggGUI = guiFolder:FindFirstChild("EggGUI")
        end
    
        if not eggGUI then
            local slashNamed = root:FindFirstChild("GUI/EggGUI")
            if slashNamed then
                eggGUI = slashNamed
            end
        end
    
        if not eggGUI then
            for _, d in ipairs(root:GetDescendants()) do
                if d.Name == "EggGUI" then
                    eggGUI = d
                    break
                end
            end
        end
    
        return eggGUI
    end
    
    ------------------------------------------------------
    -- Scan for Eggs
    ------------------------------------------------------
    
    eggChannel:Button("Scan for Eggs", function()
        if not targetIsland then
            DiscordLib:Notification("Error", "Please select an island first.", "Got it")
            return
        end
    
        local conveyorFolder = targetIsland:FindFirstChild("ENV") and targetIsland.ENV:FindFirstChild("Conveyor")
        if not conveyorFolder then
            DiscordLib:Notification("Error", "No conveyor found on this island.", "Got it")
            return
        end
    
        local foundAny = false
    
        for _, conveyor in ipairs(conveyorFolder:GetChildren()) do
            if conveyor:IsA("Model") then
                local belt = conveyor:FindFirstChild("Belt")
                if belt then
                    for _, eggModel in ipairs(belt:GetChildren()) do
                        if eggModel:IsA("Model") and eggModel:FindFirstChild("RootPart") then
                            local eggGUI = findEggGUI(eggModel.RootPart)
                            if eggGUI then
                                local eggNameObj = eggGUI:FindFirstChild("EggName")
                                local mutateObj = eggGUI:FindFirstChild("Mutate")
    
                                local eggName = eggNameObj and eggNameObj.Text or ""
                                local mutateType = mutateObj and mutateObj.Text or ""
    
                                if table.find(selectedEggs, eggName) and table.find(selectedMutations, mutateType) then
                                    foundAny = true
                                    print("[Detected Egg] " .. eggName .. " - Mutation: " .. (mutateType ~= "" and mutateType or "None"))
                                end
                            end
                        end
                    end
                end
            end
        end
    
        if foundAny then
            DiscordLib:Notification("Egg Detector", "Detected whitelisted eggs! Check console.", "Okay!")
        else
            DiscordLib:Notification("Egg Detector", "No matching eggs found.", "Okay!")
        end
    end)
    
    ------------------------------------------------------
    -- AUTO BUY SPECIAL EGGS
    ------------------------------------------------------
    
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local CharacterRE = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("CharacterRE")
    
    local autoBuy = false
    local buyInterval = 5
    
    -- Auto Buy toggle with island check
    eggChannel:Toggle("Auto Buy Eggs", false, function(state)
        if state and not targetIsland then
            DiscordLib:Notification("Auto Buy Eggs", "Please select an island first before enabling Auto Buy!", "Got it")
            autoBuy = false
            return
        end
    
        autoBuy = state
        if state then
            DiscordLib:Notification("Auto Buy Eggs", "Auto-buy started!", "Okay!")
        else
            DiscordLib:Notification("Auto Buy Eggs", "Auto-buy stopped.", "Okay!")
        end
    end)
    
    eggChannel:Textbox("Buy Interval (seconds)", "e.g. 3", true, function(text)
        local num = tonumber(text)
        if num and num > 0 then
            buyInterval = num
            DiscordLib:Notification("Auto Buy Eggs", "Interval set to " .. num .. " seconds", "Okay!")
        else
            DiscordLib:Notification("Error", "Please enter a valid number.", "Got it")
        end
    end)
    
    task.spawn(function()
    	while task.wait(0.1) do
    		if autoBuy and targetIsland then
    			local conveyorFolder = targetIsland:FindFirstChild("ENV") and targetIsland.ENV:FindFirstChild("Conveyor")
    			if conveyorFolder then
    				for _, conveyor in ipairs(conveyorFolder:GetChildren()) do
    					if conveyor:IsA("Model") then
    						local belt = conveyor:FindFirstChild("Belt")
    						if belt then
    							for _, eggModel in ipairs(belt:GetChildren()) do
    								if eggModel:IsA("Model") and eggModel:FindFirstChild("RootPart") then
    									local eggGUI = findEggGUI(eggModel.RootPart)
    									if eggGUI then
    										local eggNameObj = eggGUI:FindFirstChild("EggName")
    										local mutateObj = eggGUI:FindFirstChild("Mutate")
    
    										local eggName = eggNameObj and eggNameObj.Text or ""
    										local mutateType = mutateObj and mutateObj.Text or ""
    
    										if table.find(selectedEggs, eggName) and table.find(selectedMutations, mutateType) then
    											local args = { "BuyEgg", eggModel.Name }
    											pcall(function()
    												CharacterRE:FireServer(unpack(args))
    											end)
    											print("[Auto-Buy] Bought " .. eggName .. " (" .. (mutateType ~= "" and mutateType or "None") .. ")")
    										end
    									end
    								end
    							end
    						end
    					end
    				end
    			end
    			task.wait(buyInterval)
    		end
    	end
    end)
end


local tgls = serv:Channel("Auto")

------------------------------------------------------
-- AUTO COLLECT SYSTEM
------------------------------------------------------
local RepStorage = game:GetService("ReplicatedStorage")
local PetsFolder = workspace:WaitForChild("Pets")
local player = game:GetService("Players").LocalPlayer

local autoCollect = false
local scanInterval = 0.25

local function readTime()
    local timeObj = RepStorage:FindFirstChild("Time")
    if not timeObj then return nil end
    return timeObj, timeObj:GetAttribute("s"), timeObj.Value
end

local function computeToken()
    local timeObj, s, v = readTime()
    if not timeObj or not s or not v then return nil end
    return bit32.bxor(player.UserId, s, v)
end

local function claimPet(pet)
    if not pet then return end
    local re = pet:FindFirstChild("RE", true)
    if re and re:IsA("RemoteEvent") then
        local token = computeToken()
        pcall(function()
            if token then
                re:FireServer("Claim", token)
            else
                re:FireServer("Claim", pet.Name)
            end
        end)
    end
end

task.spawn(function()
    while task.wait(scanInterval) do
        if autoCollect then
            for _, pet in ipairs(PetsFolder:GetChildren()) do
                claimPet(pet)
            end
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

local islands = {
    ["Island 1"] = workspace.Art:FindFirstChild("Island_1"),
    ["Island 2"] = workspace.Art:FindFirstChild("Island_2"),
    ["Island 3"] = workspace.Art:FindFirstChild("Island_3"),
    ["Island 4"] = workspace.Art:FindFirstChild("Island_4"),
    ["Island 5"] = workspace.Art:FindFirstChild("Island_5"),
    ["Island 6"] = workspace.Art:FindFirstChild("Island_6")
}

local targetIsland = nil
local eggChannel = serv:Channel("Eggs")

eggChannel:Dropdown("Select Island", {"Island 1","Island 2","Island 3","Island 4","Island 5","Island 6"}, function(selected)
    targetIsland = islands[selected]
    if targetIsland then
        local character = player.Character or player.CharacterAdded:Wait()
        local root = character:WaitForChild("HumanoidRootPart", 5)

        local teleportPos = nil
        local env = targetIsland:FindFirstChild("ENV")
        if env then
            local conveyor = env:FindFirstChild("Conveyor")
            if conveyor then
                for _, model in ipairs(conveyor:GetChildren()) do
                    if model:IsA("Model") then
                        local belt = model:FindFirstChild("Belt")
                        if belt and belt:IsA("BasePart") then
                            teleportPos = belt.Position
                            break
                        end
                    end
                end
            end
        end

        if not teleportPos and targetIsland.PrimaryPart then
            teleportPos = targetIsland.PrimaryPart.Position
        elseif not teleportPos then
            teleportPos = targetIsland:GetModelCFrame().p
        end

        if root and teleportPos then
            root.CFrame = CFrame.new(teleportPos + Vector3.new(0, 10, 0))
            DiscordLib:Notification("Teleport", "Teleported to " .. selected, "Okay!")
        else
            DiscordLib:Notification("Teleport Error", "Couldn't find a valid teleport spot for " .. selected, "Got it")
        end
    else
        DiscordLib:Notification("Error", "Could not find " .. selected, "Got it")
    end
end)

------------------------------------------------------
-- Egg & Mutation Whitelist
------------------------------------------------------

local eggWhitelist = {
    "Demon Egg", "Bonedragon Egg", "Void Egg", "Bowser Egg", "Rhino Rock Egg",
    "Corn Egg", "Ultra Egg", "Saber Cub Egg", "Unicorn Egg", "General Kong Egg"
}

local mutationWhitelist = {
    "", "Golden", "Diamond", "Electric", "Fire", "Jurassic", "Snow", "Halloween"
}

local selectedEggs = { "Demon Egg", "Bonedragon Egg" } -- default eggs
local selectedMutations = { "" } -- default mutation

-- Egg selection
eggChannel:Dropdown("Select Eggs", eggWhitelist, function(selected)
    local index = table.find(selectedEggs, selected)
    if index then
        table.remove(selectedEggs, index)
        DiscordLib:Notification("Egg Selection", selected .. " removed.", "Okay!")
    else
        table.insert(selectedEggs, selected)
        DiscordLib:Notification("Egg Selection", selected .. " added.", "Okay!")
    end
end)

-- Mutation selection
eggChannel:Dropdown("Select Mutations", mutationWhitelist, function(selected)
    local index = table.find(selectedMutations, selected)
    local msg = selected ~= "" and selected or "Normal"
    if index then
        table.remove(selectedMutations, index)
        DiscordLib:Notification("Mutation Selection", msg .. " removed.", "Okay!")
    else
        table.insert(selectedMutations, selected)
        DiscordLib:Notification("Mutation Selection", msg .. " added.", "Okay!")
    end
end)

-- View whitelists
eggChannel:Button("View Selected Whitelist", function()
    DiscordLib:Notification("Selected Whitelist", "Check the console for the selected eggs and mutations.", "Okay!")

    print("[Selected Eggs]")
    for _, egg in ipairs(selectedEggs) do
        print(egg)
    end

    print("[Selected Mutations]")
    for _, mut in ipairs(selectedMutations) do
        print(mut ~= "" and mut or "Normal")
    end
end)

------------------------------------------------------
-- Function for unified EggGUI lookup
------------------------------------------------------

local function findEggGUI(root)
    if not root then return nil end
    local eggGUI = nil

    local guiFolder = root:FindFirstChild("GUI")
    if guiFolder and guiFolder:FindFirstChild("EggGUI") then
        eggGUI = guiFolder:FindFirstChild("EggGUI")
    end

    if not eggGUI then
        local slashNamed = root:FindFirstChild("GUI/EggGUI")
        if slashNamed then
            eggGUI = slashNamed
        end
    end

    if not eggGUI then
        for _, d in ipairs(root:GetDescendants()) do
            if d.Name == "EggGUI" then
                eggGUI = d
                break
            end
        end
    end

    return eggGUI
end

------------------------------------------------------
-- Scan for Eggs
------------------------------------------------------

eggChannel:Button("Scan for Eggs", function()
    if not targetIsland then
        DiscordLib:Notification("Error", "Please select an island first.", "Got it")
        return
    end

    local conveyorFolder = targetIsland:FindFirstChild("ENV") and targetIsland.ENV:FindFirstChild("Conveyor")
    if not conveyorFolder then
        DiscordLib:Notification("Error", "No conveyor found on this island.", "Got it")
        return
    end

    local foundAny = false

    for _, conveyor in ipairs(conveyorFolder:GetChildren()) do
        if conveyor:IsA("Model") then
            local belt = conveyor:FindFirstChild("Belt")
            if belt then
                for _, eggModel in ipairs(belt:GetChildren()) do
                    if eggModel:IsA("Model") and eggModel:FindFirstChild("RootPart") then
                        local eggGUI = findEggGUI(eggModel.RootPart)
                        if eggGUI then
                            local eggNameObj = eggGUI:FindFirstChild("EggName")
                            local mutateObj = eggGUI:FindFirstChild("Mutate")

                            local eggName = eggNameObj and eggNameObj.Text or ""
                            local mutateType = mutateObj and mutateObj.Text or ""

                            if table.find(selectedEggs, eggName) and table.find(selectedMutations, mutateType) then
                                foundAny = true
                                print("[Detected Egg] " .. eggName .. " - Mutation: " .. (mutateType ~= "" and mutateType or "None"))
                            end
                        end
                    end
                end
            end
        end
    end

    if foundAny then
        DiscordLib:Notification("Egg Detector", "Detected whitelisted eggs! Check console.", "Okay!")
    else
        DiscordLib:Notification("Egg Detector", "No matching eggs found.", "Okay!")
    end
end)

------------------------------------------------------
-- AUTO BUY SPECIAL EGGS
------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CharacterRE = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("CharacterRE")

local autoBuy = false
local buyInterval = 5

-- Auto Buy toggle with island check
eggChannel:Toggle("Auto Buy Eggs", false, function(state)
    if state and not targetIsland then
        DiscordLib:Notification("Auto Buy Eggs", "Please select an island first before enabling Auto Buy!", "Got it")
        autoBuy = false
        return
    end

    autoBuy = state
    if state then
        DiscordLib:Notification("Auto Buy Eggs", "Auto-buy started!", "Okay!")
    else
        DiscordLib:Notification("Auto Buy Eggs", "Auto-buy stopped.", "Okay!")
    end
end)

eggChannel:Textbox("Buy Interval (seconds)", "e.g. 3", true, function(text)
    local num = tonumber(text)
    if num and num > 0 then
        buyInterval = num
        DiscordLib:Notification("Auto Buy Eggs", "Interval set to " .. num .. " seconds", "Okay!")
    else
        DiscordLib:Notification("Error", "Please enter a valid number.", "Got it")
    end
end)

task.spawn(function()
	while task.wait(0.1) do
		if autoBuy and targetIsland then
			local conveyorFolder = targetIsland:FindFirstChild("ENV") and targetIsland.ENV:FindFirstChild("Conveyor")
			if conveyorFolder then
				for _, conveyor in ipairs(conveyorFolder:GetChildren()) do
					if conveyor:IsA("Model") then
						local belt = conveyor:FindFirstChild("Belt")
						if belt then
							for _, eggModel in ipairs(belt:GetChildren()) do
								if eggModel:IsA("Model") and eggModel:FindFirstChild("RootPart") then
									local eggGUI = findEggGUI(eggModel.RootPart)
									if eggGUI then
										local eggNameObj = eggGUI:FindFirstChild("EggName")
										local mutateObj = eggGUI:FindFirstChild("Mutate")

										local eggName = eggNameObj and eggNameObj.Text or ""
										local mutateType = mutateObj and mutateObj.Text or ""

										if table.find(selectedEggs, eggName) and table.find(selectedMutations, mutateType) then
											local args = { "BuyEgg", eggModel.Name }
											pcall(function()
												CharacterRE:FireServer(unpack(args))
											end)
											print("[Auto-Buy] Bought " .. eggName .. " (" .. (mutateType ~= "" and mutateType or "None") .. ")")
										end
									end
								end
							end
						end
					end
				end
			end
			task.wait(buyInterval)
		end
	end
end)
