local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/tbao143/Library-ui/refs/heads/main/Redzhubui"))()

local Window = redzlib:MakeWindow({
  Title = "LightHub: BloxFruits",
  SubTitle = "by Star",
  SaveFolder = "LightHub_v1"
})

Window:AddMinimizeButton({
    Button = { Image = "rbxassetid://124917680185900", BackgroundTransparency = 1 },
    Corner = { CornerRadius = UDim.new(0, 6) },
})

local Tab1 = Window:MakeTab({"Discord", "Info"})

Tab1:AddDiscordInvite({
    Name = "StarVerse | Community",
    Description = "Entre pra receber atualizações sobre o script!",
    Logo = "rbxassetid://1429259070707073097",
    Invite = "https://discord.gg/C47PMD64f",
})

local TabMain = Window:MakeTab({"Main", "home"})

local Section = TabMain:AddSection({"Combate"})

--// SPEED & JUMP
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")

local desiredSpeed = 48
local desiredJump = 50
local propertyConnection
local heartbeatConn
local charAddedConn

local function applyValues()
    if humanoid and humanoid.Parent then
        pcall(function()
            humanoid.WalkSpeed = desiredSpeed
            humanoid.JumpPower = desiredJump
        end)
    end
end

local function onWalkSpeedChanged()
    if humanoid and humanoid.WalkSpeed ~= desiredSpeed then
        pcall(function() humanoid.WalkSpeed = desiredSpeed end)
    end
end

local function bindHumanoid(h)
    if propertyConnection then propertyConnection:Disconnect() end
    humanoid = h
    applyValues()
    if humanoid then
        propertyConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(onWalkSpeedChanged)
    end
end

local function onCharacterAdded(char)
    local h = char:WaitForChild("Humanoid")
    bindHumanoid(h)
end

bindHumanoid(humanoid)
charAddedConn = player.CharacterAdded:Connect(onCharacterAdded)

heartbeatConn = RunService.Heartbeat:Connect(function()
    if humanoid and humanoid.Parent then
        pcall(function()
            if humanoid.WalkSpeed ~= desiredSpeed then humanoid.WalkSpeed = desiredSpeed end
            if humanoid.JumpPower ~= desiredJump then humanoid.JumpPower = desiredJump end
        end)
    end
end)

TabMain:AddSlider({
    Name = "Speed",
    Min = 1,
    Max = 500,
    Increase = 1,
    Default = desiredSpeed,
    Callback = function(Value)
        desiredSpeed = Value
        applyValues()
    end
})

TabMain:AddSlider({
    Name = "Jump Power",
    Min = 10,
    Max = 500,
    Increase = 1,
    Default = desiredJump,
    Callback = function(Value)
        desiredJump = Value
        applyValues()
    end
})

local TabFarm = Window:MakeTab({"Farm", "Swords"})

local Selection = TabFarm:AddSection({"Farm-Chests"})

--// AUTO CHEST FARM
local AutoChest = { Enabled = false, MaxSpeed = 300 }

local function getCharacter()
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    player.Character:WaitForChild("HumanoidRootPart")
    return player.Character
end

local function DistanceFromPlrSort(ObjectList)
    local RootPart = getCharacter().HumanoidRootPart
    table.sort(ObjectList, function(ChestA, ChestB)
        return (RootPart.Position - ChestA.Position).Magnitude < (RootPart.Position - ChestB.Position).Magnitude
    end)
end

local UncheckedChests, FirstRun = {}, true
local function getChestsSorted()
    if FirstRun then
        FirstRun = false
        for _, Object in pairs(game:GetDescendants()) do
            if Object.Name:find("Chest") and Object.ClassName == "Part" then
                table.insert(UncheckedChests, Object)
            end
        end
    end
    local Chests = {}
    for _, Chest in pairs(UncheckedChests) do
        if Chest:FindFirstChild("TouchInterest") then
            table.insert(Chests, Chest)
        end
    end
    DistanceFromPlrSort(Chests)
    return Chests
end

local function toggleNoclip(Toggle)
    for _, v in pairs(getCharacter():GetChildren()) do
        if v:IsA("BasePart") then
            v.CanCollide = not Toggle
        end
    end
end

local function Teleport(Goal)
    toggleNoclip(true)
    local RootPart = getCharacter().HumanoidRootPart
    local Magnitude = (RootPart.Position - Goal.Position).Magnitude
    local targetY = Goal.Position.Y + 3

    while AutoChest.Enabled and Magnitude > 5 do
        local Speed = AutoChest.MaxSpeed
        local currentPos = RootPart.Position
        local direction = (Vector3.new(Goal.Position.X, targetY, Goal.Position.Z) - currentPos).Unit
        local moveStep = direction * (Speed * task.wait())
        RootPart.Velocity = Vector3.zero
        RootPart.CFrame = CFrame.new(currentPos + moveStep, Goal.Position)
        Magnitude = (RootPart.Position - Goal.Position).Magnitude
    end

    toggleNoclip(false)
    RootPart.CFrame = Goal
end

local function main()
    while AutoChest.Enabled do
        local Chests = getChestsSorted()
        if #Chests > 0 then
            Teleport(Chests[1].CFrame)
        else
            task.wait(2)
        end
        task.wait(0.5)
    end
end

TabFarm:AddToggle({
    Name = "AutoChest",
    Default = false,
    Callback = function(Value)
        AutoChest.Enabled = Value
        if Value then
            task.spawn(main)
        end
    end
})



