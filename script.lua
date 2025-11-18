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
    Name = "Desplock hub | Community",
    Description = "Entre pra receber atualizações sobre o script!",
    Logo = "rbxassetid://131723242350068",
    Invite = "https://discord.gg/ccmPVMBV7Q",
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

local TabSea = Window:MakeTab({
    Name = "Sea Events"
})

local SectionSea = TabSea:AddSection({
    Name = "Auto Sea Events"
})

local SeaEvents = {
    Enabled = false,
    Speed = 250,
    Attack = true,
    AttackType = "Melee"
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local function GetChar()
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    player.Character:WaitForChild("HumanoidRootPart")
    return player.Character
end

local function NoClip(state)
    local char = GetChar()
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("BasePart") then
            v.CanCollide = not state
        end
    end
end

local function MoveTo(position)
    local char = GetChar()
    local Root = char.HumanoidRootPart
    NoClip(true)

    while SeaEvents.Enabled and (Root.Position - position).Magnitude > 5 do
        local dir = (position - Root.Position).Unit
        local step = dir * (SeaEvents.Speed * task.wait())
        Root.CFrame = CFrame.new(Root.Position + step, position)
    end
    
    NoClip(false)
end

local function FindEvent()
    local foundEvent = nil

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "SeaBeast" and obj:IsA("Model") then
            foundEvent = obj
        end
        if obj.Name == "Kraken" and obj:IsA("Model") then
            foundEvent = obj
        end
        if obj.Name == "PirateBrigade" and obj:IsA("Model") then
            foundEvent = obj
        end
        if obj.Name == "Leviathan" and obj:IsA("Model") then
            foundEvent = obj
        end
    end

    return foundEvent
end

--// 🔥 Função de ATAQUE
local function AttackTarget(target)
    if not SeaEvents.Attack then return end
    if not target then return end

    local char = GetChar()
    local Root = char.HumanoidRootPart
    local targetPart = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart

    if not targetPart then return end

    -- AIMLOCK (vira pro evento)
    Root.CFrame = CFrame.new(Root.Position, targetPart.Position)

    -- ATAQUE REAL
    if SeaEvents.AttackType == "Melee" then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AttackMelee")
    end

    if SeaEvents.AttackType == "Sword" then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AttackSword")
    end

    if SeaEvents.AttackType == "Fruit" then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AttackBloxFruit")
    end
end

-- LOOP PRINCIPAL
local function MainSea()
    while SeaEvents.Enabled do
        local event = FindEvent()
        if event then
            local part = event:FindFirstChild("HumanoidRootPart") or event.PrimaryPart
            if part then
                MoveTo(part.Position + Vector3.new(0, 15, 0)) -- Fica em cima do monstro
                AttackTarget(event)
            end
        end
        task.wait(0.2)
    end
end

--// 🔥 UI OPTIONS
TabSea:AddToggle({
    Name = "Auto Sea Events",
    Default = false,
    Callback = function(v)
        SeaEvents.Enabled = v
        if v then
            task.spawn(MainSea)
        end
    end
})

TabSea:AddToggle({
    Name = "Auto Attack",
    Default = true,
    Callback = function(v)
        SeaEvents.Attack = v
    end
})

TabSea:AddDropdown({
    Name = "Tipo de ataque",
    Options = {"Melee", "Sword", "Fruit"},
    Default = "Melee",
    Callback = function(v)
        SeaEvents.AttackType = v
    end
})

