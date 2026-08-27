local function CreateSectionHeader(SectionTitleString, YOffsetNumber)
	local HeaderFrame = Instance.new("Frame")
	HeaderFrame.Name = SectionTitleString .. "HeaderFrame"
	HeaderFrame.Size = UDim2.new(1, -20, 0, 20)
	HeaderFrame.Position = UDim2.new(0, 10, 0, YOffsetNumber)
	HeaderFrame.BackgroundTransparency = 1
	HeaderFrame.ZIndex = 101
	HeaderFrame.Parent = MenuFrame

	local HeaderLabel = Instance.new("TextLabel")
	HeaderLabel.Name = SectionTitleString .. "HeaderLabel"
	HeaderLabel.Size = UDim2.new(0, 120, 1, 0)
	HeaderLabel.BackgroundTransparency = 1
	HeaderLabel.Text = SectionTitleString
	HeaderLabel.Font = Enum.Font.SourceSansSemibold
	HeaderLabel.TextSize = 14
	HeaderLabel.TextColor3 = Color3.fromRGB(0, 200, 200)
	HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
	HeaderLabel.ZIndex = 102
	HeaderLabel.Parent = HeaderFrame

	local Divider = Instance.new("Frame")
	Divider.Name = SectionTitleString .. "Divider"
	Divider.Size = UDim2.new(1, -125, 0, 1)
	Divider.Position = UDim2.new(0, 125, 0.5, 0)
	Divider.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	Divider.BorderSizePixel = 0
	Divider.ZIndex = 101
	Divider.Parent = HeaderFrame
end

CreateSectionHeader("Aim Settings", 30)

local SmoothingValueLabel = Instance.new("TextLabel")
SmoothingValueLabel.Name = "SmoothingValueLabel"
SmoothingValueLabel.Size = UDim2.new(1, -10, 0, 20)
SmoothingValueLabel.Position = UDim2.new(0, 5, 0, 52)
SmoothingValueLabel.BackgroundTransparency = 1
SmoothingValueLabel.TextXAlignment = Enum.TextXAlignment.Left
SmoothingValueLabel.Font = Enum.Font.SourceSans
SmoothingValueLabel.TextSize = 16
SmoothingValueLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
SmoothingValueLabel.Text = "Smoothing: " .. string.format("%.2f", AimbotSmoothingNumber)
SmoothingValueLabel.ZIndex = 101
SmoothingValueLabel.Parent = MenuFrame

local SmoothSliderBackFrame = Instance.new("Frame")
SmoothSliderBackFrame.Name = "SmoothSliderBackFrame"
SmoothSliderBackFrame.Size = UDim2.new(1, -20, 0, 8)
SmoothSliderBackFrame.Position = UDim2.new(0, 10, 0, 76)
SmoothSliderBackFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SmoothSliderBackFrame.BorderSizePixel = 0
SmoothSliderBackFrame.ZIndex = 101
SmoothSliderBackFrame.Parent = MenuFrame

local SmoothSliderFillFrame = Instance.new("Frame")
SmoothSliderFillFrame.Name = "SmoothSliderFillFrame"
SmoothSliderFillFrame.Size = UDim2.new(0, 0, 1, 0)
SmoothSliderFillFrame.Position = UDim2.new(0, 0, 0, 0)
SmoothSliderFillFrame.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SmoothSliderFillFrame.BorderSizePixel = 0
SmoothSliderFillFrame.ZIndex = 102
SmoothSliderFillFrame.Parent = SmoothSliderBackFrame

local SmoothSliderKnobFrame = Instance.new("Frame")
SmoothSliderKnobFrame.Name = "SmoothSliderKnobFrame"
SmoothSliderKnobFrame.Size = UDim2.new(0, 10, 0, 14)
SmoothSliderKnobFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SmoothSliderKnobFrame.BorderSizePixel = 0
SmoothSliderKnobFrame.ZIndex = 103
SmoothSliderKnobFrame.Parent = SmoothSliderBackFrame

local FovValueLabel = Instance.new("TextLabel")
FovValueLabel.Name = "FovValueLabel"
FovValueLabel.Size = UDim2.new(1, -10, 0, 20)
FovValueLabel.Position = UDim2.new(0, 5, 0, 102)
FovValueLabel.BackgroundTransparency = 1
FovValueLabel.TextXAlignment = Enum.TextXAlignment.Left
FovValueLabel.Font = Enum.Font.SourceSans
FovValueLabel.TextSize = 16
FovValueLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
FovValueLabel.Text = "FOV Radius: " .. tostring(FovCircle.Radius)
FovValueLabel.ZIndex = 101
FovValueLabel.Parent = MenuFrame

local FovSliderBackFrame = Instance.new("Frame")
FovSliderBackFrame.Name = "FovSliderBackFrame"
FovSliderBackFrame.Size = UDim2.new(1, -20, 0, 8)
FovSliderBackFrame.Position = UDim2.new(0, 10, 0, 126)
FovSliderBackFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FovSliderBackFrame.BorderSizePixel = 0
FovSliderBackFrame.ZIndex = 101
FovSliderBackFrame.Parent = MenuFrame

local FovSliderFillFrame = Instance.new("Frame")
FovSliderFillFrame.Name = "FovSliderFillFrame"
FovSliderFillFrame.Size = UDim2.new(0, 0, 1, 0)
FovSliderFillFrame.Position = UDim2.new(0, 0, 0, 0)
FovSliderFillFrame.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
FovSliderFillFrame.BorderSizePixel = 0
FovSliderFillFrame.ZIndex = 102
FovSliderFillFrame.Parent = FovSliderBackFrame

local FovSliderKnobFrame = Instance.new("Frame")
FovSliderKnobFrame.Name = "FovSliderKnobFrame"
FovSliderKnobFrame.Size = UDim2.new(0, 10, 0, 14)
FovSliderKnobFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FovSliderKnobFrame.BorderSizePixel = 0
FovSliderKnobFrame.ZIndex = 103
FovSliderKnobFrame.Parent = FovSliderBackFrame

local HeadshotToggleButton = Instance.new("TextButton")
HeadshotToggleButton.Name = "HeadshotToggleButton"
HeadshotToggleButton.Size = UDim2.new(1, -20, 0, 20)
HeadshotToggleButton.Position = UDim2.new(0, 10, 0, 172)
HeadshotToggleButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
HeadshotToggleButton.BorderSizePixel = 0
HeadshotToggleButton.Text = "Headshot Priority: OFF"
HeadshotToggleButton.Font = Enum.Font.SourceSans
HeadshotToggleButton.TextSize = 16
HeadshotToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HeadshotToggleButton.ZIndex = 101
HeadshotToggleButton.Parent = MenuFrame

local AutoFireToggleButton = Instance.new("TextButton")
AutoFireToggleButton.Name = "AutoFireToggleButton"
AutoFireToggleButton.Size = UDim2.new(1, -20, 0, 20)
AutoFireToggleButton.Position = UDim2.new(0, 10, 0, 196)
AutoFireToggleButton.BackgroundColor3 = Color3.fromRGB(0, 60, 120)
AutoFireToggleButton.BorderSizePixel = 0
AutoFireToggleButton.Text = "Auto Fire: ON"
AutoFireToggleButton.Font = Enum.Font.SourceSans
AutoFireToggleButton.TextSize = 16
AutoFireToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoFireToggleButton.ZIndex = 101
AutoFireToggleButton.Parent = MenuFrame

local VisibleCheckToggleButton = Instance.new("TextButton")
VisibleCheckToggleButton.Name = "VisibleCheckToggleButton"
VisibleCheckToggleButton.Size = UDim2.new(1, -20, 0, 20)
VisibleCheckToggleButton.Position = UDim2.new(0, 10, 0, 220)
VisibleCheckToggleButton.BackgroundColor3 = Color3.fromRGB(0, 80, 80)
VisibleCheckToggleButton.BorderSizePixel = 0
VisibleCheckToggleButton.Text = "Visible Check: ON"
VisibleCheckToggleButton.Font = Enum.Font.SourceSans
VisibleCheckToggleButton.TextSize = 16
VisibleCheckToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
VisibleCheckToggleButton.ZIndex = 101
VisibleCheckToggleButton.Parent = MenuFrame

local TargetSegmentationToggleButton = Instance.new("TextButton")
TargetSegmentationToggleButton.Name = "TargetSegmentationToggleButton"
TargetSegmentationToggleButton.Size = UDim2.new(1, -20, 0, 20)
TargetSegmentationToggleButton.Position = UDim2.new(0, 10, 0, 244)
TargetSegmentationToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TargetSegmentationToggleButton.BorderSizePixel = 0
TargetSegmentationToggleButton.Text = "Sectioning: OFF"
TargetSegmentationToggleButton.Font = Enum.Font.SourceSans
TargetSegmentationToggleButton.TextSize = 16
TargetSegmentationToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetSegmentationToggleButton.ZIndex = 101
TargetSegmentationToggleButton.Parent = MenuFrame

local FovToggleButton = Instance.new("TextButton")
FovToggleButton.Name = "FovToggleButton"
FovToggleButton.Size = UDim2.new(1, -20, 0, 20)
FovToggleButton.Position = UDim2.new(0, 10, 0, 300)
FovToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
FovToggleButton.BorderSizePixel = 0
FovToggleButton.Text = "FOV Circle: ON"
FovToggleButton.Font = Enum.Font.SourceSans
FovToggleButton.TextSize = 16
FovToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FovToggleButton.ZIndex = 101
FovToggleButton.Parent = MenuFrame

local TargetLineToggleButton = Instance.new("TextButton")
TargetLineToggleButton.Name = "TargetLineToggleButton"
TargetLineToggleButton.Size = UDim2.new(1, -20, 0, 20)
TargetLineToggleButton.Position = UDim2.new(0, 10, 0, 324)
TargetLineToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
TargetLineToggleButton.BorderSizePixel = 0
TargetLineToggleButton.Text = "Target Line: ON"
TargetLineToggleButton.Font = Enum.Font.SourceSans
TargetLineToggleButton.TextSize = 16
TargetLineToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetLineToggleButton.ZIndex = 101
TargetLineToggleButton.Parent = MenuFrame

local LockKeyToggleButton = Instance.new("TextButton")
LockKeyToggleButton.Name = "LockKeyToggleButton"
LockKeyToggleButton.Size = UDim2.new(1, -20, 0, 20)
LockKeyToggleButton.Position = UDim2.new(0, 10, 0, 376)
LockKeyToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 0)
LockKeyToggleButton.BorderSizePixel = 0
LockKeyToggleButton.Text = "Lock Key: RMB"
LockKeyToggleButton.Font = Enum.Font.SourceSans
LockKeyToggleButton.TextSize = 16
LockKeyToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LockKeyToggleButton.ZIndex = 101
LockKeyToggleButton.Parent = MenuFrame

local HookMethodToggleButton = Instance.new("TextButton")
HookMethodToggleButton.Name = "HookMethodToggleButton"
HookMethodToggleButton.Size = UDim2.new(1, -20, 0, 20)
HookMethodToggleButton.Position = UDim2.new(0, 10, 0, 400)
HookMethodToggleButton.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
HookMethodToggleButton.BorderSizePixel = 0
HookMethodToggleButton.Text = "Method: Hook"
HookMethodToggleButton.Font = Enum.Font.SourceSans
HookMethodToggleButton.TextSize = 16
HookMethodToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HookMethodToggleButton.ZIndex = 101
HookMethodToggleButton.Parent = MenuFrame

local StickyAimToggleButton = Instance.new("TextButton")
StickyAimToggleButton.Name = "StickyAimToggleButton"
StickyAimToggleButton.Size = UDim2.new(1, -20, 0, 20)
StickyAimToggleButton.Position = UDim2.new(0, 10, 0, 424)
StickyAimToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
StickyAimToggleButton.BorderSizePixel = 0
StickyAimToggleButton.Text = "Sticky Aim: OFF"
StickyAimToggleButton.Font = Enum.Font.SourceSans
StickyAimToggleButton.TextSize = 16
StickyAimToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StickyAimToggleButton.ZIndex = 101
StickyAimToggleButton.Parent = MenuFrame

local HookHitChanceValueLabel = Instance.new("TextLabel")
HookHitChanceValueLabel.Name = "HookHitChanceValueLabel"
HookHitChanceValueLabel.Size = UDim2.new(1, -10, 0, 20)
HookHitChanceValueLabel.Position = UDim2.new(0, 5, 0, 448)
HookHitChanceValueLabel.BackgroundTransparency = 1
HookHitChanceValueLabel.TextXAlignment = Enum.TextXAlignment.Left
HookHitChanceValueLabel.Font = Enum.Font.SourceSans
HookHitChanceValueLabel.TextSize = 16
HookHitChanceValueLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
HookHitChanceValueLabel.Text = "Hook Hit Chance: " .. tostring(math.floor(NormalHookHitChanceNumber + 0.5)) .. "%"
HookHitChanceValueLabel.ZIndex = 101
HookHitChanceValueLabel.Parent = MenuFrame

local HookHitChanceSliderBackFrame = Instance.new("Frame")
HookHitChanceSliderBackFrame.Name = "HookHitChanceSliderBackFrame"
HookHitChanceSliderBackFrame.Size = UDim2.new(1, -20, 0, 8)
HookHitChanceSliderBackFrame.Position = UDim2.new(0, 10, 0, 472)
HookHitChanceSliderBackFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
HookHitChanceSliderBackFrame.BorderSizePixel = 0
HookHitChanceSliderBackFrame.ZIndex = 101
HookHitChanceSliderBackFrame.Parent = MenuFrame

local HookHitChanceSliderFillFrame = Instance.new("Frame")
HookHitChanceSliderFillFrame.Name = "HookHitChanceSliderFillFrame"
HookHitChanceSliderFillFrame.Size = UDim2.new(0, 0, 1, 0)
HookHitChanceSliderFillFrame.Position = UDim2.new(0, 0, 0, 0)
HookHitChanceSliderFillFrame.BackgroundColor3 = Color3.fromRGB(220, 165, 0)
HookHitChanceSliderFillFrame.BorderSizePixel = 0
HookHitChanceSliderFillFrame.ZIndex = 102
HookHitChanceSliderFillFrame.Parent = HookHitChanceSliderBackFrame

local HookHitChanceSliderKnobFrame = Instance.new("Frame")
HookHitChanceSliderKnobFrame.Name = "HookHitChanceSliderKnobFrame"
HookHitChanceSliderKnobFrame.Size = UDim2.new(0, 10, 0, 14)
HookHitChanceSliderKnobFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HookHitChanceSliderKnobFrame.BorderSizePixel = 0
HookHitChanceSliderKnobFrame.ZIndex = 103
HookHitChanceSliderKnobFrame.Parent = HookHitChanceSliderBackFrame

local SillyModeToggleButton = nil
local ShieldModeToggleButton = nil
local SillySkyVisibilityToggleButton = nil
if IsBloodZonePlaceBoolean then
	SillyModeToggleButton = Instance.new("TextButton")
	SillyModeToggleButton.Name = "SillyModeToggleButton"
	SillyModeToggleButton.Size = UDim2.new(1, -20, 0, 20)
	SillyModeToggleButton.Position = UDim2.new(0, 10, 0, 500)
	SillyModeToggleButton.BackgroundColor3 = Color3.fromRGB(80, 30, 80)
	SillyModeToggleButton.BorderSizePixel = 0
	SillyModeToggleButton.Text = "Silly Mode: OFF"
	SillyModeToggleButton.Font = Enum.Font.SourceSans
	SillyModeToggleButton.TextSize = 16
	SillyModeToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	SillyModeToggleButton.ZIndex = 101
	SillyModeToggleButton.Parent = MenuFrame

	ShieldModeToggleButton = Instance.new("TextButton")
	ShieldModeToggleButton.Name = "ShieldModeToggleButton"
	ShieldModeToggleButton.Size = UDim2.new(1, -20, 0, 20)
	ShieldModeToggleButton.Position = UDim2.new(0, 10, 0, 524)
	ShieldModeToggleButton.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
	ShieldModeToggleButton.BorderSizePixel = 0
	ShieldModeToggleButton.Text = "Shield Mode: LOCKED"
	ShieldModeToggleButton.Font = Enum.Font.SourceSans
	ShieldModeToggleButton.TextSize = 16
	ShieldModeToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	ShieldModeToggleButton.ZIndex = 101
	ShieldModeToggleButton.Parent = MenuFrame

	SillySkyVisibilityToggleButton = Instance.new("TextButton")
	SillySkyVisibilityToggleButton.Name = "SillySkyVisibilityToggleButton"
	SillySkyVisibilityToggleButton.Size = UDim2.new(1, -20, 0, 20)
	SillySkyVisibilityToggleButton.Position = UDim2.new(0, 10, 0, 548)
	SillySkyVisibilityToggleButton.BackgroundColor3 = Color3.fromRGB(45, 65, 90)
	SillySkyVisibilityToggleButton.BorderSizePixel = 0
	SillySkyVisibilityToggleButton.Text = "Sky Vis Check: LOCKED"
	SillySkyVisibilityToggleButton.Font = Enum.Font.SourceSans
	SillySkyVisibilityToggleButton.TextSize = 16
	SillySkyVisibilityToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	SillySkyVisibilityToggleButton.ZIndex = 101
	SillySkyVisibilityToggleButton.Parent = MenuFrame
end

CreateSectionHeader("Targeting", 150)
CreateSectionHeader("Visibility", 274)
CreateSectionHeader("Behavior", 354)

local function UpdateHeadshotButtonAppearance()
	if IsSillyModeBehaviorActive() then
		HeadshotToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
		HeadshotToggleButton.Text = "Headshot Priority: ON (Silly)"
	elseif HeadshotPriorityBoolean then
		HeadshotToggleButton.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
		HeadshotToggleButton.Text = "Headshot Priority: ON"
	else
		HeadshotToggleButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
		HeadshotToggleButton.Text = "Headshot Priority: OFF"
	end
end

local function UpdateAutoFireButtonAppearance()
	if IsSillyModeBehaviorActive() then
		AutoFireToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
		AutoFireToggleButton.Text = "Auto Fire: ON (Silly)"
	elseif AutoFireEnabledBoolean then
		AutoFireToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
		AutoFireToggleButton.Text = "Auto Fire: ON"
	else
		AutoFireToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		AutoFireToggleButton.Text = "Auto Fire: OFF"
	end
end

local function UpdateVisibleCheckButtonAppearance()
	if IsSillyModeBehaviorActive() then
		VisibleCheckToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
		VisibleCheckToggleButton.Text = "Visible Check: ON (Silly)"
	elseif VisibleCheckEnabledBoolean then
		VisibleCheckToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 120)
		VisibleCheckToggleButton.Text = "Visible Check: ON"
	else
		VisibleCheckToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		VisibleCheckToggleButton.Text = "Visible Check: OFF"
	end
end

local function UpdateTargetSegmentationButtonAppearance()
	if IsSillyModeBehaviorActive() then
		TargetSegmentationToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		TargetSegmentationToggleButton.Text = "Sectioning: OFF (Silly)"
	elseif TargetSegmentationEnabledBoolean then
		TargetSegmentationToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 120)
		TargetSegmentationToggleButton.Text = "Sectioning: ON"
	else
		TargetSegmentationToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		TargetSegmentationToggleButton.Text = "Sectioning: OFF"
	end
end

local function UpdateFovToggleButtonAppearance()
	if IsSillyModeBehaviorActive() then
		FovToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		FovToggleButton.Text = "FOV Circle: OFF (Silly)"
	elseif ShowFovCircleBoolean then
		FovToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 120)
		FovToggleButton.Text = "FOV Circle: ON"
	else
		FovToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		FovToggleButton.Text = "FOV Circle: OFF"
	end
end

local function UpdateTargetLineToggleButtonAppearance()
	if ShowTargetLineBoolean then
		TargetLineToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 120)
		TargetLineToggleButton.Text = "Target Line: ON"
	else
		TargetLineToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		TargetLineToggleButton.Text = "Target Line: OFF"
	end
end

local function UpdateHookMethodButtonAppearance()
	if IsSillyModeBehaviorActive() then
		HookMethodToggleButton.BackgroundColor3 = Color3.fromRGB(180, 70, 220)
		HookMethodToggleButton.Text = "Method: Hook (Silly)"
	elseif UseHookMethodBoolean and UseCameraMethodBoolean then
		HookMethodToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
		HookMethodToggleButton.Text = "Method: Both"
	elseif UseHookMethodBoolean then
		HookMethodToggleButton.BackgroundColor3 = Color3.fromRGB(150, 70, 200)
		HookMethodToggleButton.Text = "Method: Hook"
	else
		HookMethodToggleButton.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
		HookMethodToggleButton.Text = "Method: Camera"
	end
end

local function UpdateStickyAimButtonAppearance()
	if IsSillyModeBehaviorActive() then
		StickyAimToggleButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
		StickyAimToggleButton.Text = "Sticky Aim: LOCKED (Silly)"
	elseif StickyAimEnabledBoolean then
		StickyAimToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 90)
		StickyAimToggleButton.Text = "Sticky Aim: ON"
	else
		StickyAimToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		StickyAimToggleButton.Text = "Sticky Aim: OFF"
	end
end

local function UpdateHookHitChanceSliderAppearance()
	local HitChanceNumber = math.clamp(tonumber(NormalHookHitChanceNumber) or 100, 0, 100)
	local RatioNumber = (HitChanceNumber - MinNormalHookHitChanceNumber) / (MaxNormalHookHitChanceNumber - MinNormalHookHitChanceNumber)
	RatioNumber = math.clamp(RatioNumber, 0, 1)

	if IsSillyModeBehaviorActive() then
		HookHitChanceValueLabel.TextColor3 = Color3.fromRGB(145, 145, 145)
		HookHitChanceValueLabel.Text = "Hook Hit Chance: " .. tostring(math.floor(HitChanceNumber + 0.5)) .. "% (Locked in Silly)"
		HookHitChanceSliderBackFrame.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
		HookHitChanceSliderFillFrame.BackgroundColor3 = Color3.fromRGB(110, 110, 110)
	else
		HookHitChanceValueLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
		HookHitChanceValueLabel.Text = "Hook Hit Chance: " .. tostring(math.floor(HitChanceNumber + 0.5)) .. "%"
		HookHitChanceSliderBackFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		HookHitChanceSliderFillFrame.BackgroundColor3 = Color3.fromRGB(220, 165, 0)
	end

	local KnobWidthNumber = HookHitChanceSliderKnobFrame.AbsoluteSize.X
	HookHitChanceSliderFillFrame.Size = UDim2.new(RatioNumber, 0, 1, 0)
	HookHitChanceSliderKnobFrame.Position = UDim2.new(RatioNumber, -KnobWidthNumber / 2, 0.5, -HookHitChanceSliderKnobFrame.AbsoluteSize.Y / 2)
end

local function GetCurrentLockKeyMode()
	return LockKeyModesTable[LockKeyModeIndexNumber] or "RMB"
end

local function AdvanceLockKeyMode()
	LockKeyModeIndexNumber = LockKeyModeIndexNumber + 1
	if LockKeyModeIndexNumber > #LockKeyModesTable then
		LockKeyModeIndexNumber = 1
	end
	return GetCurrentLockKeyMode()
end

local function UpdateLockKeyButtonAppearance()
	if IsSillyModeBehaviorActive() then
		LockKeyToggleButton.BackgroundColor3 = Color3.fromRGB(180, 80, 0)
		LockKeyToggleButton.Text = "Lock Key: Always (Silly)"
		return
	end

	local LockKeyModeString = GetCurrentLockKeyMode()
	if LockKeyModeString == "Always" then
		LockKeyToggleButton.BackgroundColor3 = Color3.fromRGB(180, 80, 0)
		LockKeyToggleButton.Text = "Lock Key: Always"
	elseif LockKeyModeString == "E" then
		LockKeyToggleButton.BackgroundColor3 = Color3.fromRGB(0, 130, 130)
		LockKeyToggleButton.Text = "Lock Key: E"
	else
		LockKeyToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 0)
		LockKeyToggleButton.Text = "Lock Key: RMB"
	end
end

local function UpdateSillyModeButtonAppearance()
	if not SillyModeToggleButton then
		return
	end

	if IsSillyModeBehaviorActive() then
		SillyModeToggleButton.BackgroundColor3 = Color3.fromRGB(190, 60, 190)
		SillyModeToggleButton.Text = "Silly Mode: ON"
	elseif IsSillyModeEnabled() then
		SillyModeToggleButton.BackgroundColor3 = Color3.fromRGB(130, 45, 130)
		SillyModeToggleButton.Text = "Silly Mode: ARMED (Need Tool)"
	else
		SillyModeToggleButton.BackgroundColor3 = Color3.fromRGB(80, 30, 80)
		SillyModeToggleButton.Text = "Silly Mode: OFF"
	end
end

local function UpdateShieldModeButtonAppearance()
	if not ShieldModeToggleButton then
		return
	end

	if IsEffectiveShieldModeEnabled() then
		ShieldModeToggleButton.BackgroundColor3 = Color3.fromRGB(90, 120, 220)
		ShieldModeToggleButton.Text = "Shield Mode: ON"
	elseif ShieldModeEnabledBoolean and IsSillyModeEnabled() then
		ShieldModeToggleButton.BackgroundColor3 = Color3.fromRGB(70, 90, 170)
		ShieldModeToggleButton.Text = "Shield Mode: ARMED (Need Tool)"
	elseif IsSillyModeEnabled() then
		ShieldModeToggleButton.BackgroundColor3 = Color3.fromRGB(55, 85, 170)
		ShieldModeToggleButton.Text = "Shield Mode: OFF"
	else
		ShieldModeToggleButton.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
		ShieldModeToggleButton.Text = "Shield Mode: LOCKED (Need Silly)"
	end
end

local function UpdateSillySkyVisibilityButtonAppearance()
	if not SillySkyVisibilityToggleButton then
		return
	end

	if IsSillyModeBehaviorActive() and SillySkyAimEnabledBoolean and not ShieldModeEnabledBoolean and SillySkyVisibilityCheckEnabledBoolean then
		SillySkyVisibilityToggleButton.BackgroundColor3 = Color3.fromRGB(70, 130, 185)
		SillySkyVisibilityToggleButton.Text = "Sky Vis Check: ON"
	elseif not IsSillyModeEnabled() then
		SillySkyVisibilityToggleButton.BackgroundColor3 = Color3.fromRGB(45, 65, 90)
		SillySkyVisibilityToggleButton.Text = "Sky Vis Check: LOCKED (Need Silly)"
	elseif not SillySkyVisibilityCheckEnabledBoolean then
		SillySkyVisibilityToggleButton.BackgroundColor3 = Color3.fromRGB(45, 75, 105)
		SillySkyVisibilityToggleButton.Text = "Sky Vis Check: OFF"
	elseif ShieldModeEnabledBoolean then
		SillySkyVisibilityToggleButton.BackgroundColor3 = Color3.fromRGB(55, 70, 95)
		SillySkyVisibilityToggleButton.Text = "Sky Vis Check: LOCKED (Shield ON)"
	elseif not SillySkyAimEnabledBoolean then
		SillySkyVisibilityToggleButton.BackgroundColor3 = Color3.fromRGB(55, 70, 95)
		SillySkyVisibilityToggleButton.Text = "Sky Vis Check: LOCKED (Sky Aim OFF)"
	else
		SillySkyVisibilityToggleButton.BackgroundColor3 = Color3.fromRGB(60, 100, 145)
		SillySkyVisibilityToggleButton.Text = "Sky Vis Check: ARMED (Need Tool)"
	end
end

local function RefreshBloodZoneBehaviorButtons()
	UpdateHeadshotButtonAppearance()
	UpdateAutoFireButtonAppearance()
	UpdateVisibleCheckButtonAppearance()
	UpdateTargetSegmentationButtonAppearance()
	UpdateFovToggleButtonAppearance()
	UpdateLockKeyButtonAppearance()
	UpdateHookMethodButtonAppearance()
	UpdateStickyAimButtonAppearance()
	UpdateHookHitChanceSliderAppearance()
	UpdateSillyModeButtonAppearance()
	UpdateShieldModeButtonAppearance()
	UpdateSillySkyVisibilityButtonAppearance()
end

local function ToggleSillyMode()
	if not IsBloodZonePlaceBoolean then
		return
	end

	SillyModeEnabledBoolean = not SillyModeEnabledBoolean
	if not SillyModeEnabledBoolean then
		SillySkyAimEnabledBoolean = true
	end

	RefreshBloodZoneBehaviorButtons()
	UpdateDebugStatus("silly mode=" .. tostring(SillyModeEnabledBoolean) .. " sky aim=" .. tostring(SillySkyAimEnabledBoolean))
	DebugLog("toggle-silly", "Silly Mode set to " .. tostring(SillyModeEnabledBoolean) .. " | sky aim=" .. tostring(SillySkyAimEnabledBoolean), true)
end

local SetTargetCubeVisible

HeadshotToggleButton.MouseButton1Click.Connect(HeadshotToggleButton.MouseButton1Click, function()
	if IsAimbotUiInputSuppressed() then
		return
	end
	HeadshotPriorityBoolean = not HeadshotPriorityBoolean
	UpdateHeadshotButtonAppearance()
end)

AutoFireToggleButton.MouseButton1Click.Connect(AutoFireToggleButton.MouseButton1Click, function()
	if IsAimbotUiInputSuppressed() then
		return
	end
	AutoFireEnabledBoolean = not AutoFireEnabledBoolean
	UpdateAutoFireButtonAppearance()
end)

VisibleCheckToggleButton.MouseButton1Click.Connect(VisibleCheckToggleButton.MouseButton1Click, function()
	if IsAimbotUiInputSuppressed() then
		return
	end
	VisibleCheckEnabledBoolean = not VisibleCheckEnabledBoolean
	UpdateVisibleCheckButtonAppearance()
	UpdateDebugStatus("visible check=" .. tostring(VisibleCheckEnabledBoolean))
	DebugLog("toggle-visible", "Visible check set to " .. tostring(VisibleCheckEnabledBoolean), true)
end)

TargetSegmentationToggleButton.MouseButton1Click.Connect(TargetSegmentationToggleButton.MouseButton1Click, function()
	if IsAimbotUiInputSuppressed() then
		return
	end
	TargetSegmentationEnabledBoolean = not TargetSegmentationEnabledBoolean
	UpdateTargetSegmentationButtonAppearance()
	CurrentTargetPointVector3 = nil
	CurrentTargetAimPointVector3 = nil
	CurrentTargetLocalPointVector3 = nil
	CurrentTargetCubeCFrame = nil
	CurrentTargetCubeSize = nil
	TargetLine.Visible = false
	if SetTargetCubeVisible then
		SetTargetCubeVisible(false)
	end
	UpdateDebugStatus("sectioning=" .. tostring(TargetSegmentationEnabledBoolean))
	DebugLog("toggle-segmentation", "Sectioning set to " .. tostring(TargetSegmentationEnabledBoolean), true)
end)

FovToggleButton.MouseButton1Click.Connect(FovToggleButton.MouseButton1Click, function()
	if IsAimbotUiInputSuppressed() then
		return
	end
	ShowFovCircleBoolean = not ShowFovCircleBoolean
	UpdateFovToggleButtonAppearance()
end)

TargetLineToggleButton.MouseButton1Click.Connect(TargetLineToggleButton.MouseButton1Click, function()
	if IsAimbotUiInputSuppressed() then
		return
	end
	ShowTargetLineBoolean = not ShowTargetLineBoolean
	UpdateTargetLineToggleButtonAppearance()
	TargetLine.Visible = false
	SetTargetCubeVisible(false)
	UpdateDebugStatus("target line=" .. tostring(ShowTargetLineBoolean))
	DebugLog("toggle-line", "Target line set to " .. tostring(ShowTargetLineBoolean), true)
end)

LockKeyToggleButton.MouseButton1Click.Connect(LockKeyToggleButton.MouseButton1Click, function()
	if IsAimbotUiInputSuppressed() then
		return
	end
	AdvanceLockKeyMode()
	UpdateLockKeyButtonAppearance()
end)

HookMethodToggleButton.MouseButton1Click.Connect(HookMethodToggleButton.MouseButton1Click, function()
	if IsAimbotUiInputSuppressed() then
		return
	end
	if UseHookMethodBoolean and not UseCameraMethodBoolean then
		UseHookMethodBoolean = true
		UseCameraMethodBoolean = true
	elseif UseHookMethodBoolean and UseCameraMethodBoolean then
		UseHookMethodBoolean = false
		UseCameraMethodBoolean = true
	else
		UseHookMethodBoolean = true
		UseCameraMethodBoolean = false
	end
	ResetNormalHookHitChanceDecision()
	UpdateHookMethodButtonAppearance()
end)

StickyAimToggleButton.MouseButton1Click.Connect(StickyAimToggleButton.MouseButton1Click, function()
	if IsAimbotUiInputSuppressed() then
		return
	end
	if IsSillyModeBehaviorActive() then
		UpdateDebugStatus("sticky aim locked while silly mode active")
		DebugLog("toggle-sticky-locked", "Sticky Aim toggle ignored because Silly Mode is active", true)
		UpdateStickyAimButtonAppearance()
		return
	end

	StickyAimEnabledBoolean = not StickyAimEnabledBoolean
	UpdateStickyAimButtonAppearance()
	UpdateDebugStatus("sticky aim=" .. tostring(StickyAimEnabledBoolean))
	DebugLog("toggle-sticky", "Sticky Aim set to " .. tostring(StickyAimEnabledBoolean), true)
end)

if SillyModeToggleButton then
	SillyModeToggleButton.MouseButton1Click.Connect(SillyModeToggleButton.MouseButton1Click, function()
		if IsAimbotUiInputSuppressed() then
			return
		end
		ToggleSillyMode()
	end)
end

if ShieldModeToggleButton then
	ShieldModeToggleButton.MouseButton1Click.Connect(ShieldModeToggleButton.MouseButton1Click, function()
		if IsAimbotUiInputSuppressed() then
			return
		end
		if not IsSillyModeEnabled() then
			UpdateDebugStatus("shield mode requires silly mode enabled")
			DebugLog("toggle-shield-locked", "Shield Mode toggle ignored because Silly Mode is disabled", true)
			UpdateShieldModeButtonAppearance()
			UpdateSillySkyVisibilityButtonAppearance()
			return
		end

		ShieldModeEnabledBoolean = not ShieldModeEnabledBoolean
		UpdateShieldModeButtonAppearance()
		UpdateSillySkyVisibilityButtonAppearance()
		UpdateDebugStatus("shield mode=" .. tostring(ShieldModeEnabledBoolean))
		DebugLog("toggle-shield", "Shield Mode set to " .. tostring(ShieldModeEnabledBoolean), true)
	end)
end

if SillySkyVisibilityToggleButton then
	SillySkyVisibilityToggleButton.MouseButton1Click.Connect(SillySkyVisibilityToggleButton.MouseButton1Click, function()
		if IsAimbotUiInputSuppressed() then
			return
		end
		SillySkyVisibilityCheckEnabledBoolean = not SillySkyVisibilityCheckEnabledBoolean
		UpdateSillySkyVisibilityButtonAppearance()
		UpdateDebugStatus("sky vis check=" .. tostring(SillySkyVisibilityCheckEnabledBoolean))
		DebugLog("toggle-sky-vis", "Silly sky visibility check set to " .. tostring(SillySkyVisibilityCheckEnabledBoolean), true)
	end)
end

UpdateHeadshotButtonAppearance()
UpdateAutoFireButtonAppearance()
UpdateVisibleCheckButtonAppearance()
UpdateTargetSegmentationButtonAppearance()
UpdateFovToggleButtonAppearance()
UpdateTargetLineToggleButtonAppearance()
UpdateLockKeyButtonAppearance()
UpdateHookMethodButtonAppearance()
UpdateStickyAimButtonAppearance()
UpdateHookHitChanceSliderAppearance()
UpdateSillyModeButtonAppearance()
UpdateShieldModeButtonAppearance()
UpdateSillySkyVisibilityButtonAppearance()
PlayerListRuntimeTable.RefreshUi(true)

local function MakeFrameDraggable(FrameInstance, DragHandleInstance)
	DragHandleInstance.Active = true
	DragHandleInstance.InputBegan.Connect(DragHandleInstance.InputBegan, function(InputObject)
		if IsAimbotUiInputSuppressed() then
			return
		end
		if not UiInteractionRuntimeTable.dragEnabled then
			return
		end
		if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			UiInteractionRuntimeTable.draggingFrame = FrameInstance
			UiInteractionRuntimeTable.dragStartInputPosition = InputObject.Position
			UiInteractionRuntimeTable.startFramePosition = FrameInstance.Position
		end
	end)
end

UserInputService.InputChanged.Connect(UserInputService.InputChanged, function(InputObject)
	if UiInteractionRuntimeTable.draggingFrame and UiInteractionRuntimeTable.dragEnabled and InputObject.UserInputType == Enum.UserInputType.MouseMovement then
		local DeltaVector2 = InputObject.Position - UiInteractionRuntimeTable.dragStartInputPosition
		UiInteractionRuntimeTable.draggingFrame.Position = UDim2.new(
			UiInteractionRuntimeTable.startFramePosition.X.Scale,
			UiInteractionRuntimeTable.startFramePosition.X.Offset + DeltaVector2.X,
			UiInteractionRuntimeTable.startFramePosition.Y.Scale,
			UiInteractionRuntimeTable.startFramePosition.Y.Offset + DeltaVector2.Y
		)
	end
end)

UserInputService.InputEnded.Connect(UserInputService.InputEnded, function(InputObject)
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		UiInteractionRuntimeTable.draggingFrame = nil
	end
end)

MakeFrameDraggable(MenuFrame, TitleLabel)
MakeFrameDraggable(PlayerListRuntimeTable.frame, PlayerListRuntimeTable.titleLabel)

local function SetSmoothingFromRatio(RatioNumber)
	RatioNumber = math.clamp(RatioNumber, 0, 1)
	AimbotSmoothingNumber = MinSmoothingNumber + (MaxSmoothingNumber - MinSmoothingNumber) * RatioNumber
	SmoothingValueLabel.Text = "Smoothing: " .. string.format("%.2f", AimbotSmoothingNumber)
	local BackWidthNumber = SmoothSliderBackFrame.AbsoluteSize.X
	local KnobWidthNumber = SmoothSliderKnobFrame.AbsoluteSize.X
	SmoothSliderFillFrame.Size = UDim2.new(RatioNumber, 0, 1, 0)
	SmoothSliderKnobFrame.Position = UDim2.new(RatioNumber, -KnobWidthNumber / 2, 0.5, -SmoothSliderKnobFrame.AbsoluteSize.Y / 2)
end

local function SetFovFromRatio(RatioNumber)
	RatioNumber = math.clamp(RatioNumber, 0, 1)
	local NewRadiusNumber = MinFovRadiusNumber + (MaxFovRadiusNumber - MinFovRadiusNumber) * RatioNumber
	FovCircle.Radius = NewRadiusNumber
	FovValueLabel.Text = "FOV Radius: " .. tostring(math.floor(NewRadiusNumber))
	local BackWidthNumber = FovSliderBackFrame.AbsoluteSize.X
	local KnobWidthNumber = FovSliderKnobFrame.AbsoluteSize.X
	FovSliderFillFrame.Size = UDim2.new(RatioNumber, 0, 1, 0)
	FovSliderKnobFrame.Position = UDim2.new(RatioNumber, -KnobWidthNumber / 2, 0.5, -FovSliderKnobFrame.AbsoluteSize.Y / 2)
end

local function SetNormalHookHitChanceFromRatio(RatioNumber)
	RatioNumber = math.clamp(RatioNumber, 0, 1)
	NormalHookHitChanceNumber = MinNormalHookHitChanceNumber
		+ (MaxNormalHookHitChanceNumber - MinNormalHookHitChanceNumber) * RatioNumber
	ResetNormalHookHitChanceDecision()
	UpdateHookHitChanceSliderAppearance()
end

local function UpdateSmoothSliderFromMouse()
	local MouseLocationVector2 = UserInputService.GetMouseLocation(UserInputService)
	local BackPositionVector2 = SmoothSliderBackFrame.AbsolutePosition
	local BackSizeVector2 = SmoothSliderBackFrame.AbsoluteSize
	local RelativeXNumber = math.clamp(MouseLocationVector2.X - BackPositionVector2.X, 0, BackSizeVector2.X)
	local RatioNumber = 0
	if BackSizeVector2.X > 0 then
		RatioNumber = RelativeXNumber / BackSizeVector2.X
	end
	SetSmoothingFromRatio(RatioNumber)
end

local function UpdateFovSliderFromMouse()
	local MouseLocationVector2 = UserInputService.GetMouseLocation(UserInputService)
	local BackPositionVector2 = FovSliderBackFrame.AbsolutePosition
	local BackSizeVector2 = FovSliderBackFrame.AbsoluteSize
	local RelativeXNumber = math.clamp(MouseLocationVector2.X - BackPositionVector2.X, 0, BackSizeVector2.X)
	local RatioNumber = 0
	if BackSizeVector2.X > 0 then
		RatioNumber = RelativeXNumber / BackSizeVector2.X
	end
	SetFovFromRatio(RatioNumber)
end

local function UpdateNormalHookHitChanceSliderFromMouse()
	if IsSillyModeBehaviorActive() then
		UpdateHookHitChanceSliderAppearance()
		return
	end

	local MouseLocationVector2 = UserInputService.GetMouseLocation(UserInputService)
	local BackPositionVector2 = HookHitChanceSliderBackFrame.AbsolutePosition
	local BackSizeVector2 = HookHitChanceSliderBackFrame.AbsoluteSize
	local RelativeXNumber = math.clamp(MouseLocationVector2.X - BackPositionVector2.X, 0, BackSizeVector2.X)
	local RatioNumber = 0
	if BackSizeVector2.X > 0 then
		RatioNumber = RelativeXNumber / BackSizeVector2.X
	end
	SetNormalHookHitChanceFromRatio(RatioNumber)
end

SmoothSliderBackFrame.InputBegan.Connect(SmoothSliderBackFrame.InputBegan, function(InputObject)
	if IsAimbotUiInputSuppressed() then
		return
	end
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		UiInteractionRuntimeTable.dragEnabled = false
		UiInteractionRuntimeTable.smoothSliderDragging = true
		UpdateSmoothSliderFromMouse()
	end
end)

SmoothSliderKnobFrame.InputBegan.Connect(SmoothSliderKnobFrame.InputBegan, function(InputObject)
	if IsAimbotUiInputSuppressed() then
		return
	end
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		UiInteractionRuntimeTable.dragEnabled = false
		UiInteractionRuntimeTable.smoothSliderDragging = true
		UpdateSmoothSliderFromMouse()
	end
end)

FovSliderBackFrame.InputBegan.Connect(FovSliderBackFrame.InputBegan, function(InputObject)
	if IsAimbotUiInputSuppressed() then
		return
	end
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		UiInteractionRuntimeTable.dragEnabled = false
		UiInteractionRuntimeTable.fovSliderDragging = true
		UpdateFovSliderFromMouse()
	end
end)

FovSliderKnobFrame.InputBegan.Connect(FovSliderKnobFrame.InputBegan, function(InputObject)
	if IsAimbotUiInputSuppressed() then
		return
	end
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		UiInteractionRuntimeTable.dragEnabled = false
		UiInteractionRuntimeTable.fovSliderDragging = true
		UpdateFovSliderFromMouse()
	end
end)

HookHitChanceSliderBackFrame.InputBegan.Connect(HookHitChanceSliderBackFrame.InputBegan, function(InputObject)
	if IsAimbotUiInputSuppressed() then
		return
	end
	if IsSillyModeBehaviorActive() then
		UpdateDebugStatus("hook hit chance locked while silly mode active")
		DebugLog("slider-hit-chance-locked", "Hook Hit Chance slider ignored because Silly Mode is active", true)
		UpdateHookHitChanceSliderAppearance()
		return
	end
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		UiInteractionRuntimeTable.dragEnabled = false
		UiInteractionRuntimeTable.hitChanceSliderDragging = true
		UpdateNormalHookHitChanceSliderFromMouse()
	end
end)

HookHitChanceSliderKnobFrame.InputBegan.Connect(HookHitChanceSliderKnobFrame.InputBegan, function(InputObject)
	if IsAimbotUiInputSuppressed() then
		return
	end
	if IsSillyModeBehaviorActive() then
		UpdateDebugStatus("hook hit chance locked while silly mode active")
		DebugLog("slider-hit-chance-locked", "Hook Hit Chance knob ignored because Silly Mode is active", true)
		UpdateHookHitChanceSliderAppearance()
		return
	end
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		UiInteractionRuntimeTable.dragEnabled = false
		UiInteractionRuntimeTable.hitChanceSliderDragging = true
		UpdateNormalHookHitChanceSliderFromMouse()
	end
end)

UserInputService.InputChanged.Connect(UserInputService.InputChanged, function(InputObject)
	if InputObject.UserInputType == Enum.UserInputType.MouseMovement then
		if UiInteractionRuntimeTable.smoothSliderDragging then
			UpdateSmoothSliderFromMouse()
		end
		if UiInteractionRuntimeTable.fovSliderDragging then
			UpdateFovSliderFromMouse()
		end
		if UiInteractionRuntimeTable.hitChanceSliderDragging then
			UpdateNormalHookHitChanceSliderFromMouse()
		end
	end
end)

UserInputService.InputEnded.Connect(UserInputService.InputEnded, function(InputObject)
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		if UiInteractionRuntimeTable.smoothSliderDragging
			or UiInteractionRuntimeTable.fovSliderDragging
			or UiInteractionRuntimeTable.hitChanceSliderDragging then
			UiInteractionRuntimeTable.smoothSliderDragging = false
			UiInteractionRuntimeTable.fovSliderDragging = false
			UiInteractionRuntimeTable.hitChanceSliderDragging = false
			UiInteractionRuntimeTable.dragEnabled = true
		end
	end
end)

task.defer(function()
	local DefaultSmoothRatioNumber = (AimbotSmoothingNumber - MinSmoothingNumber) / (MaxSmoothingNumber - MinSmoothingNumber)
	DefaultSmoothRatioNumber = math.clamp(DefaultSmoothRatioNumber, 0, 1)
	SetSmoothingFromRatio(DefaultSmoothRatioNumber)
	local DefaultFovRatioNumber = (FovCircle.Radius - MinFovRadiusNumber) / (MaxFovRadiusNumber - MinFovRadiusNumber)
	DefaultFovRatioNumber = math.clamp(DefaultFovRatioNumber, 0, 1)
	SetFovFromRatio(DefaultFovRatioNumber)
	local DefaultNormalHookHitChanceRatioNumber = (NormalHookHitChanceNumber - MinNormalHookHitChanceNumber)
		/ (MaxNormalHookHitChanceNumber - MinNormalHookHitChanceNumber)
	DefaultNormalHookHitChanceRatioNumber = math.clamp(DefaultNormalHookHitChanceRatioNumber, 0, 1)
	SetNormalHookHitChanceFromRatio(DefaultNormalHookHitChanceRatioNumber)
end)

local MenuIsOpenBoolean = true
local MenuOpenPosition = MenuFrame.Position
local MenuClosedPosition = UDim2.new(MenuOpenPosition.X.Scale, MenuOpenPosition.X.Offset, MenuOpenPosition.Y.Scale, MenuOpenPosition.Y.Offset - 150)
local MenuTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

MenuFrame.Position = MenuOpenPosition
MenuFrame.Visible = true

local function SetMenuOpen(OpenBoolean)
	if MenuIsOpenBoolean == OpenBoolean then
		return
	end
	MenuIsOpenBoolean = OpenBoolean
	if OpenBoolean then
		MenuFrame.Visible = true
		MenuFrame.Position = MenuClosedPosition
		local OpenTweenObject = TweenService.Create(TweenService, MenuFrame, MenuTweenInfo, { Position = MenuOpenPosition })
		OpenTweenObject:Play()
	else
		local CloseTweenObject = TweenService.Create(TweenService, MenuFrame, MenuTweenInfo, { Position = MenuClosedPosition })
		CloseTweenObject.Completed.Connect(CloseTweenObject.Completed, function()
			if not MenuIsOpenBoolean then
				MenuFrame.Visible = false
			end
		end)
		CloseTweenObject:Play()
	end
end

UserInputService.InputBegan.Connect(UserInputService.InputBegan, function(InputObject, GameProcessedEvent)
	if GameProcessedEvent then
		return
	end
	if InputObject.KeyCode == Enum.KeyCode.RightShift then
		SetMenuOpen(not MenuIsOpenBoolean)
	elseif IsBloodZonePlaceBoolean and InputObject.KeyCode == Enum.KeyCode.LeftBracket then
		ToggleSillyMode()
	elseif IsBloodZonePlaceBoolean and IsSillyModeBehaviorActive() and not ShieldModeEnabledBoolean and InputObject.KeyCode == Enum.KeyCode.Z then
		SillySkyAimEnabledBoolean = not SillySkyAimEnabledBoolean
		UpdateSillySkyVisibilityButtonAppearance()
		UpdateDebugStatus("silly sky aim=" .. tostring(SillySkyAimEnabledBoolean))
		DebugLog("toggle-sky-aim", "Silly Mode sky aim set to " .. tostring(SillySkyAimEnabledBoolean), true)
	elseif InputObject.KeyCode == Enum.KeyCode.RightBracket and GetCurrentLockKeyMode() == "Always" then
		AdvanceLockKeyMode()
		UpdateLockKeyButtonAppearance()
	end
end)

local function IsPointInCircle(PointVector2, CircleCenterVector2, CircleRadiusNumber)
	return (PointVector2 - CircleCenterVector2).Magnitude <= CircleRadiusNumber
end

local function GetCubeSize(TargetPart)
	if IsEffectiveVisibleCheckEnabled() and IsEffectiveTargetSegmentationEnabled() then
		local SegmentCount = math.max(VisibleCheckSubdivisionsNumber, 1)
		return Vector3.new(
			TargetPart.Size.X / SegmentCount,
			TargetPart.Size.Y / SegmentCount,
			TargetPart.Size.Z / SegmentCount
		)
	end
	return TargetPart.Size
end

local function GetCubeCorners(CubeCFrame, CubeSize)
	local Half = CubeSize * 0.5
	local LocalCorners = {
		Vector3.new(-Half.X, -Half.Y, -Half.Z),
		Vector3.new(Half.X, -Half.Y, -Half.Z),
		Vector3.new(Half.X, Half.Y, -Half.Z),
		Vector3.new(-Half.X, Half.Y, -Half.Z),
		Vector3.new(-Half.X, -Half.Y, Half.Z),
		Vector3.new(Half.X, -Half.Y, Half.Z),
		Vector3.new(Half.X, Half.Y, Half.Z),
		Vector3.new(-Half.X, Half.Y, Half.Z),
	}
	local WorldCorners = {}
	for Index, LocalCorner in ipairs(LocalCorners) do
		WorldCorners[Index] = CubeCFrame:PointToWorldSpace(LocalCorner)
	end
	return WorldCorners
end

SetTargetCubeVisible = function(IsVisible)
	for _, Line in ipairs(TargetCubeLines) do
		Line.Visible = IsVisible
	end
end

local function UpdateTargetCube(CubeCFrame, CubeSize, SurfacePointVector3)
	local WorldCorners = GetCubeCorners(CubeCFrame, CubeSize)
	local ScreenCorners = {}
	local OnScreenFlags = {}

	for Index, Corner in ipairs(WorldCorners) do
		local ScreenPoint, OnScreen = Camera:WorldToViewportPoint(Corner)
		ScreenCorners[Index] = Vector2.new(ScreenPoint.X, ScreenPoint.Y)
		OnScreenFlags[Index] = OnScreen
	end

	for LineIndex, Pair in ipairs(TargetCubeEdgePairsTable) do
		local StartIndex = Pair[1]
		local EndIndex = Pair[2]
		local Line = TargetCubeLines[LineIndex]
		if OnScreenFlags[StartIndex] and OnScreenFlags[EndIndex] then
			Line.From = ScreenCorners[StartIndex]
			Line.To = ScreenCorners[EndIndex]
			Line.Visible = true
		else
			Line.Visible = false
		end
	end
end

