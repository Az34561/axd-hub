--══════════════════════════════════════════════════════════════
--  AxD Hub v1.3 | Chilli Style | Fix Button & Panel Center
--══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

--═════════════ CONFIG ICONS ═════════════
local CustomEggIcons = {
    -- ["NamaEgg"] = "rbxassetid://000000"
}

--═════════════ STATE ═════════════
local SelectedEggs = {}
local AutoSteal = false
local AntiHit = false
local AntiGuard = false
local Running = true
local TargetEggName = nil

--═════════════ HELPERS ═════════════
local function new(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function corner(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 4)
    c.Parent = o
end

local function stroke(o, color, thick)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(0, 0, 0)
    s.Thickness = thick or 2
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = o
end

local function drag(frame, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function getHRP()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart") or nil
end

local function teleportTo(cf)
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = cf
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end

--═════════════ EGG SCAN ═════════════
local function scanEggs()
    local list = {}
    for _, o in ipairs(Workspace:GetDescendants()) do
        if o:IsA("Model") and o.Name:lower():find("egg") then
            local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart", true)
            if p then
                local icon = CustomEggIcons[o.Name]
                if not icon then
                    for _, d in ipairs(o:GetDescendants()) do
                        if (d:IsA("Decal") or d:IsA("Texture")) and d.Texture ~= "" then
                            icon = d.Texture
                            break
                        end
                    end
                end
                list[o.Name] = { model = o, part = p, icon = icon }
            end
        end
    end
    return list
end

local function findEgg(name)
    for _, o in ipairs(Workspace:GetDescendants()) do
        if o:IsA("Model") and o.Name == name then
            local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart", true)
            if p then return { model = o, part = p } end
        end
    end
    return nil
end

local function findSafeZone()
    for _, o in ipairs(Workspace:GetDescendants()) do
        local n = o.Name:lower()
        if n:find("safezone") or n:find("base") or n:find("spawn") then
            if o:IsA("BasePart") then return o end
            if o:IsA("Model") then
                local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart", true)
                if p then return p end
            end
        end
    end
    return nil
end

--═════════════ STEAL LOGIC ═════════════
local function startStealLoop()
    task.spawn(function()
        while Running do
            if AutoSteal then
                local target = nil
                if TargetEggName then
                    if SelectedEggs[TargetEggName] then target = findEgg(TargetEggName) end
                else
                    for name, active in pairs(SelectedEggs) do
                        if active then
                            target = findEgg(name)
                            if target then break end
                        end
                    end
                end

                if target then
                    local hrp = getHRP()
                    if hrp then
                        teleportTo(target.part.CFrame + Vector3.new(0, 3, 0))
                        task.wait(0.08)
                        
                        for _, d in ipairs(target.model:GetDescendants()) do
                            if d:IsA("ProximityPrompt") then pcall(function() fireproximityprompt(d) end) end
                        end
                        for _, p in ipairs(target.model:GetDescendants()) do
                            if p:IsA("BasePart") then
                                pcall(function() firetouchinterest(hrp, p, 0) end)
                                pcall(function() firetouchinterest(hrp, p, 1) end)
                            end
                        end
                        
                        task.wait(0.1)
                        local safe = findSafeZone()
                        if safe then teleportTo(safe.CFrame + Vector3.new(0, 3, 0)) end
                        task.wait(0.1)
                    end
                else
                    task.wait(0.5)
                end
            else
                task.wait(0.5)
            end
            task.wait(0.05)
        end
    end)
end
startStealLoop()

--═════════════ GUARD LOGIC ═════════════
RunService.Heartbeat:Connect(function()
    if not Running then return end
    
    if AntiHit then
        local char = LP.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end
    end

    if AntiGuard then
        for _, m in ipairs(Workspace:GetDescendants()) do
            if m:IsA("Model") and m ~= LP.Character then
                local hum = m:FindFirstChildOfClass("Humanoid")
                if hum and (m.Name:lower():find("guard") or m.Name:lower():find("npc") or m.Name:lower():find("police")) then
                    hum.WalkSpeed = 0
                    hum.JumpPower = 0
                end
            end
        end
    end
end)

--═════════════ UI CREATION ═════════════
local gui = new("ScreenGui", { 
    Name = "AxDHubV1", 
    ResetOnSpawn = false, 
    IgnoreGuiInset = true, 
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999 -- FIX: Biar selalu di paling atas
}, PG)

local RedTheme = Color3.fromRGB(190, 40, 40)
local DarkBG = Color3.fromRGB(20, 20, 20)
local PanelBG = Color3.fromRGB(30, 30, 30)
local TextColor = Color3.fromRGB(255, 255, 255)

-- ⚡ TOMBOL BULAT (FIX TENGAH & DRAG)
local circle = new("TextButton", {
    Parent = gui, 
    Size = UDim2.fromOffset(50, 50), 
    AnchorPoint = Vector2.new(0.5, 0.5), -- Biar center beneran
    Position = UDim2.fromScale(0.5, 0.5), -- Mulai di tengah layar
    BackgroundColor3 = RedTheme, 
    Text = "AxD", 
    TextColor3 = TextColor, 
    Font = Enum.Font.GothamBlack, 
    TextSize = 18,
    AutoButtonColor = false, 
    Visible = true, 
    ZIndex = 50
})
corner(circle, 25)
stroke(circle, Color3.fromRGB(0,0,0), 2)

local draggingBtn, dragStartBtn, startPosBtn, movedBtn = false, nil, nil, 0
circle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingBtn = true
        dragStartBtn = input.Position
        startPosBtn = circle.Position
        movedBtn = 0
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingBtn and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartBtn
        movedBtn = movedBtn + math.abs(delta.X) + math.abs(delta.Y)
        circle.Position = UDim2.new(startPosBtn.X.Scale, startPosBtn.X.Offset + delta.X, startPosBtn.Y.Scale, startPosBtn.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if draggingBtn and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        draggingBtn = false
        if movedBtn < 10 then -- Kalau gerakan dikit, anggap ngeklik
            circle.Visible = false
            main.Visible = true
            task.spawn(function() pcall(renderEggs) end)
        end
    end
end)

-- Main Panel (FIX TENGAH)
local main = new("Frame", {
    Parent = gui, 
    Size = UDim2.fromOffset(450, 300), 
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), -- Selalu di tengah layar
    BackgroundColor3 = DarkBG, 
    Visible = false, 
    ZIndex = 10
})
corner(main, 6)
stroke(main, Color3.fromRGB(0,0,0), 2)

-- Title Bar
local titleBar = new("Frame", {
    Parent = main, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = RedTheme, ZIndex = 11
})
corner(titleBar, 6)
new("TextLabel", {
    Parent = titleBar, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
    Text = "AxD Hub v1", TextColor3 = TextColor, Font = Enum.Font.GothamBlack, TextSize = 18,
    ZIndex = 12
})

-- Tombol Minimize (-)
local minBtn = new("TextButton", {
    Parent = titleBar, Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -70, 0, 2),
    BackgroundColor3 = Color3.fromRGB(50, 50, 50), Text = "-", TextColor3 = TextColor, Font = Enum.Font.GothamBlack, TextSize = 16, ZIndex = 12
})
corner(minBtn, 4)

-- Tombol Close (X)
local closeBtn = new("TextButton", {
    Parent = titleBar, Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -35, 0, 2),
    BackgroundColor3 = Color3.fromRGB(0,0,0), Text = "X", TextColor3 = TextColor, Font = Enum.Font.GothamBlack, TextSize = 14, ZIndex = 12
})
corner(closeBtn, 4)

drag(main, titleBar)

-- Side Nav (Kiri)
local navL = new("Frame", {
    Parent = main, Size = UDim2.fromOffset(100, 265), Position = UDim2.fromOffset(0, 35), BackgroundTransparency = 1, ZIndex = 11
})
local navLayout = new("UIListLayout", { Parent = navL, Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center })

local function createNavBtn(txt, parent)
    local b = new("TextButton", {
        Parent = parent, Size = UDim2.fromOffset(100, 35), BackgroundColor3 = RedTheme,
        Text = txt, TextColor3 = TextColor, Font = Enum.Font.GothamBold, TextSize = 14, AutoButtonColor = false
    })
    corner(b, 4)
    stroke(b, Color3.fromRGB(0,0,0), 1.5)
    return b
end

local btnStealTab = createNavBtn("Steal", navL)
local btnGuardTab = createNavBtn("Guard", navL)

-- Side Nav (Kanan)
local navR = new("Frame", {
    Parent = main, Size = UDim2.fromOffset(100, 265), Position = UDim2.new(1, -100, 0, 35), BackgroundTransparency = 1, ZIndex = 11
})
local navRLayout = new("UIListLayout", { Parent = navR, Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center })

local btnDiscord = createNavBtn("Discord", navR)
local btnConfig = createNavBtn("Config", navR)

-- Content Area (Tengah)
local content = new("Frame", {
    Parent = main, Size = UDim2.new(1, -200, 1, -35), Position = UDim2.fromOffset(100, 35),
    BackgroundColor3 = PanelBG, ZIndex = 11
})
corner(content, 4)

--═════════════ TAB: STEAL ═════════════
local tabSteal = new("Frame", { Parent = content, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 12 })

local stealScroll = new("ScrollingFrame", {
    Parent = tabSteal, Size = UDim2.new(1, -10, 1, -60), Position = UDim2.fromOffset(5, 50),
    BackgroundColor3 = Color3.fromRGB(20, 20, 20), BorderSizePixel = 0, ScrollBarThickness = 4,
    ScrollBarImageColor3 = RedTheme, ZIndex = 12
})
corner(stealScroll, 4)
stroke(stealScroll, Color3.fromRGB(0,0,0), 1.5)

local eggLayout = new("UIListLayout", { Parent = stealScroll, Padding = UDim.new(0, 4), HorizontalAlignment = Enum.HorizontalAlignment.Center })
local eggPad = new("UIPadding", { Parent = stealScroll, PaddingTop = UDim.new(0, 5) })

-- Header Auto Steal
local headerSteal = new("Frame", { Parent = tabSteal, Size = UDim2.new(1, -10, 0, 40), Position = UDim2.fromOffset(5, 5), BackgroundColor3 = Color3.fromRGB(40,40,40), ZIndex = 12 })
corner(headerSteal, 4)
stroke(headerSteal, Color3.fromRGB(0,0,0), 1.5)
new("TextLabel", { Parent = headerSteal, Size = UDim2.fromScale(0.7, 1), Position = UDim2.fromOffset(10,0), BackgroundTransparency = 1, Text = "Auto Steal", TextColor3 = TextColor, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13 })

local toggleStealBg = new("Frame", { Parent = headerSteal, Size = UDim2.fromOffset(40, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = Color3.fromRGB(80, 20, 20), ZIndex = 13 })
corner(toggleStealBg, 10)
stroke(toggleStealBg, Color3.fromRGB(0,0,0), 1.5)
local toggleStealBtn = new("TextButton", { Parent = toggleStealBg, Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(1, 1), BackgroundColor3 = Color3.fromRGB(255,255,255), Text = "", ZIndex = 14 })
corner(toggleStealBtn, 9)

local stealToggleState = false
toggleStealBtn.MouseButton1Click:Connect(function()
    stealToggleState = not stealToggleState
    AutoSteal = stealToggleState
    if stealToggleState then
        TweenService:Create(toggleStealBtn, TweenInfo.new(0.2), {Position = UDim2.fromOffset(21, 1)}):Play()
        TweenService:Create(toggleStealBg, TweenInfo.new(0.2), {BackgroundColor3 = RedTheme}):Play()
    else
        TweenService:Create(toggleStealBtn, TweenInfo.new(0.2), {Position = UDim2.fromOffset(1, 1)}):Play()
        TweenService:Create(toggleStealBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 20, 20)}):Play()
    end
end)

-- Render Eggs
function renderEggs()
    for _, c in ipairs(stealScroll:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
    end
    local eggs = scanEggs()
    local count = 0
    for name, data in pairs(eggs) do
        count = count + 1
        local row = new("Frame", { Parent = stealScroll, Size = UDim2.new(1, -10, 0, 40), BackgroundColor3 = Color3.fromRGB(40,40,40), LayoutOrder = count, ZIndex = 12 })
        corner(row, 4)
        
        local img = new("ImageLabel", { Parent = row, Size = UDim2.fromOffset(30, 30), Position = UDim2.fromOffset(5, 5), BackgroundColor3 = Color3.fromRGB(20,20,20), Image = data.icon or "", ZIndex = 13 })
        corner(img, 4)
        if not data.icon then
            new("TextLabel", { Parent = img, Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Text = "Egg", TextColor3 = TextColor, TextSize = 10, Font = Enum.Font.GothamBold })
        end
        
        new("TextLabel", { Parent = row, Size = UDim2.new(1, -100, 1, 0), Position = UDim2.fromOffset(40, 0), BackgroundTransparency = 1, Text = name, TextColor3 = TextColor, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 13 })
        
        local cb = new("TextButton", { Parent = row, Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -30, 0.5, -10), BackgroundColor3 = SelectedEggs[name] and RedTheme or Color3.fromRGB(20,20,20), Text = "", ZIndex = 13 })
        corner(cb, 2)
        stroke(cb, Color3.fromRGB(0,0,0), 1.5)
        
        cb.MouseButton1Click:Connect(function()
            SelectedEggs[name] = not SelectedEggs[name]
            cb.BackgroundColor3 = SelectedEggs[name] and RedTheme or Color3.fromRGB(20,20,20)
            if SelectedEggs[name] and not TargetEggName then
                TargetEggName = name
            elseif not SelectedEggs[name] and TargetEggName == name then
                TargetEggName = nil
            end
        end)
    end
    stealScroll.CanvasSize = UDim2.new(0, 0, 0, eggLayout.AbsoluteContentSize.Y + 10)
end

eggLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    stealScroll.CanvasSize = UDim2.new(0, 0, 0, eggLayout.AbsoluteContentSize.Y + 10)
end)

local scanBtn = new("TextButton", { Parent = tabSteal, Size = UDim2.new(1, -10, 0, 30), Position = UDim2.new(0, 5, 1, -35), BackgroundColor3 = RedTheme, Text = "Scan Eggs", TextColor3 = TextColor, Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 12 })
corner(scanBtn, 4)
stroke(scanBtn, Color3.fromRGB(0,0,0), 1.5)
scanBtn.MouseButton1Click:Connect(function() task.spawn(function() pcall(renderEggs) end) end)

--═════════════ TAB: GUARD ═════════════
local tabGuard = new("Frame", { Parent = content, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 12, Visible = false })

local function createGuardToggle(txt, posY)
    local f = new("Frame", { Parent = tabGuard, Size = UDim2.new(1, -10, 0, 40), Position = UDim2.fromOffset(5, posY), BackgroundColor3 = Color3.fromRGB(40,40,40), ZIndex = 12 })
    corner(f, 4)
    stroke(f, Color3.fromRGB(0,0,0), 1.5)
    new("TextLabel", { Parent = f, Size = UDim2.fromScale(0.7, 1), Position = UDim2.fromOffset(10,0), BackgroundTransparency = 1, Text = txt, TextColor3 = TextColor, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13 })
    
    local bg = new("Frame", { Parent = f, Size = UDim2.fromOffset(40, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = Color3.fromRGB(80, 20, 20), ZIndex = 13 })
    corner(bg, 10)
    stroke(bg, Color3.fromRGB(0,0,0), 1.5)
    local btn = new("TextButton", { Parent = bg, Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(1, 1), BackgroundColor3 = Color3.fromRGB(255,255,255), Text = "", ZIndex = 14 })
    corner(btn, 9)
    
    return btn, bg
end

local hitBtn, hitBg = createGuardToggle("Anti Hit (Godmode)", 5)
local guardBtn, guardBg = createGuardToggle("Anti Guard (Freeze NPC)", 50)

local hitState, guardState = false, false

hitBtn.MouseButton1Click:Connect(function()
    hitState = not hitState
    AntiHit = hitState
    TweenService:Create(hitBtn, TweenInfo.new(0.2), {Position = hitState and UDim2.fromOffset(21, 1) or UDim2.fromOffset(1, 1)}):Play()
    TweenService:Create(hitBg, TweenInfo.new(0.2), {BackgroundColor3 = hitState and RedTheme or Color3.fromRGB(80, 20, 20)}):Play()
end)

guardBtn.MouseButton1Click:Connect(function()
    guardState = not guardState
    AntiGuard = guardState
    TweenService:Create(guardBtn, TweenInfo.new(0.2), {Position = guardState and UDim2.fromOffset(21, 1) or UDim2.fromOffset(1, 1)}):Play()
    TweenService:Create(guardBg, TweenInfo.new(0.2), {BackgroundColor3 = guardState and RedTheme or Color3.fromRGB(80, 20, 20)}):Play()
    
    if not guardState then
        for _, m in ipairs(Workspace:GetDescendants()) do
            if m:IsA("Model") then
                local hum = m:FindFirstChildOfClass("Humanoid")
                if hum and (m.Name:lower():find("guard") or m.Name:lower():find("npc")) then
                    hum.WalkSpeed = 16
                end
            end
        end
    end
end)

--═════════════ TAB SWITCH ═════════════
local function showTab(tab)
    tabSteal.Visible = tab == "steal"
    tabGuard.Visible = tab == "guard"
end

btnStealTab.MouseButton1Click:Connect(function() showTab("steal") end)
btnGuardTab.MouseButton1Click:Connect(function() showTab("guard") end)

--═════════════ PANEL CLOSE / MINIMIZE ═════════════
minBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    circle.Visible = true
end)

-- Konfirmasi Hapus
local confirm = new("Frame", {
    Parent = gui, Size = UDim2.fromOffset(260, 150), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(15, 12, 20), Visible = false, ZIndex = 200
})
corner(confirm, 12)
stroke(confirm, Color3.fromRGB(180, 50, 70), 1.5)

new("TextLabel", {
    Parent = confirm, Size = UDim2.new(1, -20, 0, 50), Position = UDim2.fromOffset(10, 14),
    BackgroundTransparency = 1, Text = "Hapus AxD Hub v1?\nScript bakal berhenti total & hilang.",
    TextColor3 = Color3.fromRGB(255, 220, 220), Font = Enum.Font.Gotham, TextSize = 12, TextWrapped = true, ZIndex = 201
})

local yesBtn = new("TextButton", {
    Parent = confirm, Size = UDim2.fromOffset(110, 34), Position = UDim2.fromOffset(14, 100),
    BackgroundColor3 = Color3.fromRGB(120, 30, 45), Text = "Ya, Hapus",
    TextColor3 = Color3.fromRGB(255, 240, 240), Font = Enum.Font.GothamBold, TextSize = 13, ZIndex = 201
})
corner(yesBtn, 8)

local noBtn = new("TextButton", {
    Parent = confirm, Size = UDim2.fromOffset(110, 34), Position = UDim2.new(1, -124, 0, 100),
    BackgroundColor3 = Color3.fromRGB(35, 35, 50), Text = "Batal",
    TextColor3 = Color3.fromRGB(220, 220, 240), Font = Enum.Font.GothamBold, TextSize = 13, ZIndex = 201
})
corner(noBtn, 8)

noBtn.MouseButton1Click:Connect(function() confirm.Visible = false end)
yesBtn.MouseButton1Click:Connect(function()
    Running = false
    gui:Destroy()
end)

closeBtn.MouseButton1Click:Connect(function() confirm.Visible = true end)

task.wait(1)
task.spawn(function() pcall(renderEggs) end)
