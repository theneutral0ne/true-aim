LockKeyModesTable = { "RMB", "E", "Always" }
LockKeyModeIndexNumber = 1
SillyModeEnabledBoolean = false
SillyModeRuntimeActiveBoolean = false
SillySkyAimEnabledBoolean = true
SillySkyVisibilityCheckEnabledBoolean = true
ShieldModeEnabledBoolean = false
NormalHookHitChanceDecisionWindowNumber = 0.02
LastNormalHookHitChanceDecisionTimeNumber = 0
LastNormalHookHitChanceDecisionBoolean = true
local PlayerListRuntimeTable: { [string]: any } = {
	whitelistByPlayer = {},
	priorityByPlayer = {},
	entryButtonsByPlayer = {},
	entryStateCache = setmetatable({}, { __mode = "k" }),
	refreshInterval = CurrentGameIntegrationPlayerListRefreshIntervalNumber,
	lastRefreshTime = 0,
}
PlayerListEntryStateCacheDurationNumber = CurrentGameIntegrationPlayerListEntryCacheDurationNumber
DebugModeEnabledBoolean = false
DebugPrintIntervalNumber = 0.35
DebugLastPrintByKeyTable = {}
TraceModeEnabledBoolean = false
TracePrintIntervalNumber = 0.08
TraceLastPrintByKeyTable = {}
DebugRejectCountsTable = {}
local ShieldModeRuntimeTable: { [string]: any } = {
	nextShotTime = 0,
	pendingReequipTime = 0,
	secondaryReadyTime = 0,
	reloadHoldUntilTime = 0,
	reloadObserved = false,
	reloadDeferredForThreat = false,
	reloadSuppressionActive = false,
	savedAutoReloadSetting = nil,
	savedCancelReloadingSetting = nil,
	reloadResumeUntilTime = 0,
	lastThreatScanTime = 0,
	cachedThreatData = nil,
	threatScanInterval = 0.08,
	lastEquipAttemptTime = 0,
	equipThrottle = 0.03,
	localData = nil,
	weaponData = nil,
	localCharacterModule = nil,
	localGunModule = nil,
	weaponClientModule = nil,
	clientProjectilesModule = nil,
	cursorModule = nil,
	directionIndicatorModule = nil,
	localCharacterHooksApplied = false,
	localGunHooksApplied = false,
	cursorHooksApplied = false,
	forcedBodyRotationCFrame = nil,
	activeLocalGun = nil,
	activeFiringLocalGun = nil,
	skyAimSolutionCache = nil,
	heldItemStateCacheDuration = 0.2,
	GetBloodZoneHeldItemState = nil,
}
ShieldModeRuntimeTable.heldItemStateCache = setmetatable({}, { __mode = "k" })
local GetSearchableCharacterEntries
local RaycastBetweenIgnoringGlass
local IsCharacterForceFieldProtected
local GetPreferredTargetPart
local HasEquippedGun
local IsRaycastResultTargetHit
local RunUnredirectedWorkspaceRaycast
