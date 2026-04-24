#Requires -Version 5.1
<#
.SYNOPSIS
  rwang-workbench orphan-originals detector for Phase 7.
.DESCRIPTION
  Checks whether the 11 incorporated original plugins (from THIRD_PARTY_NOTICES)
  are independently installed in user scope, and whether ~/.claude/skills/
  contains per-skill clones that duplicate incorporated skills. Reports exit 0
  (clean), 2 (WARN, 7B cleanup needed), or 1 (FAIL, gate blocker).
  PowerShell 5.1 compatible.
.NOTES
  Spec: docs/phase7-plan.md v6 (G1 passed).
  O-1 checks installed_plugins.json via generic key enumeration + scope=='user'
  filter + (exact <name> | <name>@* prefix) match, with strict schema drift
  detection per v5/v6 failure taxonomy.
  O-2 checks ~/.claude/skills/ against union of (plugins/*/skills/<dir>/
  directory names) and (SKILL.md frontmatter name: values).
  O-3 is informational (known_marketplaces.json registration state).
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot

# Per phase7-plan §4.1.2 — 11 incorporated originals from THIRD_PARTY_NOTICES.md
# first table Plugin column (manually copied).
$OriginalPlugins = @(
    'hookify',
    'claude-code-setup',
    'claude-md-management',
    'mcp-server-dev',
    'playground',
    'plugin-dev',
    'session-report',
    'commit-commands',
    'feature-dev',
    'pr-review-toolkit',
    'security-guidance'
)

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

function Get-HomeClaudeDir {
    # PS 5.1: $HOME resolves to the user profile on Windows/mac/linux.
    return Join-Path $HOME '.claude'
}

# ---------- O-1 ----------
function Test-InstalledOriginals {
    $claudeDir = Get-HomeClaudeDir
    $pluginsDir = Join-Path $claudeDir 'plugins'
    $installedJson = Join-Path $pluginsDir 'installed_plugins.json'

    if (-not (Test-Path -LiteralPath $installedJson -PathType Leaf)) {
        # file-missing = PASS per §4.1.2 taxonomy
        foreach ($name in $OriginalPlugins) {
            Add-Result -Id 'O-1' -Label $name -Status 'PASS' -Detail 'installed_plugins.json missing (no user-scope installs)'
        }
        return
    }

    # Read & parse; classify parse/schema errors as FAIL per §4.1.2
    $json = $null
    try {
        $raw = Get-Content -LiteralPath $installedJson -Raw -Encoding UTF8 -ErrorAction Stop
        $json = $raw | ConvertFrom-Json -ErrorAction Stop
    } catch {
        Add-Result -Id 'O-1' -Label 'installed_plugins.json parse' -Status 'FAIL' -Detail ("parse-failed: " + $_.Exception.Message)
        return
    }
    # Case-sensitive 'plugins' field lookup (PS default property access is case-insensitive,
    # so use Properties enumeration with -ceq to enforce exact-case schema).
    if ($null -eq $json -or -not ($json -is [psobject])) {
        Add-Result -Id 'O-1' -Label 'installed_plugins.json schema' -Status 'FAIL' -Detail "unexpected-schema: root is not an object"
        return
    }
    $pluginsProp = @($json.PSObject.Properties | Where-Object { $_.Name -ceq 'plugins' })
    if ($pluginsProp.Count -eq 0) {
        Add-Result -Id 'O-1' -Label 'installed_plugins.json schema' -Status 'FAIL' -Detail "unexpected-schema: missing 'plugins' field (case-sensitive)"
        return
    }
    $pluginsNode = $pluginsProp[0].Value
    if ($null -eq $pluginsNode -or $pluginsNode -is [Array] -or -not ($pluginsNode -is [psobject])) {
        Add-Result -Id 'O-1' -Label 'installed_plugins.json schema' -Status 'FAIL' -Detail "unexpected-schema: 'plugins' must be a JSON object (got null, Array, or scalar)"
        return
    }

    # Per §4.1.2: generic enumerate keys, scope=='user' filter, dual match.
    $allKeys = @($pluginsNode.PSObject.Properties.Name)

    foreach ($orig in $OriginalPlugins) {
        # Case-sensitive match per spec (§4.1.2): <name> / <name>@*
        $matchingKeys = @($allKeys | Where-Object {
            $_ -ceq $orig -or $_ -clike "$orig@*"
        })

        if ($matchingKeys.Count -eq 0) {
            Add-Result -Id 'O-1' -Label $orig -Status 'PASS' -Detail 'not installed'
            continue
        }

        # For each matching key, validate entry shape and check scope=='user'
        $foundUserScope = $false
        $failedSchema = $null

        foreach ($key in $matchingKeys) {
            $entries = $pluginsNode.$key

            # Row: matching-key entries value not Array → FAIL (v5 H-1)
            if (-not ($entries -is [Array])) {
                $failedSchema = "key '$key' entries value is not Array"
                break
            }

            # Row: Array internal element malformed → FAIL (v6 H-1).
            # Use case-sensitive property lookup and value compare: a drifted
            # 'Scope: User' entry must be detected as schema drift, not
            # silently accepted as valid user scope.
            foreach ($entry in $entries) {
                if ($null -eq $entry) {
                    $failedSchema = "key '$key' has null entry element"
                    break
                }
                if (-not ($entry -is [psobject])) {
                    $failedSchema = "key '$key' entry is not an object"
                    break
                }
                $scopeProp = @($entry.PSObject.Properties | Where-Object { $_.Name -ceq 'scope' })
                if ($scopeProp.Count -eq 0) {
                    $failedSchema = "key '$key' entry missing 'scope' field (case-sensitive)"
                    break
                }
                $scope = $scopeProp[0].Value
                if ($null -eq $scope -or ($scope -isnot [string])) {
                    $failedSchema = "key '$key' entry 'scope' is not string"
                    break
                }
                if ($scope -ceq 'user') {
                    $foundUserScope = $true
                }
            }
            if ($null -ne $failedSchema) { break }
        }

        if ($null -ne $failedSchema) {
            Add-Result -Id 'O-1' -Label $orig -Status 'FAIL' -Detail ("schema-drift: " + $failedSchema)
            continue
        }

        if ($foundUserScope) {
            Add-Result -Id 'O-1' -Label $orig -Status 'WARN' -Detail ("user-scope installed: " + ($matchingKeys -join ', '))
        } else {
            Add-Result -Id 'O-1' -Label $orig -Status 'PASS' -Detail ("keys present but no user-scope entry: " + ($matchingKeys -join ', '))
        }
    }
}

# ---------- O-2 ----------
function Get-IncorporatedSkillNames {
    # Union: (a) plugins/*/skills/<dir>/ directory names
    #        (b) SKILL.md frontmatter 'name:' values
    $set = @{}

    $pluginsRoot = Join-Path $RepoRoot 'plugins'
    if (-not (Test-Path -LiteralPath $pluginsRoot -PathType Container)) {
        return @()
    }

    $skillDirs = @()
    foreach ($pack in (Get-ChildItem -Path $pluginsRoot -Directory -ErrorAction SilentlyContinue)) {
        $packSkillsDir = Join-Path $pack.FullName 'skills'
        if (Test-Path -LiteralPath $packSkillsDir -PathType Container) {
            $skillDirs += @(Get-ChildItem -Path $packSkillsDir -Directory -ErrorAction SilentlyContinue)
        }
    }

    foreach ($dir in $skillDirs) {
        if (-not $set.ContainsKey($dir.Name)) { $set[$dir.Name] = $true }

        $skillMd = Join-Path $dir.FullName 'SKILL.md'
        if (Test-Path -LiteralPath $skillMd -PathType Leaf) {
            try {
                $lines = Get-Content -LiteralPath $skillMd -Encoding UTF8 -ErrorAction Stop
            } catch { continue }
            # Parse first YAML frontmatter block (between leading --- and next ---)
            if ($lines.Count -lt 1 -or $lines[0].Trim() -ne '---') { continue }
            for ($i = 1; $i -lt $lines.Count; $i++) {
                if ($lines[$i].Trim() -eq '---') { break }
                # Match `name: <value>` with optional inline YAML comment stripped.
                # Quoted values preserved before comment stripping.
                $m = [regex]::Match($lines[$i], '^\s*name:\s*(?<v>.+?)\s*(?:#.*)?$')
                if ($m.Success) {
                    $val = $m.Groups['v'].Value.Trim()
                    # Strip matching outer quotes if present.
                    if ($val.Length -ge 2 -and (($val.StartsWith('"') -and $val.EndsWith('"')) -or ($val.StartsWith("'") -and $val.EndsWith("'")))) {
                        $val = $val.Substring(1, $val.Length - 2)
                    }
                    if ($val -ne '' -and -not $set.ContainsKey($val)) { $set[$val] = $true }
                }
            }
        }
    }
    return @($set.Keys | Sort-Object)
}

function Test-OrphanSkills {
    $claudeDir = Get-HomeClaudeDir
    $skillsDir = Join-Path $claudeDir 'skills'

    if (-not (Test-Path -LiteralPath $skillsDir -PathType Container)) {
        Add-Result -Id 'O-2' -Label '~/.claude/skills/' -Status 'PASS' -Detail 'directory not found (no orphans possible)'
        return
    }

    $incorporated = @(Get-IncorporatedSkillNames)
    if ($incorporated.Count -eq 0) {
        Add-Result -Id 'O-2' -Label '~/.claude/skills/' -Status 'INFO' -Detail 'no incorporated skills found in plugins/*/skills/'
        return
    }

    $userSkillDirs = @(Get-ChildItem -Path $skillsDir -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name)
    $overlaps = @($userSkillDirs | Where-Object { $incorporated -contains $_ })

    if ($overlaps.Count -eq 0) {
        Add-Result -Id 'O-2' -Label '~/.claude/skills/' -Status 'PASS' -Detail ("no overlap with {0} incorporated skill names" -f $incorporated.Count)
    } else {
        Add-Result -Id 'O-2' -Label '~/.claude/skills/' -Status 'WARN' -Detail ("overlap: " + ($overlaps -join ', '))
    }
}

# ---------- O-3 ----------
function Test-KnownMarketplaces {
    $claudeDir = Get-HomeClaudeDir
    $knownJson = Join-Path $claudeDir 'plugins/known_marketplaces.json'

    # Spec §4.1.2 names these with the 'anthropics/' prefix — match against
    # the entry's .source.repo field (not the top-level key) for spec fidelity.
    $check = @('anthropics/claude-plugins-official', 'anthropics/claude-plugins-public')

    if (-not (Test-Path -LiteralPath $knownJson -PathType Leaf)) {
        foreach ($m in $check) {
            Add-Result -Id 'O-3' -Label $m -Status 'INFO' -Detail 'known_marketplaces.json not found'
        }
        return
    }

    $json = $null
    try {
        $raw = Get-Content -LiteralPath $knownJson -Raw -Encoding UTF8 -ErrorAction Stop
        $json = $raw | ConvertFrom-Json -ErrorAction Stop
    } catch {
        foreach ($m in $check) {
            Add-Result -Id 'O-3' -Label $m -Status 'INFO' -Detail ("parse error: " + $_.Exception.Message)
        }
        return
    }

    # Collect .source.repo values across all top-level marketplace entries
    $repos = @{}
    if ($null -ne $json -and ($json -is [psobject]) -and -not ($json -is [Array])) {
        foreach ($prop in $json.PSObject.Properties) {
            $entry = $prop.Value
            if ($null -eq $entry -or -not ($entry -is [psobject])) { continue }
            $sourceProp = @($entry.PSObject.Properties | Where-Object { $_.Name -ceq 'source' })
            if ($sourceProp.Count -eq 0) { continue }
            $src = $sourceProp[0].Value
            if ($null -eq $src -or -not ($src -is [psobject])) { continue }
            $repoProp = @($src.PSObject.Properties | Where-Object { $_.Name -ceq 'repo' })
            if ($repoProp.Count -eq 0) { continue }
            $repoVal = $repoProp[0].Value
            if ($repoVal -is [string] -and $repoVal -ne '') {
                if (-not $repos.ContainsKey($repoVal)) { $repos[$repoVal] = $prop.Name }
            }
        }
    }

    foreach ($m in $check) {
        if ($repos.ContainsKey($m)) {
            Add-Result -Id 'O-3' -Label $m -Status 'INFO' -Detail ("registered as '" + $repos[$m] + "'")
        } else {
            Add-Result -Id 'O-3' -Label $m -Status 'INFO' -Detail 'not registered'
        }
    }
}

# ---------- main ----------
Write-Host 'rwang-workbench check-orphan-originals v1.0'
Write-Host '========================================'

Test-InstalledOriginals
Test-OrphanSkills
Test-KnownMarketplaces

foreach ($r in $script:Results) {
    $label = ("[{0}] {1}" -f $r.Id, $r.Label).PadRight(46)
    $line = "{0} ... {1}" -f $label, $r.Status
    if ($r.Detail -ne '') { $line = "{0}  ({1})" -f $line, $r.Detail }
    Write-Host $line
}

Write-Host '========================================'
Write-Host ("Result: {0} PASS, {1} WARN, {2} FAIL, {3} INFO" -f $script:PassCount, $script:WarnCount, $script:FailCount, $script:InfoCount)

# Exit code rules per phase7-plan §4.1.3:
#   0 = clean (0 WARN, 0 FAIL)
#   2 = WARN >= 1, FAIL == 0
#   1 = FAIL >= 1
if ($script:FailCount -gt 0) { exit 1 }
elseif ($script:WarnCount -gt 0) { exit 2 }
else { exit 0 }
