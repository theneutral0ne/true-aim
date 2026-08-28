$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$repositoryFullName = "theneutral0ne/true-aim"
$branchName = "main"
$bundleRelativePath = "dist/true-aim.bundle.lua"
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

function Add-BundleLine {
    param(
        [System.Text.StringBuilder]$Builder,
        [string]$Line = ""
    )

    [void]$Builder.AppendLine($Line)
}

function ConvertTo-LuaQuotedStringLiteral {
    param([AllowNull()][string]$Text)

    if ($null -eq $Text) {
        return "nil"
    }

    $escapedText = $Text.Replace('\', '\\').Replace('"', '\"').Replace("`r", '\r').Replace("`n", '\n').Replace("`t", '\t')
    return '"' + $escapedText + '"'
}

function Get-TopLevelLocalDeclarationNames {
    param([AllowNull()][string]$DeclarationText)

    $exportNameList = New-Object 'System.Collections.Generic.List[string]'
    if ([string]::IsNullOrWhiteSpace($DeclarationText)) {
        return @()
    }

    foreach ($declarationPart in $DeclarationText -split ',') {
        $exportName = ($declarationPart -split ':', 2)[0].Trim()
        if ($exportName -match '^[A-Za-z_][A-Za-z0-9_]*$' -and -not $exportNameList.Contains($exportName)) {
            $exportNameList.Add($exportName) | Out-Null
        }
    }

    return $exportNameList.ToArray()
}

function Get-TopLevelLocalExportNames {
    param([AllowNull()][string]$SourceText)

    $exportNameList = New-Object 'System.Collections.Generic.List[string]'
    if ($null -eq $SourceText) {
        return @()
    }

    $sourceLines = $SourceText -split "`r?`n"
    foreach ($sourceLine in $sourceLines) {
        if ($sourceLine -notmatch '^local\s+') {
            continue
        }

        if ($sourceLine -match '^local\s+function\s+([A-Za-z_][A-Za-z0-9_]*)(.*)$') {
            $exportName = $Matches[1]
            if (-not $exportNameList.Contains($exportName)) {
                $exportNameList.Add($exportName) | Out-Null
            }
            continue
        }

        if ($sourceLine -match '^local\s+(.+?)(\s*=\s*.*)?$') {
            foreach ($exportName in Get-TopLevelLocalDeclarationNames $Matches[1]) {
                if (-not $exportNameList.Contains($exportName)) {
                    $exportNameList.Add($exportName) | Out-Null
                }
            }
        }
    }

    return $exportNameList.ToArray()
}

function Get-TopLevelSharedLocalNames {
    param([object[]]$SegmentMetadataArray)

    $sharedNameList = New-Object 'System.Collections.Generic.List[string]'

    for ($currentIndex = 0; $currentIndex -lt $SegmentMetadataArray.Count; $currentIndex++) {
        $currentMetadata = $SegmentMetadataArray[$currentIndex]
        foreach ($exportName in $currentMetadata.ExportNames) {
            if ($sharedNameList.Contains($exportName)) {
                continue
            }

            for ($laterIndex = $currentIndex + 1; $laterIndex -lt $SegmentMetadataArray.Count; $laterIndex++) {
                $laterSourceText = $SegmentMetadataArray[$laterIndex].SourceText
                if ($laterSourceText -match ('(?<![A-Za-z0-9_])' + [regex]::Escape($exportName) + '(?![A-Za-z0-9_])')) {
                    $sharedNameList.Add($exportName) | Out-Null
                    break
                }
            }
        }
    }

    return $sharedNameList.ToArray()
}

function Convert-SharedTopLevelLocalsToAssignments {
    param(
        [AllowNull()][string]$SourceText,
        [System.Collections.Generic.HashSet[string]]$SharedLocalNameSet,
        [string]$RelativePath
    )

    if ($null -eq $SourceText) {
        return ""
    }

    $transformedLineList = New-Object 'System.Collections.Generic.List[string]'
    $sourceLines = $SourceText -split "`r?`n"

    for ($lineIndex = 0; $lineIndex -lt $sourceLines.Count; $lineIndex++) {
        $sourceLine = $sourceLines[$lineIndex]

        if ($sourceLine -match '^local\s+function\s+([A-Za-z_][A-Za-z0-9_]*)(.*)$') {
            $functionName = $Matches[1]
            if ($SharedLocalNameSet.Contains($functionName)) {
                $transformedLineList.Add("function $functionName$($Matches[2])") | Out-Null
            } else {
                $transformedLineList.Add($sourceLine) | Out-Null
            }
            continue
        }

        if ($sourceLine -match '^local\s+(.+?)(\s*=\s*.*)?$') {
            $declarationText = $Matches[1]
            $initializerSuffix = $Matches[2]
            $declarationNames = @(Get-TopLevelLocalDeclarationNames $declarationText)
            if ($declarationNames.Count -eq 0) {
                $transformedLineList.Add($sourceLine) | Out-Null
                continue
            }

            $sharedDeclarationNames = @($declarationNames | Where-Object { $SharedLocalNameSet.Contains($_) })
            if ($sharedDeclarationNames.Count -eq 0) {
                $transformedLineList.Add($sourceLine) | Out-Null
                continue
            }

            if ($sharedDeclarationNames.Count -ne $declarationNames.Count) {
                throw "Mixed shared/non-shared top-level local declaration in $RelativePath at line $($lineIndex + 1): $sourceLine"
            }

            $assignmentLeftSide = [string]::Join(", ", $declarationNames)
            if ([string]::IsNullOrWhiteSpace($initializerSuffix)) {
                $transformedLineList.Add($assignmentLeftSide + " = " + $assignmentLeftSide) | Out-Null
            } else {
                $transformedLineList.Add($assignmentLeftSide + $initializerSuffix) | Out-Null
            }
            continue
        }

        $transformedLineList.Add($sourceLine) | Out-Null
    }

    return [string]::Join([Environment]::NewLine, $transformedLineList)
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$distDirectoryPath = Join-Path $repoRoot "dist"
$bundleOutputPath = Join-Path $repoRoot $bundleRelativePath
$launcherOutputPath = Join-Path $repoRoot "true-aim.lua"

New-Item -ItemType Directory -Force -Path $distDirectoryPath | Out-Null

$segmentMetadataList = New-Object 'System.Collections.Generic.List[object]'
$totalExportCount = 0

foreach ($relativePath in $segmentPaths) {
    $absolutePath = Join-Path $repoRoot $relativePath
    if (-not (Test-Path -LiteralPath $absolutePath)) {
        throw "Missing source segment: $relativePath"
    }

    $normalizedRelativePath = $relativePath -replace "\\", "/"
    $sourceText = [System.IO.File]::ReadAllText($absolutePath)
    $exportNames = @(Get-TopLevelLocalExportNames $sourceText)
    $totalExportCount += $exportNames.Count

    $segmentMetadataList.Add([pscustomobject]@{
        RelativePath = $normalizedRelativePath
        SourceText = $sourceText
        ExportNames = $exportNames
    }) | Out-Null
}

$sharedLocalNames = @(Get-TopLevelSharedLocalNames $segmentMetadataList)
$sharedLocalNameSet = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
foreach ($sharedLocalName in $sharedLocalNames) {
    $sharedLocalNameSet.Add($sharedLocalName) | Out-Null
}

$bundleBuilder = New-Object System.Text.StringBuilder
Add-BundleLine $bundleBuilder "-- true-aim bundle: generated by scripts/build.ps1"
Add-BundleLine $bundleBuilder ('-- repository: ' + $repositoryFullName + ' @ ' + $branchName)
Add-BundleLine $bundleBuilder ('-- assembled segments: ' + $segmentPaths.Count)
Add-BundleLine $bundleBuilder ('-- shared top-level locals: ' + $sharedLocalNames.Count)
Add-BundleLine $bundleBuilder ""

if ($sharedLocalNames.Count -gt 0) {
    $sharedLocalChunkSize = 20
    Add-BundleLine $bundleBuilder "-- cross-segment locals hoisted by the assembler"
    for ($sharedIndex = 0; $sharedIndex -lt $sharedLocalNames.Count; $sharedIndex += $sharedLocalChunkSize) {
        $sharedChunkEndIndex = [Math]::Min($sharedIndex + $sharedLocalChunkSize - 1, $sharedLocalNames.Count - 1)
        $sharedChunk = $sharedLocalNames[$sharedIndex..$sharedChunkEndIndex]
        Add-BundleLine $bundleBuilder ('local ' + [string]::Join(", ", $sharedChunk))
    }
    Add-BundleLine $bundleBuilder ""
}

foreach ($segmentMetadata in $segmentMetadataList) {
    $transformedSourceText = Convert-SharedTopLevelLocalsToAssignments $segmentMetadata.SourceText $sharedLocalNameSet $segmentMetadata.RelativePath
    Add-BundleLine $bundleBuilder ('-- begin segment: ' + $segmentMetadata.RelativePath)
    Add-BundleLine $bundleBuilder "do"
    Add-BundleLine $bundleBuilder $transformedSourceText
    Add-BundleLine $bundleBuilder "end"
    Add-BundleLine $bundleBuilder ('-- end segment: ' + $segmentMetadata.RelativePath)
    Add-BundleLine $bundleBuilder ""
}

[System.IO.File]::WriteAllText($bundleOutputPath, $bundleBuilder.ToString(), $utf8NoBom)

$launcherBuilder = New-Object System.Text.StringBuilder
Add-BundleLine $launcherBuilder "local LoadStringFunction = loadstring or load"
Add-BundleLine $launcherBuilder 'if type(LoadStringFunction) ~= "function" then'
Add-BundleLine $launcherBuilder '	error("true-aim: loadstring is unavailable in this environment", 0)'
Add-BundleLine $launcherBuilder "end"
Add-BundleLine $launcherBuilder ""
Add-BundleLine $launcherBuilder ('local RepositoryFullNameString = ' + (ConvertTo-LuaQuotedStringLiteral $repositoryFullName))
Add-BundleLine $launcherBuilder ('local BranchNameString = ' + (ConvertTo-LuaQuotedStringLiteral $branchName))
Add-BundleLine $launcherBuilder ('local BundleRelativePathString = ' + (ConvertTo-LuaQuotedStringLiteral ($bundleRelativePath -replace "\\", "/")))
Add-BundleLine $launcherBuilder 'local CacheBustString = tostring(os.clock()):gsub("%.", "")'
Add-BundleLine $launcherBuilder 'local RawUrlString = ("https://raw.githubusercontent.com/%s/%s/%s"):format('
Add-BundleLine $launcherBuilder "	RepositoryFullNameString,"
Add-BundleLine $launcherBuilder "	BranchNameString,"
Add-BundleLine $launcherBuilder "	BundleRelativePathString"
Add-BundleLine $launcherBuilder ")"
Add-BundleLine $launcherBuilder 'local SuccessBoolean, ResultValue = pcall(game.HttpGet, game, RawUrlString .. "?v=" .. CacheBustString)'
Add-BundleLine $launcherBuilder "if not SuccessBoolean then"
Add-BundleLine $launcherBuilder '	error(("true-aim: failed to fetch bundle (%s)"):format(tostring(ResultValue)), 0)'
Add-BundleLine $launcherBuilder "end"
Add-BundleLine $launcherBuilder ""
Add-BundleLine $launcherBuilder 'local ChunkFunction, CompileErrorString = LoadStringFunction(ResultValue, "@" .. BundleRelativePathString)'
Add-BundleLine $launcherBuilder 'if type(ChunkFunction) ~= "function" then'
Add-BundleLine $launcherBuilder '	error(("true-aim: failed to compile bundle (%s)"):format(tostring(CompileErrorString)), 0)'
Add-BundleLine $launcherBuilder "end"
Add-BundleLine $launcherBuilder ""
Add-BundleLine $launcherBuilder "return ChunkFunction()"

[System.IO.File]::WriteAllText($launcherOutputPath, $launcherBuilder.ToString(), $utf8NoBom)

Write-Host (
    "Built {0} and {1} from {2} source segments with {3} shared top-level locals ({4} total top-level locals)." -f `
    $bundleOutputPath, `
    $launcherOutputPath, `
    $segmentPaths.Count, `
    $sharedLocalNames.Count, `
    $totalExportCount
)
