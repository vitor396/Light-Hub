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
)

-- ==========================
-- AUTO FARM PRO - ALL IN ONE
-- Usa: RedzLib window já criada (Window)
-- Cole após CheckQuest() e depois das abas
-- ==========================

local RunService = game:GetService("RunService")
local Replicated = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local VirtualInput = game:GetService("VirtualUser")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer

-- UTILIDADES
local function Char()
    return Player.Character or Player.CharacterAdded:Wait()
end
local function Root()
    local c = Char()
    return c:WaitForChild("HumanoidRootPart")
end
local function SafeTP(cframe)
    pcall(function() Root().CFrame = cframe end)
end
local function Click()
    pcall(function() VirtualInput:CaptureController(); VirtualInput:ClickButton1(Vector2.new(1,1)) end)
end

-- CONFIG GLOBAL
local FarmConfig = {
    Enabled = false,
    FastMode = false,
    SuperMode = false, -- super human/god human helpers
    Bring = true,
    Attack = true,
    AutoLoot = true,
    AutoMaterials = true,
    AntiKD = true,
    FarmSpeed = 300,
    ReachDistance = 8,
    UseBoat = true,
    AutoBoat = true,
    BossFarm = true
}

-- UI: Aba "Auto Pro"
local TabPro = Window:MakeTab({ Name = "Auto Pro" })
local SectionPro = TabPro:AddSection({ Name = "Auto Farm PRO" })

TabPro:AddToggle({ Name = "Auto Farm (Master)", Default = false, Callback = function(v) FarmConfig.Enabled = v end })
TabPro:AddToggle({ Name = "Fast Mode (teleport rápido)", Default = false, Callback = function(v) FarmConfig.FastMode = v end })
TabPro:AddToggle({ Name = "Super/God Helpers", Default = false, Callback = function(v) FarmConfig.SuperMode = v end })
TabPro:AddToggle({ Name = "Bring Mobs", Default = true, Callback = function(v) FarmConfig.Bring = v end })
TabPro:AddToggle({ Name = "Auto Attack", Default = true, Callback = function(v) FarmConfig.Attack = v end })
TabPro:AddToggle({ Name = "Auto Loot/Drops", Default = true, Callback = function(v) FarmConfig.AutoLoot = v end })
TabPro:AddToggle({ Name = "Auto Materials (auto requestEntrance)", Default = true, Callback = function(v) FarmConfig.AutoMaterials = v end })
TabPro:AddToggle({ Name = "Auto Boat Spawn", Default = true, Callback = function(v) FarmConfig.AutoBoat = v end })
TabPro:AddToggle({ Name = "Boss Farm", Default = true, Callback = function(v) FarmConfig.BossFarm = v end })
TabPro:AddSlider({ Name = "Farm Speed", Min = 50, Max = 1000, Increase = 10, Default = FarmConfig.FarmSpeed, Callback = function(val) FarmConfig.FarmSpeed = val end })

-- ESP simples (BillboardGui) para mobs ativos
local ESPFolder = Instance.new("Folder", workspace)
ESPFolder.Name = "AutoFarmESP"
local function CreateESPFor(model)
    if not model or not model.PrimaryPart then return end
    if model:FindFirstChild("AutoESP") then return end
    local bg = Instance.new("BillboardGui")
    bg.Name = "AutoESP"
    bg.Adornee = model.PrimaryPart
    bg.Size = UDim2.new(0,100,0,40)
    bg.AlwaysOnTop = true
    local txt = Instance.new("TextLabel", bg)
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.TextStrokeTransparency = 0
    txt.Text = model.Name
    txt.Font = Enum.Font.SourceSansBold
    txt.TextScaled = true
    bg.Parent = model
end
local function ClearESP()
    for _, m in pairs(workspace:GetDescendants()) do
        if m:IsA("BillboardGui") and m.Name == "AutoESP" then
            pcall(function() m:Destroy() end)
        end
    end
end

-- Bring mobs (coloca mob perto de você)
local function BringMobsByName(name)
    for _, mob in pairs(workspace:GetDescendants()) do
        if mob.Name == name and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") then
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            pcall(function()
                hrp.CFrame = Root().CFrame * CFrame.new(0,0,-FarmConfig.ReachDistance)
                if hrp.Parent and hrp.Parent:FindFirstChild("Humanoid") then
                    hrp.Parent.Humanoid.WalkSpeed = 0
                    hrp.Parent.Humanoid.JumpPower = 0
                end
            end)
        end
    end
end

-- Auto loot: pega itens perto do player
local function AutoLoot()
    if not FarmConfig.AutoLoot then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("TouchInterest") then
            pcall(function()
                local pos = obj:GetModelCFrame().p
                if (pos - Root().Position).Magnitude < 20 then
                    SafeTP(CFrame.new(pos + Vector3.new(0,3,0)))
                    task.wait(0.2)
                end
            end)
        end
    end
end

-- Auto material / requestEntrance helper baseado no info.txt examples
local function EnsureEntranceIfFar(cframeQuest)
    if not cframeQuest then return end
    if FarmConfig.AutoMaterials and (cframeQuest.Position - Root().Position).Magnitude > 10000 then
        pcall(function()
            Replicated.Remotes.CommF_:InvokeServer("requestEntrance", cframeQuest.Position)
        end)
    end
end

-- Auto attack (usa remotes que você tinha)
local function DoAttack()
    pcall(function()
        -- tenta usar remotes padrões. Ajuste se o jogo mudar nomes.
        if Replicated and Replicated:FindFirstChild("Remotes") and Replicated.Remotes:FindFirstChild("CommF_") then
            Replicated.Remotes.CommF_:InvokeServer("Attack")
        else
            Click()
        end
    end)
end

-- Spawn/TP Boat (tenta remoto que você já usou nos cases)
local function SpawnBoat()
    pcall(function()
        if Replicated and Replicated:FindFirstChild("Remotes") and Replicated.Remotes:FindFirstChild("CommF_") then
            -- request to spawn boat common remote (nome pode mudar)
            Replicated.Remotes.CommF_:InvokeServer("SpawnBoat")
        end
    end)
end

-- Detectar bosses e mob alvo (usa NameMon e CFrameMon da sua CheckQuest)
local function FindNearestTargetByName(name)
    local nearest, ndist = nil, math.huge
    for _, mob in pairs(workspace:GetDescendants()) do
        if mob.Name == name and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            local d = (mob.HumanoidRootPart.Position - Root().Position).Magnitude
            if d < ndist then nearest, ndist = mob, d end
        end
    end
    return nearest
end

-- Main farm loop (integra CheckQuest que você já tem)
task.spawn(function()
    while task.wait(0.25) do
        if not FarmConfig.Enabled then
            task.wait(0.5)
        else
            -- atualiza quest alvo via sua função CheckQuest()
            pcall(CheckQuest)

            -- tentar garantir entrada caso o quest seja muito longe
            if CFrameQuest then EnsureEntranceIfFar(CFrameQuest) end

            -- se não tiver quest ativa, pega a quest
            local hasQuest = false
            local success, gui = pcall(function() return Player.PlayerGui.Main.Quest.Visible end)
            if success and gui then hasQuest = Player.PlayerGui.Main.Quest.Visible end

            if not hasQuest then
                if CFrameQuest then
                    SafeTP(CFrameQuest + Vector3.new(0,4,0))
                    task.wait(0.5)
                    pcall(function()
                        Replicated.Remotes.CommF_:InvokeServer("StartQuest", NameQuest, LevelQuest)
                    end)
                    task.wait(0.6)
                end
            end

            -- prioridade: BossFarm (procura por monstros "boss" comuns: "Boss", "BigBoss", "SeaBeast", "Kraken")
            if FarmConfig.BossFarm then
                local bossNames = {"SeaBeast","Kraken","Leviathan","Boss","BigBoss"}
                for _, bname in pairs(bossNames) do
                    local b = FindNearestTargetByName(bname)
                    if b then
                        -- ir para boss
                        local pos = b:FindFirstChild("HumanoidRootPart") and b.HumanoidRootPart.Position or (b.PrimaryPart and b.PrimaryPart.Position)
                        if pos then
                            if FarmConfig.FastMode then
                                SafeTP(CFrame.new(pos + Vector3.new(0,20,0)))
                            else
                                -- movimento até o boss
                                local root = Root()
                                while (root.Position - pos).Magnitude > 8 and FarmConfig.Enabled do
                                    local dir = (pos - root.Position).Unit
                                    root.CFrame = CFrame.new(root.Position + dir * (FarmConfig.FarmSpeed * task.wait()), pos)
                                end
                            end
                            -- bring opcional
                            if FarmConfig.Bring then
                                BringMobsByName(b.Name)
                            end
                            -- attack loop curto
                            local t0 = tick()
                            while b and b:FindFirstChild("Humanoid") and b.Humanoid.Health > 0 and FarmConfig.Enabled do
                                if FarmConfig.Attack then DoAttack() end
                                task.wait(0.3)
                                if tick() - t0 > 60 then break end -- evita loop infinito
                            end
                            task.wait(0.5)
                        end
                        break
                    end
                end
            end

            -- se tem monster target por CheckQuest (NameMon)
            if NameMon then
                local target = FindNearestTargetByName(NameMon)
                if target then
                    local pos = target.HumanoidRootPart.Position
                    if FarmConfig.FastMode then
                        SafeTP(CFrame.new(pos + Vector3.new(0,8,0)))
                    else
                        local root = Root()
                        while (root.Position - pos).Magnitude > FarmConfig.ReachDistance and FarmConfig.Enabled do
                            local dir = (pos - root.Position).Unit
                            root.CFrame = CFrame.new(root.Position + dir * (FarmConfig.FarmSpeed * task.wait()), pos)
                        end
                    end

                    if FarmConfig.Bring then
                        BringMobsByName(NameMon)
                    end

                    -- ataque contínuo até morrer
                    local t0 = tick()
                    while target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 and FarmConfig.Enabled do
                        if FarmConfig.Attack then DoAttack() end
                        task.wait(0.2)
                        if tick() - t0 > 45 then break end
                    end
                else
                    -- ir para spawn do mob (CFrameMon)
                    if CFrameMon then
                        if FarmConfig.FastMode then
                            SafeTP(CFrameMon + Vector3.new(0,5,0))
                        else
                            SafeTP(CFrameMon + Vector3.new(0,5,0))
                        end
                    end
                end
            end

            -- Auto loot e materials
            if FarmConfig.AutoLoot then AutoLoot() end
            if FarmConfig.AutoMaterials and CFrameQuest then EnsureEntranceIfFar(CFrameQuest) end

            -- auto boat spawn se estiver configurado e estiver no mar
            if FarmConfig.AutoBoat and FarmConfig.UseBoat then
                pcall(SpawnBoat)
            end

            -- ESP: marca mobs do tipo NameMon
            ClearESP()
            for _, m in pairs(workspace:GetDescendants()) do
                if m:IsA("Model") and m:FindFirstChild("Humanoid") and (NameMon and m.Name == NameMon) then
                    pcall(function() CreateESPFor(m) end)
                end
            end

            task.wait(0.15)
        end
    end
end)

-- ==========================
-- FUNÇÕES AVANÇADAS (Super/God helpers)
-- ==========================
-- super mode: reduz knockback, aplica anti-stun, melhoria de ataque
task.spawn(function()
    while task.wait(1) do
        if FarmConfig.SuperMode then
            pcall(function()
                local char = Char()
                if char and char:FindFirstChildOfClass("Humanoid") then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    hum.WalkSpeed = 50 -- melhora mobilidade
                    hum.JumpPower = 75
                end
                -- tenta ativar hard remotes para dar vantagens (apenas se existirem)
                if Replicated and Replicated:FindFirstChild("Remotes") and Replicated.Remotes:FindFirstChild("CommF_") then
                    pcall(function()
                        Replicated.Remotes.CommF_:InvokeServer("SuperMode") -- pode falhar se não existir
                    end)
                end
            end)
        end
    end
end)

-- ==========================
-- TECLAS RAPIDAS
-- ==========================
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.F6 then
        FarmConfig.Enabled = not FarmConfig.Enabled
    elseif inp.KeyCode == Enum.KeyCode.F7 then
        FarmConfig.FastMode = not FarmConfig.FastMode
    elseif inp.KeyCode == Enum.KeyCode.F8 then
        FarmConfig.SuperMode = not FarmConfig.SuperMode
    end
end)

-- ==========================
-- FINAL
-- ==========================
print("[AutoFarm PRO] carregado. Toggle via RedzLib -> Auto Pro ou teclas F6 (on/off), F7 (fast), F8 (super).")
