$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
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

foreach ($relativePath in $segmentPaths) {
    $absolutePath = Join-Path $repoRoot $relativePath
    if (-not (Test-Path -LiteralPath $absolutePath)) {
        throw "Missing source segment: $relativePath"
    }

    [void]$builder.Append([System.IO.File]::ReadAllText($absolutePath))
}

$outputPath = Join-Path $repoRoot "bloodzone_aimbot.lua"
[System.IO.File]::WriteAllText($outputPath, $builder.ToString(), $utf8NoBom)

Write-Host ("Built {0} from {1} source segments." -f $outputPath, $segmentPaths.Count)
