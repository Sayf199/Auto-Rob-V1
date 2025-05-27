-- Jailbreak Full Auto Rob Script
-- UI + AntiAFK + KillAura + ServerHop
-- Made for GitHub loadstring execution

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Anti-AFK
for _,v in pairs(getconnections(LocalPlayer.Idled)) do
    v:Disable()
end

-- UI
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "AutoRobUI"

local frame = Instance.new("Frame", screenGui)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.Size = UDim2.new(0, 200, 0, 180)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.2
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "💰 Auto Rob UI"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.TextScaled = true

function createToggle(name, default)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, 30 + #frame:GetChildren()*35)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Text = name .. ": " .. (default and "ON" or "OFF")
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
    end)
    return function() return state end
end

local getAutoRob = createToggle("Auto Rob", true)
local getKillAura = createToggle("Kill Aura", true)
local getHop = createToggle("Server Hop", true)

-- Notifications
local function notify(msg)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Rob",
            Text = msg,
            Duration = 3
        })
    end)
end

local function safeTP(vec)
    pcall(function()
        HumanoidRootPart.CFrame = CFrame.new(vec)
    end)
end

local function isStoreOpen(name)
    local status = workspace:FindFirstChild("RobberyMarkers")
    if status then
        local marker = status:FindFirstChild(name)
        if marker and marker:IsA("Model") then
            local light = marker:FindFirstChild("Open")
            if light and light:IsA("BoolValue") then
                return light.Value
            end
        end
    end
    return false
end

local function killAura()
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Team.Name == "Police" then
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local dist = (char.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                if dist < 20 then
                    local weapon = LocalPlayer.Backpack:FindFirstChildOfClass("Tool") or Character:FindFirstChildOfClass("Tool")
                    if weapon then
                        weapon:Activate()
                        notify("⚠️ Police detected nearby!")
                    end
                end
            end
        end
    end
end

local function serverHop()
    notify("🔄 No stores open. Hopping server...")
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    for _,server in pairs(servers.data) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
            break
        end
    end
end

local stores = {
    {name="Bank", pos=Vector3.new(29, 18, 839)},
    {name="Museum", pos=Vector3.new(1075, 104, 1238)},
    {name="Jewelry", pos=Vector3.new(138, 18, 1347)},
    {name="PowerPlant", pos=Vector3.new(2636, 18, 1570)},
}

task.spawn(function()
    while task.wait(10) do
        if getAutoRob() then
            local robbed = false
            for _,store in pairs(stores) do
                pcall(function()
                    if isStoreOpen(store.name) then
                        notify("Robbing "..store.name)
                        safeTP(store.pos)
                        task.wait(3)
                        if ReplicatedStorage:FindFirstChild("Robbery") then
                            ReplicatedStorage.Robbery:FireServer(store.name)
                        end
                        robbed = true
                        task.wait(6)
                    end
                end)
            end
            if not robbed and getHop() then
                serverHop()
            end
        end
        if getKillAura() then
            killAura()
        end
    end
end)
