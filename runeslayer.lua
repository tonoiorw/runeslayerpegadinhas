local library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()
local Wait = library.subs.Wait -- Only returns if the GUI has not been terminated. For 'while Wait() do' loops

local PepsisWorld = library:CreateWindow({
    Name = "Pepsi's World",
    Themeable = {
        Info = "Discord Server: VzYTJ7Y"
    }
})

local GeneralTab = PepsisWorld:CreateTab({
    Name = "General"
})

local PlayerSection = GeneralTab:CreateSection({
    Name = "Player Controls"
})

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
local character, rootPart, humanoid

-- Function to update character references
local function updateCharacter(newCharacter)
    character = newCharacter
    rootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")

    -- Reapply active features
    if antiFall then monitorFall() end
    if infiniteJump then enableInfiniteJump() end
    if noclip then setNoClip(true) end
end

-- Monitor respawn
player.CharacterAdded:Connect(updateCharacter)
updateCharacter(player.Character or player.CharacterAdded:Wait())

-- WalkSpeed Toggle
PlayerSection:AddToggle({
    Name = "Enable Walkspeed",
    Flag = "PlayerSection_WalkSpeed",
    Callback = function(Value)
        enabled = Value
        if enabled then
            moveCharacter()
        end
    end
})

-- Anti-Fall Toggle
PlayerSection:AddToggle({
    Name = "Enable Anti-Fall",
    Flag = "PlayerSection_AntiFall",
    Callback = function(Value)
        antiFall = Value
        if antiFall then
            monitorFall()
        end
    end
})

-- Infinite Jump Toggle
PlayerSection:AddToggle({
    Name = "Enable Infinite Jump",
    Flag = "PlayerSection_InfiniteJump",
    Callback = function(Value)
        infiniteJump = Value
        if infiniteJump then
            enableInfiniteJump()
        end
    end
})

-- NoClip Toggle
PlayerSection:AddToggle({
    Name = "Enable NoClip",
    Flag = "PlayerSection_NoClip",
    Callback = function(Value)
        setNoClip(Value)
    end
})

-- Keybinds for Walkspeed, Anti-Fall, Infinite Jump, NoClip
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == walkSpeedKey then
        PlayerSection.Flags["PlayerSection_WalkSpeed"].Callback(not enabled)
    elseif input.KeyCode == antiFallKey then
        PlayerSection.Flags["PlayerSection_AntiFall"].Callback(not antiFall)
    elseif input.KeyCode == jumpKey then
        PlayerSection.Flags["PlayerSection_InfiniteJump"].Callback(not infiniteJump)
    elseif input.KeyCode == noclipKey then
        PlayerSection.Flags["PlayerSection_NoClip"].Callback(not noclip)
    end
end)

-- Platform Creation for Infinite Jump
local function createInvisiblePlatform()
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
        if infiniteJump and rootPart then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            createInvisiblePlatform()
        end
    end)
end

-- Improved Anti-Fall (Slows Falling Velocity)
local function monitorFall()
    runService.Stepped:Connect(function()
        if antiFall and rootPart then
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

    local function noClipStep()
        if noclip and character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end

    if noclip then
        runService.Stepped:Connect(noClipStep)
    else
        for _, part in pairs(character:GetDescendants()) do
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
        if not enabled or not rootPart then
            connection:Disconnect()
            return
        end

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

-- Wait for the GUI to be active
Wait()  -- This ensures the script continues running as long as the GUI is active
