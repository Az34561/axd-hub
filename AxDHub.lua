--══════════════════════════════════════════════════════════════
--  AxD Hub v2.0 | Auto Steal (Biome Sync & Tier Data)
--══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local parentGui
pcall(function()
    parentGui = gethui and gethui() or game:GetService("CoreGui")
end)
if not parentGui then parentGui = PG end

if parentGui:FindFirstChild("AxDHubV1") then parentGui.AxDHubV1:Destroy() end

--═════════════ TIER COLORS ═════════════
local TierColors = {
    ["COMMON"] = Color3.fromRGB(100, 255, 100),
    ["UNCOMMON"] = Color3.fromRGB(100, 150, 255),
    ["RARE"] = Color3.fromRGB(200, 100, 255),
    ["EPIC"] = Color3.fromRGB(255, 255, 100),
    ["LEGENDARY"] = Color3.fromRGB(255, 170, 50),
    ["MYTHIC"] = Color3.fromRGB(255, 80, 80),
    ["COSMIC"] = Color3.fromRGB(180, 100, 255),
    ["SECRET"] = Color3.fromRGB(150, 150, 150),
    ["ETERNAL"] = Color3.fromRGB(255, 255, 255),
    ["DIVINE"] = Color3.fromRGB(255, 215, 0)
}

--═════════════ DATA HEWAN & TIER ═════════════
-- Mengambil dari list yang kamu kasih
local PetData = {
    -- COMMON
    ["Chicken"] = "COMMON", ["Dog"] = "COMMON", ["Frog"] = "COMMON", ["Duckling"] = "COMMON", ["Jerboa"] = "COMMON", ["Scorpion"] = "COMMON", 
    ["Chameleon"] = "COMMON", ["Sloth"] = "COMMON", ["Penguin"] = "COMMON", ["Snow Rabbit"] = "COMMON", ["Lava Gecko"] = "COMMON", ["Ash Beetle"] = "COMMON", 
    ["Starfish"] = "COMMON", ["Clownfish"] = "COMMON", ["Trilobite"] = "COMMON", ["Ammonite"] = "COMMON", ["Alien Beetle"] = "COMMON", ["Centipede"] = "COMMON", 
    ["Koi Fish"] = "COMMON", ["Shiba Inu"] = "COMMON", ["Golem"] = "COMMON", ["Gargoyle"] = "COMMON", ["Light Dove"] = "COMMON", ["Imp"] = "COMMON", 
    ["Toxic Rat"] = "COMMON", ["Brainrot Toilet"] = "COMMON", ["Zombie Pig"] = "COMMON", ["Mewing Cat"] = "COMMON", ["Mummy"] = "COMMON",
    -- UNCOMMON
    ["Bird"] = "UNCOMMON", ["Catfish"] = "UNCOMMON", ["Fennec Fox"] = "UNCOMMON", ["Meerkat"] = "UNCOMMON", ["Tree Frog"] = "UNCOMMON", ["Parrot"] = "UNCOMMON", 
    ["Seal"] = "UNCOMMON", ["Snowy Owl"] = "UNCOMMON", ["Magma Snail"] = "UNCOMMON", ["Flame Lizard"] = "UNCOMMON", ["Parrot Fish"] = "UNCOMMON", ["Jellyfish"] = "UNCOMMON", 
    ["Dodo"] = "UNCOMMON", ["Dimetrodon"] = "UNCOMMON", ["Space Slime"] = "UNCOMMON", ["Meteor Dog"] = "UNCOMMON", ["Crane"] = "UNCOMMON", ["Panda"] = "UNCOMMON", 
    ["Stone Cat"] = "UNCOMMON", ["Crustacia"] = "UNCOMMON", ["Flame Sprite"] = "UNCOMMON", ["Holy Lamb"] = "UNCOMMON", ["Radioactive Bat"] = "UNCOMMON", 
    ["Brainrot Sigma"] = "UNCOMMON", ["Skibidi Dog"] = "UNCOMMON", ["Frankenstein"] = "UNCOMMON", ["Vampire Bat"] = "UNCOMMON",
    -- RARE
    ["Owl"] = "RARE", ["Raccoon"] = "RARE", ["Turtle"] = "RARE", ["Camel"] = "RARE", ["Burrowing Owl"] = "RARE", ["Monkey"] = "RARE", ["Jaguar"] = "RARE", 
    ["Walrus"] = "RARE", ["Polar Bear"] = "RARE", ["Obsidian Turtle"] = "RARE", ["Fire Newt"] = "RARE", ["Stingray"] = "RARE", ["Seahorse"] = "RARE", 
    ["Pterodactyl"] = "RARE", ["Stegosaurus"] = "RARE", ["Nebula Cat"] = "RARE", ["Star Bunny"] = "RARE", ["Tanuki"] = "RARE", ["Kitsune Pup"] = "RARE", 
    ["Jade Dragon"] = "RARE", ["Minotaur"] = "RARE", ["Seraphim"] = "RARE", ["Demon Hound"] = "RARE", ["Bio Spider"] = "RARE", 
    ["Grimace"] = "RARE", ["Ohio Monster"] = "RARE", ["Pumpkin Cat"] = "RARE", ["Witch Cat"] = "RARE",
    -- EPIC
    ["Fox"] = "EPIC", ["Bear"] = "EPIC", ["Swan"] = "EPIC", ["Crocodile"] = "EPIC", ["Gila Monster"] = "EPIC", ["Coyote"] = "EPIC", ["Chimpanzee"] = "EPIC", 
    ["Toucan"] = "EPIC", ["Arctic Fox"] = "EPIC", ["Reindeer"] = "EPIC", ["Lavahound"] = "EPIC", ["Magma Slime"] = "EPIC", ["Hammerhead Shark"] = "EPIC", 
    ["Anglerfish"] = "EPIC", ["Velociraptor"] = "EPIC", ["Triceratops"] = "EPIC", ["Galaxy Fox"] = "EPIC", ["Astronaut Cat"] = "EPIC", ["Deer"] = "EPIC", 
    ["Samurai Dog"] = "EPIC", ["Colossus"] = "EPIC", ["Cyclops"] = "EPIC", ["Valkyrie"] = "EPIC", ["Hellhound"] = "EPIC", ["Acid Slime"] = "EPIC", 
    ["Mutation Dog"] = "EPIC", ["Kaiju"] = "EPIC", ["Godzilla"] = "EPIC", ["Scarecrow"] = "EPIC", ["Candy Corn Cat"] = "EPIC",
    -- LEGENDARY
    ["Brr Brr Patapim"] = "LEGENDARY", ["Axolotl"] = "LEGENDARY", ["Royal Sphinx"] = "LEGENDARY", ["Gorilla"] = "LEGENDARY", ["Snow Leopard"] = "LEGENDARY", 
    ["Yeti"] = "LEGENDARY", ["Fire Phoenix"] = "LEGENDARY", ["Great White Shark"] = "LEGENDARY", ["T-Rex"] = "LEGENDARY", ["Spinosaurus"] = "LEGENDARY", 
    ["Black Hole Blob"] = "LEGENDARY", ["Cosmic Gorilla"] = "LEGENDARY", ["Ninja Cat"] = "LEGENDARY", ["Blossom Dragon"] = "LEGENDARY", ["Titan Warden"] = "LEGENDARY", 
    ["Hydra"] = "LEGENDARY", ["Archangel"] = "LEGENDARY", ["World Burner"] = "LEGENDARY", ["Cyber Gorilla"] = "LEGENDARY", ["Mech Spider"] = "LEGENDARY", 
    ["Glitch"] = "LEGENDARY", ["Void Cat"] = "LEGENDARY", ["Headless Horseman"] = "LEGENDARY", ["Ghost Dragon"] = "LEGENDARY",
    -- MYTHIC
    ["Elder Ent"] = "MYTHIC", ["Hydra"] = "MYTHIC", ["Sand Worm"] = "MYTHIC", ["Anaconda"] = "MYTHIC", ["Ice Dragon"] = "MYTHIC", ["Lava Dragon"] = "MYTHIC", 
    ["Kraken"] = "MYTHIC", ["Megalodon"] = "MYTHIC", ["Mosasaurus"] = "MYTHIC", ["Brachiosaurus"] = "MYTHIC", ["Nebula Dragon"] = "MYTHIC", ["Eclipse Lion"] = "MYTHIC", 
    ["Shadow Samurai"] = "MYTHIC", ["Kami Dragon"] = "MYTHIC", ["Chronos"] = "MYTHIC", ["Atlas"] = "MYTHIC", ["Cherubim"] = "MYTHIC", ["Lucifer"] = "MYTHIC", 
    ["Dr. Scramble Bot"] = "MYTHIC", ["Chimera"] = "MYTHIC", ["Void Dragon"] = "MYTHIC", ["Grim Reaper"] = "MYTHIC", ["Phantom Dragon"] = "MYTHIC",
    -- COSMIC
    ["Cosmic Frog"] = "COSMIC", ["Cosmic Owl"] = "COSMIC", ["Cosmic Unicorn"] = "COSMIC", ["Star Destroyer"] = "COSMIC", ["Solar Kitsune"] = "COSMIC", 
    ["Aegis Knight"] = "COSMIC", ["Gabriel"] = "COSMIC", ["Beelzebub"] = "COSMIC", ["Cybernetic Behemoth"] = "COSMIC", ["Prototype X"] = "COSMIC", 
    ["Galaxy Agony"] = "COSMIC", ["Nebula Wolf"] = "COSMIC", ["Halloween Reaper"] = "COSMIC",
    -- SECRET
    ["King Snake"] = "SECRET", ["El Maja"] = "SECRET", ["Voidmaw"] = "SECRET", ["Black Hole Dragon"] = "SECRET", ["Shinigami"] = "SECRET", 
    ["Zeus"] = "SECRET", ["Poseidon"] = "SECRET", ["Metatron"] = "SECRET", ["Asmodeus"] = "SECRET", ["Octophant"] = "SECRET", ["Biohazard Rex"] = "SECRET", 
    ["Eternal Void"] = "SECRET", ["Dominus Darkwing"] = "SECRET", ["Mortuus"] = "SECRET", ["Zombified Dragon"] = "SECRET",
    -- ETERNAL
    ["Celestial Sunlion"] = "ETERNAL", ["Eternal Agony"] = "ETERNAL", ["Galaxy Overlord"] = "ETERNAL", ["Seraphim Overlord"] = "ETERNAL", 
    ["Hellfire Emperor"] = "ETERNAL", ["Amalgamation 404"] = "ETERNAL", ["Eternal Grim Reaper"] = "ETERNAL", ["Cyber Overlord"] = "ETERNAL",
    -- DIVINE
    ["Kitsune"] = "DIVINE", ["Nightflame"] = "DIVINE", ["Royal Skywell"] = "DIVINE", ["Spirit World Guardian"] = "DIVINE", 
    ["Scramble's Ultimate Creation"] = "DIVINE", ["Bone Emperor"] = "DIVINE", ["Strawberry Elephant"] = "DIVINE"
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

-- Cari Egg yang ada di WILD (jauh dari safezone)
local function findWildEgg(name)
    local safe = findSafeZone()
    for _, o in ipairs(Workspace:GetDescendants()) do
        if o:IsA("Model") and o.Name:lower():find(name:lower()) then
            local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart", true)
            if p then
                -- Cek jarak, kalau deket safezone berarti egg di pangkalan (skip)
                if safe then
                    local dist = (p.Position - safe.Position).Magnitude
                    if dist > 50 then -- Jarak aman, berarti di luar pangkalan
                        return { model = o, part = p }
                    end
                else
                    return { model = o, part = p } -- Fallback kalau safezone ga ketemu
                end
            end
        end
    end
    return nil
end

--═════════════ STEAL LOGIC ═════════════
local function startStealLoop()
    task.spawn(function()
        while Running do
            if AutoSteal and TargetEggName then
                local target = findWildEgg(TargetEggName)
                
                -- Kalau egg target ketemu di luar pangkalan
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
                    -- Kalau egg belum spawn di wild, diam di tempat
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
            if hum and hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
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
    Name = "AxDHubV1", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999 
}, parentGui)

local RedTheme = Color3.fromRGB(190, 40, 40)
local DarkBG = Color3.fromRGB(20, 20, 20)
local PanelBG = Color3.fromRGB(30, 30, 30)
local TextColor = Color3.fromRGB(255, 255, 255)

local main
local renderEggs

-- ⚡ TOMBOL BULAT
local circle = new("TextButton", {
    Parent = gui, Size = UDim2.fromOffset(50, 50), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), 
    BackgroundColor3 = RedTheme, Text = "AxD", TextColor3 = TextColor, Font = Enum.Font.GothamBlack, TextSize = 18, ZIndex = 50
})
corner(circle, 25)
stroke(circle, Color3.fromRGB(0,0,0), 2)

local function openPanel()
    pcall(function()
        if main then
            main.Visible = true
            circle.Visible = false
            if renderEggs then renderEggs() end
        end
    end)
end

local draggingBtn, dragStartBtn, startPosBtn, movedBtn = false, nil, nil, 0
circle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingBtn = true; dragStartBtn = input.Position; startPosBtn = circle.Position; movedBtn = 0
    end
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
        if movedBtn < 5 then openPanel() end
    end
end)
circle.MouseButton1Click:Connect(function() if movedBtn < 5 then openPanel() end end)

-- Main Panel
main = new("Frame", {
    Parent = gui, Size = UDim2.fromOffset(450, 320), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), 
    BackgroundColor3 = DarkBG, Visible = false, ZIndex = 10
})
corner(main, 6)
stroke(main, Color3.fromRGB(0,0,0), 2)

-- Title Bar
local titleBar = new("Frame", { Parent = main, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = RedTheme, ZIndex = 11 })
corner(titleBar, 6)
new("TextLabel", { Parent = titleBar, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "AxD Hub v2.0", TextColor3 = TextColor, Font = Enum.Font.GothamBlack, TextSize = 18, ZIndex = 12 })

local minBtn = new("TextButton", { Parent = titleBar, Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -70, 0, 2), BackgroundColor3 = Color3.fromRGB(50, 50, 50), Text = "-", TextColor3 = TextColor, Font = Enum.Font.GothamBlack, TextSize = 16, ZIndex = 12 })
corner(minBtn, 4)

local closeBtn = new("TextButton", { Parent = titleBar, Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -35, 0, 2), BackgroundColor3 = Color3.fromRGB(0,0,0), Text = "X", TextColor3 = TextColor, Font = Enum.Font.GothamBlack, TextSize = 14, ZIndex = 12 })
corner(closeBtn, 4)

drag(main, titleBar)

-- Side Nav (Kiri)
local navL = new("Frame", { Parent = main, Size = UDim2.fromOffset(100, 285), Position = UDim2.fromOffset(0, 35), BackgroundTransparency = 1, ZIndex = 11 })
local navLayout = new("UIListLayout", { Parent = navL, Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center })

local function createNavBtn(txt, parent)
    local b = new("TextButton", { Parent = parent, Size = UDim2.fromOffset(100, 35), BackgroundColor3 = RedTheme, Text = txt, TextColor3 = TextColor, Font = Enum.Font.GothamBold, TextSize = 14, AutoButtonColor = false })
    corner(b, 4); stroke(b, Color3.fromRGB(0,0,0), 1.5); return b
end

local btnStealTab = createNavBtn("Steal", navL)
local btnGuardTab = createNavBtn("Guard", navL)

-- Side Nav (Kanan)
local navR = new("Frame", { Parent = main, Size = UDim2.fromOffset(100, 285), Position = UDim2.new(1, -100, 0, 35), BackgroundTransparency = 1, ZIndex = 11 })
local navRLayout = new("UIListLayout", { Parent = navR, Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center })
local btnDiscord = createNavBtn("Discord", navR)
local btnConfig = createNavBtn("Config", navR)

-- Content Area
local content = new("Frame", { Parent = main, Size = UDim2.new(1, -200, 1, -35), Position = UDim2.fromOffset(100, 35), BackgroundColor3 = PanelBG, ZIndex = 11 })
corner(content, 4)

--═════════════ TAB: STEAL ═════════════
local tabSteal = new("Frame", { Parent = content, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 12 })

-- Search Bar
local searchBox = new("TextBox", { Parent = tabSteal, Size = UDim2.new(1, -10, 0, 30), Position = UDim2.fromOffset(5, 5), BackgroundColor3 = Color3.fromRGB(20,20,20), Text = "", PlaceholderText = "Search pet name...", TextColor3 = TextColor, Font = Enum.Font.Gotham, TextSize = 12, ZIndex = 13 })
corner(searchBox, 4); stroke(searchBox, RedTheme, 1)

local stealScroll = new("ScrollingFrame", {
    Parent = tabSteal, Size = UDim2.new(1, -10, 1, -85), Position = UDim2.fromOffset(5, 40),
    BackgroundColor3 = Color3.fromRGB(15, 15, 15), BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = RedTheme, ZIndex = 12
})
corner(stealScroll, 4); stroke(stealScroll, Color3.fromRGB(0,0,0), 1.5)

local eggLayout = new("UIListLayout", { Parent = stealScroll, Padding = UDim.new(0, 4), HorizontalAlignment = Enum.HorizontalAlignment.Center })
local eggPad = new("UIPadding", { Parent = stealScroll, PaddingTop = UDim.new(0, 5) })

-- Header Auto Steal (Toggle)
local headerSteal = new("Frame", { Parent = tabSteal, Size = UDim2.new(1, -10, 0, 40), Position = UDim2.new(0, 5, 1, -40), BackgroundColor3 = Color3.fromRGB(40,40,40), ZIndex = 12 })
corner(headerSteal, 4); stroke(headerSteal, Color3.fromRGB(0,0,0), 1.5)
new("TextLabel", { Parent = headerSteal, Size = UDim2.fromScale(0.7, 1), Position = UDim2.fromOffset(10,0), BackgroundTransparency = 1, Text = "Auto Steal (Tunggu Spawn)", TextColor3 = TextColor, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13 })

local toggleStealBg = new("Frame", { Parent = headerSteal, Size = UDim2.fromOffset(40, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = Color3.fromRGB(80, 20, 20), ZIndex = 13 })
corner(toggleStealBg, 10); stroke(toggleStealBg, Color3.fromRGB(0,0,0), 1.5)
local toggleStealBtn = new("TextButton", { Parent = toggleStealBg, Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(1, 1), BackgroundColor3 = Color3.fromRGB(255,255,255), Text = "", ZIndex = 14 })
corner(toggleStealBtn, 9)

local stealToggleState = false
toggleStealBtn.MouseButton1Click:Connect(function()
    stealToggleState = not stealToggleState
    AutoSteal = stealToggleState
    local targetPos = stealToggleState and UDim2.fromOffset(21, 1) or UDim2.fromOffset(1, 1)
    local targetColor = stealToggleState and RedTheme or Color3.fromRGB(80, 20, 20)
    TweenService:Create(toggleStealBtn, TweenInfo.new(0.2), {Position = targetPos}):Play()
    TweenService:Create(toggleStealBg, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
end)

-- Render Eggs (Pake Data Tier)
renderEggs = function()
    for _, c in ipairs(stealScroll:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
    end
    
    local searchText = searchBox.Text:lower()
    local count = 0
    
    -- Sort berdasarkan Tier (Divine di atas)
    local sortedPets = {}
    for petName, tier in pairs(PetData) do
        table.insert(sortedPets, {Name = petName, Tier = tier})
    end
    table.sort(sortedPets, function(a, b)
        local order = {"DIVINE", "ETERNAL", "SECRET", "COSMIC", "MYTHIC", "LEGENDARY", "EPIC", "RARE", "UNCOMMON", "COMMON"}
        local aIdx = table.find(order, a.Tier) or 99
        local bIdx = table.find(order, b.Tier) or 99
        if aIdx == bIdx then return a.Name < b.Name end
        return aIdx < bIdx
    end)

    for _, data in ipairs(sortedPets) do
        if searchText == "" or data.Name:lower():find(searchText) then
            count = count + 1
            local tierColor = TierColors[data.Tier] or Color3.fromRGB(255,255,255)
            
            local row = new("Frame", { Parent = stealScroll, Size = UDim2.new(1, -10, 0, 45), BackgroundColor3 = Color3.fromRGB(30,30,30), LayoutOrder = count, ZIndex = 12 })
            corner(row, 4); stroke(row, tierColor, 1.5)
            
            -- Nama Hewan
            new("TextLabel", { Parent = row, Size = UDim2.new(1, -40, 0, 20), Position = UDim2.fromOffset(10, 4), BackgroundTransparency = 1, Text = data.Name, TextColor3 = TextColor, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13 })
            
            -- Tier di Bawah Nama
            new("TextLabel", { Parent = row, Size = UDim2.new(1, -40, 0, 15), Position = UDim2.fromOffset(10, 22), BackgroundTransparency = 1, Text = data.Tier, TextColor3 = tierColor, Font = Enum.Font.GothamBlack, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13 })
            
            -- Checkbox
            local cb = new("TextButton", { Parent = row, Size = UDim2.fromOffset(24, 24), Position = UDim2.new(1, -32, 0.5, -12), BackgroundColor3 = (TargetEggName == data.Name) and RedTheme or Color3.fromRGB(20,20,20), Text = "", ZIndex = 13 })
            corner(cb, 4); stroke(cb, tierColor, 1.5)
            
            cb.MouseButton1Click:Connect(function()
                if TargetEggName == data.Name then
                    TargetEggName = nil
                    cb.BackgroundColor3 = Color3.fromRGB(20,20,20)
                else
                    TargetEggName = data.Name
                    -- Reset semua tombol lain
                    for _, child in ipairs(stealScroll:GetChildren()) do
                        if child:IsA("Frame") then
                            local btn = child:FindFirstChildOfClass("TextButton")
                            if btn then btn.BackgroundColor3 = Color3.fromRGB(20,20,20) end
                        end
                    end
                    cb.BackgroundColor3 = RedTheme
                end
            end)
        end
    end
    stealScroll.CanvasSize = UDim2.new(0, 0, 0, eggLayout.AbsoluteContentSize.Y + 10)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(renderEggs)
eggLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    stealScroll.CanvasSize = UDim2.new(0, 0, 0, eggLayout.AbsoluteContentSize.Y + 10)
end)

--═════════════ TAB: GUARD ═════════════
local tabGuard = new("Frame", { Parent = content, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 12, Visible = false })

local function createGuardToggle(txt, posY)
    local f = new("Frame", { Parent = tabGuard, Size = UDim2.new(1, -10, 0, 40), Position = UDim2.fromOffset(5, posY), BackgroundColor3 = Color3.fromRGB(40,40,40), ZIndex = 12 })
    corner(f, 4); stroke(f, Color3.fromRGB(0,0,0), 1.5)
    new("TextLabel", { Parent = f, Size = UDim2.fromScale(0.7, 1), Position = UDim2.fromOffset(10,0), BackgroundTransparency = 1, Text = txt, TextColor3 = TextColor, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13 })
    local bg = new("Frame", { Parent = f, Size = UDim2.fromOffset(40, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = Color3.fromRGB(80, 20, 20), ZIndex = 13 })
    corner(bg, 10); stroke(bg, Color3.fromRGB(0,0,0), 1.5)
    local btn = new("TextButton", { Parent = bg, Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(1, 1), BackgroundColor3 = Color3.fromRGB(255,255,255), Text = "", ZIndex = 14 })
    corner(btn, 9)
    return btn, bg
end

local hitBtn, hitBg = createGuardToggle("Anti Hit (Godmode)", 5)
local guardBtn, guardBg = createGuardToggle("Anti Guard (Freeze NPC)", 50)
local hitState, guardState = false, false

hitBtn.MouseButton1Click:Connect(function()
    hitState = not hitState; AntiHit = hitState
    TweenService:Create(hitBtn, TweenInfo.new(0.2), {Position = hitState and UDim2.fromOffset(21, 1) or UDim2.fromOffset(1, 1)}):Play()
    TweenService:Create(hitBg, TweenInfo.new(0.2), {BackgroundColor3 = hitState and RedTheme or Color3.fromRGB(80, 20, 20)}):Play()
end)

guardBtn.MouseButton1Click:Connect(function()
    guardState = not guardState; AntiGuard = guardState
    TweenService:Create(guardBtn, TweenInfo.new(0.2), {Position = guardState and UDim2.fromOffset(21, 1) or UDim2.fromOffset(1, 1)}):Play()
    TweenService:Create(guardBg, TweenInfo.new(0.2), {BackgroundColor3 = guardState and RedTheme or Color3.fromRGB(80, 20, 20)}):Play()
    if not guardState then
        for _, m in ipairs(Workspace:GetDescendants()) do
            if m:IsA("Model") then
                local hum = m:FindFirstChildOfClass("Humanoid")
                if hum and (m.Name:lower():find("guard") or m.Name:lower():find("npc")) then hum.WalkSpeed = 16 end
            end
        end
    end
end)

-- Tab Switch
local function showTab(tab)
    tabSteal.Visible = tab == "steal"
    tabGuard.Visible = tab == "guard"
end
btnStealTab.MouseButton1Click:Connect(function() showTab("steal") end)
btnGuardTab.MouseButton1Click:Connect(function() showTab("guard") end)

-- Close / Min
minBtn.MouseButton1Click:Connect(function() main.Visible = false; circle.Visible = true end)

-- Konfirmasi Hapus
local confirm = new("Frame", { Parent = gui, Size = UDim2.fromOffset(260, 150), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(15, 12, 20), Visible = false, ZIndex = 200 })
corner(confirm, 12); stroke(confirm, Color3.fromRGB(180, 50, 70), 1.5)
new("TextLabel", { Parent = confirm, Size = UDim2.new(1, -20, 0, 50), Position = UDim2.fromOffset(10, 14), BackgroundTransparency = 1, Text = "Hapus AxD Hub v2.0?\nScript bakal berhenti total.", TextColor3 = Color3.fromRGB(255, 220, 220), Font = Enum.Font.Gotham, TextSize = 12, TextWrapped = true, ZIndex = 201 })
local yesBtn = new("TextButton", { Parent = confirm, Size = UDim2.fromOffset(110, 34), Position = UDim2.fromOffset(14, 100), BackgroundColor3 = Color3.fromRGB(120, 30, 45), Text = "Ya, Hapus", TextColor3 = Color3.fromRGB(255, 240, 240), Font = Enum.Font.GothamBold, TextSize = 13, ZIndex = 201 })
corner(yesBtn, 8)
local noBtn = new("TextButton", { Parent = confirm, Size = UDim2.fromOffset(110, 34), Position = UDim2.new(1, -124, 0, 100), BackgroundColor3 = Color3.fromRGB(35, 35, 50), Text = "Batal", TextColor3 = Color3.fromRGB(220, 220, 240), Font = Enum.Font.GothamBold, TextSize = 13, ZIndex = 201 })
corner(noBtn, 8)

noBtn.MouseButton1Click:Connect(function() confirm.Visible = false end)
yesBtn.MouseButton1Click:Connect(function() Running = false; gui:Destroy() end)
closeBtn.MouseButton1Click:Connect(function() confirm.Visible = true end)

task.wait(1)
task.spawn(function() pcall(renderEggs) end)
