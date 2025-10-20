_G.HitPercentage = 1

-- Silent reload protection
if _G.SilentAimLoaded then
    warn("Silent Aim already running. Updated HitPercentage to " .. tostring(_G.HitPercentage))
    return
end
_G.SilentAimLoaded = true

-- Disconnect previous connections safely
pcall(function()
    if _G.Stepped then _G.Stepped:Disconnect() end
    if _G.InputBegan then _G.InputBegan:Disconnect() end
end)

local Player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local IsInFooting = false
local Mode = "A"
local SelectedGoal = nil
local HighlightA, HighlightB

-- Find all goal parts
local Goals = {}
for _, obj in next, workspace:GetDescendants() do
    if obj:IsA("BasePart") and obj.Name == "Goal" then
        table.insert(Goals, obj)
    end
end

-- Simple highlight creation
local function CreateHighlight(target, color)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = target
    highlight.FillColor = color
    highlight.FillTransparency = 0.4
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0
    highlight.Parent = target
    return highlight
end

if Goals[1] then HighlightA = CreateHighlight(Goals[1], Color3.fromRGB(0, 255, 0)) end
if Goals[2] then HighlightB = CreateHighlight(Goals[2], Color3.fromRGB(255, 0, 0)) end

-- Garbage-collected functions
local XYZ = {"X1", "Y1", "Z1", "X2", "Y2", "Z2"}
local Selected
for _, v in next, getgc(true) do
    if type(v) == "function" and getinfo(v).name == "selected1" then
        Selected = v
    end
end

local Shuffled = {}
for _, t in next, getgc(true) do
    if type(t) == "table" and rawget(t, "1") and rawget(t, "1") ~= true then
        Shuffled = t
    end
end

local Clicker = getupvalue(Selected, 3)

local function GetKeyFromKeyTable()
    local Keys = getupvalue(Selected, 4)
    return Keys[1]
end

local function RemoveKeyFromKeyTable()
    local Keys = getupvalue(Selected, 4)
    table.remove(Keys, 1)
    setupvalue(Selected, 4, Keys)
end

local function GetRandomizedTable(TorsoPosition, ShootPosition)
    local UnrandomizedArgs = {
        X1 = TorsoPosition.X,
        Y1 = TorsoPosition.Y,
        Z1 = TorsoPosition.Z,
        X2 = ShootPosition.X,
        Y2 = ShootPosition.Y,
        Z2 = ShootPosition.Z
    }
    return {
        UnrandomizedArgs[Shuffled["1"]],
        UnrandomizedArgs[Shuffled["2"]],
        UnrandomizedArgs[Shuffled["3"]],
        UnrandomizedArgs[Shuffled["4"]],
        UnrandomizedArgs[Shuffled["5"]],
        UnrandomizedArgs[Shuffled["6"]],
    }
end

local function GetCorrectPosition(Position)
    return Position - Player.Character.Torso.Position
end

local function GetUnitPosition(Position)
    return Position.Unit
end

-- Goal and mode switching
UIS.InputBegan:Connect(function(Input, GPE)
    if GPE then return end
    if Input.KeyCode == Enum.KeyCode.Nine then
        SelectedGoal = Goals[1]
        if HighlightA then HighlightA.FillTransparency = 0.2 end
        if HighlightB then HighlightB.FillTransparency = 0.8 end
    elseif Input.KeyCode == Enum.KeyCode.Zero then
        SelectedGoal = Goals[2]
        if HighlightB then HighlightB.FillTransparency = 0.2 end
        if HighlightA then HighlightA.FillTransparency = 0.8 end
    elseif Input.KeyCode == Enum.KeyCode.One then Mode = "A"
    elseif Input.KeyCode == Enum.KeyCode.Two then Mode = "B"
    elseif Input.KeyCode == Enum.KeyCode.Three then Mode = "C"
    elseif Input.KeyCode == Enum.KeyCode.Four then Mode = "D" end
end)

local function GetGoal()
    return SelectedGoal or Goals[1]
end

local function GetDistance()
    local Goal = GetGoal()
    return (Player.Character.Torso.Position - Goal.Position).Magnitude
end

local function GetBasketball()
    return Player.Character:FindFirstChildOfClass("Folder")
end

local function IsDunkAnimPlaying()
    for _, Anim in next, Player.Character.Humanoid:GetPlayingAnimationTracks() do
        if Anim.Animation.Name == "Dunk1" then return true end
    end
    return false
end

local function InFootingCheck()
    local Distance = GetDistance()
    local Basketball = GetBasketball()
    IsInFooting = Basketball and Distance > 3 and Distance < 109
end

local DunkStartTime = nil

local function GetArc()
    local Distance = GetDistance()
    local Basketball = GetBasketball()
    if not Basketball then return 180, 100 end
    local Arc
    local Power = Basketball.PowerValue.Value
    local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")

    if Mode == "A" then
        -- Arc table for Mode A
        if Distance > 3 and Distance < 9 then Arc = 185
        elseif Distance > 9 and Distance < 15 then Arc = 180
        elseif Distance > 15 and Distance < 21 then Arc = 175
        elseif Distance > 21 and Distance < 27 then Arc = 170
        elseif Distance > 27 and Distance < 33 then Arc = 165
        elseif Distance > 33 and Distance < 39 then Arc = 160
        elseif Distance > 39 and Distance < 45 then Arc = 155
        elseif Distance > 45 and Distance < 51 then Arc = 150
        elseif Distance > 51 and Distance < 57 then Arc = 145
        elseif Distance > 57 and Distance < 63 then Arc = 140
        elseif Distance > 63 and Distance < 69 then Arc = 135
        elseif Distance > 69 and Distance < 74 then Arc = 130
        elseif Distance > 74 and Distance < 79 then Arc = 125
        elseif Distance > 79 and Distance < 82 then Arc = 120
        elseif Distance > 82 and Distance < 84 then Arc = 115
        elseif Distance > 84 and Distance < 88 then Arc = 110
        elseif Distance > 88 and Distance < 91 then Arc = 100
        elseif Distance > 91 and Distance < 92 then Arc = 90
        elseif Distance > 92 and Distance < 93 then Arc = 85
        elseif Distance > 93 and Distance < 94 then Arc = 80
        elseif Distance > 94 and Distance < 95 then Arc = 75
        elseif Distance > 95 and Distance < 96 then Arc = 70
        elseif Distance > 96 and Distance < 97 then Arc = 67
        elseif Distance > 97 and Distance < 100 then Arc = 145
        elseif Distance > 100 and Distance < 103 then Arc = 150
        elseif Distance > 103 and Distance < 106 then Arc = 155
        elseif Distance > 106 and Distance < 109 then Arc = 160
        end

        local isTouchingGround = humanoid and humanoid.FloorMaterial ~= Enum.Material.Air
        if IsDunkAnimPlaying() then
            if not DunkStartTime then DunkStartTime = tick() end
        else
            DunkStartTime = nil
        end

        if isTouchingGround then
            Arc = Arc - 20
        else
            if IsDunkAnimPlaying() and DunkStartTime and tick() - DunkStartTime >= 3 then
                Arc = Arc - 20
            else
                Arc = Arc - 10
            end
        end

        Power = 100
    elseif Mode == "B" then
        -- Mode B logic (same as before)
        if Distance > 3 and Distance < 9 then Arc = 1
        elseif Distance > 9 and Distance < 15 then Arc = 3
        elseif Distance > 15 and Distance < 21 then Arc = 6
        elseif Distance > 21 and Distance < 27 then Arc = 7
        elseif Distance > 27 and Distance < 33 then Arc = 8
        elseif Distance > 33 and Distance < 39 then Arc = 9
        elseif Distance > 39 and Distance < 45 then Arc = 10
        elseif Distance > 45 and Distance < 51 then Arc = 12
        elseif Distance > 51 and Distance < 57 then Arc = 6
        elseif Distance > 57 and Distance < 63 then Arc = 6
        elseif Distance > 63 and Distance < 69 then Arc = 11
        elseif Distance > 69 and Distance < 74 then Arc = 12
        elseif Distance > 74 and Distance < 79 then Arc = 13
        elseif Distance > 79 and Distance < 82 then Arc = 14
        elseif Distance > 82 and Distance < 84 then Arc = 40
        elseif Distance > 84 and Distance < 88 then Arc = 44
        elseif Distance > 88 and Distance < 91 then Arc = 48
        elseif Distance > 91 and Distance < 92 then Arc = 52
        elseif Distance > 92 and Distance < 93 then Arc = 56
        elseif Distance > 93 and Distance < 94 then Arc = 60
        elseif Distance > 94 and Distance < 95 then Arc = 73
        elseif Distance > 95 and Distance < 96 then Arc = 70
        elseif Distance > 96 and Distance < 97 then Arc = 67
        end
    elseif Mode == "C" then
        -- Mode C logic
        if Distance > 3 and Distance < 9 then Arc = 235
        elseif Distance > 9 and Distance < 15 then Arc = 230
        elseif Distance > 15 and Distance < 21 then Arc = 225
        elseif Distance > 21 and Distance < 27 then Arc = 220
        elseif Distance > 27 and Distance < 33 then Arc = 215
        elseif Distance > 33 and Distance < 39 then Arc = 210
        elseif Distance > 39 and Distance < 45 then Arc = 205
        elseif Distance > 45 and Distance < 51 then Arc = 200
        elseif Distance > 51 and Distance < 57 then Arc = 198
        elseif Distance > 57 and Distance < 63 then Arc = 189
        elseif Distance > 63 and Distance < 69 then Arc = 186
        elseif Distance > 69 and Distance < 74 then Arc = 180
        elseif Distance > 74 and Distance < 79 then Arc = 175
        elseif Distance > 79 and Distance < 82 then Arc = 170
        elseif Distance > 82 and Distance < 84 then Arc = 165
        elseif Distance > 84 and Distance < 88 then Arc = 165
        elseif Distance > 88 and Distance < 91 then Arc = 160
        elseif Distance > 91 and Distance < 92 then Arc = 160
        elseif Distance > 92 and Distance < 93 then Arc = 160
        end
    elseif Mode == "D" then
        -- Round or snap distance to 1 decimal place to stabilize conditions
        local RoundedDistance = math.floor(Distance * 10 + 0.5) / 10
    
        -- Optional: debug print (remove later)
        print("Distance:", RoundedDistance)

        if RoundedDistance >= 57 and RoundedDistance <= 59 then
            Power, Arc = 75, 55
        elseif RoundedDistance > 59 and RoundedDistance <= 60 then
            Power, Arc = 75, 50
        elseif RoundedDistance > 60 and RoundedDistance <= 62 then
            Power, Arc = 75, 48

        elseif RoundedDistance > 62 and RoundedDistance <= 65 then
            Power, Arc = 80, 60
        elseif RoundedDistance > 65 and RoundedDistance <= 67 then
            Power, Arc = 80, 50
        elseif RoundedDistance > 67 and RoundedDistance <= 68 then
            Power, Arc = 80, 45
            
        elseif RoundedDistance > 68 and RoundedDistance <= 70 then
            Power, Arc = 85, 70
        elseif RoundedDistance > 70 and RoundedDistance <= 73 then
            Power, Arc = 85, 60
    
        elseif RoundedDistance > 73 and RoundedDistance <= 77 then
            Power, Arc = 90, 75
        elseif RoundedDistance > 77 and RoundedDistance <= 79 then
            Power, Arc = 90, 65
    
        elseif RoundedDistance > 79 and RoundedDistance <= 82 then
            Power, Arc = 95, 75
        elseif RoundedDistance > 82 and RoundedDistance <= 84 then
            Power, Arc = 95, 65     
        elseif RoundedDistance > 84 and RoundedDistance <= 86 then
            Power, Arc = 95, 60
    
        elseif RoundedDistance > 86 and RoundedDistance <= 88 then
            Power, Arc = 100, 85
        elseif RoundedDistance > 88 and RoundedDistance <= 90 then
            Power, Arc = 100, 65
        elseif RoundedDistance > 90 and RoundedDistance <= 93 then
            Power, Arc = 100, 55
    
        else
            Power, Arc = 100, 160
        end
    
        -- Optional debug line
        print("Power:", Power, "Arc:", Arc)
    end

    return Arc, Power
end
-- Shoot function
local function Shoot()
    local Goal = GetGoal()
    if not Goal then return end
    local Arc, Power = GetArc()
    local TargetPosition = Goal.Position + Vector3.new(0, Arc, 0) + Player.Character.Humanoid.MoveDirection

    if math.random(1, 100) > _G.HitPercentage then
        TargetPosition += Vector3.new(math.random(-5,5), math.random(-5,5), math.random(-5,5))
    end

    local CorrectPosition = GetCorrectPosition(TargetPosition)
    local Position = GetUnitPosition(CorrectPosition)
    local RandomizedArgs = GetRandomizedTable(Player.Character.Torso.Position, Position)
    local Basketball = GetBasketball()
    local Key = GetKeyFromKeyTable()
    if type(Key) ~= "string" then Key = "Shotta" end
    Clicker:FireServer(Basketball, Power, RandomizedArgs, Key)
    if Key ~= "Shotta" then RemoveKeyFromKeyTable() end
end

-- Silent Aim toggle
local isEnabled = false
local XConnection

local function EnableSilentAim()
    if XConnection then XConnection:Disconnect() end
    _G.Stepped = RS.Stepped:Connect(InFootingCheck)

    XConnection = UIS.InputBegan:Connect(function(Input, GPE)
        if GPE or not isEnabled then return end
        if Input.KeyCode == Enum.KeyCode.X then
            task.spawn(function()
                local Ball = GetBasketball()
                if Player.Character and Ball and IsInFooting then
                    local currentDistance = GetDistance()
                    print("Mode:", Mode, "| Shooting from distance:", math.floor(currentDistance * 100) / 100)
                    if Mode == "D" then
                        Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        task.wait(0.23)
                    end
                    local success, err = pcall(Shoot)
                    if not success then warn("Shoot failed:", err) end
                end
            end)
        end
    end)
end

local function DisableSilentAim()
    if _G.Stepped then _G.Stepped:Disconnect() end
    if XConnection then XConnection:Disconnect() end
end

_G.InputBegan = UIS.InputBegan:Connect(function(Input, GPE)
    if GPE then return end
    if Input.KeyCode == Enum.KeyCode.K then
        isEnabled = not isEnabled
        print("Silent Aim is now " .. (isEnabled and "ON" or "OFF"))
        if isEnabled then
            EnableSilentAim()
        else
            DisableSilentAim()
        end
    end
end)

-- Rejoin same server on L key
do
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local UIS = game:GetService("UserInputService")

    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.L then
            print("[Silent Aim] Rejoining same server...")
            local player = Players.LocalPlayer
            local placeId = game.PlaceId
            local jobId = game.JobId
            task.wait(0.2)
            TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
        end
    end)
end

