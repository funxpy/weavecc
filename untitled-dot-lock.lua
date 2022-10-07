--[[
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
─██████──────────██████─██████████████─██████████████─██████──██████─██████████████────────██████████████─██████████████─
─██░░██──────────██░░██─██░░░░░░░░░░██─██░░░░░░░░░░██─██░░██──██░░██─██░░░░░░░░░░██────────██░░░░░░░░░░██─██░░░░░░░░░░██─
─██░░██──────────██░░██─██░░██████████─██░░██████░░██─██░░██──██░░██─██░░██████████────────██░░██████████─██░░██████████─
─██░░██──────────██░░██─██░░██─────────██░░██──██░░██─██░░██──██░░██─██░░██────────────────██░░██─────────██░░██─────────
─██░░██──██████──██░░██─██░░██████████─██░░██████░░██─██░░██──██░░██─██░░██████████────────██░░██─────────██░░██─────────
─██░░██──██░░██──██░░██─██░░░░░░░░░░██─██░░░░░░░░░░██─██░░██──██░░██─██░░░░░░░░░░██────────██░░██─────────██░░██─────────
─██░░██──██░░██──██░░██─██░░██████████─██░░██████░░██─██░░██──██░░██─██░░██████████────────██░░██─────────██░░██─────────
─██░░██████░░██████░░██─██░░██─────────██░░██──██░░██─██░░░░██░░░░██─██░░██────────────────██░░██─────────██░░██─────────
─██░░░░░░░░░░░░░░░░░░██─██░░██████████─██░░██──██░░██─████░░░░░░████─██░░██████████─██████─██░░██████████─██░░██████████─
─██░░██████░░██████░░██─██░░░░░░░░░░██─██░░██──██░░██───████░░████───██░░░░░░░░░░██─██░░██─██░░░░░░░░░░██─██░░░░░░░░░░██─
─██████──██████──██████─██████████████─██████──██████─────██████─────██████████████─██████─██████████████─██████████████─
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
]]





local settings = {
    main = {
        DotEnabled = true,
        Prediction = 0.135,
        Part = "HumanoidRootPart",
        Key = "q",
        Notifications = true,
        AirshotFunc = true
    },
    Dot = {
        Show = true,
        Color = Color3.fromRGB(0, 0, 128),
        Size = Vector3.new(0.9, 1.2, 0.9)
    }
}






local CurrentCamera = game:GetService "Workspace".CurrentCamera
local Mouse = game.Players.LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local Plr = game.Players.LocalPlayer

local Part = Instance.new("Part", game.Workspace)
Part.Anchored = true
Part.CanCollide = false
Part.Parent = game.Workspace
Part.Shape = Enum.PartType.Ball
Part.Size = settings.Dot.Size
Part.Color = settings.Dot.Color

if settings.Dot.Show == true then
    Part.Transparency = 0
else
    Part.Transparency = 1
end

Mouse.KeyDown:Connect(function(KeyPressed)
    if KeyPressed == (settings.main.Key) then
        if settings.main.DotEnabled == true then
            settings.main.DotEnabled = false
            if settings.main.Notifications == true then
                Plr = FindClosestUser()
                game.StarterGui:SetCore("SendNotification", {
                    Title = "weave.cc",
                    Text = "unlocked"
                })
            end
        else
            Plr = FindClosestUser()
            settings.main.DotEnabled = true
            if settings.main.Notifications == true then
                game.StarterGui:SetCore("SendNotification", {
                    Title = "weave.cc",
                    Text = "Locked: " .. tostring(Plr.Character.Humanoid.DisplayName)
                })
            end
        end
    end
end)

function FindClosestUser()
    local closestPlayer
    local shortestDistance = math.huge

    for i, v in pairs(game.Players:GetPlayers()) do
        if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and
            v.Character.Humanoid.Health ~= 0 and v.Character:FindFirstChild("HumanoidRootPart") then
            local pos = CurrentCamera:WorldToViewportPoint(v.Character.PrimaryPart.Position)
            local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).magnitude
            if magnitude < shortestDistance then
                closestPlayer = v
                shortestDistance = magnitude
            end
        end
    end
    return closestPlayer
end

RunService.Stepped:connect(function()
    if settings.main.DotEnabled and Plr.Character and Plr.Character:FindFirstChild("LowerTorso") then
        Part.CFrame = CFrame.new(Plr.Character[settings.main.Part].Position +
                                     (Plr.Character.LowerTorso.Velocity * settings.main.Prediction))
    else
        Part.CFrame = CFrame.new(0, 9999, 0)

    end
end)

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(...)
    local args = {...}
    if settings.main.DotEnabled and getnamecallmethod() == "FireServer" and args[2] == "UpdateMousePos" then
        args[3] = Plr.Character[settings.main.Part].Position +
                      (Plr.Character[settings.main.Part].Velocity * settings.main.Prediction)
        return old(unpack(args))
    end
    return old(...)
end)


if settings.main.AirshotFunc == true then
    if Plr.Character.Humanoid.Jump == true and Plr.Character.Humanoid.FloorMaterial == Enum.Material.Air then
        settings.main.Part = "RightFoot"
    else
        Plr.Character:WaitForChild("Humanoid").StateChanged:Connect(function(old,new)
            if new == Enum.HumanoidStateType.Freefall then
                settings.main.Part = "RightFoot"
            else
                settings.main.Part = "LowerTorso"
            end
        end)
    end
end
