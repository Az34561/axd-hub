--══════════════════════════════════════════════════════════════
--  AxD Hub v1  |  Steal An Egg  |  Made by ENI for LO
--══════════════════════════════════════════════════════════════

pcall(function()
    local cg = game:GetService("CoreGui")
    local old = cg:FindFirstChild("AxDHubV1")
    if old then old:Destroy() end
end)

local Players   = game:GetService("Players")
local Tween     = game:GetService("TweenService")
local UIS       = game:GetService("UserInputService")
local WS        = game:GetService("Workspace")
local Run       = game:GetService("RunService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

--═════════════ STATE ═════════════
local Selected   = {}
local StealOn    = false
local CurrentTab = "main"
local Running    = true
local KillPanel  = nil

--═════════════ HELPERS ═════════════
local function new(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function corner(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = o
end

local function stroke(o, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(80, 80, 95)
    s.Thickness = thick or 1
    s.Transparency = trans or 0.35
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = o
end

local function makeDraggable(frame, handle, onClick)
    local dragging, dragStart, startPos = false, nil, nil
    local moved = 0
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = 0
            startPos = frame.Position
            dragStart = input.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = input.Position - dragStart
        moved = moved + d.Magnitude
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if dragging and moved < 6 and onClick then onClick() end
        dragging = false
    end)
end

--═════════════ EGG SCAN ═════════════
local function scanEggs()
    local eggs = {}
    for _, o in ipairs(WS:GetDescendants()) do
        if o:IsA("Model") and o.Name:lower():find("egg") then
            local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart", true)
            if p then
                eggs[o.Name] = { model = o, part = p }
            end
        end
    end
    return eggs
end

local function findEgg(name)
    for _, o in ipairs(WS:GetDescendants()) do
        if o:IsA("Model") and o.Name == name then
            local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart", true)
            if p then return { model = o, part = p } end
        end
    end
    return nil
end

local function findSafeZone()
    for _, o in ipairs(WS:GetDescendants()) do
        local n = o.Name:lower()
        if n:find("safezone") or n == "safe" or n:find("safe zone") or n:find("base") then
            if o:IsA("BasePart") then return o end
            if o:IsA("Model") then
                local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart", true)
                if p then return p end
            end
        end
    end
    for _, o in ipairs(WS:GetDescendants()) do
        if o:IsA("SpawnLocation") then return o end
    end
    return nil
end

local function eggIcon(model)
    for _, d in ipairs(model:GetDescendants()) do
        if (d:IsA("Decal") or d:IsA("Texture")) and d.Texture ~= "" then
            return d.Texture
        end
    end
    return nil
end

local function eggRole(model)
    for _, a in ipairs({"Rarity","Role","Type","Tier","Rank","Kind"}) do
        local v = model:GetAttribute(a)
        if v then return tostring(v) end
    end
    local n = model.Name:lower()
    if n:find("legend") or n:find("myth") then return "Legendary" end
    if n:find("rare") or n:find("gold") then return "Rare" end
    if n:find("event") or n:find("special") then return "Event" end
    return "Common"
end

local function getHRP()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart") or nil
end

local function tryGrab(egg)
    for _, d in ipairs(egg.model:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            pcall(function() fireproximityprompt(d) end)
        end
    end
    local hrp = getHRP()
    if hrp then
        for _, p in ipairs(egg.model:GetDescendants()) do
            if p:IsA("BasePart") then
                pcall(function() firetouchinterest(hrp, p, 0) end)
                pcall(function() firetouchinterest(hrp, p, 1) end)
            end
        end
    end
end

--═════════════ STEAL LOOP ═════════════
local function startSteal()
    if StealOn then return end
    if not next(Selected) then
        for n in pairs(scanEggs()) do Selected[n] = true end
    end
    StealOn = true
    task.spawn(function()
        while StealOn and Running do
            local any = false
            for name, on in pairs(Selected) do
                if not StealOn or not Running then break end
                if on then
                    local egg = findEgg(name)
                    local hrp = getHRP()
                    if egg and hrp then
                        pcall(function()
                            hrp.CFrame = egg.part.CFrame + Vector3.new(0, 3, 0)
                        end)
                        task.wait(0.04)
                        tryGrab(egg)
                        task.wait(0.06)
                        local safe = findSafeZone()
                        if safe then
                            pcall(function()
                                hrp.CFrame = safe.CFrame + Vector3.new(0, 3, 0)
                            end)
                        end
                        task.wait(0.04)
                        any = true
                    end
                end
            end
            task.wait(any and 0.03 or 0.4)
        end
    end)
end

local function stopSteal() StealOn = false end

--═════════════ GUI ROOT ═════════════
local gui = new("ScreenGui", {
    Name = "AxDHubV1",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PG)

KillPanel = gui

--═════════════ FLOATING CIRCLE BUTTON ═════════════
local circle = new("TextButton", {
    Name = "OpenBtn",
    Parent = gui,
    Size = UDim2.fromOffset(62, 62),
    Position = UDim2.new(0, 20, 0.4, 0),
    BackgroundColor3 = Color3.fromRGB(15, 15, 20),
    Text = "",
    AutoButtonColor = false,
    BorderSizePixel = 0,
    ZIndex = 50,
})
corner(circle, 999)
stroke(circle, Color3.fromRGB(120, 90, 200), 2, 0.1)

local circGrad = new("UIGradient", { Parent = circle })
circGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 20, 45)),
})

new("TextLabel", {
    Parent = circle,
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "AxD",
    TextColor3 = Color3.fromRGB(220, 200, 255),
    Font = Enum.Font.GothamBlack,
    TextSize = 20,
    ZIndex = 51,
})

local pulse = Tween:Create(circle, TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
    Size = UDim2.fromOffset(66, 66),
})
pulse:Play()

--═════════════ MAIN PANEL ═════════════
local panel = new("Frame", {
    Name = "MainPanel",
    Parent = gui,
    Size = UDim2.fromOffset(320, 380),
    Position = UDim2.new(0.5, -160, 0.5, -190),
    BackgroundColor3 = Color3.fromRGB(12, 12, 16),
    BackgroundTransparency = 0.06,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 10,
})
corner(panel, 14)
stroke(panel, Color3.fromRGB(90, 70, 140), 1.5, 0.25)

local panelGrad = new("UIGradient", { Parent = panel })
panelGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 18, 28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 14)),
})
panelGrad.Rotation = 135

-- title bar
local title = new("Frame", {
    Parent = panel,
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(18, 16, 24),
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    ZIndex = 11,
})
corner(title, 14)

new("TextLabel", {
    Parent = title,
    Size = UDim2.new(1, -90, 1, 0),
    Position = UDim2.fromOffset(14, 0),
    BackgroundTransparency = 1,
    Text = "⚡ AxD Hub v1",
    TextColor3 = Color3.fromRGB(225, 210, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 12,
})

local minBtn = new("TextButton", {
    Parent = title,
    Size = UDim2.fromOffset(28, 28),
    Position = UDim2.new(1, -66, 0.5, -14),
    BackgroundColor3 = Color3.fromRGB(40, 40, 55),
    Text = "–",
    TextColor3 = Color3.fromRGB(230, 230, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    AutoButtonColor = false,
    BorderSizePixel = 0,
    ZIndex = 12,
})
corner(minBtn, 8)

local closeBtn = new("TextButton", {
    Parent = title,
    Size = UDim2.fromOffset(28, 28),
    Position = UDim2.new(1, -34, 0.5, -14),
    BackgroundColor3 = Color3.fromRGB(90, 30, 40),
    Text = "X",
    TextColor3 = Color3.fromRGB(255, 220, 220),
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    AutoButtonColor = false,
    BorderSizePixel = 0,
    ZIndex = 12,
})
corner(closeBtn, 8)

-- draggable panel via title
makeDraggable(panel, title, nil)

--═════════════ TAB CONTAINER ═════════════
local tabMain = new("Frame", {
    Parent = panel,
    Position = UDim2.fromOffset(0, 40),
    Size = UDim2.new(1, 0, 1, -40),
    BackgroundTransparency = 1,
    ZIndex = 11,
})

local tabEggs = new("Frame", {
    Parent = panel,
    Position = UDim2.fromOffset(0, 40),
    Size = UDim2.new(1, 0, 1, -40),
    BackgroundTransparency = 1,
    Visible = false,
    ZIndex = 11,
})

--═════════════ TAB MAIN CONTENT ═════════════
local stealBtn = new("TextButton", {
    Parent = tabMain,
    Size = UDim2.new(1, -28, 0, 56),
    Position = UDim2.fromOffset(14, 18),
    BackgroundColor3 = Color3.fromRGB(35, 25, 60),
    Text = "⚡  Steal Egg Fast",
    TextColor3 = Color3.fromRGB(230, 220, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    AutoButtonColor = false,
    BorderSizePixel = 0,
    ZIndex = 12,
})
corner(stealBtn, 10)
stroke(stealBtn, Color3.fromRGB(120, 90, 200), 1.5, 0.2)

local eggBtn = new("TextButton", {
    Parent = tabMain,
    Size = UDim2.new(1, -28, 0, 56),
    Position = UDim2.fromOffset(14, 86),
    BackgroundColor3 = Color3.fromRGB(25, 25, 35),
    Text = "🥚  Mihh Egg",
    TextColor3 = Color3.fromRGB(220, 220, 240),
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    AutoButtonColor = false,
    BorderSizePixel = 0,
    ZIndex = 12,
})
corner(eggBtn, 10)
stroke(eggBtn, Color3.fromRGB(90, 70, 140), 1.5, 0.3)

local statusLbl = new("TextLabel", {
    Parent = tabMain,
    Size = UDim2.new(1, -28, 0, 60),
    Position = UDim2.fromOffset(14, 160),
    BackgroundColor3 = Color3.fromRGB(18, 18, 24),
    BackgroundTransparency = 0.4,
    Text = "Status: Idle\nEgg terpilih: -",
    TextColor3 = Color3.fromRGB(200, 200, 220),
    Font = Enum.Font.Gotham,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextWrapped = true,
    BorderSizePixel = 0,
    ZIndex = 12,
})
corner(statusLbl, 8)
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.TextYAlignment = Enum.TextYAlignment.Top
local pad = new("UIPadding", { Parent = statusLbl })
pad.PaddingLeft = UDim.new(0, 10)
pad.PaddingTop = UDim.new(0, 8)

local function refreshStatus()
    local count = 0
    for _, v in pairs(Selected) do if v then count = count + 1 end end
    statusLbl.Text = "Status: " .. (StealOn and "🔥 Stealing..." or "Idle")
        .. "\nEgg terpilih: " .. (count > 0 and (count .. " egg") or "-")
end

--═════════════ EGG LIST UI ═════════════
local headerRow = new("Frame", {
    Parent = tabEggs,
    Size = UDim2.new(1, -20, 0, 32),
    Position = UDim2.fromOffset(10, 6),
    BackgroundTransparency = 1,
    ZIndex = 12,
})

local backBtn = new("TextButton", {
    Parent = headerRow,
    Size = UDim2.fromOffset(80, 28),
    Position = UDim2.fromOffset(0, 0),
    BackgroundColor3 = Color3.fromRGB(40, 30, 60),
    Text = "← Back",
    TextColor3 = Color3.fromRGB(220, 210, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    AutoButtonColor = false,
    BorderSizePixel = 0,
    ZIndex = 13,
})
corner(backBtn, 8)

local rescanBtn = new("TextButton", {
    Parent = headerRow,
    Size = UDim2.fromOffset(80, 28),
    Position = UDim2.new(1, -80, 0, 0),
    BackgroundColor3 = Color3.fromRGB(40, 30, 60),
    Text = "↻ Scan",
    TextColor3 = Color3.fromRGB(220, 210, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    AutoButtonColor = false,
    BorderSizePixel = 0,
    ZIndex = 13,
})
corner(rescanBtn, 8)

local eggScroll = new("ScrollingFrame", {
    Parent = tabEggs,
    Position = UDim2.fromOffset(10, 44),
    Size = UDim2.new(1, -20, 1, -130),
    BackgroundColor3 = Color3.fromRGB(15, 15, 20),
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = Color3.fromRGB(140, 110, 220),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ZIndex = 12,
})
corner(eggScroll, 10)
stroke(eggScroll, Color3.fromRGB(70, 55, 110), 1, 0.4)

local eggLayout = new("UIListLayout", { Parent = eggScroll })
eggLayout.Padding = UDim.new(0, 6)
eggLayout.SortOrder = Enum.SortOrder.LayoutOrder
local eggPad = new("UIPadding", { Parent = eggScroll })
eggPad.PaddingTop = UDim.new(0, 8)
eggPad.PaddingLeft = UDim.new(0, 8)
eggPad.PaddingRight = UDim.new(0, 8)
eggPad.PaddingBottom = UDim.new(0, 8)

local runBtn = new("TextButton", {
    Parent = tabEggs,
    Size = UDim2.new(1, -20, 0, 44),
    Position = UDim2.new(0, 10, 1, -50),
    BackgroundColor3 = Color3.fromRGB(70, 40, 130),
    Text = "🔙  Kembali & Run",
    TextColor3 = Color3.fromRGB(240, 230, 255),
    Font = Enum.Font.GothamBlack,
    TextSize = 15,
    AutoButtonColor = false,
    BorderSizePixel = 0,
    ZIndex = 13,
})
corner(runBtn, 10)
stroke(runBtn, Color3.fromRGB(150, 110, 240), 2, 0.15)

local function buildEggRows()
    for _, c in ipairs(eggScroll:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
    end
    local eggs = scanEggs()
    local count = 0
    for name, info in pairs(eggs) do
        count = count + 1
        local row = new("Frame", {
            Parent = eggScroll,
            Size = UDim2.new(1, 0, 0, 52),
            BackgroundColor3 = Color3.fromRGB(22, 22, 30),
            BorderSizePixel = 0,
            LayoutOrder = count,
            ZIndex = 12,
        })
        corner(row, 8)
        stroke(row, Color3.fromRGB(60, 50, 90), 1, 0.5)

        local icon = eggIcon(info.model)
        local iconLbl = new("ImageLabel", {
            Parent = row,
            Size = UDim2.fromOffset(40, 40),
            Position = UDim2.fromOffset(8, 6),
            BackgroundColor3 = Color3.fromRGB(35, 30, 50),
            BackgroundTransparency = icon and 1 or 0.3,
            Image = icon or "",
            BorderSizePixel = 0,
            ZIndex = 13,
        })
        corner(iconLbl, 8)
        if not icon then
            new("TextLabel", {
                Parent = iconLbl,
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Text = "🥚",
                TextSize = 20,
                ZIndex = 14,
            })
        end

        local nameLbl = new("TextLabel", {
            Parent = row,
            Position = UDim2.fromOffset(56, 6),
            Size = UDim2.new(1, -110, 0, 20),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Color3.fromRGB(235, 235, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 13,
        })

        local roleLbl = new("TextLabel", {
            Parent = row,
            Position = UDim2.fromOffset(56, 26),
            Size = UDim2.new(1, -110, 0, 18),
            BackgroundTransparency = 1,
            Text = "Role: " .. eggRole(info.model),
            TextColor3 = Color3.fromRGB(170, 160, 210),
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 13,
        })

        local cb = new("TextButton", {
            Parent = row,
            Size = UDim2.fromOffset(28, 28),
            Position = UDim2.new(1, -38, 0.5, -14),
            BackgroundColor3 = Selected[name] and Color3.fromRGB(90, 60, 170) or Color3.fromRGB(30, 30, 40),
            Text = Selected[name] and "✓" or "",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBlack,
            TextSize = 16,
            AutoButtonColor = false,
            BorderSizePixel = 0,
            ZIndex = 13,
        })
        corner(cb, 6)
        stroke(cb, Color3.fromRGB(140, 110, 220), 1.2, 0.2)

        cb.MouseButton1Click:Connect(function()
            Selected[name] = not Selected[name]
            cb.BackgroundColor3 = Selected[name] and Color3.fromRGB(90, 60, 170) or Color3.fromRGB(30, 30, 40)
            cb.Text = Selected[name] and "✓" or ""
            refreshStatus()
        end)
    end

    if count == 0 then
        new("TextLabel", {
            Parent = eggScroll,
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            Text = "Belum ada egg ke-detect. Coba ↻ Scan.",
            TextColor3 = Color3.fromRGB(180, 170, 220),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            ZIndex = 12,
        })
    end
    eggScroll.CanvasSize = UDim2.new(0, 0, 0, eggLayout.AbsoluteContentSize.Y + 16)
end

eggLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    eggScroll.CanvasSize = UDim2.new(0, 0, 0, eggLayout.AbsoluteContentSize.Y + 16)
end)

--═════════════ TAB SWITCH ═════════════
local function showTab(which)
    CurrentTab = which
    tabMain.Visible = which == "main"
    tabEggs.Visible = which == "eggs"
    if which == "eggs" then buildEggRows() end
end

eggBtn.MouseButton1Click:Connect(function() showTab("eggs") end)
backBtn.MouseButton1Click:Connect(function() showTab("main") end)
rescanBtn.MouseButton1Click:Connect(function() buildEggRows() end)

--═════════════ STEAL TOGGLE ═════════════
stealBtn.MouseButton1Click:Connect(function()
    if StealOn then
        stopSteal()
        stealBtn.Text = "⚡  Steal Egg Fast"
        stealBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 60)
    else
        startSteal()
        stealBtn.Text = "⏹  Stop Stealing"
        stealBtn.BackgroundColor3 = Color3.fromRGB(80, 25, 45)
    end
    refreshStatus()
end)

runBtn.MouseButton1Click:Connect(function()
    if not next(Selected) then
        for n in pairs(scanEggs()) do Selected[n] = true end
    end
    showTab("main")
    if not StealOn then
        startSteal()
        stealBtn.Text = "⏹  Stop Stealing"
        stealBtn.BackgroundColor3 = Color3.fromRGB(80, 25, 45)
    end
    refreshStatus()
end)

--═════════════ MIN / CLOSE ═════════════
local function openPanel()
    panel.Visible = true
    panel.Size = UDim2.fromOffset(220, 260)
    Tween:Create(panel, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(320, 380),
        BackgroundTransparency = 0.06,
    }):Play()
    circle.Visible = false
end

local function hidePanel()
    Tween:Create(panel, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(220, 260),
        BackgroundTransparency = 1,
    }):Play()
    task.delay(0.25, function()
        panel.Visible = false
        circle.Visible = true
    end)
end

minBtn.MouseButton1Click:Connect(hidePanel)
circle.MouseButton1Click:Connect(openPanel)

--═════════════ CLOSE CONFIRMATION ═════════════
local confirm = new("Frame", {
    Parent = gui,
    Size = UDim2.fromOffset(260, 150),
    Position = UDim2.new(0.5, -130, 0.5, -75),
    BackgroundColor3 = Color3.fromRGB(15, 12, 20),
    BackgroundTransparency = 0.03,
    Visible = false,
    ZIndex = 200,
})
corner(confirm, 12)
stroke(confirm, Color3.fromRGB(180, 50, 70), 1.5, 0.15)

new("TextLabel", {
    Parent = confirm,
    Size = UDim2.new(1, -20, 0, 50),
    Position = UDim2.fromOffset(10, 14),
    BackgroundTransparency = 1,
    Text = "⚠  Hapus AxD Hub v1?\nScript bakal berhenti total & hilang dari game.",
    TextColor3 = Color3.fromRGB(255, 220, 220),
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextWrapped = true,
    ZIndex = 201,
})

local yesBtn = new("TextButton", {
    Parent = confirm,
    Size = UDim2.fromOffset(110, 34),
    Position = UDim2.fromOffset(14, 100),
    BackgroundColor3 = Color3.fromRGB(120, 30, 45),
    Text = "Ya, Hapus",
    TextColor3 = Color3.fromRGB(255, 240, 240),
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    AutoButtonColor = false,
    BorderSizePixel = 0,
    ZIndex = 201,
})
corner(yesBtn, 8)

local noBtn = new("TextButton", {
    Parent = confirm,
    Size = UDim2.fromOffset(110, 34),
    Position = UDim2.new(1, -124, 0, 100),
    BackgroundColor3 = Color3.fromRGB(35, 35, 50),
    Text = "Batal",
    TextColor3 = Color3.fromRGB(220, 220, 240),
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    AutoButtonColor = false,
    BorderSizePixel = 0,
    ZIndex = 201,
})
corner(noBtn, 8)

closeBtn.MouseButton1Click:Connect(function()
    confirm.Visible = true
end)

noBtn.MouseButton1Click:Connect(function()
    confirm.Visible = false
end)

yesBtn.MouseButton1Click:Connect(function()
    Running = false
    StealOn = false
    confirm.Visible = false
    pcall(function() gui:Destroy() end)
end)

--═════════════ REFRESH STATUS INITIAL ═════════════
refreshStatus()
openPanel()

--═════════════ END ═════════════
