local RunService = game.GetService(game, "RunService")
local Players = game.GetService(game, "Players")
local WorkspaceService = game.GetService(game, "Workspace")
local CollectionService = game.GetService(game, "CollectionService")
local ReplicatedStorageService = game.GetService(game, "ReplicatedStorage")
local UserInputService = game.GetService(game, "UserInputService")
local GuiService = game.GetService(game, "GuiService")
local TweenService = game.GetService(game, "TweenService")
local VirtualInputManager = game.GetService(game, "VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = WorkspaceService.CurrentCamera
local MouseObject = LocalPlayer.GetMouse(LocalPlayer)

FovCircle = Drawing.new("Circle")
FovCircle.Radius = 300
FovCircle.Thickness = 2
FovCircle.Filled = false
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Transparency = 1
FovCircle.Visible = true
FovCircle.NumSides = 64

TargetLine = Drawing.new("Line")
TargetLine.Thickness = 1
TargetLine.Transparency = 1
TargetLine.Color = Color3.fromRGB(255, 255, 255)
TargetLine.Visible = false

TargetCubeEdgeColor3 = Color3.fromRGB(255, 220, 0)
TargetCubeLineThicknessNumber = 2
TargetCubeLines = {}
TargetCubeEdgePairsTable = {
	{ 1, 2 }, { 2, 3 }, { 3, 4 }, { 4, 1 },
	{ 5, 6 }, { 6, 7 }, { 7, 8 }, { 8, 5 },
	{ 1, 5 }, { 2, 6 }, { 3, 7 }, { 4, 8 },
}

for LineIndex = 1, #TargetCubeEdgePairsTable do
	local Line = Drawing.new("Line")
	Line.Thickness = TargetCubeLineThicknessNumber
	Line.Transparency = 1
	Line.Color = TargetCubeEdgeColor3
	Line.Visible = false
	TargetCubeLines[LineIndex] = Line
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
CurrentWeaponBallisticsProfileTable = nil
LastFallbackIndicatorPartInstance = nil
LastFallbackIndicatorCharacterModel = nil
LastFallbackIndicatorPlayerObject = nil
CurrentFrameSequenceNumber = 0
CurrentFrameLocalCharacterModel = nil
CurrentFrameLocalCharacterReadyBoolean = false

AimbotSmoothingNumber = 0.2
AimbotRequireRmbBoolean = true
NormalHookHitChanceNumber = 100
StickyAimEnabledBoolean = false

MinSmoothingNumber = 0.01
MaxSmoothingNumber = 1.0

MinFovRadiusNumber = 50
MaxFovRadiusNumber = 600
MinNormalHookHitChanceNumber = 0
MaxNormalHookHitChanceNumber = 100

MaxDistanceNumber = 5000

HeadshotPriorityBoolean = false

AutoFireEnabledBoolean = true
AutoFireCooldownNumber = 0.1
LastAutoFireTimeNumber = 0

VisibleCheckEnabledBoolean = true
VisibleCheckSubdivisionsNumber = 4
TargetSegmentationEnabledBoolean = false
SkyAimHitDistanceNumber = 4096
SkyAimSolutionCacheDurationNumber = 0.05
SkyAimPreferredPitchDegreesNumber = 45
SkyAimSamplePitchDegreesTable = { 88, 76, 64, 52, 45, 40, 28, 16 }
SkyAimSampleYawOffsetDegreesTable = { 0, 15, -15, 30, -30, 45, -45, 60, -60, 90, -90, 180 }
SkyAimVisibilitySamplePitchDegreesTable = { 88, 70, 52, 45, 34, 18 }
SkyAimVisibilitySampleYawOffsetDegreesTable = { 0, 30, -30, 60, -60, 90, -90, 180 }

ShowFovCircleBoolean = true
ShowTargetLineBoolean = true

UseHookMethodBoolean = true
UseCameraMethodBoolean = true

RetargetMinImprovementNumber = 0
TargetSearchIntervalNumber = 0.1
LastTargetSearchTimeNumber = 0
VisibilityRaycastParams = RaycastParams.new()
VisibilityRaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
LastRaycastCharacterModel = nil
CustomCharacterCacheDurationNumber = 0.2
TargetablePartsCacheDurationNumber = 0.25
SearchableCharacterEntriesCacheDurationNumber = 0.25
PlayerListMenuRefreshIntervalNumber = 1.25
CachedCharactersFolderInstance = nil
CachedCharacterFolderChildCountNumber = -1
CachedCharacterFolderScanTimeNumber = 0
CachedDirectCharacterModelsTable = {}
CachedCustomCharacterByPlayerTable = {}
ResolveCharacterModelCacheDurationNumber = 0.15
ResolveCharacterModelCacheTable = setmetatable({}, { __mode = "k" })
TargetablePartsCacheTable = {}
CachedSearchableCharacterEntriesTable = {}
CachedSearchableCharacterEntriesKeyString = nil
CachedSearchableCharacterEntriesTimeNumber = 0
FrameTargetDataCacheTable = {
	normal = {},
	ignoreFov = {},
}
FrameVisiblePointCacheTable = {}
FrameCharacterAliveCacheTable = {}
FrameCharacterVelocityCacheTable = {}
ObservedCharacterVelocitySampleByModelTable = setmetatable({}, { __mode = "k" })
