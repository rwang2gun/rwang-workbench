#Requires -Version 5.1
<#
.SYNOPSIS
  rwang-workbench marketplace/plugin manifest validator.
.DESCRIPTION
  Structural checks for marketplace.json, each pack's plugin.json, optional
  recommends.json, THIRD_PARTY_NOTICES consistency, and pre-commit hook
  presence. Runs all checks and reports in a single pass. Exits 1 on any
  FAIL, otherwise 0. PowerShell 5.1 compatible.
.NOTES
  Designed per docs/phase6-plan.md Batch 6A (V-1..V-6).
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot

$script:Results = @()
$script:PassCount = 0
$script:WarnCount = 0
$script:FailCount = 0
$script:InfoCount = 0

function Add-Result {
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Label,
        [Parameter(Mandatory)][ValidateSet('PASS','WARN','FAIL','INFO')][string]$Status,
        [string]$Detail = ''
    )
    $script:Results += [PSCustomObject]@{
        Id = $Id; Label = $Label; Status = $Status; Detail = $Detail
    }
    switch ($Status) {
        'PASS' { $script:PassCount++ }
        'WARN' { $script:WarnCount++ }
        'FAIL' { $script:FailCount++ }
        'INFO' { $script:InfoCount++ }
    }
}

function Read-JsonFile {
    param([Parameter(Mandatory)][string]$Path)
    $raw = Get-Content -Path $Path -Raw -Encoding UTF8 -ErrorAction Stop
    return ($raw | ConvertFrom-Json -ErrorAction Stop)
}

# ---------- V-1: marketplace.json ----------
function Test-Marketplace {
    $rel = '.claude-plugin/marketplace.json'
    $path = Join-Path $RepoRoot $rel
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Add-Result -Id 'V-1' -Label 'marketplace.json structure' -Status 'FAIL' -Detail "missing: $rel"
        return $null
    }
    try {
        $json = Read-JsonFile -Path $path
    } catch {
        Add-Result -Id 'V-1' -Label 'marketplace.json structure' -Status 'FAIL' -Detail "JSON parse error: $($_.Exception.Message)"
        return $null
    }
    $missing = @()
    foreach ($field in @('name','owner','plugins')) {
        if (-not ($json.PSObject.Properties.Name -contains $field)) { $missing += $field }
    }
    if ($missing.Count -gt 0) {
        Add-Result -Id 'V-1' -Label 'marketplace.json structure' -Status 'FAIL' -Detail ("missing fields: " + ($missing -join ', '))
        return $null
    }
    if (-not ($json.plugins -is [Array])) {
        Add-Result -Id 'V-1' -Label 'marketplace.json structure' -Status 'FAIL' -Detail "'plugins' is not a JSON array"
        return $null
    }
    $plugins = @($json.plugins)
    if ($plugins.Count -eq 0) {
        Add-Result -Id 'V-1' -Label 'marketplace.json structure' -Status 'FAIL' -Detail 'plugins[] is empty'
        return $null
    }
    Add-Result -Id 'V-1' -Label 'marketplace.json structure' -Status 'PASS' -Detail ("{0} plugins registered" -f $plugins.Count)
    return $json
}

# ---------- V-2 / V-3: per-pack plugin.json ----------
$AllowedPluginFields = @('name','description','version','author','keywords','homepage','icon','license')

function Test-PluginManifest {
    param([Parameter(Mandatory)][string]$PackName)
    $rel = "plugins/$PackName/.claude-plugin/plugin.json"
    $path = Join-Path (Join-Path $RepoRoot 'plugins') (Join-Path $PackName '.claude-plugin/plugin.json')
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Add-Result -Id 'V-2' -Label "$PackName/plugin.json" -Status 'FAIL' -Detail "missing: $rel"
        return
    }
    try {
        $json = Read-JsonFile -Path $path
    } catch {
        Add-Result -Id 'V-2' -Label "$PackName/plugin.json" -Status 'FAIL' -Detail "JSON parse error: $($_.Exception.Message)"
        return
    }
    $missing = @()
    foreach ($field in @('name','description')) {
        if (-not ($json.PSObject.Properties.Name -contains $field)) { $missing += $field }
    }
    if ($missing.Count -gt 0) {
        Add-Result -Id 'V-2' -Label "$PackName/plugin.json" -Status 'FAIL' -Detail ("missing required fields: " + ($missing -join ', '))
    } else {
        Add-Result -Id 'V-2' -Label "$PackName/plugin.json" -Status 'PASS'
    }

    # V-3 unknown-field check
    $present = @($json.PSObject.Properties.Name)
    $unknown = @($present | Where-Object { $AllowedPluginFields -notcontains $_ })
    if ($unknown.Count -gt 0) {
        Add-Result -Id 'V-3' -Label "$PackName/plugin.json unknown fields" -Status 'WARN' -Detail ("unknown: " + ($unknown -join ', '))
    } else {
        Add-Result -Id 'V-3' -Label "$PackName/plugin.json unknown fields" -Status 'PASS' -Detail 'none found'
    }
}

# ---------- V-4: recommends.json (optional) ----------
function Test-Recommends {
    param([Parameter(Mandatory)][string]$PackName)
    $path = Join-Path (Join-Path $RepoRoot 'plugins') (Join-Path $PackName '.claude-plugin/recommends.json')
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        return
    }
    try {
        $json = Read-JsonFile -Path $path
    } catch {
        Add-Result -Id 'V-4' -Label "$PackName recommends.json" -Status 'FAIL' -Detail "JSON parse error: $($_.Exception.Message)"
        return
    }
    if (-not ($json.PSObject.Properties.Name -contains 'recommends')) {
        Add-Result -Id 'V-4' -Label "$PackName recommends.json" -Status 'FAIL' -Detail "missing 'recommends' key"
        return
    }
    if (-not ($json.recommends -is [Array])) {
        Add-Result -Id 'V-4' -Label "$PackName recommends.json" -Status 'FAIL' -Detail "'recommends' is not a JSON array"
        return
    }
    $items = @($json.recommends)
    $badIdx = @()
    for ($i = 0; $i -lt $items.Count; $i++) {
        $item = $items[$i]
        if ($null -eq $item) { $badIdx += $i; continue }
        $props = @($item.PSObject.Properties.Name)
        if (($props -notcontains 'name') -or ($props -notcontains 'reason')) {
            $badIdx += $i
        }
    }
    if ($badIdx.Count -gt 0) {
        Add-Result -Id 'V-4' -Label "$PackName recommends.json" -Status 'FAIL' -Detail ("items missing name/reason at index: " + ($badIdx -join ', '))
    } else {
        Add-Result -Id 'V-4' -Label "$PackName recommends.json" -Status 'PASS' -Detail ("{0} items" -f $items.Count)
    }
}

# ---------- V-5: THIRD_PARTY_NOTICES consistency ----------
function Get-VendoredPluginSet {
    $pluginsRoot = Join-Path $RepoRoot 'plugins'
    if (-not (Test-Path -LiteralPath $pluginsRoot -PathType Container)) { return @() }
    $set = @{}
    $files = Get-ChildItem -Path $pluginsRoot -Recurse -File -ErrorAction SilentlyContinue
    foreach ($f in $files) {
        try {
            $matches = Select-String -LiteralPath $f.FullName -Pattern 'vendored-from:\s*https?://\S+' -AllMatches -ErrorAction SilentlyContinue
        } catch { continue }
        if ($null -eq $matches) { continue }
        foreach ($m in $matches) {
            foreach ($mm in $m.Matches) {
                $line = $mm.Value
                $nameMatch = [regex]::Match($line, '/plugins/([^/\s]+)')
                if ($nameMatch.Success) {
                    $name = $nameMatch.Groups[1].Value
                    if (-not $set.ContainsKey($name)) { $set[$name] = $true }
                }
            }
        }
    }
    return @($set.Keys | Sort-Object)
}

function Get-NoticesPluginSet {
    $path = Join-Path $RepoRoot 'THIRD_PARTY_NOTICES.md'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $null }
    $lines = Get-Content -LiteralPath $path -Encoding UTF8
    $sepIdx = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^\s*\|\s*---') { $sepIdx = $i; break }
    }
    if ($sepIdx -lt 0) { return $null }
    $set = @{}
    for ($i = $sepIdx + 1; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match '^\s*$') { break }
        if ($line -notmatch '^\s*\|') { break }
        $cols = $line -split '\|'
        if ($cols.Count -lt 2) { continue }
        $name = $cols[1].Trim()
        if ($name -eq '' -or $name -eq 'Plugin') { continue }
        if (-not $set.ContainsKey($name)) { $set[$name] = $true }
    }
    return @($set.Keys | Sort-Object)
}

function Test-Notices {
    $vendored = @(Get-VendoredPluginSet)
    $notices = Get-NoticesPluginSet
    if ($null -eq $notices) {
        Add-Result -Id 'V-5' -Label 'THIRD_PARTY_NOTICES consistency' -Status 'WARN' -Detail 'THIRD_PARTY_NOTICES.md first table not found'
        return
    }
    $noticesArr = @($notices)
    $onlyVendored = @($vendored | Where-Object { $noticesArr -notcontains $_ })
    $onlyNotices  = @($noticesArr | Where-Object { $vendored -notcontains $_ })
    if ($onlyVendored.Count -eq 0 -and $onlyNotices.Count -eq 0) {
        Add-Result -Id 'V-5' -Label 'THIRD_PARTY_NOTICES consistency' -Status 'PASS' -Detail ("{0}/{1} plugins matched" -f $vendored.Count, $noticesArr.Count)
    } else {
        $parts = @()
        if ($onlyVendored.Count -gt 0) { $parts += ("only in vendored: " + ($onlyVendored -join ', ')) }
        if ($onlyNotices.Count -gt 0)  { $parts += ("only in NOTICES: " + ($onlyNotices -join ', ')) }
        Add-Result -Id 'V-5' -Label 'THIRD_PARTY_NOTICES consistency' -Status 'WARN' -Detail ($parts -join ' | ')
    }
}

# ---------- V-6: pre-commit hook ----------
function Test-PreCommitHook {
    $path = Join-Path $RepoRoot 'scripts/git-hooks/pre-commit'
    if (Test-Path -LiteralPath $path -PathType Leaf) {
        Add-Result -Id 'V-6' -Label 'pre-commit hook file' -Status 'INFO' -Detail 'exists'
    } else {
        Add-Result -Id 'V-6' -Label 'pre-commit hook file' -Status 'WARN' -Detail "missing: scripts/git-hooks/pre-commit"
    }
}

# ---------- main ----------
Write-Host 'rwang-workbench validate-plugins v1.0'
Write-Host '========================================'

$marketplace = Test-Marketplace

$packs = @()
if ($null -ne $marketplace) {
    foreach ($p in @($marketplace.plugins)) { $packs += $p.name }
} else {
    # Fallback: scan plugins/ directory so V-2..V-4 still run for diagnostics.
    $pluginsRoot = Join-Path $RepoRoot 'plugins'
    if (Test-Path -LiteralPath $pluginsRoot -PathType Container) {
        $packs = @(Get-ChildItem -Path $pluginsRoot -Directory | Select-Object -ExpandProperty Name)
    }
}

foreach ($pack in $packs) {
    Test-PluginManifest -PackName $pack
}
foreach ($pack in $packs) {
    Test-Recommends -PackName $pack
}
Test-Notices
Test-PreCommitHook

foreach ($r in $script:Results) {
    $label = ("[{0}] {1}" -f $r.Id, $r.Label).PadRight(46)
    $line = "{0} ... {1}" -f $label, $r.Status
    if ($r.Detail -ne '') { $line = "{0}  ({1})" -f $line, $r.Detail }
    Write-Host $line
}

Write-Host '========================================'
Write-Host ("Result: {0} PASS, {1} WARN, {2} FAIL, {3} INFO" -f $script:PassCount, $script:WarnCount, $script:FailCount, $script:InfoCount)

if ($script:FailCount -gt 0) { exit 1 } else { exit 0 }
