MenuGui = Instance.new("ScreenGui")
MenuGui.Name = "AimbotSettingsGui"
MenuGui.ResetOnSpawn = false
MenuGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
MenuGui.DisplayOrder = 9999
MenuGui.Parent = gethui()

MenuFrame = Instance.new("Frame")
MenuFrame.Name = "MainFrame"
MenuFrame.Size = UDim2.new(0, 230, 0, CurrentGameIntegrationMenuHeightNumber)
MenuFrame.Position = UDim2.new(0, 20, 0, 200)
MenuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MenuFrame.BorderSizePixel = 0
MenuFrame.Active = true
MenuFrame.ZIndex = 100
MenuFrame.Parent = MenuGui

TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -10, 0, 24)
TitleLabel.Position = UDim2.new(0, 5, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Aimbot Settings"
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 18
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 101
TitleLabel.Parent = MenuFrame

PlayerListRuntimeTable.frame = Instance.new("Frame")
PlayerListRuntimeTable.frame.Name = "PlayerListFrame"
PlayerListRuntimeTable.frame.Size = UDim2.new(0, 220, 0, MenuFrame.Size.Y.Offset)
PlayerListRuntimeTable.frame.Position = UDim2.new(
	MenuFrame.Position.X.Scale,
	MenuFrame.Position.X.Offset + MenuFrame.Size.X.Offset + 10,
	MenuFrame.Position.Y.Scale,
	MenuFrame.Position.Y.Offset
)
PlayerListRuntimeTable.frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
PlayerListRuntimeTable.frame.BorderSizePixel = 0
PlayerListRuntimeTable.frame.Active = true
PlayerListRuntimeTable.frame.ZIndex = 100
PlayerListRuntimeTable.frame.Parent = MenuGui

PlayerListRuntimeTable.titleLabel = Instance.new("TextLabel")
PlayerListRuntimeTable.titleLabel.Name = "PlayerListTitleLabel"
PlayerListRuntimeTable.titleLabel.Size = UDim2.new(1, -12, 0, 24)
PlayerListRuntimeTable.titleLabel.Position = UDim2.new(0, 6, 0, 4)
PlayerListRuntimeTable.titleLabel.BackgroundTransparency = 1
PlayerListRuntimeTable.titleLabel.Text = "Players"
PlayerListRuntimeTable.titleLabel.Font = Enum.Font.SourceSansBold
PlayerListRuntimeTable.titleLabel.TextSize = 18
PlayerListRuntimeTable.titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerListRuntimeTable.titleLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerListRuntimeTable.titleLabel.ZIndex = 101
PlayerListRuntimeTable.titleLabel.Parent = PlayerListRuntimeTable.frame

PlayerListRuntimeTable.statusLabel = Instance.new("TextLabel")
PlayerListRuntimeTable.statusLabel.Name = "PlayerListStatusLabel"
PlayerListRuntimeTable.statusLabel.Size = UDim2.new(1, -12, 0, 42)
PlayerListRuntimeTable.statusLabel.Position = UDim2.new(0, 6, 0, 28)
PlayerListRuntimeTable.statusLabel.BackgroundTransparency = 1
PlayerListRuntimeTable.statusLabel.Text = IsBloodZonePlaceBoolean
	and "LMB: priority | RMB: whitelist\nTags: TGT P W SAFE DOWN SHLD GUN"
	or "LMB: priority | RMB: whitelist\nP: priority | W: whitelist"
PlayerListRuntimeTable.statusLabel.Font = Enum.Font.SourceSans
PlayerListRuntimeTable.statusLabel.TextSize = 14
PlayerListRuntimeTable.statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
PlayerListRuntimeTable.statusLabel.TextWrapped = true
PlayerListRuntimeTable.statusLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerListRuntimeTable.statusLabel.TextYAlignment = Enum.TextYAlignment.Top
PlayerListRuntimeTable.statusLabel.ZIndex = 101
PlayerListRuntimeTable.statusLabel.Parent = PlayerListRuntimeTable.frame

PlayerListRuntimeTable.scrollFrame = Instance.new("ScrollingFrame")
PlayerListRuntimeTable.scrollFrame.Name = "PlayerListScrollFrame"
PlayerListRuntimeTable.scrollFrame.Size = UDim2.new(1, -12, 1, -78)
PlayerListRuntimeTable.scrollFrame.Position = UDim2.new(0, 6, 0, 72)
PlayerListRuntimeTable.scrollFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
PlayerListRuntimeTable.scrollFrame.BorderSizePixel = 0
PlayerListRuntimeTable.scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListRuntimeTable.scrollFrame.ScrollBarThickness = 6
PlayerListRuntimeTable.scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
PlayerListRuntimeTable.scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.None
PlayerListRuntimeTable.scrollFrame.ZIndex = 101
PlayerListRuntimeTable.scrollFrame.Parent = PlayerListRuntimeTable.frame

PlayerListRuntimeTable.layout = Instance.new("UIListLayout")
PlayerListRuntimeTable.layout.Name = "PlayerListLayout"
PlayerListRuntimeTable.layout.Padding = UDim.new(0, 2)
PlayerListRuntimeTable.layout.SortOrder = Enum.SortOrder.LayoutOrder
PlayerListRuntimeTable.layout.Parent = PlayerListRuntimeTable.scrollFrame

DebugFrame = Instance.new("Frame")
DebugFrame.Name = "DebugFrame"
DebugFrame.Size = UDim2.new(0, 300, 0, 72)
DebugFrame.Position = UDim2.new(0, 260, 0, 200)
DebugFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
DebugFrame.BorderSizePixel = 0
DebugFrame.Visible = DebugModeEnabledBoolean
DebugFrame.ZIndex = 100
DebugFrame.Parent = MenuGui

DebugStatusLabel = Instance.new("TextLabel")
DebugStatusLabel.Name = "DebugStatusLabel"
DebugStatusLabel.Size = UDim2.new(1, -12, 1, -12)
DebugStatusLabel.Position = UDim2.new(0, 6, 0, 6)
DebugStatusLabel.BackgroundTransparency = 1
DebugStatusLabel.Text = "Debug: booting"
DebugStatusLabel.Font = Enum.Font.Code
DebugStatusLabel.TextSize = 14
DebugStatusLabel.TextColor3 = Color3.fromRGB(255, 220, 120)
DebugStatusLabel.TextWrapped = true
DebugStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
DebugStatusLabel.TextYAlignment = Enum.TextYAlignment.Top
DebugStatusLabel.ZIndex = 101
DebugStatusLabel.Parent = DebugFrame

local function SafeDebugName(Value)
	if Value == nil then
		return "nil"
	end
	if typeof(Value) == "Instance" then
		return Value.Name
	end
	return tostring(Value)
end

local function GetTargetIdentity(PlayerObject, CharacterModel, PartInstance)
	local PlayerNameString = "nil"
	if PlayerObject then
		PlayerNameString = PlayerObject.Name
	elseif CharacterModel then
		PlayerNameString = SafeDebugName(CharacterModel)
	end
	return PlayerNameString .. "/" .. SafeDebugName(PartInstance)
end

local function UpdateDebugStatus(TextString)
	if DebugModeEnabledBoolean and DebugStatusLabel then
		DebugStatusLabel.Text = "Debug: " .. TextString
	end
end

local function IsMouseOverAimbotUi(MouseLocationVector2)
	if not MouseLocationVector2 or not MenuGui or not MenuGui.Parent then
		return false
	end

	local InsetTopLeftVector2 = GuiService.GetGuiInset and GuiService.GetGuiInset(GuiService) or Vector2.new()
	local GuiMouseLocationVector2 = MouseLocationVector2 - InsetTopLeftVector2

	local function IsPointInsideGuiObject(GuiObject)
		if not GuiObject or not GuiObject.Visible then
			return false
		end

		local AbsolutePositionVector2 = GuiObject.AbsolutePosition
		local AbsoluteSizeVector2 = GuiObject.AbsoluteSize
		if AbsoluteSizeVector2.X <= 0 or AbsoluteSizeVector2.Y <= 0 then
			return false
		end

		return GuiMouseLocationVector2.X >= AbsolutePositionVector2.X
			and GuiMouseLocationVector2.X <= (AbsolutePositionVector2.X + AbsoluteSizeVector2.X)
			and GuiMouseLocationVector2.Y >= AbsolutePositionVector2.Y
			and GuiMouseLocationVector2.Y <= (AbsolutePositionVector2.Y + AbsoluteSizeVector2.Y)
	end

	for _, GuiObject in ipairs({
		MenuFrame,
		PlayerListRuntimeTable.frame,
		DebugFrame,
	}) do
		if IsPointInsideGuiObject(GuiObject) then
			return true
		end
	end

	return false
end

local UiInteractionRuntimeTable = {
	inputSuppressedUntilTime = 0,
	dragEnabled = true,
	draggingFrame = nil,
	dragStartInputPosition = nil,
	startFramePosition = nil,
	smoothSliderDragging = false,
	fovSliderDragging = false,
	hitChanceSliderDragging = false,
}

local function SuppressAimbotUiInput(DurationNumber)
	local SuppressDurationNumber = math.max(DurationNumber or 0.12, 0)
	UiInteractionRuntimeTable.inputSuppressedUntilTime = math.max(UiInteractionRuntimeTable.inputSuppressedUntilTime, tick() + SuppressDurationNumber)
end

local function IsAimbotUiInputSuppressed()
	return tick() < UiInteractionRuntimeTable.inputSuppressedUntilTime
end

local function SendAimbotMouseClick(MouseLocationVector2)
	if not MouseLocationVector2 then
		return
	end

	SuppressAimbotUiInput(0.15)
	VirtualInputManager.SendMouseButtonEvent(VirtualInputManager, MouseLocationVector2.X, MouseLocationVector2.Y, 0, true, nil, 0)
	VirtualInputManager.SendMouseButtonEvent(VirtualInputManager, MouseLocationVector2.X, MouseLocationVector2.Y, 0, false, nil, 0)
end

local function DebugLog(KeyString, TextString, ForceBoolean)
	if not DebugModeEnabledBoolean then
		return
	end

	local NowNumber = tick()
	if not ForceBoolean then
		local LastPrintNumber = DebugLastPrintByKeyTable[KeyString]
		if LastPrintNumber and (NowNumber - LastPrintNumber) < DebugPrintIntervalNumber then
			return
		end
	end

	DebugLastPrintByKeyTable[KeyString] = NowNumber
	warn("[aimbot-debug][" .. KeyString .. "] " .. TextString)
end

local function TraceLog(KeyString, TextString, ForceBoolean)
	if not TraceModeEnabledBoolean then
		return
	end

	local NowNumber = tick()
	if not ForceBoolean then
		local LastPrintNumber = TraceLastPrintByKeyTable[KeyString]
		if LastPrintNumber and (NowNumber - LastPrintNumber) < TracePrintIntervalNumber then
			return
		end
	end

	TraceLastPrintByKeyTable[KeyString] = NowNumber
	warn("[aimbot-trace][" .. KeyString .. "] " .. TextString)
end

local function FormatDebugVector3(Value)
	if typeof(Value) ~= "Vector3" then
		return tostring(Value)
	end

	return string.format("(%.2f, %.2f, %.2f)", Value.X, Value.Y, Value.Z)
end

local function DescribeDebugInstance(Value)
	if typeof(Value) ~= "Instance" then
		return tostring(Value)
	end

	local PathPartsTable = {}
	local CurrentInstance = Value
	local DepthNumber = 0
	while CurrentInstance and DepthNumber < 6 do
		table.insert(PathPartsTable, 1, CurrentInstance.Name)
		CurrentInstance = CurrentInstance.Parent
		DepthNumber = DepthNumber + 1
	end

	return Value.ClassName .. "<" .. table.concat(PathPartsTable, "/") .. ">"
end

local function SafeGetLocalGunBase(LocalGunTable)
	if type(LocalGunTable) ~= "table" or type(LocalGunTable.GetBase) ~= "function" then
		return nil, "no-getbase"
	end

	local SuccessBoolean, ResultValue = pcall(LocalGunTable.GetBase, LocalGunTable)
	if not SuccessBoolean then
		return nil, tostring(ResultValue)
	end

	return ResultValue, nil
end

UpdateDebugStatus("waiting for target search")

local function ResetRejectCounts()
	DebugRejectCountsTable = {}
end

local function RecordRejectReason(ReasonKey)
	DebugRejectCountsTable[ReasonKey] = (DebugRejectCountsTable[ReasonKey] or 0) + 1
end

local function GetRejectCountsSummary()
	local SummaryParts = {}
	for _, ReasonKey in ipairs({
		"dead",
		"distance",
		"offscreen",
		"fov",
		"visible",
		"point_offscreen",
		"point_fov",
	}) do
		local CountNumber = DebugRejectCountsTable[ReasonKey]
		if CountNumber and CountNumber > 0 then
			table.insert(SummaryParts, ReasonKey .. "=" .. tostring(CountNumber))
		end
	end

	if #SummaryParts == 0 then
		return "none"
	end

	return table.concat(SummaryParts, " ")
end

local function IsSillyModeEnabled()
	return IsBloodZonePlaceBoolean and SillyModeEnabledBoolean
end

local function IsSillyModeBehaviorActive()
	return IsBloodZonePlaceBoolean and SillyModeRuntimeActiveBoolean
end

local function IsEffectiveShieldModeEnabled()
	return IsSillyModeBehaviorActive() and ShieldModeEnabledBoolean
end

local function GetProjectileProfileSpeedNumber(ProfileTable)
	if type(ProfileTable) ~= "table" then
		return nil
	end

	return tonumber(ProfileTable.speed)
end

local function ShouldUseForceCurveProjectileProfile(ProfileTable)
	return type(ProfileTable) == "table" and ProfileTable.launchMode == "force_curve"
end

local function GetProjectileProfileGravityNumber(ProfileTable)
	if type(ProfileTable) ~= "table" then
		return 0
	end

	if ProfileTable.useWorkspaceGravity == true then
		return tonumber(WorkspaceService and WorkspaceService.Gravity) or 196.2
	end

	return tonumber(ProfileTable.gravity) or 0
end

local function GetProjectileProfileGravityMagnitudeNumber(ProfileTable)
	return math.abs(GetProjectileProfileGravityNumber(ProfileTable))
end

local function GetProjectileSplashRadiusNumber(ProfileTable)
	if type(ProfileTable) ~= "table" then
		return nil
	end

	local ExplicitRadiusNumber = tonumber(ProfileTable.splashRadius)
	if type(ExplicitRadiusNumber) == "number" and ExplicitRadiusNumber > 0 then
		return ExplicitRadiusNumber
	end

	local WeaponSettingsTable = ProfileTable.settings
	local DamageNumber = tonumber(WeaponSettingsTable and WeaponSettingsTable.Damage)
	if type(DamageNumber) == "number" and DamageNumber > 0 then
		local EstimatedRadiusNumber = math.clamp(DamageNumber * 0.16, 6, 14)
		if ProfileTable.isLauncher then
			EstimatedRadiusNumber = math.max(EstimatedRadiusNumber, 10)
		end
		return EstimatedRadiusNumber
	end

	return nil
end

local function IsExplosiveProjectileProfile(ProfileTable)
	if type(ProfileTable) ~= "table" or ProfileTable.isProjectile ~= true then
		return false
	end

	if ProfileTable.explodes == true or ProfileTable.isLauncher == true then
		return true
	end

	local ProjectileNameString = ProfileTable.projectileName
	if type(ProjectileNameString) == "string"
		and ExplosiveProjectileNameSetTable[ProjectileNameString] == true then
		return true
	end

	local LaunchAssetInstance = ProfileTable.launchAsset
	local LaunchAssetNameString = LaunchAssetInstance and LaunchAssetInstance.Name or nil
	return type(LaunchAssetNameString) == "string"
		and ExplosiveProjectileNameSetTable[LaunchAssetNameString] == true
end

local function ShouldUseProjectileArcVisibilityProfile(ProfileTable)
	return ShieldModeRuntimeTable.CanPredictProjectileWeaponProfile(ProfileTable)
		and IsExplosiveProjectileProfile(ProfileTable)
end

local function ShouldPreferHighArcProjectileProfile(ProfileTable)
	if ShouldUseForceCurveProjectileProfile(ProfileTable) then
		return false
	end

	return ShouldUseProjectileArcVisibilityProfile(ProfileTable)
		and GetProjectileProfileGravityMagnitudeNumber(ProfileTable) > 0.001
end

local function IsWideProjectileCastProfile(ProfileTable)
	return type(ProfileTable) == "table"
		and type(ProfileTable.castType) == "number"
		and ProfileTable.castType ~= 0
end

local function IsPrecisionProjectileHeadAimProfile(ProfileTable)
	if type(ProfileTable) ~= "table" or ProfileTable.isProjectile ~= true then
		return false
	end

	if ProfileTable.rayHit ~= true or IsWideProjectileCastProfile(ProfileTable) then
		return false
	end

	local SpeedNumber = GetProjectileProfileSpeedNumber(ProfileTable) or 0
	local GravityMagnitudeNumber = GetProjectileProfileGravityMagnitudeNumber(ProfileTable)
	return SpeedNumber >= 450 and GravityMagnitudeNumber <= 60
end

local function ShouldPreferProjectileBodyAimForProfile(ProfileTable)
	if type(ProfileTable) ~= "table" or ProfileTable.isProjectile ~= true then
		return false
	end

	local SpeedNumber = GetProjectileProfileSpeedNumber(ProfileTable) or math.huge
	local GravityMagnitudeNumber = GetProjectileProfileGravityMagnitudeNumber(ProfileTable)
	if IsPrecisionProjectileHeadAimProfile(ProfileTable) then
		return false
	end
	if ProfileTable.rayHit == false then
		return true
	end
	if IsWideProjectileCastProfile(ProfileTable) then
		return true
	end
	if GravityMagnitudeNumber >= 25 and SpeedNumber <= 550 then
		return true
	end
	if GravityMagnitudeNumber >= 15 and SpeedNumber <= 260 then
		return true
	end

	return false
end

local function ShouldPreferProjectileFeetImpactForProfile(ProfileTable)
	if not ShouldPreferProjectileBodyAimForProfile(ProfileTable) then
		return false
	end

	return ProfileTable.rayHit == false or IsWideProjectileCastProfile(ProfileTable)
end

local function IsEffectiveHeadshotPriorityEnabled()
	if ShouldPreferProjectileBodyAimForProfile(CurrentWeaponBallisticsProfileTable) then
		return false
	end

	return IsSillyModeBehaviorActive() or HeadshotPriorityBoolean
end

local function IsEffectiveAutoFireEnabled()
	return IsSillyModeBehaviorActive() or AutoFireEnabledBoolean
end

local function IsEffectiveVisibleCheckEnabled()
	return IsSillyModeBehaviorActive() or VisibleCheckEnabledBoolean
end

local function IsEffectiveTargetSegmentationEnabled()
	if IsSillyModeBehaviorActive() then
		return false
	end
	return TargetSegmentationEnabledBoolean
end

local function IsEffectiveHookMethodEnabled()
	return IsSillyModeBehaviorActive() or UseHookMethodBoolean
end

local function IsEffectiveCameraMethodEnabled()
	if IsSillyModeBehaviorActive() then
		return false
	end
	return UseCameraMethodBoolean
end

local function IsLegitModeBehaviorActive()
	return not IsSillyModeBehaviorActive()
end

local function IsStickyAimActive()
	return IsLegitModeBehaviorActive() and StickyAimEnabledBoolean
end

local function ResetNormalHookHitChanceDecision()
	LastNormalHookHitChanceDecisionTimeNumber = 0
	LastNormalHookHitChanceDecisionBoolean = true
end

local function ShouldApplyNormalHookHitChance()
	if not IsLegitModeBehaviorActive() or not UseHookMethodBoolean then
		return true
	end

	local HitChanceNumber = math.clamp(tonumber(NormalHookHitChanceNumber) or 100, 0, 100)
	if HitChanceNumber >= 100 then
		return true
	end
	if HitChanceNumber <= 0 then
		return false
	end

	local NowNumber = tick()
	-- Keep multiple internal raycasts from the same shot on the same roll.
	if (NowNumber - LastNormalHookHitChanceDecisionTimeNumber) <= NormalHookHitChanceDecisionWindowNumber then
		return LastNormalHookHitChanceDecisionBoolean
	end

	LastNormalHookHitChanceDecisionTimeNumber = NowNumber
	LastNormalHookHitChanceDecisionBoolean = math.random(0, 1000000) <= (HitChanceNumber * 10000)
	return LastNormalHookHitChanceDecisionBoolean
end

local function ShouldIgnoreFovChecks(IgnoreFovBoolean)
	return IgnoreFovBoolean or IsSillyModeBehaviorActive()
end

local function ShouldIgnoreOffscreenChecks()
	return IsSillyModeBehaviorActive()
end

local function GetTargetSortDistance(TargetData)
	if not TargetData then
		return math.huge
	end
	return TargetData.sortDistance or TargetData.screenDistance or math.huge
end

local function GetCharacterHumanoid(CharacterModel)
	if not CharacterModel then
		return nil
	end

	local Humanoid = CharacterModel.FindFirstChild(CharacterModel, "Humanoid")
	if Humanoid and Humanoid.ClassName == "Humanoid" then
		return Humanoid
	end

	local HumanoidByClass = CharacterModel.FindFirstChildWhichIsA and CharacterModel.FindFirstChildWhichIsA(CharacterModel, "Humanoid") or nil
	if HumanoidByClass and HumanoidByClass.Parent == CharacterModel then
		return HumanoidByClass
	end

	return nil
end

local function IsHumanoidCharacterModel(CharacterModel)
	return GetCharacterHumanoid(CharacterModel) ~= nil
end

local function GetCharactersFolder()
	local CharactersFolder = WorkspaceService.Characters
	if not CharactersFolder then
		CharactersFolder = WorkspaceService.FindFirstChild(WorkspaceService, "Characters")
	end
	if CharactersFolder and (CharactersFolder.ClassName == "Model" or CharactersFolder.ClassName == "Folder") then
		return CharactersFolder
	end
	return nil
end

local function GetCharacterRootPart(CharacterModel)
	if not CharacterModel then
		return nil
	end

	local RootPartInstance = CharacterModel.FindFirstChild(CharacterModel, "HumanoidRootPart")
	if RootPartInstance and RootPartInstance.IsA(RootPartInstance, "BasePart") then
		return RootPartInstance
	end

	return nil
end

local function GetCharacterHeadPart(CharacterModel)
	if not CharacterModel then
		return nil
	end

	local HeadPartInstance = CharacterModel.FindFirstChild(CharacterModel, "Head")
	if HeadPartInstance and HeadPartInstance.IsA(HeadPartInstance, "BasePart") then
		return HeadPartInstance
	end

	return nil
end

local PreferredTorsoPartNamesInOrderTable = {
	"UpperTorso",
	"Torso",
	"LowerTorso",
	"Center",
	"HitboxPart",
}

local function GetCharacterTorsoLikePart(CharacterModel)
	if not CharacterModel then
		return nil
	end

	for _, PreferredPartNameString in ipairs(PreferredTorsoPartNamesInOrderTable) do
		local PartInstance = CharacterModel.FindFirstChild(CharacterModel, PreferredPartNameString)
		if PartInstance and PartInstance.IsA(PartInstance, "BasePart") then
			return PartInstance
		end
	end

	return nil
end

local function SafeGetBasePartAssemblyLinearVelocity(PartInstance)
	if not PartInstance
		or not PartInstance.Parent
		or not PartInstance.IsA
		or not PartInstance.IsA(PartInstance, "BasePart") then
		return nil
	end

	local SuccessBoolean, VelocityVector3 = pcall(function()
		return PartInstance.AssemblyLinearVelocity
	end)
	if SuccessBoolean and typeof(VelocityVector3) == "Vector3" then
		return VelocityVector3
	end

	return nil
end

local function GetCharacterVelocitySamplePart(CharacterModel, PreferredPartInstance)
	local RootPartInstance = GetCharacterRootPart(CharacterModel)
	if RootPartInstance and RootPartInstance.Parent then
		return RootPartInstance
	end

	if PreferredPartInstance
		and PreferredPartInstance.Parent
		and PreferredPartInstance.IsA
		and PreferredPartInstance.IsA(PreferredPartInstance, "BasePart") then
		return PreferredPartInstance
	end

	return GetCharacterTorsoLikePart(CharacterModel)
		or GetCharacterHeadPart(CharacterModel)
		or nil
end

local function EstimateCharacterObservedVelocityVector3(CharacterModel, PreferredPartInstance)
	if not CharacterModel or not CharacterModel.Parent then
		return nil
	end

	local SamplePartInstance = GetCharacterVelocitySamplePart(CharacterModel, PreferredPartInstance)
	if not SamplePartInstance then
		return nil
	end

	local CurrentPositionVector3 = SamplePartInstance.Position
	local CurrentTimeNumber = tick()
	local PreviousSampleTable = ObservedCharacterVelocitySampleByModelTable[CharacterModel]
	local PreviousVelocityVector3 = PreviousSampleTable and PreviousSampleTable.velocity or nil
	local ObservedVelocityVector3 = nil

	if PreviousSampleTable
		and typeof(PreviousSampleTable.position) == "Vector3"
		and type(PreviousSampleTable.time) == "number" then
		local DeltaTimeNumber = CurrentTimeNumber - PreviousSampleTable.time
		local PositionDeltaVector3 = CurrentPositionVector3 - PreviousSampleTable.position
		if DeltaTimeNumber >= (1 / 240)
			and DeltaTimeNumber <= 0.35
			and PositionDeltaVector3.Magnitude <= 64 then
			ObservedVelocityVector3 = PositionDeltaVector3 / DeltaTimeNumber
			if typeof(PreviousVelocityVector3) == "Vector3" then
				local BlendAlphaNumber = math.clamp(DeltaTimeNumber * 8, 0.18, 0.55)
				ObservedVelocityVector3 = PreviousVelocityVector3:Lerp(ObservedVelocityVector3, BlendAlphaNumber)
			end
		end
	end

	local StoredVelocityVector3 = ObservedVelocityVector3
		or (typeof(PreviousVelocityVector3) == "Vector3" and PreviousVelocityVector3 or nil)
	if typeof(StoredVelocityVector3) == "Vector3" and StoredVelocityVector3.Magnitude > 120 then
		StoredVelocityVector3 = StoredVelocityVector3.Unit * 120
	end

	ObservedCharacterVelocitySampleByModelTable[CharacterModel] = {
		position = CurrentPositionVector3,
		time = CurrentTimeNumber,
		velocity = StoredVelocityVector3,
	}

	return StoredVelocityVector3
end

local function GetCharacterVelocityVector3(CharacterModel, PreferredPartInstance)
	if not CharacterModel then
		return Vector3.zero
	end

	local CachedVelocityVector3 = FrameCharacterVelocityCacheTable[CharacterModel]
	if typeof(CachedVelocityVector3) == "Vector3" then
		return CachedVelocityVector3
	end

	local AssemblyVelocityVector3 = SafeGetBasePartAssemblyLinearVelocity(GetCharacterRootPart(CharacterModel))
	if typeof(AssemblyVelocityVector3) ~= "Vector3" then
		AssemblyVelocityVector3 = SafeGetBasePartAssemblyLinearVelocity(PreferredPartInstance)
	end

	local ObservedVelocityVector3 = EstimateCharacterObservedVelocityVector3(CharacterModel, PreferredPartInstance)
	local VelocityVector3 = nil
	if typeof(AssemblyVelocityVector3) == "Vector3" and typeof(ObservedVelocityVector3) == "Vector3" then
		local HorizontalAssemblyVelocityVector3 = Vector3.new(AssemblyVelocityVector3.X, 0, AssemblyVelocityVector3.Z)
		local HorizontalObservedVelocityVector3 = Vector3.new(ObservedVelocityVector3.X, 0, ObservedVelocityVector3.Z)
		local HorizontalVelocityVector3
		if HorizontalObservedVelocityVector3.Magnitude <= 0.1 then
			HorizontalVelocityVector3 = HorizontalAssemblyVelocityVector3
		elseif HorizontalAssemblyVelocityVector3.Magnitude <= 0.1 then
			HorizontalVelocityVector3 = HorizontalObservedVelocityVector3
		else
			HorizontalVelocityVector3 = HorizontalAssemblyVelocityVector3:Lerp(HorizontalObservedVelocityVector3, 0.75)
		end

		local VerticalVelocityNumber = math.abs(AssemblyVelocityVector3.Y) >= 2
			and AssemblyVelocityVector3.Y
			or ObservedVelocityVector3.Y
		VelocityVector3 = Vector3.new(
			HorizontalVelocityVector3.X,
			VerticalVelocityNumber,
			HorizontalVelocityVector3.Z
		)
	elseif typeof(ObservedVelocityVector3) == "Vector3" then
		VelocityVector3 = ObservedVelocityVector3
	elseif typeof(AssemblyVelocityVector3) == "Vector3" then
		VelocityVector3 = AssemblyVelocityVector3
	end

	if typeof(VelocityVector3) ~= "Vector3" then
		VelocityVector3 = Vector3.zero
	end

	FrameCharacterVelocityCacheTable[CharacterModel] = VelocityVector3
	return VelocityVector3
end

local function GetCharacterIdentityString(CharacterModel)
	if not CharacterModel then
		return nil
	end

	local CharacterNameString = CharacterModel.Name
	if CharacterNameString and CharacterNameString ~= "" then
		return CharacterNameString
	end

	local Humanoid = GetCharacterHumanoid(CharacterModel)
	local HumanoidDisplayNameString = Humanoid and Humanoid.DisplayName or nil
	if HumanoidDisplayNameString and HumanoidDisplayNameString ~= "" then
		return HumanoidDisplayNameString
	end

	return nil
end

local function GetCharacterModelDebugName(CharacterModel)
	local CharacterIdentityString = GetCharacterIdentityString(CharacterModel)
	if CharacterIdentityString then
		return CharacterIdentityString
	end

	return SafeDebugName(CharacterModel)
end

local function RefreshCustomCharacterCaches()
	local CharactersFolder = GetCharactersFolder()
	if not CharactersFolder then
		CachedCharactersFolderInstance = nil
		CachedCharacterFolderChildCountNumber = -1
		CachedCharacterFolderScanTimeNumber = tick()
		CachedDirectCharacterModelsTable = {}
		CachedCustomCharacterByPlayerTable = {}
		return
	end

	local DirectCharacterModelsTable = {}
	local CustomCharacterByPlayerTable = {}
	for _, ChildInstance in ipairs(CharactersFolder.GetChildren(CharactersFolder)) do
		if ChildInstance.ClassName == "Model"
			and GetCharacterHumanoid(ChildInstance)
			and GetCharacterRootPart(ChildInstance) then
			table.insert(DirectCharacterModelsTable, ChildInstance)
			local MatchingPlayerObject = Players.GetPlayerFromCharacter(Players, ChildInstance)
			if MatchingPlayerObject then
				CustomCharacterByPlayerTable[MatchingPlayerObject] = ChildInstance
			end
		end
	end

	CachedCharactersFolderInstance = CharactersFolder
	CachedCharacterFolderChildCountNumber = #CharactersFolder.GetChildren(CharactersFolder)
	CachedCharacterFolderScanTimeNumber = tick()
	CachedDirectCharacterModelsTable = DirectCharacterModelsTable
	CachedCustomCharacterByPlayerTable = CustomCharacterByPlayerTable
end

local function EnsureCustomCharacterCaches()
	if not IsCustomCharacterGameBoolean then
		return
	end

	local CharactersFolder = GetCharactersFolder()
	local NowNumber = tick()
	if not CharactersFolder then
		if CachedCharactersFolderInstance ~= nil then
			RefreshCustomCharacterCaches()
		end
		return
	end

	local ChildCountNumber = #CharactersFolder.GetChildren(CharactersFolder)
	if CachedCharactersFolderInstance ~= CharactersFolder
		or CachedCharacterFolderChildCountNumber ~= ChildCountNumber
		or (NowNumber - CachedCharacterFolderScanTimeNumber) >= CustomCharacterCacheDurationNumber then
		RefreshCustomCharacterCaches()
	end
end

local function GetDirectCharacterModelsFromCharactersFolder()
	EnsureCustomCharacterCaches()
	return CachedDirectCharacterModelsTable
end

local function GetCharacterModelsFromCharactersFolder()
	return GetDirectCharacterModelsFromCharactersFolder()
end

local function FindCustomCharacterForPlayer(PlayerObject)
	if not PlayerObject then
		return nil
	end

	EnsureCustomCharacterCaches()
	local CachedCharacterModel = CachedCustomCharacterByPlayerTable[PlayerObject]
	if CachedCharacterModel and CachedCharacterModel.Parent then
		return CachedCharacterModel
	end

	if not IsCustomCharacterGameBoolean then
		return nil
	end

	local PlayerNameLowerString = string.lower(PlayerObject.Name or "")
	local DisplayNameLowerString = string.lower(PlayerObject.DisplayName or "")
	for _, CharacterModel in ipairs(CachedDirectCharacterModelsTable) do
		local CharacterNameLowerString = string.lower(CharacterModel.Name or "")
		if CharacterNameLowerString == PlayerNameLowerString
			or (DisplayNameLowerString ~= "" and CharacterNameLowerString == DisplayNameLowerString) then
			CachedCustomCharacterByPlayerTable[PlayerObject] = CharacterModel
			return CharacterModel
		end

		local CharacterIdentityLowerString = string.lower(GetCharacterIdentityString(CharacterModel) or "")
		if CharacterIdentityLowerString == PlayerNameLowerString
			or (DisplayNameLowerString ~= "" and CharacterIdentityLowerString == DisplayNameLowerString) then
			CachedCustomCharacterByPlayerTable[PlayerObject] = CharacterModel
			return CharacterModel
		end

		local AboveGuiInstance = CharacterModel.FindFirstChild and CharacterModel.FindFirstChild(CharacterModel, "ABOVE", true) or nil
		local UsernameLabelInstance = AboveGuiInstance and AboveGuiInstance.FindFirstChild and AboveGuiInstance.FindFirstChild(AboveGuiInstance, "Username", true) or nil
		local UsernameTextLowerString = string.lower(UsernameLabelInstance and UsernameLabelInstance.Text or "")
		if UsernameTextLowerString == PlayerNameLowerString
			or (DisplayNameLowerString ~= "" and UsernameTextLowerString == DisplayNameLowerString) then
			CachedCustomCharacterByPlayerTable[PlayerObject] = CharacterModel
			return CharacterModel
		end
	end

	return nil
end

local function ResolveCharacterModelForPlayer(PlayerObject)
	if not PlayerObject then
		return nil
	end

	local NowNumber = tick()
	local CachedEntryTable = ResolveCharacterModelCacheTable[PlayerObject]
	if CachedEntryTable and (NowNumber - (CachedEntryTable.time or 0)) < ResolveCharacterModelCacheDurationNumber then
		local CachedCharacterModel = CachedEntryTable.character
		if not CachedCharacterModel or CachedCharacterModel.Parent then
			return CachedCharacterModel
		end
	end

	local ResolvedCharacterModel = nil
	if IsCustomCharacterGameBoolean then
		local CustomCharacterModel = FindCustomCharacterForPlayer(PlayerObject)
		if CustomCharacterModel then
			ResolvedCharacterModel = CustomCharacterModel
		end
	end

	if not ResolvedCharacterModel then
		local PlayerCharacter = PlayerObject.Character
		if IsHumanoidCharacterModel(PlayerCharacter) then
			ResolvedCharacterModel = PlayerCharacter
		end
	end

	if not ResolvedCharacterModel then
		local CustomCharacterModel = FindCustomCharacterForPlayer(PlayerObject)
		if CustomCharacterModel then
			ResolvedCharacterModel = CustomCharacterModel
		end
	end

	ResolveCharacterModelCacheTable[PlayerObject] = {
		time = NowNumber,
		character = ResolvedCharacterModel,
	}
	return ResolvedCharacterModel
end

local function InvalidateSearchableCharacterEntriesCache()
	CachedSearchableCharacterEntriesTable = {}
	CachedSearchableCharacterEntriesKeyString = nil
	CachedSearchableCharacterEntriesTimeNumber = 0
end

function PlayerListRuntimeTable.IsPlayerWhitelisted(PlayerObject)
	return PlayerObject ~= nil and PlayerListRuntimeTable.whitelistByPlayer[PlayerObject] == true
end

function PlayerListRuntimeTable.IsPriorityPlayer(PlayerObject)
	return PlayerObject ~= nil and PlayerListRuntimeTable.priorityByPlayer[PlayerObject] == true
end

function PlayerListRuntimeTable.IsCurrentTargetPlayer(PlayerObject)
	if not PlayerObject or not CurrentTargetPartInstance then
		return false
	end

	if CurrentTargetPlayerObject ~= nil and CurrentTargetPlayerObject == PlayerObject then
		return true
	end

	local CharacterModel = ResolveCharacterModelForPlayer(PlayerObject)
	return CharacterModel ~= nil and CurrentTargetCharacterModel == CharacterModel
end

function PlayerListRuntimeTable.ClearTrackedTargetForPlayer(PlayerObject)
	if not PlayerObject then
		return
	end

	if CurrentTargetPlayerObject == PlayerObject then
		CurrentTargetPartInstance = nil
		CurrentTargetCharacterModel = nil
		CurrentTargetPlayerObject = nil
		CurrentTargetPointVector3 = nil
		CurrentTargetAimPointVector3 = nil
		CurrentTargetLocalPointVector3 = nil
		CurrentTargetCubeCFrame = nil
		CurrentTargetCubeSize = nil
	end

	if LastFallbackIndicatorPlayerObject == PlayerObject then
		LastFallbackIndicatorPartInstance = nil
		LastFallbackIndicatorCharacterModel = nil
		LastFallbackIndicatorPlayerObject = nil
	end
end

function PlayerListRuntimeTable.CleanupTargetPreferences()
	for PlayerObject, _ in pairs(PlayerListRuntimeTable.whitelistByPlayer) do
		if typeof(PlayerObject) ~= "Instance" or PlayerObject.Parent ~= Players then
			PlayerListRuntimeTable.whitelistByPlayer[PlayerObject] = nil
		end
	end

	for PlayerObject, _ in pairs(PlayerListRuntimeTable.priorityByPlayer) do
		if typeof(PlayerObject) ~= "Instance" or PlayerObject.Parent ~= Players then
			PlayerListRuntimeTable.priorityByPlayer[PlayerObject] = nil
		end
	end
end

function PlayerListRuntimeTable.GetDisplayName(PlayerObject)
	if not PlayerObject then
		return "Unknown"
	end

	local DisplayNameString = PlayerObject.DisplayName
	if type(DisplayNameString) == "string" and DisplayNameString ~= "" and DisplayNameString ~= PlayerObject.Name then
		return DisplayNameString .. " (@" .. PlayerObject.Name .. ")"
	end

	return PlayerObject.Name
end

function PlayerListRuntimeTable.GetEntryState(PlayerObject, CharacterModel, IsCurrentTargetBoolean)
	local NowNumber = tick()
	local StateTags = {}
	local BackgroundColor3 = Color3.fromRGB(42, 42, 42)
	local TextColor3 = Color3.fromRGB(255, 255, 255)
	local PriorityBoolean = PlayerListRuntimeTable.IsPriorityPlayer(PlayerObject)
	local WhitelistedBoolean = PlayerListRuntimeTable.IsPlayerWhitelisted(PlayerObject)
	local CachedEntryTable = PlayerListRuntimeTable.entryStateCache and PlayerListRuntimeTable.entryStateCache[PlayerObject] or nil
	if CachedEntryTable
		and CachedEntryTable.character == CharacterModel
		and CachedEntryTable.isCurrentTarget == IsCurrentTargetBoolean
		and CachedEntryTable.isPriority == PriorityBoolean
		and CachedEntryTable.isWhitelist == WhitelistedBoolean
		and (NowNumber - (CachedEntryTable.time or 0)) < PlayerListEntryStateCacheDurationNumber then
		return CachedEntryTable.state
	end
	if IsBloodZonePlaceBoolean then
		CharacterModel = CharacterModel or ResolveCharacterModelForPlayer(PlayerObject)
	else
		CharacterModel = nil
	end
	if IsCurrentTargetBoolean == nil then
		IsCurrentTargetBoolean = PlayerListRuntimeTable.IsCurrentTargetPlayer(PlayerObject)
	end
	local Humanoid = nil
	local RootPartInstance = nil
	local SafeBoolean = false
	local CarriedBoolean = false
	local EscapedBoolean = false
	local DownedBoolean = false
	local DeadBodyBoolean = false
	local DeadBoolean = false
	local HasShieldBoolean = false
	local ArmedBoolean = false

	if IsBloodZonePlaceBoolean then
		Humanoid = CharacterModel and GetCharacterHumanoid(CharacterModel) or nil
		RootPartInstance = CharacterModel and GetCharacterRootPart(CharacterModel) or nil
		SafeBoolean = CharacterModel and IsCharacterForceFieldProtected ~= nil and IsCharacterForceFieldProtected(CharacterModel, Humanoid) or false
		CarriedBoolean = CharacterModel and CharacterModel.GetAttribute(CharacterModel, "Carried") == true or false
		EscapedBoolean = CharacterModel and CharacterModel.GetAttribute(CharacterModel, "Escaped") == true or false
		DownedBoolean = CharacterModel and (CharacterModel.GetAttribute(CharacterModel, "Downed") == true or CharacterModel.GetAttribute(CharacterModel, "IsRagdolled") == true) or false
		DeadBodyBoolean = CharacterModel and CollectionService.HasTag(CollectionService, CharacterModel, "DeadBody") or false

		local HeldItemStateTable = CharacterModel and ShieldModeRuntimeTable.GetBloodZoneHeldItemState and ShieldModeRuntimeTable.GetBloodZoneHeldItemState(CharacterModel) or nil
		HasShieldBoolean = HeldItemStateTable and HeldItemStateTable.hasShield or (CharacterModel and GetBloodZoneMetalShieldTool ~= nil and GetBloodZoneMetalShieldTool(CharacterModel) ~= nil) or false
		ArmedBoolean = HeldItemStateTable and HeldItemStateTable.hasGun or (CharacterModel and HasEquippedGun ~= nil and HasEquippedGun(CharacterModel)) or false

		if CharacterModel and Humanoid and RootPartInstance then
			local HealthNumber = Humanoid.Health
			DeadBoolean = DeadBodyBoolean
				or (Humanoid.GetAttribute and Humanoid.GetAttribute(Humanoid, "Dead") == true)
				or (type(HealthNumber) == "number" and HealthNumber <= 0)
		end
	end

	if IsBloodZonePlaceBoolean and IsCurrentTargetBoolean then
		table.insert(StateTags, "TGT")
	end
	if PriorityBoolean then
		table.insert(StateTags, "P")
	end
	if WhitelistedBoolean then
		table.insert(StateTags, "W")
	end

	if IsBloodZonePlaceBoolean then
		if not CharacterModel or not CharacterModel.Parent then
			table.insert(StateTags, "NOCHAR")
		else
			if SafeBoolean then
				table.insert(StateTags, "SAFE")
			end
			if CarriedBoolean then
				table.insert(StateTags, "CARRY")
			end
			if EscapedBoolean then
				table.insert(StateTags, "ESC")
			end
			if DownedBoolean and not DeadBoolean then
				table.insert(StateTags, "DOWN")
			end
			if HasShieldBoolean then
				table.insert(StateTags, "SHLD")
			elseif ArmedBoolean then
				table.insert(StateTags, "GUN")
			end
		end
	end

	if IsBloodZonePlaceBoolean and IsCurrentTargetBoolean then
		BackgroundColor3 = Color3.fromRGB(140, 100, 0)
		TextColor3 = Color3.fromRGB(255, 245, 170)
	elseif PriorityBoolean then
		BackgroundColor3 = Color3.fromRGB(0, 110, 70)
	elseif WhitelistedBoolean then
		BackgroundColor3 = Color3.fromRGB(110, 45, 45)
		TextColor3 = Color3.fromRGB(255, 210, 210)
	elseif IsBloodZonePlaceBoolean and SafeBoolean then
		BackgroundColor3 = Color3.fromRGB(30, 65, 110)
		TextColor3 = Color3.fromRGB(210, 230, 255)
	elseif IsBloodZonePlaceBoolean and (DeadBoolean or CarriedBoolean or EscapedBoolean) then
		BackgroundColor3 = Color3.fromRGB(55, 55, 55)
		TextColor3 = Color3.fromRGB(190, 190, 190)
	elseif IsBloodZonePlaceBoolean and DownedBoolean then
		BackgroundColor3 = Color3.fromRGB(120, 80, 20)
		TextColor3 = Color3.fromRGB(255, 230, 180)
	elseif IsBloodZonePlaceBoolean and HasShieldBoolean then
		BackgroundColor3 = Color3.fromRGB(55, 70, 85)
		TextColor3 = Color3.fromRGB(225, 235, 255)
	elseif IsBloodZonePlaceBoolean and ArmedBoolean then
		BackgroundColor3 = Color3.fromRGB(45, 75, 45)
		TextColor3 = Color3.fromRGB(220, 255, 220)
	end

	local StateTable = {
		tags = StateTags,
		backgroundColor = BackgroundColor3,
		textColor = TextColor3,
	}
	if PlayerListRuntimeTable.entryStateCache then
		PlayerListRuntimeTable.entryStateCache[PlayerObject] = {
			time = NowNumber,
			character = CharacterModel,
			isCurrentTarget = IsCurrentTargetBoolean,
			isPriority = PriorityBoolean,
			isWhitelist = WhitelistedBoolean,
			state = StateTable,
		}
	end
	return StateTable
end

function PlayerListRuntimeTable.GetOrCreateEmptyLabel()
	local EmptyLabel = PlayerListRuntimeTable.emptyLabel
	if EmptyLabel and EmptyLabel.Parent then
		return EmptyLabel
	end

	EmptyLabel = Instance.new("TextLabel")
	EmptyLabel.Name = "EmptyLabel"
	EmptyLabel.Size = UDim2.new(1, -4, 0, 28)
	EmptyLabel.BackgroundTransparency = 1
	EmptyLabel.Text = "No other players"
	EmptyLabel.Font = Enum.Font.SourceSans
	EmptyLabel.TextSize = 15
	EmptyLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
	EmptyLabel.ZIndex = 102
	EmptyLabel.Visible = false
	EmptyLabel.Parent = PlayerListRuntimeTable.scrollFrame
	PlayerListRuntimeTable.emptyLabel = EmptyLabel
	return EmptyLabel
end

function PlayerListRuntimeTable.GetOrCreateEntryButton(PlayerObject)
	local EntryButton = PlayerListRuntimeTable.entryButtonsByPlayer[PlayerObject]
	if EntryButton and EntryButton.Parent then
		return EntryButton
	end

	EntryButton = Instance.new("TextButton")
	EntryButton.Name = "PlayerEntry_" .. tostring(PlayerObject.UserId)
	EntryButton.Size = UDim2.new(1, -4, 0, 32)
	EntryButton.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
	EntryButton.BorderSizePixel = 0
	EntryButton.AutoButtonColor = false
	EntryButton.Font = Enum.Font.SourceSans
	EntryButton.TextSize = 15
	EntryButton.TextXAlignment = Enum.TextXAlignment.Left
	EntryButton.Text = ""
	EntryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	EntryButton.ZIndex = 102
	EntryButton.Parent = PlayerListRuntimeTable.scrollFrame

	local NameLabel = Instance.new("TextLabel")
	NameLabel.Name = "NameLabel"
	NameLabel.Size = UDim2.new(1, -8, 0, 15)
	NameLabel.Position = UDim2.new(0, 4, 0, 1)
	NameLabel.BackgroundTransparency = 1
	NameLabel.Font = Enum.Font.SourceSans
	NameLabel.TextSize = 15
	NameLabel.TextXAlignment = Enum.TextXAlignment.Left
	NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	NameLabel.ZIndex = 103
	NameLabel.Parent = EntryButton

	local TagsLabel = Instance.new("TextLabel")
	TagsLabel.Name = "TagsLabel"
	TagsLabel.Size = UDim2.new(1, -8, 0, 13)
	TagsLabel.Position = UDim2.new(0, 4, 0, 16)
	TagsLabel.BackgroundTransparency = 1
	TagsLabel.Font = Enum.Font.Code
	TagsLabel.TextSize = 11
	TagsLabel.TextXAlignment = Enum.TextXAlignment.Left
	TagsLabel.TextTruncate = Enum.TextTruncate.AtEnd
	TagsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TagsLabel.ZIndex = 103
	TagsLabel.Parent = EntryButton

	EntryButton.MouseButton1Click.Connect(EntryButton.MouseButton1Click, function()
		if IsAimbotUiInputSuppressed() then
			return
		end
		if PlayerListRuntimeTable.IsPriorityPlayer(PlayerObject) then
			PlayerListRuntimeTable.priorityByPlayer[PlayerObject] = nil
			UpdateDebugStatus("priority target cleared=" .. PlayerObject.Name)
			DebugLog("priority-target", "Priority target cleared for " .. PlayerObject.Name, true)
		else
			PlayerListRuntimeTable.priorityByPlayer[PlayerObject] = true
			PlayerListRuntimeTable.whitelistByPlayer[PlayerObject] = nil
			UpdateDebugStatus("priority target=" .. PlayerObject.Name)
			DebugLog("priority-target", "Priority target set to " .. PlayerObject.Name, true)
		end

		InvalidateSearchableCharacterEntriesCache()
		PlayerListRuntimeTable.RefreshUi(true)
	end)

	EntryButton.MouseButton2Click.Connect(EntryButton.MouseButton2Click, function()
		if IsAimbotUiInputSuppressed() then
			return
		end
		local NextWhitelistedBoolean = not PlayerListRuntimeTable.IsPlayerWhitelisted(PlayerObject)
		PlayerListRuntimeTable.whitelistByPlayer[PlayerObject] = NextWhitelistedBoolean or nil
		if NextWhitelistedBoolean and PlayerListRuntimeTable.IsPriorityPlayer(PlayerObject) then
			PlayerListRuntimeTable.priorityByPlayer[PlayerObject] = nil
		end
		if NextWhitelistedBoolean then
			PlayerListRuntimeTable.ClearTrackedTargetForPlayer(PlayerObject)
		end

		UpdateDebugStatus("whitelist " .. PlayerObject.Name .. "=" .. tostring(NextWhitelistedBoolean))
		DebugLog("whitelist-target", "Whitelist for " .. PlayerObject.Name .. " set to " .. tostring(NextWhitelistedBoolean), true)
		InvalidateSearchableCharacterEntriesCache()
		PlayerListRuntimeTable.RefreshUi(true)
	end)

	PlayerListRuntimeTable.entryButtonsByPlayer[PlayerObject] = EntryButton
	return EntryButton
end

function PlayerListRuntimeTable.RefreshUi(ForceBoolean)
	local NowNumber = tick()
	if not ForceBoolean and (NowNumber - PlayerListRuntimeTable.lastRefreshTime) < PlayerListRuntimeTable.refreshInterval then
		return
	end
	PlayerListRuntimeTable.lastRefreshTime = NowNumber

	PlayerListRuntimeTable.CleanupTargetPreferences()

	local PlayerRowsTable = {}
	for _, PlayerObject in ipairs(Players.GetPlayers(Players)) do
		if PlayerObject ~= LocalPlayer then
			local CharacterModel = IsBloodZonePlaceBoolean and ResolveCharacterModelForPlayer(PlayerObject) or nil
			local IsCurrentTargetBoolean = CurrentTargetPlayerObject == PlayerObject
				or (IsBloodZonePlaceBoolean and CharacterModel ~= nil and CurrentTargetCharacterModel == CharacterModel)
			local DisplayNameString = PlayerListRuntimeTable.GetDisplayName(PlayerObject)
			PlayerRowsTable[#PlayerRowsTable + 1] = {
				player = PlayerObject,
				character = CharacterModel,
				displayName = DisplayNameString,
				displayNameLower = string.lower(DisplayNameString),
				isCurrentTarget = IsCurrentTargetBoolean,
				isPriority = PlayerListRuntimeTable.IsPriorityPlayer(PlayerObject),
				isWhitelist = PlayerListRuntimeTable.IsPlayerWhitelisted(PlayerObject),
				entryState = PlayerListRuntimeTable.GetEntryState(PlayerObject, CharacterModel, IsCurrentTargetBoolean),
			}
		end
	end

	table.sort(PlayerRowsTable, function(LeftEntryTable, RightEntryTable)
		if LeftEntryTable.isCurrentTarget ~= RightEntryTable.isCurrentTarget then
			return LeftEntryTable.isCurrentTarget
		end

		if LeftEntryTable.isPriority ~= RightEntryTable.isPriority then
			return LeftEntryTable.isPriority
		end

		if LeftEntryTable.isWhitelist ~= RightEntryTable.isWhitelist then
			return not LeftEntryTable.isWhitelist
		end

		return LeftEntryTable.displayNameLower < RightEntryTable.displayNameLower
	end)

	local ActivePlayersTable = {}
	if #PlayerRowsTable == 0 then
		PlayerListRuntimeTable.GetOrCreateEmptyLabel().Visible = true
	else
		local EmptyLabel = PlayerListRuntimeTable.emptyLabel
		if EmptyLabel then
			EmptyLabel.Visible = false
		end

		for LayoutOrderNumber, EntryTable in ipairs(PlayerRowsTable) do
			local PlayerObject = EntryTable.player
			ActivePlayersTable[PlayerObject] = true
			local EntryButton = PlayerListRuntimeTable.GetOrCreateEntryButton(PlayerObject)
			local EntryStateTable = EntryTable.entryState
			local DisplayNameString = EntryTable.displayName
			local NameLabel = EntryButton.FindFirstChild and EntryButton.FindFirstChild(EntryButton, "NameLabel") or nil
			local TagsLabel = EntryButton.FindFirstChild and EntryButton.FindFirstChild(EntryButton, "TagsLabel") or nil

			EntryButton.LayoutOrder = LayoutOrderNumber
			EntryButton.BackgroundColor3 = EntryStateTable.backgroundColor
			if NameLabel then
				NameLabel.TextColor3 = EntryStateTable.textColor
				NameLabel.Text = DisplayNameString
			end
			if TagsLabel then
				TagsLabel.TextColor3 = EntryStateTable.textColor
				TagsLabel.Visible = IsBloodZonePlaceBoolean or #EntryStateTable.tags > 0
				TagsLabel.Text = #EntryStateTable.tags > 0 and table.concat(EntryStateTable.tags, " ") or ""
			end
		end
	end

	local StalePlayersTable = {}
	for PlayerObject in pairs(PlayerListRuntimeTable.entryButtonsByPlayer) do
		if not ActivePlayersTable[PlayerObject] then
			table.insert(StalePlayersTable, PlayerObject)
		end
	end
	for _, PlayerObject in ipairs(StalePlayersTable) do
		local EntryButton = PlayerListRuntimeTable.entryButtonsByPlayer[PlayerObject]
		PlayerListRuntimeTable.entryButtonsByPlayer[PlayerObject] = nil
		if EntryButton and EntryButton.Parent then
			EntryButton.Destroy(EntryButton)
		end
	end

	local WhitelistCountNumber = 0
	for _, WhitelistedBoolean in pairs(PlayerListRuntimeTable.whitelistByPlayer) do
		if WhitelistedBoolean then
			WhitelistCountNumber = WhitelistCountNumber + 1
		end
	end

	local PriorityCountNumber = 0
	for _, PriorityBoolean in pairs(PlayerListRuntimeTable.priorityByPlayer) do
		if PriorityBoolean then
			PriorityCountNumber = PriorityCountNumber + 1
		end
	end
	PlayerListRuntimeTable.titleLabel.Text = "Players (" .. tostring(#PlayerRowsTable) .. ")"
	if IsBloodZonePlaceBoolean then
		PlayerListRuntimeTable.statusLabel.Text = "LMB: priority | RMB: whitelist\nP: " .. tostring(PriorityCountNumber) .. " | W: " .. tostring(WhitelistCountNumber) .. " | TGT SAFE DOWN SHLD GUN"
	else
		PlayerListRuntimeTable.statusLabel.Text = "LMB: priority | RMB: whitelist\nP: " .. tostring(PriorityCountNumber) .. " | W: " .. tostring(WhitelistCountNumber)
	end
	PlayerListRuntimeTable.scrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(#PlayerRowsTable * 34, 34))
end

Players.PlayerAdded.Connect(Players.PlayerAdded, function()
	PlayerListRuntimeTable.RefreshUi(true)
end)

Players.PlayerRemoving.Connect(Players.PlayerRemoving, function(PlayerObject)
	PlayerListRuntimeTable.whitelistByPlayer[PlayerObject] = nil
	PlayerListRuntimeTable.priorityByPlayer[PlayerObject] = nil
	PlayerListRuntimeTable.ClearTrackedTargetForPlayer(PlayerObject)
	ResolveCharacterModelCacheTable[PlayerObject] = nil
	PlayerListRuntimeTable.entryStateCache[PlayerObject] = nil
	InvalidateSearchableCharacterEntriesCache()
	PlayerListRuntimeTable.RefreshUi(true)
end)

local function IsLocalCharacterReadyForAimbot(CharacterModel)
	if not CharacterModel or not CharacterModel.Parent then
		return false
	end

	local Humanoid = GetCharacterHumanoid(CharacterModel)
	local RootPartInstance = GetCharacterRootPart(CharacterModel)
	if not Humanoid or not RootPartInstance then
		return false
	end

	if CharacterModel.GetAttribute(CharacterModel, "Carried") then
		return false
	end

	if CharacterModel.GetAttribute(CharacterModel, "Escaped") then
		return false
	end

	if CharacterModel.GetAttribute(CharacterModel, "Downed") then
		return false
	end

	if CharacterModel.GetAttribute(CharacterModel, "IsRagdolled") then
		return false
	end

	if CollectionService.HasTag(CollectionService, CharacterModel, "DeadBody") then
		return false
	end

	if Humanoid.GetAttribute and Humanoid.GetAttribute(Humanoid, "Dead") then
		return false
	end

	local HealthNumber = Humanoid.Health
	return type(HealthNumber) == "number" and HealthNumber > 0
end

local function HasEquippedTool(CharacterModel)
	if not CharacterModel then
		return false
	end

	for _, ChildInstance in ipairs(CharacterModel.GetChildren(CharacterModel)) do
		if ChildInstance.IsA(ChildInstance, "Tool") then
			return true
		end
	end

	if IsBloodZonePlaceBoolean then
		if ShieldModeRuntimeTable.GetEquippedGunTool and ShieldModeRuntimeTable.GetEquippedGunTool(CharacterModel) then
			return true
		end

		if CharacterModel.FindFirstChild and CharacterModel.FindFirstChild(CharacterModel, "GUN_CORE", true) then
			return true
		end
	end

	return false
end

HasEquippedGun = function(CharacterModel)
	if not CharacterModel then
		return false
	end

	if IsBloodZonePlaceBoolean and ShieldModeRuntimeTable.GetBloodZoneHeldItemState then
		local HeldItemStateTable = ShieldModeRuntimeTable.GetBloodZoneHeldItemState(CharacterModel)
		return HeldItemStateTable ~= nil and HeldItemStateTable.hasGun == true
	end

	if ShieldModeRuntimeTable.GetEquippedGunTool and ShieldModeRuntimeTable.GetEquippedGunTool(CharacterModel) then
		return true
	end

	if not IsBloodZonePlaceBoolean then
		return false
	end

	if CharacterModel.FindFirstChild and CharacterModel.FindFirstChild(CharacterModel, "GUN_CORE", true) then
		return true
	end

	local GetGunDataByNameFunction = ShieldModeRuntimeTable.GetGunDataByName
	for _, DescendantInstance in ipairs(CharacterModel.GetDescendants(CharacterModel)) do
		if DescendantInstance.IsA(DescendantInstance, "Tool") or DescendantInstance.IsA(DescendantInstance, "Model") then
			if DescendantInstance.Name ~= "Metal Shield"
				and GetGunDataByNameFunction
				and GetGunDataByNameFunction(DescendantInstance.Name) ~= nil then
				return true
			end
		elseif DescendantInstance.IsA(DescendantInstance, "BasePart") then
			if DescendantInstance.Name == "GUN_CORE" then
				return true
			end

			local TargetWeldParentName = DescendantInstance.GetAttribute and DescendantInstance.GetAttribute(DescendantInstance, "TargetWeldParent") or nil
			if type(TargetWeldParentName) == "string" and TargetWeldParentName ~= "" then
				local AncestorInstance = DescendantInstance.Parent
				while AncestorInstance and AncestorInstance ~= CharacterModel do
					if AncestorInstance.IsA(AncestorInstance, "Tool") or AncestorInstance.IsA(AncestorInstance, "Model") then
						if AncestorInstance.Name ~= "Metal Shield"
							and GetGunDataByNameFunction
							and GetGunDataByNameFunction(AncestorInstance.Name) ~= nil then
							return true
						end
					end
					AncestorInstance = AncestorInstance.Parent
				end
			end
		end
	end

	return false
end
