-- Rune Slayer - Basic - Made by toto
local player = game:GetService("Players").LocalPlayer
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local speed = 16
local enabled = false -- Walkspeed toggle
local antiFall = false -- Anti-Fall toggle
local infiniteJump = false -- Infinite Jump toggle
local noclip = false -- NoClip toggle

local walkSpeedKey = Enum.KeyCode.F
local antiFallKey = Enum.KeyCode.G
local jumpKey = Enum.KeyCode.Space
local noclipKey = Enum.KeyCode.V

local platformLifetime = 0.5

local function resetCharacterFunctions(character)
    -- Wait for necessary parts
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    -- Re-enable NoClip for new character
    setNoClip(noclip)

    -- Monitor fall again
    monitorFall()

    -- Enable infinite jump again
    if infiniteJump then
        enableInfiniteJump()
    end

    -- Handle WalkSpeed again
    if enabled then
        moveCharacter()
    end
end

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Position = UDim2.new(0.3, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 350, 0, 300)
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 0
Frame.ClipsDescendants = true

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = Frame
ScrollingFrame.Position = UDim2.new(0, 0, 0.1, 0)
ScrollingFrame.Size = UDim2.new(1, 0, 1, -30)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
ScrollingFrame.ScrollBarThickness = 8
ScrollingFrame.BackgroundTransparency = 1

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Text = "Rune Slayer - Basic - Made by Totonio"
Title.Size = UDim2.new(1, 0, 0.1, 0)
Title.BackgroundTransparency = 1
Title.TextScaled = true
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSans

-- Button Creation Function
local function createButton(text, parent)
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.Text = text
    button.Size = UDim2.new(1, 0, 0.2, 0)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSans
    button.TextScaled = true
    return button
end

-- Create buttons
local ToggleButton = createButton("Enable Walkspeed", ScrollingFrame)
local AntiFallButton = createButton("Enable Anti-Fall", ScrollingFrame)
local InfiniteJumpButton = createButton("Enable Infinite Jump", ScrollingFrame)
local NoClipButton = createButton("Enable NoClip", ScrollingFrame)

-- Platform Creation for Infinite Jump
local function createInvisiblePlatform(rootPart)
    local platform = Instance.new("Part")
    platform.Size = Vector3.new(4, 1, 4)
    platform.Position = rootPart.Position - Vector3.new(0, 3, 0)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 1
    platform.Parent = workspace
    game.Debris:AddItem(platform, platformLifetime)
end

-- Fixed Infinite Jump
local function enableInfiniteJump()
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if infiniteJump then
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                createInvisiblePlatform(game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart"))
            end
        end
    end)
end

-- Improved Anti-Fall (Slows Falling Velocity)
local function monitorFall()
    local rootPart = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    runService.Stepped:Connect(function()
        if antiFall then
            local velocity = rootPart.Velocity
            if velocity.Y < -10 then -- Only slow falling
                rootPart.Velocity = Vector3.new(velocity.X, -5, velocity.Z)
            end
        end
    end)
end

-- NoClip Toggle
local function setNoClip(state)
    noclip = state
    NoClipButton.Text = noclip and "Disable NoClip" or "Enable NoClip" -- Update button text

    local function noClipStep()
        if noclip then
            for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        else
            -- Restore collision when noclip is off
            for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end

    if noclip then
        runService.Stepped:Connect(noClipStep)
    else
        -- Ensure no-clip state is correctly reset
        for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- CFrame Walkspeed
local function moveCharacter()
    local connection
    connection = runService.RenderStepped:Connect(function()
        local character = game.Players.LocalPlayer.Character
        if not enabled or not character then
            connection:Disconnect()
            return
        end

        local rootPart = character:WaitForChild("HumanoidRootPart")
        local moveDirection = Vector3.new(0, 0, 0)
        if userInput:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + (workspace.CurrentCamera.CFrame.LookVector * speed * 0.05)
        end
        if userInput:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - (workspace.CurrentCamera.CFrame.LookVector * speed * 0.05)
        end
        if userInput:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - (workspace.CurrentCamera.CFrame.RightVector * speed * 0.05)
        end
        if userInput:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + (workspace.CurrentCamera.CFrame.RightVector * speed * 0.05)
        end
        rootPart.CFrame = rootPart.CFrame + moveDirection
    end)
end

-- Button Click Events
ToggleButton.MouseButton1Click:Connect(function()
    enabled = not enabled
    ToggleButton.Text = enabled and "Disable Walkspeed" or "Enable Walkspeed"
    moveCharacter()
end)

AntiFallButton.MouseButton1Click:Connect(function()
    antiFall = not antiFall
    AntiFallButton.Text = antiFall and "Disable Anti-Fall" or "Enable Anti-Fall"
end)

InfiniteJumpButton.MouseButton1Click:Connect(function()
    infiniteJump = not infiniteJump
    InfiniteJumpButton.Text = infiniteJump and "Disable Infinite Jump" or "Enable Infinite Jump"
    if infiniteJump then
        enableInfiniteJump()
    end
end)

NoClipButton.MouseButton1Click:Connect(function()
    noclip = not noclip
    setNoClip(noclip)
end)

-- Keybinds
userInput.InputBegan:Connect(function(input)
    if input.KeyCode == walkSpeedKey then
        ToggleButton.MouseButton1Click()
    elseif input.KeyCode == antiFallKey then
        AntiFallButton.MouseButton1Click()
    elseif input.KeyCode == jumpKey then
        InfiniteJumpButton.MouseButton1Click()
    elseif input.KeyCode == noclipKey then
        NoClipButton.MouseButton1Click()
    end
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(character)
    -- Reset the functions on respawn
    resetCharacterFunctions(character)
end)

monitorFall() -- Start Anti-Fall monitoring
