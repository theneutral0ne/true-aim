local function ClearMutableTable(TableObject)
	if type(TableObject) ~= "table" then
		return {}
	end

	if type(table.clear) == "function" then
		table.clear(TableObject)
	else
		for Key in pairs(TableObject) do
			TableObject[Key] = nil
		end
	end

	return TableObject
end

ShieldModeRuntimeTable.oldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
	local Method = getnamecallmethod()
	local IsWorkspaceRaycastMethodBoolean = Method == "Raycast" and Self == WorkspaceService
	local IsLegacyRayMethodBoolean = Method == "FindPartOnRayWithIgnoreList" or Method == "FindPartOnRay"
	if InternalAimbotRaycastBypassDepth > 0
		and (IsWorkspaceRaycastMethodBoolean or IsLegacyRayMethodBoolean) then
		return ShieldModeRuntimeTable.oldNamecall(Self, ...)
	end

	if not IsWorkspaceRaycastMethodBoolean and not IsLegacyRayMethodBoolean then
		return ShieldModeRuntimeTable.oldNamecall(Self, ...)
	end

	if not IsEffectiveHookMethodEnabled()
		or not CurrentTargetPartInstance
		or not CurrentTargetCharacterModel
		or not CurrentTargetPartInstance.Parent then
		return ShieldModeRuntimeTable.oldNamecall(Self, ...)
	end

	local LocalCharacterModel = CurrentFrameLocalCharacterModel
	local LocalCharacterReadyBoolean = CurrentFrameLocalCharacterReadyBoolean
	if not LocalCharacterReadyBoolean or not LocalCharacterModel or not LocalCharacterModel.Parent then
		LocalCharacterModel = ResolveCharacterModelForPlayer(LocalPlayer)
		LocalCharacterReadyBoolean = IsLocalCharacterReadyForAimbot(LocalCharacterModel)
		if not LocalCharacterReadyBoolean then
			return ShieldModeRuntimeTable.oldNamecall(Self, ...)
		end
	end

	local ShouldRedirect = true
	if AimbotRequireRmbBoolean then
		ShouldRedirect = ShieldModeRuntimeTable.IsLockKeyHeld()
	end
	if ShouldRedirect then
		ShouldRedirect = ShouldApplyNormalHookHitChance()
	end
	if not ShouldRedirect then
		return ShieldModeRuntimeTable.oldNamecall(Self, ...)
	end

	local Args = { ... }
	if IsWorkspaceRaycastMethodBoolean then
		local Origin = Args[1]
		local Direction = Args[2]
		local RaycastParamsObject = Args[3]

		if typeof(Origin) == "Vector3"
			and typeof(Direction) == "Vector3"
			and Direction.Magnitude > 0.001 then
			local TargetPosition = GetCurrentEffectiveAimPointVector3() or CurrentTargetPartInstance.Position
			local ActiveFiringLocalGunTable = ShieldModeRuntimeTable.activeFiringLocalGun
			if IsBloodZonePlaceBoolean
				and type(ActiveFiringLocalGunTable) == "table"
				and RaycastParamsObject == ActiveFiringLocalGunTable.CheckParams then
				local RedirectOriginVector3, RedirectDirectionVector3 = ShieldModeRuntimeTable.GetFireGunMuzzleRedirect(
					ActiveFiringLocalGunTable,
					TargetPosition,
					Origin,
					Direction.Magnitude
				)
				if RedirectOriginVector3 and RedirectDirectionVector3 then
					Args[1] = RedirectOriginVector3
					Args[2] = RedirectDirectionVector3
				end
			elseif ShieldModeRuntimeTable.ShouldSkipBloodZoneProjectileRaycastRedirect(LocalCharacterModel, RaycastParamsObject) then
				return ShieldModeRuntimeTable.oldNamecall(Self, ...)
			else
				Args[2] = (TargetPosition - Origin).Unit * Direction.Magnitude
			end
		end

		return ShieldModeRuntimeTable.oldNamecall(Self, unpack(Args))
	end

	local RayObject = Args[1]
	if RayObject then
		local TargetPosition = GetCurrentEffectiveAimPointVector3() or CurrentTargetPartInstance.Position
		local NewDirection = (TargetPosition - RayObject.Origin).Unit * RayObject.Direction.Magnitude
		Args[1] = Ray.new(RayObject.Origin, NewDirection)
	end

	return ShieldModeRuntimeTable.oldNamecall(Self, unpack(Args))
end)

RunService.RenderStepped.Connect(RunService.RenderStepped, function()
	CurrentFrameSequenceNumber = (tonumber(CurrentFrameSequenceNumber) or 0) + 1
	local FrameNowNumber = tick()
	local MouseLocationVector2 = UserInputService.GetMouseLocation(UserInputService)
	local MouseOverPartInstance = MouseObject.Target
	FrameTargetDataCacheTable.normal = ClearMutableTable(FrameTargetDataCacheTable.normal)
	FrameTargetDataCacheTable.ignoreFov = ClearMutableTable(FrameTargetDataCacheTable.ignoreFov)
	FrameVisiblePointCacheTable = ClearMutableTable(FrameVisiblePointCacheTable)
	FrameCharacterAliveCacheTable = ClearMutableTable(FrameCharacterAliveCacheTable)
	FrameCharacterVelocityCacheTable = ClearMutableTable(FrameCharacterVelocityCacheTable)
	CurrentWeaponBallisticsProfileTable = nil
	CurrentFrameLocalCharacterModel = nil
	CurrentFrameLocalCharacterReadyBoolean = false
	ShieldModeRuntimeTable.shotSkyAimDataCache = nil
	FovCircle.Position = MouseLocationVector2
	if not UseHookMethodBoolean or IsSillyModeBehaviorActive() or not CurrentTargetPartInstance then
		ResetNormalHookHitChanceDecision()
	end
	if CurrentTargetPartInstance and (not CurrentTargetPartInstance.Parent or not IsCharacterAlive(CurrentTargetCharacterModel)) then
		CurrentTargetPartInstance = nil
		CurrentTargetCharacterModel = nil
		CurrentTargetPlayerObject = nil
		CurrentTargetPointVector3 = nil
		CurrentTargetAimPointVector3 = nil
		CurrentTargetLocalPointVector3 = nil
		CurrentTargetCubeCFrame = nil
		CurrentTargetCubeSize = nil
	end

	local LocalCharacterModel = ResolveCharacterModelForPlayer(LocalPlayer)
	if LocalCharacterModel ~= LastRaycastCharacterModel then
		if LocalCharacterModel then
			VisibilityRaycastParams.FilterDescendantsInstances = { LocalCharacterModel }
		else
			VisibilityRaycastParams.FilterDescendantsInstances = {}
		end
		LastRaycastCharacterModel = LocalCharacterModel
	end

	local LocalCharacterReadyBoolean = IsLocalCharacterReadyForAimbot(LocalCharacterModel)
	CurrentFrameLocalCharacterModel = LocalCharacterModel
	CurrentFrameLocalCharacterReadyBoolean = LocalCharacterReadyBoolean
	if UseProjectilePredictionBoolean and LocalCharacterReadyBoolean then
		CurrentWeaponBallisticsProfileTable = ShieldModeRuntimeTable.ResolveCurrentWeaponBallisticsProfile(LocalCharacterModel)
	else
		CurrentWeaponBallisticsProfileTable = nil
	end
	local ShouldActivateSillyModeBoolean = IsBloodZonePlaceBoolean
		and IsSillyModeEnabled()
		and LocalCharacterReadyBoolean
		and HasEquippedTool(LocalCharacterModel)
	local PlayerListRefreshIntervalNumber = LocalCharacterReadyBoolean and PlayerListRuntimeTable.refreshInterval or PlayerListMenuRefreshIntervalNumber
	if (FrameNowNumber - PlayerListRuntimeTable.lastRefreshTime) >= PlayerListRefreshIntervalNumber then
		PlayerListRuntimeTable.RefreshUi(false)
	end
	if IsBloodZonePlaceBoolean then
		if LocalCharacterReadyBoolean then
			ShieldModeRuntimeTable.EnsureLocalGunHooks()
			ShieldModeRuntimeTable.EnsureCursorHooks()
		end

		if SillyModeRuntimeActiveBoolean ~= ShouldActivateSillyModeBoolean then
			SillyModeRuntimeActiveBoolean = ShouldActivateSillyModeBoolean
			if SillyModeRuntimeActiveBoolean then
				ShieldModeRuntimeTable.EnsureLocalCharacterHooks()
			end
			RefreshBloodZoneBehaviorButtons()
		end

		if not IsEffectiveShieldModeEnabled() then
			ShieldModeRuntimeTable.ResetState()
		end
	end

	if not LocalCharacterReadyBoolean then
		if IsBloodZonePlaceBoolean then
			ShieldModeRuntimeTable.ResetState()
		end
		CurrentTargetPartInstance = nil
		CurrentTargetCharacterModel = nil
		CurrentTargetPlayerObject = nil
		CurrentTargetPointVector3 = nil
		CurrentTargetAimPointVector3 = nil
		CurrentTargetLocalPointVector3 = nil
		CurrentTargetCubeCFrame = nil
		CurrentTargetCubeSize = nil
		CurrentVisibilityOriginVector3 = nil
		LastFallbackIndicatorPartInstance = nil
		LastFallbackIndicatorCharacterModel = nil
		LastFallbackIndicatorPlayerObject = nil
		FovCircle.Visible = false
		TargetLine.Visible = false
		SetTargetCubeVisible(false)
		return
	end

	FovCircle.Visible = ShowFovCircleBoolean and not IsSillyModeBehaviorActive()
	CurrentVisibilityOriginVector3 = GetCurrentGunVisibilityOrigin(LocalCharacterModel)
	if not CurrentVisibilityOriginVector3 then
		local VisibilityOriginPartInstance = GetCharacterHeadPart(LocalCharacterModel) or GetCharacterRootPart(LocalCharacterModel)
		if VisibilityOriginPartInstance then
			CurrentVisibilityOriginVector3 = VisibilityOriginPartInstance.Position
		else
			CurrentVisibilityOriginVector3 = Camera.CFrame.Position
		end
	end
	local TeamCheckEnabledBoolean = false
	local LocalTeamObject = nil

	if not IsCustomCharacterGameBoolean then
		if LocalPlayer.Team ~= nil then
			TeamCheckEnabledBoolean = true
			LocalTeamObject = LocalPlayer.Team
		end
	end

	local FinalTargetPartInstance = nil
	local FinalTargetCharacterModel = nil
	local FinalTargetPlayerObject = nil
	local FinalTargetScreenPositionVector2 = nil
	local FinalTargetPointVector3 = nil
	local FinalTargetLocalPointVector3 = nil
	local FinalTargetCubeCFrame = nil
	local FinalTargetCubeSize = nil
	local CurrentTargetValidBoolean = false
	local CurrentTargetDistanceNumber = nil
	local IndicatorScreenPositionVector2 = nil
	local IndicatorPointVector3 = nil
	local IndicatorCubeCFrame = nil
	local IndicatorCubeSize = nil
	local IndicatorPartInstance = nil
	local IndicatorCharacterModel = nil
	local ShouldSearchForNewTargetBoolean = true
	local TargetSearchResultTable = nil
	local CandidateData = nil
	local FallbackIndicatorData = nil

	if CurrentTargetPartInstance
		and CurrentTargetCharacterModel
		and CurrentTargetCharacterModel.Parent
		and not PlayerListRuntimeTable.IsPlayerWhitelisted(CurrentTargetPlayerObject) then
		if IsCharacterAlive(CurrentTargetCharacterModel) then
			local TargetData = ShieldModeRuntimeTable.GetTargetDataForPart(CurrentTargetPartInstance, CurrentTargetCharacterModel, MouseLocationVector2, false)
			if TargetData then
				CurrentTargetValidBoolean = true
				CurrentTargetDistanceNumber = GetTargetSortDistance(TargetData)
				local BestTargetData = ShieldModeRuntimeTable.GetBestTargetForCharacter(CurrentTargetCharacterModel, MouseLocationVector2)
				if BestTargetData and GetTargetSortDistance(BestTargetData) < (CurrentTargetDistanceNumber - RetargetMinImprovementNumber) then
					FinalTargetPartInstance = BestTargetData.part
					FinalTargetCharacterModel = BestTargetData.character
					FinalTargetPlayerObject = CurrentTargetPlayerObject
					FinalTargetScreenPositionVector2 = BestTargetData.screen
					FinalTargetPointVector3 = BestTargetData.point
					FinalTargetLocalPointVector3 = BestTargetData.localPoint
					FinalTargetCubeCFrame = BestTargetData.cubeCFrame
					FinalTargetCubeSize = BestTargetData.cubeSize
					IndicatorScreenPositionVector2 = BestTargetData.screen
					IndicatorPointVector3 = BestTargetData.point
					IndicatorCubeCFrame = BestTargetData.cubeCFrame
					IndicatorCubeSize = BestTargetData.cubeSize
					IndicatorPartInstance = BestTargetData.part
					IndicatorCharacterModel = BestTargetData.character
				else
					FinalTargetPartInstance = TargetData.part
					FinalTargetCharacterModel = TargetData.character
					FinalTargetPlayerObject = CurrentTargetPlayerObject
					FinalTargetScreenPositionVector2 = TargetData.screen
					FinalTargetPointVector3 = TargetData.point
					FinalTargetLocalPointVector3 = TargetData.localPoint
					FinalTargetCubeCFrame = TargetData.cubeCFrame
					FinalTargetCubeSize = TargetData.cubeSize
					IndicatorScreenPositionVector2 = TargetData.screen
					IndicatorPointVector3 = TargetData.point
					IndicatorCubeCFrame = TargetData.cubeCFrame
					IndicatorCubeSize = TargetData.cubeSize
					IndicatorPartInstance = TargetData.part
					IndicatorCharacterModel = TargetData.character
				end
			end
		end
	end

	local StickyAimHoldingBoolean = false
	if CurrentTargetValidBoolean and IsStickyAimActive() then
		StickyAimHoldingBoolean = not AimbotRequireRmbBoolean or ShieldModeRuntimeTable.IsLockKeyHeld()
	end
	if StickyAimHoldingBoolean then
		ShouldSearchForNewTargetBoolean = false
	end

	local NowNumber = tick()
	local AllowTargetSearchBoolean = ShouldSearchForNewTargetBoolean and (NowNumber - LastTargetSearchTimeNumber >= TargetSearchIntervalNumber)
	if AllowTargetSearchBoolean then
		LastTargetSearchTimeNumber = NowNumber
		ResetRejectCounts()
	end

	if AllowTargetSearchBoolean then
		TargetSearchResultTable = ShieldModeRuntimeTable.RunTargetSearch(LocalCharacterModel, MouseLocationVector2, TeamCheckEnabledBoolean, LocalTeamObject, ShowTargetLineBoolean)
		CandidateData = TargetSearchResultTable.candidate
		FallbackIndicatorData = TargetSearchResultTable.fallbackIndicator

		if CandidateData then
			local CandidateIdentityString = GetTargetIdentity(CandidateData.player, CandidateData.character, CandidateData.part)
			local CandidateThreatSuffixString = CandidateData.isAimingThreat and " threat" or ""
			UpdateDebugStatus("candidate=" .. CandidateIdentityString .. CandidateThreatSuffixString .. " dist=" .. string.format("%.1f", CandidateData.distance or -1))
			if DebugModeEnabledBoolean then
				DebugLog("candidate-found", "Found candidate " .. CandidateIdentityString .. " at target distance " .. string.format("%.1f", CandidateData.distance or -1) .. " | threat=" .. tostring(CandidateData.isAimingThreat) .. " | vis=" .. tostring(IsEffectiveVisibleCheckEnabled()), false)
			end
		else
			UpdateDebugStatus("no candidate | vis=" .. tostring(IsEffectiveVisibleCheckEnabled()) .. " line=" .. tostring(ShowTargetLineBoolean) .. " maxDist=" .. tostring(MaxDistanceNumber) .. " live=" .. tostring(TargetSearchResultTable.liveCharacterCount) .. " parts=" .. tostring(TargetSearchResultTable.totalTargetablePartCount))
			if DebugModeEnabledBoolean then
				DebugLog("candidate-missing", "Target search found no candidate. Mouse target=" .. SafeDebugName(MouseOverPartInstance) .. " | vis=" .. tostring(IsEffectiveVisibleCheckEnabled()) .. " | line=" .. tostring(ShowTargetLineBoolean) .. " | maxDist=" .. tostring(MaxDistanceNumber) .. " | live=" .. tostring(TargetSearchResultTable.liveCharacterCount) .. " | parts=" .. tostring(TargetSearchResultTable.totalTargetablePartCount) .. " | preferredThreat=" .. GetCharacterModelDebugName(TargetSearchResultTable.preferredAimingThreatCharacter) .. " | threatScore=" .. string.format("%.1f", TargetSearchResultTable.preferredAimingThreatScore or -1) .. " | rejects=" .. GetRejectCountsSummary(), false)
			end
		end

		if not CandidateData and FallbackIndicatorData and FallbackIndicatorData.part and FallbackIndicatorData.screen then
			local FallbackIdentityString = GetTargetIdentity(FallbackIndicatorData.player, FallbackIndicatorData.character, FallbackIndicatorData.part)
			if DebugModeEnabledBoolean then
				DebugLog("indicator-fallback", "Using off-FOV indicator fallback for " .. FallbackIdentityString .. " at screen distance " .. string.format("%.1f", FallbackIndicatorData.distance or -1), false)
			end
		end
	end

	if AllowTargetSearchBoolean then
		if FallbackIndicatorData and FallbackIndicatorData.part and FallbackIndicatorData.character then
			LastFallbackIndicatorPartInstance = FallbackIndicatorData.part
			LastFallbackIndicatorCharacterModel = FallbackIndicatorData.character
			LastFallbackIndicatorPlayerObject = FallbackIndicatorData.player
		elseif not CandidateData and not CurrentTargetValidBoolean then
			LastFallbackIndicatorPartInstance = nil
			LastFallbackIndicatorCharacterModel = nil
			LastFallbackIndicatorPlayerObject = nil
		end
	end

	if not FallbackIndicatorData and LastFallbackIndicatorPartInstance and LastFallbackIndicatorCharacterModel then
		if LastFallbackIndicatorPartInstance.Parent and IsCharacterAlive(LastFallbackIndicatorCharacterModel) then
			local PersistedFallbackTargetData = ShieldModeRuntimeTable.GetTargetDataForPart(LastFallbackIndicatorPartInstance, LastFallbackIndicatorCharacterModel, MouseLocationVector2, true)
			if PersistedFallbackTargetData then
				FallbackIndicatorData = ShieldModeRuntimeTable.BuildFallbackIndicatorData(PersistedFallbackTargetData, LastFallbackIndicatorPlayerObject)
			else
				LastFallbackIndicatorPartInstance = nil
				LastFallbackIndicatorCharacterModel = nil
				LastFallbackIndicatorPlayerObject = nil
			end
		else
			LastFallbackIndicatorPartInstance = nil
			LastFallbackIndicatorCharacterModel = nil
			LastFallbackIndicatorPlayerObject = nil
		end
	end

	if AllowTargetSearchBoolean then
		if not CurrentTargetValidBoolean and CandidateData then
			FinalTargetPartInstance = CandidateData.part
			FinalTargetCharacterModel = CandidateData.character
			FinalTargetPlayerObject = CandidateData.player
			FinalTargetScreenPositionVector2 = CandidateData.screen
			FinalTargetPointVector3 = CandidateData.point
			FinalTargetLocalPointVector3 = CandidateData.localPoint
			FinalTargetCubeCFrame = CandidateData.cubeCFrame
			FinalTargetCubeSize = CandidateData.cubeSize
		elseif CurrentTargetValidBoolean and CandidateData and CandidateData.distance then
			if not IsSillyModeBehaviorActive() then
				if CandidateData.distance < (CurrentTargetDistanceNumber - RetargetMinImprovementNumber) then
					FinalTargetPartInstance = CandidateData.part
					FinalTargetCharacterModel = CandidateData.character
					FinalTargetPlayerObject = CandidateData.player
					FinalTargetScreenPositionVector2 = CandidateData.screen
					FinalTargetPointVector3 = CandidateData.point
					FinalTargetLocalPointVector3 = CandidateData.localPoint
					FinalTargetCubeCFrame = CandidateData.cubeCFrame
					FinalTargetCubeSize = CandidateData.cubeSize
				end
			else
				local CandidatePriorityBoolean = PlayerListRuntimeTable.IsPriorityPlayer(CandidateData.player)
				local CurrentPriorityBoolean = PlayerListRuntimeTable.IsPriorityPlayer(CurrentTargetPlayerObject)
				local PreferredAimingThreatCharacterModel = TargetSearchResultTable and TargetSearchResultTable.preferredAimingThreatCharacter or nil
				local CurrentTargetIsAimingThreatBoolean = PreferredAimingThreatCharacterModel ~= nil
					and CurrentTargetCharacterModel == PreferredAimingThreatCharacterModel
				if CandidateData.isAimingThreat and not CurrentTargetIsAimingThreatBoolean then
					FinalTargetPartInstance = CandidateData.part
					FinalTargetCharacterModel = CandidateData.character
					FinalTargetPlayerObject = CandidateData.player
					FinalTargetScreenPositionVector2 = CandidateData.screen
					FinalTargetPointVector3 = CandidateData.point
					FinalTargetLocalPointVector3 = CandidateData.localPoint
					FinalTargetCubeCFrame = CandidateData.cubeCFrame
					FinalTargetCubeSize = CandidateData.cubeSize
				elseif CurrentTargetIsAimingThreatBoolean and not CandidateData.isAimingThreat then
					-- Keep the current threat target while no stronger threat candidate replaces it.
				elseif CandidatePriorityBoolean and not CurrentPriorityBoolean then
					FinalTargetPartInstance = CandidateData.part
					FinalTargetCharacterModel = CandidateData.character
					FinalTargetPlayerObject = CandidateData.player
					FinalTargetScreenPositionVector2 = CandidateData.screen
					FinalTargetPointVector3 = CandidateData.point
					FinalTargetLocalPointVector3 = CandidateData.localPoint
					FinalTargetCubeCFrame = CandidateData.cubeCFrame
					FinalTargetCubeSize = CandidateData.cubeSize
				elseif not CurrentPriorityBoolean or CandidatePriorityBoolean then
					if CandidateData.distance < (CurrentTargetDistanceNumber - RetargetMinImprovementNumber) then
						FinalTargetPartInstance = CandidateData.part
						FinalTargetCharacterModel = CandidateData.character
						FinalTargetPlayerObject = CandidateData.player
						FinalTargetScreenPositionVector2 = CandidateData.screen
						FinalTargetPointVector3 = CandidateData.point
						FinalTargetLocalPointVector3 = CandidateData.localPoint
						FinalTargetCubeCFrame = CandidateData.cubeCFrame
						FinalTargetCubeSize = CandidateData.cubeSize
					end
				end
			end
		end
	end

	if not CurrentTargetValidBoolean and not FinalTargetPartInstance then
		if DebugModeEnabledBoolean then
			DebugLog("target-cleared", "Clearing current target because no valid target or candidate exists", false)
		end
		ResetNormalHookHitChanceDecision()
		CurrentTargetPartInstance = nil
		CurrentTargetCharacterModel = nil
		CurrentTargetPlayerObject = nil
		CurrentTargetPointVector3 = nil
		CurrentTargetAimPointVector3 = nil
		CurrentTargetLocalPointVector3 = nil
		CurrentTargetCubeCFrame = nil
		CurrentTargetCubeSize = nil
	end

	if FinalTargetPartInstance and (FinalTargetScreenPositionVector2 or IsSillyModeBehaviorActive()) then
		local NewTargetPointVector3 = FinalTargetPointVector3 or FinalTargetPartInstance.Position
		local NewTargetAimPointVector3 = ResolveTargetAimPointVector3(
			LocalCharacterModel,
			FinalTargetCharacterModel,
			FinalTargetPartInstance,
			NewTargetPointVector3
		) or NewTargetPointVector3
		if CurrentTargetPartInstance ~= FinalTargetPartInstance
			or CurrentTargetPointVector3 ~= NewTargetPointVector3
			or CurrentTargetLocalPointVector3 ~= FinalTargetLocalPointVector3 then
			local FinalIdentityString = GetTargetIdentity(FinalTargetPlayerObject, FinalTargetCharacterModel, FinalTargetPartInstance)
			UpdateDebugStatus("locked=" .. FinalIdentityString)
			local LockedDistanceNumber = CandidateData and CandidateData.distance or CurrentTargetDistanceNumber or 0
			if FinalTargetScreenPositionVector2 then
				LockedDistanceNumber = (FinalTargetScreenPositionVector2 - MouseLocationVector2).Magnitude
			end
			if DebugModeEnabledBoolean then
				DebugLog("target-locked", "Locked target " .. FinalIdentityString .. " | target distance=" .. string.format("%.1f", LockedDistanceNumber), true)
			end
			ResetNormalHookHitChanceDecision()
			CurrentTargetPartInstance = FinalTargetPartInstance
			CurrentTargetCharacterModel = FinalTargetCharacterModel
			CurrentTargetPlayerObject = FinalTargetPlayerObject
			CurrentTargetPointVector3 = NewTargetPointVector3
			CurrentTargetLocalPointVector3 = FinalTargetLocalPointVector3
			CurrentTargetCubeCFrame = FinalTargetCubeCFrame
			CurrentTargetCubeSize = FinalTargetCubeSize
		end
		CurrentTargetAimPointVector3 = NewTargetAimPointVector3
	end

	if not IndicatorScreenPositionVector2 and CandidateData and CandidateData.screen and CandidateData.point then
		IndicatorScreenPositionVector2 = CandidateData.screen
		IndicatorPointVector3 = CandidateData.point
		IndicatorCubeCFrame = CandidateData.cubeCFrame
		IndicatorCubeSize = CandidateData.cubeSize
		IndicatorPartInstance = CandidateData.part
		IndicatorCharacterModel = CandidateData.character
	end

	if not IndicatorScreenPositionVector2 and FallbackIndicatorData and FallbackIndicatorData.screen and FallbackIndicatorData.point then
		IndicatorScreenPositionVector2 = FallbackIndicatorData.screen
		IndicatorPointVector3 = FallbackIndicatorData.point
		IndicatorCubeCFrame = FallbackIndicatorData.cubeCFrame
		IndicatorCubeSize = FallbackIndicatorData.cubeSize
		IndicatorPartInstance = FallbackIndicatorData.part
		IndicatorCharacterModel = FallbackIndicatorData.character
	end

	local HasValidIndicatorTargetBoolean = CurrentTargetPartInstance
		and CurrentTargetCharacterModel
		and CurrentTargetPartInstance.Parent
		and IndicatorCharacterModel == CurrentTargetCharacterModel
		and IsCharacterAlive(CurrentTargetCharacterModel)

	if HasValidIndicatorTargetBoolean and IndicatorScreenPositionVector2 and IndicatorPointVector3 and IndicatorPartInstance and ShowTargetLineBoolean then
		TargetLine.From = MouseLocationVector2
		TargetLine.To = IndicatorScreenPositionVector2
		TargetLine.Visible = true
		local IndicatorIdentityString = GetTargetIdentity(CurrentTargetPlayerObject, IndicatorCharacterModel, IndicatorPartInstance)
		UpdateDebugStatus("line draw=" .. IndicatorIdentityString)
		if DebugModeEnabledBoolean then
			DebugLog("line-drawing", "Drawing target line to " .. IndicatorIdentityString .. " at " .. tostring(IndicatorScreenPositionVector2), false)
		end
		local CubeCFrame = IndicatorCubeCFrame or IndicatorPartInstance.CFrame
		local CubeSize = IndicatorCubeSize or GetCubeSize(IndicatorPartInstance)
		UpdateTargetCube(CubeCFrame, CubeSize, IndicatorPointVector3)
	else
		TargetLine.Visible = false
		SetTargetCubeVisible(false)
		local HiddenReasonParts = {}
		if not HasValidIndicatorTargetBoolean then
			table.insert(HiddenReasonParts, "no valid target")
		end
		if not ShowTargetLineBoolean then
			table.insert(HiddenReasonParts, "toggle off")
		end
		if not IndicatorScreenPositionVector2 then
			table.insert(HiddenReasonParts, "no screen point")
		end
		if not IndicatorPointVector3 then
			table.insert(HiddenReasonParts, "no world point")
		end
		if not IndicatorPartInstance then
			table.insert(HiddenReasonParts, "no part")
		end
		local HiddenReasonString = table.concat(HiddenReasonParts, ", ")
		UpdateDebugStatus("line hidden=" .. HiddenReasonString)
		if DebugModeEnabledBoolean then
			DebugLog("line-hidden", "Target line hidden because " .. HiddenReasonString .. " | current=" .. SafeDebugName(CurrentTargetPartInstance) .. " | mouse target=" .. SafeDebugName(MouseOverPartInstance), false)
		end
	end

	if CurrentTargetPartInstance and IsCharacterAlive(CurrentTargetCharacterModel) then
		local TargetPositionVector3 = GetCurrentEffectiveAimPointVector3()
			or GetCurrentTrackedTargetPointVector3()
			or CurrentTargetPartInstance.Position

		local ShouldAimbotBoolean = true
		if AimbotRequireRmbBoolean then
			ShouldAimbotBoolean = ShieldModeRuntimeTable.IsLockKeyHeld()
		end

		if ShouldAimbotBoolean and IsEffectiveCameraMethodEnabled() then
			local CameraPositionVector3 = Camera.CFrame.Position
			local DirectionVector3 = (TargetPositionVector3 - CameraPositionVector3).Unit
			local CurrentLookVector = Camera.CFrame.LookVector
			local SmoothedLookVector = CurrentLookVector:Lerp(DirectionVector3, AimbotSmoothingNumber)
			Camera.CFrame = CFrame.new(CameraPositionVector3, CameraPositionVector3 + SmoothedLookVector)
		end

		local ScopeAllowedBoolean = true
		if UseCustomScopeCheckBoolean then
			local PlayerGui = LocalPlayer.FindFirstChild(LocalPlayer, "PlayerGui")
			local MainUI = PlayerGui and PlayerGui.FindFirstChild(PlayerGui, "MainUI")
			local ScopeObject = MainUI and MainUI.FindFirstChild(MainUI, "Scope")
			ScopeAllowedBoolean = ScopeObject and ScopeObject.Visible or false
		end

		local AutoFireScopeAllowedBoolean = ScopeAllowedBoolean or ShieldModeRuntimeTable.IsHookOnlyMethodEnabled()

		local IsTypingBoolean = IsTypingInTextBox()
		local MouseOverAimbotUiBoolean = IsMouseOverAimbotUi(MouseLocationVector2)
		local ShouldAutoFireBoolean = IsEffectiveAutoFireEnabled()
			and not IsTypingBoolean
			and not MouseOverAimbotUiBoolean
			and ShouldAimbotBoolean
			and CurrentTargetCharacterModel
			and AutoFireScopeAllowedBoolean
		local ShouldAutoFireCurrentTargetBoolean = false
		if ShouldAutoFireBoolean then
			if ShieldModeRuntimeTable.IsHookOnlyMethodEnabled() then
				ShouldAutoFireCurrentTargetBoolean = true
			elseif MouseObject.Target and MouseObject.Target.IsDescendantOf(MouseObject.Target, CurrentTargetCharacterModel) then
				ShouldAutoFireCurrentTargetBoolean = true
			end
		end

		local ShieldModeUsableBoolean = false
		local ShieldModeShotContextTable = nil
		if IsBloodZonePlaceBoolean then
			ShieldModeUsableBoolean, ShieldModeShotContextTable = ShieldModeRuntimeTable.UpdateCombatState(LocalCharacterModel, ShouldAutoFireBoolean and ShouldAutoFireCurrentTargetBoolean)
		end
		if ShieldModeUsableBoolean then
			if ShieldModeShotContextTable then
				SendAimbotMouseClick(MouseLocationVector2)
				ShieldModeRuntimeTable.FinalizeShot(ShieldModeShotContextTable)
			end
		elseif ShouldAutoFireBoolean and ShouldAutoFireCurrentTargetBoolean then
			local NowNumber = tick()
			if NowNumber - LastAutoFireTimeNumber >= AutoFireCooldownNumber then
				LastAutoFireTimeNumber = NowNumber
				SendAimbotMouseClick(MouseLocationVector2)
			end
		end
	elseif IsBloodZonePlaceBoolean and IsEffectiveShieldModeEnabled() then
		ShieldModeRuntimeTable.UpdateCombatState(LocalCharacterModel, false)
	end
end)
