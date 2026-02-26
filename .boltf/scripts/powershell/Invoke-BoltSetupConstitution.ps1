<#
.SYNOPSIS
    Bolt Framework - Setup Constitution (Step 2 of Two-Step Initialization)

.DESCRIPTION
    Completes Bolt Framework setup after Init.ps1 with a four-phase approach:

    Phase 1: Generate constitution.master.md (complete merge)
    Phase 2: Interactive refinement (handled by agent)
    Phase 3: Generate constitution.md (refined summary)
    Phase 4: Provision resources (skills, agents, prompts, etc.)

    This is Step 2 of the two-step initialization:
    - Step 1 (Init.ps1): Select Practice → Generate basic config
    - Step 2 (THIS SCRIPT): Four-phase constitution and provisioning

.PARAMETER ProjectPath
    Path to the initialized project directory (contains .boltf/)

.PARAMETER GenerateMaster
    Phase 1: Generate constitution.master.md by merging all scope constitutions

.PARAMETER GenerateFinal
    Phase 3: Generate constitution.md (refined summary) from refinement ledger

.PARAMETER Refinements
    Hashtable of refinement decisions from Phase 2 (used with -GenerateFinal)

.PARAMETER Provision
    Phase 4: Provision resources based on scope.yaml manifests

.PARAMETER Force
    Overwrite existing files during provisioning

.PARAMETER DryRun
    Preview changes without writing files

.EXAMPLE
    # Phase 1: Generate master constitution
    .\Invoke-BoltSetupConstitution.ps1 -ProjectPath ./my-project -GenerateMaster

.EXAMPLE
    # Phase 3: Generate final constitution with refinements
    .\Invoke-BoltSetupConstitution.ps1 -ProjectPath ./my-project -GenerateFinal -Refinements $refinements

.EXAMPLE
    # Phase 4: Provision resources
    .\Invoke-BoltSetupConstitution.ps1 -ProjectPath ./my-project -Provision

.EXAMPLE
    # Dry run for any phase
    .\Invoke-BoltSetupConstitution.ps1 -ProjectPath ./my-project -GenerateMaster -DryRun
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = ".",

    [switch]$GenerateMaster,
    [switch]$GenerateFinal,
    [hashtable]$Refinements = @{},
    [switch]$Provision,

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
    if ($content -match 'project:\s+practice:\s*(.+?)\s+type:\s*(.+?)\s+migration-type:\s*(.+?)\s+use-aspire:\s*(true|false)[\r\n]') {
        $yaml.project = @{
            practice = $matches[1].Trim()
            type = $matches[2].Trim()
            'migration-type' = $matches[3].Trim()
            'use-aspire' = ($matches[4].Trim() -eq 'true')
        }
    }
    elseif ($content -match 'project:\s+practice:\s*(.+?)\s+type:\s*(.+?)\s+migration-type:\s*(.+?)[\r\n]') {
        # Fallback for older scopes.yaml without use-aspire field
        $yaml.project = @{
            practice = $matches[1].Trim()
            type = $matches[2].Trim()
            'migration-type' = $matches[3].Trim()
            'use-aspire' = $false
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

    $scopesYamlPath = Join-Path $ProjectPath ".boltf\scopes.yaml"

    if (-not (Test-Path $scopesYamlPath)) {
        Write-Err "Missing required file: .boltf/scopes.yaml"
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

    # ALWAYS include 'common' scope (universal skills)
    if ($activeScopes -notcontains 'common') {
        Write-Info "Adding 'common' scope (universal skills always included)"
        $activeScopes = @('common') + $activeScopes
    }

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

# ─── Phase 1: Generate constitution.master.md ───────────────────────────────

function New-MasterConstitution {
    param(
        [string]$ProjectPath,
        [array]$Scopes,
        [switch]$DryRun
    )

    Write-Step "Phase 1: Generating constitution.master.md"

    $constitutionPath = Join-Path $ProjectPath ".boltf\memory\constitution.md"
    $masterPath = Join-Path $ProjectPath ".boltf\memory\constitution.master.md"
    $originalBackupPath = Join-Path $ProjectPath ".boltf\memory\constitution.original.md"

    if (-not (Test-Path $constitutionPath)) {
        Write-Err "Missing: .boltf/memory/constitution.md"
        Write-Err "Action: Run Init.ps1 first to create base constitution"
        throw "Missing constitution.md"
    }

    # Backup original constitution (from Init.ps1)
    if (-not $DryRun -and -not (Test-Path $originalBackupPath)) {
        Write-Info "Backing up original constitution"
        Copy-Item $constitutionPath $originalBackupPath -Force
    }

    # Read base constitution (created by Init.ps1)
    $baseConstitution = Get-Content $constitutionPath -Raw

    # Track merged scopes
    $mergedScopes = @()
    $constitutionSections = @($baseConstitution.TrimEnd())

    # Append each scope's constitution
    foreach ($scope in $Scopes) {
        $scopeConstitutionPath = Join-Path $ProjectPath ".boltf\scopes\$scope\memory\constitution.md"

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

    # Assemble final master constitution
    $masterConstitution = $constitutionSections -join "`n`n"

    # Write master constitution
    if (-not $DryRun) {
        Set-Content -Path $masterPath -Value $masterConstitution -Encoding UTF8 -NoNewline
        Write-Success "Master constitution generated: $masterPath"
        Write-Success "Merged $($mergedScopes.Count) scope constitutions"
    }
    else {
        Write-Info "[DRY RUN] Would generate constitution.master.md"
        Write-Info "[DRY RUN] Would merge $($mergedScopes.Count) scopes"
    }

    return @{
        scopes = $mergedScopes
        count = $mergedScopes.Count
        size = $masterConstitution.Length
        path = $masterPath
    }
}

# ─── Phase 3: Generate constitution.md (Refined Summary) ───────────────────

function New-FinalConstitution {
    param(
        [string]$ProjectPath,
        [hashtable]$Refinements,
        [switch]$DryRun
    )

    Write-Step "Phase 3: Generating constitution.md (Refined Summary)"

    $masterPath = Join-Path $ProjectPath ".boltf\memory\constitution.master.md"
    $finalPath = Join-Path $ProjectPath ".boltf\memory\constitution.md"

    if (-not (Test-Path $masterPath)) {
        Write-Err "Missing: constitution.master.md"
        Write-Err "Action: Run with -GenerateMaster first"
        throw "Missing constitution.master.md"
    }

    # If no refinements provided, use master as-is
    if ($Refinements.Count -eq 0) {
        Write-Warn "No refinements provided - using master constitution as final"
        if (-not $DryRun) {
            Copy-Item $masterPath $finalPath -Force
            Write-Success "Final constitution copied from master"
        }
        return @{ refined = $false }
    }

    # TODO: Implement refinement logic
    # For now, we'll create a summary from master
    $masterContent = Get-Content $masterPath -Raw

    # Create refined summary version
    $finalConstitution = @"
# Project Constitution v1.0.0

_Generated from constitution.master.md with interactive refinements_

$(if ($Refinements.Count -gt 0) { "## Refinement Summary`n`n$($Refinements.Keys | ForEach-Object { "- **$($_)**: $($Refinements[$_])`n" })" })

---

$masterContent
"@

    if (-not $DryRun) {
        Set-Content -Path $finalPath -Value $finalConstitution -Encoding UTF8 -NoNewline
        Write-Success "Final constitution generated: $finalPath"
        Write-Success "Applied $($Refinements.Count) refinements"
    }
    else {
        Write-Info "[DRY RUN] Would generate constitution.md"
        Write-Info "[DRY RUN] Would apply $($Refinements.Count) refinements"
    }

    return @{
        refined = $true
        refinements = $Refinements.Count
        path = $finalPath
    }
}

# ─── Phase 4: Provision Resources ────────────────────────────────────────────

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
        $scopeYamlPath = Join-Path $ProjectPath ".boltf\scopes\$scope\scope.yaml"

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
            $destPath = Join-Path $ProjectPath "$($item.dest_folder)\$($item.dest_name)"
            $sourcePath = $null
            $sourceType = $item.source_type
            $requiresDownload = $false

            # Handle different source types
            switch ($sourceType) {
                'local_file' {
                    if ($item.source_path) {
                        $sourcePath = Join-Path $ProjectPath ".boltf\$($item.source_path)"
                    }
                }
                'context7' {
                    # Mark for download - agent will handle via MCP
                    $requiresDownload = $true
                    Write-Info "Item $($item.id) requires Context7 download (agent-handled)"
                }
                'awesome_copilot' {
                    # Mark for download - agent will handle via MCP
                    $requiresDownload = $true
                    Write-Info "Item $($item.id) requires Awesome Copilot download (agent-handled)"
                }
                default {
                    Write-Warn "Unknown source type: $sourceType for item $($item.id) (skipping)"
                    continue
                }
            }

            # Skip external sources in script - let agent handle them
            if ($requiresDownload) {
                Write-Info "External source: $($item.id) → Agent will download to $destPath"

                # Track as requiring agent action
                $itemLabel = "$($item.dest_name) (from $scope, requires download: $sourceType)"
                switch ($item.kind) {
                    'prompts' { $provisionedItems.prompts += $itemLabel }
                    'instructions' { $provisionedItems.instructions += $itemLabel }
                    'skills' { $provisionedItems.skills += $itemLabel }
                    'templates' { $provisionedItems.templates += $itemLabel }
                    'agents' { $provisionedItems.agents += $itemLabel }
                }
                continue
            }

            # Validate local source exists
            if ($sourcePath -and -not (Test-Path $sourcePath)) {
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
    # 2. From .boltf/available-skills/bolt-framework/ (ALL skills auto-discovered)
    $boltFrameworkPath = Join-Path $ProjectPath ".boltf\available-skills\bolt-framework"
    $auroraSkills = @()
    if (Test-Path $boltFrameworkPath) {
        $auroraSkills = Get-ChildItem -Path $boltFrameworkPath -Directory | Select-Object -ExpandProperty Name
        Write-Verbose "Auto-discovered $(($auroraSkills).Count) Bolt Framework skills: $($auroraSkills -join ', ')"
    } else {
        Write-Warn "Bolt Framework skills path not found: $boltFrameworkPath"
    }

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

    # Provision skills from .boltf/available-skills
    foreach ($skillName in $auroraSkills) {
        $sourcePath = Join-Path $ProjectPath ".boltf\available-skills\bolt-framework\$skillName"
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

# ─── Step 4.5: Provision Aspire Resources (Conditional) ──────────────────────

function Copy-AspireResources {
    param(
        [string]$ProjectPath,
        [bool]$UseAspire
    )

    if (-not $UseAspire) {
        Write-Info "Aspire not enabled — skipping Aspire resources"
        return @()
    }

    Write-Step "Step 4.5: Provisioning Aspire Resources (Conditional)"

    $provisionedAspire = @()

    # 1. Provision Aspire skill
    $skillName = "skill-bolt-aspire-orchestration"
    $skillSourcePath = Join-Path $ProjectPath ".boltf\available-skills\aspire\$skillName"
    $skillDestPath = Join-Path $ProjectPath ".github\skills\$skillName"

    if (Test-Path $skillSourcePath) {
        if ((Test-Path $skillDestPath) -and -not $Force) {
            Write-Info "Aspire skill already exists: $skillName (preserving)"
            $provisionedAspire += "$skillName (preserved)"
        }
        else {
            if (-not $DryRun) {
                Copy-Item -Path $skillSourcePath -Destination $skillDestPath -Recurse -Force
                Write-Success "Aspire skill provisioned: $skillName"
                $provisionedAspire += $skillName
            }
            else {
                Write-Info "[DRY RUN] Would provision Aspire skill: $skillName"
                $provisionedAspire += "$skillName (dry-run)"
            }
        }
    }
    else {
        Write-Warn "Aspire skill not found: $skillSourcePath (skipping)"
    }

    # 2. Provision Aspire templates
    $templates = @('AppHost.csproj', 'ServiceDefaults.csproj', 'Program.cs.template')
    $templatesSourcePath = Join-Path $ProjectPath ".boltf\templates\aspire"
    $templatesDestPath = Join-Path $ProjectPath ".github\templates\aspire"

    if (Test-Path $templatesSourcePath) {
        foreach ($template in $templates) {
            $templateSource = Join-Path $templatesSourcePath $template
            $templateDest = Join-Path $templatesDestPath $template

            if (-not (Test-Path $templateSource)) {
                Write-Warn "Aspire template not found: $template (skipping)"
                continue
            }

            if ((Test-Path $templateDest) -and -not $Force) {
                Write-Info "Aspire template already exists: $template (preserving)"
                $provisionedAspire += "Template: $template (preserved)"
            }
            else {
                if (-not $DryRun) {
                    # Create destination directory
                    if (-not (Test-Path $templatesDestPath)) {
                        New-Item -ItemType Directory -Path $templatesDestPath -Force | Out-Null
                    }

                    Copy-Item -Path $templateSource -Destination $templateDest -Force
                    Write-Success "Aspire template provisioned: $template"
                    $provisionedAspire += "Template: $template"
                }
                else {
                    Write-Info "[DRY RUN] Would provision Aspire template: $template"
                    $provisionedAspire += "Template: $template (dry-run)"
                }
            }
        }
    }
    else {
        Write-Warn "Aspire templates path not found: $templatesSourcePath (skipping templates)"
    }

    if ($provisionedAspire.Count -gt 0) {
        Write-Success "Aspire resources provisioned: $($provisionedAspire.Count) items"
    }
    else {
        Write-Warn "No Aspire resources were provisioned (check source paths)"
    }

    return $provisionedAspire
}

# ─── Step 5: Generate Provision Report ───────────────────────────────────────

function New-ProvisionReport {
    param(
        [string]$ProjectPath,
        [hashtable]$Scopes,
        [hashtable]$Constitution,
        [hashtable]$ScopeFiles,
        [array]$CoreSkills,
        [array]$AspireResources = @()
    )

    Write-Step "Step 5: Generating Provision Report"

    $reportPath = Join-Path $ProjectPath ".boltf\memory\provision-report.md"
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

    # Build scope constitutions section
    $scopeConstitutions = if ($Constitution.scopes.Count -gt 0) {
        $Constitution.scopes | ForEach-Object { "- **$_** - Constitution appended from scope" } | Out-String
    } else {
        "No scope-specific constitutions found (using base constitution only)"
    }

    # Build core skills section
    $coreSkillsList = $CoreSkills | ForEach-Object { "- **$_**" } | Out-String

    # Build Aspire resources section
    $aspireSection = ""
    if ($AspireResources.Count -gt 0) {
        $aspireList = $AspireResources | ForEach-Object { "- **$_**" } | Out-String
        $aspireSection = @"

### .NET Aspire Resources (Conditional)

$aspireList

✅ **Aspire Enabled**: Service orchestration with AppHost pattern
📂 **Skill Location**: `.github/skills/skill-bolt-aspire-orchestration/`
📂 **Templates Location**: `.github/templates/aspire/`
📖 **Documentation**: See Article XX in constitution.md

"@
    }

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

📄 **Location**: `.boltf/memory/constitution.md`
📄 **Backup**: `.boltf/memory/constitution.original.md` (original from Init.ps1)

---

## Files Provisioned

### Core Skills (ALWAYS included)

$coreSkillsList

📂 **Location**: `.github/skills/`
$aspireSection

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
| Aspire Resources | $($AspireResources.Count) |
| Prompts | $($ScopeFiles.prompts.Count) |
| Instructions | $($ScopeFiles.instructions.Count) |
| Scope Skills | $($ScopeFiles.skills.Count) |
| Templates | $($ScopeFiles.templates.Count) |
| Agents | $($ScopeFiles.agents.Count) |
| **Total Items** | **$($CoreSkills.Count + $AspireResources.Count + $ScopeFiles.prompts.Count + $ScopeFiles.instructions.Count + $ScopeFiles.skills.Count + $ScopeFiles.templates.Count + $ScopeFiles.agents.Count)** |
| Files Skipped | $($ScopeFiles.skipped.Count) |

---

## Next Steps

1. **Review Constitution**: Open `.boltf/memory/constitution.md` to see your complete project constitution
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
    Write-Host "  │   Bolt Framework - Setup Constitution (Step 2/2)            │" -ForegroundColor Cyan
    Write-Host "  └──────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
    Write-Host ""

    if ($DryRun) {
        Write-Warn "DRY RUN MODE - No files will be modified"
        Write-Host ""
    }

    # Resolve project path
    $resolvedPath = Resolve-Path $ProjectPath -ErrorAction Stop
    Write-Info "Project: $resolvedPath"
    Write-Host ""

    # Load active scopes (required for all phases)
    $scopes = Get-ActiveScopes -ProjectPath $resolvedPath

    try {
        # ─── Phase-based execution ──────────────────────────────────────────

        if ($GenerateMaster) {
            # Phase 1: Generate constitution.master.md
            Write-Host "  🔹 Phase 1: Generate Master Constitution" -ForegroundColor Magenta
            Write-Host ""

            $master = New-MasterConstitution -ProjectPath $resolvedPath -Scopes $scopes.all -DryRun:$DryRun

            Write-Host ""
            Write-Success "Phase 1 Complete"
            Write-Info "Master constitution: $($master.path)"
            Write-Info "Scopes merged: $($master.count)"
            Write-Info "Size: $([math]::Round($master.size / 1KB, 2)) KB"
            Write-Host ""
        }
        elseif ($GenerateFinal) {
            # Phase 3: Generate constitution.md (refined)
            Write-Host "  🔹 Phase 3: Generate Final Constitution" -ForegroundColor Magenta
            Write-Host ""

            $final = New-FinalConstitution -ProjectPath $resolvedPath -Refinements $Refinements -DryRun:$DryRun

            Write-Host ""
            Write-Success "Phase 3 Complete"
            Write-Info "Final constitution: $($final.path)"
            if ($final.refined) {
                Write-Info "Refinements applied: $($final.refinements)"
            } else {
                Write-Warn "No refinements provided - used master as-is"
            }
            Write-Host ""
        }
        elseif ($Provision) {
            # Phase 4: Provision resources
            Write-Host "  🔹 Phase 4: Provision Resources" -ForegroundColor Magenta
            Write-Host ""

            # Read scopes.yaml to get Aspire flag
            $scopesYamlPath = Join-Path $resolvedPath ".boltf\memory\scopes.yaml"
            $scopesConfig = Read-Yaml -FilePath $scopesYamlPath
            $useAspire = if ($scopesConfig.project.'use-aspire') { $scopesConfig.project.'use-aspire' } else { $false }

            $scopeFiles = Copy-ProvisionedFiles -ProjectPath $resolvedPath -Scopes $scopes.all
            $coreSkills = Copy-CoreSkills -ProjectPath $resolvedPath
            $aspireResources = Copy-AspireResources -ProjectPath $resolvedPath -UseAspire $useAspire

            # Generate provision report
            $reportPath = New-ProvisionReport `
                -ProjectPath $resolvedPath `
                -Scopes $scopes `
                -Constitution @{count=0} `
                -ScopeFiles $scopeFiles `
                -CoreSkills $coreSkills `
                -AspireResources $aspireResources

            Write-Host ""
            Write-Success "Phase 4 Complete"
            Write-Success "Core skills: $($coreSkills.Count)"
            if ($useAspire) {
                Write-Success "Aspire resources: $($aspireResources.Count)"
            }
            Write-Success "Prompts: $($scopeFiles.prompts.Count)"
            Write-Success "Instructions: $($scopeFiles.instructions.Count)"
            Write-Success "Skills: $($scopeFiles.skills.Count)"
            Write-Success "Templates: $($scopeFiles.templates.Count)"
            Write-Success "Agents: $($scopeFiles.agents.Count)"
            Write-Info "Provision report: $reportPath"
            Write-Host ""
        }
        else {
            # No phase specified - show usage
            Write-Err "No phase specified"
            Write-Host ""
            Write-Info "Usage:"
            Write-Info "  Phase 1: .\Invoke-BoltSetupConstitution.ps1 -GenerateMaster"
            Write-Info "  Phase 3: .\Invoke-BoltSetupConstitution.ps1 -GenerateFinal -Refinements `$refine"
            Write-Info "  Phase 4: .\Invoke-BoltSetupConstitution.ps1 -Provision"
            Write-Host ""
            Write-Info "Add -DryRun to preview without writing files"
            Write-Host ""
            exit 1
        }

        # Success banner
        Write-Host ""
        Write-Host "  ┌──────────────────────────────────────────────────────────────┐" -ForegroundColor Green
        Write-Host "  │   ✅ Phase Completed Successfully                            │" -ForegroundColor Green
        Write-Host "  └──────────────────────────────────────────────────────────────┘" -ForegroundColor Green
        Write-Host ""
    }
    catch {
        Write-Host ""
        Write-Host "  ┌──────────────────────────────────────────────────────────────┐" -ForegroundColor Red
        Write-Host "  │   ❌ Setup Failed                                             │" -ForegroundColor Red
        Write-Host "  └──────────────────────────────────────────────────────────────┘" -ForegroundColor Red
        Write-Host ""
        Write-Err "Error: $_"
        Write-Err "Stack: $($_.ScriptStackTrace)"
        Write-Host ""
        exit 1
    }
}

Main
