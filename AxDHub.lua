--══════════════════════════════════════════════════════════════
--  AxD Hub v4.1 | Break and Steal an Egg (Clean Dark Theme)
--══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local parentGui
pcall(function() parentGui = gethui and gethui() or game:GetService("CoreGui") end)
if not parentGui then parentGui = PG end
if parentGui:FindFirstChild("AxDHubV1") then parentGui.AxDHubV1:Destroy() end

-- ═════════════ DATA ZONES & EGGS (Sesuai List Lu) ═════════════
local ZoneData = {
    ["Forest"] = {"Rock Egg", "Forest Egg"},
    ["Desert"] = {"Cactus Egg", "Bones Egg"},
    ["Snowy"] = {"Frosty Egg", "Frozen Egg"},
    ["Candy"] = {"Candy Egg", "Rainbow Egg", "Easter Bunny Egg"},
    ["Swamp"] = {"Sticky Egg", "Tree Egg", "Lake Egg"},
    ["Abyss Ocean"] = {"Water Egg", "Ocean Egg", "Sea Rock Egg"},
    ["Volcano"] = {"Volcanic Egg", "Angel Egg", "Fallen Angel Egg"},
    ["Cherry Blossom"] = {"Blossom Egg", "Petal Egg", "Sakura Egg"},
    ["Galaxy"] = {"Cosmic Egg", "Nebula Egg", "Black Hole Egg"},
    ["Planet X"] = {"Plasma Egg", "Supernova Egg", "Celestial Egg"}
}

-- ═════════════ STATE ═════════════
local SelectedZones = {}
local SelectedEggs = {}
local AutoBreak = false
local Running = true
local SafeZonePart = nil
local StatusLabel

-- ═════════════ HELPERS ═════════════
local function new(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function applyCleanStyle(obj, rad)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, rad or 6); c.Parent = obj
    local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(255,255,255); s.Thickness = 1; s.Transparency = 0.85; s.Parent = obj
end

local function drag(frame, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

local function getHRP()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart") or nil
end

local function getSafeZone()
    if SafeZonePart and SafeZonePart.Parent then return SafeZonePart end
    for _, o in ipairs(Workspace:GetDescendants()) do
        local n = o.Name:lower()
        if n:find("safezone") or n:find("base") or n:find("spawn") or n:find(LP.Name:lower()) then
            if o:IsA("BasePart") then SafeZonePart = o; return o end
            if o:IsA("Model") then
                local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart", true)
                if p then SafeZonePart = p; return p end
            end
        end
    end
    return nil
end

-- ═════════════ LOGIKA BREAK & STEAL ═════════════
local function startBreakLoop()
    task.spawn(function()
        while Running do
            if AutoBreak and next(SelectedEggs) then
                local hrp = getHRP()
                if hrp then
                    if StatusLabel then StatusLabel.Text = "Status: Mencari Egg..." end
                    
                    local targetEgg = nil
                    for eggName, active in pairs(SelectedEggs) do
                        if active then
                            -- Cari model telur di Workspace
                            for _, obj in ipairs(Workspace:GetDescendants()) do
                                if obj:IsA("Model") and string.find(string.lower(obj.Name), string.lower(eggName)) then
                                    local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                                    local safe = getSafeZone()
                                    -- Pastikan bukan egg yang ada di dalem base
                                    if part and (not safe or (part.Position - safe.Position).Magnitude > 50) then
                                        targetEgg = {model = obj, part = part}
                                        break
                                    end
                                end
                            end
                        end
                        if targetEgg then break end
                    end
                    
                    if targetEgg then
                        if StatusLabel then StatusLabel.Text = "Status: Breaking & Stealing!" end
                        
                        -- 1. Teleport ke Egg
                        hrp.CFrame = targetEgg.part.CFrame + Vector3.new(0, 3, 0)
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                        task.wait(0.1)
                        
                        -- 2. Equip Pickaxe & Hack Damage 1T
                        local char = LP.Character
                        if char then
                            local tool = char:FindFirstChildWhichIsA("Tool")
                            if not tool then
                                local bp = LP:FindFirstChild("Backpack")
                                if bp then
                                    -- Cari Pickaxe di backpack (biasanya slot 1)
                                    local pick = bp:FindFirstChild("Pickaxe") or bp:FindFirstChildWhichIsA("Tool")
                                    if pick then char.Humanoid:EquipTool(pick) end
                                end
                            end
                            
                            -- Paksa Damage 1T
                            if tool then
                                for _, v in ipairs(tool:GetDescendants()) do
                                    if v:IsA("NumberValue") or v:IsA("IntValue") then
                                        if string.find(string.lower(v.Name), "damage") or string.find(string.lower(v.Name), "power") then
                                            pcall(function() v.Value = 1000000000000 end) -- 1T
                                        end
                                    end
                                end
                                -- Spam Activate tool (mukul)
                                for i = 1, 10 do
                                    pcall(function() tool:Activate() end)
                                    task.wait(0.03)
                                end
                            end
                        end
                        
                        -- 3. Fire Prompts & Touch untuk ambil pet/egg
                        for _, d in ipairs(targetEgg.model:GetDescendants()) do
                            if d:IsA("ProximityPrompt") then pcall(function() fireproximityprompt(d) end) end
                            if d:IsA("ClickDetector") then pcall(function() fireclickdetector(d) end) end
                        end
                        for _, p in ipairs(targetEgg.model:GetDescendants()) do
                            if p:IsA("BasePart") then
                                pcall(function() firetouchinterest(hrp, p, 0) end)
                                pcall(function() firetouchinterest(hrp, p, 1) end)
                            end
                        end
                        
                        task.wait(0.2)
                        if StatusLabel then StatusLabel.Text = "Status: Balik ke Safe Zone" end
                        
                        -- 4. Balik ke Safe Zone
                        local safe = getSafeZone()
                        if safe then 
                            hrp.CFrame = safe.CFrame + Vector3.new(0, 3, 0) 
                            hrp.AssemblyLinearVelocity = Vector3.zero
                        end
                        task.wait(0.3)
                    else
                        task.wait(0.5)
                    end
                end
            else
                if StatusLabel then StatusLabel.Text = "Status: Idle" end
                task.wait(0.5)
            end
            task.wait(0.05)
        end
    end)
end
startBreakLoop()

-- ═════════════ UI CREATION (Hitam Bersih) ═════════════
local gui = new("ScreenGui", { Name = "AxDHubV1", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999 }, parentGui)

-- Tema Hitam Doff
local MainBg = Color3.fromRGB(15, 15, 15)
local DarkPanel = Color3.fromRGB(25, 25, 25)
local WhiteText = Color3.fromRGB(255, 255, 255)
local GreyText = Color3.fromRGB(150, 150, 150)

-- Floating Button
local circle = new("TextButton", { Parent = gui, Size = UDim2.fromOffset(50, 50), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = MainBg, Text = "AxD", TextColor3 = WhiteText, Font = Enum.Font.GothamBlack, TextSize = 18, ZIndex = 50 })
applyCleanStyle(circle, 25)

-- Main Window
local main = new("Frame", { Parent = gui, Size = UDim2.fromOffset(450, 350), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = MainBg, Visible = false, ZIndex = 10 })
applyCleanStyle(main, 8)

local titleBar = new("Frame", { Parent = main, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = DarkPanel, ZIndex = 11 })
applyCleanStyle(titleBar, 8)
new("TextLabel", { Parent = titleBar, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "AxD Hub v4.1", TextColor3 = WhiteText, Font = Enum.Font.GothamBold, TextSize = 16, ZIndex = 12 })

local minBtn = new("TextButton", { Parent = titleBar, Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -70, 0, 2), BackgroundColor3 = DarkPanel, Text = "-", TextColor3 = WhiteText, Font = Enum.Font.GothamBold, TextSize = 16, ZIndex = 12 })
applyCleanStyle(minBtn, 4)
local closeBtn = new("TextButton", { Parent = titleBar, Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -35, 0, 2), BackgroundColor3 = DarkPanel, Text = "X", TextColor3 = WhiteText, Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 12 })
applyCleanStyle(closeBtn, 4)
drag(main, titleBar)

-- Sidebar
local navL = new("Frame", { Parent = main, Size = UDim2.fromOffset(90, 315), Position = UDim2.fromOffset(0, 35), BackgroundTransparency = 1, ZIndex = 11 })
new("UIListLayout", { Parent = navL, Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center })

local function createNavBtn(txt)
    local b = new("TextButton", { Parent = navL, Size = UDim2.fromOffset(80, 35), BackgroundColor3 = DarkPanel, Text = txt, TextColor3 = GreyText, Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false })
    applyCleanStyle(b, 6)
    return b
end

local btnBreak = createNavBtn("Break")
local btnSteal = createNavBtn("Steal")

-- Konten Utama
local content = new("Frame", { Parent = main, Size = UDim2.new(1, -100, 1, -70), Position = UDim2.fromOffset(90, 35), BackgroundColor3 = DarkPanel, ZIndex = 11 })
applyCleanStyle(content, 6)

StatusLabel = new("TextLabel", { Parent = main, Size = UDim2.new(1, -100, 0, 20), Position = UDim2.new(0, 90, 1, -30), BackgroundTransparency = 1, Text = "Status: Idle", TextColor3 = WhiteText, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12 })

-- ═════════════ TAB BREAK ═════════════
local tabBreak = new("Frame", { Parent = content, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 12 })

new("TextLabel", { Parent = tabBreak, Size = UDim2.new(1, -10, 0, 25), Position = UDim2.fromOffset(5, 5), BackgroundTransparency = 1, Text = "1. Pilih Zone", TextColor3 = WhiteText, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12 })

local zoneScroll = new("ScrollingFrame", { Parent = tabBreak, Size = UDim2.new(1, -10, 0, 100), Position = UDim2.fromOffset(5, 30), BackgroundColor3 = MainBg, BorderSizePixel = 0, ScrollBarThickness = 2, ZIndex = 12 })
applyCleanStyle(zoneScroll, 4)
local zoneLayout = new("UIListLayout", { Parent = zoneScroll, Padding = UDim.new(0, 3), HorizontalAlignment = Enum.HorizontalAlignment.Center })

new("TextLabel", { Parent = tabBreak, Size = UDim2.new(1, -10, 0, 25), Position = UDim2.fromOffset(5, 135), BackgroundTransparency = 1, Text = "2. Pilih Egg", TextColor3 = WhiteText, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12 })

local eggScroll = new("ScrollingFrame", { Parent = tabBreak, Size = UDim2.new(1, -10, 0, 100), Position = UDim2.fromOffset(5, 160), BackgroundColor3 = MainBg, BorderSizePixel = 0, ScrollBarThickness = 2, ZIndex = 12 })
applyCleanStyle(eggScroll, 4)
local eggLayout = new("UIListLayout", { Parent = eggScroll, Padding = UDim.new(0, 3), HorizontalAlignment = Enum.HorizontalAlignment.Center })

local btnStart = new("TextButton", { Parent = tabBreak, Size = UDim2.new(1, -10, 0, 30), Position = UDim2.new(0, 5, 1, -35), BackgroundColor3 = Color3.fromRGB(30, 80, 40), Text = "Start Break", TextColor3 = WhiteText, Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 12, Visible = false })
applyCleanStyle(btnStart, 6)

-- Render Egg berdasarkan Zone
local function renderEggs()
    for _, c in ipairs(eggScroll:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
    end
    
    local count = 0
    for zName, isZSelected in pairs(SelectedZones) do
        if isZSelected then
            for _, eName in ipairs(ZoneData[zName]) do
                count = count + 1
                local isSelected = SelectedEggs[eName] == true
                
                local row = new("Frame", { Parent = eggScroll, Size = UDim2.new(1, -5, 0, 30), BackgroundColor3 = DarkPanel, LayoutOrder = count, ZIndex = 13 })
                applyCleanStyle(row, 4)
                
                new("TextLabel", { Parent = row, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1, Text = eName, TextColor3 = WhiteText, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14 })
                
                local cb = new("TextButton", { Parent = row, Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -25, 0.5, -10), BackgroundColor3 = isSelected and WhiteText or MainBg, Text = "", ZIndex = 14 })
                applyCleanStyle(cb, 4)
                
                cb.MouseButton1Click:Connect(function()
                    local isNow = not (SelectedEggs[eName] == true)
                    SelectedEggs[eName] = isNow
                    cb.BackgroundColor3 = isNow and WhiteText or MainBg
                    btnStart.Visible = next(SelectedEggs) ~= nil
                end)
            end
        end
    end
    eggScroll.CanvasSize = UDim2.new(0, 0, 0, eggLayout.AbsoluteContentSize.Y + 5)
end

-- Render Zone
for zName, _ in pairs(ZoneData) do
    local row = new("Frame", { Parent = zoneScroll, Size = UDim2.new(1, -5, 0, 25), BackgroundColor3 = DarkPanel, ZIndex = 13 })
    applyCleanStyle(row, 4)
    
    new("TextLabel", { Parent = row, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1, Text = zName, TextColor3 = WhiteText, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14 })
    
    local cb = new("TextButton", { Parent = row, Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -25, 0.5, -10), BackgroundColor3 = MainBg, Text = "", ZIndex = 14 })
    applyCleanStyle(cb, 4)
    
    cb.MouseButton1Click:Connect(function()
        local isNow = not (SelectedZones[zName] == true)
        SelectedZones[zName] = isNow
        cb.BackgroundColor3 = isNow and WhiteText or MainBg
        renderEggs()
    end)
end
zoneLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    zoneScroll.CanvasSize = UDim2.new(0, 0, 0, zoneLayout.AbsoluteContentSize.Y + 5)
end)

btnStart.MouseButton1Click:Connect(function()
    if next(SelectedEggs) then
        AutoBreak = not AutoBreak
        btnStart.Text = AutoBreak and "Stop Break" or "Start Break"
        btnStart.BackgroundColor3 = AutoBreak and Color3.fromRGB(100, 30, 30) or Color3.fromRGB(30, 80, 40)
    end
end)

-- ═════════════ TAB STEAL (Placeholder) ═════════════
local tabSteal = new("Frame", { Parent = content, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 12, Visible = false })
new("TextLabel", { Parent = tabSteal, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "Fitur Steal menyusul di update berikutnya.", TextColor3 = WhiteText, Font = Enum.Font.Gotham, TextSize = 13 })

-- Switch Tab
local function switchTab(tab)
    tabBreak.Visible = tab == "break"
    tabSteal.Visible = tab == "steal"
    btnBreak.TextColor3 = tab == "break" and WhiteText or GreyText
    btnSteal.TextColor3 = tab == "steal" and WhiteText or GreyText
end
btnBreak.MouseButton1Click:Connect(function() switchTab("break") end)
btnSteal.MouseButton1Click:Connect(function() switchTab("steal") end)

-- Open/Close
circle.MouseButton1Click:Connect(function() main.Visible = true; circle.Visible = false end)
minBtn.MouseButton1Click:Connect(function() main.Visible = false; circle.Visible = true end)

-- Konfirmasi Hapus
local confirm = new("Frame", { Parent = gui, Size = UDim2.fromOffset(260, 130), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = MainBg, Visible = false, ZIndex = 200 })
applyCleanStyle(confirm, 8)
new("TextLabel", { Parent = confirm, Size = UDim2.new(1, -20, 0, 50), Position = UDim2.fromOffset(10, 14), BackgroundTransparency = 1, Text = "Hapus AxD Hub v4.1?", TextColor3 = WhiteText, Font = Enum.Font.Gotham, TextSize = 13, TextWrapped = true, ZIndex = 201 })
local yesBtn = new("TextButton", { Parent = confirm, Size = UDim2.fromOffset(100, 30), Position = UDim2.fromOffset(14, 80), BackgroundColor3 = Color3.fromRGB(100, 30, 30), Text = "Ya", TextColor3 = WhiteText, Font = Enum.Font.GothamBold, TextSize = 13, ZIndex = 201 })
applyCleanStyle(yesBtn, 6)
local noBtn = new("TextButton", { Parent = confirm, Size = UDim2.fromOffset(100, 30), Position = UDim2.new(1, -114, 0, 80), BackgroundColor3 = DarkPanel, Text = "Batal", TextColor3 = WhiteText, Font = Enum.Font.GothamBold, TextSize = 13, ZIndex = 201 })
applyCleanStyle(noBtn, 6)

noBtn.MouseButton1Click:Connect(function() confirm.Visible = false end)
yesBtn.MouseButton1Click:Connect(function() Running = false; gui:Destroy() end)
closeBtn.MouseButton1Click:Connect(function() confirm.Visible = true end)

switchTab("break")
