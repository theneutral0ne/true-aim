function ShieldModeRuntimeTable.ResetState()
	ShieldModeRuntimeTable.SetReloadSuppressionEnabled(false)
	ShieldModeRuntimeTable.nextShotTime = 0
	ShieldModeRuntimeTable.pendingReequipTime = 0
	ShieldModeRuntimeTable.secondaryReadyTime = 0
	ShieldModeRuntimeTable.reloadHoldUntilTime = 0
	ShieldModeRuntimeTable.reloadObserved = false
	ShieldModeRuntimeTable.reloadDeferredForThreat = false
	ShieldModeRuntimeTable.reloadResumeUntilTime = 0
	ShieldModeRuntimeTable.lastThreatScanTime = 0
	ShieldModeRuntimeTable.cachedThreatData = nil
	ShieldModeRuntimeTable.cachedAimingThreatData = nil
	ShieldModeRuntimeTable.cachedThreatScanCharacter = nil
	ShieldModeRuntimeTable.cachedThreatScanFrameId = 0
	ShieldModeRuntimeTable.skyAimSolutionCache = nil
	ShieldModeRuntimeTable.shotSkyAimDataCache = nil
	ShieldModeRuntimeTable.forcedBodyRotationCFrame = nil
	ShieldModeRuntimeTable.lastEquipAttemptTime = 0
end

function ShieldModeRuntimeTable.GetLocalPlayerBackpack()
	return LocalPlayer and LocalPlayer.FindFirstChild(LocalPlayer, "Backpack") or nil
end

function ShieldModeRuntimeTable.GetEquippedTool(CharacterModel)
	if not CharacterModel then
		return nil
	end

	for _, ChildInstance in ipairs(CharacterModel.GetChildren(CharacterModel)) do
		if ChildInstance.IsA(ChildInstance, "Tool") then
			return ChildInstance
		end
	end

	return nil
end

function ShieldModeRuntimeTable.FindToolByNameInContainer(ContainerInstance, ToolNameString)
	if not ContainerInstance or type(ToolNameString) ~= "string" or ToolNameString == "" then
		return nil
	end

	for _, ChildInstance in ipairs(ContainerInstance.GetChildren(ContainerInstance)) do
		if ChildInstance.IsA(ChildInstance, "Tool") and ChildInstance.Name == ToolNameString then
			return ChildInstance
		end
	end

	return nil
end

function ShieldModeRuntimeTable.GetToolServiceName(ToolInstance)
	if not ToolInstance or not ToolInstance.GetAttribute then
		return nil
	end

	local ServiceNameString = ToolInstance.GetAttribute(ToolInstance, "Service")
	if type(ServiceNameString) == "string" and ServiceNameString ~= "" then
		return ServiceNameString
	end

	return nil
end

function ShieldModeRuntimeTable.IsToolReloading(ToolInstance)
	if not ToolInstance or not ToolInstance.GetAttribute then
		return false
	end

	return ToolInstance.GetAttribute(ToolInstance, "Reloading") == true
end

function ShieldModeRuntimeTable.FindLocalToolByName(CharacterModel, ToolNameString)
	return ShieldModeRuntimeTable.FindToolByNameInContainer(CharacterModel, ToolNameString)
		or ShieldModeRuntimeTable.FindToolByNameInContainer(ShieldModeRuntimeTable.GetLocalPlayerBackpack(), ToolNameString)
end

function ShieldModeRuntimeTable.GetLocalMetalShieldTool(CharacterModel)
	local DirectShieldTool = ShieldModeRuntimeTable.FindLocalToolByName(CharacterModel, "Metal Shield")
	if DirectShieldTool then
		return DirectShieldTool
	end

	local HeldItemStateTable = ShieldModeRuntimeTable.GetBloodZoneHeldItemState
		and ShieldModeRuntimeTable.GetBloodZoneHeldItemState(CharacterModel) or nil
	return HeldItemStateTable and HeldItemStateTable.shieldInstance or nil
end

function ShieldModeRuntimeTable.GetLocalSettings()
	return LocalPlayer and LocalPlayer.FindFirstChild(LocalPlayer, "Settings") or nil
end

function ShieldModeRuntimeTable.SetReloadSuppressionEnabled(EnabledBoolean)
	local SettingsInstance = ShieldModeRuntimeTable.GetLocalSettings()
	if not SettingsInstance or not SettingsInstance.GetAttribute or not SettingsInstance.SetAttribute then
		return
	end

	if EnabledBoolean then
		if not ShieldModeRuntimeTable.reloadSuppressionActive then
			ShieldModeRuntimeTable.savedAutoReloadSetting = SettingsInstance.GetAttribute(SettingsInstance, "AutoReload")
			ShieldModeRuntimeTable.savedCancelReloadingSetting = SettingsInstance.GetAttribute(SettingsInstance, "CancelReloading")
			ShieldModeRuntimeTable.reloadSuppressionActive = true
		end

		if SettingsInstance.GetAttribute(SettingsInstance, "AutoReload") ~= false then
			SettingsInstance.SetAttribute(SettingsInstance, "AutoReload", false)
		end
		if SettingsInstance.GetAttribute(SettingsInstance, "CancelReloading") ~= true then
			SettingsInstance.SetAttribute(SettingsInstance, "CancelReloading", true)
		end
		return
	end

	if not ShieldModeRuntimeTable.reloadSuppressionActive then
		return
	end

	local SavedAutoReloadSetting = ShieldModeRuntimeTable.savedAutoReloadSetting
	if SavedAutoReloadSetting ~= nil and SettingsInstance.GetAttribute(SettingsInstance, "AutoReload") ~= SavedAutoReloadSetting then
		SettingsInstance.SetAttribute(SettingsInstance, "AutoReload", SavedAutoReloadSetting)
	end

	local SavedCancelReloadingSetting = ShieldModeRuntimeTable.savedCancelReloadingSetting
	if SavedCancelReloadingSetting ~= nil and SettingsInstance.GetAttribute(SettingsInstance, "CancelReloading") ~= SavedCancelReloadingSetting then
		SettingsInstance.SetAttribute(SettingsInstance, "CancelReloading", SavedCancelReloadingSetting)
	end

	ShieldModeRuntimeTable.reloadSuppressionActive = false
	ShieldModeRuntimeTable.savedAutoReloadSetting = nil
	ShieldModeRuntimeTable.savedCancelReloadingSetting = nil
end

function ShieldModeRuntimeTable.GetGunCursorAmmoRotation()
	local PlayerGui = LocalPlayer and LocalPlayer.FindFirstChild(LocalPlayer, "PlayerGui") or nil
	local GunCursor = PlayerGui and PlayerGui.FindFirstChild(PlayerGui, "GunCursor") or nil
	local AmmoImage = GunCursor and GunCursor.FindFirstChild(GunCursor, "Ammo") or nil
	local GradientInstance = AmmoImage and AmmoImage.FindFirstChild(AmmoImage, "UIGradient") or nil
	if not GradientInstance then
		return nil
	end

	return tonumber(GradientInstance.Rotation)
end

function ShieldModeRuntimeTable.IsCurrentGunAmmoEmpty()
	local AmmoRotationNumber = ShieldModeRuntimeTable.GetGunCursorAmmoRotation()
	return type(AmmoRotationNumber) == "number" and AmmoRotationNumber >= 134.5
end

function ShieldModeRuntimeTable.IsPersistentSillySkyAimActive()
	return IsSillyModeBehaviorActive() and SillySkyAimEnabledBoolean and not ShieldModeEnabledBoolean
end

function ShieldModeRuntimeTable.IsSkyAimActive()
	return ShieldModeRuntimeTable.IsPersistentSillySkyAimActive()
end

local function GetFlatFacingDirectionVector3(DirectionVector3)
	if typeof(DirectionVector3) ~= "Vector3" then
		return nil
	end

	local FlatDirectionVector3 = Vector3.new(DirectionVector3.X, 0, DirectionVector3.Z)
	if FlatDirectionVector3.Magnitude <= 0.001 then
		return nil
	end

	return FlatDirectionVector3.Unit
end

local function AreCloseVector3Values(LeftVector3, RightVector3, ToleranceNumber)
	if typeof(LeftVector3) ~= "Vector3" or typeof(RightVector3) ~= "Vector3" then
		return LeftVector3 == RightVector3
	end

	return (LeftVector3 - RightVector3).Magnitude <= (ToleranceNumber or 0.05)
end

local function ResolveShotSkyAimDataTable(LocalCharacterModel, ReferenceDirectionVector3, EquippedTool)
	if not IsSillyModeBehaviorActive() then
		return nil
	end

	if not LocalCharacterModel or not LocalCharacterModel.Parent or (not EquippedTool and not HasEquippedTool(LocalCharacterModel)) then
		return nil
	end

	if not ShieldModeRuntimeTable.IsSkyAimActive() then
		return nil
	end

	local WeaponBallisticsProfileTable = CurrentWeaponBallisticsProfileTable
		or ShieldModeRuntimeTable.ResolveCurrentWeaponBallisticsProfile(LocalCharacterModel)
	local FrameIdNumber = tonumber(CurrentFrameSequenceNumber) or 0
	local TargetCharacterModel = CurrentTargetCharacterModel and CurrentTargetCharacterModel.Parent and CurrentTargetCharacterModel or nil
	local TargetPartInstance = CurrentTargetPartInstance and CurrentTargetPartInstance.Parent and CurrentTargetPartInstance or nil
	local AimPointVector3 = GetCurrentEffectiveAimPointVector3()
	if typeof(AimPointVector3) ~= "Vector3" and TargetPartInstance then
		AimPointVector3 = TargetPartInstance.Position
	end

	local CachedShotSkyAimDataTable = ShieldModeRuntimeTable.shotSkyAimDataCache
	if CachedShotSkyAimDataTable
		and CachedShotSkyAimDataTable.frameId == FrameIdNumber
		and CachedShotSkyAimDataTable.localCharacter == LocalCharacterModel
		and CachedShotSkyAimDataTable.weaponProfile == WeaponBallisticsProfileTable
		and CachedShotSkyAimDataTable.targetCharacter == TargetCharacterModel
		and CachedShotSkyAimDataTable.targetPart == TargetPartInstance
		and AreCloseVector3Values(CachedShotSkyAimDataTable.targetPoint, AimPointVector3, 0.05)
		and AreCloseVector3Values(CachedShotSkyAimDataTable.referenceDirection, ReferenceDirectionVector3, 0.01) then
		return CachedShotSkyAimDataTable.data
	end

	local function FinalizeShotSkyAimData(ShotSkyAimDataTable)
		ShieldModeRuntimeTable.shotSkyAimDataCache = {
			frameId = FrameIdNumber,
			localCharacter = LocalCharacterModel,
			weaponProfile = WeaponBallisticsProfileTable,
			targetCharacter = TargetCharacterModel,
			targetPart = TargetPartInstance,
			targetPoint = AimPointVector3,
			referenceDirection = ReferenceDirectionVector3,
			data = ShotSkyAimDataTable,
		}
		return ShotSkyAimDataTable
	end

	if ShieldModeRuntimeTable.IsProjectileWeaponProfile(WeaponBallisticsProfileTable) then
		local AimOriginVector3 = ResolveWeaponAimOriginVector3(LocalCharacterModel, WeaponBallisticsProfileTable)
		if typeof(AimOriginVector3) == "Vector3" and typeof(AimPointVector3) == "Vector3" then
			local DirectionVector3 = AimPointVector3 - AimOriginVector3
			if DirectionVector3.Magnitude > 0.001 then
				return FinalizeShotSkyAimData({
					direction = DirectionVector3.Unit,
					facingDirection = GetFlatFacingDirectionVector3(DirectionVector3),
				})
			end
		end

		return FinalizeShotSkyAimData(nil)
	end

	local SkyAimSolutionTable = ResolveSkyAimSolution(
		LocalCharacterModel,
		ReferenceDirectionVector3,
		EquippedTool,
		AimPointVector3,
		TargetCharacterModel,
		TargetPartInstance
	)
	if not SkyAimSolutionTable then
		return FinalizeShotSkyAimData(nil)
	end

	local FacingDirectionVector3 = SkyAimSolutionTable.facingDirection
	if typeof(FacingDirectionVector3) ~= "Vector3" then
		FacingDirectionVector3 = GetFlatFacingDirectionVector3(SkyAimSolutionTable.direction)
	end

	return FinalizeShotSkyAimData({
		direction = SkyAimSolutionTable.direction,
		facingDirection = FacingDirectionVector3,
		hitPosition = SkyAimSolutionTable.hitPosition,
		priority = SkyAimSolutionTable.priority,
	})
end

function ShieldModeRuntimeTable.GetShotSkyHitPosition()
	if not IsSillyModeBehaviorActive() then
		return nil
	end

	if not ShieldModeRuntimeTable.IsSkyAimActive() then
		return nil
	end

	local LocalCharacterModel = CurrentFrameLocalCharacterModel
	local LocalCharacterReadyBoolean = CurrentFrameLocalCharacterReadyBoolean
	if not LocalCharacterReadyBoolean or not LocalCharacterModel or not LocalCharacterModel.Parent then
		LocalCharacterModel = ResolveCharacterModelForPlayer(LocalPlayer)
		LocalCharacterReadyBoolean = IsLocalCharacterReadyForAimbot(LocalCharacterModel)
	end
	if not LocalCharacterReadyBoolean then
		return nil
	end

	local EquippedTool = ShieldModeRuntimeTable.GetEquippedTool(LocalCharacterModel)
	if not EquippedTool and not HasEquippedTool(LocalCharacterModel) then
		return nil
	end

	local ShotSkyAimDataTable = ResolveShotSkyAimDataTable(LocalCharacterModel, nil, EquippedTool)
	return ShotSkyAimDataTable and ShotSkyAimDataTable.hitPosition or nil
end

function ShieldModeRuntimeTable.GetShotSkyAimDirection(LocalCharacterModel, ReferenceDirectionVector3, EquippedTool)
	if not IsSillyModeBehaviorActive() then
		return nil
	end

	if not LocalCharacterModel or not LocalCharacterModel.Parent or (not EquippedTool and not HasEquippedTool(LocalCharacterModel)) then
		return nil
	end

	local HumanoidInstance = GetCharacterHumanoid(LocalCharacterModel)
	local RootPartInstance = GetCharacterRootPart(LocalCharacterModel)
	if not HumanoidInstance or not RootPartInstance or (tonumber(HumanoidInstance.Health) or 0) <= 0 then
		return nil
	end

	local ShotSkyAimDataTable = ResolveShotSkyAimDataTable(LocalCharacterModel, ReferenceDirectionVector3, EquippedTool)
	return ShotSkyAimDataTable and ShotSkyAimDataTable.direction or nil
end

function ShieldModeRuntimeTable.GetShotSkyFacingDirection(LocalCharacterModel, ReferenceDirectionVector3, EquippedTool)
	if not IsSillyModeBehaviorActive() then
		return nil
	end

	if not LocalCharacterModel or not LocalCharacterModel.Parent or (not EquippedTool and not HasEquippedTool(LocalCharacterModel)) then
		return nil
	end

	local HumanoidInstance = GetCharacterHumanoid(LocalCharacterModel)
	local RootPartInstance = GetCharacterRootPart(LocalCharacterModel)
	if not HumanoidInstance or not RootPartInstance or (tonumber(HumanoidInstance.Health) or 0) <= 0 then
		return nil
	end

	local ShotSkyAimDataTable = ResolveShotSkyAimDataTable(LocalCharacterModel, ReferenceDirectionVector3, EquippedTool)
	return ShotSkyAimDataTable and ShotSkyAimDataTable.facingDirection or nil
end

function ShieldModeRuntimeTable.ResolveCursorModule()
	if not IsBloodZonePlaceBoolean then
		return nil
	end

	if ShieldModeRuntimeTable.cursorModule then
		return ShieldModeRuntimeTable.cursorModule
	end

	local ModulesFolder = ReplicatedStorageService and ReplicatedStorageService.FindFirstChild(ReplicatedStorageService, "Modules") or nil
	local ClientFolder = ModulesFolder and ModulesFolder.FindFirstChild(ModulesFolder, "Client") or nil
	local HudFolder = ClientFolder and ClientFolder.FindFirstChild(ClientFolder, "HUD") or nil
	local GameUiFolder = HudFolder and HudFolder.FindFirstChild(HudFolder, "GameUi") or nil
	local CursorModuleScript = GameUiFolder and GameUiFolder.FindFirstChild(GameUiFolder, "Cursor") or nil
	if not CursorModuleScript then
		return nil
	end

	local SuccessBoolean, ModuleTable = pcall(require, CursorModuleScript)
	if not SuccessBoolean or type(ModuleTable) ~= "table" then
		return nil
	end

	ShieldModeRuntimeTable.cursorModule = ModuleTable
	return ModuleTable
end

function ShieldModeRuntimeTable.ResolveLocalGunModule()
	if not IsBloodZonePlaceBoolean then
		return nil
	end

	if ShieldModeRuntimeTable.localGunModule then
		return ShieldModeRuntimeTable.localGunModule
	end

	local ModulesFolder = ReplicatedStorageService and ReplicatedStorageService.FindFirstChild(ReplicatedStorageService, "Modules") or nil
	local ClientFolder = ModulesFolder and ModulesFolder.FindFirstChild(ModulesFolder, "Client") or nil
	local GameFolder = ClientFolder and ClientFolder.FindFirstChild(ClientFolder, "Game") or nil
	local WeaponClientModuleScript = GameFolder and GameFolder.FindFirstChild(GameFolder, "WeaponClient") or nil
	local LocalWeaponFolder = WeaponClientModuleScript and WeaponClientModuleScript.FindFirstChild(WeaponClientModuleScript, "LocalWeapon") or nil
	local LocalGunModuleScript = LocalWeaponFolder and LocalWeaponFolder.FindFirstChild(LocalWeaponFolder, "LocalGun") or nil
	if not LocalGunModuleScript then
		return nil
	end

	local SuccessBoolean, ModuleTable = pcall(require, LocalGunModuleScript)
	if not SuccessBoolean or type(ModuleTable) ~= "table" then
		return nil
	end

	ShieldModeRuntimeTable.localGunModule = ModuleTable
	return ModuleTable
end

function ShieldModeRuntimeTable.EnsureLocalGunHooks()
	if ShieldModeRuntimeTable.localGunHooksApplied or not IsBloodZonePlaceBoolean then
		return
	end

	local LocalGunModuleTable = ShieldModeRuntimeTable.ResolveLocalGunModule()
	local LocalGunOperationsTable = LocalGunModuleTable and (LocalGunModuleTable.__Operations or LocalGunModuleTable) or nil
	if not LocalGunOperationsTable
		or type(LocalGunOperationsTable.DoRecoil) ~= "function"
		or type(LocalGunOperationsTable.FireGun) ~= "function" then
		return
	end

	local OriginalDoRecoilFunction = LocalGunOperationsTable.DoRecoil
	local OriginalFireGunFunction = LocalGunOperationsTable.FireGun
	LocalGunOperationsTable.DoRecoil = function(SelfTable, ...)
		if IsSillyModeBehaviorActive() then
			local LocalCharacterModuleTable = ShieldModeRuntimeTable.ResolveLocalCharacterModule()
			if LocalCharacterModuleTable and type(LocalCharacterModuleTable.Rotate3rdPersonTime) == "number" then
				LocalCharacterModuleTable.Rotate3rdPersonTime = 0
			end
			return
		end

		return OriginalDoRecoilFunction(SelfTable, ...)
	end
	LocalGunOperationsTable.FireGun = function(SelfTable, ...)
		local PreviousActiveFiringLocalGun = ShieldModeRuntimeTable.activeFiringLocalGun
		ShieldModeRuntimeTable.activeFiringLocalGun = SelfTable
		local ResultTable = table.pack(pcall(OriginalFireGunFunction, SelfTable, ...))
		ShieldModeRuntimeTable.activeFiringLocalGun = PreviousActiveFiringLocalGun
		if not ResultTable[1] then
			error(ResultTable[2], 0)
		end
		return table.unpack(ResultTable, 2, ResultTable.n)
	end

	ShieldModeRuntimeTable.localGunHooksApplied = true
	DebugLog("localgun-hooks", "Installed Blood Zone LocalGun recoil and FireGun context hooks", true)
end

function ShieldModeRuntimeTable.EnsureCursorHooks()
	if ShieldModeRuntimeTable.cursorHooksApplied or not IsBloodZonePlaceBoolean then
		return
	end

	local CursorModuleTable = ShieldModeRuntimeTable.ResolveCursorModule()
	if not CursorModuleTable or type(CursorModuleTable.GetHit) ~= "function" then
		return
	end

	local OriginalGetHitFunction = CursorModuleTable.GetHit
	CursorModuleTable.GetHit = function(SelfTable, ...)
		if not CurrentTargetPartInstance or not CurrentTargetCharacterModel or not CurrentTargetPartInstance.Parent then
			return OriginalGetHitFunction(SelfTable, ...)
		end

		local LocalCharacterModel = CurrentFrameLocalCharacterModel
		local LocalCharacterReadyBoolean = CurrentFrameLocalCharacterReadyBoolean
		if not LocalCharacterReadyBoolean or not LocalCharacterModel or not LocalCharacterModel.Parent then
			LocalCharacterModel = ResolveCharacterModelForPlayer(LocalPlayer)
			LocalCharacterReadyBoolean = IsLocalCharacterReadyForAimbot(LocalCharacterModel)
			if not LocalCharacterReadyBoolean then
				return OriginalGetHitFunction(SelfTable, ...)
			end
		end

		local WeaponBallisticsProfileTable = CurrentWeaponBallisticsProfileTable
		if not WeaponBallisticsProfileTable then
			WeaponBallisticsProfileTable = ShieldModeRuntimeTable.ResolveCurrentWeaponBallisticsProfile(LocalCharacterModel)
		end
		if ShieldModeRuntimeTable.IsProjectileWeaponProfile(WeaponBallisticsProfileTable)
			and ShieldModeRuntimeTable.ShouldRedirectTowardCurrentTarget(LocalCharacterModel)
			and ShouldApplyNormalHookHitChance() then
			local ProjectileAimPointVector3 = GetCurrentEffectiveAimPointVector3()
			if typeof(ProjectileAimPointVector3) == "Vector3" then
				return ProjectileAimPointVector3
			end
		end

		if not IsSillyModeBehaviorActive() then
			return OriginalGetHitFunction(SelfTable, ...)
		end

		local ForcedHitPositionVector3 = ShieldModeRuntimeTable.GetShotSkyHitPosition()
		if ForcedHitPositionVector3 then
			return ForcedHitPositionVector3
		end

		return OriginalGetHitFunction(SelfTable, ...)
	end

	ShieldModeRuntimeTable.cursorHooksApplied = true
	DebugLog("shot-sky-cursor-hook", "Installed Blood Zone cursor hit override for shot sky aim", true)
end

local function CollectVisibleShieldParts(ShieldInstance)
	local ShieldPartsTable = {}
	if not ShieldInstance or not ShieldInstance.GetDescendants then
		return ShieldPartsTable
	end

	for _, DescendantInstance in ipairs(ShieldInstance.GetDescendants(ShieldInstance)) do
		if DescendantInstance.IsA(DescendantInstance, "BasePart")
			and DescendantInstance.Transparency < 0.95 then
			table.insert(ShieldPartsTable, DescendantInstance)
		end
	end

	return ShieldPartsTable
end

function ShieldModeRuntimeTable.GetBloodZoneHeldItemState(CharacterModel)
	local StateTable = {
		hasGun = false,
		hasShield = false,
		gunInstance = nil,
		shieldInstance = nil,
		shieldParts = nil,
	}
	if not IsBloodZonePlaceBoolean or not CharacterModel then
		return StateTable
	end

	local NowNumber = tick()
	local CachedEntryTable = ShieldModeRuntimeTable.heldItemStateCache and ShieldModeRuntimeTable.heldItemStateCache[CharacterModel] or nil
	if CachedEntryTable and (NowNumber - (CachedEntryTable.time or 0)) < (ShieldModeRuntimeTable.heldItemStateCacheDuration or 0) then
		return CachedEntryTable.state or StateTable
	end

	local SeenInstancesTable = {}
	local GetGunDataByNameFunction = ShieldModeRuntimeTable.GetGunDataByName
	local function MarkShield(ItemInstance)
		if not StateTable.shieldInstance then
			StateTable.shieldInstance = ItemInstance
		end
		StateTable.hasShield = true
	end
	local function MarkGun(ItemInstance)
		if not StateTable.gunInstance then
			StateTable.gunInstance = ItemInstance
		end
		StateTable.hasGun = true
	end
	local function ResolveHeldItemRoot(ItemInstance)
		local CurrentInstance = ItemInstance
		while CurrentInstance and CurrentInstance ~= CharacterModel do
			local ParentInstance = CurrentInstance.Parent
			if ParentInstance == CharacterModel then
				return CurrentInstance
			end
			if ParentInstance and ParentInstance.Name == "EmoteAddons" and ParentInstance.Parent == CharacterModel then
				return CurrentInstance
			end
			CurrentInstance = ParentInstance
		end
		return ItemInstance
	end
	local function ConsiderHeldItem(ItemInstance)
		if not ItemInstance or SeenInstancesTable[ItemInstance] then
			return
		end
		SeenInstancesTable[ItemInstance] = true

		local ItemNameString = ItemInstance.Name
		if ItemNameString == "Metal Shield" then
			MarkShield(ItemInstance)
		end

		local ServiceNameString = ItemInstance.GetAttribute and ItemInstance.GetAttribute(ItemInstance, "Service") or nil
		if ServiceNameString == "GunService" then
			MarkGun(ItemInstance)
		elseif type(ItemNameString) == "string"
			and ItemNameString ~= ""
			and ItemNameString ~= "Metal Shield"
			and GetGunDataByNameFunction
			and GetGunDataByNameFunction(ItemNameString) ~= nil then
			MarkGun(ItemInstance)
		end

		if ItemInstance.FindFirstChild and ItemInstance.FindFirstChild(ItemInstance, "GUN_CORE", true) then
			MarkGun(ItemInstance)
		end
	end

	for _, ChildInstance in ipairs(CharacterModel.GetChildren(CharacterModel)) do
		if ChildInstance.IsA(ChildInstance, "Tool") then
			ConsiderHeldItem(ChildInstance)
		end
	end

	local EmoteAddonsFolder = CharacterModel.FindFirstChild and CharacterModel.FindFirstChild(CharacterModel, "EmoteAddons") or nil
	local HasEmoteAddonChildrenBoolean = false
	if EmoteAddonsFolder then
		for _, ChildInstance in ipairs(EmoteAddonsFolder.GetChildren(EmoteAddonsFolder)) do
			HasEmoteAddonChildrenBoolean = true
			ConsiderHeldItem(ChildInstance)
		end
	end

	if HasEmoteAddonChildrenBoolean and (not StateTable.hasGun or not StateTable.hasShield) then
		for _, DescendantInstance in ipairs(CharacterModel.GetDescendants(CharacterModel)) do
			if not StateTable.hasShield and DescendantInstance.Name == "Metal Shield" then
				MarkShield(ResolveHeldItemRoot(DescendantInstance))
			end

			if not StateTable.hasGun then
				if DescendantInstance.Name == "GUN_CORE" then
					MarkGun(ResolveHeldItemRoot(DescendantInstance))
				else
					local ServiceNameString = DescendantInstance.GetAttribute and DescendantInstance.GetAttribute(DescendantInstance, "Service") or nil
					if ServiceNameString == "GunService" then
						MarkGun(ResolveHeldItemRoot(DescendantInstance))
					end
				end
			end

			if StateTable.hasGun and StateTable.hasShield then
				break
			end
		end
	end

	if StateTable.shieldInstance then
		StateTable.shieldParts = CollectVisibleShieldParts(StateTable.shieldInstance)
	end

	if ShieldModeRuntimeTable.heldItemStateCache then
		ShieldModeRuntimeTable.heldItemStateCache[CharacterModel] = {
			time = NowNumber,
			state = StateTable,
		}
	end

	return StateTable
end

function ShieldModeRuntimeTable.GetBloodZoneShieldVisibleParts(CharacterModel)
	if not IsBloodZonePlaceBoolean or not CharacterModel then
		return nil
	end

	local StateTable = ShieldModeRuntimeTable.GetBloodZoneHeldItemState(CharacterModel)
	return StateTable and StateTable.shieldParts or nil
end

function ShieldModeRuntimeTable.ResolveModuleData()
	if not IsBloodZonePlaceBoolean then
		return nil, nil
	end

	local ModulesFolder = ReplicatedStorageService and ReplicatedStorageService.FindFirstChild(ReplicatedStorageService, "Modules") or nil
	if not ModulesFolder then
		return ShieldModeRuntimeTable.localData, ShieldModeRuntimeTable.weaponData
	end

	if not ShieldModeRuntimeTable.localData then
		local ClientFolder = ModulesFolder.FindFirstChild(ModulesFolder, "Client")
		local LocalDataModule = ClientFolder and ClientFolder.FindFirstChild(ClientFolder, "LocalData")
		if LocalDataModule then
			local SuccessBoolean, ResultValue = pcall(require, LocalDataModule)
			if SuccessBoolean and type(ResultValue) == "table" then
				ShieldModeRuntimeTable.localData = ResultValue
			end
		end
	end

	if not ShieldModeRuntimeTable.weaponData then
		local DataFolder = ModulesFolder.FindFirstChild(ModulesFolder, "Data")
		local WeaponDataModule = DataFolder and DataFolder.FindFirstChild(DataFolder, "WeaponData")
		if WeaponDataModule then
			local SuccessBoolean, ResultValue = pcall(require, WeaponDataModule)
			if SuccessBoolean and type(ResultValue) == "table" then
				ShieldModeRuntimeTable.weaponData = ResultValue
			end
		end
	end

	return ShieldModeRuntimeTable.localData, ShieldModeRuntimeTable.weaponData
end

function ShieldModeRuntimeTable.GetLoadoutWeaponName(SlotNameString)
	local LocalDataTable = ShieldModeRuntimeTable.ResolveModuleData()
	local DataSlotTable = LocalDataTable and LocalDataTable.DataSlot or nil
	local LoadoutTable = DataSlotTable and DataSlotTable.Loadout or nil
	local WeaponNameString = LoadoutTable and LoadoutTable[SlotNameString] or nil
	if type(WeaponNameString) == "string" and WeaponNameString ~= "" then
		return WeaponNameString
	end

	return nil
end

function ShieldModeRuntimeTable.GetGunDataByName(WeaponNameString)
	if type(WeaponNameString) ~= "string" or WeaponNameString == "" then
		return nil
	end

	local _, WeaponDataTable = ShieldModeRuntimeTable.ResolveModuleData()
	local GunDataTable = WeaponDataTable and WeaponDataTable.Gun or nil
	local WeaponEntryTable = GunDataTable and GunDataTable[WeaponNameString] or nil
	if type(WeaponEntryTable) == "table" then
		return WeaponEntryTable
	end

	return nil
end

function ShieldModeRuntimeTable.IsGunTool(ToolInstance)
	if not ToolInstance or not ToolInstance.IsA(ToolInstance, "Tool") then
		return false
	end

	local ServiceNameString = ShieldModeRuntimeTable.GetToolServiceName(ToolInstance)
	if ServiceNameString == "GunService" then
		return true
	end

	if ToolInstance.FindFirstChild(ToolInstance, "GUN_CORE", true) then
		return true
	end

	return ShieldModeRuntimeTable.GetGunDataByName(ToolInstance.Name) ~= nil
end

function ShieldModeRuntimeTable.GetEquippedGunTool(CharacterModel)
	local EquippedTool = ShieldModeRuntimeTable.GetEquippedTool(CharacterModel)
	if not EquippedTool or EquippedTool.Name == "Metal Shield" then
		return nil
	end

	if ShieldModeRuntimeTable.IsGunTool(EquippedTool) then
		return EquippedTool
	end

	return nil
end

function ShieldModeRuntimeTable.IsThreatCharacterValid(CharacterModel)
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

	if IsCharacterForceFieldProtected(CharacterModel, Humanoid) then
		return false
	end

	local HealthNumber = Humanoid.Health
	if type(HealthNumber) ~= "number" or HealthNumber <= 0 then
		return false
	end

	if ShieldModeRuntimeTable.GetEquippedGunTool(CharacterModel) then
		return true
	end

	local HeldItemStateTable = ShieldModeRuntimeTable.GetBloodZoneHeldItemState
		and ShieldModeRuntimeTable.GetBloodZoneHeldItemState(CharacterModel) or nil
	return HeldItemStateTable ~= nil and HeldItemStateTable.hasGun == true
end

function ShieldModeRuntimeTable.GetThreatAimData(ThreatCharacterModel, LocalCharacterModel)
	if not ShieldModeRuntimeTable.IsThreatCharacterValid(ThreatCharacterModel) then
		return nil
	end

	local ThreatHeadPartInstance = GetCharacterHeadPart(ThreatCharacterModel)
	local ThreatRootPartInstance = GetCharacterRootPart(ThreatCharacterModel)
	local ThreatOriginPartInstance = ThreatHeadPartInstance or ThreatRootPartInstance
	local LocalRootPartInstance = GetCharacterRootPart(LocalCharacterModel)
	local LocalHeadPartInstance = GetCharacterHeadPart(LocalCharacterModel)
	if not ThreatOriginPartInstance or not LocalRootPartInstance then
		return nil
	end

	local CandidateLocalParts = {}
	if LocalHeadPartInstance then
		table.insert(CandidateLocalParts, LocalHeadPartInstance)
	end
	table.insert(CandidateLocalParts, LocalRootPartInstance)

	local PreferredLocalPartInstance = GetPreferredTargetPart(LocalCharacterModel)
	if PreferredLocalPartInstance and PreferredLocalPartInstance ~= LocalHeadPartInstance and PreferredLocalPartInstance ~= LocalRootPartInstance then
		table.insert(CandidateLocalParts, PreferredLocalPartInstance)
	end

	local ThreatOriginVector3 = ThreatOriginPartInstance.Position
	local BestThreatData = nil
	for _, LocalPartInstance in ipairs(CandidateLocalParts) do
		local ToLocalVector3 = LocalPartInstance.Position - ThreatOriginVector3
		local DistanceNumber = ToLocalVector3.Magnitude
		if DistanceNumber <= 0.001 or DistanceNumber > MaxDistanceNumber then
			continue
		end

		local ToLocalUnitVector3 = ToLocalVector3.Unit
		local HeadLookDotNumber = ThreatHeadPartInstance and ThreatHeadPartInstance.CFrame.LookVector:Dot(ToLocalUnitVector3) or -1
		local RootLookDotNumber = ThreatRootPartInstance and ThreatRootPartInstance.CFrame.LookVector:Dot(ToLocalUnitVector3) or -1
		local AimDotNumber = math.max(HeadLookDotNumber, RootLookDotNumber)
		if AimDotNumber < 0.82 then
			continue
		end

		local LineOfSightResult = RaycastBetweenIgnoringGlass(
			ThreatOriginVector3,
			LocalPartInstance.Position,
			{ ThreatCharacterModel, LocalCharacterModel }
		)
		if LineOfSightResult then
			continue
		end

		local ThreatScoreNumber = (AimDotNumber * 1000) - (DistanceNumber * 0.12) + (HeadLookDotNumber * 35)
		if not BestThreatData or ThreatScoreNumber > BestThreatData.score then
			BestThreatData = {
				character = ThreatCharacterModel,
				part = ThreatOriginPartInstance,
				position = ThreatOriginVector3,
				targetPart = LocalPartInstance,
				targetPosition = LocalPartInstance.Position,
				score = ThreatScoreNumber,
				dot = AimDotNumber,
				distance = DistanceNumber,
				source = "aiming",
			}
		end
	end

	return BestThreatData
end

function ShieldModeRuntimeTable.ResolveDirectionIndicatorModule()
	if not IsBloodZonePlaceBoolean then
		return nil
	end

	if ShieldModeRuntimeTable.directionIndicatorModule then
		return ShieldModeRuntimeTable.directionIndicatorModule
	end

	local ModulesFolder = ReplicatedStorageService and ReplicatedStorageService.FindFirstChild(ReplicatedStorageService, "Modules") or nil
	local ClientFolder = ModulesFolder and ModulesFolder.FindFirstChild(ModulesFolder, "Client") or nil
	local HudFolder = ClientFolder and ClientFolder.FindFirstChild(ClientFolder, "HUD") or nil
	local GameUiFolder = HudFolder and HudFolder.FindFirstChild(HudFolder, "GameUi") or nil
	local CursorFolder = GameUiFolder and GameUiFolder.FindFirstChild(GameUiFolder, "Cursor") or nil
	local DirectionIndicatorModuleScript = CursorFolder and CursorFolder.FindFirstChild(CursorFolder, "DirectionIndicator") or nil
	if not DirectionIndicatorModuleScript then
		return nil
	end

	local SuccessBoolean, ModuleTable = pcall(require, DirectionIndicatorModuleScript)
	if not SuccessBoolean or type(ModuleTable) ~= "table" then
		return nil
	end

	ShieldModeRuntimeTable.directionIndicatorModule = ModuleTable
	return ModuleTable
end

function ShieldModeRuntimeTable.GetDamageIndicatorThreatData(LocalCharacterModel)
	local DirectionIndicatorModuleTable = ShieldModeRuntimeTable.ResolveDirectionIndicatorModule()
	local ActiveIndicatorsTable = DirectionIndicatorModuleTable and DirectionIndicatorModuleTable.ActiveIndicators or nil
	local LocalRootPartInstance = GetCharacterRootPart(LocalCharacterModel)
	if type(ActiveIndicatorsTable) ~= "table" or not LocalRootPartInstance then
		return nil
	end

	local BestThreatData = nil
	for SubjectValue, IndicatorData in pairs(ActiveIndicatorsTable) do
		local WorldPositionVector3 = IndicatorData and IndicatorData.WorldPosition or nil
		local DeleteTimerNumber = tonumber(IndicatorData and IndicatorData.DeleteTimer) or 0
		if typeof(WorldPositionVector3) ~= "Vector3" or DeleteTimerNumber <= 0 then
			continue
		end

		local FlatDirectionVector3 = Vector3.new(
			WorldPositionVector3.X - LocalRootPartInstance.Position.X,
			0,
			WorldPositionVector3.Z - LocalRootPartInstance.Position.Z
		)
		local FlatDistanceNumber = FlatDirectionVector3.Magnitude
		if FlatDistanceNumber <= 0.001 then
			continue
		end

		local ThreatScoreNumber = DeleteTimerNumber * 1000 - FlatDistanceNumber * 0.05
		if not BestThreatData or ThreatScoreNumber > BestThreatData.score then
			BestThreatData = {
				character = nil,
				part = nil,
				position = WorldPositionVector3,
				score = ThreatScoreNumber,
				dot = 1,
				distance = FlatDistanceNumber,
				source = "damage",
				subject = SubjectValue,
			}
		end
	end

	return BestThreatData
end

function ShieldModeRuntimeTable.GetVisibleArmedThreatData(ThreatCharacterModel, LocalCharacterModel)
	if not ShieldModeRuntimeTable.IsThreatCharacterValid(ThreatCharacterModel) then
		return nil
	end

	local ThreatPartInstance = GetPreferredTargetPart(ThreatCharacterModel) or GetCharacterRootPart(ThreatCharacterModel) or GetCharacterHeadPart(ThreatCharacterModel)
	local LocalRootPartInstance = GetCharacterRootPart(LocalCharacterModel)
	if not ThreatPartInstance or not LocalRootPartInstance then
		return nil
	end

	local ThreatPositionVector3 = ThreatPartInstance.Position
	local FlatDirectionVector3 = Vector3.new(
		ThreatPositionVector3.X - LocalRootPartInstance.Position.X,
		0,
		ThreatPositionVector3.Z - LocalRootPartInstance.Position.Z
	)
	local FlatDistanceNumber = FlatDirectionVector3.Magnitude
	if FlatDistanceNumber <= 0.001 or FlatDistanceNumber > MaxDistanceNumber then
		return nil
	end

	local LineOfSightResult = RaycastBetweenIgnoringGlass(
		LocalRootPartInstance.Position,
		ThreatPositionVector3,
		{ ThreatCharacterModel, LocalCharacterModel }
	)
	if LineOfSightResult then
		return nil
	end

	return {
		character = ThreatCharacterModel,
		part = ThreatPartInstance,
		position = ThreatPositionVector3,
		score = 500 - FlatDistanceNumber * 0.1,
		dot = 0,
		distance = FlatDistanceNumber,
		source = "visible",
	}
end

local function IsThreatDataCacheEntryUsable(ThreatDataTable)
	return ThreatDataTable == nil
		or (ThreatDataTable.position ~= nil
			and ((not ThreatDataTable.character) or ThreatDataTable.character.Parent))
end

local function ResolveCachedThreatData(LocalCharacterModel)
	if not LocalCharacterModel then
		return nil, nil
	end

	local NowNumber = tick()
	local FrameIdNumber = tonumber(CurrentFrameSequenceNumber) or 0
	local CacheAgeNumber = NowNumber - (ShieldModeRuntimeTable.lastThreatScanTime or 0)
	local CacheCharacterMatchesBoolean = ShieldModeRuntimeTable.cachedThreatScanCharacter == LocalCharacterModel
	local CacheIsCurrentFrameBoolean = FrameIdNumber > 0
		and ShieldModeRuntimeTable.cachedThreatScanFrameId == FrameIdNumber
	local CacheIsFreshBoolean = CacheAgeNumber < (ShieldModeRuntimeTable.threatScanInterval or 0.08)
	if CacheCharacterMatchesBoolean
		and (CacheIsCurrentFrameBoolean or CacheIsFreshBoolean)
		and IsThreatDataCacheEntryUsable(ShieldModeRuntimeTable.cachedThreatData)
		and IsThreatDataCacheEntryUsable(ShieldModeRuntimeTable.cachedAimingThreatData) then
		return ShieldModeRuntimeTable.cachedThreatData, ShieldModeRuntimeTable.cachedAimingThreatData
	end

	ShieldModeRuntimeTable.lastThreatScanTime = NowNumber
	ShieldModeRuntimeTable.cachedThreatScanCharacter = LocalCharacterModel
	ShieldModeRuntimeTable.cachedThreatScanFrameId = FrameIdNumber
	ShieldModeRuntimeTable.cachedThreatData = nil
	ShieldModeRuntimeTable.cachedAimingThreatData = nil

	local TeamCheckEnabledBoolean = false
	local LocalTeamObject = nil
	if not IsCustomCharacterGameBoolean and LocalPlayer.Team ~= nil then
		TeamCheckEnabledBoolean = true
		LocalTeamObject = LocalPlayer.Team
	end

	local BestThreatData = ShieldModeRuntimeTable.GetDamageIndicatorThreatData(LocalCharacterModel)
	local BestAimingThreatData = nil
	local CharacterEntries = GetSearchableCharacterEntries(LocalCharacterModel, TeamCheckEnabledBoolean, LocalTeamObject)
	for _, CharacterEntry in ipairs(CharacterEntries) do
		local AimingThreatData = ShieldModeRuntimeTable.GetThreatAimData(CharacterEntry.character, LocalCharacterModel)
		if AimingThreatData and (not BestAimingThreatData or AimingThreatData.score > BestAimingThreatData.score) then
			BestAimingThreatData = AimingThreatData
		end

		local ThreatData = AimingThreatData
		if not ThreatData then
			ThreatData = ShieldModeRuntimeTable.GetVisibleArmedThreatData(CharacterEntry.character, LocalCharacterModel)
		end
		if ThreatData and (not BestThreatData or ThreatData.score > BestThreatData.score) then
			BestThreatData = ThreatData
		end
	end

	ShieldModeRuntimeTable.cachedThreatData = BestThreatData
	ShieldModeRuntimeTable.cachedAimingThreatData = BestAimingThreatData
	return BestThreatData, BestAimingThreatData
end

function ShieldModeRuntimeTable.ResolveThreatData(LocalCharacterModel)
	local ThreatData = ResolveCachedThreatData(LocalCharacterModel)
	return ThreatData
end

function ShieldModeRuntimeTable.ResolveAimingThreatData(LocalCharacterModel)
	local _, AimingThreatData = ResolveCachedThreatData(LocalCharacterModel)
	return AimingThreatData
end

function ShieldModeRuntimeTable.GetThreatFacingDirection(LocalCharacterModel, MetalShieldTool, EquippedTool)
	if not IsEffectiveShieldModeEnabled() or not LocalCharacterModel or not MetalShieldTool then
		return nil, nil
	end

	local LocalRootPartInstance = GetCharacterRootPart(LocalCharacterModel)
	if not LocalRootPartInstance then
		return nil, nil
	end

	local ThreatData = ShieldModeRuntimeTable.ResolveThreatData(LocalCharacterModel)
	if not ThreatData or not ThreatData.position then
		return nil, nil
	end

	local FlatDirectionVector3 = Vector3.new(
		ThreatData.position.X - LocalRootPartInstance.Position.X,
		0,
		ThreatData.position.Z - LocalRootPartInstance.Position.Z
	)
	if FlatDirectionVector3.Magnitude <= 0.001 then
		return nil, nil
	end

	return FlatDirectionVector3.Unit, ThreatData
end

local function GetThreatAimDirectionVector3(LocalCharacterModel, ThreatData, FallbackDirectionVector3)
	if not LocalCharacterModel or not ThreatData or typeof(ThreatData.position) ~= "Vector3" then
		return FallbackDirectionVector3
	end

	local AimOriginPartInstance = GetCharacterHeadPart(LocalCharacterModel) or GetCharacterRootPart(LocalCharacterModel)
	if not AimOriginPartInstance then
		return FallbackDirectionVector3
	end

	local ThreatAimDirectionVector3 = ThreatData.position - AimOriginPartInstance.Position
	if ThreatAimDirectionVector3.Magnitude <= 0.001 then
		return FallbackDirectionVector3
	end

	return ThreatAimDirectionVector3.Unit
end

function ShieldModeRuntimeTable.ApplyBodyFacingOverride(SelfTable, FacingDirectionVector3, DeltaTimeNumber)
	if not FacingDirectionVector3
		or not SelfTable
		or not SelfTable.Root
		or not SelfTable.Head
		or not SelfTable.Humanoid
		or not SelfTable.Character
		or not SelfTable.Character.PivotTo
		or SelfTable.Humanoid.GetState(SelfTable.Humanoid) == Enum.HumanoidStateType.Climbing then
		return false
	end

	if SelfTable.Root == WorkspaceService or SelfTable.Character == WorkspaceService or SelfTable.Head == WorkspaceService then
		TraceLog(
			"body-face-workspace",
			"root=" .. DescribeDebugInstance(SelfTable.Root)
				.. " | head=" .. DescribeDebugInstance(SelfTable.Head)
				.. " | character=" .. DescribeDebugInstance(SelfTable.Character)
				.. " | facing=" .. FormatDebugVector3(FacingDirectionVector3),
			true
		)
	end

	local FlatDirectionVector3 = Vector3.new(FacingDirectionVector3.X, 0, FacingDirectionVector3.Z)
	if FlatDirectionVector3.Magnitude <= 0.001 then
		return false
	end

	local TargetRotationCFrame = CFrame.new(SelfTable.Root.Position, SelfTable.Root.Position + FlatDirectionVector3.Unit)
	local PreviousRotationCFrame = ShieldModeRuntimeTable.forcedBodyRotationCFrame or SelfTable.Root.CFrame.Rotation
	local RotationAlphaNumber = math.clamp((tonumber(DeltaTimeNumber) or 0.016) * 10, 0, 1)
	local NewRotationCFrame = CFrame.new(SelfTable.Root.Position) * PreviousRotationCFrame:Lerp(TargetRotationCFrame.Rotation, RotationAlphaNumber)
	SelfTable.Humanoid.AutoRotate = false
	SelfTable.Character.PivotTo(SelfTable.Character, NewRotationCFrame)
	ShieldModeRuntimeTable.forcedBodyRotationCFrame = NewRotationCFrame.Rotation

	local CharacterHumanoid = SelfTable.Character.FindFirstChild and SelfTable.Character.FindFirstChild(SelfTable.Character, "Humanoid") or nil
	if CharacterHumanoid then
		CharacterHumanoid.CameraOffset = (SelfTable.Root.CFrame * CFrame.new(0, 1.5, 0)):PointToObjectSpace(SelfTable.Head.Position)
	end

	if type(SelfTable.Rotate3rdPersonTime) == "number" then
		SelfTable.Rotate3rdPersonTime = math.max(SelfTable.Rotate3rdPersonTime, 0.2)
	end

	return true
end

function ShieldModeRuntimeTable.ShouldDelayReloadForThreat(LocalCharacterModel)
	local ThreatData = LocalCharacterModel and ShieldModeRuntimeTable.ResolveAimingThreatData(LocalCharacterModel) or nil
	if not ThreatData then
		return false, nil
	end

	return (tonumber(ThreatData.dot) or -1) >= 0.88, ThreatData
end

function ShieldModeRuntimeTable.ResolveLocalCharacterModule()
	if not IsBloodZonePlaceBoolean then
		return nil
	end

	if ShieldModeRuntimeTable.localCharacterModule then
		return ShieldModeRuntimeTable.localCharacterModule
	end

	local ModulesFolder = ReplicatedStorageService and ReplicatedStorageService.FindFirstChild(ReplicatedStorageService, "Modules") or nil
	local ClientFolder = ModulesFolder and ModulesFolder.FindFirstChild(ModulesFolder, "Client") or nil
	local GameFolder = ClientFolder and ClientFolder.FindFirstChild(ClientFolder, "Game") or nil
	local LocalCharacterModuleScript = GameFolder and GameFolder.FindFirstChild(GameFolder, "LocalCharacter") or nil
	if not LocalCharacterModuleScript then
		return nil
	end

	local SuccessBoolean, ModuleTable = pcall(require, LocalCharacterModuleScript)
	if not SuccessBoolean or type(ModuleTable) ~= "table" then
		return nil
	end

	ShieldModeRuntimeTable.localCharacterModule = ModuleTable
	return ModuleTable
end

function ShieldModeRuntimeTable.EnsureLocalCharacterHooks()
	if ShieldModeRuntimeTable.localCharacterHooksApplied or not IsBloodZonePlaceBoolean then
		return
	end

	local LocalCharacterModuleTable = ShieldModeRuntimeTable.ResolveLocalCharacterModule()
	if not LocalCharacterModuleTable then
		return
	end

	local OriginalUpdateLookFunction = LocalCharacterModuleTable.UpdateLook
	local OriginalUpdateLimbsFunction = LocalCharacterModuleTable.UpdateLimbs
	if type(OriginalUpdateLookFunction) ~= "function" or type(OriginalUpdateLimbsFunction) ~= "function" then
		return
	end

	LocalCharacterModuleTable.UpdateLook = function(SelfTable, DirectionVector3, DeltaTimeNumber)
		if IsSillyModeBehaviorActive() and type(SelfTable and SelfTable.Rotate3rdPersonTime) == "number" then
			SelfTable.Rotate3rdPersonTime = 0
		end

		local LocalCharacterModel = SelfTable and SelfTable.Character or nil
		local MetalShieldTool = LocalCharacterModel and ShieldModeRuntimeTable.GetLocalMetalShieldTool(LocalCharacterModel) or nil
		local EquippedTool = LocalCharacterModel and ShieldModeRuntimeTable.GetEquippedTool(LocalCharacterModel) or nil
		local ForcedDirectionVector3, ThreatData = ShieldModeRuntimeTable.GetThreatFacingDirection(LocalCharacterModel, MetalShieldTool, EquippedTool)
		local ThreatAimDirectionVector3 = GetThreatAimDirectionVector3(LocalCharacterModel, ThreatData, ForcedDirectionVector3)
		local ShotSkyAimDataTable = ResolveShotSkyAimDataTable(LocalCharacterModel, DirectionVector3, EquippedTool)
		local ShotSkyDirectionVector3 = ShotSkyAimDataTable and ShotSkyAimDataTable.direction or nil
		local ShotSkyFacingDirectionVector3 = ShotSkyAimDataTable and ShotSkyAimDataTable.facingDirection or nil

		if ForcedDirectionVector3 and ShieldModeRuntimeTable.ApplyBodyFacingOverride(SelfTable, ForcedDirectionVector3, DeltaTimeNumber) then
			DirectionVector3 = ThreatAimDirectionVector3 or DirectionVector3
			if type(SelfTable.Rotate3rdPersonTime) == "number" then
				SelfTable.Rotate3rdPersonTime = math.max(SelfTable.Rotate3rdPersonTime, 0.2)
			end
			if DebugModeEnabledBoolean then
				DebugLog(
					"shield-face-override",
					"Shield Mode overriding LocalCharacter.UpdateLook toward " .. GetCharacterModelDebugName(ThreatData.character)
						.. " | dot=" .. string.format("%.2f", ThreatData.dot or -1)
						.. " | aim=" .. FormatDebugVector3(ThreatAimDirectionVector3),
					false
				)
			end
			-- Do not call the original look update here. In first person it restores
			-- AutoRotate, which immediately undoes the forced shield-facing rotation.
			return
		end

		local AppliedShotSkyFacingOverrideBoolean = false
		if ShotSkyDirectionVector3 then
			if ShotSkyFacingDirectionVector3 then
				AppliedShotSkyFacingOverrideBoolean = ShieldModeRuntimeTable.ApplyBodyFacingOverride(
					SelfTable,
					ShotSkyFacingDirectionVector3,
					DeltaTimeNumber
				) == true
			end
			DirectionVector3 = ShotSkyDirectionVector3
			if type(SelfTable.Rotate3rdPersonTime) == "number" then
				SelfTable.Rotate3rdPersonTime = math.max(SelfTable.Rotate3rdPersonTime, 0.2)
			end
		end

		if not AppliedShotSkyFacingOverrideBoolean then
			ShieldModeRuntimeTable.forcedBodyRotationCFrame = nil
		end
		return OriginalUpdateLookFunction(SelfTable, DirectionVector3, DeltaTimeNumber)
	end

	LocalCharacterModuleTable.UpdateLimbs = function(SelfTable, DirectionVector3, DeltaTimeNumber)
		if IsSillyModeBehaviorActive() and type(SelfTable and SelfTable.Rotate3rdPersonTime) == "number" then
			SelfTable.Rotate3rdPersonTime = 0
		end

		local LocalCharacterModel = SelfTable and SelfTable.Character or nil
		local MetalShieldTool = LocalCharacterModel and ShieldModeRuntimeTable.GetLocalMetalShieldTool(LocalCharacterModel) or nil
		local EquippedTool = LocalCharacterModel and ShieldModeRuntimeTable.GetEquippedTool(LocalCharacterModel) or nil
		local ShotSkyDirectionVector3 = ShieldModeRuntimeTable.GetShotSkyAimDirection(LocalCharacterModel, DirectionVector3, EquippedTool)
		local ForcedDirectionVector3, ThreatData = ShieldModeRuntimeTable.GetThreatFacingDirection(LocalCharacterModel, MetalShieldTool, EquippedTool)
		local ThreatAimDirectionVector3 = GetThreatAimDirectionVector3(LocalCharacterModel, ThreatData, ForcedDirectionVector3)
		if ForcedDirectionVector3 then
			DirectionVector3 = ThreatAimDirectionVector3 or ForcedDirectionVector3
			if type(SelfTable.Rotate3rdPersonTime) == "number" then
				SelfTable.Rotate3rdPersonTime = math.max(SelfTable.Rotate3rdPersonTime, 0.2)
			end
		elseif ShotSkyDirectionVector3 then
			DirectionVector3 = ShotSkyDirectionVector3
			if type(SelfTable.Rotate3rdPersonTime) == "number" then
				SelfTable.Rotate3rdPersonTime = math.max(SelfTable.Rotate3rdPersonTime, 0.2)
			end
		end
		return OriginalUpdateLimbsFunction(SelfTable, DirectionVector3, DeltaTimeNumber)
	end

	ShieldModeRuntimeTable.localCharacterHooksApplied = true
	DebugLog("shield-hooks", "Installed LocalCharacter facing override hooks", true)
end

function ShieldModeRuntimeTable.ApplyThreatFacing(LocalCharacterModel, MetalShieldTool, EquippedTool)
	local ForcedDirectionVector3, ThreatData = ShieldModeRuntimeTable.GetThreatFacingDirection(LocalCharacterModel, MetalShieldTool, EquippedTool)
	if not ForcedDirectionVector3 or not ThreatData then
		return
	end

	local LocalCharacterModuleTable = ShieldModeRuntimeTable.ResolveLocalCharacterModule()
	if LocalCharacterModuleTable then
		ShieldModeRuntimeTable.ApplyBodyFacingOverride(
			LocalCharacterModuleTable,
			ForcedDirectionVector3,
			0.016
		)
	end

	if DebugModeEnabledBoolean then
		DebugLog(
			"shield-face",
			"Shield Mode facing threat " .. GetCharacterModelDebugName(ThreatData.character) .. " | dot=" .. string.format("%.2f", ThreatData.dot or -1) .. " | dist=" .. string.format("%.1f", ThreatData.distance or -1),
			false
		)
	end
end

function ShieldModeRuntimeTable.GetSecondaryTool(CharacterModel)
	local SecondaryWeaponNameString = ShieldModeRuntimeTable.GetLoadoutWeaponName("Secondary")
	if SecondaryWeaponNameString then
		local SecondaryTool = ShieldModeRuntimeTable.FindLocalToolByName(CharacterModel, SecondaryWeaponNameString)
		if SecondaryTool then
			return SecondaryTool, SecondaryWeaponNameString
		end
	end

	for _, ContainerInstance in ipairs({ ShieldModeRuntimeTable.GetLocalPlayerBackpack(), CharacterModel }) do
		if ContainerInstance then
			for _, ChildInstance in ipairs(ContainerInstance.GetChildren(ContainerInstance)) do
				if ChildInstance.IsA(ChildInstance, "Tool")
					and ChildInstance.Name ~= "Metal Shield"
					and ShieldModeRuntimeTable.IsGunTool(ChildInstance) then
					return ChildInstance, ChildInstance.Name
				end
			end
		end
	end

	return nil, SecondaryWeaponNameString
end

function ShieldModeRuntimeTable.EquipTool(CharacterModel, ToolInstance)
	if not CharacterModel or not ToolInstance then
		return false
	end

	if ToolInstance.Parent == CharacterModel then
		return true
	end

	local BackpackInstance = ShieldModeRuntimeTable.GetLocalPlayerBackpack()
	if ToolInstance.Parent ~= BackpackInstance then
		return false
	end

	local Humanoid = GetCharacterHumanoid(CharacterModel)
	if not Humanoid then
		return false
	end

	if Humanoid.UnequipTools then
		Humanoid.UnequipTools(Humanoid)
	end

	if Humanoid.EquipTool then
		Humanoid.EquipTool(Humanoid, ToolInstance)
		return true
	end

	return false
end

function ShieldModeRuntimeTable.TryEquipTool(CharacterModel, ToolInstance, ReasonString, ForceBoolean)
	if not CharacterModel or not ToolInstance then
		return false
	end

	local NowNumber = tick()
	if not ForceBoolean and (NowNumber - ShieldModeRuntimeTable.lastEquipAttemptTime) < ShieldModeRuntimeTable.equipThrottle then
		return false
	end

	if ShieldModeRuntimeTable.EquipTool(CharacterModel, ToolInstance) then
		ShieldModeRuntimeTable.lastEquipAttemptTime = NowNumber
		if DebugModeEnabledBoolean then
			DebugLog("shield-equip-" .. ToolInstance.Name, "Shield Mode equipped " .. ToolInstance.Name .. " (" .. ReasonString .. ")", false)
		end
		return true
	end

	return false
end

function ShieldModeRuntimeTable.UpdateCombatState(LocalCharacterModel, WantsShotBoolean)
	if not IsEffectiveShieldModeEnabled() or not LocalCharacterModel then
		return false, nil
	end

	ShieldModeRuntimeTable.EnsureLocalCharacterHooks()

	local MetalShieldTool = ShieldModeRuntimeTable.GetLocalMetalShieldTool(LocalCharacterModel)
	local SecondaryTool, SecondaryWeaponNameString = ShieldModeRuntimeTable.GetSecondaryTool(LocalCharacterModel)
	local SecondaryWeaponDataTable = ShieldModeRuntimeTable.GetGunDataByName(SecondaryWeaponNameString)
	if not MetalShieldTool then
		return false, nil
	end

	if not SecondaryTool then
		local EquippedTool = ShieldModeRuntimeTable.GetEquippedTool(LocalCharacterModel)
		if EquippedTool ~= MetalShieldTool then
			ShieldModeRuntimeTable.TryEquipTool(LocalCharacterModel, MetalShieldTool, "missing secondary", false)
			EquippedTool = ShieldModeRuntimeTable.GetEquippedTool(LocalCharacterModel)
		end
		ShieldModeRuntimeTable.ApplyThreatFacing(LocalCharacterModel, MetalShieldTool, EquippedTool)
		return true, nil
	end

	local ShootTimeNumber = tonumber(SecondaryWeaponDataTable and SecondaryWeaponDataTable.ShootTime) or 0.12
	local ReloadTimeNumber = tonumber(SecondaryWeaponDataTable and SecondaryWeaponDataTable.ReloadTime) or 1.7
	local ReequipDelayNumber = math.clamp(ShootTimeNumber * 0.28, 0.03, 0.08)
	local ReadyDelayNumber = math.clamp(ShootTimeNumber * 0.18, 0.02, 0.06)
	local NowNumber = tick()
	local EquippedTool = ShieldModeRuntimeTable.GetEquippedTool(LocalCharacterModel)
	local SecondaryReloadingBoolean = ShieldModeRuntimeTable.IsToolReloading(SecondaryTool)
	local DelayReloadBoolean, DelayReloadThreatData = ShieldModeRuntimeTable.ShouldDelayReloadForThreat(LocalCharacterModel)
	local AmmoEmptyBoolean = ShieldModeRuntimeTable.IsCurrentGunAmmoEmpty()
	local ReloadResumeWindowNumber = math.max(ReadyDelayNumber, 0.3)

	ShieldModeRuntimeTable.SetReloadSuppressionEnabled(DelayReloadBoolean)

	if AmmoEmptyBoolean and DelayReloadBoolean then
		ShieldModeRuntimeTable.reloadDeferredForThreat = true
		ShieldModeRuntimeTable.reloadResumeUntilTime = 0
	end

	if AmmoEmptyBoolean and not DelayReloadBoolean and not SecondaryReloadingBoolean then
		ShieldModeRuntimeTable.reloadDeferredForThreat = true
		if ShieldModeRuntimeTable.reloadResumeUntilTime <= 0 then
			ShieldModeRuntimeTable.reloadResumeUntilTime = NowNumber + ReloadResumeWindowNumber
		end
	end

	if SecondaryReloadingBoolean then
		if DelayReloadBoolean then
			ShieldModeRuntimeTable.reloadObserved = false
			ShieldModeRuntimeTable.reloadDeferredForThreat = true
			ShieldModeRuntimeTable.reloadHoldUntilTime = 0
			ShieldModeRuntimeTable.pendingReequipTime = 0
			ShieldModeRuntimeTable.secondaryReadyTime = 0
			ShieldModeRuntimeTable.reloadResumeUntilTime = 0
			if EquippedTool ~= MetalShieldTool then
				ShieldModeRuntimeTable.TryEquipTool(LocalCharacterModel, MetalShieldTool, "delay reload for threat", true)
				EquippedTool = ShieldModeRuntimeTable.GetEquippedTool(LocalCharacterModel)
			end
			ShieldModeRuntimeTable.ApplyThreatFacing(LocalCharacterModel, MetalShieldTool, EquippedTool)
			if DebugModeEnabledBoolean then
				DebugLog("shield-reload-defer", "Shield Mode deferred reload because threat pressure from " .. GetCharacterModelDebugName(DelayReloadThreatData and DelayReloadThreatData.character), false)
			end
			return true, nil
		end

		if not ShieldModeRuntimeTable.reloadObserved then
			ShieldModeRuntimeTable.reloadObserved = true
			ShieldModeRuntimeTable.reloadHoldUntilTime = NowNumber + ReloadTimeNumber + 0.05
			ShieldModeRuntimeTable.reloadResumeUntilTime = 0
			if DebugModeEnabledBoolean then
				DebugLog("shield-reloading-start", "Shield Mode started reloading " .. tostring(SecondaryWeaponNameString), false)
			end
		end
		ShieldModeRuntimeTable.pendingReequipTime = 0
		ShieldModeRuntimeTable.secondaryReadyTime = 0
		if EquippedTool ~= SecondaryTool then
			ShieldModeRuntimeTable.TryEquipTool(LocalCharacterModel, SecondaryTool, "reload", true)
		end
		if DebugModeEnabledBoolean then
			DebugLog("shield-reloading", "Shield Mode holding " .. tostring(SecondaryWeaponNameString) .. " while it reloads", false)
		end
		return true, nil
	elseif ShieldModeRuntimeTable.reloadObserved then
		ShieldModeRuntimeTable.reloadObserved = false
		ShieldModeRuntimeTable.reloadHoldUntilTime = NowNumber + ReadyDelayNumber
		ShieldModeRuntimeTable.secondaryReadyTime = NowNumber + ReadyDelayNumber
		ShieldModeRuntimeTable.pendingReequipTime = 0
		ShieldModeRuntimeTable.reloadResumeUntilTime = 0
		ShieldModeRuntimeTable.nextShotTime = math.max(ShieldModeRuntimeTable.nextShotTime, NowNumber + ReadyDelayNumber)
		if DebugModeEnabledBoolean then
			DebugLog("shield-reload-finished", "Shield Mode reload finished for " .. tostring(SecondaryWeaponNameString), false)
		end
	end

	if ShieldModeRuntimeTable.reloadHoldUntilTime > 0 then
		if NowNumber < ShieldModeRuntimeTable.reloadHoldUntilTime then
			if EquippedTool ~= SecondaryTool then
				ShieldModeRuntimeTable.TryEquipTool(LocalCharacterModel, SecondaryTool, "reload recovery", false)
			end
			return true, nil
		end

		ShieldModeRuntimeTable.reloadHoldUntilTime = 0
	end

	if ShieldModeRuntimeTable.pendingReequipTime > 0 and NowNumber >= ShieldModeRuntimeTable.pendingReequipTime then
		ShieldModeRuntimeTable.pendingReequipTime = 0
		if EquippedTool ~= MetalShieldTool then
			ShieldModeRuntimeTable.TryEquipTool(LocalCharacterModel, MetalShieldTool, "post-shot re-equip", true)
			EquippedTool = ShieldModeRuntimeTable.GetEquippedTool(LocalCharacterModel)
		end
	end

	ShieldModeRuntimeTable.ApplyThreatFacing(LocalCharacterModel, MetalShieldTool, EquippedTool)

	if ShieldModeRuntimeTable.reloadDeferredForThreat then
		if DelayReloadBoolean then
			if EquippedTool ~= MetalShieldTool then
				ShieldModeRuntimeTable.TryEquipTool(LocalCharacterModel, MetalShieldTool, "hold shield during deferred reload", true)
			end
			return true, nil
		end

		ShieldModeRuntimeTable.reloadDeferredForThreat = false
		ShieldModeRuntimeTable.reloadResumeUntilTime = NowNumber + ReloadResumeWindowNumber
		if EquippedTool ~= SecondaryTool then
			ShieldModeRuntimeTable.TryEquipTool(LocalCharacterModel, SecondaryTool, "resume deferred reload", true)
		end
		return true, nil
	end

	if ShieldModeRuntimeTable.reloadResumeUntilTime > 0 then
		if AmmoEmptyBoolean then
			if EquippedTool ~= SecondaryTool then
				ShieldModeRuntimeTable.TryEquipTool(LocalCharacterModel, SecondaryTool, "safe reload window", true)
			end
			if NowNumber < ShieldModeRuntimeTable.reloadResumeUntilTime then
				return true, nil
			end
		end

		ShieldModeRuntimeTable.reloadResumeUntilTime = 0
	end

	if AmmoEmptyBoolean then
		ShieldModeRuntimeTable.secondaryReadyTime = 0
		if EquippedTool ~= MetalShieldTool then
			ShieldModeRuntimeTable.TryEquipTool(LocalCharacterModel, MetalShieldTool, "empty secondary hold shield", true)
		end
		return true, nil
	end

	if not WantsShotBoolean then
		ShieldModeRuntimeTable.secondaryReadyTime = 0
		if EquippedTool ~= MetalShieldTool then
			ShieldModeRuntimeTable.TryEquipTool(LocalCharacterModel, MetalShieldTool, "idle", false)
		end
		return true, nil
	end

	if NowNumber < ShieldModeRuntimeTable.nextShotTime then
		ShieldModeRuntimeTable.secondaryReadyTime = 0
		if EquippedTool ~= MetalShieldTool then
			ShieldModeRuntimeTable.TryEquipTool(LocalCharacterModel, MetalShieldTool, "cooldown", false)
		end
		return true, nil
	end

	if EquippedTool ~= SecondaryTool then
		if ShieldModeRuntimeTable.TryEquipTool(LocalCharacterModel, SecondaryTool, "prepare shot", false) then
			ShieldModeRuntimeTable.secondaryReadyTime = NowNumber + ReadyDelayNumber
		end
		return true, nil
	end

	if ShieldModeRuntimeTable.secondaryReadyTime <= 0 then
		ShieldModeRuntimeTable.secondaryReadyTime = NowNumber + ReadyDelayNumber
		return true, nil
	end

	if NowNumber < ShieldModeRuntimeTable.secondaryReadyTime then
		return true, nil
	end

	return true, {
		now = NowNumber,
		shootTime = ShootTimeNumber,
		reequipDelay = ReequipDelayNumber,
		secondaryName = SecondaryWeaponNameString,
	}
end

function ShieldModeRuntimeTable.FinalizeShot(ShotContextTable)
	if not ShotContextTable then
		return
	end

	ShieldModeRuntimeTable.nextShotTime = ShotContextTable.now + ShotContextTable.shootTime
	ShieldModeRuntimeTable.pendingReequipTime = ShotContextTable.now + ShotContextTable.reequipDelay
	ShieldModeRuntimeTable.secondaryReadyTime = 0
	LastAutoFireTimeNumber = ShotContextTable.now
	if DebugModeEnabledBoolean then
		DebugLog("shield-shot", "Shield Mode fired " .. tostring(ShotContextTable.secondaryName) .. " | shootTime=" .. string.format("%.3f", ShotContextTable.shootTime), false)
	end
end

local function AppendUniqueIgnoredInstance(IgnoredInstancesTable, IgnoredInstance)
	if not IgnoredInstancesTable or not IgnoredInstance then
		return
	end

	for _, ExistingIgnoredInstance in ipairs(IgnoredInstancesTable) do
		if ExistingIgnoredInstance == IgnoredInstance then
			return
		end
	end

	table.insert(IgnoredInstancesTable, IgnoredInstance)
end

local function IsTypingInTextBox()
	if not UserInputService.GetFocusedTextBox then
		return false
	end

	return UserInputService.GetFocusedTextBox(UserInputService) ~= nil
end

local function FindPlayerForCharacterModel(CharacterModel)
	if not CharacterModel then
		return nil
	end

	local MatchingPlayerObject = Players.GetPlayerFromCharacter(Players, CharacterModel)
	if MatchingPlayerObject then
		return MatchingPlayerObject
	end

	if IsCustomCharacterGameBoolean then
		for _, PlayerObject in ipairs(Players.GetPlayers(Players)) do
			if FindCustomCharacterForPlayer(PlayerObject) == CharacterModel then
				return PlayerObject
			end
		end
	end

	return nil
end

local function IsLocalControlledCharacterModel(CharacterModel, LocalCharacterModel)
	if not CharacterModel then
		return false
	end

	if LocalCharacterModel and CharacterModel == LocalCharacterModel then
		return true
	end

	local Humanoid = GetCharacterHumanoid(CharacterModel)
	if Humanoid and Camera and Camera.CameraSubject == Humanoid then
		return true
	end

	return false
end

local ProjectilePreferredTargetPartNamesTable = {
	"HumanoidRootPart",
	"UpperTorso",
	"Torso",
	"LowerTorso",
	"Center",
	"HitboxPart",
	"Head",
}
local StandardPreferredTargetPartNamesTable = {
	"HitboxPart",
	"Head",
	"HumanoidRootPart",
	"Torso",
	"Center",
}
local PriorityTargetablePartNamesTable = {
	hitboxpart = true,
	head = true,
	humanoidrootpart = true,
	torso = true,
	center = true,
}

local function IsPartUnderIgnoredAncestor(PartInstance, CharacterModel)
	local AncestorInstance = PartInstance and PartInstance.Parent or nil
	while AncestorInstance and AncestorInstance ~= CharacterModel do
		if AncestorInstance.IsA(AncestorInstance, "Accessory") or AncestorInstance.IsA(AncestorInstance, "Tool") then
			return true
		end
		AncestorInstance = AncestorInstance.Parent
	end
	return false
end

GetPreferredTargetPart = function(CharacterModel)
	if not CharacterModel then
		return nil
	end

	local PreferProjectileBodyAimBoolean = ShouldPreferProjectileBodyAimForProfile(CurrentWeaponBallisticsProfileTable)
	local PreferredPartNamesInOrderTable = PreferProjectileBodyAimBoolean
		and ProjectilePreferredTargetPartNamesTable
		or StandardPreferredTargetPartNamesTable

	local PrimaryPartInstance = CharacterModel.PrimaryPart
	if PrimaryPartInstance
		and PrimaryPartInstance.IsA(PrimaryPartInstance, "BasePart")
		and not IsPartUnderIgnoredAncestor(PrimaryPartInstance, CharacterModel)
		and (not PreferProjectileBodyAimBoolean or string.lower(PrimaryPartInstance.Name) ~= "head") then
		return PrimaryPartInstance
	end

	for _, PreferredPartNameString in ipairs(PreferredPartNamesInOrderTable) do
		local PreferredPartInstance = CharacterModel.FindFirstChild(CharacterModel, PreferredPartNameString)
		if PreferredPartInstance
			and PreferredPartInstance.IsA(PreferredPartInstance, "BasePart")
			and not IsPartUnderIgnoredAncestor(PreferredPartInstance, CharacterModel) then
			return PreferredPartInstance
		end
	end

	return nil
end

local function GetTargetableParts(CharacterModel)
	if not CharacterModel then
		return {}
	end

	local NowNumber = tick()
	local CachedEntryTable = TargetablePartsCacheTable[CharacterModel]
	local FrameIdNumber = tonumber(CurrentFrameSequenceNumber) or 0
	if CachedEntryTable
		and FrameIdNumber > 0
		and CachedEntryTable.frameId == FrameIdNumber then
		return CachedEntryTable.parts
	end

	local ChildCountNumber = #CharacterModel.GetChildren(CharacterModel)
	if CachedEntryTable
		and CachedEntryTable.childCount == ChildCountNumber
		and (NowNumber - CachedEntryTable.time) < TargetablePartsCacheDurationNumber then
		return CachedEntryTable.parts
	end

	local PriorityTargetableParts = {}
	local FallbackTargetableParts = {}
	local SeenPartsTable = {}

	local function AddPartIfTargetable(PartInstance)
		if SeenPartsTable[PartInstance] or not PartInstance.IsA(PartInstance, "BasePart") then
			return
		end

		if IsPartUnderIgnoredAncestor(PartInstance, CharacterModel) then
			return
		end

		SeenPartsTable[PartInstance] = true
		local PartNameLowerString = string.lower(PartInstance.Name)
		if PriorityTargetablePartNamesTable[PartNameLowerString] then
			table.insert(PriorityTargetableParts, PartInstance)
		else
			table.insert(FallbackTargetableParts, PartInstance)
		end
	end

	local PreferredPartInstance = GetPreferredTargetPart(CharacterModel)
	if PreferredPartInstance then
		AddPartIfTargetable(PreferredPartInstance)
	end

	for _, ChildInstance in ipairs(CharacterModel.GetChildren(CharacterModel)) do
		if ChildInstance.IsA(ChildInstance, "BasePart") then
			AddPartIfTargetable(ChildInstance)
		end
	end

	if #PriorityTargetableParts > 0 then
		TargetablePartsCacheTable[CharacterModel] = {
			childCount = ChildCountNumber,
			time = NowNumber,
			frameId = FrameIdNumber,
			parts = PriorityTargetableParts,
		}
		return PriorityTargetableParts
	end

	TargetablePartsCacheTable[CharacterModel] = {
		childCount = ChildCountNumber,
		time = NowNumber,
		frameId = FrameIdNumber,
		parts = FallbackTargetableParts,
	}
	return FallbackTargetableParts
end

GetSearchableCharacterEntries = function(LocalCharacterModel, TeamCheckEnabledBoolean, LocalTeamObject)
	local CacheKeyString = tostring(LocalCharacterModel) .. "|" .. tostring(TeamCheckEnabledBoolean) .. "|" .. tostring(LocalTeamObject)
	local NowNumber = tick()
	if CachedSearchableCharacterEntriesKeyString == CacheKeyString
		and (NowNumber - CachedSearchableCharacterEntriesTimeNumber) < SearchableCharacterEntriesCacheDurationNumber then
		return CachedSearchableCharacterEntriesTable
	end

	local CharacterEntries = {}
	local SeenCharacterModels = {}

	local function AddCharacterEntry(PlayerObject, CharacterModel)
		if not IsHumanoidCharacterModel(CharacterModel) then
			return
		end
		if not GetCharacterRootPart(CharacterModel) then
			return
		end
		if IsLocalControlledCharacterModel(CharacterModel, LocalCharacterModel) then
			return
		end
		if SeenCharacterModels[CharacterModel] then
			return
		end

		if IsCustomCharacterGameBoolean and not PlayerObject then
			return
		end

		if PlayerObject and PlayerListRuntimeTable.IsPlayerWhitelisted(PlayerObject) then
			return
		end

		if TeamCheckEnabledBoolean and PlayerObject and LocalTeamObject and PlayerObject.Team == LocalTeamObject then
			return
		end

		SeenCharacterModels[CharacterModel] = true
		table.insert(CharacterEntries, {
			player = PlayerObject,
			character = CharacterModel,
		})
	end

	if IsCustomCharacterGameBoolean then
		for _, CharacterModel in ipairs(GetCharacterModelsFromCharactersFolder()) do
			local MatchingPlayerObject = FindPlayerForCharacterModel(CharacterModel)
			AddCharacterEntry(MatchingPlayerObject, CharacterModel)
		end
	else
		for _, PlayerObject in ipairs(Players.GetPlayers(Players)) do
			if PlayerObject == LocalPlayer then
				continue
			end

			local CharacterModel = ResolveCharacterModelForPlayer(PlayerObject)
			if CharacterModel then
				AddCharacterEntry(PlayerObject, CharacterModel)
			end
		end
	end

	if DebugModeEnabledBoolean then
		DebugLog("search-pool", "Prepared " .. tostring(#CharacterEntries) .. " searchable character models", false)
	end

	CachedSearchableCharacterEntriesTable = CharacterEntries
	CachedSearchableCharacterEntriesKeyString = CacheKeyString
	CachedSearchableCharacterEntriesTimeNumber = NowNumber
	return CharacterEntries
end
