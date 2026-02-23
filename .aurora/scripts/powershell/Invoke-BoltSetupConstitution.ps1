<#
.SYNOPSIS
    Bolt Framework - Setup Constitution (Step 2 of Two-Step Initialization)

.DESCRIPTION
    Completes Bolt Framework setup after Init.ps1 by:
    1. Loading active scopes from scopes.yaml
    2. Merging scope-specific constitution articles
    3. Provisioning files (skills, agents) based on scope manifests
    4. Provisioning core skills (always included)
    5. Generating provision report

    This is Step 2 of the two-step initialization:
    - Step 1 (Init.ps1): Select Practice → Generate basic config
    - Step 2 (THIS SCRIPT): Provision files → Merge constitutions → Report

.PARAMETER ProjectPath
    Path to the initialized project directory (contains .aurora/)

.PARAMETER Force
    Overwrite existing files during provisioning

.PARAMETER DryRun
    Preview changes without writing files

.EXAMPLE
    .\Invoke-BoltSetupConstitution.ps1 -ProjectPath ./my-project

.EXAMPLE
    .\Invoke-BoltSetupConstitution.ps1 -ProjectPath ./my-project -DryRun
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = ".",

    [switch]$Force,
    [switch]$DryRun
)

# ─── Logging Functions ───────────────────────────────────────────────────────

function Write-Info { Write-Host "  ℹ $args" -ForegroundColor Blue }
function Write-Success { Write-Host "  ✓ $args" -ForegroundColor Green }
function Write-Warn { Write-Host "  ⚠ $args" -ForegroundColor Yellow }
function Write-Err { Write-Host "  ✗ $args" -ForegroundColor Red }
function Write-Step { param($msg) Write-Host "`n[$msg]" -ForegroundColor Cyan }

# ─── YAML Parser ──────────────────────────────────────────────────────────────

function Read-Yaml {
    param([string]$FilePath)

    if (-not (Test-Path $FilePath)) {
        Write-Err "File not found: $FilePath"
        return $null
    }

    # Simple YAML parsing for our use case (PowerShell 5.1 compatible)
    # For complex YAML, consider PowerShell-Yaml module
    $content = Get-Content $FilePath -Raw
    $yaml = @{}

    # Extract project section
    if ($content -match 'project:\s+practice:\s*(.+?)\s+type:\s*(.+?)\s+migration-type:\s*(.+?)[\r\n]') {
        $yaml.project = @{
            practice = $matches[1].Trim()
            type = $matches[2].Trim()
            'migration-type' = $matches[3].Trim()
        }
    }

    # Extract active scopes
    $scopes = @()
    if ($content -match 'active-scopes:([\s\S]+?)(?:transversal-scopes:|decisions:)') {
        $scopesBlock = $matches[1]
        $scopes = $scopesBlock -split "`n" | Where-Object { $_ -match '^\s*-\s*(.+)' } | ForEach-Object { $matches[1].Trim() }
    }
    $yaml.'active-scopes' = $scopes

    # Extract transversal scopes
    $transversal = @()
    if ($content -match 'transversal-scopes:([\s\S]+?)(?:decisions:|$)') {
        $transversal = $matches[1] -split "`n" | Where-Object { $_ -match '^\s*-\s*(.+)' } | ForEach-Object { $matches[1].Trim() }
    }
    $yaml.'transversal-scopes' = $transversal

    return $yaml
}

function Read-ScopeYaml {
    param([string]$FilePath)

    if (-not (Test-Path $FilePath)) {
        return $null
    }

    $content = Get-Content $FilePath -Raw

    # Extract scope name
    $scopeName = if ($content -match 'scope:\s*(.+)') { $matches[1].Trim() } else { $null }

    # Extract auto_provision items
    $autoProvisionItems = @()
    $lines = $content -split "`n"
    $inItem = $false
    $currentItem = @{}

    foreach ($line in $lines) {
        if ($line -match '^\s*-\s*id:\s*(.+)') {
            if ($currentItem.Count -gt 0 -and $currentItem.auto_provision -eq 'true') {
                $autoProvisionItems += $currentItem
            }
            $currentItem = @{ id = $matches[1].Trim() }
            $inItem = $true
        }
        elseif ($inItem) {
            if ($line -match '^\s*kind:\s*(.+)') { $currentItem.kind = $matches[1].Trim() }
            if ($line -match '^\s*auto_provision:\s*(true|false)') { $currentItem.auto_provision = $matches[1].Trim() }
            if ($line -match '^\s*path:\s*(.+)') { $currentItem.source_path = $matches[1].Trim() }
            if ($line -match '^\s*folder:\s*(.+)') { $currentItem.dest_folder = $matches[1].Trim() }
            if ($line -match '^\s*name:\s*(.+)') { $currentItem.dest_name = $matches[1].Trim() }
        }
    }

    # Add last item
    if ($currentItem.Count -gt 0 -and $currentItem.auto_provision -eq 'true') {
        $autoProvisionItems += $currentItem
    }

    return @{
        scope = $scopeName
        auto_provision_items = $autoProvisionItems
    }
}

# ─── Step 1: Load Active Scopes ──────────────────────────────────────────────

function Get-ActiveScopes {
    param([string]$ProjectPath)

    Write-Step "Step 1: Loading Active Scopes"

    $scopesYamlPath = Join-Path $ProjectPath ".aurora\scopes.yaml"

    if (-not (Test-Path $scopesYamlPath)) {
        Write-Err "Missing required file: .aurora/scopes.yaml"
        Write-Err "Action: Run Init.ps1 or init.sh first to initialize project"
        throw "Missing scopes.yaml"
    }

    $scopesConfig = Read-Yaml -FilePath $scopesYamlPath

    if (-not $scopesConfig -or -not $scopesConfig.'active-scopes') {
        Write-Err "Invalid scopes.yaml: missing active-scopes"
        throw "Invalid scopes.yaml"
    }

    $activeScopes = $scopesConfig.'active-scopes'
    $transversal = if ($scopesConfig.'transversal-scopes') { $scopesConfig.'transversal-scopes' } else { @('work-management') }
    $practice = if ($scopesConfig.project.practice) { $scopesConfig.project.practice } else { 'Custom' }

    Write-Success "Practice: $practice"
    Write-Success "Active scopes: $($activeScopes -join ', ')"
    Write-Success "Transversal: $($transversal -join ', ')"

    return @{
        active = $activeScopes
        transversal = $transversal
        practice = $practice
        all = $activeScopes + $transversal
    }
}

# ─── Step 2: Merge Constitution Articles ─────────────────────────────────────

function Merge-ConstitutionArticles {
    param(
        [string]$ProjectPath,
        [array]$Scopes
    )

    Write-Step "Step 2: Merging Constitution Articles"

    $constitutionPath = Join-Path $ProjectPath ".aurora\memory\constitution.md"

    if (-not (Test-Path $constitutionPath)) {
        Write-Err "Missing: .aurora/memory/constitution.md"
        throw "Missing constitution.md"
    }

    # Read basic constitution (created by Init.ps1)
    $baseConstitution = Get-Content $constitutionPath -Raw

    # Track merged articles
    $mergedArticles = @()
    $constitutionSections = @($baseConstitution)

    # Merge each scope's constitution
    foreach ($scope in $Scopes) {
        $scopeConstitutionPath = Join-Path $ProjectPath ".aurora\scopes\$scope\memory\constitution.md"

        if (Test-Path $scopeConstitutionPath) {
            Write-Info "Merging articles from scope: $scope"

            $scopeConstitution = Get-Content $scopeConstitutionPath -Raw

            # Extract article sections (simplified - assumes articles are separated by # headers)
            $articles = $scopeConstitution -split '(?m)^# Article' | Where-Object { $_ -match '\w' }

            foreach ($article in $articles) {
                if ($article -match '^# Article (.+)') {
                    $articleId = $matches[1] -replace '\s.*', ''  # Extract article number
                    if ($articleId) {
                        $mergedArticles += "$articleId (from $scope)"
                        $constitutionSections += "`n`n# Article$article"
                    }
                }
                elseif ($article.Trim()) {
                    $constitutionSections += "`n`n$article"
                }
            }
        }
        else {
            Write-Warn "Scope constitution not found: $scope (skipping)"
        }
    }

    # Write merged constitution
    $mergedConstitution = $constitutionSections -join ""

    if (-not $DryRun) {
        # Backup original
        $backupPath = Join-Path $ProjectPath ".aurora\memory\constitution.original.md"
        if (-not (Test-Path $backupPath)) {
            Copy-Item $constitutionPath $backupPath -Force
            Write-Info "Backed up original to: constitution.original.md"
        }

        Set-Content -Path $constitutionPath -Value $mergedConstitution -Encoding UTF8
        Write-Success "Constitution merged: $($mergedArticles.Count) articles"
    }
    else {
        Write-Info "[DRY RUN] Would merge $($mergedArticles.Count) articles"
    }

    return @{
        articles = $mergedArticles
        count = $mergedArticles.Count
    }
}

# ─── Step 3: Provision Files by Scope ────────────────────────────────────────

function Copy-ProvisionedFiles {
    param(
        [string]$ProjectPath,
        [array]$Scopes
    )

    Write-Step "Step 3: Provisioning Files by Scope"

    $provisionedSkills = @()
    $provisionedAgents = @()
    $skippedFiles = @()

    foreach ($scope in $Scopes) {
        $scopeYamlPath = Join-Path $ProjectPath ".aurora\scopes\$scope\scope.yaml"

        if (-not (Test-Path $scopeYamlPath)) {
            Write-Warn "Scope manifest not found: $scope (skipping provisioning)"
            continue
        }

        $scopeConfig = Read-ScopeYaml -FilePath $scopeYamlPath

        if (-not $scopeConfig.auto_provision_items -or $scopeConfig.auto_provision_items.Count -eq 0) {
            Write-Info "No auto-provision items in scope: $scope"
            continue
        }

        Write-Info "Processing scope: $scope"

        foreach ($item in $scopeConfig.auto_provision_items) {
            $sourcePath = Join-Path $ProjectPath ".aurora\$($item.source_path)"
            $destPath = Join-Path $ProjectPath "$($item.dest_folder)\$($item.dest_name)"

            if (-not (Test-Path $sourcePath)) {
                Write-Warn "Source not found: $($item.source_path) (skipping $($item.id))"
                continue
            }

            # Check if destination exists
            if ((Test-Path $destPath) -and -not $Force) {
                Write-Warn "Already exists: $destPath (use -Force to overwrite)"
                $skippedFiles += $destPath
                # Still track as available (preserved from Init.ps1)
                if ($item.kind -eq 'skills') {
                    $provisionedSkills += "$($item.dest_name) (from $scope, preserved)"
                }
                elseif ($item.kind -eq 'agents') {
                    $provisionedAgents += "$($item.dest_name) (from $scope, preserved)"
                }
                continue
            }

            if (-not $DryRun) {
                # Create destination directory
                $destDir = Split-Path $destPath -Parent
                if (-not (Test-Path $destDir)) {
                    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
                }

                # Copy file or directory
                if (Test-Path $sourcePath -PathType Container) {
                    Copy-Item -Path $sourcePath -Destination $destPath -Recurse -Force
                }
                else {
                    Copy-Item -Path $sourcePath -Destination $destPath -Force
                }

                Write-Success "$($item.kind) provisioned: $($item.dest_name) (from $scope)"

                # Track provisioned items
                if ($item.kind -eq 'skills') {
                    $provisionedSkills += "$($item.dest_name) (from $scope)"
                }
                elseif ($item.kind -eq 'agents') {
                    $provisionedAgents += "$($item.dest_name) (from $scope)"
                }
            }
            else {
                Write-Info "[DRY RUN] Would provision: $($item.dest_name) from $scope"
                # Track dry-run items
                if ($item.kind -eq 'skills') {
                    $provisionedSkills += "$($item.dest_name) (from $scope, dry-run)"
                }
                elseif ($item.kind -eq 'agents') {
                    $provisionedAgents += "$($item.dest_name) (from $scope, dry-run)"
                }
            }
        }
    }

    return @{
        skills = $provisionedSkills
        agents = $provisionedAgents
        skipped = $skippedFiles
    }
}

# ─── Step 4: Provision Core Skills ───────────────────────────────────────────

function Copy-CoreSkills {
    param([string]$ProjectPath)

    Write-Step "Step 4: Provisioning Core Skills (ALWAYS included)"

    $provisionedCore = @()

    # Core skills split into two categories:
    # 1. Already in .github/skills (from Init.ps1 copy)
    $githubSkills = @('new-skill', 'markdown-formatting')
    # 2. From .aurora/available-skills/bolt-framework/
    $auroraSkills = @('bolt-framework', 'bolt-adr')

    # Check skills that came from .github (already provisioned by Init.ps1)
    foreach ($skillName in $githubSkills) {
        $destPath = Join-Path $ProjectPath ".github\skills\$skillName"

        if (Test-Path $destPath) {
            Write-Info "Core skill already exists: $skillName (from .github)"
            $provisionedCore += "$skillName (from .github)"
        }
        else {
            Write-Warn "Expected skill not found: $skillName (should be copied by Init.ps1)"
        }
    }

    # Provision skills from .aurora/available-skills
    foreach ($skillName in $auroraSkills) {
        $sourcePath = Join-Path $ProjectPath ".aurora\available-skills\bolt-framework\$skillName"
        $destPath = Join-Path $ProjectPath ".github\skills\$skillName"

        if (-not (Test-Path $sourcePath)) {
            Write-Warn "Core skill not found: $skillName (skipping)"
            continue
        }

        if ((Test-Path $destPath) -and -not $Force) {
            Write-Info "Core skill already exists: $skillName (preserving)"
            $provisionedCore += "$skillName (preserved)"
            continue
        }

        if (-not $DryRun) {
            # Create .github/skills directory if needed
            $skillsDir = Join-Path $ProjectPath ".github\skills"
            if (-not (Test-Path $skillsDir)) {
                New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null
            }

            # Copy skill recursively
            Copy-Item -Path $sourcePath -Destination $destPath -Recurse -Force
            Write-Success "Core skill provisioned: $skillName"
            $provisionedCore += $skillName
        }
        else {
            Write-Info "[DRY RUN] Would provision core skill: $skillName"
            $provisionedCore += "$skillName (dry-run)"
        }
    }

    return $provisionedCore
}

# ─── Step 5: Generate Provision Report ───────────────────────────────────────

function New-ProvisionReport {
    param(
        [string]$ProjectPath,
        [hashtable]$Scopes,
        [hashtable]$Constitution,
        [hashtable]$ScopeFiles,
        [array]$CoreSkills
    )

    Write-Step "Step 5: Generating Provision Report"

    $reportPath = Join-Path $ProjectPath ".aurora\memory\provision-report.md"
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

    $report = @"
# Bolt Setup Constitution - Provision Report

**Date**: $timestamp
**Practice**: $($Scopes.practice)
**Scopes**: $($Scopes.active -join ', ')
**Transversal**: $($Scopes.transversal -join ', ')

## Constitution Merge

✓ Merged $($Constitution.count) articles from $($Scopes.all.Count) scopes

### Articles by Scope

$($Constitution.articles | ForEach-Object { "- $_" } | Out-String)

## Files Provisioned

### Core Skills (ALWAYS provisioned)

$($CoreSkills | ForEach-Object { "- **$_** (methodology + examples + templates)" } | Out-String)

### Scope-Specific Skills

$($ScopeFiles.skills | ForEach-Object { "- $_" } | Out-String)

### Agents

$($ScopeFiles.agents | ForEach-Object { "- $_" } | Out-String)

## Warnings

$(if ($ScopeFiles.skipped.Count -gt 0) {
    "⚠ Skipped (already exist):`n`n" + ($ScopeFiles.skipped | ForEach-Object { "- $_" } | Out-String)
} else {
    "No files skipped."
})

## Summary Statistics

- **Constitution Articles Merged**: $($Constitution.count)
- **Core Skills Provisioned**: $($CoreSkills.Count)
- **Scope Skills Provisioned**: $($ScopeFiles.skills.Count)
- **Agents Provisioned**: $($ScopeFiles.agents.Count)
- **Files Skipped**: $($ScopeFiles.skipped.Count)
- **Errors**: 0

## Next Steps

1. Review constitution: ``.aurora/memory/constitution.md``
2. Verify skills: ``.github/skills/``
3. Verify agents: ``.github/agents/``
4. Start development: Invoke ``@Bolt Framework``

---

_Generated by Bolt Setup Constitution v2.0.0_
"@

    if (-not $DryRun) {
        Set-Content -Path $reportPath -Value $report -Encoding UTF8
        Write-Success "Provision report created: provision-report.md"
    }
    else {
        Write-Info "[DRY RUN] Would create provision report"
    }

    return $reportPath
}

# ─── Main Workflow ────────────────────────────────────────────────────────────

function Main {
    Write-Host ""
    Write-Host "  ┌──────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
    Write-Host "  │   Bolt Framework - Setup Constitution (Phase 2/2)           │" -ForegroundColor Cyan
    Write-Host "  └──────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
    Write-Host ""

    if ($DryRun) {
        Write-Warn "DRY RUN MODE - No files will be modified"
        Write-Host ""
    }

    try {
        # Resolve project path
        $resolvedPath = Resolve-Path $ProjectPath -ErrorAction Stop
        Write-Info "Project: $resolvedPath"
        Write-Host ""

        # Step 1: Load active scopes
        $scopes = Get-ActiveScopes -ProjectPath $resolvedPath

        # Step 2: Merge constitutions
        $constitution = Merge-ConstitutionArticles -ProjectPath $resolvedPath -Scopes $scopes.all

        # Step 3: Provision scope-specific files
        $scopeFiles = Copy-ProvisionedFiles -ProjectPath $resolvedPath -Scopes $scopes.all

        # Step 4: Provision core skills
        $coreSkills = Copy-CoreSkills -ProjectPath $resolvedPath

        # Step 5: Generate provision report
        $reportPath = New-ProvisionReport `
            -ProjectPath $resolvedPath `
            -Scopes $scopes `
            -Constitution $constitution `
            -ScopeFiles $scopeFiles `
            -CoreSkills $coreSkills

        # Summary
        Write-Host ""
        Write-Host "  ┌──────────────────────────────────────────────────────────────┐" -ForegroundColor Green
        Write-Host "  │   Bolt Framework Setup Complete!                             │" -ForegroundColor Green
        Write-Host "  └──────────────────────────────────────────────────────────────┘" -ForegroundColor Green
        Write-Host ""
        Write-Success "Constitution merged: $($constitution.count) articles"
        Write-Success "Core skills: $($coreSkills.Count)"
        Write-Success "Scope skills: $($scopeFiles.skills.Count)"
        Write-Success "Agents: $($scopeFiles.agents.Count)"
        Write-Host ""
        Write-Info "Review provision report: .aurora/memory/provision-report.md"
        Write-Info "Start development: @Bolt Framework"
        Write-Host ""
    }
    catch {
        Write-Host ""
        Write-Err "Setup failed: $_"
        Write-Host ""
        exit 1
    }
}

Main
