setfpscap(120)

local Library = loadstring(game:HttpGet("https://pastebin.com/raw/vff1bQ9F"))()
local Window = Library.CreateLib("ViuxHob", "DarkTheme")

-- Main Tab
local Tab = Window:NewTab("Main")
local Main = Tab:NewSection("Combat")

Main:NewToggle("Auto Parry", "Auto Parry the ball if it's close & is targeting you.", function(state)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local workspace = game:GetService("Workspace")
    local vim = game:GetService("VirtualInputManager")
    local ballFolder = workspace.Balls

    local indicatorPart = Instance.new("Part")
    indicatorPart.Size = Vector3.new(5, 5, 5)
    indicatorPart.Anchored = true
    indicatorPart.CanCollide = false
    indicatorPart.Transparency = 1
    indicatorPart.BrickColor = BrickColor.new("Bright red")
    indicatorPart.Parent = workspace

    local lastBallPressed, isKeyPressed = nil, false

    local function calculatePredictionTime(ball, player)
        local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local relativePosition = ball.Position - rootPart.Position
            local velocity = ball.Velocity + rootPart.Velocity 
            local a = ball.Size.magnitude / 2
            local b = relativePosition.magnitude
            local c = math.sqrt(a * a + b * b)
            return (c - a) / velocity.magnitude
        end
        return math.huge
    end

    local function checkProximityToPlayer(ball, player)
        local predictionTime = calculatePredictionTime(ball, player)
        local realBallAttribute = ball:GetAttribute("realBall")
        local target = ball:GetAttribute("target")

        local ballSpeedThreshold = math.max(0.4, 0.6 - ball.Velocity.magnitude * 0.01)
        if predictionTime <= ballSpeedThreshold and realBallAttribute and target == player.Name and not isKeyPressed then
            vim:SendKeyEvent(true, Enum.KeyCode.F, false, nil)
            wait(0.005)
            vim:SendKeyEvent(false, Enum.KeyCode.F, false, nil)
            lastBallPressed = ball
            isKeyPressed = true
        elseif lastBallPressed == ball and (predictionTime > ballSpeedThreshold or not realBallAttribute or target ~= player.Name) then
            isKeyPressed = false
        end
    end

    local function checkBallsProximity()
        local player = players.LocalPlayer
        if player then
            for _, ball in pairs(ballFolder:GetChildren()) do
                checkProximityToPlayer(ball, player)
            end
        end
    end

    if state then
        runService.Heartbeat:Connect(checkBallsProximity)
    else
        lastBallPressed = nil
        isKeyPressed = false
    end
end)
