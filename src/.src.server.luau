-- Copyright (c) 2024 Shinji esk.
-- このソフトウェアはMITライセンスのもとで公開されています。。。。
-- This software is released under the MIT License.
-- https://opensource.org/licenses/MIT

-- Services
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")
local MaterialService = game:GetService("MaterialService")

-- Constants
local MAINFRAME_BACKGROUND_COLOR =Color3.fromRGB(158, 158, 158)
local FRAME_BACKGROUND_COLOR = Color3.fromRGB(234, 234, 234)
local FRAME_BORDER_COLOR = Color3.fromRGB(99, 99, 99)
local BUTTON_BACKGROUND_COOLOR = Color3.fromRGB(205, 205, 205)
local BUTTON_TEXT_COLOR = Color3.fromRGB(0, 0, 0)
local HOVER_BACKGROUND_COLOR = Color3.fromRGB(96, 107, 209) 
local HOVER_TEXT_COLOR = Color3.fromRGB(255, 255, 255) 
local TEXTBOX_BACKGROUND_COLOR = Color3.fromRGB(255,255,255)
local DROPDOWN_SCROOLBAR_COLOR = Color3.fromRGB(68, 68, 68)
-- Font
local FONT_NOTO_SANS_JP = {
    REGULAR = Font.new("rbxasset://fonts/families/NotoSerifJP.json", Enum.FontWeight.Regular),
    BOLD = Font.new("rbxasset://fonts/families/NotoSerifJP.json", Enum.FontWeight.Bold),
    ITALIC = Font.new("rbxasset://fonts/families/NotoSerifJP.json", Enum.FontWeight.Regular, Enum.FontStyle.Italic)
}

local FONT_SIZE = {
    SMALL = 9,
    MEDIUM = 16,
    LARGE = 18
}


-- SettingsManager
local SettingsManager = {}

function SettingsManager.saveSettings(plugin, settings)
	local settingsToSave = {
		useDefaultMaterial = settings.useDefaultMaterial,
		selectedMaterial = settings.selectedMaterial,
		selectedVariant = settings.selectedVariant,
		defaultColorR = settings.defaultColor and settings.defaultColor.R or 1,
		defaultColorG = settings.defaultColor and settings.defaultColor.G or 1,
		defaultColorB = settings.defaultColor and settings.defaultColor.B or 1,
		variantColorR = settings.variantColor and settings.variantColor.R or 1,
		variantColorG = settings.variantColor and settings.variantColor.G or 1,
		variantColorB = settings.variantColor and settings.variantColor.B or 1,
        reflectance = settings.reflectance or 0,
        transparency = settings.transparency or 0
	}
	local success, errorMsg = pcall(function()
		plugin:SetSetting("MaterialAssignerSettings", settingsToSave)
	end)
	if not success then
		warn("設定の保存に失敗しました: " .. errorMsg)
	end
end

function SettingsManager.loadSettings(plugin)
	local success, result = pcall(function()
		return plugin:GetSetting("MaterialAssignerSettings")
	end)
	if not success then
		warn("設定の読み込みに失敗しました: " .. result)
		return {
			useDefaultMaterial = true,
			selectedMaterial = "Plastic",
			defaultColor = Color3.new(1, 1, 1),
			variantColor = Color3.new(1, 1, 1)
		}
	end

	if result then
		result.defaultColor = Color3.new(
			result.defaultColorR or 1,
			result.defaultColorG or 1,
			result.defaultColorB or 1
		)
		result.variantColor = Color3.new(
			result.variantColorR or 1,
			result.variantColorG or 1,
			result.variantColorB or 1
		)
        result.reflectance = result.reflectance or 0
        result.transparency = result.transparency or 0
	end

	return result or {
		useDefaultMaterial = true,
		selectedMaterial = "Plastic",
		defaultColor = Color3.new(1, 1, 1),
		variantColor = Color3.new(1, 1, 1),
        reflectance = 0,
        transparency = 0
	}
end

-- UICreator
local UICreator = {}

function UICreator.createFrame(name, size, position, parent)
	local newFrame = Instance.new("Frame")
	newFrame.Name = name
	newFrame.Size = size
	newFrame.Position = position
	newFrame.BackgroundColor3 = FRAME_BACKGROUND_COLOR
	newFrame.BorderSizePixel = 1
	newFrame.BorderColor3 = FRAME_BORDER_COLOR
	newFrame.Parent = parent
	return newFrame
end

function UICreator.createButton(text, size, position, parent)
	local button = Instance.new("TextButton")
	button.Size = size
    button.BackgroundColor3 = BUTTON_BACKGROUND_COOLOR
	button.Position = position
	button.Text = text
    button.TextColor3 = BUTTON_TEXT_COLOR
    button.FontFace = FONT_NOTO_SANS_JP.REGULAR
    button.TextSize = FONT_SIZE.MEDIUM
	button.Parent = parent
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = HOVER_BACKGROUND_COLOR
        button.TextColor3 = HOVER_TEXT_COLOR
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = BUTTON_BACKGROUND_COOLOR
        button.TextColor3 = BUTTON_TEXT_COLOR
    end)

	return button
end

function UICreator.createRadioButton(text, position, parent)
	local button = Instance.new("TextButton")
	button.Position = position
	button.Size = UDim2.new(0, 16, 0, 16)
	button.Text = ""
    button.TextSize = 10
	button.BackgroundColor3 = Color3.new(1, 1, 1)
	button.BorderColor3 = Color3.new(0, 0, 0)
	button.Parent = parent

	local label = Instance.new("TextLabel")
	label.Position = UDim2.new(0, 25, 0, 0) + position
	label.Size = UDim2.new(0, 200, 0, 16)
	label.BackgroundTransparency = 1
	label.Text = text
    label.FontFace = FONT_NOTO_SANS_JP.REGULAR
    label.TextSize = FONT_SIZE.MEDIUM
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent

	return button
end

-- ColorPicker
local ColorPicker = {}

function ColorPicker.createSlider(name, yPosition, maxValue, parent)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.05, 0, 0, 20)
	label.Position = UDim2.new(0, 5, 0, yPosition)
    label.FontFace = FONT_NOTO_SANS_JP.REGULAR
	label.TextSize = FONT_SIZE.MEDIUM
	label.Text = name
	label.TextXAlignment = Enum.TextXAlignment.Right
	label.BackgroundTransparency = 1
	label.Parent = parent

	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.new(0.15, -10, 0, 20)
	textBox.Position = UDim2.new(0.05, 15, 0, yPosition)
    textBox.FontFace = FONT_NOTO_SANS_JP.REGULAR
	textBox.TextSize = FONT_SIZE.MEDIUM
    textBox.BackgroundColor3 = TEXTBOX_BACKGROUND_COLOR
	textBox.Parent = parent
	textBox.ClearTextOnFocus = false
	textBox.Text = "0"

	local slider = Instance.new("TextButton")
	slider.Size = UDim2.new(0.75, -25, 0, 20)
	slider.Position = UDim2.new(0.2, 15, 0, yPosition)
	slider.Text = ""
	slider.TextSize = FONT_SIZE.MEDIUM
	slider.Parent = parent

	local sliderFill = Instance.new("Frame")
	sliderFill.Size = UDim2.new(0, 0, 1, 0)
	sliderFill.BackgroundColor3 = Color3.new(0, 0.5, 1)
	sliderFill.Parent = slider

	return label, textBox, slider, sliderFill
end

function ColorPicker.setupSliderBehavior(slider, sliderFill, textBox, colorKey, max, updateColorCallback)
	local isDragging = false

	local function updateValue(x)
		local percentage = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
		local value = math.floor(percentage * max)
		textBox.Text = tostring(value)
		sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
		updateColorCallback()
	end

	slider.MouseButton1Down:Connect(function()
		isDragging = true
	end)

	slider.MouseButton1Up:Connect(function()
		isDragging = false
	end)

	slider.MouseLeave:Connect(function()
		isDragging = false
	end)

	slider.MouseMoved:Connect(function(x, y)
		if isDragging then
			updateValue(x)
		end
	end)

	textBox.FocusLost:Connect(function(enterPressed)
		local value = tonumber(textBox.Text)
		if value then
			value = math.clamp(math.floor(value), 0, max)
			textBox.Text = tostring(value)
			sliderFill.Size = UDim2.new(value / max, 0, 1, 0)
			updateColorCallback()
		end
	end)
end

function ColorPicker.updateColor(settings, colorDisplay, rgbRadio, rTextBox, gTextBox, bTextBox, hTextBox, sTextBox, vTextBox)
	local color
	if rgbRadio.Text == "●" then
		local r = tonumber(rTextBox.Text) or 0
		local g = tonumber(gTextBox.Text) or 0
		local b = tonumber(bTextBox.Text) or 0
		color = Color3.new(r/255, g/255, b/255)
	else
		local h = tonumber(hTextBox.Text) or 0
		local s = tonumber(sTextBox.Text) or 0
		local v = tonumber(vTextBox.Text) or 0
		color = Color3.fromHSV(h/360, s/100, v/100)
	end
	colorDisplay.BackgroundColor3 = color
	if settings.useDefaultMaterial then
		settings.defaultColor = color
	else
		settings.variantColor = color
	end
end

-- MaterialSelector
local MaterialSelector = {}

function MaterialSelector.getMaterialVariants()
	local variants = {}
	local materialVariants = MaterialService:GetDescendants()

	for _, variant in ipairs(materialVariants) do
		if variant:IsA("MaterialVariant") then
			table.insert(variants, variant.Name)
		end
	end

	return variants
end

function MaterialSelector.getDefaultMaterials()
    local defaultMaterials = {}
    for _, material in pairs(Enum.Material:GetEnumItems()) do
        table.insert(defaultMaterials, material.Name)
    end
    table.sort(defaultMaterials) 
    return defaultMaterials
end

function MaterialSelector.createDropdown(settings, widget, dropdown)
	local dropdownMenu = Instance.new("ScrollingFrame")
	dropdownMenu.Size = UDim2.new(0.9, 0, 0, 200)
	dropdownMenu.Position = UDim2.new(0.05, 0, 0, 105)
	dropdownMenu.Parent = widget
	dropdownMenu.ZIndex = 10
	dropdownMenu.BackgroundColor3 = DROPDOWN_SCROOLBAR_COLOR
	dropdownMenu.BorderSizePixel = 1

	local items = settings.useDefaultMaterial and MaterialSelector.getDefaultMaterials() or MaterialSelector.getMaterialVariants()
	for i, item in ipairs(items) do
		local button = Instance.new("TextButton")
		button.Text = item
		button.Size = UDim2.new(1, 0, 0, 25)
		button.Position = UDim2.new(0, 0, 0, (i-1) * 25)
        button.BackgroundColor3 = BUTTON_BACKGROUND_COOLOR
        button.TextColor3 = BUTTON_TEXT_COLOR
		button.Parent = dropdownMenu
		button.ZIndex = 11
        
		button.MouseButton1Click:Connect(function()
			dropdown.Text = item
			if settings.useDefaultMaterial then
				settings.selectedMaterial = item
			else
				settings.selectedVariant = item
			end
			dropdownMenu:Destroy()
		end)

        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = HOVER_BACKGROUND_COLOR
            button.TextColor3 = HOVER_TEXT_COLOR
        end)

        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = BUTTON_BACKGROUND_COOLOR
            button.TextColor3 = BUTTON_TEXT_COLOR
        end)

	end

	dropdownMenu.CanvasSize = UDim2.new(0, 0, 0, #items * 25)

	local function closeDropdown(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local position = input.Position
			local dropdownPosition = dropdownMenu.AbsolutePosition
			local dropdownSize = dropdownMenu.AbsoluteSize
			if position.X < dropdownPosition.X or position.X > dropdownPosition.X + dropdownSize.X or
				position.Y < dropdownPosition.Y or position.Y > dropdownPosition.Y + dropdownSize.Y then
				dropdownMenu:Destroy()
			end
		end
	end

	game:GetService("UserInputService").InputBegan:Connect(closeDropdown)
end

function MaterialSelector.updateRadioButtons(useDefaultMaterial, defaultMaterialRadio, materialVariantRadio, dropdown)
	defaultMaterialRadio.Text = useDefaultMaterial and "●" or ""
	materialVariantRadio.Text = useDefaultMaterial and "" or "●"
	dropdown.Text = useDefaultMaterial and "デフォルトマテリアルを選択" or "マテリアルバリアントを選択"
end





-- extra -------------------------------------------------------------------------------
local extra = {}

function extra.createSlider(name, yPosition, maxValue, parent)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.05, 0, 0, 20)
	label.Position = UDim2.new(0, 5, 0, yPosition)
    label.FontFace = FONT_NOTO_SANS_JP.REGULAR
	label.TextSize = FONT_SIZE.MEDIUM
	label.Text = name
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = parent

	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.new(0.15, -10, 0, 20)
	textBox.Position = UDim2.new(0, 100, 0, yPosition)
    textBox.FontFace = FONT_NOTO_SANS_JP.REGULAR
	textBox.TextSize = FONT_SIZE.MEDIUM
    textBox.BackgroundColor3 = TEXTBOX_BACKGROUND_COLOR
	textBox.Parent = parent
	textBox.ClearTextOnFocus = false
	textBox.Text = "0"

	local slider = Instance.new("TextButton")
	slider.Size = UDim2.new(1, -160, 0, 20)
	slider.Position = UDim2.new(0, 145, 0, yPosition)
	slider.Text = ""
	slider.TextSize = FONT_SIZE.MEDIUM
	slider.Parent = parent

	local sliderFill = Instance.new("Frame")
	sliderFill.Size = UDim2.new(0, 0, 1, 0)
	sliderFill.BackgroundColor3 = Color3.new(0, 0.5, 1)
	sliderFill.Parent = slider

	return label, textBox, slider, sliderFill
end

function extra.setupSliderBehavior(slider, sliderFill, textBox, updateCallback)
    local isDragging = false

    local function updateValue(x)
        local percentage = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        local value = percentage
        textBox.Text = string.format("%.2f", value)
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        if updateCallback and type(updateCallback) == "function" then
            updateCallback(value)
        end
    end

    slider.MouseButton1Down:Connect(function()
        isDragging = true
    end)

    slider.MouseButton1Up:Connect(function()
        isDragging = false
    end)

    slider.MouseLeave:Connect(function()
        isDragging = false
    end)

    slider.MouseMoved:Connect(function(x, y)
        if isDragging then
            updateValue(x)
        end
    end)

    textBox.FocusLost:Connect(function(enterPressed)
        local value = tonumber(textBox.Text)
        if value then
            value = math.clamp(value, 0, 1)
            textBox.Text = string.format("%.2f", value)
            sliderFill.Size = UDim2.new(value, 0, 1, 0)
            if updateCallback and type(updateCallback) == "function" then
                updateCallback(value)
            end
        end
    end)
end


-- Eyedropper
local Eyedropper = {}

function Eyedropper.pickColor(settings, updateRadioButtons, dropdown, rTextBox, gTextBox, bTextBox, hTextBox, sTextBox, vTextBox, colorDisplay, rSliderFill, gSliderFill, bSliderFill, hSliderFill, sSliderFill, vSliderFill, reflectanceTextBox, reflectanceSliderFill, transparencyTextBox, transparencySliderFill)
    local selectedObjects = Selection:Get()
    if #selectedObjects == 0 then
        warn("オブジェクトが選択されていません。")
        return
    end

    local function findFirstBasePart(obj)
        if obj:IsA("BasePart") then
            return obj
        elseif obj:IsA("Model") then
            for _, child in ipairs(obj:GetDescendants()) do
                if child:IsA("BasePart") then
                    return child
                end
            end
        end
        return nil
    end

    local object = findFirstBasePart(selectedObjects[1])
    if not object then
        warn("選択されたオブジェクトまたはその子オブジェクトにBasePartが見つかりません。")
        return
    end

    local material = object.Material
    local materialVariant = object.MaterialVariant
    local color = object.Color
    local reflectance = object.Reflectance
    local transparency = object.Transparency

    if materialVariant ~= "" then
        settings.useDefaultMaterial = false
        settings.selectedVariant = materialVariant
        updateRadioButtons(false)
        dropdown.Text = materialVariant
    else
        settings.useDefaultMaterial = true
        settings.selectedMaterial = material.Name
        updateRadioButtons(true)
        dropdown.Text = material.Name
    end

    if color then
        local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
        local h, s, v = color:ToHSV()
        h, s, v = math.floor(h * 360), math.floor(s * 100), math.floor(v * 100)

        rTextBox.Text = tostring(r)
        gTextBox.Text = tostring(g)
        bTextBox.Text = tostring(b)
        rSliderFill.Size = UDim2.new(color.R, 0, 1, 0)
        gSliderFill.Size = UDim2.new(color.G, 0, 1, 0)
        bSliderFill.Size = UDim2.new(color.B, 0, 1, 0)

        hTextBox.Text = tostring(h)
        sTextBox.Text = tostring(s)
        vTextBox.Text = tostring(v)
        hSliderFill.Size = UDim2.new(h / 360, 0, 1, 0)
        sSliderFill.Size = UDim2.new(s / 100, 0, 1, 0)
        vSliderFill.Size = UDim2.new(v / 100, 0, 1, 0)

        colorDisplay.BackgroundColor3 = color

        if settings.useDefaultMaterial then
            settings.defaultColor = color
        else
            settings.variantColor = color
        end
    else
        warn("色情報を取得できませんでした。")
    end

    -- 反射率と透明度の設定
    if reflectance then
        settings.reflectance = reflectance
        reflectanceTextBox.Text = string.format("%.2f", reflectance)
        reflectanceSliderFill.Size = UDim2.new(reflectance, 0, 1, 0)
    end

    if transparency then
        settings.transparency = transparency
        transparencyTextBox.Text = string.format("%.2f", transparency)
        transparencySliderFill.Size = UDim2.new(transparency, 0, 1, 0)
    end
end


-- MaterialAssigner
local MaterialAssigner = {}

function MaterialAssigner.assignMaterial(settings)
    local selectedObjects = Selection:Get()
    if #selectedObjects == 0 then
        warn("オブジェクトが選択されていません。")
        return
    end

    if settings.useDefaultMaterial and not settings.selectedMaterial then
        warn("デフォルトマテリアルが選択されていません。")
        return
    elseif not settings.useDefaultMaterial and not settings.selectedVariant then
        warn("マテリアルバリアントが選択されていません。")
        return
    end

    ChangeHistoryService:SetWaypoint("Before Material Assignment")

    local function roundToTwoDecimals(value)
        return tonumber(string.format("%.2f", value))
    end

    local function applyMaterialToObject(object)
        if object:IsA("BasePart") then
            if settings.useDefaultMaterial and settings.selectedMaterial then
                object.Material = Enum.Material[settings.selectedMaterial]
                object.MaterialVariant = ""
                object.Color = settings.defaultColor
            elseif not settings.useDefaultMaterial and settings.selectedVariant then
                local variant = MaterialService:FindFirstChild(settings.selectedVariant, true)
                if variant and variant:IsA("MaterialVariant") then
                    local baseMaterial = variant.BaseMaterial
                    if baseMaterial then
                        object.Material = baseMaterial
                    else
                        warn("Base Materialが見つかりません:", settings.selectedVariant)
                    end
                    object.MaterialVariant = variant.Name
                    object.Color = settings.variantColor
                else
                    warn("マテリアルバリアントが見つかりません:", settings.selectedVariant)
                end
            end

            -- 反射率とトランスペアレンシーを適用（小数点以下2位まで正確に丸める）
            local reflectance = roundToTwoDecimals(settings.reflectance or 0)
            local transparency = roundToTwoDecimals(settings.transparency or 0)
            
            object.Reflectance = reflectance
            object.Transparency = transparency

            if object:IsA("UnionOperation") then
                object.UsePartColor = true
            end
        elseif object:IsA("Model") then
            for _, child in ipairs(object:GetDescendants()) do
                if child:IsA("BasePart") then
                    applyMaterialToObject(child)
                end
            end
        end
    end

    for _, object in ipairs(selectedObjects) do
        applyMaterialToObject(object)
    end

    ChangeHistoryService:SetWaypoint("After Material Assignment")
end

-- Main
local function initializePlugin(plugin)
	local settings = SettingsManager.loadSettings(plugin)

	local toolbar = plugin:CreateToolbar("マテリアル適用")
	local assignButton = toolbar:CreateButton("適用する", "マテリアルを適用する", "rbxassetid://18155801323")
	local widgetButton = toolbar:CreateButton("設定を開く", "マテリアル適用の設定を開く", "rbxassetid://18155801323")

	local widget = plugin:CreateDockWidgetPluginGui(
		"MaterialAssignerWidget",
		DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 300, 450, 300, 450)
	)

	widget.Title = "マテリアル適用"

	local frame = UICreator.createFrame("MainFrame", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), widget)
	frame.BackgroundColor3 = MAINFRAME_BACKGROUND_COLOR

    -- materialSelection ----------------------------------
	local materialSelectionFrame = UICreator.createFrame("MaterialSelectionFrame", UDim2.new(0.9, 0, 0, 95), UDim2.new(0.05, 0, 0, 10), frame)

	local defaultMaterialRadio = UICreator.createRadioButton("マテリアル", UDim2.new(0, 10, 0, 10), materialSelectionFrame)
	local materialVariantRadio = UICreator.createRadioButton("マテリアルバリアント", UDim2.new(0, 10, 0, 32), materialSelectionFrame)

	local dropdown = UICreator.createButton("マテリアルを選択", UDim2.new(0.9, 0, 0, 24), UDim2.new(0, 10, 0, 60), materialSelectionFrame)

    -- colorFrame -------------------------------------
	local colorFrame = UICreator.createFrame("ColorFrame", UDim2.new(0.9, 0, 0, 210), UDim2.new(0.05, 0, 0, 110), frame)

    local radioColorFrame = UICreator.createFrame("radioColorFrame", UDim2.new(0.9, 0,0,36),UDim2.new(0,10,0,10),colorFrame)

	local rgbRadio = UICreator.createRadioButton("RGB", UDim2.new(0, 10, 0, 10), radioColorFrame)
	local hsvRadio = UICreator.createRadioButton("HSV", UDim2.new(0, 80, 0, 10), radioColorFrame)

	local rLabel, rTextBox, rSlider, rSliderFill = ColorPicker.createSlider("R", 60, 255, colorFrame)
	local gLabel, gTextBox, gSlider, gSliderFill = ColorPicker.createSlider("G", 90, 255, colorFrame)
	local bLabel, bTextBox, bSlider, bSliderFill = ColorPicker.createSlider("B", 120, 255, colorFrame)

	local hLabel, hTextBox, hSlider, hSliderFill = ColorPicker.createSlider("H", 60, 360, colorFrame)
	local sLabel, sTextBox, sSlider, sSliderFill = ColorPicker.createSlider("S", 90, 100, colorFrame)
	local vLabel, vTextBox, vSlider, vSliderFill = ColorPicker.createSlider("V", 120, 100, colorFrame)

	local colorDisplay = UICreator.createFrame("ColorDisplay", UDim2.new(0.9, 0, 0, 40), UDim2.new(0.05, 0, 0, 155), colorFrame)
	colorDisplay.BorderSizePixel = 2

    -- extraFrame ----------------------------------------
    local extraFrame = UICreator.createFrame("extraFrame", UDim2.new(0.9, 0, 0, 70), UDim2.new(0.05, 0, 0, 325), frame)

    local ReflectanceLabel, ReflectanceTextBox, ReflectanceSlider, ReflectanceSliderFill = extra.createSlider("Reflectance", 10,100,extraFrame)
    local TranceparencyLabel, TranceparencyTextBox, TranceparencySlider, TranceparencySliderFill = extra.createSlider("Tranceparency", 40,100,extraFrame)

    local function updateReflectance(value)
        settings.reflectance = value
        -- ここで必要に応じて他の処理を追加
    end

    local function updateTransparency(value)
        settings.transparency = value
        -- ここで必要に応じて他の処理を追加
    end

    extra.setupSliderBehavior(ReflectanceSlider, ReflectanceSliderFill, ReflectanceTextBox, updateReflectance)
    extra.setupSliderBehavior(TranceparencySlider, TranceparencySliderFill, TranceparencyTextBox, updateTransparency)
    

    -- 初期値の設定
    ReflectanceTextBox.Text = string.format("%.2f", settings.reflectance or 0)
    ReflectanceSliderFill.Size = UDim2.new(settings.reflectance or 0, 0, 1, 0)
    TranceparencyTextBox.Text = string.format("%.2f", settings.transparency or 0)
    TranceparencySliderFill.Size = UDim2.new(settings.transparency or 0, 0, 1, 0)



    
    -- Buttons -----------------------------------------------
	local applyButton = UICreator.createButton("適用", UDim2.new(0, 100, 0, 30), UDim2.new(1, -110, 1, -40), frame)

	local eyedropperButton = Instance.new("ImageButton")
	eyedropperButton.Size = UDim2.new(0, 30, 0, 30)
	eyedropperButton.Position = UDim2.new(0, 10, 1, -40)
	eyedropperButton.Parent = frame
	eyedropperButton.Image = "rbxassetid://18271905411"
    eyedropperButton.BackgroundColor3 = BUTTON_BACKGROUND_COOLOR


    -- ------------------------------------------------------------------------------------------------------------------
	local function updateRadioSelection(selected)
		rgbRadio.Text = (selected == rgbRadio) and "●" or ""
		hsvRadio.Text = (selected == hsvRadio) and "●" or ""

		local isRGB = (selected == rgbRadio)

		rLabel.Visible = isRGB
		rTextBox.Visible = isRGB
		rSlider.Visible = isRGB
		gLabel.Visible = isRGB
		gTextBox.Visible = isRGB
		gSlider.Visible = isRGB
		bLabel.Visible = isRGB
		bTextBox.Visible = isRGB
		bSlider.Visible = isRGB

		hLabel.Visible = not isRGB
		hTextBox.Visible = not isRGB
		hSlider.Visible = not isRGB
		sLabel.Visible = not isRGB
		sTextBox.Visible = not isRGB
		sSlider.Visible = not isRGB
		vLabel.Visible = not isRGB
		vTextBox.Visible = not isRGB
		vSlider.Visible = not isRGB

		if isRGB then
			local h = tonumber(hTextBox.Text) or 0
			local s = tonumber(sTextBox.Text) or 0
			local v = tonumber(vTextBox.Text) or 0

			local color = Color3.fromHSV(h / 360, s / 100, v / 100)
			local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)

			rTextBox.Text = tostring(r)
			gTextBox.Text = tostring(g)
			bTextBox.Text = tostring(b)

			rSliderFill.Size = UDim2.new(r / 255, 0, 1, 0)
			gSliderFill.Size = UDim2.new(g / 255, 0, 1, 0)
			bSliderFill.Size = UDim2.new(b / 255, 0, 1, 0)
		else
			local r = tonumber(rTextBox.Text) or 0
			local g = tonumber(gTextBox.Text) or 0
			local b = tonumber(bTextBox.Text) or 0

			local color = Color3.fromRGB(r, g, b)
			local h, s, v = color:ToHSV()

			hTextBox.Text = tostring(math.floor(h * 360))
			sTextBox.Text = tostring(math.floor(s * 100))
			vTextBox.Text = tostring(math.floor(v * 100))

			hSliderFill.Size = UDim2.new(h, 0, 1, 0)
			sSliderFill.Size = UDim2.new(s, 0, 1, 0)
			vSliderFill.Size = UDim2.new(v, 0, 1, 0)
		end
	end

	updateRadioSelection(rgbRadio)

	rgbRadio.MouseButton1Click:Connect(function()
		updateRadioSelection(rgbRadio)
	end)

	hsvRadio.MouseButton1Click:Connect(function()
		updateRadioSelection(hsvRadio)
	end)

	MaterialSelector.updateRadioButtons(settings.useDefaultMaterial, defaultMaterialRadio, materialVariantRadio, dropdown)
	dropdown.Text = settings.useDefaultMaterial and (settings.selectedMaterial or "デフォルトマテリアルを選択") or (settings.selectedVariant or "マテリアルバリアントを選択")

	defaultMaterialRadio.MouseButton1Click:Connect(function()
		settings.useDefaultMaterial = true
		MaterialSelector.updateRadioButtons(true, defaultMaterialRadio, materialVariantRadio, dropdown)
		ColorPicker.updateColor(settings, colorDisplay, rgbRadio, rTextBox, gTextBox, bTextBox, hTextBox, sTextBox, vTextBox)
	end)

	materialVariantRadio.MouseButton1Click:Connect(function()
		settings.useDefaultMaterial = false
		MaterialSelector.updateRadioButtons(false, defaultMaterialRadio, materialVariantRadio, dropdown)
		ColorPicker.updateColor(settings, colorDisplay, rgbRadio, rTextBox, gTextBox, bTextBox, hTextBox, sTextBox, vTextBox)
	end)

	dropdown.MouseButton1Click:Connect(function()
		MaterialSelector.createDropdown(settings, widget, dropdown)
	end)




eyedropperButton.MouseButton1Click:Connect(function()
    Eyedropper.pickColor(
        settings,
        function(useDefaultMaterial) 
            MaterialSelector.updateRadioButtons(useDefaultMaterial, defaultMaterialRadio, materialVariantRadio, dropdown)
        end,
        dropdown,
        rTextBox, gTextBox, bTextBox,
        hTextBox, sTextBox, vTextBox,
        colorDisplay,
        rSliderFill, gSliderFill, bSliderFill,
        hSliderFill, sSliderFill, vSliderFill,
        ReflectanceTextBox, ReflectanceSliderFill,
        TranceparencyTextBox, TranceparencySliderFill
    )
end)




	applyButton.MouseButton1Click:Connect(function()
		MaterialAssigner.assignMaterial(settings)
		SettingsManager.saveSettings(plugin, settings)
	end)

	assignButton.Click:Connect(function()
		MaterialAssigner.assignMaterial(settings)
	end)

	widgetButton.Click:Connect(function()
		widget.Enabled = not widget.Enabled
	end)

	local function updateColorCallback()
		ColorPicker.updateColor(settings, colorDisplay, rgbRadio, rTextBox, gTextBox, bTextBox, hTextBox, sTextBox, vTextBox)
	end

	ColorPicker.setupSliderBehavior(rSlider, rSliderFill, rTextBox, "r", 255, updateColorCallback)
	ColorPicker.setupSliderBehavior(gSlider, gSliderFill, gTextBox, "g", 255, updateColorCallback)
	ColorPicker.setupSliderBehavior(bSlider, bSliderFill, bTextBox, "b", 255, updateColorCallback)
	ColorPicker.setupSliderBehavior(hSlider, hSliderFill, hTextBox, "h", 360, updateColorCallback)
	ColorPicker.setupSliderBehavior(sSlider, sSliderFill, sTextBox, "s", 100, updateColorCallback)
	ColorPicker.setupSliderBehavior(vSlider, vSliderFill, vTextBox, "v", 100, updateColorCallback)

    extra.setupSliderBehavior(ReflectanceSlider, ReflectanceSliderFill,ReflectanceTextBox,"Re")



	local function setInitialColor(color)
		if not color then
			warn("色情報がありません。")
			return
		end

		rTextBox.Text = tostring(math.floor(color.R * 255))
		gTextBox.Text = tostring(math.floor(color.G * 255))
		bTextBox.Text = tostring(math.floor(color.B * 255))

		rSliderFill.Size = UDim2.new(color.R, 0, 1, 0)
		gSliderFill.Size = UDim2.new(color.G, 0, 1, 0)
		bSliderFill.Size = UDim2.new(color.B, 0, 1, 0)

		ColorPicker.updateColor(settings, colorDisplay, rgbRadio, rTextBox, gTextBox, bTextBox, hTextBox, sTextBox, vTextBox)
	end

	setInitialColor(settings.useDefaultMaterial and settings.defaultColor or settings.variantColor)
end

-- プラグインの初期化
local plugin = script.Parent
initializePlugin(plugin)

plugin.Unloading:Connect(function()

end)
