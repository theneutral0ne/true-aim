local function GetBloodZoneMetalShieldTool(CharacterModel)
	if not IsBloodZonePlaceBoolean or not CharacterModel then
		return nil
	end

	if ShieldModeRuntimeTable.GetBloodZoneHeldItemState then
		local HeldItemStateTable = ShieldModeRuntimeTable.GetBloodZoneHeldItemState(CharacterModel)
		if HeldItemStateTable and HeldItemStateTable.shieldInstance then
			return HeldItemStateTable.shieldInstance
		end
	end

	for _, ChildInstance in ipairs(CharacterModel.GetChildren(CharacterModel)) do
		if ChildInstance.IsA(ChildInstance, "Tool") and ChildInstance.Name == "Metal Shield" then
			return ChildInstance
		end
	end

	local DescendantTool = CharacterModel.FindFirstChild and CharacterModel.FindFirstChild(CharacterModel, "Metal Shield", true) or nil
	if DescendantTool and DescendantTool.IsA and DescendantTool.IsA(DescendantTool, "Tool") then
		return DescendantTool
	end

	return nil
end

function ShieldModeRuntimeTable.ResolveWeaponClientModule()
	if not IsBloodZonePlaceBoolean then
		return nil
	end

	if ShieldModeRuntimeTable.weaponClientModule then
		return ShieldModeRuntimeTable.weaponClientModule
	end

	local ModulesFolder = ReplicatedStorageService and ReplicatedStorageService.FindFirstChild(ReplicatedStorageService, "Modules") or nil
	local ClientFolder = ModulesFolder and ModulesFolder.FindFirstChild(ModulesFolder, "Client") or nil
	local GameFolder = ClientFolder and ClientFolder.FindFirstChild(ClientFolder, "Game") or nil
	local WeaponClientModuleScript = GameFolder and GameFolder.FindFirstChild(GameFolder, "WeaponClient") or nil
	if not WeaponClientModuleScript then
		return nil
	end

	local SuccessBoolean, ModuleTable = pcall(require, WeaponClientModuleScript)
	if not SuccessBoolean or type(ModuleTable) ~= "table" then
		return nil
	end

	ShieldModeRuntimeTable.weaponClientModule = ModuleTable
	return ModuleTable
end

function ShieldModeRuntimeTable.ResolveClientProjectilesModule()
	if not IsBloodZonePlaceBoolean then
		return nil
	end

	if ShieldModeRuntimeTable.clientProjectilesModule then
		return ShieldModeRuntimeTable.clientProjectilesModule
	end

	local ModulesFolder = ReplicatedStorageService and ReplicatedStorageService.FindFirstChild(ReplicatedStorageService, "Modules") or nil
	local ClientFolder = ModulesFolder and ModulesFolder.FindFirstChild(ModulesFolder, "Client") or nil
	local GameFolder = ClientFolder and ClientFolder.FindFirstChild(ClientFolder, "Game") or nil
	local WeaponClientModuleScript = GameFolder and GameFolder.FindFirstChild(GameFolder, "WeaponClient") or nil
	local ClientProjectilesModuleScript = WeaponClientModuleScript and WeaponClientModuleScript.FindFirstChild(WeaponClientModuleScript, "ClientProjectiles") or nil
	if not ClientProjectilesModuleScript then
		return nil
	end

	local SuccessBoolean, ModuleTable = pcall(require, ClientProjectilesModuleScript)
	if not SuccessBoolean or type(ModuleTable) ~= "table" then
		return nil
	end

	ShieldModeRuntimeTable.clientProjectilesModule = ModuleTable
	return ModuleTable
end

function ShieldModeRuntimeTable.ResolveCurrentLocalGun(LocalCharacterModel)
	local FrameIdNumber = tonumber(CurrentFrameSequenceNumber) or 0
	local EquippedGunToolInstance = ShieldModeRuntimeTable.GetEquippedGunTool
		and ShieldModeRuntimeTable.GetEquippedGunTool(LocalCharacterModel) or nil
	if ShieldModeRuntimeTable.currentLocalGunResolved
		and ShieldModeRuntimeTable.currentLocalGunFrameId == FrameIdNumber
		and ShieldModeRuntimeTable.currentLocalGunCharacter == LocalCharacterModel
		and ShieldModeRuntimeTable.currentLocalGunTool == EquippedGunToolInstance then
		return ShieldModeRuntimeTable.activeLocalGun
	end

	local function FinalizeResolvedLocalGun(ResolvedLocalGunTable)
		local PreviousLocalGunTable = ShieldModeRuntimeTable.activeLocalGun
		ShieldModeRuntimeTable.activeLocalGun = ResolvedLocalGunTable
		ShieldModeRuntimeTable.currentLocalGunFrameId = FrameIdNumber
		ShieldModeRuntimeTable.currentLocalGunCharacter = LocalCharacterModel
		ShieldModeRuntimeTable.currentLocalGunTool = EquippedGunToolInstance
		ShieldModeRuntimeTable.currentLocalGunResolved = true
		if PreviousLocalGunTable ~= ResolvedLocalGunTable then
			ShieldModeRuntimeTable.currentLocalGunMuzzleOriginFrameId = 0
			ShieldModeRuntimeTable.currentLocalGunMuzzleOriginValue = nil
			ShieldModeRuntimeTable.currentLocalGunRaycastParamsFrameId = 0
			ShieldModeRuntimeTable.currentLocalGunRaycastParamsValue = nil
			ShieldModeRuntimeTable.currentLocalGunCheckParamsFrameId = 0
			ShieldModeRuntimeTable.currentLocalGunCheckParamsValue = nil
			ShieldModeRuntimeTable.currentWeaponBallisticsProfileFrameId = 0
			ShieldModeRuntimeTable.currentWeaponBallisticsProfileCharacter = nil
			ShieldModeRuntimeTable.currentWeaponBallisticsProfileLocalGun = nil
			ShieldModeRuntimeTable.currentWeaponBallisticsProfileValue = nil
		end
		return ResolvedLocalGunTable
	end

	if not IsBloodZonePlaceBoolean or not LocalCharacterModel or not LocalCharacterModel.Parent then
		return FinalizeResolvedLocalGun(nil)
	end

	local ActiveLocalGunTable = ShieldModeRuntimeTable.activeLocalGun
	if type(ActiveLocalGunTable) == "table"
		and type(ActiveLocalGunTable.GetBase) == "function"
		and type(ActiveLocalGunTable.Settings) == "table"
		and IsSupportedBloodZoneWeaponType(ActiveLocalGunTable.Settings.WeaponType)
		and ActiveLocalGunTable.CharacterModel == LocalCharacterModel
		and ActiveLocalGunTable.Equipped
		and ActiveLocalGunTable.Tool == EquippedGunToolInstance then
		return FinalizeResolvedLocalGun(ActiveLocalGunTable)
	end

	local WeaponClientModuleTable = ShieldModeRuntimeTable.ResolveWeaponClientModule()
	local LoadedWeaponsTable = WeaponClientModuleTable and WeaponClientModuleTable.LoadedWeapons or nil
	if type(LoadedWeaponsTable) ~= "table" then
		return FinalizeResolvedLocalGun(nil)
	end

	if EquippedGunToolInstance then
		for _, LoadedWeaponTable in pairs(LoadedWeaponsTable) do
			if type(LoadedWeaponTable) == "table"
				and LoadedWeaponTable.Tool == EquippedGunToolInstance
				and type(LoadedWeaponTable.GetBase) == "function"
				and type(LoadedWeaponTable.Settings) == "table"
				and IsSupportedBloodZoneWeaponType(LoadedWeaponTable.Settings.WeaponType) then
				return FinalizeResolvedLocalGun(LoadedWeaponTable)
			end
		end
	end

	local FallbackLocalGunTable = nil
	for _, LoadedWeaponTable in pairs(LoadedWeaponsTable) do
		local GunToolInstance = LoadedWeaponTable and LoadedWeaponTable.Tool or nil
		local GunSettingsTable = LoadedWeaponTable and LoadedWeaponTable.Settings or nil
		local GunCharacterModel = LoadedWeaponTable and LoadedWeaponTable.CharacterModel or nil
		local GunEquippedBoolean = LoadedWeaponTable and LoadedWeaponTable.Equipped or false
		local GunMatchesCharacterBoolean = GunCharacterModel == LocalCharacterModel
			or (GunToolInstance and GunToolInstance.IsDescendantOf and GunToolInstance.IsDescendantOf(GunToolInstance, LocalCharacterModel))
		if type(LoadedWeaponTable) == "table"
			and GunMatchesCharacterBoolean
			and type(LoadedWeaponTable.GetBase) == "function"
			and type(GunSettingsTable) == "table"
			and IsSupportedBloodZoneWeaponType(GunSettingsTable.WeaponType) then
			if GunEquippedBoolean then
				return FinalizeResolvedLocalGun(LoadedWeaponTable)
			end

			if not FallbackLocalGunTable then
				FallbackLocalGunTable = LoadedWeaponTable
			end
		end
	end

	if FallbackLocalGunTable then
		return FinalizeResolvedLocalGun(FallbackLocalGunTable)
	end

	return FinalizeResolvedLocalGun(nil)
end

local function GetLocalGunTipWorldPosition(LocalGunTable)
	if type(LocalGunTable) ~= "table" then
		return nil
	end

	local CurrentBaseInstance = SafeGetLocalGunBase(LocalGunTable)
	if not CurrentBaseInstance then
		return nil
	end

	local TipInstance = CurrentBaseInstance and CurrentBaseInstance.FindFirstChild and CurrentBaseInstance.FindFirstChild(CurrentBaseInstance, "Tip") or nil
	if TipInstance and TipInstance.Parent then
		if TipInstance.IsA and TipInstance.IsA(TipInstance, "Attachment") then
			local SuccessBoolean, TipWorldPositionVector3 = pcall(function()
				return TipInstance.WorldPosition
			end)
			if SuccessBoolean and typeof(TipWorldPositionVector3) == "Vector3" then
				return TipWorldPositionVector3
			end
		end
		if TipInstance.IsA and TipInstance.IsA(TipInstance, "BasePart") then
			return TipInstance.Position
		end
	end

	local FallbackTipInstance = LocalGunTable.Tip
	if FallbackTipInstance and FallbackTipInstance.Parent then
		if FallbackTipInstance.IsA and FallbackTipInstance.IsA(FallbackTipInstance, "Attachment") then
			local SuccessBoolean, TipWorldPositionVector3 = pcall(function()
				return FallbackTipInstance.WorldPosition
			end)
			if SuccessBoolean and typeof(TipWorldPositionVector3) == "Vector3" then
				return TipWorldPositionVector3
			end
		end
		if FallbackTipInstance.IsA and FallbackTipInstance.IsA(FallbackTipInstance, "BasePart") then
			return FallbackTipInstance.Position
		end
	end

	return nil
end

function ShieldModeRuntimeTable.GetCurrentLocalGunMuzzleOrigin(LocalCharacterModel)
	local FrameIdNumber = tonumber(CurrentFrameSequenceNumber) or 0
	local ActiveLocalGunTable = ShieldModeRuntimeTable.ResolveCurrentLocalGun(LocalCharacterModel)
	if ShieldModeRuntimeTable.currentLocalGunMuzzleOriginFrameId == FrameIdNumber
		and ShieldModeRuntimeTable.currentLocalGunCharacter == LocalCharacterModel
		and ShieldModeRuntimeTable.activeLocalGun == ActiveLocalGunTable then
		return ShieldModeRuntimeTable.currentLocalGunMuzzleOriginValue
	end

	if not ActiveLocalGunTable then
		ShieldModeRuntimeTable.currentLocalGunMuzzleOriginFrameId = FrameIdNumber
		ShieldModeRuntimeTable.currentLocalGunMuzzleOriginValue = nil
		return nil
	end

	local MuzzleOriginVector3 = GetLocalGunTipWorldPosition(ActiveLocalGunTable)
	ShieldModeRuntimeTable.currentLocalGunMuzzleOriginFrameId = FrameIdNumber
	ShieldModeRuntimeTable.currentLocalGunMuzzleOriginValue = MuzzleOriginVector3
	return MuzzleOriginVector3
end

function ShieldModeRuntimeTable.GetCurrentLocalGunRaycastParams(LocalCharacterModel)
	local FrameIdNumber = tonumber(CurrentFrameSequenceNumber) or 0
	local ActiveLocalGunTable = ShieldModeRuntimeTable.ResolveCurrentLocalGun(LocalCharacterModel)
	if ShieldModeRuntimeTable.currentLocalGunRaycastParamsFrameId == FrameIdNumber
		and ShieldModeRuntimeTable.currentLocalGunCharacter == LocalCharacterModel
		and ShieldModeRuntimeTable.activeLocalGun == ActiveLocalGunTable then
		return ShieldModeRuntimeTable.currentLocalGunRaycastParamsValue
	end

	local RayParamsObject = ActiveLocalGunTable and ActiveLocalGunTable.RayParams or nil
	local FinalRaycastParamsObject = RayParamsObject or VisibilityRaycastParams
	ShieldModeRuntimeTable.currentLocalGunRaycastParamsFrameId = FrameIdNumber
	ShieldModeRuntimeTable.currentLocalGunRaycastParamsValue = FinalRaycastParamsObject
	return FinalRaycastParamsObject
end

function ShieldModeRuntimeTable.GetCurrentLocalGunCheckParams(LocalCharacterModel)
	local FrameIdNumber = tonumber(CurrentFrameSequenceNumber) or 0
	local ActiveLocalGunTable = ShieldModeRuntimeTable.ResolveCurrentLocalGun(LocalCharacterModel)
	if ShieldModeRuntimeTable.currentLocalGunCheckParamsFrameId == FrameIdNumber
		and ShieldModeRuntimeTable.currentLocalGunCharacter == LocalCharacterModel
		and ShieldModeRuntimeTable.activeLocalGun == ActiveLocalGunTable then
		return ShieldModeRuntimeTable.currentLocalGunCheckParamsValue
	end

	local CheckParamsObject = ActiveLocalGunTable and ActiveLocalGunTable.CheckParams or nil
	ShieldModeRuntimeTable.currentLocalGunCheckParamsFrameId = FrameIdNumber
	ShieldModeRuntimeTable.currentLocalGunCheckParamsValue = CheckParamsObject
	return CheckParamsObject
end

function ShieldModeRuntimeTable.ResolveCurrentWeaponBallisticsProfile(LocalCharacterModel)
	local FrameIdNumber = tonumber(CurrentFrameSequenceNumber) or 0
	local ActiveLocalGunTable = ShieldModeRuntimeTable.ResolveCurrentLocalGun(LocalCharacterModel)
	if ShieldModeRuntimeTable.currentWeaponBallisticsProfileFrameId == FrameIdNumber
		and ShieldModeRuntimeTable.currentWeaponBallisticsProfileCharacter == LocalCharacterModel
		and ShieldModeRuntimeTable.currentWeaponBallisticsProfileLocalGun == ActiveLocalGunTable
		and type(ShieldModeRuntimeTable.currentWeaponBallisticsProfileValue) == "table" then
		return ShieldModeRuntimeTable.currentWeaponBallisticsProfileValue
	end

	local function FinalizeProfile(ProfileResultTable)
		ShieldModeRuntimeTable.currentWeaponBallisticsProfileFrameId = FrameIdNumber
		ShieldModeRuntimeTable.currentWeaponBallisticsProfileCharacter = LocalCharacterModel
		ShieldModeRuntimeTable.currentWeaponBallisticsProfileLocalGun = ActiveLocalGunTable
		ShieldModeRuntimeTable.currentWeaponBallisticsProfileValue = ProfileResultTable
		return ProfileResultTable
	end

	local GunSettingsTable = ActiveLocalGunTable and ActiveLocalGunTable.Settings or nil
	local WeaponTypeString = GunSettingsTable and GunSettingsTable.WeaponType or nil
	local WeaponNameString = GunSettingsTable and GunSettingsTable.Name
		or (ActiveLocalGunTable and ActiveLocalGunTable.Tool and ActiveLocalGunTable.Tool.Name)
		or nil
	local LauncherFallbackProfileTable = WeaponNameString and LauncherBallisticsProfileByNameTable[WeaponNameString] or nil
	local ProjectileNameString = GunSettingsTable and GunSettingsTable.Projectile
		or (LauncherFallbackProfileTable and LauncherFallbackProfileTable.projectileName)
		or nil
	local ProfileTable = {
		localCharacter = LocalCharacterModel,
		localGun = ActiveLocalGunTable,
		settings = GunSettingsTable,
		weaponType = WeaponTypeString,
		isLauncher = WeaponTypeString == "Launcher",
		explodes = GunSettingsTable and GunSettingsTable.Explodes == true or false,
		customShot = GunSettingsTable and GunSettingsTable.CustomShot == true or false,
		launchAsset = GunSettingsTable and GunSettingsTable.LaunchAsset or nil,
		splashRadius = LauncherFallbackProfileTable and tonumber(LauncherFallbackProfileTable.splashRadius) or nil,
		launchMode = LauncherFallbackProfileTable and LauncherFallbackProfileTable.launchMode or nil,
		forceDistanceClamp = LauncherFallbackProfileTable and tonumber(LauncherFallbackProfileTable.forceDistanceClamp) or nil,
		forceDistanceScale = LauncherFallbackProfileTable and tonumber(LauncherFallbackProfileTable.forceDistanceScale) or nil,
		forceDistanceBias = LauncherFallbackProfileTable and tonumber(LauncherFallbackProfileTable.forceDistanceBias) or nil,
		simulationStep = LauncherFallbackProfileTable and tonumber(LauncherFallbackProfileTable.simulationStep) or nil,
		useWorkspaceGravity = LauncherFallbackProfileTable and LauncherFallbackProfileTable.useWorkspaceGravity == true or false,
		delayedExplosion = LauncherFallbackProfileTable and LauncherFallbackProfileTable.delayedExplosion == true or false,
		splashAcceptanceScale = LauncherFallbackProfileTable and tonumber(LauncherFallbackProfileTable.splashAcceptanceScale) or nil,
		muzzleOrigin = ShieldModeRuntimeTable.GetCurrentLocalGunMuzzleOrigin(LocalCharacterModel),
		isProjectile = ProjectileNameString ~= nil or LauncherFallbackProfileTable ~= nil,
		projectileName = ProjectileNameString,
		speed = nil,
		gravity = 0,
		lifetime = nil,
		rayHit = nil,
	}

	local function ApplyProjectileProfileValues(SourceTable)
		if type(SourceTable) ~= "table" then
			return
		end

		if type(ProfileTable.speed) ~= "number" then
			ProfileTable.speed = tonumber(SourceTable.speed or SourceTable.Speed)
		end
		if math.abs(tonumber(ProfileTable.gravity) or 0) <= 0.000001 then
			ProfileTable.gravity = tonumber(SourceTable.gravity or SourceTable.Gravity) or ProfileTable.gravity or 0
		end
		if type(ProfileTable.lifetime) ~= "number" then
			ProfileTable.lifetime = tonumber(SourceTable.lifetime or SourceTable.Lifetime)
		end
		if ProfileTable.rayHit == nil then
			local RayHitValue = SourceTable.rayHit
			if RayHitValue == nil then
				RayHitValue = SourceTable.RayHit
			end
			ProfileTable.rayHit = RayHitValue
		end
		if type(ProfileTable.splashRadius) ~= "number" then
			ProfileTable.splashRadius = tonumber(SourceTable.splashRadius or SourceTable.SplashRadius)
		end
		if type(ProfileTable.launchMode) ~= "string" then
			ProfileTable.launchMode = SourceTable.launchMode
		end
		if type(ProfileTable.forceDistanceClamp) ~= "number" then
			ProfileTable.forceDistanceClamp = tonumber(SourceTable.forceDistanceClamp)
		end
		if type(ProfileTable.forceDistanceScale) ~= "number" then
			ProfileTable.forceDistanceScale = tonumber(SourceTable.forceDistanceScale)
		end
		if type(ProfileTable.forceDistanceBias) ~= "number" then
			ProfileTable.forceDistanceBias = tonumber(SourceTable.forceDistanceBias)
		end
		if type(ProfileTable.simulationStep) ~= "number" then
			ProfileTable.simulationStep = tonumber(SourceTable.simulationStep)
		end
		if ProfileTable.useWorkspaceGravity ~= true and SourceTable.useWorkspaceGravity == true then
			ProfileTable.useWorkspaceGravity = true
		end
		if ProfileTable.delayedExplosion ~= true and SourceTable.delayedExplosion == true then
			ProfileTable.delayedExplosion = true
		end
		if type(ProfileTable.splashAcceptanceScale) ~= "number" then
			ProfileTable.splashAcceptanceScale = tonumber(SourceTable.splashAcceptanceScale)
		end
	end

	if ProjectileNameString == nil and LauncherFallbackProfileTable == nil then
		return FinalizeProfile(ProfileTable)
	end

	ApplyProjectileProfileValues(LauncherFallbackProfileTable)

	local ClientProjectilesModuleTable = ShieldModeRuntimeTable.ResolveClientProjectilesModule()
	local ProjectileDataTable = nil
	local ProjectileDataAccessorTable = ClientProjectilesModuleTable and ClientProjectilesModuleTable.Data or nil
	local GetParamFunction = ProjectileDataAccessorTable and ProjectileDataAccessorTable.GetParam or nil
	if type(GetParamFunction) == "function" then
		local SuccessBoolean, ResultValue = pcall(GetParamFunction, ProjectileNameString)
		if not SuccessBoolean or type(ResultValue) ~= "table" then
			local AlternateSuccessBoolean, AlternateResultValue = pcall(GetParamFunction, ProjectileDataAccessorTable, ProjectileNameString)
			if AlternateSuccessBoolean and type(AlternateResultValue) == "table" then
				SuccessBoolean, ResultValue = AlternateSuccessBoolean, AlternateResultValue
			end
		end
		if SuccessBoolean and type(ResultValue) == "table" then
			ProjectileDataTable = ResultValue
		end
	end
	if not ProjectileDataTable then
		return FinalizeProfile(ProfileTable)
	end

	ProfileTable.projectileData = ProjectileDataTable
	ApplyProjectileProfileValues(ProjectileDataTable)

	local ProjectileParamsTable = ProjectileDataTable.Params
	if type(ProjectileParamsTable) == "table" then
		ProfileTable.gravity = tonumber(ProjectileParamsTable.Gravity) or ProfileTable.gravity or 0
		ProfileTable.lifetime = tonumber(ProjectileParamsTable.Lifetime) or ProfileTable.lifetime

		local CastingParamsTable = ProjectileParamsTable.CastingParams
		if type(CastingParamsTable) == "table" then
			ProfileTable.castType = CastingParamsTable[1]
			ProfileTable.castSize = CastingParamsTable[2]
		end
	end

	return FinalizeProfile(ProfileTable)
end

function ShieldModeRuntimeTable.IsProjectileWeaponProfile(ProfileTable)
	return type(ProfileTable) == "table" and ProfileTable.isProjectile == true
end

function ShieldModeRuntimeTable.IsShotgunWeaponProfile(ProfileTable)
	if type(ProfileTable) ~= "table" or ProfileTable.isProjectile == true then
		return false
	end

	local SettingsTable = ProfileTable.settings
	local WeaponNameString = ProfileTable.weaponName
		or (SettingsTable and SettingsTable.Name)
		or (ProfileTable.localGun and ProfileTable.localGun.Tool and ProfileTable.localGun.Tool.Name)
	if type(WeaponNameString) ~= "string" then
		return false
	end

	return string.find(string.lower(WeaponNameString), "shotgun", 1, true) ~= nil
end

function ShieldModeRuntimeTable.GetShotgunRedirectDistance(ProfileTable, OriginVector3, TargetPositionVector3, OriginalDistanceNumber)
	if not IsSillyModeBehaviorActive()
		or not ShieldModeRuntimeTable.IsShotgunWeaponProfile(ProfileTable)
		or typeof(OriginVector3) ~= "Vector3"
		or typeof(TargetPositionVector3) ~= "Vector3"
		or type(OriginalDistanceNumber) ~= "number"
		or OriginalDistanceNumber <= 0.001 then
		return OriginalDistanceNumber
	end

	local TargetDistanceNumber = (TargetPositionVector3 - OriginVector3).Magnitude
	if TargetDistanceNumber <= 0.001 then
		return OriginalDistanceNumber
	end

	-- Blood Zone's shotgun client ray is capped at Settings.Distance (150 for
	-- Pump Shotgun). Let the redirected ray reach the selected target instead.
	return math.max(OriginalDistanceNumber, TargetDistanceNumber + 6)
end

function ShieldModeRuntimeTable.CanPredictProjectileWeaponProfile(ProfileTable)
	return UseProjectilePredictionBoolean
		and ShieldModeRuntimeTable.IsProjectileWeaponProfile(ProfileTable)
		and (
			(type(ProfileTable.speed) == "number" and ProfileTable.speed > 0)
			or ShouldUseForceCurveProjectileProfile(ProfileTable)
		)
end

local function GetCurrentGunVisibilityOrigin(LocalCharacterModel)
	if not LocalCharacterModel or not LocalCharacterModel.Parent then
		return nil
	end

	if ShieldModeRuntimeTable.GetCurrentLocalGunMuzzleOrigin then
		return ShieldModeRuntimeTable.GetCurrentLocalGunMuzzleOrigin(LocalCharacterModel)
	end

	return nil
end

local function ResolveTrackedTargetPointVector3(PartInstance, WorldPointVector3, LocalPointVector3)
	if PartInstance and PartInstance.Parent and typeof(LocalPointVector3) == "Vector3" then
		return PartInstance.CFrame:PointToWorldSpace(LocalPointVector3)
	end

	if typeof(WorldPointVector3) == "Vector3" then
		return WorldPointVector3
	end

	if PartInstance and PartInstance.Parent then
		return PartInstance.Position
	end

	return nil
end

local function GetCurrentTrackedTargetPointVector3()
	return ResolveTrackedTargetPointVector3(CurrentTargetPartInstance, CurrentTargetPointVector3, CurrentTargetLocalPointVector3)
end

local function GetCurrentEffectiveAimPointVector3()
	if typeof(CurrentTargetAimPointVector3) == "Vector3" then
		return CurrentTargetAimPointVector3
	end

	return GetCurrentTrackedTargetPointVector3()
end

local function ResolveWeaponAimOriginVector3(LocalCharacterModel, WeaponBallisticsProfileTable)
	local MuzzleOriginVector3 = WeaponBallisticsProfileTable and WeaponBallisticsProfileTable.muzzleOrigin or nil
	if typeof(MuzzleOriginVector3) == "Vector3" then
		return MuzzleOriginVector3
	end

	local HeadPartInstance = LocalCharacterModel and GetCharacterHeadPart(LocalCharacterModel) or nil
	if HeadPartInstance then
		return HeadPartInstance.Position
	end

	local RootPartInstance = LocalCharacterModel and GetCharacterRootPart(LocalCharacterModel) or nil
	if RootPartInstance then
		return RootPartInstance.Position
	end

	local ActiveCamera = WorkspaceService.CurrentCamera or Camera
	return ActiveCamera and ActiveCamera.CFrame.Position or nil
end

local function ResolveProjectilePreferredImpactPart(CharacterModel, PartInstance, ProfileTable)
	if not CharacterModel or not CharacterModel.Parent then
		return PartInstance
	end

	if not ShouldPreferProjectileBodyAimForProfile(ProfileTable) then
		return PartInstance
	end

	return GetCharacterRootPart(CharacterModel)
		or GetCharacterTorsoLikePart(CharacterModel)
		or PartInstance
end

local function ResolveProjectileBaseTargetPointVector3(CharacterModel, PartInstance, TargetPointVector3, ProfileTable)
	if typeof(TargetPointVector3) ~= "Vector3" then
		return nil, PartInstance
	end

	local PreferredPartInstance = ResolveProjectilePreferredImpactPart(CharacterModel, PartInstance, ProfileTable)
	local PreferredTargetPointVector3 = PreferredPartInstance and PreferredPartInstance.Position or TargetPointVector3
	if ShouldPreferProjectileFeetImpactForProfile(ProfileTable) and PreferredPartInstance then
		local HalfHeightNumber = PreferredPartInstance.Size and (PreferredPartInstance.Size.Y * 0.5) or 1
		local DownwardBiasNumber = math.clamp(HalfHeightNumber * 0.35, 0.35, 1.5)
		PreferredTargetPointVector3 = PreferredTargetPointVector3 - Vector3.new(0, DownwardBiasNumber, 0)
	end

	return PreferredTargetPointVector3, PreferredPartInstance or PartInstance
end

local function EvaluateProjectileTravelTime(OriginVector3, TargetPointVector3, TargetVelocityVector3, ProjectileSpeedNumber, GravityNumber, TravelTimeNumber)
	if type(TravelTimeNumber) ~= "number" or TravelTimeNumber <= 0 then
		return nil, nil, nil
	end

	local GravityAccelerationVector3 = Vector3.new(0, -(tonumber(GravityNumber) or 0), 0)
	local FutureTargetPointVector3 = TargetPointVector3 + TargetVelocityVector3 * TravelTimeNumber
	local RequiredVelocityVector3 = (FutureTargetPointVector3 - OriginVector3 - GravityAccelerationVector3 * (0.5 * TravelTimeNumber * TravelTimeNumber)) / TravelTimeNumber
	local RequiredSpeedNumber = RequiredVelocityVector3.Magnitude
	if RequiredSpeedNumber <= 0.001 then
		return nil, nil, nil
	end

	local SpeedErrorNumber = RequiredSpeedNumber - ProjectileSpeedNumber
	local AimDistanceNumber = math.max((FutureTargetPointVector3 - OriginVector3).Magnitude, 32)
	local AimPointVector3 = OriginVector3 + RequiredVelocityVector3.Unit * AimDistanceNumber
	return SpeedErrorNumber, RequiredVelocityVector3, AimPointVector3
end

local function SolveLinearInterceptTravelTime(OriginVector3, TargetPointVector3, TargetVelocityVector3, ProjectileSpeedNumber)
	local DisplacementVector3 = TargetPointVector3 - OriginVector3
	local QuadraticANumber = TargetVelocityVector3:Dot(TargetVelocityVector3) - ProjectileSpeedNumber * ProjectileSpeedNumber
	local QuadraticBNumber = 2 * DisplacementVector3:Dot(TargetVelocityVector3)
	local QuadraticCNumber = DisplacementVector3:Dot(DisplacementVector3)
	if math.abs(QuadraticANumber) <= 0.000001 then
		if math.abs(QuadraticBNumber) <= 0.000001 then
			return nil
		end

		local LinearTimeNumber = -QuadraticCNumber / QuadraticBNumber
		if LinearTimeNumber > 0 then
			return LinearTimeNumber
		end

		return nil
	end

	local DiscriminantNumber = QuadraticBNumber * QuadraticBNumber - 4 * QuadraticANumber * QuadraticCNumber
	if DiscriminantNumber < 0 then
		return nil
	end

	local SqrtDiscriminantNumber = math.sqrt(DiscriminantNumber)
	local TravelTimeNumberA = (-QuadraticBNumber - SqrtDiscriminantNumber) / (2 * QuadraticANumber)
	local TravelTimeNumberB = (-QuadraticBNumber + SqrtDiscriminantNumber) / (2 * QuadraticANumber)
	local BestTravelTimeNumber = nil
	for _, TravelTimeNumber in ipairs({ TravelTimeNumberA, TravelTimeNumberB }) do
		if type(TravelTimeNumber) == "number"
			and TravelTimeNumber > 0
			and (not BestTravelTimeNumber or TravelTimeNumber < BestTravelTimeNumber) then
			BestTravelTimeNumber = TravelTimeNumber
		end
	end

	return BestTravelTimeNumber
end

local function GetForceCurveProjectileTravelTimeNumber(ProfileTable, DistanceNumber)
	if type(DistanceNumber) ~= "number" or DistanceNumber <= 0.001 then
		return nil, nil
	end

	local DistanceScaleNumber = tonumber(ProfileTable and ProfileTable.forceDistanceScale) or 0.01
	local DistanceBiasNumber = tonumber(ProfileTable and ProfileTable.forceDistanceBias) or 1.001
	local DistanceClampNumber = tonumber(ProfileTable and ProfileTable.forceDistanceClamp)
	local EffectiveDistanceNumber = DistanceNumber
	if type(DistanceClampNumber) == "number" and DistanceClampNumber > 0 then
		EffectiveDistanceNumber = math.min(EffectiveDistanceNumber, DistanceClampNumber)
	end

	local TravelTimeNumber = math.log(EffectiveDistanceNumber * DistanceScaleNumber + DistanceBiasNumber)
	if type(TravelTimeNumber) ~= "number"
		or TravelTimeNumber ~= TravelTimeNumber
		or TravelTimeNumber <= 0.001 then
		return nil, EffectiveDistanceNumber
	end

	return TravelTimeNumber, EffectiveDistanceNumber
end

local function SolveForceCurveProjectileAimPointVector3(OriginVector3, TargetPointVector3, TargetVelocityVector3, ProfileTable)
	if typeof(OriginVector3) ~= "Vector3"
		or typeof(TargetPointVector3) ~= "Vector3"
		or typeof(TargetVelocityVector3) ~= "Vector3"
		or not ShouldUseForceCurveProjectileProfile(ProfileTable) then
		return nil, nil
	end

	local MaximumTravelTimeNumber = type(ProfileTable.lifetime) == "number" and ProfileTable.lifetime > 0 and ProfileTable.lifetime or 2
	local MaximumDistanceNumber = tonumber(ProfileTable.forceDistanceClamp)
	local IterativeAimPointVector3 = TargetPointVector3
	local BestAimPointVector3 = nil
	local BestTravelTimeNumber = nil

	for _ = 1, 8 do
		local AimDisplacementVector3 = IterativeAimPointVector3 - OriginVector3
		local AimDistanceNumber = AimDisplacementVector3.Magnitude
		if AimDistanceNumber <= 0.001 then
			return nil, nil
		end
		if type(MaximumDistanceNumber) == "number" and MaximumDistanceNumber > 0 then
			if AimDistanceNumber > (MaximumDistanceNumber + 0.5) then
				return nil, nil
			end
		end

		local TravelTimeNumber = GetForceCurveProjectileTravelTimeNumber(ProfileTable, AimDistanceNumber)
		if type(TravelTimeNumber) ~= "number" or TravelTimeNumber > MaximumTravelTimeNumber then
			return nil, nil
		end

		BestAimPointVector3 = IterativeAimPointVector3
		BestTravelTimeNumber = TravelTimeNumber

		local NextAimPointVector3 = TargetPointVector3 + TargetVelocityVector3 * TravelTimeNumber
		if (NextAimPointVector3 - IterativeAimPointVector3).Magnitude <= 0.05 then
			break
		end

		IterativeAimPointVector3 = NextAimPointVector3
	end

	return BestAimPointVector3, BestTravelTimeNumber
end

local function ResolveProjectileLaunchVelocityVector3(OriginVector3, AimPointVector3, ProfileTable)
	if typeof(OriginVector3) ~= "Vector3"
		or typeof(AimPointVector3) ~= "Vector3"
		or type(ProfileTable) ~= "table" then
		return nil, nil
	end

	local LaunchDirectionVector3 = AimPointVector3 - OriginVector3
	local LaunchDistanceNumber = LaunchDirectionVector3.Magnitude
	if LaunchDistanceNumber <= 0.001 then
		return nil, nil
	end

	if ShouldUseForceCurveProjectileProfile(ProfileTable) then
		local TravelTimeNumber, EffectiveDistanceNumber = GetForceCurveProjectileTravelTimeNumber(ProfileTable, LaunchDistanceNumber)
		local MaximumDistanceNumber = tonumber(ProfileTable.forceDistanceClamp)
		if type(MaximumDistanceNumber) == "number"
			and MaximumDistanceNumber > 0
			and LaunchDistanceNumber > (MaximumDistanceNumber + 0.5) then
			return nil, nil
		end
		if type(TravelTimeNumber) ~= "number" then
			return nil, nil
		end

		local GravityNumber = GetProjectileProfileGravityMagnitudeNumber(ProfileTable)
		local LaunchVelocityVector3 = LaunchDirectionVector3.Unit * (EffectiveDistanceNumber / TravelTimeNumber)
			+ Vector3.new(0, GravityNumber * TravelTimeNumber * 0.5, 0)
		return LaunchVelocityVector3, TravelTimeNumber
	end

	local ProjectileSpeedNumber = tonumber(ProfileTable.speed)
	if type(ProjectileSpeedNumber) ~= "number" or ProjectileSpeedNumber <= 0.001 then
		return nil, nil
	end

	return LaunchDirectionVector3.Unit * ProjectileSpeedNumber, LaunchDistanceNumber / ProjectileSpeedNumber
end

local function GetProjectileSplashAcceptanceRadiusNumber(ProfileTable, SplashRadiusNumber)
	if type(SplashRadiusNumber) ~= "number" or SplashRadiusNumber <= 0 then
		return 0
	end

	local SplashAcceptanceScaleNumber = tonumber(ProfileTable and ProfileTable.splashAcceptanceScale)
	local AcceptanceRadiusNumber = SplashRadiusNumber
	if type(SplashAcceptanceScaleNumber) == "number" and SplashAcceptanceScaleNumber > 0 then
		AcceptanceRadiusNumber = AcceptanceRadiusNumber * SplashAcceptanceScaleNumber
	end

	if type(ProfileTable) == "table" and ProfileTable.delayedExplosion == true then
		AcceptanceRadiusNumber = math.min(AcceptanceRadiusNumber, SplashRadiusNumber * 0.65)
	end

	return AcceptanceRadiusNumber + 0.5
end

local function IsProjectileSplashImpactAcceptable(ProfileTable, ImpactPositionVector3, TargetPointVector3, SplashRadiusNumber)
	if typeof(ImpactPositionVector3) ~= "Vector3" or typeof(TargetPointVector3) ~= "Vector3" then
		return false, math.huge
	end

	local ImpactDistanceNumber = (ImpactPositionVector3 - TargetPointVector3).Magnitude
	local AcceptanceRadiusNumber = GetProjectileSplashAcceptanceRadiusNumber(ProfileTable, SplashRadiusNumber)
	if ImpactDistanceNumber > AcceptanceRadiusNumber then
		return false, ImpactDistanceNumber
	end

	if type(ProfileTable) == "table" and ProfileTable.delayedExplosion == true then
		local VerticalOvershootNumber = ImpactPositionVector3.Y - TargetPointVector3.Y
		local MaximumVerticalOvershootNumber = math.max(1.5, AcceptanceRadiusNumber * 0.35)
		if VerticalOvershootNumber > MaximumVerticalOvershootNumber then
			return false, ImpactDistanceNumber
		end
	end

	return true, ImpactDistanceNumber
end

local function SolveStationaryBallisticTravelTime(OriginVector3, TargetPointVector3, ProjectileSpeedNumber, GravityNumber, PreferHighArcBoolean)
	local SignedGravityNumber = tonumber(GravityNumber) or 0
	if math.abs(SignedGravityNumber) <= 0.000001 then
		return (TargetPointVector3 - OriginVector3).Magnitude / ProjectileSpeedNumber
	end
	if SignedGravityNumber < 0 then
		return nil
	end

	local DisplacementVector3 = TargetPointVector3 - OriginVector3
	local HorizontalDistanceNumber = Vector3.new(DisplacementVector3.X, 0, DisplacementVector3.Z).Magnitude
	if HorizontalDistanceNumber <= 0.001 then
		return nil
	end

	local VerticalOffsetNumber = DisplacementVector3.Y
	local ProjectileSpeedSquaredNumber = ProjectileSpeedNumber * ProjectileSpeedNumber
	local DiscriminantNumber = ProjectileSpeedSquaredNumber * ProjectileSpeedSquaredNumber
		- SignedGravityNumber * (SignedGravityNumber * HorizontalDistanceNumber * HorizontalDistanceNumber + 2 * VerticalOffsetNumber * ProjectileSpeedSquaredNumber)
	if DiscriminantNumber < 0 then
		return nil
	end

	local SqrtDiscriminantNumber = math.sqrt(DiscriminantNumber)
	local TangentThetaNumeratorNumber = PreferHighArcBoolean
		and (ProjectileSpeedSquaredNumber + SqrtDiscriminantNumber)
		or (ProjectileSpeedSquaredNumber - SqrtDiscriminantNumber)
	local TangentThetaNumber = TangentThetaNumeratorNumber / (SignedGravityNumber * HorizontalDistanceNumber)
	if type(TangentThetaNumber) ~= "number" or TangentThetaNumber ~= TangentThetaNumber then
		return nil
	end

	local CosThetaNumber = 1 / math.sqrt(1 + TangentThetaNumber * TangentThetaNumber)
	if CosThetaNumber <= 0.001 then
		return nil
	end

	return HorizontalDistanceNumber / (ProjectileSpeedNumber * CosThetaNumber)
end

local function SolveProjectileAimPointVector3(OriginVector3, TargetPointVector3, TargetVelocityVector3, ProjectileSpeedNumber, GravityNumber, LifetimeNumber, PreferHighArcBoolean)
	if typeof(OriginVector3) ~= "Vector3"
		or typeof(TargetPointVector3) ~= "Vector3"
		or typeof(TargetVelocityVector3) ~= "Vector3"
		or type(ProjectileSpeedNumber) ~= "number"
		or ProjectileSpeedNumber <= 0.001 then
		return nil, nil
	end

	local MaximumTravelTimeNumber = type(LifetimeNumber) == "number" and LifetimeNumber > 0 and LifetimeNumber or 8
	local MinimumTravelTimeNumber = math.min(0.01, MaximumTravelTimeNumber)
	local BestAimPointVector3 = nil
	local BestTravelTimeNumber = nil
	local BestSpeedErrorNumber = math.huge

	local function ConsiderTravelTime(TravelTimeNumber)
		local ClampedTravelTimeNumber = math.clamp(TravelTimeNumber, MinimumTravelTimeNumber, MaximumTravelTimeNumber)
		local SpeedErrorNumber, RequiredVelocityVector3, AimPointVector3 = EvaluateProjectileTravelTime(
			OriginVector3,
			TargetPointVector3,
			TargetVelocityVector3,
			ProjectileSpeedNumber,
			GravityNumber,
			ClampedTravelTimeNumber
		)
		if type(SpeedErrorNumber) ~= "number" then
			return nil, nil, nil
		end

		local AbsoluteSpeedErrorNumber = math.abs(SpeedErrorNumber)
		local ShouldReplaceBestBoolean = AbsoluteSpeedErrorNumber < (BestSpeedErrorNumber - 0.0001)
		if not ShouldReplaceBestBoolean and math.abs(AbsoluteSpeedErrorNumber - BestSpeedErrorNumber) <= 0.0001 then
			if type(BestTravelTimeNumber) ~= "number" then
				ShouldReplaceBestBoolean = true
			elseif PreferHighArcBoolean then
				ShouldReplaceBestBoolean = ClampedTravelTimeNumber > BestTravelTimeNumber
			else
				ShouldReplaceBestBoolean = ClampedTravelTimeNumber < BestTravelTimeNumber
			end
		end

		if ShouldReplaceBestBoolean then
			BestSpeedErrorNumber = AbsoluteSpeedErrorNumber
			BestTravelTimeNumber = ClampedTravelTimeNumber
			BestAimPointVector3 = AimPointVector3
		end

		return SpeedErrorNumber, RequiredVelocityVector3, AimPointVector3
	end

	local StraightLineTravelTimeNumber = math.clamp(
		(TargetPointVector3 - OriginVector3).Magnitude / ProjectileSpeedNumber,
		MinimumTravelTimeNumber,
		MaximumTravelTimeNumber
	)
	ConsiderTravelTime(StraightLineTravelTimeNumber)

	local SignedGravityNumber = tonumber(GravityNumber) or 0
	if math.abs(SignedGravityNumber) <= 0.000001 then
		local LinearTravelTimeNumber = SolveLinearInterceptTravelTime(OriginVector3, TargetPointVector3, TargetVelocityVector3, ProjectileSpeedNumber)
		if type(LinearTravelTimeNumber) == "number" then
			StraightLineTravelTimeNumber = math.clamp(LinearTravelTimeNumber, MinimumTravelTimeNumber, MaximumTravelTimeNumber)
			ConsiderTravelTime(StraightLineTravelTimeNumber)
		end
	elseif SignedGravityNumber > 0 then
		local IterativeTravelTimeNumber = SolveStationaryBallisticTravelTime(
			OriginVector3,
			TargetPointVector3,
			ProjectileSpeedNumber,
			SignedGravityNumber,
			PreferHighArcBoolean
		)
			or StraightLineTravelTimeNumber
		IterativeTravelTimeNumber = math.clamp(IterativeTravelTimeNumber, MinimumTravelTimeNumber, MaximumTravelTimeNumber)
		ConsiderTravelTime(IterativeTravelTimeNumber)
		for _ = 1, 7 do
			local FutureTargetPointVector3 = TargetPointVector3 + TargetVelocityVector3 * IterativeTravelTimeNumber
			local SolvedTravelTimeNumber = SolveStationaryBallisticTravelTime(
				OriginVector3,
				FutureTargetPointVector3,
				ProjectileSpeedNumber,
				SignedGravityNumber,
				PreferHighArcBoolean
			)
			if type(SolvedTravelTimeNumber) ~= "number" then
				break
			end

			local ClampedTravelTimeNumber = math.clamp(SolvedTravelTimeNumber, MinimumTravelTimeNumber, MaximumTravelTimeNumber)
			local PreviousTravelTimeNumber = IterativeTravelTimeNumber
			IterativeTravelTimeNumber = ClampedTravelTimeNumber
			ConsiderTravelTime(IterativeTravelTimeNumber)
			if math.abs(IterativeTravelTimeNumber - PreviousTravelTimeNumber) <= 0.001 then
				break
			end
		end
	end

	if BestSpeedErrorNumber <= 0.25 then
		return BestAimPointVector3, BestTravelTimeNumber
	end

	local PreviousTimeNumber = MinimumTravelTimeNumber
	local PreviousErrorNumber = ConsiderTravelTime(PreviousTimeNumber)
	local BracketLowTimeNumber = nil
	local BracketHighTimeNumber = nil
	local BracketLowErrorNumber = nil
	local BracketHighErrorNumber = nil
	local SampleCountNumber = 36

	for SampleIndexNumber = 1, SampleCountNumber do
		local AlphaNumber = SampleIndexNumber / SampleCountNumber
		local SampleTimeNumber = MinimumTravelTimeNumber + (MaximumTravelTimeNumber - MinimumTravelTimeNumber) * AlphaNumber
		local SampleErrorNumber = ConsiderTravelTime(SampleTimeNumber)
		if type(PreviousErrorNumber) == "number" and type(SampleErrorNumber) == "number" then
			if PreviousErrorNumber == 0 then
				BracketLowTimeNumber = PreviousTimeNumber
				BracketHighTimeNumber = PreviousTimeNumber
				BracketLowErrorNumber = PreviousErrorNumber
				BracketHighErrorNumber = PreviousErrorNumber
				break
			end
			if SampleErrorNumber == 0
				or (PreviousErrorNumber < 0 and SampleErrorNumber > 0)
				or (PreviousErrorNumber > 0 and SampleErrorNumber < 0) then
				BracketLowTimeNumber = PreviousTimeNumber
				BracketHighTimeNumber = SampleTimeNumber
				BracketLowErrorNumber = PreviousErrorNumber
				BracketHighErrorNumber = SampleErrorNumber
				break
			end
		end
		PreviousTimeNumber = SampleTimeNumber
		PreviousErrorNumber = SampleErrorNumber
	end

	if BracketLowTimeNumber and BracketHighTimeNumber then
		for _ = 1, 16 do
			local MidTimeNumber = (BracketLowTimeNumber + BracketHighTimeNumber) * 0.5
			local MidErrorNumber = ConsiderTravelTime(MidTimeNumber)
			if type(MidErrorNumber) ~= "number" then
				break
			end
			if math.abs(MidErrorNumber) <= 0.001 then
				break
			end
			if type(BracketLowErrorNumber) ~= "number" then
				BracketLowTimeNumber = MidTimeNumber
				BracketLowErrorNumber = MidErrorNumber
			elseif (BracketLowErrorNumber <= 0 and MidErrorNumber <= 0)
				or (BracketLowErrorNumber >= 0 and MidErrorNumber >= 0) then
				BracketLowTimeNumber = MidTimeNumber
				BracketLowErrorNumber = MidErrorNumber
			else
				BracketHighTimeNumber = MidTimeNumber
				BracketHighErrorNumber = MidErrorNumber
			end
		end
	end

	return BestAimPointVector3, BestTravelTimeNumber
end

local function SimulateProjectileImpactResult(OriginVector3, AimPointVector3, ProfileTable, RaycastParamsObject, TargetCharacterModel)
	if typeof(OriginVector3) ~= "Vector3"
		or typeof(AimPointVector3) ~= "Vector3"
		or type(ProfileTable) ~= "table" then
		return nil
	end

	local LaunchVelocityVector3 = ResolveProjectileLaunchVelocityVector3(OriginVector3, AimPointVector3, ProfileTable)
	if typeof(LaunchVelocityVector3) ~= "Vector3" or LaunchVelocityVector3.Magnitude <= 0.001 then
		return nil
	end

	local SignedGravityNumber = GetProjectileProfileGravityNumber(ProfileTable)
	local GravityAccelerationVector3 = Vector3.new(0, -SignedGravityNumber, 0)
	local MaximumTravelTimeNumber = type(ProfileTable.lifetime) == "number" and ProfileTable.lifetime > 0 and ProfileTable.lifetime or 8
	local StepDurationNumber = tonumber(ProfileTable.simulationStep) or 0.05
	local PreviousPositionVector3 = OriginVector3
	local ElapsedTimeNumber = 0

	while ElapsedTimeNumber < MaximumTravelTimeNumber do
		local DeltaTimeNumber = math.min(StepDurationNumber, MaximumTravelTimeNumber - ElapsedTimeNumber)
		local NextElapsedTimeNumber = ElapsedTimeNumber + DeltaTimeNumber
		local NextPositionVector3 = OriginVector3
			+ LaunchVelocityVector3 * NextElapsedTimeNumber
			+ GravityAccelerationVector3 * (0.5 * NextElapsedTimeNumber * NextElapsedTimeNumber)
		local SegmentVector3 = NextPositionVector3 - PreviousPositionVector3
		if SegmentVector3.Magnitude > 0.001 then
			local RaycastResult = RunUnredirectedWorkspaceRaycast(PreviousPositionVector3, SegmentVector3, RaycastParamsObject)
			if RaycastResult then
				return {
					hit = RaycastResult,
					hitTarget = IsRaycastResultTargetHit(RaycastResult, TargetCharacterModel),
					impactPosition = RaycastResult.Position,
					elapsedTime = NextElapsedTimeNumber,
				}
			end
		end

		PreviousPositionVector3 = NextPositionVector3
		ElapsedTimeNumber = NextElapsedTimeNumber
	end

	return {
		hit = nil,
		hitTarget = false,
		impactPosition = PreviousPositionVector3,
		elapsedTime = ElapsedTimeNumber,
		expired = true,
	}
end

local function ResolveProjectileAimSolutionTable(LocalCharacterModel, CharacterModel, PartInstance, TargetPointVector3, ProfileTable, RequireReachabilityBoolean)
	if typeof(TargetPointVector3) ~= "Vector3"
		or not ShieldModeRuntimeTable.CanPredictProjectileWeaponProfile(ProfileTable) then
		return nil
	end

	local AimOriginVector3 = ResolveWeaponAimOriginVector3(LocalCharacterModel, ProfileTable)
	if typeof(AimOriginVector3) ~= "Vector3" then
		return nil
	end

	local TargetVelocityVector3 = GetCharacterVelocityVector3(CharacterModel, PartInstance)
	local RaycastParamsObject = ProfileTable and ProfileTable.localGun and ProfileTable.localGun.RayParams or VisibilityRaycastParams
	local SplashRadiusNumber = GetProjectileSplashRadiusNumber(ProfileTable) or 0
	local BestSolutionTable = nil

	local function ConsiderArc(PreferHighArcBoolean)
		local AimPointVector3
		local TravelTimeNumber
		if ShouldUseForceCurveProjectileProfile(ProfileTable) then
			if PreferHighArcBoolean then
				return
			end
			AimPointVector3, TravelTimeNumber = SolveForceCurveProjectileAimPointVector3(
				AimOriginVector3,
				TargetPointVector3,
				TargetVelocityVector3,
				ProfileTable
			)
		else
			AimPointVector3, TravelTimeNumber = SolveProjectileAimPointVector3(
				AimOriginVector3,
				TargetPointVector3,
				TargetVelocityVector3,
				ProfileTable.speed,
				GetProjectileProfileGravityNumber(ProfileTable),
				ProfileTable.lifetime,
				PreferHighArcBoolean
			)
		end
		if typeof(AimPointVector3) ~= "Vector3" then
			return
		end
		if type(ProfileTable.lifetime) == "number"
			and type(TravelTimeNumber) == "number"
			and TravelTimeNumber > (ProfileTable.lifetime + 0.05) then
			return
		end

		local CandidateSolutionTable = {
			aimPoint = AimPointVector3,
			travelTime = TravelTimeNumber,
			targetPoint = TargetPointVector3,
			part = PartInstance,
			preferHighArc = PreferHighArcBoolean == true,
			reachabilityScore = RequireReachabilityBoolean and -1 or 0,
			impactDistance = math.huge,
		}

		if RequireReachabilityBoolean then
			local SimulationResultTable = SimulateProjectileImpactResult(
				AimOriginVector3,
				AimPointVector3,
				ProfileTable,
				RaycastParamsObject,
				CharacterModel
			)
			if not SimulationResultTable then
				return
			end

			CandidateSolutionTable.simulation = SimulationResultTable
			local ImpactPositionVector3 = SimulationResultTable.impactPosition
			if SimulationResultTable.hitTarget then
				CandidateSolutionTable.reachabilityScore = 2
				CandidateSolutionTable.impactDistance = 0
			elseif SimulationResultTable.hit and typeof(ImpactPositionVector3) == "Vector3" then
				local SplashImpactAcceptableBoolean, ImpactDistanceNumber = IsProjectileSplashImpactAcceptable(
					ProfileTable,
					ImpactPositionVector3,
					TargetPointVector3,
					SplashRadiusNumber
				)
				CandidateSolutionTable.impactDistance = ImpactDistanceNumber
				if SplashImpactAcceptableBoolean then
					CandidateSolutionTable.reachabilityScore = 1
				else
					return
				end
			else
				return
			end
		end

		local ShouldReplaceBestBoolean = false
		if not BestSolutionTable then
			ShouldReplaceBestBoolean = true
		elseif CandidateSolutionTable.reachabilityScore ~= BestSolutionTable.reachabilityScore then
			ShouldReplaceBestBoolean = CandidateSolutionTable.reachabilityScore > BestSolutionTable.reachabilityScore
		elseif math.abs(CandidateSolutionTable.impactDistance - BestSolutionTable.impactDistance) > 0.05 then
			ShouldReplaceBestBoolean = CandidateSolutionTable.impactDistance < BestSolutionTable.impactDistance
		elseif type(CandidateSolutionTable.travelTime) == "number" and type(BestSolutionTable.travelTime) == "number" then
			ShouldReplaceBestBoolean = CandidateSolutionTable.travelTime < BestSolutionTable.travelTime
		end

		if ShouldReplaceBestBoolean then
			BestSolutionTable = CandidateSolutionTable
		end
	end

	ConsiderArc(false)
	if ShouldPreferHighArcProjectileProfile(ProfileTable) then
		ConsiderArc(true)
	end

	return BestSolutionTable
end

local function ResolveTargetAimPointVector3(LocalCharacterModel, CharacterModel, PartInstance, TargetPointVector3)
	if typeof(TargetPointVector3) ~= "Vector3" then
		return nil
	end

	local WeaponBallisticsProfileTable = CurrentWeaponBallisticsProfileTable
	if not ShieldModeRuntimeTable.CanPredictProjectileWeaponProfile(WeaponBallisticsProfileTable) then
		return TargetPointVector3
	end

	local BaseTargetPointVector3, PreferredTargetPartInstance = ResolveProjectileBaseTargetPointVector3(
		CharacterModel,
		PartInstance,
		TargetPointVector3,
		WeaponBallisticsProfileTable
	)
	if typeof(BaseTargetPointVector3) == "Vector3" then
		TargetPointVector3 = BaseTargetPointVector3
		PartInstance = PreferredTargetPartInstance or PartInstance
	end

	local AimOriginVector3 = ResolveWeaponAimOriginVector3(LocalCharacterModel, WeaponBallisticsProfileTable)
	if typeof(AimOriginVector3) ~= "Vector3" then
		return TargetPointVector3
	end

	local ProjectileAimSolutionTable = ResolveProjectileAimSolutionTable(
		LocalCharacterModel,
		CharacterModel,
		PartInstance,
		TargetPointVector3,
		WeaponBallisticsProfileTable,
		ShouldUseProjectileArcVisibilityProfile(WeaponBallisticsProfileTable)
	)
	local AimPointVector3 = ProjectileAimSolutionTable and ProjectileAimSolutionTable.aimPoint or nil
	local TravelTimeNumber = ProjectileAimSolutionTable and ProjectileAimSolutionTable.travelTime or nil
	if typeof(AimPointVector3) ~= "Vector3" then
		return TargetPointVector3
	end

	local LifetimeNumber = tonumber(WeaponBallisticsProfileTable.lifetime)
	if LifetimeNumber and LifetimeNumber > 0 and type(TravelTimeNumber) == "number" and TravelTimeNumber > (LifetimeNumber + 0.05) then
		return TargetPointVector3
	end

	return AimPointVector3
end

local function ResolveCurrentSkyTargetData()
	local TargetCharacterModel = CurrentTargetCharacterModel and CurrentTargetCharacterModel.Parent and CurrentTargetCharacterModel or nil
	local TargetPartInstance = CurrentTargetPartInstance and CurrentTargetPartInstance.Parent and CurrentTargetPartInstance or nil
	local TargetPositionVector3 = GetCurrentTrackedTargetPointVector3()
	if not TargetPositionVector3 and TargetPartInstance then
		TargetPositionVector3 = TargetPartInstance.Position
	end

	if not TargetPositionVector3 and TargetCharacterModel then
		local TargetReferencePartInstance = GetCharacterRootPart(TargetCharacterModel) or GetCharacterHeadPart(TargetCharacterModel)
		TargetPositionVector3 = TargetReferencePartInstance and TargetReferencePartInstance.Position or nil
	end

	return TargetPositionVector3, TargetCharacterModel, TargetPartInstance
end

local CachedSkyAimCandidateGroupsByKeyTable = {}

local function GetSkyAimCandidateGroups(RequiredPriorityNumber)
	local UseVisibilityPoolBoolean = RequiredPriorityNumber and RequiredPriorityNumber >= 3
	local CacheKeyString = UseVisibilityPoolBoolean and "visibility" or "default"
	local CachedCandidateGroupsTable = CachedSkyAimCandidateGroupsByKeyTable[CacheKeyString]
	if CachedCandidateGroupsTable then
		return CachedCandidateGroupsTable
	end

	local PitchDegreesTable = UseVisibilityPoolBoolean and SkyAimVisibilitySamplePitchDegreesTable or SkyAimSamplePitchDegreesTable
	local YawOffsetDegreesTable = UseVisibilityPoolBoolean and SkyAimVisibilitySampleYawOffsetDegreesTable or SkyAimSampleYawOffsetDegreesTable

	local CandidateGroupsTable = {}
	for _, PitchDegreeNumber in ipairs(PitchDegreesTable) do
		local PitchRadiansNumber = math.rad(PitchDegreeNumber)
		local PitchGroupTable = {
			pitch = PitchDegreeNumber,
			sinPitch = math.sin(PitchRadiansNumber),
			cosPitch = math.cos(PitchRadiansNumber),
			yaws = {},
		}

		for _, YawOffsetDegreeNumber in ipairs(YawOffsetDegreesTable) do
			local YawRadiansNumber = math.rad(YawOffsetDegreeNumber)
			table.insert(PitchGroupTable.yaws, {
				yaw = YawOffsetDegreeNumber,
				rotation = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), YawRadiansNumber),
			})
		end

		table.insert(CandidateGroupsTable, PitchGroupTable)
	end

	CachedSkyAimCandidateGroupsByKeyTable[CacheKeyString] = CandidateGroupsTable
	return CandidateGroupsTable
end

local function GetFallbackFlatAimDirectionVector3(LocalCharacterModel, ReferenceDirectionVector3, TargetPositionVector3)
	local RootPartInstance = LocalCharacterModel and GetCharacterRootPart(LocalCharacterModel) or nil
	if RootPartInstance and typeof(TargetPositionVector3) == "Vector3" then
		local TargetFlatDirectionVector3 = Vector3.new(
			TargetPositionVector3.X - RootPartInstance.Position.X,
			0,
			TargetPositionVector3.Z - RootPartInstance.Position.Z
		)
		if TargetFlatDirectionVector3.Magnitude > 0.001 then
			return TargetFlatDirectionVector3.Unit
		end
	end

	if typeof(ReferenceDirectionVector3) == "Vector3" then
		local ReferenceFlatDirectionVector3 = Vector3.new(ReferenceDirectionVector3.X, 0, ReferenceDirectionVector3.Z)
		if ReferenceFlatDirectionVector3.Magnitude > 0.001 then
			return ReferenceFlatDirectionVector3.Unit
		end
	end

	if RootPartInstance then
		local RootLookVector3 = RootPartInstance.CFrame.LookVector
		local RootFlatDirectionVector3 = Vector3.new(RootLookVector3.X, 0, RootLookVector3.Z)
		if RootFlatDirectionVector3.Magnitude > 0.001 then
			return RootFlatDirectionVector3.Unit
		end
	end

	local ActiveCamera = WorkspaceService.CurrentCamera or Camera
	if ActiveCamera then
		local CameraLookVector3 = ActiveCamera.CFrame.LookVector
		local CameraFlatDirectionVector3 = Vector3.new(CameraLookVector3.X, 0, CameraLookVector3.Z)
		if CameraFlatDirectionVector3.Magnitude > 0.001 then
			return CameraFlatDirectionVector3.Unit
		end
	end

	return Vector3.new(0, 0, -1)
end

local function BuildFallbackSkyAimSolution(LocalCharacterModel, ReferenceDirectionVector3, TargetPositionVector3)
	local HeadPartInstance = LocalCharacterModel and GetCharacterHeadPart(LocalCharacterModel) or nil
	local RootPartInstance = LocalCharacterModel and GetCharacterRootPart(LocalCharacterModel) or nil
	local ActiveCamera = WorkspaceService.CurrentCamera or Camera
	local MuzzleOriginVector3 = ShieldModeRuntimeTable.GetCurrentLocalGunMuzzleOrigin
		and ShieldModeRuntimeTable.GetCurrentLocalGunMuzzleOrigin(LocalCharacterModel) or nil
	local HitOriginVector3 = MuzzleOriginVector3
		or (HeadPartInstance and HeadPartInstance.Position)
		or (RootPartInstance and RootPartInstance.Position)
		or (ActiveCamera and ActiveCamera.CFrame.Position)
	if typeof(HitOriginVector3) ~= "Vector3" then
		return nil
	end

	local FlatDirectionVector3 = GetFallbackFlatAimDirectionVector3(LocalCharacterModel, ReferenceDirectionVector3, TargetPositionVector3)
	local ShotDirectionVector3 = (Vector3.new(FlatDirectionVector3.X, 1, FlatDirectionVector3.Z)).Unit
	return {
		direction = ShotDirectionVector3,
		hitPosition = HitOriginVector3 + ShotDirectionVector3 * SkyAimHitDistanceNumber,
		facingDirection = FlatDirectionVector3,
		priority = -1,
		isFallback = true,
	}
end

local function BuildSkyAimCandidateFacingDirection(BaseFlatDirectionVector3, YawRotationCFrame)
	local FlatDirectionVector3 = Vector3.new(BaseFlatDirectionVector3.X, 0, BaseFlatDirectionVector3.Z)
	if FlatDirectionVector3.Magnitude <= 0.001 then
		FlatDirectionVector3 = Vector3.new(0, 0, -1)
	else
		FlatDirectionVector3 = FlatDirectionVector3.Unit
	end

	local RotatedFlatDirectionVector3 = YawRotationCFrame:VectorToWorldSpace(FlatDirectionVector3)
	RotatedFlatDirectionVector3 = Vector3.new(RotatedFlatDirectionVector3.X, 0, RotatedFlatDirectionVector3.Z)
	if RotatedFlatDirectionVector3.Magnitude <= 0.001 then
		RotatedFlatDirectionVector3 = FlatDirectionVector3
	else
		RotatedFlatDirectionVector3 = RotatedFlatDirectionVector3.Unit
	end

	return RotatedFlatDirectionVector3
end

local function BuildSkyAimCandidateDirection(FlatFacingDirectionVector3, PitchSineNumber, PitchCosineNumber)
	local CandidateFlatDirectionVector3 = typeof(FlatFacingDirectionVector3) == "Vector3"
		and Vector3.new(FlatFacingDirectionVector3.X, 0, FlatFacingDirectionVector3.Z)
		or nil
	if typeof(CandidateFlatDirectionVector3) ~= "Vector3" or CandidateFlatDirectionVector3.Magnitude <= 0.001 then
		CandidateFlatDirectionVector3 = Vector3.new(0, 0, -1)
	else
		CandidateFlatDirectionVector3 = CandidateFlatDirectionVector3.Unit
	end

	local CandidateDirectionVector3 = CandidateFlatDirectionVector3 * PitchCosineNumber + Vector3.new(0, PitchSineNumber, 0)
	if CandidateDirectionVector3.Magnitude <= 0.001 then
		return nil
	end

	return CandidateDirectionVector3.Unit
end

local function ResolveSkyAimCandidatePose(RootPartInstance, HeadPositionVector3, MuzzleOriginVector3, FacingDirectionVector3)
	if not RootPartInstance
		or typeof(HeadPositionVector3) ~= "Vector3"
		or typeof(MuzzleOriginVector3) ~= "Vector3"
		or typeof(FacingDirectionVector3) ~= "Vector3" then
		return MuzzleOriginVector3, HeadPositionVector3
	end

	local FlatFacingDirectionVector3 = Vector3.new(FacingDirectionVector3.X, 0, FacingDirectionVector3.Z)
	if FlatFacingDirectionVector3.Magnitude <= 0.001 then
		return MuzzleOriginVector3, HeadPositionVector3
	end

	local CurrentRootCFrame = RootPartInstance.CFrame
	local CandidateRootCFrame = CFrame.new(RootPartInstance.Position, RootPartInstance.Position + FlatFacingDirectionVector3.Unit)
	local MuzzleLocalOffsetVector3 = CurrentRootCFrame:PointToObjectSpace(MuzzleOriginVector3)
	local HeadLocalOffsetVector3 = CurrentRootCFrame:PointToObjectSpace(HeadPositionVector3)
	return CandidateRootCFrame:PointToWorldSpace(MuzzleLocalOffsetVector3), CandidateRootCFrame:PointToWorldSpace(HeadLocalOffsetVector3)
end

local function GetPointToRayDistance(PointVector3, OriginVector3, DirectionVector3)
	if typeof(PointVector3) ~= "Vector3"
		or typeof(OriginVector3) ~= "Vector3"
		or typeof(DirectionVector3) ~= "Vector3"
		or DirectionVector3.Magnitude <= 0.001 then
		return math.huge, -math.huge
	end

	local DirectionUnitVector3 = DirectionVector3.Unit
	local OffsetVector3 = PointVector3 - OriginVector3
	local AlongNumber = OffsetVector3:Dot(DirectionUnitVector3)
	if AlongNumber <= 0 then
		return OffsetVector3.Magnitude, AlongNumber
	end

	local ClosestPointVector3 = OriginVector3 + DirectionUnitVector3 * AlongNumber
	return (PointVector3 - ClosestPointVector3).Magnitude, AlongNumber
end

IsRaycastResultTargetHit = function(RaycastResult, TargetCharacterModel)
	local HitInstance = RaycastResult and RaycastResult.Instance or nil
	if not TargetCharacterModel or not HitInstance or not HitInstance.IsDescendantOf then
		return false
	end

	return HitInstance.IsDescendantOf(HitInstance, TargetCharacterModel)
end

local InternalAimbotRaycastBypassDepth = 0

RunUnredirectedWorkspaceRaycast = function(OriginVector3, DirectionVector3, RaycastParamsObject)
	InternalAimbotRaycastBypassDepth = InternalAimbotRaycastBypassDepth + 1
	local ResultTable = table.pack(pcall(WorkspaceService.Raycast, WorkspaceService, OriginVector3, DirectionVector3, RaycastParamsObject))
	InternalAimbotRaycastBypassDepth = math.max(InternalAimbotRaycastBypassDepth - 1, 0)
	if not ResultTable[1] then
		error(ResultTable[2], 0)
	end

	return ResultTable[2]
end

local function GetSkyAimAlignmentTolerance(TargetPartInstance)
	local ToleranceNumber = 1.25
	if TargetPartInstance and TargetPartInstance.Size then
		local PartRadiusNumber = math.max(TargetPartInstance.Size.X, math.max(TargetPartInstance.Size.Y, TargetPartInstance.Size.Z)) * 0.6
		ToleranceNumber = math.max(ToleranceNumber, PartRadiusNumber)
	end

	return math.clamp(ToleranceNumber, 1.25, 4.5)
end

local function ResolveSkyAimSolution(LocalCharacterModel, ReferenceDirectionVector3, EquippedTool, TargetPositionVector3, TargetCharacterModel, TargetPartInstance, SkipCacheBoolean, RequiredPriorityNumber)
	if not IsSillyModeBehaviorActive() or not ShieldModeRuntimeTable.IsSkyAimActive() then
		return nil
	end

	if not LocalCharacterModel
		or not LocalCharacterModel.Parent
		or (not EquippedTool and not HasEquippedTool(LocalCharacterModel)) then
		return nil
	end

	local HumanoidInstance = GetCharacterHumanoid(LocalCharacterModel)
	local RootPartInstance = GetCharacterRootPart(LocalCharacterModel)
	local HeadPartInstance = GetCharacterHeadPart(LocalCharacterModel)
	if not HumanoidInstance
		or not RootPartInstance
		or not HeadPartInstance
		or (tonumber(HumanoidInstance.Health) or 0) <= 0 then
		return nil
	end

	if typeof(TargetPositionVector3) ~= "Vector3" and not TargetCharacterModel and not TargetPartInstance then
		TargetPositionVector3, TargetCharacterModel, TargetPartInstance = ResolveCurrentSkyTargetData()
	end
	local BaseFlatDirectionVector3 = GetFallbackFlatAimDirectionVector3(LocalCharacterModel, ReferenceDirectionVector3, TargetPositionVector3)
	local FallbackSolutionTable = BuildFallbackSkyAimSolution(LocalCharacterModel, ReferenceDirectionVector3, TargetPositionVector3)
	if typeof(TargetPositionVector3) ~= "Vector3" then
		return FallbackSolutionTable
	end

	local HeadPositionVector3 = HeadPartInstance.Position
	local MuzzleOriginVector3 = ShieldModeRuntimeTable.GetCurrentLocalGunMuzzleOrigin
		and ShieldModeRuntimeTable.GetCurrentLocalGunMuzzleOrigin(LocalCharacterModel) or nil
	if typeof(MuzzleOriginVector3) ~= "Vector3" then
		MuzzleOriginVector3 = HeadPositionVector3
	end
	local CurrentLocalGunRaycastParamsObject = ShieldModeRuntimeTable.GetCurrentLocalGunRaycastParams
		and ShieldModeRuntimeTable.GetCurrentLocalGunRaycastParams(LocalCharacterModel) or nil
	local CurrentLocalGunCheckParamsObject = ShieldModeRuntimeTable.GetCurrentLocalGunCheckParams
		and ShieldModeRuntimeTable.GetCurrentLocalGunCheckParams(LocalCharacterModel) or nil
	if not SkipCacheBoolean then
		local CachedSolutionTable = ShieldModeRuntimeTable.skyAimSolutionCache
		local CachedSolutionValue = CachedSolutionTable and CachedSolutionTable.solution or nil
		local CachedSolutionCanBeReusedBoolean = true
		if CachedSolutionValue then
			local CachedPriorityNumber = CachedSolutionValue.priority or 0
			if CachedPriorityNumber < 2 then
				CachedSolutionCanBeReusedBoolean = false
			elseif TargetCharacterModel then
				CachedSolutionCanBeReusedBoolean = false
				local CachedMuzzleOriginVector3 = CachedSolutionValue.muzzleOrigin or CachedSolutionTable.muzzleOrigin
				local CachedDirectionVector3 = CachedSolutionValue.direction
				local CachedTargetDirectionVector3 = CachedSolutionValue.targetDirection or CachedDirectionVector3
				if typeof(CachedMuzzleOriginVector3) == "Vector3"
					and typeof(CachedTargetDirectionVector3) == "Vector3"
					and CachedTargetDirectionVector3.Magnitude > 0.001 then
					if CachedPriorityNumber >= 3 and CurrentLocalGunRaycastParamsObject then
						local CachedTargetDistanceNumber = (TargetPositionVector3 - CachedMuzzleOriginVector3).Magnitude
						if CachedTargetDistanceNumber > 0.001 then
							local CachedRaycastResult = RunUnredirectedWorkspaceRaycast(
								CachedMuzzleOriginVector3,
								CachedTargetDirectionVector3.Unit * math.max(CachedTargetDistanceNumber + 6, 12),
								CurrentLocalGunRaycastParamsObject
							)
							CachedSolutionCanBeReusedBoolean = IsRaycastResultTargetHit(CachedRaycastResult, TargetCharacterModel)
						end
					elseif CachedPriorityNumber >= 2
						and CachedSolutionValue.headPosition
						and CurrentLocalGunCheckParamsObject then
							local CachedHeadRaycastResult = RunUnredirectedWorkspaceRaycast(
								CachedSolutionValue.headPosition,
								CachedDirectionVector3.Unit * 3.5,
								CurrentLocalGunCheckParamsObject
							)
							CachedSolutionCanBeReusedBoolean = CachedHeadRaycastResult == nil
						end
					end
				end
			end
			if CachedSolutionTable
				and CachedSolutionCanBeReusedBoolean
				and (tick() - (CachedSolutionTable.time or 0)) < SkyAimSolutionCacheDurationNumber
				and CachedSolutionTable.localCharacter == LocalCharacterModel
				and CachedSolutionTable.targetCharacter == TargetCharacterModel
				and CachedSolutionTable.targetPart == TargetPartInstance
				and typeof(CachedSolutionTable.targetPosition) == "Vector3"
				and (CachedSolutionTable.targetPosition - TargetPositionVector3).Magnitude <= 0.05
				and typeof(CachedSolutionTable.muzzleOrigin) == "Vector3"
				and (CachedSolutionTable.muzzleOrigin - MuzzleOriginVector3).Magnitude <= 0.05
				and typeof(CachedSolutionTable.headPosition) == "Vector3"
				and (CachedSolutionTable.headPosition - HeadPositionVector3).Magnitude <= 0.05 then
			return CachedSolutionTable.solution
		end
	end

	local TargetDistanceNumber = (TargetPositionVector3 - MuzzleOriginVector3).Magnitude
	local AlignmentToleranceNumber = GetSkyAimAlignmentTolerance(TargetPartInstance)
	local BestSolutionTable = nil
	local BestApproximateSolutionTable = nil
	local PreviousCandidateSolutionTable = nil
	local PreviousSkyAimCacheTable = ShieldModeRuntimeTable.skyAimSolutionCache
	local PreviousSkyAimSolutionTable = PreviousSkyAimCacheTable and PreviousSkyAimCacheTable.solution or nil
	local CandidateLockDurationNumber = math.max(tonumber(SkyAimCandidateLockDurationNumber) or 0, 0)
	if PreviousSkyAimSolutionTable
		and not PreviousSkyAimSolutionTable.isFallback
		and type(PreviousSkyAimSolutionTable.yaw) == "number"
		and type(PreviousSkyAimSolutionTable.pitch) == "number"
		and CandidateLockDurationNumber > 0
		and (tick() - (PreviousSkyAimCacheTable.time or 0)) < CandidateLockDurationNumber
		and PreviousSkyAimCacheTable.localCharacter == LocalCharacterModel
		and PreviousSkyAimCacheTable.targetCharacter == TargetCharacterModel
		and PreviousSkyAimCacheTable.targetPart == TargetPartInstance
		and PreviousSkyAimCacheTable.equippedTool == EquippedTool then
		PreviousCandidateSolutionTable = PreviousSkyAimSolutionTable
	end

	if RequiredPriorityNumber and RequiredPriorityNumber >= 3 and (not CurrentLocalGunRaycastParamsObject or TargetDistanceNumber <= 0.001) then
		return nil
	end

	local function ConsiderCandidate(CandidateDirectionVector3, CandidateFacingDirectionVector3, CandidateMuzzleOriginVector3, CandidateHeadPositionVector3, PitchDegreeNumber, YawDegreeNumber)
		local CandidateTargetOffsetVector3 = TargetPositionVector3 - CandidateMuzzleOriginVector3
		local CandidateHeadTargetOffsetVector3 = TargetPositionVector3 - CandidateHeadPositionVector3
		if CandidateTargetOffsetVector3.Magnitude <= 0.001 or CandidateHeadTargetOffsetVector3.Magnitude <= 0.001 then
			return
		end

		-- The pitch/yaw candidate is the simulated weapon pose. Reachability still
		-- follows the real muzzle-to-target line because the hook redirects that line.
		local CandidateTargetDirectionVector3 = CandidateTargetOffsetVector3.Unit
		local CandidateHeadTargetDirectionVector3 = CandidateHeadTargetOffsetVector3.Unit
		local MuzzleMissDistanceNumber, MuzzleAlongNumber = GetPointToRayDistance(
			TargetPositionVector3,
			CandidateMuzzleOriginVector3,
			CandidateTargetDirectionVector3
		)
		local HeadMissDistanceNumber, HeadAlongNumber = GetPointToRayDistance(
			TargetPositionVector3,
			CandidateHeadPositionVector3,
			CandidateHeadTargetDirectionVector3
		)
		local MissDistanceNumber = math.min(MuzzleMissDistanceNumber, HeadMissDistanceNumber)
		local AlongNumber = math.max(MuzzleAlongNumber, HeadAlongNumber)
		if AlongNumber <= 0 then
			return
		end

		local FlatFacingDirectionVector3 = Vector3.new(CandidateFacingDirectionVector3.X, 0, CandidateFacingDirectionVector3.Z)
		if FlatFacingDirectionVector3.Magnitude <= 0.001 then
			FlatFacingDirectionVector3 = BaseFlatDirectionVector3
		else
			FlatFacingDirectionVector3 = FlatFacingDirectionVector3.Unit
		end

		local AbsoluteYawNumber = math.abs(YawDegreeNumber)
		local PitchDistanceNumber = math.abs(PitchDegreeNumber - SkyAimPreferredPitchDegreesNumber)
		local CandidateSolutionTable = {
			direction = CandidateDirectionVector3,
			targetDirection = CandidateTargetDirectionVector3,
			muzzleOrigin = CandidateMuzzleOriginVector3,
			headPosition = CandidateHeadPositionVector3,
			hitPosition = CandidateMuzzleOriginVector3 + CandidateDirectionVector3 * SkyAimHitDistanceNumber,
			facingDirection = FlatFacingDirectionVector3,
			missDistance = MissDistanceNumber,
			upward = CandidateDirectionVector3.Y,
			yaw = YawDegreeNumber,
			yawAbs = AbsoluteYawNumber,
			pitch = PitchDegreeNumber,
			pitchDistance = PitchDistanceNumber,
			priority = 0,
		}

		if not BestApproximateSolutionTable
			or MissDistanceNumber < (BestApproximateSolutionTable.missDistance - 0.01)
			or (math.abs(MissDistanceNumber - BestApproximateSolutionTable.missDistance) <= 0.01
				and PitchDistanceNumber < ((BestApproximateSolutionTable.pitchDistance or math.huge) - 0.01))
			or (math.abs(MissDistanceNumber - BestApproximateSolutionTable.missDistance) <= 0.01
				and math.abs(PitchDistanceNumber - (BestApproximateSolutionTable.pitchDistance or math.huge)) <= 0.01
				and CandidateDirectionVector3.Y > (BestApproximateSolutionTable.upward or -math.huge)) then
			BestApproximateSolutionTable = CandidateSolutionTable
		end

		if MissDistanceNumber > (AlignmentToleranceNumber * 2.5) then
			return
		end

		local DirectHitBoolean = false
		local CandidateTargetDistanceNumber = (TargetPositionVector3 - CandidateMuzzleOriginVector3).Magnitude
		if CurrentLocalGunRaycastParamsObject and CandidateTargetDistanceNumber > 0.001 then
			local RaycastDistanceNumber = math.max(CandidateTargetDistanceNumber + 6, 12)
			local RaycastResult = RunUnredirectedWorkspaceRaycast(
				CandidateMuzzleOriginVector3,
				CandidateTargetDirectionVector3 * RaycastDistanceNumber,
				CurrentLocalGunRaycastParamsObject
			)
			DirectHitBoolean = IsRaycastResultTargetHit(RaycastResult, TargetCharacterModel)
		end

		if RequiredPriorityNumber and RequiredPriorityNumber >= 3 and not DirectHitBoolean then
			return
		end

		local HeadClearBoolean = true
		if CurrentLocalGunCheckParamsObject and (DirectHitBoolean or not RequiredPriorityNumber or RequiredPriorityNumber < 3) then
			HeadClearBoolean = RunUnredirectedWorkspaceRaycast(
				CandidateHeadPositionVector3,
				CandidateDirectionVector3 * 3.5,
				CurrentLocalGunCheckParamsObject
			) == nil
		end

		if DirectHitBoolean and HeadClearBoolean then
			CandidateSolutionTable.priority = 4
		elseif DirectHitBoolean then
			CandidateSolutionTable.priority = 3
		elseif HeadClearBoolean and MissDistanceNumber <= AlignmentToleranceNumber then
			CandidateSolutionTable.priority = 2
		elseif MissDistanceNumber <= AlignmentToleranceNumber then
			CandidateSolutionTable.priority = 1
		end

		local KeepPreviousDirectCandidateBoolean = PreviousCandidateSolutionTable
			and BestSolutionTable
			and (PreviousCandidateSolutionTable.priority or 0) >= 3
			and CandidateSolutionTable.priority >= 3
			and BestSolutionTable.priority >= 3
		if KeepPreviousDirectCandidateBoolean then
			local CandidateRotationChangeNumber = math.abs(CandidateSolutionTable.yaw - PreviousCandidateSolutionTable.yaw)
				+ math.abs(CandidateSolutionTable.pitch - PreviousCandidateSolutionTable.pitch)
			local BestRotationChangeNumber = math.abs(BestSolutionTable.yaw - PreviousCandidateSolutionTable.yaw)
				+ math.abs(BestSolutionTable.pitch - PreviousCandidateSolutionTable.pitch)
			if CandidateRotationChangeNumber < (BestRotationChangeNumber - 0.01) then
				BestSolutionTable = CandidateSolutionTable
			end
			return false
		end

		if not BestSolutionTable
			or CandidateSolutionTable.priority > (BestSolutionTable.priority or -math.huge)
			or (CandidateSolutionTable.priority == BestSolutionTable.priority
				and PitchDistanceNumber < ((BestSolutionTable.pitchDistance or math.huge) - 0.01))
			or (CandidateSolutionTable.priority == BestSolutionTable.priority
				and math.abs(PitchDistanceNumber - (BestSolutionTable.pitchDistance or math.huge)) <= 0.01
				and CandidateDirectionVector3.Y > ((BestSolutionTable.upward or -math.huge) + 0.001))
			or (CandidateSolutionTable.priority == BestSolutionTable.priority
				and math.abs(PitchDistanceNumber - (BestSolutionTable.pitchDistance or math.huge)) <= 0.01
				and math.abs(CandidateDirectionVector3.Y - (BestSolutionTable.upward or -math.huge)) <= 0.001
				and MissDistanceNumber < ((BestSolutionTable.missDistance or math.huge) - 0.01))
			or (CandidateSolutionTable.priority == BestSolutionTable.priority
				and math.abs(PitchDistanceNumber - (BestSolutionTable.pitchDistance or math.huge)) <= 0.01
				and math.abs(CandidateDirectionVector3.Y - (BestSolutionTable.upward or -math.huge)) <= 0.001
				and math.abs(MissDistanceNumber - (BestSolutionTable.missDistance or math.huge)) <= 0.01
				and AbsoluteYawNumber < (BestSolutionTable.yawAbs or math.huge)) then
			BestSolutionTable = CandidateSolutionTable
		end

		if RequiredPriorityNumber and CandidateSolutionTable.priority >= RequiredPriorityNumber then
			return true
		end

		return false
	end

	for _, PitchGroupTable in ipairs(GetSkyAimCandidateGroups(RequiredPriorityNumber)) do
		for _, YawEntryTable in ipairs(PitchGroupTable.yaws) do
			local CandidateFacingDirectionVector3 = BuildSkyAimCandidateFacingDirection(
				BaseFlatDirectionVector3,
				YawEntryTable.rotation
			)
			local CandidateMuzzleOriginVector3, CandidateHeadPositionVector3 = ResolveSkyAimCandidatePose(
				RootPartInstance,
				HeadPositionVector3,
				MuzzleOriginVector3,
				CandidateFacingDirectionVector3
			)
			local CandidateDirectionVector3 = BuildSkyAimCandidateDirection(
				CandidateFacingDirectionVector3,
				PitchGroupTable.sinPitch,
				PitchGroupTable.cosPitch
			)
			if CandidateDirectionVector3 then
				if ConsiderCandidate(
					CandidateDirectionVector3,
					CandidateFacingDirectionVector3,
					CandidateMuzzleOriginVector3,
					CandidateHeadPositionVector3,
					PitchGroupTable.pitch,
					YawEntryTable.yaw
				) then
					break
				end
			end
		end

		if BestSolutionTable
			and (
				((BestSolutionTable.priority or 0) >= 4)
				or (RequiredPriorityNumber and (BestSolutionTable.priority or 0) >= RequiredPriorityNumber)
			) then
			break
		end
	end

	local FinalSolutionTable = BestSolutionTable
	if FinalSolutionTable and (FinalSolutionTable.priority or 0) < 2 then
		FinalSolutionTable = nil
	end

	if RequiredPriorityNumber and RequiredPriorityNumber >= 3 then
		if not FinalSolutionTable or (FinalSolutionTable.priority or -math.huge) < RequiredPriorityNumber then
			return nil
		end
		return FinalSolutionTable
	end

	if not FinalSolutionTable then
		if BestApproximateSolutionTable
			and (BestApproximateSolutionTable.priority or 0) > 0
			and (BestApproximateSolutionTable.missDistance or math.huge) <= (AlignmentToleranceNumber * 4) then
			FinalSolutionTable = BestApproximateSolutionTable
		else
			FinalSolutionTable = FallbackSolutionTable
		end
	end

	if FinalSolutionTable then
		if TraceModeEnabledBoolean then
			TraceLog(
				"sky-aim-final",
				"pitch=" .. tostring(FinalSolutionTable.pitch)
					.. " | yaw=" .. tostring(FinalSolutionTable.yaw or 0)
					.. " | priority=" .. tostring(FinalSolutionTable.priority)
					.. " | miss=" .. string.format("%.2f", FinalSolutionTable.missDistance or -1)
					.. " | facing=" .. FormatDebugVector3(FinalSolutionTable.facingDirection)
					.. " | dir=" .. FormatDebugVector3(FinalSolutionTable.direction),
				false
			)
		end
	end

	if not SkipCacheBoolean then
		ShieldModeRuntimeTable.skyAimSolutionCache = {
			time = tick(),
			localCharacter = LocalCharacterModel,
			targetCharacter = TargetCharacterModel,
			targetPart = TargetPartInstance,
			targetPosition = TargetPositionVector3,
			muzzleOrigin = MuzzleOriginVector3,
			headPosition = HeadPositionVector3,
			equippedTool = EquippedTool,
			solution = FinalSolutionTable,
		}
	end
	return FinalSolutionTable
end
