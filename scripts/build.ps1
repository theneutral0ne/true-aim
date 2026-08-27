$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$repositoryFullName = "theneutral0ne/true-aim"
$branchName = "main"
$segmentPaths = @(
    "src/shared/00_bootstrap.lua",
    "src/games/00_registry.lua",
    "src/shared/05_runtime_state.lua",
    "src/games/bloodzone/00_settings.lua",
    "src/shared/10_core.lua",
    "src/games/bloodzone/10_ballistics.lua",
    "src/games/bloodzone/20_shield_mode.lua",
    "src/shared/20_ui.lua",
    "src/shared/30_visibility_targeting.lua",
    "src/shared/40_runtime.lua"
)

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$builder = New-Object System.Text.StringBuilder
$distDirectoryPath = Join-Path $repoRoot "dist"
$bundleOutputPath = Join-Path $distDirectoryPath "true-aim.bundle.lua"
$launcherOutputPath = Join-Path $repoRoot "true-aim.lua"

New-Item -ItemType Directory -Force -Path $distDirectoryPath | Out-Null

foreach ($relativePath in $segmentPaths) {
    $absolutePath = Join-Path $repoRoot $relativePath
    if (-not (Test-Path -LiteralPath $absolutePath)) {
        throw "Missing source segment: $relativePath"
    }

    [void]$builder.Append([System.IO.File]::ReadAllText($absolutePath))
}

[System.IO.File]::WriteAllText($bundleOutputPath, $builder.ToString(), $utf8NoBom)

$quotedSegmentPaths = $segmentPaths | ForEach-Object { '    "' + ($_ -replace "\\", "/") + '"' }
$launcherSource = @"
local LoadStringFunction = loadstring or load
if type(LoadStringFunction) ~= "function" then
	error("true-aim: loadstring is unavailable in this environment", 0)
end

local RepositoryFullNameString = "$repositoryFullName"
local BranchNameString = "$branchName"
local ModulePathsTable = {
__MODULE_PATHS__
}

local SourceChunksTable = {}
local CacheBustString = tostring(os.clock()):gsub("%.", "")
for IndexNumber, RelativePathString in ipairs(ModulePathsTable) do
	local RawUrlString = ("https://raw.githubusercontent.com/%s/%s/%s"):format(
		RepositoryFullNameString,
		BranchNameString,
		RelativePathString
	)
	local SuccessBoolean, ResultValue = pcall(game.HttpGet, game, RawUrlString .. "?v=" .. CacheBustString)
	if not SuccessBoolean then
		error(("true-aim: failed to fetch %s (%s)"):format(RelativePathString, tostring(ResultValue)), 0)
	end
	SourceChunksTable[IndexNumber] = ResultValue
end

local ChunkFunction, CompileErrorString = LoadStringFunction(table.concat(SourceChunksTable, "\n"))
if type(ChunkFunction) ~= "function" then
	error(("true-aim: failed to compile remote source (%s)"):format(tostring(CompileErrorString)), 0)
end

return ChunkFunction()
"@
$launcherSource = $launcherSource.Replace("__MODULE_PATHS__", ($quotedSegmentPaths -join ",`n"))
[System.IO.File]::WriteAllText($launcherOutputPath, $launcherSource, $utf8NoBom)

Write-Host ("Built {0} and {1} from {2} source segments." -f $bundleOutputPath, $launcherOutputPath, $segmentPaths.Count)
