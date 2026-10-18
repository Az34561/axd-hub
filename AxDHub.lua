--══════════════════════════════════════════════════════════════
--  AxD Hub v5.2 | Smart Pickup & Live Reload
--══════════════════════════════════════════════════════════════

-- ⚠️ MASUKIN LINK RAW GITHUB LU DI SINI BUAT FITUR RELOAD ⚠️
local ScriptURL = "https://raw.githubusercontent.com/..." 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

if PG:FindFirstChild("AxDHubV1") then PG.AxDHubV1:Destroy() end

-- ═════════════ DATA LENGKAP ═════════════
local EggDatabase = {
    ["Planet X"] = { eggs = {"Plasma Egg", "Nebula Egg", "Supernova Egg"}, pets = "Bug, Crystal Lizard, Crystal Beast, Crystal Raptor, Crystal Dragon, Mantis, Alien Jellyfish, Crystal Scorpion, Behemoth, Crystal Wolf, Celestial Beast, Celestial Spirit" },
    ["Forest Zone"] = { eggs = {"Rock Egg", "Forest Egg"}, pets = "Chicken, Dog, Bird, Owl, Raccoon, Bear, Fox, Brr Brr Patapim" },
    ["Desert Zone"] = { eggs = {"Cactus Egg", "Bones Egg"}, pets = "Jerboa, Fennec, Camel, Tob Tobi Tob Tob, Snake, Scorpion, Sand Spider, Royal Sphinx" },
    ["Snowy Zone"] = { eggs = {"Frozen Egg", "Yeti Egg"}, pets = "Penguin, Snowman, Arctic Fox, Seal, Polar Bear, Yeti, Ice Dragon, El Maja" },
    ["Candy Zone"] = { eggs = {"Candy Egg", "Rainbow Egg", "Easter Bunny Egg"}, pets = "Gummy Bear, Lollipop Cat, Cotton Candy Dog, Marshmallow Bunny, Chocolate Dragon, Candy Serpent" },
    ["Swamp Zone"] = { eggs = {"Gooey Egg", "Tree Egg", "Lake Egg"}, pets = "Frog, Duckling, Catfish, Turtle, Swan, Axolotl, Crocodile, Leviathan" },
    ["Ocean Zone"] = { eggs = {"Sea Stones Egg", "Water Egg", "Sea Egg"}, pets = "Starfish, Clownfish, Shark, Dolphin, Orca, Octopus, Demon Crab, Kraken" },
    ["Volcano Zone"] = { eggs = {"Fallen Angel Egg", "Angel Egg", "Volcanic Egg"}, pets = "Fire Imp, Magma Gorilla, Phoenix, Lava Hound, Lava Dragon, Nightflame" },
    ["Blossom Zone"] = { eggs = {"Blossom Egg", "Bamboo Egg", "Fortune Egg"}, pets = "Panda, Crane, Tanuki, Samurai Cat, Kitsune, Jade Dragon, Chimera Guardian" },
    ["Galaxy Zone"] = { eggs = {"Sun Egg", "Starry Egg", "Blackhole Egg"}, pets = "Alien, Astronaut Dog, Star Cat, Meteor Golem, Galaxy Hydra, Cosmic Dragon" }
}

local SelectedZones = {}
local SelectedEggs = {}
local AutoBreak = false
local Running = true
local SafeZonePart = nil
local StatusLabel

-- ═════════════ HELPERS ═════════════
local function new(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do pcall(function() o[k] = v end) end
    if parent then o.Parent = parent end
    return o
end

local function applyStyle(obj, rad)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, rad or 6); c.Parent = obj
    local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(100, 100, 110); s.Thickness = 1; s.Transparency = 0; s.Parent = obj
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

-- ═════════════ LOGIKA BREAK (FIX PICKUP) ═════════════
local function startBreakLoop()
    task.spawn(function()
        while Running do
            if AutoBreak and next(SelectedEggs) then
                local hrp = getHRP()
                if hrp then
                    if StatusLabel then StatusLabel.Text = "Status: Mencari Egg..." end
                    local targetEgg = nil
                    local targetName = nil
                    
                    -- Cari Egg
                    for eggName, active in pairs(SelectedEggs) do
                        if active then
                            for _, obj in ipairs(Workspace:GetDescendants()) do
                                if (obj:IsA("Model") or obj:IsA("BasePart")) and string.find(string.lower(obj.Name), string.lower(eggName)) then
                                    local part = obj:IsA("BasePart") and obj or (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true))
                                    local safe = getSafeZone()
                                    if part and (not safe or (part.Position - safe.Position).Magnitude > 80) then
                                        targetEgg = {model = obj, part = part}
                                        targetName = eggName
                                        break
                                    end
                                end
                            end
                        end
                        if targetEgg then break end
                    end
                    
                    if targetEgg then
                        if StatusLabel then StatusLabel.Text = "Status: Breaking " .. targetName end
                        
                        hrp.CFrame = targetEgg.part.CFrame * CFrame.new(0, 0, -3)
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        task.wait(0.2)
                        
                        -- Equip Tool
                        local tool = LP.Character and LP.Character:FindFirstChildWhichIsA("Tool")
                        if not tool and LP.Backpack then
                            local pick = LP.Backpack:FindFirstChild("Pickaxe") or LP.Backpack:FindFirstChildWhichIsA("Tool")
                            if pick and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
                                pcall(function() LP.Character:FindFirstChildOfClass("Humanoid"):EquipTool(pick) end)
                                tool = pick
                            end
                        end
                        
                        -- Hajar Telur
                        local startTime = tick()
                        local isBroken = false
                        while tick() - startTime < 2.0 do
                            if not targetEgg.model or not targetEgg.model.Parent then 
                                isBroken = true 
                                break 
                            end
                            if tool then pcall(function() tool:Activate() end) end
                            pcall(function() firetouchinterest(hrp, targetEgg.part, 0) end)
                            pcall(function() firetouchinterest(hrp, targetEgg.part, 1) end)
                            task.wait(0.05)
                        end
                        
                        if isBroken or not targetEgg.model.Parent then
                            if StatusLabel then StatusLabel.Text = "Status: Telur Pecah! Mencari Pet..." end
                            task.wait(0.3) -- Tunggu drop spawn
                            
                            -- CARI PET DROP DI SEKITAR AREA
                            local drop = nil
                            for _, obj in ipairs(Workspace:GetDescendants()) do
                                if obj:IsA("Tool") or (obj:IsA("Model") and (obj:FindFirstChildWhichIsA("ProximityPrompt", true) or obj:FindFirstChildWhichIsA("ClickDetector", true))) then
                                    local dp = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                                    if dp and (dp.Position - targetEgg.part.Position).Magnitude < 30 then
                                        drop = obj
                                        break
                                    end
                                end
                            end
                            
                            -- AMBIL PET
                            if drop then
                                if StatusLabel then StatusLabel.Text = "Status: Mengambil Pet!" end
                                local dp = drop:IsA("BasePart") and drop or drop:FindFirstChildWhichIsA("BasePart", true)
                                if dp then
                                    hrp.CFrame = dp.CFrame + Vector3.new(0, 2, 0)
                                    task.wait(0.1)
                                    for _, d in ipairs(drop:GetDescendants()) do
                                        if d:IsA("ProximityPrompt") then pcall(function() fireproximityprompt(d) end) end
                                        if d:IsA("ClickDetector") then pcall(function() fireclickdetector(d) end) end
                                    end
                                    pcall(function() firetouchinterest(hrp, dp, 0) end)
                                    pcall(function() firetouchinterest(hrp, dp, 1) end)
                                    task.wait(0.2)
                                end
                            end
                            
                            -- BALIK KE SAFE ZONE
                            if StatusLabel then StatusLabel.Text = "Status: Balik ke Safe Zone" end
                            local safe = getSafeZone()
                            if safe then 
                                hrp.CFrame = safe.CFrame + Vector3.new(0, 3, 0) 
                                hrp.AssemblyLinearVelocity = Vector3.zero
                            end
                            task.wait(0.5)
                        else
                            if StatusLabel then StatusLabel.Text = "Status: Gagal pecah, skip..." end
                            task.wait(0.5)
                        end
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

-- ═════════════ UI CREATION ═════════════
local gui = new("ScreenGui", { Name = "AxDHubV1", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999 }, PG)

local MainBg = Color3.fromRGB(15, 15, 15)
local DarkPanel = Color3.fromRGB(30, 30, 35)
local BtnBg = Color3.fromRGB(45, 45, 55)
local WhiteText = Color3.fromRGB(255, 255, 255)
local GreyText = Color3.fromRGB(180, 180, 180)

-- Tombol Bulat
local circle = new("TextButton", { Parent = gui, Size = UDim2.fromOffset(50, 50), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = MainBg, Text = "AxD", TextColor3 = WhiteText, Font = Enum.Font.GothamBlack, TextSize = 18, ZIndex = 50 })
applyStyle(circle, 25)

-- Main Panel
local main = new("Frame", { Parent = gui, Size = UDim2.fromOffset(460, 360), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = MainBg, Visible = false, ZIndex = 10 })
applyStyle(main, 8)

local titleBar = new("Frame", { Parent = main, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = DarkPanel, ZIndex = 11 })
applyStyle(titleBar, 8)
new("TextLabel", { Parent = titleBar, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "AxD Hub v5.2", TextColor3 = WhiteText, Font = Enum.Font.GothamBold, TextSize = 16, ZIndex = 12 })

local minBtn = new("TextButton", { Parent = titleBar, Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -70, 0, 2), BackgroundColor3 = BtnBg, Text = "-", TextColor3 = WhiteText, Font = Enum.Font.GothamBold, TextSize = 16, ZIndex = 12 })
applyStyle(minBtn, 4)
local closeBtn = new("TextButton", { Parent = titleBar, Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -35, 0, 2), BackgroundColor3 = BtnBg, Text = "X", TextColor3 = WhiteText, Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 12 })
applyStyle(closeBtn, 4)

-- Drag Tombol
local draggingBtn, dragStartBtn, startPosBtn, movedBtn = false, nil, nil, 0
circle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingBtn = true; dragStartBtn = input.Position; startPosBtn = circle.Position; movedBtn = 0 end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingBtn and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartBtn
        movedBtn = movedBtn + delta.Magnitude
        circle.Position = UDim2.new(startPosBtn.X.Scale, startPosBtn.X.Offset + delta.X, startPosBtn.Y.Scale, startPosBtn.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if draggingBtn and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        draggingBtn = false
        if movedBtn < 5 then main.Visible = true; circle.Visible = false end
    end
end)

-- Drag Panel
local draggingPanel, dragStartPanel, startPosPanel
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingPanel = true; dragStartPanel = input.Position; startPosPanel = main.Position end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingPanel and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartPanel
        main.Position = UDim2.new(startPosPanel.X.Scale, startPosPanel.X.Offset + delta.X, startPosPanel.Y.Scale, startPosPanel.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if draggingPanel and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then draggingPanel = false end
end)

minBtn.MouseButton1Click:Connect(function() main.Visible = false; circle.Visible = true end)

-- Sidebar
local navL = new("Frame", { Parent = main, Size = UDim2.fromOffset(90, 325), Position = UDim2.fromOffset(0, 35), BackgroundTransparency = 1, ZIndex = 11 })
new("UIListLayout", { Parent = navL, Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center })

local function createNavBtn(txt)
    local b = new("TextButton", { Parent = navL, Size = UDim2.fromOffset(80, 35), BackgroundColor3 = BtnBg, Text = txt, TextColor3 = GreyText, Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false, ZIndex = 12 })
    applyStyle(b, 6)
    return b
end

local btnHome = createNavBtn("Beranda")
local btnBreak = createNavBtn("Break")
local btnSteal = createNavBtn("Steal")

local content = new("Frame", { Parent = main, Size = UDim2.new(1, -100, 1, -70), Position = UDim2.fromOffset(90, 35), BackgroundColor3 = DarkPanel, ZIndex = 11 })
applyStyle(content, 6)

StatusLabel = new("TextLabel", { Parent = main, Size = UDim2.new(1, -100, 0, 20), Position = UDim2.new(0, 90, 1, -30), BackgroundTransparency = 1, Text = "Status: Idle", TextColor3 = WhiteText, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12 })

-- ═════════════ TAB BERANDA ═════════════
local tabHome = new("Frame", { Parent = content, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 12 })

local profileImg = new("ImageLabel", { Parent = tabHome, Size = UDim2.fromOffset(80, 80), Position = UDim2.fromOffset(10, 10), BackgroundColor3 = MainBg, ZIndex = 13 })
applyStyle(profileImg, 8)
pcall(function() profileImg.Image = Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end)

new("TextLabel", { Parent = tabHome, Size = UDim2.new(1, -110, 0, 25), Position = UDim2.fromOffset(100, 15), BackgroundTransparency = 1, Text = "Username: " .. LP.Name, TextColor3 = WhiteText, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13 })

local pingLabel = new("TextLabel", { Parent = tabHome, Size = UDim2.new(1, -110, 0, 20), Position = UDim2.fromOffset(100, 40), BackgroundTransparency = 1, Text = "Ping: 0 ms", TextColor3 = GreyText, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13 })
task.spawn(function() while Running do pcall(function() pingLabel.Text = "Ping: " .. math.floor(LP:GetNetworkPing() * 1000) .. " ms" end); task.wait(1) end end)

local btnReload = new("TextButton", { Parent = tabHome, Size = UDim2.new(1, -20, 0, 35), Position = UDim2.fromOffset(10, 100), BackgroundColor3 = BtnBg, Text = "Reload Script (Live Update)", TextColor3 = WhiteText, Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 13 })
applyStyle(btnReload, 6)

-- LOGIKA RELOAD SCRIPT DARI GITHUB (Tanpa Rejoin)
btnReload.MouseButton1Click:Connect(function()
    if ScriptURL == "https://raw.githubusercontent.com/..." or ScriptURL == "" then
        btnReload.Text = "URL GitHub Belum Diisi!"
        task.wait(2)
        btnReload.Text = "Reload Script (Live Update)"
    else
        btnReload.Text = "Menghapus & Mendownload..."
        gui:Destroy() -- Hapus UI lama
        task.wait(0.5)
        pcall(function()
            loadstring(game:HttpGet(ScriptURL))() -- Download & Jalanin script baru
        end)
    end
end)

-- ═════════════ TAB BREAK ═════════════
local tabBreak = new("Frame", { Parent = content, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 12, Visible = false })
new("TextLabel", { Parent = tabBreak, Size = UDim2.new(1, -10, 0, 20), Position = UDim2.fromOffset(5, 5), BackgroundTransparency = 1, Text = "1. Pilih Zone", TextColor3 = WhiteText, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12 })

local zoneScroll = new("ScrollingFrame", { Parent = tabBreak, Size = UDim2.new(1, -10, 0, 80), Position = UDim2.fromOffset(5, 25), BackgroundColor3 = MainBg, BorderSizePixel = 0, ScrollBarThickness = 3, ZIndex = 12 })
applyStyle(zoneScroll, 4)
local zoneLayout = new("UIListLayout", { Parent = zoneScroll, Padding = UDim.new(0, 3), HorizontalAlignment = Enum.HorizontalAlignment.Center })

new("TextLabel", { Parent = tabBreak, Size = UDim2.new(1, -10, 0, 20), Position = UDim2.fromOffset(5, 110), BackgroundTransparency = 1, Text = "2. Pilih Egg", TextColor3 = WhiteText, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12 })

local eggScroll = new("ScrollingFrame", { Parent = tabBreak, Size = UDim2.new(1, -10, 0, 90), Position = UDim2.fromOffset(5, 130), BackgroundColor3 = MainBg, BorderSizePixel = 0, ScrollBarThickness = 3, ZIndex = 12 })
applyStyle(eggScroll, 4)
local eggLayout = new("UIListLayout", { Parent = eggScroll, Padding = UDim.new(0, 3), HorizontalAlignment = Enum.HorizontalAlignment.Center })

-- Kotak Info Pet
local petInfoBox = new("TextLabel", { Parent = tabBreak, Size = UDim2.new(1, -10, 0, 45), Position = UDim2.fromOffset(5, 225), BackgroundColor3 = MainBg, Text = "Pets: (Pilih telur untuk lihat isinya)", TextColor3 = GreyText, Font = Enum.Font.Gotham, TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 12 })
applyStyle(petInfoBox, 4)
local pad = new("UIPadding", { Parent = petInfoBox }); pad.PaddingLeft = UDim.new(0, 5); pad.PaddingTop = UDim.new(0, 5)

local btnStart = new("TextButton", { Parent = tabBreak, Size = UDim2.new(1, -10, 0, 30), Position = UDim2.new(0, 5, 1, -35), BackgroundColor3 = Color3.fromRGB(40, 100, 50), Text = "Start Break", TextColor3 = WhiteText, Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 12, Visible = false })
applyStyle(btnStart, 6)

local function renderEggs()
    for _, c in ipairs(eggScroll:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
    end
    local count = 0
    for zName, isZSelected in pairs(SelectedZones) do
        if isZSelected then
            local zoneData = EggDatabase[zName]
            if zoneData then
                for _, eName in ipairs(zoneData.eggs) do
                    count = count + 1
                    local isSelected = SelectedEggs[eName] == true
                    
                    local row = new("Frame", { Parent = eggScroll, Size = UDim2.new(1, -5, 0, 30), BackgroundColor3 = BtnBg, LayoutOrder = count, ZIndex = 13 })
                    applyStyle(row, 4)
                    
                    local btnName = new("TextButton", { Parent = row, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1, Text = eName, TextColor3 = WhiteText, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14 })
                    btnName.MouseButton1Click:Connect(function() petInfoBox.Text = "Pets inside " .. eName .. ":\n" .. zoneData.pets end)
                    
                    local cb = new("TextButton", { Parent = row, Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -25, 0.5, -10), BackgroundColor3 = isSelected and WhiteText or MainBg, Text = "", ZIndex = 14 })
                    applyStyle(cb, 4)
                    cb.MouseButton1Click:Connect(function()
                        local isNow = not (SelectedEggs[eName] == true)
                        SelectedEggs[eName] = isNow
                        cb.BackgroundColor3 = isNow and WhiteText or MainBg
                        btnStart.Visible = next(SelectedEggs) ~= nil
                    end)
                end
            end
        end
    end
    eggScroll.CanvasSize = UDim2.new(0, 0, 0, eggLayout.AbsoluteContentSize.Y + 5)
end

for zName, _ in pairs(EggDatabase) do
    local row = new("Frame", { Parent = zoneScroll, Size = UDim2.new(1, -5, 0, 25), BackgroundColor3 = BtnBg, ZIndex = 13 })
    applyStyle(row, 4)
    new("TextLabel", { Parent = row, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1, Text = zName, TextColor3 = WhiteText, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14 })
    
    local cb = new("TextButton", { Parent = row, Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -25, 0.5, -10), BackgroundColor3 = MainBg, Text = "", ZIndex = 14 })
    applyStyle(cb, 4)
    cb.MouseButton1Click:Connect(function()
        local isNow = not (SelectedZones[zName] == true)
        SelectedZones[zName] = isNow
        cb.BackgroundColor3 = isNow and WhiteText or MainBg
        renderEggs()
    end)
end
zoneLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() zoneScroll.CanvasSize = UDim2.new(0, 0, 0, zoneLayout.AbsoluteContentSize.Y + 5) end)

btnStart.MouseButton1Click:Connect(function()
    if next(SelectedEggs) then
        AutoBreak = not AutoBreak
        btnStart.Text = AutoBreak and "Stop Break" or "Start Break"
        btnStart.BackgroundColor3 = AutoBreak and Color3.fromRGB(150, 40, 40) or Color3.fromRGB(40, 100, 50)
    end
end)

-- ═════════════ TAB STEAL ═════════════
local tabSteal = new("Frame", { Parent = content, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 12, Visible = false })
new("TextLabel", { Parent = tabSteal, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "Fitur Steal menyusul.", TextColor3 = WhiteText, Font = Enum.Font.Gotham, TextSize = 13 })

local function switchTab(tab)
    tabHome.Visible = tab == "home"
    tabBreak.Visible = tab == "break"
    tabSteal.Visible = tab == "steal"
    btnHome.TextColor3 = tab == "home" and WhiteText or GreyText
    btnBreak.TextColor3 = tab == "break" and WhiteText or GreyText
    btnSteal.TextColor3 = tab == "steal" and WhiteText or GreyText
end
btnHome.MouseButton1Click:Connect(function() switchTab("home") end)
btnBreak.MouseButton1Click:Connect(function() switchTab("break") end)
btnSteal.MouseButton1Click:Connect(function() switchTab("steal") end)

-- Konfirmasi Hapus
local confirm = new("Frame", { Parent = gui, Size = UDim2.fromOffset(260, 130), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = MainBg, Visible = false, ZIndex = 200 })
applyStyle(confirm, 8)
new("TextLabel", { Parent = confirm, Size = UDim2.new(1, -20, 0, 50), Position = UDim2.fromOffset(10, 14), BackgroundTransparency = 1, Text = "Hapus AxD Hub v5.2?", TextColor3 = WhiteText, Font = Enum.Font.Gotham, TextSize = 13, TextWrapped = true, ZIndex = 201 })
local yesBtn = new("TextButton", { Parent = confirm, Size = UDim2.fromOffset(100, 30), Position = UDim2.fromOffset(14, 80), BackgroundColor3 = Color3.fromRGB(150, 40, 40), Text = "Ya", TextColor3 = WhiteText, Font = Enum.Font.GothamBold, TextSize = 13, ZIndex = 201 })
applyStyle(yesBtn, 6)
local noBtn = new("TextButton", { Parent = confirm, Size = UDim2.fromOffset(100, 30), Position = UDim2.new(1, -114, 0, 80), BackgroundColor3 = BtnBg, Text = "Batal", TextColor3 = WhiteText, Font = Enum.Font.GothamBold, TextSize = 13, ZIndex = 201 })
applyStyle(noBtn, 6)

noBtn.MouseButton1Click:Connect(function() confirm.Visible = false end)
yesBtn.MouseButton1Click:Connect(function() Running = false; gui:Destroy() end)
closeBtn.MouseButton1Click:Connect(function() confirm.Visible = true end)

switchTab("home")
