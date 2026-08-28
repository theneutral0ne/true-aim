local function IsGlassVisibilityPart(PartInstance)
	if not PartInstance then
		return false
	end

	local HitFunctionValue = PartInstance.GetAttribute and PartInstance.GetAttribute(PartInstance, "HitFunction") or nil
	return HitFunctionValue == "Glass"
end

local function CloneRaycastParamsWithIgnoredInstances(BaseRaycastParamsObject, ExtraIgnoredInstancesTable)
	local RaycastParamsObject = RaycastParams.new()
	if BaseRaycastParamsObject then
		RaycastParamsObject.FilterType = BaseRaycastParamsObject.FilterType
		RaycastParamsObject.IgnoreWater = BaseRaycastParamsObject.IgnoreWater
		pcall(function()
			RaycastParamsObject.CollisionGroup = BaseRaycastParamsObject.CollisionGroup
		end)
		pcall(function()
			RaycastParamsObject.RespectCanCollide = BaseRaycastParamsObject.RespectCanCollide
		end)
		pcall(function()
			RaycastParamsObject.BruteForceAllSlow = BaseRaycastParamsObject.BruteForceAllSlow
		end)
	else
		RaycastParamsObject.FilterType = Enum.RaycastFilterType.Blacklist
	end

	local FilterDescendantsInstances = {}
	local BaseIgnoredInstances = BaseRaycastParamsObject and BaseRaycastParamsObject.FilterDescendantsInstances or {}
	for _, IgnoredInstance in ipairs(BaseIgnoredInstances) do
		AppendUniqueIgnoredInstance(FilterDescendantsInstances, IgnoredInstance)
	end

	if ExtraIgnoredInstancesTable then
		for _, IgnoredInstance in ipairs(ExtraIgnoredInstancesTable) do
			AppendUniqueIgnoredInstance(FilterDescendantsInstances, IgnoredInstance)
		end
	end

	RaycastParamsObject.FilterDescendantsInstances = FilterDescendantsInstances
	return RaycastParamsObject
end

local function GetVisibilityRaycastBaseParams()
	if IsBloodZonePlaceBoolean and ShieldModeRuntimeTable.GetCurrentLocalGunRaycastParams then
		local LocalCharacterModel = ResolveCharacterModelForPlayer(LocalPlayer)
		local BaseRaycastParamsObject = ShieldModeRuntimeTable.GetCurrentLocalGunRaycastParams(LocalCharacterModel)
		if BaseRaycastParamsObject then
			return BaseRaycastParamsObject
		end
	end

	return VisibilityRaycastParams
end

local function CreateVisibilityRaycastParams(ExtraIgnoredInstancesTable)
	return CloneRaycastParamsWithIgnoredInstances(GetVisibilityRaycastBaseParams(), ExtraIgnoredInstancesTable)
end

local function DoesSegmentIntersectPartBounds(SegmentStartVector3, SegmentEndVector3, PartInstance)
	if not SegmentStartVector3 or not SegmentEndVector3 or not PartInstance then
		return false
	end

	local LocalStartVector3 = PartInstance.CFrame:PointToObjectSpace(SegmentStartVector3)
	local LocalEndVector3 = PartInstance.CFrame:PointToObjectSpace(SegmentEndVector3)
	local LocalDirectionVector3 = LocalEndVector3 - LocalStartVector3
	local HalfSizeVector3 = PartInstance.Size * 0.5
	local MinimumTimeNumber = 0
	local MaximumTimeNumber = 1
	local EpsilonNumber = 0.00001

	local function ClipAxis(StartCoordinateNumber, DirectionCoordinateNumber, HalfExtentNumber)
		if math.abs(DirectionCoordinateNumber) <= EpsilonNumber then
			return StartCoordinateNumber >= -HalfExtentNumber and StartCoordinateNumber <= HalfExtentNumber
		end

		local InverseDirectionNumber = 1 / DirectionCoordinateNumber
		local NearTimeNumber = (-HalfExtentNumber - StartCoordinateNumber) * InverseDirectionNumber
		local FarTimeNumber = (HalfExtentNumber - StartCoordinateNumber) * InverseDirectionNumber
		if NearTimeNumber > FarTimeNumber then
			NearTimeNumber, FarTimeNumber = FarTimeNumber, NearTimeNumber
		end

		MinimumTimeNumber = math.max(MinimumTimeNumber, NearTimeNumber)
		MaximumTimeNumber = math.min(MaximumTimeNumber, FarTimeNumber)
		return MaximumTimeNumber >= MinimumTimeNumber
	end

	if not ClipAxis(LocalStartVector3.X, LocalDirectionVector3.X, HalfSizeVector3.X) then
		return false
	end

	if not ClipAxis(LocalStartVector3.Y, LocalDirectionVector3.Y, HalfSizeVector3.Y) then
		return false
	end

	if not ClipAxis(LocalStartVector3.Z, LocalDirectionVector3.Z, HalfSizeVector3.Z) then
		return false
	end

	return MaximumTimeNumber >= 0 and MinimumTimeNumber <= 1
end

local function IsTargetPointBlockedByMetalShield(TargetPositionVector3, CharacterModel)
	if not IsBloodZonePlaceBoolean or not TargetPositionVector3 or not CharacterModel then
		return false
	end

	local MetalShieldTool = GetBloodZoneMetalShieldTool(CharacterModel)
	if not MetalShieldTool then
		return false
	end

	local VisibilityOriginVector3 = CurrentVisibilityOriginVector3 or Camera.CFrame.Position
	for _, DescendantInstance in ipairs(MetalShieldTool.GetDescendants(MetalShieldTool)) do
		if DescendantInstance.IsA(DescendantInstance, "BasePart")
			and DescendantInstance.Transparency < 0.95
			and DoesSegmentIntersectPartBounds(VisibilityOriginVector3, TargetPositionVector3, DescendantInstance) then
			return true
		end
	end

	return false
end

RaycastBetweenIgnoringGlass = function(OriginVector3, TargetPositionVector3, ExtraIgnoredInstancesTable)
	if not OriginVector3 or not TargetPositionVector3 then
		return nil
	end

	local FullDirectionVector3 = TargetPositionVector3 - OriginVector3
	local FullDistanceNumber = FullDirectionVector3.Magnitude
	if FullDistanceNumber <= 0.001 then
		return nil
	end

	local DirectionUnitVector3 = FullDirectionVector3.Unit
	local IgnoredInstancesTable = {}
	if ExtraIgnoredInstancesTable then
		for _, IgnoredInstance in ipairs(ExtraIgnoredInstancesTable) do
			AppendUniqueIgnoredInstance(IgnoredInstancesTable, IgnoredInstance)
		end
	end
	local CurrentOriginVector3 = OriginVector3
	local RemainingDistanceNumber = FullDistanceNumber

	for _ = 1, 16 do
		local RaycastResult = RunUnredirectedWorkspaceRaycast(
			CurrentOriginVector3,
			DirectionUnitVector3 * RemainingDistanceNumber,
			CreateVisibilityRaycastParams(IgnoredInstancesTable)
		)

		if not RaycastResult then
			return nil
		end

		if not IsGlassVisibilityPart(RaycastResult.Instance) then
			return RaycastResult
		end

		AppendUniqueIgnoredInstance(IgnoredInstancesTable, RaycastResult.Instance)
		CurrentOriginVector3 = RaycastResult.Position + DirectionUnitVector3 * 0.01
		RemainingDistanceNumber = FullDistanceNumber - (CurrentOriginVector3 - OriginVector3).Magnitude
		if RemainingDistanceNumber <= 0.001 then
			return nil
		end
	end

	return nil
end

local function RaycastToTargetIgnoringGlass(TargetPositionVector3)
	local OriginVector3 = CurrentVisibilityOriginVector3 or Camera.CFrame.Position
	return RaycastBetweenIgnoringGlass(OriginVector3, TargetPositionVector3, nil)
end

local function IsVisible(TargetPositionVector3, CharacterModel, PartInstance)
	if IsTargetPointBlockedByMetalShield(TargetPositionVector3, CharacterModel) then
		return false
	end

	local Result = RaycastToTargetIgnoringGlass(TargetPositionVector3)
	if not Result then
		return true
	end

	local HitTargetBoolean = false
	if PartInstance then
		HitTargetBoolean = Result.Instance == PartInstance or Result.Instance:IsDescendantOf(CharacterModel)
	else
		HitTargetBoolean = Result.Instance.IsDescendantOf(Result.Instance, CharacterModel)
	end
	if HitTargetBoolean then
		return true
	end

	if IsBloodZonePlaceBoolean
		and SillySkyVisibilityCheckEnabledBoolean
		and IsSillyModeBehaviorActive()
		and SillySkyAimEnabledBoolean
		and not ShieldModeEnabledBoolean
		and not ShieldModeRuntimeTable.IsProjectileWeaponProfile(CurrentWeaponBallisticsProfileTable) then
		local LocalCharacterModel = CurrentFrameLocalCharacterModel
		if CurrentFrameLocalCharacterReadyBoolean and LocalCharacterModel and LocalCharacterModel.Parent then
			local EquippedTool = ShieldModeRuntimeTable.GetEquippedTool and ShieldModeRuntimeTable.GetEquippedTool(LocalCharacterModel) or nil
			local SkyAimSolutionTable = ResolveSkyAimSolution(
				LocalCharacterModel,
				nil,
				EquippedTool,
				TargetPositionVector3,
				CharacterModel,
				PartInstance,
				true,
				3
			)
			if SkyAimSolutionTable and (SkyAimSolutionTable.priority or -1) >= 3 then
				return true
			end
		end
	end

	return false
end

IsCharacterForceFieldProtected = function(CharacterModel, Humanoid)
	if not CharacterModel then
		return false
	end

	if CharacterModel.GetAttribute(CharacterModel, "InSafeZone") then
		return true
	end

	if Humanoid and Humanoid.GetAttribute and Humanoid.GetAttribute(Humanoid, "InSafeZone") then
		return true
	end

	if CharacterModel.FindFirstChildWhichIsA then
		local ForceFieldInstance = CharacterModel.FindFirstChildWhichIsA(CharacterModel, "ForceField", true)
		if ForceFieldInstance then
			return true
		end
	end

	if CharacterModel.FindFirstChild(CharacterModel, "ForceField", true) then
		return true
	end

	if CharacterModel.FindFirstChild(CharacterModel, "ForceFieldPARTICLE", true) then
		return true
	end

	return false
end

local function IsCharacterAlive(CharacterModel)
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

	if CollectionService.HasTag(CollectionService, CharacterModel, "DeadBody") then
		return false
	end

	if Humanoid.GetAttribute and Humanoid.GetAttribute(Humanoid, "Dead") then
		return false
	end

	if IsCharacterForceFieldProtected(CharacterModel, Humanoid) then
		return false
	end

	if IsCustomCharacterGameBoolean then
		if CharacterModel.GetAttribute(CharacterModel, "Downed") then
			return true
		end

		if CharacterModel.GetAttribute(CharacterModel, "IsRagdolled") then
			return true
		end
	end

	local HealthNumber = Humanoid.Health
	if type(HealthNumber) == "number" then
		if HealthNumber > 0 then
			return true
		end

		return false
	end

	return false
end

local function GetProjectileArcVisibleTargetData(PartInstance, CharacterModel)
	local WeaponBallisticsProfileTable = CurrentWeaponBallisticsProfileTable
	if not ShouldUseProjectileArcVisibilityProfile(WeaponBallisticsProfileTable) then
		return nil
	end
	if not PartInstance or not PartInstance.Parent or not CharacterModel or not CharacterModel.Parent then
		return nil
	end

	local LocalCharacterModel = ResolveCharacterModelForPlayer(LocalPlayer)
	if not LocalCharacterModel or not LocalCharacterModel.Parent then
		return nil
	end

	local TargetPointVector3, PreferredTargetPartInstance = ResolveProjectileBaseTargetPointVector3(
		CharacterModel,
		PartInstance,
		PartInstance.Position,
		WeaponBallisticsProfileTable
	)
	if typeof(TargetPointVector3) ~= "Vector3" then
		return nil
	end
	if IsTargetPointBlockedByMetalShield(TargetPointVector3, CharacterModel) then
		return nil
	end

	local EffectivePartInstance = PreferredTargetPartInstance or PartInstance
	local AimSolutionTable = ResolveProjectileAimSolutionTable(
		LocalCharacterModel,
		CharacterModel,
		EffectivePartInstance,
		TargetPointVector3,
		WeaponBallisticsProfileTable,
		true
	)
	if not AimSolutionTable then
		return nil
	end

	return {
		point = AimSolutionTable.targetPoint or TargetPointVector3,
		cubeCFrame = EffectivePartInstance.CFrame,
		cubeSize = EffectivePartInstance.Size,
		part = EffectivePartInstance,
	}
end

local function GetVisiblePointForPart(PartInstance, CharacterModel, MouseLocationVector2)
	if not IsEffectiveTargetSegmentationEnabled() then
		local CenterPointVector3 = PartInstance.Position
		if not IsVisible(CenterPointVector3, CharacterModel, PartInstance) then
			return GetProjectileArcVisibleTargetData(PartInstance, CharacterModel)
		end
		return {
			point = CenterPointVector3,
			cubeCFrame = PartInstance.CFrame,
			cubeSize = PartInstance.Size,
		}
	end

	local CenterPointVector3 = PartInstance.Position
	if IsVisible(CenterPointVector3, CharacterModel, PartInstance) then
		return {
			point = CenterPointVector3,
			cubeCFrame = PartInstance.CFrame,
			cubeSize = PartInstance.Size,
		}
	end

	local ProjectileArcVisibleTargetData = GetProjectileArcVisibleTargetData(PartInstance, CharacterModel)
	if ProjectileArcVisibleTargetData then
		return ProjectileArcVisibleTargetData
	end

	local SubdivisionNumber = math.max(VisibleCheckSubdivisionsNumber, 1)
	local PartSize = PartInstance.Size
	local HalfSize = PartSize * 0.5
	local StepSize = Vector3.new(PartSize.X / SubdivisionNumber, PartSize.Y / SubdivisionNumber, PartSize.Z / SubdivisionNumber)
	local HalfStep = StepSize * 0.5
	local BestPointVector3 = nil
	local BestCubeCFrame = nil
	local BestCubeSize = nil
	local BestDistanceNumber = math.huge
	local Rotation = PartInstance.CFrame - PartInstance.CFrame.Position
	local ThicknessNumber = math.min(StepSize.X, StepSize.Y, StepSize.Z)

	local function EvaluateSurfacePoint(LocalPoint, LocalCenter, CellSize)
		local TargetPointVector3 = PartInstance.CFrame:PointToWorldSpace(LocalPoint)
		local ScreenPositionVector3, OnScreenBoolean = Camera.WorldToViewportPoint(Camera, TargetPointVector3)
		if not OnScreenBoolean then
			return
		end
		local ScreenPositionVector2 = Vector2.new(ScreenPositionVector3.X, ScreenPositionVector3.Y)
		local ScreenDistanceNumber = (ScreenPositionVector2 - MouseLocationVector2).Magnitude
		if ScreenDistanceNumber >= BestDistanceNumber then
			return
		end
		if not IsVisible(TargetPointVector3, CharacterModel, PartInstance) then
			return
		end
		BestDistanceNumber = ScreenDistanceNumber
		BestPointVector3 = TargetPointVector3
		BestCubeCFrame = CFrame.new(PartInstance.CFrame:PointToWorldSpace(LocalCenter)) * Rotation
		BestCubeSize = CellSize
	end

	for YIndex = 0, SubdivisionNumber - 1 do
		local YOffset = -HalfSize.Y + HalfStep.Y + StepSize.Y * YIndex
		for ZIndex = 0, SubdivisionNumber - 1 do
			local ZOffset = -HalfSize.Z + HalfStep.Z + StepSize.Z * ZIndex
			EvaluateSurfacePoint(
				Vector3.new(HalfSize.X, YOffset, ZOffset),
				Vector3.new(HalfSize.X - ThicknessNumber / 2, YOffset, ZOffset),
				Vector3.new(ThicknessNumber, StepSize.Y, StepSize.Z)
			)
			EvaluateSurfacePoint(
				Vector3.new(-HalfSize.X, YOffset, ZOffset),
				Vector3.new(-HalfSize.X + ThicknessNumber / 2, YOffset, ZOffset),
				Vector3.new(ThicknessNumber, StepSize.Y, StepSize.Z)
			)
		end
	end

	for XIndex = 0, SubdivisionNumber - 1 do
		local XOffset = -HalfSize.X + HalfStep.X + StepSize.X * XIndex
		for ZIndex = 0, SubdivisionNumber - 1 do
			local ZOffset = -HalfSize.Z + HalfStep.Z + StepSize.Z * ZIndex
			EvaluateSurfacePoint(
				Vector3.new(XOffset, HalfSize.Y, ZOffset),
				Vector3.new(XOffset, HalfSize.Y - ThicknessNumber / 2, ZOffset),
				Vector3.new(StepSize.X, ThicknessNumber, StepSize.Z)
			)
			EvaluateSurfacePoint(
				Vector3.new(XOffset, -HalfSize.Y, ZOffset),
				Vector3.new(XOffset, -HalfSize.Y + ThicknessNumber / 2, ZOffset),
				Vector3.new(StepSize.X, ThicknessNumber, StepSize.Z)
			)
		end
	end

	for XIndex = 0, SubdivisionNumber - 1 do
		local XOffset = -HalfSize.X + HalfStep.X + StepSize.X * XIndex
		for YIndex = 0, SubdivisionNumber - 1 do
			local YOffset = -HalfSize.Y + HalfStep.Y + StepSize.Y * YIndex
			EvaluateSurfacePoint(
				Vector3.new(XOffset, YOffset, HalfSize.Z),
				Vector3.new(XOffset, YOffset, HalfSize.Z - ThicknessNumber / 2),
				Vector3.new(StepSize.X, StepSize.Y, ThicknessNumber)
			)
			EvaluateSurfacePoint(
				Vector3.new(XOffset, YOffset, -HalfSize.Z),
				Vector3.new(XOffset, YOffset, -HalfSize.Z + ThicknessNumber / 2),
				Vector3.new(StepSize.X, StepSize.Y, ThicknessNumber)
			)
		end
	end

	if not BestPointVector3 then
		return nil
	end

	return {
		point = BestPointVector3,
		cubeCFrame = BestCubeCFrame,
		cubeSize = BestCubeSize,
	}
end

function ShieldModeRuntimeTable.RejectTargetDataForPart(ReasonKey, DebugKey, CharacterModel, PartInstance, MessageString)
	RecordRejectReason(ReasonKey)
	if DebugModeEnabledBoolean then
		DebugLog(DebugKey, "Rejected " .. GetTargetIdentity(nil, CharacterModel, PartInstance) .. " because " .. MessageString, false)
	end
	return nil
end

function ShieldModeRuntimeTable.ClampPointToPart(TargetPointVector3, ClampPartInstance)
	local HalfSize = ClampPartInstance.Size * 0.5
	local Inset = math.min(0.05, math.min(HalfSize.X, HalfSize.Y, HalfSize.Z) * 0.1)
	local LocalPointVector3 = ClampPartInstance.CFrame:PointToObjectSpace(TargetPointVector3)
	local ClampedLocalVector3 = Vector3.new(
		math.clamp(LocalPointVector3.X, -HalfSize.X + Inset, HalfSize.X - Inset),
		math.clamp(LocalPointVector3.Y, -HalfSize.Y + Inset, HalfSize.Y - Inset),
		math.clamp(LocalPointVector3.Z, -HalfSize.Z + Inset, HalfSize.Z - Inset)
	)
	return ClampPartInstance.CFrame:PointToWorldSpace(ClampedLocalVector3)
end

function ShieldModeRuntimeTable.ResolveEffectiveTargetGeometryForPart(PartInstance, CharacterModel, MouseLocationVector2)
	local TargetPointVector3 = PartInstance.Position
	local CubeCFrame = PartInstance.CFrame
	local CubeSize = PartInstance.Size
	local EffectivePartInstance = PartInstance

	if not IsEffectiveVisibleCheckEnabled() then
		return TargetPointVector3, CubeCFrame, CubeSize, EffectivePartInstance
	end

	local VisibleTargetData = GetVisiblePointForPart(PartInstance, CharacterModel, MouseLocationVector2)
	if not VisibleTargetData then
		return ShieldModeRuntimeTable.RejectTargetDataForPart(
			"visible",
			"reject-visible",
			CharacterModel,
			PartInstance,
			"visible check found no visible point"
		)
	end

	TargetPointVector3 = VisibleTargetData.point
	CubeCFrame = VisibleTargetData.cubeCFrame
	CubeSize = VisibleTargetData.cubeSize
	if VisibleTargetData.part and VisibleTargetData.part.Parent then
		EffectivePartInstance = VisibleTargetData.part
	end

	return TargetPointVector3, CubeCFrame, CubeSize, EffectivePartInstance
end

function ShieldModeRuntimeTable.BuildTargetDataForResolvedPoint(PartInstance, EffectivePartInstance, CharacterModel, MouseLocationVector2, IgnoreOffscreenBoolean, IgnoreFovForThisTargetBoolean, WorldDistanceNumber, TargetPointVector3, CubeCFrame, CubeSize)
	TargetPointVector3 = ShieldModeRuntimeTable.ClampPointToPart(TargetPointVector3, EffectivePartInstance)
	local LocalTargetPointVector3 = EffectivePartInstance.CFrame:PointToObjectSpace(TargetPointVector3)
	local ScreenPositionVector3, OnScreenBoolean = Camera.WorldToViewportPoint(Camera, TargetPointVector3)
	if not OnScreenBoolean and not IgnoreOffscreenBoolean then
		return ShieldModeRuntimeTable.RejectTargetDataForPart(
			"point_offscreen",
			"reject-point-offscreen",
			CharacterModel,
			PartInstance,
			"the final target point is off-screen"
		)
	end

	local ScreenPositionVector2 = nil
	local ScreenDistanceNumber = WorldDistanceNumber
	if OnScreenBoolean then
		ScreenPositionVector2 = Vector2.new(ScreenPositionVector3.X, ScreenPositionVector3.Y)
		ScreenDistanceNumber = (ScreenPositionVector2 - MouseLocationVector2).Magnitude
	end

	if not IgnoreFovForThisTargetBoolean and ScreenPositionVector2 and not IsPointInCircle(ScreenPositionVector2, MouseLocationVector2, FovCircle.Radius) then
		return ShieldModeRuntimeTable.RejectTargetDataForPart(
			"point_fov",
			"reject-point-fov",
			CharacterModel,
			PartInstance,
			"the final target point is outside the FOV circle"
		)
	end

	local SortDistanceNumber = ScreenDistanceNumber
	if IsSillyModeBehaviorActive() then
		local SortOriginVector3 = CurrentVisibilityOriginVector3 or Camera.CFrame.Position
		local SortReferencePartInstance = GetCharacterRootPart(CharacterModel) or PartInstance
		SortDistanceNumber = (SortReferencePartInstance.Position - SortOriginVector3).Magnitude
	end

	return {
		part = EffectivePartInstance,
		character = CharacterModel,
		point = TargetPointVector3,
		localPoint = LocalTargetPointVector3,
		cubeCFrame = CubeCFrame,
		cubeSize = CubeSize,
		screen = ScreenPositionVector2,
		screenDistance = ScreenDistanceNumber,
		sortDistance = SortDistanceNumber,
	}
end

function ShieldModeRuntimeTable.ComputeTargetDataForPart(PartInstance, CharacterModel, MouseLocationVector2, IgnoreFovBoolean)
	if not IsCharacterAlive(CharacterModel) then
		return ShieldModeRuntimeTable.RejectTargetDataForPart("dead", "reject-dead", CharacterModel, PartInstance, "the character is not alive")
	end

	local WorldDistanceNumber = (PartInstance.Position - Camera.CFrame.Position).Magnitude
	if WorldDistanceNumber > MaxDistanceNumber then
		return ShieldModeRuntimeTable.RejectTargetDataForPart(
			"distance",
			"reject-distance",
			CharacterModel,
			PartInstance,
			"distance " .. string.format("%.1f", WorldDistanceNumber) .. " is over max " .. tostring(MaxDistanceNumber)
		)
	end

	local IgnoreOffscreenBoolean = ShouldIgnoreOffscreenChecks()
	local IgnoreFovForThisTargetBoolean = ShouldIgnoreFovChecks(IgnoreFovBoolean)
	local ScreenPositionVector3, OnScreenBoolean = Camera.WorldToViewportPoint(Camera, PartInstance.Position)
	local ScreenDistanceNumber = WorldDistanceNumber

	if not OnScreenBoolean and not IgnoreOffscreenBoolean then
		return ShieldModeRuntimeTable.RejectTargetDataForPart("offscreen", "reject-offscreen", CharacterModel, PartInstance, "the part is off-screen")
	end

	if OnScreenBoolean then
		local ScreenPositionVector2 = Vector2.new(ScreenPositionVector3.X, ScreenPositionVector3.Y)
		ScreenDistanceNumber = (ScreenPositionVector2 - MouseLocationVector2).Magnitude
		if not IgnoreFovForThisTargetBoolean and ScreenDistanceNumber > FovCircle.Radius then
			return ShieldModeRuntimeTable.RejectTargetDataForPart(
				"fov",
				"reject-fov",
				CharacterModel,
				PartInstance,
				"screen distance " .. string.format("%.1f", ScreenDistanceNumber) .. " is outside FOV " .. tostring(FovCircle.Radius)
			)
		end
	end

	local TargetPointVector3, CubeCFrame, CubeSize, EffectivePartInstance = ShieldModeRuntimeTable.ResolveEffectiveTargetGeometryForPart(
		PartInstance,
		CharacterModel,
		MouseLocationVector2
	)
	if not TargetPointVector3 then
		return nil
	end

	return ShieldModeRuntimeTable.BuildTargetDataForResolvedPoint(
		PartInstance,
		EffectivePartInstance,
		CharacterModel,
		MouseLocationVector2,
		IgnoreOffscreenBoolean,
		IgnoreFovForThisTargetBoolean,
		WorldDistanceNumber,
		TargetPointVector3,
		CubeCFrame,
		CubeSize
	)
end

function ShieldModeRuntimeTable.GetTargetDataForPart(PartInstance, CharacterModel, MouseLocationVector2, IgnoreFovBoolean)
	if not PartInstance then
		return nil
	end

	local CacheTable = IgnoreFovBoolean and FrameTargetDataCacheTable.ignoreFov or FrameTargetDataCacheTable.normal
	local CachedValue = CacheTable[PartInstance]
	if CachedValue ~= nil then
		return CachedValue or nil
	end

	local TargetData = ShieldModeRuntimeTable.ComputeTargetDataForPart(PartInstance, CharacterModel, MouseLocationVector2, IgnoreFovBoolean)
	CacheTable[PartInstance] = TargetData or false
	return TargetData
end

function ShieldModeRuntimeTable.GetBestTargetForCharacter(CharacterModel, MouseLocationVector2)
	local ClosestDistanceNumber = math.huge
	local ClosestTargetData = nil

	local ClosestHeadDistanceNumber = math.huge
	local ClosestHeadTargetData = nil

	for _, PartInstance in ipairs(GetTargetableParts(CharacterModel)) do
		local TargetData = ShieldModeRuntimeTable.GetTargetDataForPart(PartInstance, CharacterModel, MouseLocationVector2)
		if not TargetData then
			continue
		end

		local PartNameLowerString = string.lower(PartInstance.Name)
		local IsHeadBoolean = string.find(PartNameLowerString, "head") ~= nil
		local TargetSortDistanceNumber = GetTargetSortDistance(TargetData)
		if IsHeadBoolean and TargetSortDistanceNumber < ClosestHeadDistanceNumber then
			ClosestHeadDistanceNumber = TargetSortDistanceNumber
			ClosestHeadTargetData = TargetData
		end

		if TargetSortDistanceNumber < ClosestDistanceNumber then
			ClosestDistanceNumber = TargetSortDistanceNumber
			ClosestTargetData = TargetData
		end
	end

	if IsEffectiveHeadshotPriorityEnabled() and ClosestHeadTargetData then
		return ClosestHeadTargetData
	end

	return ClosestTargetData
end

function ShieldModeRuntimeTable.CreateTargetSelectionSlot()
	return {
		distance = math.huge,
	}
end

function ShieldModeRuntimeTable.UpdateTargetSelectionSlot(SelectionSlotTable, TargetData, PlayerObject, DistanceNumber)
	if not SelectionSlotTable or not TargetData or DistanceNumber >= SelectionSlotTable.distance then
		return
	end

	SelectionSlotTable.distance = DistanceNumber
	SelectionSlotTable.screen = TargetData.screen
	SelectionSlotTable.part = TargetData.part
	SelectionSlotTable.character = TargetData.character
	SelectionSlotTable.player = PlayerObject
	SelectionSlotTable.point = TargetData.point
	SelectionSlotTable.localPoint = TargetData.localPoint
	SelectionSlotTable.cubeCFrame = TargetData.cubeCFrame
	SelectionSlotTable.cubeSize = TargetData.cubeSize
end

function ShieldModeRuntimeTable.ReadTargetSelectionSlot(SelectionSlotTable, IsAimingThreatBoolean)
	if not SelectionSlotTable or not SelectionSlotTable.part then
		return nil
	end

	return {
		distance = SelectionSlotTable.distance,
		screen = SelectionSlotTable.screen,
		part = SelectionSlotTable.part,
		character = SelectionSlotTable.character,
		player = SelectionSlotTable.player,
		point = SelectionSlotTable.point,
		localPoint = SelectionSlotTable.localPoint,
		cubeCFrame = SelectionSlotTable.cubeCFrame,
		cubeSize = SelectionSlotTable.cubeSize,
		isAimingThreat = IsAimingThreatBoolean == true,
	}
end

function ShieldModeRuntimeTable.BuildFallbackIndicatorData(TargetData, PlayerObject)
	if not TargetData then
		return nil
	end

	return {
		distance = TargetData.screenDistance,
		screen = TargetData.screen,
		part = TargetData.part,
		character = TargetData.character,
		player = PlayerObject,
		point = TargetData.point,
		localPoint = TargetData.localPoint,
		cubeCFrame = TargetData.cubeCFrame,
		cubeSize = TargetData.cubeSize,
	}
end

function ShieldModeRuntimeTable.RunTargetSearch(LocalCharacterModel, MouseLocationVector2, TeamCheckEnabledBoolean, LocalTeamObject, ShowTargetLineBoolean)
	local SearchResultTable = {
		candidate = nil,
		fallbackIndicator = nil,
		liveCharacterCount = 0,
		totalTargetablePartCount = 0,
		preferredAimingThreatCharacter = nil,
		preferredAimingThreatScore = nil,
	}

	local ClosestSelectionSlotTable = ShieldModeRuntimeTable.CreateTargetSelectionSlot()
	local ClosestHeadSelectionSlotTable = ShieldModeRuntimeTable.CreateTargetSelectionSlot()
	local ClosestPrioritySelectionSlotTable = ShieldModeRuntimeTable.CreateTargetSelectionSlot()
	local ClosestPriorityHeadSelectionSlotTable = ShieldModeRuntimeTable.CreateTargetSelectionSlot()
	local ClosestAimingThreatSelectionSlotTable = ShieldModeRuntimeTable.CreateTargetSelectionSlot()
	local ClosestAimingThreatHeadSelectionSlotTable = ShieldModeRuntimeTable.CreateTargetSelectionSlot()

	if IsSillyModeBehaviorActive() and ShieldModeRuntimeTable.ResolveAimingThreatData then
		local PreferredAimingThreatData = ShieldModeRuntimeTable.ResolveAimingThreatData(LocalCharacterModel)
		if PreferredAimingThreatData and PreferredAimingThreatData.character then
			SearchResultTable.preferredAimingThreatCharacter = PreferredAimingThreatData.character
			SearchResultTable.preferredAimingThreatScore = PreferredAimingThreatData.score
		end
	end

	local CharacterEntries = GetSearchableCharacterEntries(LocalCharacterModel, TeamCheckEnabledBoolean, LocalTeamObject)
	for _, CharacterEntry in ipairs(CharacterEntries) do
		local PlayerObject = CharacterEntry.player
		local CharacterModel = CharacterEntry.character
		if not IsCharacterAlive(CharacterModel) then
			continue
		end
		SearchResultTable.liveCharacterCount = SearchResultTable.liveCharacterCount + 1

		local TargetableParts = GetTargetableParts(CharacterModel)
		SearchResultTable.totalTargetablePartCount = SearchResultTable.totalTargetablePartCount + #TargetableParts
		if #TargetableParts == 0 then
			DebugLog("no-parts-" .. CharacterModel.Name, "Found no targetable parts for " .. CharacterModel.Name, false)
		end

		for _, PartInstance in ipairs(TargetableParts) do
			local TargetData = ShieldModeRuntimeTable.GetTargetDataForPart(PartInstance, CharacterModel, MouseLocationVector2)
			local FallbackTargetData = nil
			if not TargetData and ShowTargetLineBoolean then
				FallbackTargetData = ShieldModeRuntimeTable.GetTargetDataForPart(PartInstance, CharacterModel, MouseLocationVector2, true)
			end

			if FallbackTargetData then
				local FallbackDistanceNumber = FallbackTargetData.screenDistance or math.huge
				local CurrentFallbackDistanceNumber = SearchResultTable.fallbackIndicator and SearchResultTable.fallbackIndicator.distance or math.huge
				if FallbackDistanceNumber < CurrentFallbackDistanceNumber then
					SearchResultTable.fallbackIndicator = ShieldModeRuntimeTable.BuildFallbackIndicatorData(FallbackTargetData, PlayerObject)
				end
			end

			if not TargetData then
				continue
			end

			local PartNameLowerString = string.lower(PartInstance.Name)
			local IsHeadBoolean = string.find(PartNameLowerString, "head") ~= nil
			local TargetSortDistanceNumber = GetTargetSortDistance(TargetData)
			local PriorityPlayerBoolean = PlayerListRuntimeTable.IsPriorityPlayer(PlayerObject)
			local AimingThreatCharacterBoolean = SearchResultTable.preferredAimingThreatCharacter ~= nil
				and CharacterModel == SearchResultTable.preferredAimingThreatCharacter

			if AimingThreatCharacterBoolean then
				if IsHeadBoolean then
					ShieldModeRuntimeTable.UpdateTargetSelectionSlot(ClosestAimingThreatHeadSelectionSlotTable, TargetData, PlayerObject, TargetSortDistanceNumber)
				else
					ShieldModeRuntimeTable.UpdateTargetSelectionSlot(ClosestAimingThreatSelectionSlotTable, TargetData, PlayerObject, TargetSortDistanceNumber)
				end
			end

			if IsHeadBoolean then
				if PriorityPlayerBoolean then
					ShieldModeRuntimeTable.UpdateTargetSelectionSlot(ClosestPriorityHeadSelectionSlotTable, TargetData, PlayerObject, TargetSortDistanceNumber)
				else
					ShieldModeRuntimeTable.UpdateTargetSelectionSlot(ClosestHeadSelectionSlotTable, TargetData, PlayerObject, TargetSortDistanceNumber)
				end
			end

			if PriorityPlayerBoolean then
				ShieldModeRuntimeTable.UpdateTargetSelectionSlot(ClosestPrioritySelectionSlotTable, TargetData, PlayerObject, TargetSortDistanceNumber)
			else
				ShieldModeRuntimeTable.UpdateTargetSelectionSlot(ClosestSelectionSlotTable, TargetData, PlayerObject, TargetSortDistanceNumber)
			end
		end
	end

	if not IsSillyModeBehaviorActive() then
		if IsEffectiveHeadshotPriorityEnabled() then
			SearchResultTable.candidate = ShieldModeRuntimeTable.ReadTargetSelectionSlot(ClosestHeadSelectionSlotTable, false)
		end
		if not SearchResultTable.candidate then
			SearchResultTable.candidate = ShieldModeRuntimeTable.ReadTargetSelectionSlot(ClosestSelectionSlotTable, false)
		end
		return SearchResultTable
	end

	if IsEffectiveHeadshotPriorityEnabled() then
		SearchResultTable.candidate = ShieldModeRuntimeTable.ReadTargetSelectionSlot(ClosestAimingThreatHeadSelectionSlotTable, true)
	end
	if not SearchResultTable.candidate then
		SearchResultTable.candidate = ShieldModeRuntimeTable.ReadTargetSelectionSlot(ClosestAimingThreatSelectionSlotTable, true)
	end
	if not SearchResultTable.candidate and IsEffectiveHeadshotPriorityEnabled() then
		SearchResultTable.candidate = ShieldModeRuntimeTable.ReadTargetSelectionSlot(ClosestPriorityHeadSelectionSlotTable, false)
	end
	if not SearchResultTable.candidate then
		SearchResultTable.candidate = ShieldModeRuntimeTable.ReadTargetSelectionSlot(ClosestPrioritySelectionSlotTable, false)
	end
	if not SearchResultTable.candidate and IsEffectiveHeadshotPriorityEnabled() then
		SearchResultTable.candidate = ShieldModeRuntimeTable.ReadTargetSelectionSlot(ClosestHeadSelectionSlotTable, false)
	end
	if not SearchResultTable.candidate then
		SearchResultTable.candidate = ShieldModeRuntimeTable.ReadTargetSelectionSlot(ClosestSelectionSlotTable, false)
	end

	return SearchResultTable
end

function ShieldModeRuntimeTable.IsLockKeyHeld()
	if IsSillyModeBehaviorActive() then
		return true
	end

	local LockKeyModeString = GetCurrentLockKeyMode()
	if LockKeyModeString == "Always" then
		return true
	elseif LockKeyModeString == "E" then
		return UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.E)
	else
		return UserInputService.IsMouseButtonPressed(UserInputService, Enum.UserInputType.MouseButton2)
	end
end

function ShieldModeRuntimeTable.ShouldRedirectTowardCurrentTarget(LocalCharacterModel)
	if not LocalCharacterModel
		or not IsLocalCharacterReadyForAimbot(LocalCharacterModel)
		or not CurrentTargetPartInstance
		or not CurrentTargetCharacterModel
		or not CurrentTargetPartInstance.Parent
		or not IsCharacterAlive(CurrentTargetCharacterModel) then
		return false
	end

	if AimbotRequireRmbBoolean and not ShieldModeRuntimeTable.IsLockKeyHeld() then
		return false
	end

	return true
end

function ShieldModeRuntimeTable.IsHookOnlyMethodEnabled()
	return IsEffectiveHookMethodEnabled() and not IsEffectiveCameraMethodEnabled()
end

function ShieldModeRuntimeTable.GetFireGunMuzzleRedirect(ActiveFiringLocalGunTable, TargetPositionVector3, FallbackOriginVector3, DirectionMagnitudeNumber)
	if type(ActiveFiringLocalGunTable) ~= "table"
		or typeof(TargetPositionVector3) ~= "Vector3"
		or typeof(FallbackOriginVector3) ~= "Vector3"
		or type(DirectionMagnitudeNumber) ~= "number"
		or DirectionMagnitudeNumber <= 0.001 then
		return nil, nil
	end

	local MuzzleOriginVector3 = GetLocalGunTipWorldPosition(ActiveFiringLocalGunTable) or FallbackOriginVector3
	local RedirectDirectionVector3 = TargetPositionVector3 - MuzzleOriginVector3
	if RedirectDirectionVector3.Magnitude <= 0.001 then
		return nil, nil
	end

	return MuzzleOriginVector3, RedirectDirectionVector3.Unit * DirectionMagnitudeNumber
end

function ShieldModeRuntimeTable.ShouldSkipBloodZoneProjectileRaycastRedirect(LocalCharacterModel, RaycastParamsObject)
	if not IsBloodZonePlaceBoolean or not RaycastParamsObject then
		return false
	end

	local WeaponBallisticsProfileTable = CurrentWeaponBallisticsProfileTable
		or ShieldModeRuntimeTable.ResolveCurrentWeaponBallisticsProfile(LocalCharacterModel)
	if not ShieldModeRuntimeTable.IsProjectileWeaponProfile(WeaponBallisticsProfileTable) then
		return false
	end

	local ActiveLocalGunTable = WeaponBallisticsProfileTable and WeaponBallisticsProfileTable.localGun or nil
	if type(ActiveLocalGunTable) ~= "table" then
		ActiveLocalGunTable = ShieldModeRuntimeTable.ResolveCurrentLocalGun(LocalCharacterModel)
	end

	local ProjectileRaycastParamsObject = ActiveLocalGunTable and ActiveLocalGunTable.RayParams or nil
	return ProjectileRaycastParamsObject ~= nil and RaycastParamsObject == ProjectileRaycastParamsObject
end
