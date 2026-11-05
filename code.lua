-- HFX Fruit ESP - Blox Fruits
-- ميزة: إعادة التفعيل تلقائياً عند الانتقال لسيرفر آخر (Server Hop)

-- تنفيذ السكربت تلقائياً بعد الانتقال إلى سيرفر جديد
if queue_on_teleport then
    queue_on_teleport([[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/اسم-حسابك/اسم-المستودع/main/HFX_FruitESP.lua"))()
    ]])
end

-- منع تكرار الواجهة عند إعادة تشغيل السكربت
if game.CoreGui:FindFirstChild("HFX_TopTextUI") then game.CoreGui:FindFirstChild("HFX_TopTextUI"):Destroy() end
if game.CoreGui:FindFirstChild("DevilFruitESP_Folder") then game.CoreGui:FindFirstChild("DevilFruitESP_Folder"):Destroy() end

-- إنشاء مجلد لتخزين المؤشرات البرمجية
local ESPFolder = Instance.new("Folder", game.CoreGui)
ESPFolder.Name = "DevilFruitESP_Folder"

-- 1. إنشاء واجهة النص العلوي للشاشة (HFX)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "HFX_TopTextUI"
ScreenGui.ResetOnSpawn = false

local TopText = Instance.new("TextLabel", ScreenGui)
TopText.Name = "TopText"
TopText.Size = UDim2.new(0, 150, 0, 40)
TopText.Position = UDim2.new(0.5, -75, 0, 15) -- أعلى وسط الشاشة تماماً
TopText.BackgroundTransparency = 1 -- خلفية شفافة ليكون النص فقط واضحاً
TopText.Text = "HFX"
TopText.Font = Enum.Font.GothamBold
TopText.TextSize = 28 -- حجم الخط كبير وواضح
TopText.TextStrokeTransparency = 0.1 -- ظل أسود ناعم خلف النص ليزيد وضوحه
TopText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

-- محرك الـ RGB لتحريك ألوان النص العلوي (HFX)
task.spawn(function()
    local hue = 0
    while task.wait() do
        hue = (hue + 1.5) % 360 -- سرعة تموج الألوان
        local color = Color3.fromHSV(hue / 360, 1, 1)
        TopText.TextColor3 = color
    end
end)

-- 2. دالة كاشف الفواكه الشيطانية بحدود RGB وميزة الرؤية خلف الجدران
local function CreateESP(fruit)
    if fruit:IsA("Tool") or fruit:IsA("Model") then
        if string.find(string.lower(fruit.Name), "fruit") and not string.find(string.lower(fruit.Name), "dealer") then
            
            local handle = fruit:FindFirstChild("Handle") or fruit:FindFirstChildOfClass("Part") or fruit:FindFirstChildOfClass("MeshPart")
            if handle and not handle:FindFirstChild("FruitESP") then
                
                -- إنشاء لوحة الاسم والمسافة فوق الفاكهة
                local BillboardGui = Instance.new("BillboardGui", handle)
                BillboardGui.Name = "FruitESP"
                BillboardGui.AlwaysOnTop = true
                BillboardGui.Size = UDim2.new(0, 200, 0, 50)
                BillboardGui.Adornee = handle
                BillboardGui.ExtentsOffset = Vector3.new(0, 2.5, 0)

                local TextLabel = Instance.new("TextLabel", BillboardGui)
                TextLabel.Size = UDim2.new(1, 0, 1, 0)
                TextLabel.BackgroundTransparency = 1
                TextLabel.Font = Enum.Font.GothamBold
                TextLabel.TextSize = 15
                TextLabel.TextStrokeTransparency = 0.2
                TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

                -- إنشاء خط التحديد المحيط بجسم الفاكهة (Highlight) للرؤية جدارياً
                local Highlight = Instance.new("Highlight")
                Highlight.Name = fruit.Name .. "_Highlight"
                Highlight.Parent = ESPFolder
                Highlight.Adornee = fruit 
                Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- الرؤية عبر الجدران
                Highlight.OutlineTransparency = 0
                Highlight.FillTransparency = 0.75

                -- محرك الـ RGB وتحديث المسافات للفواكه بشكل مستقل
                task.spawn(function()
                    local fruitHue = 0
                    while fruit:IsDescendantOf(workspace) and handle:FindFirstChild("FruitESP") do
                        fruitHue = (fruitHue + 1.5) % 360
                        local dynamicColor = Color3.fromHSV(fruitHue / 360, 1, 1)
                        
                        -- تطبيق تدرج الألوان على كاشف الفاكهة ونصوصها
                        Highlight.OutlineColor = dynamicColor
                        Highlight.FillColor = dynamicColor
                        TextLabel.TextColor3 = dynamicColor
                        
                        -- حساب المسافة الحالية بين اللاعب والفاكهة
                        local player = game.Players.LocalPlayer
                        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local distance = math.floor((player.Character.HumanoidRootPart.Position - handle.Position).Magnitude)
                            TextLabel.Text = "🍇 " .. fruit.Name .. "\n[" .. tostring(distance) .. "m]"
                        end
                        task.wait(0.03)
                    end
                    Highlight:Destroy()
                end)
            end
        end
    end
end

-- فحص الماب فور تشغيل السكربت لرصد الفواكه المرسبنة مسبقاً
for _, object in ipairs(workspace:GetChildren()) do
    CreateESP(object)
end

-- مراقبة السيرفر حياً لظهور أي فواكه جديدة تلقائياً
workspace.ChildAdded:Connect(function(child)
    task.wait(0.5)
    CreateESP(child)
end)
