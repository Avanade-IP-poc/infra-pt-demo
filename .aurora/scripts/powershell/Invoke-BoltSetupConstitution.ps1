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

    # Extract scope name and description
    $scopeName = if ($content -match 'scope:\s*(.+)') { $matches[1].Trim() } else { $null }
    $description = if ($content -match 'description:\s*(.+)') { $matches[1].Trim() } else { '' }

    # Extract enabled items (enabled: true, not auto_provision)
    $enabledItems = @()
    $lines = $content -split "`n"
    $inItem = $false
    $currentItem = @{}

    foreach ($line in $lines) {
        # New item starts with  - id:
        if ($line -match '^\s*-\s*id:\s*(.+)') {
            # Save previous item if it was enabled
            if ($currentItem.Count -gt 0 -and $currentItem.enabled -eq 'true') {
                $enabledItems += $currentItem
            }
            # Start new item
            $currentItem = @{ id = $matches[1].Trim() }
            $inItem = $true
        }
        elseif ($inItem) {
            # Extract item properties
            if ($line -match '^\s*kind:\s*(.+)') { $currentItem.kind = $matches[1].Trim() }
            if ($line -match '^\s*enabled:\s*(true|false)') { $currentItem.enabled = $matches[1].Trim() }
            if ($line -match '^\s*tags:\s*\[(.+)\]') { 
                $currentItem.tags = $matches[1].Trim() -split ',' | ForEach-Object { $_.Trim().Trim("'") }
            }
            
            # Source section
            if ($line -match '^\s*type:\s*(.+)') { $currentItem.source_type = $matches[1].Trim() }
            if ($line -match '^\s*path:\s*(.+)') { $currentItem.source_path = $matches[1].Trim() }
            
            # Destination section
            if ($line -match '^\s*folder:\s*(.+)') { $currentItem.dest_folder = $matches[1].Trim() }
            if ($line -match '^\s*name:\s*(.+)') { $currentItem.dest_name = $matches[1].Trim() }
            
            # Detect start of next section (end of current item)
            if ($line -match '^\s*-\s*id:') {
                $inItem = $false
            }
        }
    }

    # Add last item if it was enabled
    if ($currentItem.Count -gt 0 -and $currentItem.enabled -eq 'true') {
        $enabledItems += $currentItem
    }

    return @{
        scope = $scopeName
        description = $description
        enabled_items = $enabledItems
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
    $mergedScopes = @()
    $constitutionSections = @($baseConstitution.TrimEnd())

    # Append each scope's constitution
    foreach ($scope in $Scopes) {
        $scopeConstitutionPath = Join-Path $ProjectPath ".aurora\scopes\$scope\memory\constitution.md"

        if (Test-Path $scopeConstitutionPath) {
            Write-Info "Appending constitution from scope: $scope"

            $scopeConstitution = Get-Content $scopeConstitutionPath -Raw

            # Only append if constitution has content
            if ($scopeConstitution -and $scopeConstitution.Trim()) {
                # Add section marker and scope constitution
                $sectionMarker = @"

<!-- ============================================================ -->
<!-- Constitution Articles from Scope: $scope                     -->
<!-- ============================================================ -->

"@
                $constitutionSections += $sectionMarker
                $constitutionSections += $scopeConstitution.Trim()
                $mergedScopes += $scope
            }
            else {
                Write-Warn "Scope constitution is empty: $scope (skipping)"
            }
        }
        else {
            Write-Info "Scope has no constitution: $scope (skipping)"
        }
    }

    # Assemble final constitution with proper line endings
    $mergedConstitution = $constitutionSections -join "`n`n"

    if (-not $DryRun) {
        # Backup original only if not already backed up
        $backupPath = Join-Path $ProjectPath ".aurora\memory\constitution.original.md"
        if (-not (Test-Path $backupPath)) {
            Copy-Item $constitutionPath $backupPath -Force
            Write-Info "Backed up original to: constitution.original.md"
        }

        Set-Content -Path $constitutionPath -Value $mergedConstitution -Encoding UTF8 -NoNewline
        Write-Success "Constitution updated: appended $($mergedScopes.Count) scope articles"
    }
    else {
        Write-Info "[DRY RUN] Would append $($mergedScopes.Count) scope constitutions"
    }

    return @{
        scopes = $mergedScopes
        count = $mergedScopes.Count
    }
}

# ─── Step 3: Provision Files by Scope ────────────────────────────────────────

function Copy-ProvisionedFiles {
    param(
        [string]$ProjectPath,
        [array]$Scopes
    )

    Write-Step "Step 3: Provisioning Files by Scope"

    # Track provisioned items by kind
    $provisionedItems = @{
        prompts = @()
        instructions = @()
        skills = @()
        templates = @()
        agents = @()
    }
    $skippedFiles = @()

    foreach ($scope in $Scopes) {
        $scopeYamlPath = Join-Path $ProjectPath ".aurora\scopes\$scope\scope.yaml"

        if (-not (Test-Path $scopeYamlPath)) {
            Write-Warn "Scope manifest not found: $scope (skipping provisioning)"
            continue
        }

        $scopeConfig = Read-ScopeYaml -FilePath $scopeYamlPath

        if (-not $scopeConfig.enabled_items -or $scopeConfig.enabled_items.Count -eq 0) {
            Write-Info "No enabled items in scope: $scope"
            continue
        }

        Write-Info "Processing scope: $scope ($($scopeConfig.enabled_items.Count) items enabled)"

        foreach ($item in $scopeConfig.enabled_items) {
            # Build source path based on source type
            if ($item.source_type -eq 'local_file' -and $item.source_path) {
                $sourcePath = Join-Path $ProjectPath ".aurora\$($item.source_path)"
            }
            else {
                # For context7, awesome_copilot, etc. - source would be fetched from external
                # For now, assume local_file is primary source type
                Write-Warn "Non-local source type: $($item.source_type) for item $($item.id) (skipping)"
                continue
            }

            $destPath = Join-Path $ProjectPath "$($item.dest_folder)\$($item.dest_name)"

            if (-not (Test-Path $sourcePath)) {
                Write-Warn "Source not found: $($item.source_path) (skipping $($item.id))"
                continue
            }

            # Check if destination exists
            if ((Test-Path $destPath) -and -not $Force) {
                Write-Warn "Already exists: $destPath (use -Force to overwrite)"
                $skippedFiles += $destPath
                
                # Still track as available (preserved from Init.ps1 or previous run)
                $itemLabel = "$($item.dest_name) (from $scope, preserved)"
                switch ($item.kind) {
                    'prompts' { $provisionedItems.prompts += $itemLabel }
                    'instructions' { $provisionedItems.instructions += $itemLabel }
                    'skills' { $provisionedItems.skills += $itemLabel }
                    'templates' { $provisionedItems.templates += $itemLabel }
                    'agents' { $provisionedItems.agents += $itemLabel }
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

                Write-Success "$($item.kind): $($item.dest_name) (from $scope)"

                # Track provisioned items
                $itemLabel = "$($item.dest_name) (from $scope)"
                switch ($item.kind) {
                    'prompts' { $provisionedItems.prompts += $itemLabel }
                    'instructions' { $provisionedItems.instructions += $itemLabel }
                    'skills' { $provisionedItems.skills += $itemLabel }
                    'templates' { $provisionedItems.templates += $itemLabel }
                    'agents' { $provisionedItems.agents += $itemLabel }
                }
            }
            else {
                Write-Info "[DRY RUN] Would provision: $($item.dest_name) ($($item.kind)) from $scope"
                
                # Track dry-run items
                $itemLabel = "$($item.dest_name) (from $scope, dry-run)"
                switch ($item.kind) {
                    'prompts' { $provisionedItems.prompts += $itemLabel }
                    'instructions' { $provisionedItems.instructions += $itemLabel }
                    'skills' { $provisionedItems.skills += $itemLabel }
                    'templates' { $provisionedItems.templates += $itemLabel }
                    'agents' { $provisionedItems.agents += $itemLabel }
                }
            }
        }
    }

    return @{
        prompts = $provisionedItems.prompts
        instructions = $provisionedItems.instructions
        skills = $provisionedItems.skills
        templates = $provisionedItems.templates
        agents = $provisionedItems.agents
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

    # Build scope constitutions section
    $scopeConstitutions = if ($Constitution.scopes.Count -gt 0) {
        $Constitution.scopes | ForEach-Object { "- **$_** - Constitution appended from scope" } | Out-String
    } else {
        "No scope-specific constitutions found (using base constitution only)"
    }

    # Build core skills section
    $coreSkillsList = $CoreSkills | ForEach-Object { "- **$_**" } | Out-String

    # Build scope items sections
    $promptsList = if ($ScopeFiles.prompts.Count -gt 0) {
        $ScopeFiles.prompts | ForEach-Object { "- $_" } | Out-String
    } else { "_No prompts provisioned_" }

    $instructionsList = if ($ScopeFiles.instructions.Count -gt 0) {
        $ScopeFiles.instructions | ForEach-Object { "- $_" } | Out-String
    } else { "_No instructions provisioned_" }

    $scopeSkillsList = if ($ScopeFiles.skills.Count -gt 0) {
        $ScopeFiles.skills | ForEach-Object { "- $_" } | Out-String
    } else { "_No scope-specific skills provisioned_" }

    $templatesList = if ($ScopeFiles.templates.Count -gt 0) {
        $ScopeFiles.templates | ForEach-Object { "- $_" } | Out-String
    } else { "_No templates provisioned_" }

    $agentsList = if ($ScopeFiles.agents.Count -gt 0) {
        $ScopeFiles.agents | ForEach-Object { "- $_" } | Out-String
    } else { "_No agents provisioned_" }

    $skippedList = if ($ScopeFiles.skipped.Count -gt 0) {
        "⚠ **Skipped** (already exist):`n`n" + ($ScopeFiles.skipped | ForEach-Object { "- $_" } | Out-String)
    } else { "_No files skipped_" }

    $report = @"
# Bolt Setup Constitution - Provision Report

**Generated**: $timestamp
**Practice**: $($Scopes.practice)
**Active Scopes**: $($Scopes.active -join ', ')
**Transversal**: $($Scopes.transversal -join ', ')

---

## Constitution

✓ Base constitution created by Init.ps1
✓ Appended **$($Constitution.count)** scope-specific constitutions

### Scope Constitutions Appended

$scopeConstitutions

📄 **Location**: `.aurora/memory/constitution.md`
📄 **Backup**: `.aurora/memory/constitution.original.md` (original from Init.ps1)

---

## Files Provisioned

### Core Skills (ALWAYS included)

$coreSkillsList

📂 **Location**: `.github/skills/`

### Prompts

$promptsList

📂 **Location**: `.github/prompts/`

### Instructions

$instructionsList

📂 **Location**: `.github/instructions/`

### Scope-Specific Skills

$scopeSkillsList

📂 **Location**: `.github/skills/`

### Templates

$templatesList

📂 **Location**: Various (per scope definition)

### Agents

$agentsList

📂 **Location**: `.github/agents/`

---

## Summary

$skippedList

---

## Statistics

| Category | Count |
|----------|-------|
| Constitution Articles | $($Constitution.count) |
| Core Skills | $($CoreSkills.Count) |
| Prompts | $($ScopeFiles.prompts.Count) |
| Instructions | $($ScopeFiles.instructions.Count) |
| Scope Skills | $($ScopeFiles.skills.Count) |
| Templates | $($ScopeFiles.templates.Count) |
| Agents | $($ScopeFiles.agents.Count) |
| **Total Items** | **$($CoreSkills.Count + $ScopeFiles.prompts.Count + $ScopeFiles.instructions.Count + $ScopeFiles.skills.Count + $ScopeFiles.templates.Count + $ScopeFiles.agents.Count)** |
| Files Skipped | $($ScopeFiles.skipped.Count) |

---

## Next Steps

1. **Review Constitution**: Open `.aurora/memory/constitution.md` to see your complete project constitution
2. **Explore Skills**: Browse `.github/skills/` to see available Copilot skills
3. **Check Prompts**: Review `.github/prompts/` for reusable prompt templates
4. **Start Development**: Use **@Bolt Framework** to begin the AI-DLC workflow

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
        Write-Success "Constitution: $($constitution.count) scope articles appended"
        Write-Success "Core skills: $($coreSkills.Count)"
        Write-Success "Prompts: $($scopeFiles.prompts.Count)"
        Write-Success "Instructions: $($scopeFiles.instructions.Count)"
        Write-Success "Scope skills: $($scopeFiles.skills.Count)"
        Write-Success "Templates: $($scopeFiles.templates.Count)"
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
