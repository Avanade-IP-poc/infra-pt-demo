# =============================================================================
# Bolt Framework - Project Initialization Script v2.0.0
# =============================================================================
# Simplified: fills base constitution articles + generates scopes.yaml
# =============================================================================

param(
    [Parameter(Mandatory = $false)]
    [string]$OutputDirectory = "",

    [Parameter(Mandatory = $false)]
    [string]$ProjectType = "",

    [Parameter(Mandatory = $false)]
    [string]$SourceDirectory = "",

    [Parameter(Mandatory = $false)]
    [switch]$Help
)

# ─── Logging ─────────────────────────────────────────────────────────────────
function Write-Info    { param([string]$M) Write-Host "[INFO] $M"    -ForegroundColor Blue }
function Write-Success { param([string]$M) Write-Host "[OK]   $M"    -ForegroundColor Green }
function Write-Warn    { param([string]$M) Write-Host "[WARN] $M"    -ForegroundColor Yellow }
function Write-Err     { param([string]$M) Write-Host "[ERR]  $M"    -ForegroundColor Red }
function Write-Step    { param([string]$M) Write-Host "[STEP] $M"    -ForegroundColor Cyan }
function Write-Prompt  { param([string]$M) Write-Host $M             -ForegroundColor Yellow -NoNewline }

# ─── Banner ──────────────────────────────────────────────────────────────────
function Show-Banner {
    Write-Host @"
╔═════════════════════════════════════════════════════════════╗
║                                                             ║
║       ██████╗  ██████╗ ██╗  ████████╗    ███████╗           ║
║       ██╔══██╗██╔═══██╗██║  ╚══██╔══╝    ██╔════╝           ║
║       ██████╔╝██║   ██║██║     ██║       █████╗             ║
║       ██╔══██╗██║   ██║██║     ██║       ██╔══╝             ║
║       ██████╔╝╚██████╔╝███████╗██║       ██╗     ██║        ║
║       ╚═════╝  ╚═════╝ ╚══════╝╚═╝       ╚═╝     ╚═╝        ║
║                                                             ║
║           Bolt Framework — AI-DLC v2.0.0                    ║
║                                                             ║
╚═════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Magenta
}

# ─── Usage ───────────────────────────────────────────────────────────────────
function Show-Usage {
    Write-Host @"
Usage:
  ./Init.ps1 -OutputDirectory <path> -ProjectType <green|brown> [-SourceDirectory <path>]

Parameters:
  -OutputDirectory  Where to create the new project
                    • Accepts: Absolute path (C:\\Projects\\MyApp) or relative path (.\\MyApp)
                    • Creates the directory if it doesn't exist

  -ProjectType      Type of project to initialize
                    • green  = Greenfield (new project from scratch)
                    • brown  = Brownfield (migration from existing legacy code)

  -SourceDirectory  Directory containing legacy source code
                    • Required when: -ProjectType is 'brown'
                    • Optional when: -ProjectType is 'green'
                    • Accepts: Absolute path (C:\\Legacy\\Code) or relative path (.\\legacy)
                    • Must exist and contain source files

  -Help             Show this message

The wizard walks you through the mandatory constitution decisions
and generates a scopes.yaml with the selected scopes.
"@
}

# ─── Interactive helpers ─────────────────────────────────────────────────────

function Read-Choice {
    <#
    .SYNOPSIS  Show a numbered menu, return the selected value.
    #>
    param(
        [string]$Title,
        [string[]]$Options,     # display labels
        [string[]]$Values,      # values returned
        [int]$Default = 1       # 1-based
    )
    Write-Host ""
    Write-Host "  $Title" -ForegroundColor Cyan
    for ($i = 0; $i -lt $Options.Count; $i++) {
        $marker = if ($i + 1 -eq $Default) { " (default)" } else { "" }
        Write-Host "    $($i + 1). $($Options[$i])$marker"
    }
    Write-Prompt "  Select [1-$($Options.Count)] > "
    $input = Read-Host
    if ([string]::IsNullOrWhiteSpace($input)) { $idx = $Default - 1 }
    else { $idx = [int]$input - 1 }
    if ($idx -lt 0 -or $idx -ge $Values.Count) { $idx = $Default - 1 }
    return $Values[$idx]
}

function Read-MultiChoice {
    <#
    .SYNOPSIS  Interactive checkbox-based multi-select (↑↓ navigate, Space toggle, Enter confirm)
    #>
    param(
        [string]$Title,
        [string[]]$Options,
        [string[]]$Values
    )

    # Initialize state
    $currentIndex = 0
    $selectedIndices = @()
    $hasAllOption = ($Values.Count -gt 0 -and $Values[0] -eq "all")
    $linesDrawn = 0

    # Helper to draw the menu
    function Draw-Menu {
        param($Index, $Selected, [ref]$LastDrawnLines)

        # If not first draw, move up and clear
        if ($LastDrawnLines.Value -gt 0) {
            # Move cursor up the exact number of lines we drew last time
            for ($i = 0; $i -lt $LastDrawnLines.Value; $i++) {
                Write-Host "`e[1A`e[2K" -NoNewline  # Move up 1 line + Clear line
            }
        }

        # Reset line counter
        $linesThisDraw = 0

        Write-Host ""
        $linesThisDraw++
        Write-Host "  $Title" -ForegroundColor Cyan
        $linesThisDraw++
        Write-Host "  (↑↓ navigate | Space select | Enter confirm)" -ForegroundColor DarkGray
        $linesThisDraw++

        for ($i = 0; $i -lt $Options.Count; $i++) {
            $checkbox = if ($Selected -contains $i) { "[X]" } else { "[ ]" }
            $prefix = if ($i -eq $Index) { "  >" } else { "   " }

            if ($i -eq $Index) {
                Write-Host "$prefix $checkbox " -NoNewline -ForegroundColor Yellow
                Write-Host "$($Options[$i])" -ForegroundColor Yellow
            } else {
                Write-Host "$prefix $checkbox $($Options[$i])"
            }
            $linesThisDraw++
        }

        # Save how many lines we drew for next redraw
        $LastDrawnLines.Value = $linesThisDraw
    }

    # Initial draw
    Draw-Menu -Index $currentIndex -Selected $selectedIndices -LastDrawnLines ([ref]$linesDrawn)

    # Input loop
    $done = $false
    while (-not $done) {
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

        switch ($key.VirtualKeyCode) {
            38 { # Up Arrow
                $currentIndex = if ($currentIndex -gt 0) { $currentIndex - 1 } else { $Options.Count - 1 }
                Draw-Menu -Index $currentIndex -Selected $selectedIndices -LastDrawnLines ([ref]$linesDrawn)
            }
            40 { # Down Arrow
                $currentIndex = if ($currentIndex -lt $Options.Count - 1) { $currentIndex + 1 } else { 0 }
                Draw-Menu -Index $currentIndex -Selected $selectedIndices -LastDrawnLines ([ref]$linesDrawn)
            }
            32 { # Space
                if ($selectedIndices -contains $currentIndex) {
                    $selectedIndices = @($selectedIndices | Where-Object { $_ -ne $currentIndex })
                } else {
                    $selectedIndices += $currentIndex
                }
                Draw-Menu -Index $currentIndex -Selected $selectedIndices -LastDrawnLines ([ref]$linesDrawn)
            }
            13 { # Enter
                $done = $true
            }
        }
    }

    Write-Host ""

    # Process selection
    $result = @()

    # Check if "All" option was selected
    $selectAll = $hasAllOption -and ($selectedIndices -contains 0)

    if ($selectAll) {
        # Return all values except the "all" marker
        return $Values | Where-Object { $_ -ne "all" }
    }

    # Return selected values
    foreach ($idx in $selectedIndices) {
        if ($idx -ge 0 -and $idx -lt $Values.Count) {
            $result += $Values[$idx]
        }
    }

    return $result
}

function Read-YesNo {
    param([string]$Question, [bool]$Default = $true)
    $hint = if ($Default) { "Y/n" } else { "y/N" }
    Write-Prompt "  $Question [$hint] > "
    $ans = Read-Host
    if ([string]::IsNullOrWhiteSpace($ans)) { return $Default }
    return ($ans.Trim().ToLower() -eq 'y')
}

# ─── Prerequisite checks ────────────────────────────────────────────────────
function Test-Prerequisites {
    if ($ProjectType -eq "brown" -and [string]::IsNullOrEmpty($SourceDirectory)) {
        Write-Err "SourceDirectory is required for brownfield projects"; exit 1
    }
    if ($ProjectType -eq "brown" -and -not (Test-Path $SourceDirectory)) {
        Write-Err "Source directory '$SourceDirectory' does not exist"; exit 1
    }
    if (Test-Path $OutputDirectory) {
        Write-Err "Output directory '$OutputDirectory' already exists"; exit 1
    }
}

# ─── Collect decisions ───────────────────────────────────────────────────────

function Get-AllDecisions {
    <#
    .SYNOPSIS  Interactive wizard that collects every base-constitution decision.
    .OUTPUTS   Hashtable with all choices.
    #>
    $d = @{}

    # ── Step 0 — Practice Selection ─────────────────────────────────────────
    Write-Host ""
    Write-Step "Step 0 — Practice Selection"

    $practiceMap = @{
        "Apps & Infra" = @("backend", "frontend", "cloud-platform")
        "Data & AI"    = @("data", "ai", "integration")
        "CRM"          = @("crm")
        "Custom"       = @()  # Manual selection
    }

    $selectedPractice = Read-Choice `
        -Title "Select your Practice (pre-configured scope bundles)" `
        -Options @(
            "Apps & Infra  — Backend APIs, Frontend UIs, Cloud Infrastructure",
            "Data & AI     — Databases, AI/ML models, Data integrations",
            "CRM           — Dynamics 365, Power Platform, Dataverse",
            "Custom        — Manual scope selection (advanced)"
        ) `
        -Values @("Apps & Infra", "Data & AI", "CRM", "Custom") `
        -Default 1

    $d.Practice = $selectedPractice

    # ── Article I §1.1 — Active Scopes ──────────────────────────────────────
    Write-Host ""
    Write-Step "Article I — Active Scopes"

    if ($selectedPractice -eq "Custom") {
        # Manual selection (original flow)
        Write-Host "  ℹ Manual scope selection mode" -ForegroundColor DarkGray
        $d.Scopes = Read-MultiChoice `
            -Title "§1.1  Active scopes (select all that apply)" `
            -Options @(
                "backend        — Server-side APIs, services, domain logic",
                "frontend       — Web/mobile UI, SPA, design system",
                "cloud-platform — Infrastructure, Landing Zones, IaC",
                "data           — Databases, ETL/ELT, analytics",
                "integration    — API management, messaging, connectors",
                "ai             — AI/ML models, agents, prompt engineering",
                "crm            — Dynamics 365, Power Platform, Dataverse"
            ) `
            -Values @("backend", "frontend", "cloud-platform", "data", "integration", "ai", "crm")
    } else {
        # Practice-based pre-selection
        $preselectedScopes = $practiceMap[$selectedPractice]
        Write-Host "  ℹ Practice '$selectedPractice' pre-selects: $($preselectedScopes -join ', ')" -ForegroundColor Green

        $confirm = Read-YesNo "  Confirm these scopes?" $true
        if ($confirm) {
            $d.Scopes = $preselectedScopes
        } else {
            # User wants to customize
            Write-Host "  ℹ Customizing scopes for '$selectedPractice' practice" -ForegroundColor DarkGray
            $d.Scopes = Read-MultiChoice `
                -Title "§1.1  Active scopes (select all that apply)" `
                -Options @(
                    "backend        — Server-side APIs, services, domain logic",
                    "frontend       — Web/mobile UI, SPA, design system",
                    "cloud-platform — Infrastructure, Landing Zones, IaC",
                    "data           — Databases, ETL/ELT, analytics",
                    "integration    — API management, messaging, connectors",
                    "ai             — AI/ML models, agents, prompt engineering",
                    "crm            — Dynamics 365, Power Platform, Dataverse"
                ) `
                -Values @("backend", "frontend", "cloud-platform", "data", "integration", "ai", "crm")
        }
    }

    if ($d.Scopes.Count -eq 0) {
        Write-Warn "No scopes selected — defaulting to 'backend'"
        $d.Scopes = @("backend")
    }

    # Derive project type from selected scopes (replaces former §1.0)
    $hasCloudPlatform = $d.Scopes -contains "cloud-platform"
    $hasAppScopes = ($d.Scopes | Where-Object { $_ -in @("backend","frontend","ai") }).Count -gt 0
    if ($hasCloudPlatform -and $hasAppScopes) { $d.ProjectType = "full-stack" }
    elseif ($hasCloudPlatform)                { $d.ProjectType = "infra-only" }
    else                                      { $d.ProjectType = "app-only" }

    # ── Step 1.5 — Work Management Tool Integration (Optional) ─────────────
    Write-Host ""
    Write-Step "Step 1.6 — Work Management Tool Integration"

    Write-Host ""
    Write-Host "  ℹ Bolt Framework can integrate with work management tools" -ForegroundColor Cyan
    Write-Host "  This enables automatic sync of:" -ForegroundColor DarkGray
    Write-Host "     • Feature specs → Work items/Issues" -ForegroundColor DarkGray
    Write-Host "     • Implementation plans → Tasks" -ForegroundColor DarkGray
    Write-Host "     • Bolt iterations → Status updates" -ForegroundColor DarkGray
    Write-Host ""

    $d.WorkManagementTool = Read-Choice `
        -Title "Select work management tool (or None for manual tracking)" `
        -Options @(
            "None (manual tracking)",
            "Azure Boards (Azure DevOps work items)",
            "GitHub Projects (GitHub Issues integration)",
            "Jira (Atlassian work management)"
        ) `
        -Values @("none", "azure-boards", "github-projects", "jira") `
        -Default 1

    if ($d.WorkManagementTool -ne "none") {
        Write-Success "Work management tool: $($d.WorkManagementTool)"
        Write-Host "  ℹ Configure connection details in constitution after provisioning" -ForegroundColor DarkGray
    } else {
        Write-Info "Manual tracking — no automatic sync configured"
    }

    # ── Step 1.6 — Development Environment Configuration ───────────────────
    Write-Host ""
    Write-Step "Step 1.6 — Development Environment Configuration"

    Write-Host ""
    Write-Host "  ℹ Configure your local development environment" -ForegroundColor Cyan
    Write-Host "  This determines which tools and configurations are provisioned" -ForegroundColor DarkGray
    Write-Host ""

    # Detect multi-service architecture
    $serviceCount = 0
    if ($d.Scopes -contains "backend")        { $serviceCount++ }
    if ($d.Scopes -contains "frontend")       { $serviceCount++ }
    if ($d.Scopes -contains "cloud-platform" -or $d.Scopes -contains "data" -or $d.Scopes -contains "integration") {
        $serviceCount++ # External resources suggest multi-service
    }

    # Local Orchestration (if multi-service)
    $d.LocalOrchestration = "none"
    if ($serviceCount -ge 2) {
        Write-Host "  Multi-service architecture detected — local orchestration recommended" -ForegroundColor Yellow
        $d.LocalOrchestration = Read-Choice `
            -Title "Select local orchestration tool" `
            -Options @(
                ".NET Aspire (automatic service discovery, observability)",
                "Docker Compose (YAML-based, simple)",
                "Kubernetes (minikube/kind for local dev)",
                "Podman Compose (rootless alternative)",
                "None (manual service startup)"
            ) `
            -Values @("aspire", "docker-compose", "kubernetes", "podman", "none") `
            -Default 1

        if ($d.LocalOrchestration -eq "aspire") {
            Write-Success "Aspire selected — constitution will guide setup during provisioning"
        } elseif ($d.LocalOrchestration -ne "none") {
            Write-Success "Orchestration: $($d.LocalOrchestration) — configs will be provisioned"
        }
    }

    # Frontend Framework (if frontend scope active)
    $d.FrontendFramework = "none"
    if ($d.Scopes -contains "frontend") {
        Write-Host ""
        $d.FrontendFramework = Read-Choice `
            -Title "Select frontend framework (provisions matching instructions)" `
            -Options @(
                "React (hooks, components, state management)",
                "Angular (standalone components, signals)",
                "Vue.js (Composition API, Pinia)",
                "None or multiple (will provision manually)"
            ) `
            -Values @("react", "angular", "vue", "none") `
            -Default 1

        if ($d.FrontendFramework -ne "none") {
            Write-Success "Framework: $($d.FrontendFramework) — matching instructions enabled"
        }
    }

    # Cloud Development Environment
    Write-Host ""
    $d.CloudDevEnvironment = Read-Choice `
        -Title "Will you use cloud-based development environments?" `
        -Options @(
            "No (local development only)",
            "GitHub Codespaces (cloud-based VS Code)",
            "VS Code Remote - Containers (devcontainer.json)",
            "Both Codespaces + Devcontainers"
        ) `
        -Values @("none", "codespaces", "devcontainers", "both") `
        -Default 1

    if ($d.CloudDevEnvironment -ne "none") {
        Write-Success "Cloud dev: $($d.CloudDevEnvironment) — devcontainer configs will be provisioned"
    }

    # Container Runtime
    Write-Host ""
    $d.ContainerRuntime = Read-Choice `
        -Title "Container runtime for local development" `
        -Options @(
            "Docker Desktop (standard, GUI management)",
            "Podman (rootless, daemonless)",
            "None (no containerization)"
        ) `
        -Values @("docker", "podman", "none") `
        -Default 1

    # ── Article X — Environments & Configuration ────────────────────────────
    Write-Host ""
    Write-Step "Article X — Environments & Configuration"

    $d.Environments = Read-MultiChoice `
        -Title "§10.1  Enabled environments" `
        -Options @("dev", "uat", "pre", "prod") `
        -Values @("dev", "uat", "pre", "prod")
    if ($d.Environments.Count -eq 0) { $d.Environments = @("dev", "prod") }

    # §10.1 Auto-Deploy per environment
    $d.AutoDeploy = @{}
    $triggerMap = @{
        "dev"  = "On commit to develop"
        "uat"  = "On PR merge"
        "pre"  = "Manual trigger"
        "prod" = "Manual approval"
    }
    foreach ($env in $d.Environments) {
        $def = ($env -eq "dev")
        $d.AutoDeploy[$env] = Read-YesNo "§10.1  Auto-deploy ${env}: $($triggerMap[$env])?" $def
    }

    $d.ConfigManagement = Read-Choice `
        -Title "§10.2  Configuration management" `
        -Options @(
            "Environment Variables",
            "appsettings / .env files",
            "Azure App Config + Key Vault (recommended)"
        ) `
        -Values @("env-vars", "config-files", "app-config-keyvault") `
        -Default 3

    $d.SecretsDev = Read-Choice `
        -Title "§10.3  Local dev secrets" `
        -Options @(
            "User Secrets (.NET: dotnet user-secrets)",
            ".env files (gitignored)",
            "Local Key Vault (dev instance)"
        ) `
        -Values @("user-secrets", "env-files", "local-keyvault") `
        -Default 1

    $d.FeatureFlags = Read-Choice `
        -Title "§10.4  Feature flag provider" `
        -Options @("None", "Azure App Configuration", "LaunchDarkly", "Unleash") `
        -Values @("none", "azure-app-config", "launchdarkly", "unleash") `
        -Default 1

    # ── Article XI — CI/CD Pipeline ─────────────────────────────────────────
    Write-Host ""
    Write-Step "Article XI — CI/CD Pipeline"

    $d.CiCdPlatform = Read-Choice `
        -Title "§11.1  CI/CD platform" `
        -Options @("GitHub Actions", "Azure DevOps Pipelines") `
        -Values @("github-actions", "azure-devops") `
        -Default 1

    # ── §11.1b — Infrastructure as Code (if cloud-platform active) ─────
    $hasInfraForIaC = $d.Scopes -contains "cloud-platform"
    if ($hasInfraForIaC) {
        $d.IaCTool = Read-Choice `
            -Title "§11.1b Infrastructure as Code (IaC) tool" `
            -Options @(
                "Bicep          — Azure-native, type-safe (recommended)",
                "ARM Templates  — Azure-native JSON (legacy)",
                "Terraform      — Multi-cloud HCL",
                "Pulumi         — Multi-cloud with programming languages"
            ) `
            -Values @("bicep", "arm", "terraform", "pulumi") `
            -Default 1
    } else {
        $d.IaCTool = "none"
    }

    # ── §11.2 — Pipeline Stages (Application) ──────────────────────────
    $hasApp = ($d.Scopes | Where-Object { $_ -in @("backend","frontend","ai") }).Count -gt 0
    if ($hasApp) {
        $d.AppPipelineStages = Read-MultiChoice `
            -Title "§11.2  Application pipeline stages" `
            -Options @(
                "Build", "Lint/Format", "Unit Tests", "Integration Tests",
                "Architecture Tests", "Mutation Tests", "Security Scan",
                "Container Build", "Container Scan"
            ) `
            -Values @(
                "build", "lint-format", "unit-tests", "integration-tests",
                "architecture-tests", "mutation-tests", "security-scan",
                "container-build", "container-scan"
            )
        if ($d.AppPipelineStages.Count -eq 0) {
            $d.AppPipelineStages = @("build", "lint-format", "unit-tests", "security-scan")
        }

        if ($d.AppPipelineStages -contains "unit-tests") {
            Write-Prompt "  §11.2  Unit test coverage threshold (%) [80] > "
            $cov = Read-Host
            $d.UnitTestCoverage = if ([string]::IsNullOrWhiteSpace($cov)) { 80 } else { [int]$cov }
        } else { $d.UnitTestCoverage = 0 }

        if ($d.AppPipelineStages -contains "mutation-tests") {
            Write-Prompt "  §11.2  Mutation test score threshold (%) [60] > "
            $mut = Read-Host
            $d.MutationScore = if ([string]::IsNullOrWhiteSpace($mut)) { 60 } else { [int]$mut }
        } else { $d.MutationScore = 0 }
    } else {
        $d.AppPipelineStages = @()
        $d.UnitTestCoverage = 0
        $d.MutationScore = 0
    }

    # ── §11.2 — Pipeline Stages (Infrastructure) ───────────────────────
    $hasInfra = $d.Scopes -contains "cloud-platform"
    if ($hasInfra) {
        $d.InfraPipelineStages = Read-MultiChoice `
            -Title "§11.2  Infrastructure pipeline stages" `
            -Options @(
                "IaC Lint", "IaC Validation", "Security Scan",
                "Cost Estimation", "Compliance Check"
            ) `
            -Values @(
                "iac-lint", "iac-validation", "security-scan",
                "cost-estimation", "compliance-check"
            )
        if ($d.InfraPipelineStages.Count -eq 0) {
            $d.InfraPipelineStages = @("iac-lint", "iac-validation", "security-scan")
        }
    } else {
        $d.InfraPipelineStages = @()
    }

    # ── §11.2 — Deployment Stages (derived from environments) ──────────
    $d.DeployPipelineStages = [string[]]@($d.Environments)

    $d.DeployStrategy = Read-Choice `
        -Title "§11.3  Deployment strategy" `
        -Options @("Rolling Update", "Blue-Green", "Canary", "Feature Flags") `
        -Values @("rolling", "blue-green", "canary", "feature-flags") `
        -Default 1

    $d.BranchStrategy = Read-Choice `
        -Title "§11.4  Branch strategy" `
        -Options @(
            "GitFlow  (feature/, develop, release/, main)",
            "GitHub Flow  (feature/, main)",
            "Trunk-Based  (short-lived branches, main)"
        ) `
        -Values @("gitflow", "github-flow", "trunk-based") `
        -Default 2

    # ── Article XII — Observability ─────────────────────────────────────────
    Write-Host ""
    Write-Step "Article XII — Observability"

    $d.Observability = Read-Choice `
        -Title "§12.1  Observability strategy" `
        -Options @(
            "Azure-Native (Azure Monitor + Application Insights)",
            "OpenTelemetry → Azure Monitor Exporter (recommended)",
            "OpenTelemetry → Grafana Stack (self-hosted)"
        ) `
        -Values @("azure-native", "otel-azure", "otel-grafana") `
        -Default 2

    # ── §12.3 — Infrastructure Monitoring (conditional) ─────────────────
    $hasInfra2 = $d.Scopes -contains "cloud-platform"
    if ($hasInfra2) {
        $d.InfraMonitoring = Read-MultiChoice `
            -Title "§12.3  Infrastructure monitoring components" `
            -Options @(
                "Resource Health (Azure Resource Health)",
                "Activity Logs (Azure Monitor)",
                "Diagnostics (Log Analytics)",
                "Alerts (Azure Monitor Alerts)",
                "Dashboards (Azure Workbooks / Grafana)"
            ) `
            -Values @("resource-health", "activity-logs", "diagnostics", "alerts", "dashboards")
        if ($d.InfraMonitoring.Count -eq 0) {
            $d.InfraMonitoring = @("resource-health", "activity-logs", "diagnostics", "alerts", "dashboards")
        }
    } else {
        $d.InfraMonitoring = @()
    }

    # ── Article XVI — Security Policies ─────────────────────────────────────
    Write-Host ""
    Write-Step "Article XVI — Security Policies"

    $d.VNet          = Read-YesNo "§16.1  Azure Virtual Network?"          $true
    $d.PrivateEndpoints = Read-YesNo "§16.1  Private Endpoints?"           $true
    $d.WAF           = Read-YesNo "§16.1  Web Application Firewall (Front Door)?" $false

    $d.EncryptionKeys = Read-Choice `
        -Title "§16.2  Encryption at rest" `
        -Options @("Azure-managed keys", "Customer-managed keys") `
        -Values @("azure-managed", "customer-managed") `
        -Default 1

    $d.PiiHandling = Read-Choice `
        -Title "§16.2  PII handling" `
        -Options @("Anonymization", "Pseudonymization", "Encryption") `
        -Values @("anonymization", "pseudonymization", "encryption") `
        -Default 3

    $d.Compliance = Read-MultiChoice `
        -Title "§16.3  Compliance requirements" `
        -Options @("GDPR", "HIPAA", "SOC 2", "PCI-DSS", "None") `
        -Values @("gdpr", "hipaa", "soc2", "pci-dss", "none")
    if ($d.Compliance.Count -eq 0) { $d.Compliance = @("none") }

    return $d
}

# ─── Copy Bolt framework ────────────────────────────────────────────────────

function Copy-BoltFramework {
    Write-Step "Copying Bolt Framework..."

    $root = $PSScriptRoot

    # .github
    if (Test-Path "$root\.github") {
        Copy-Item "$root\.github" "$OutputDirectory\.github" -Recurse -Force
    }
    # .boltf
    if (Test-Path "$root\.boltf") {
        Copy-Item "$root\.boltf" "$OutputDirectory\.boltf" -Recurse -Force
    }
    # Root docs
    @("README.md","CHANGELOG.md","CONTRIBUTING.md","LICENSE","PENDIENTES.md") | ForEach-Object {
        if (Test-Path "$root\.boltf\$_") { Copy-Item "$root\.boltf\$_" "$OutputDirectory\$_" -Force }
    }
    @("INITIALIZER.md","USAGE.md") | ForEach-Object {
        if (Test-Path "$root\$_") { Copy-Item "$root\$_" "$OutputDirectory\$_" -Force }
    }

    # Python integration scripts (root level wrapper only)
    @("Invoke-PythonScript.ps1") | ForEach-Object {
        if (Test-Path "$root\$_") {
            Copy-Item "$root\$_" "$OutputDirectory\$_" -Force
            Write-Info "Copied Python script: $_"
        }
    }

    # Python documentation and examples
    if (Test-Path "$root\docs") {
        Copy-Item "$root\docs" "$OutputDirectory\docs" -Recurse -Force
        Write-Info "Copied documentation including Python integration guide"
    }
    if (Test-Path "$root\examples") {
        Copy-Item "$root\examples" "$OutputDirectory\examples" -Recurse -Force
        Write-Info "Copied examples including Python usage examples"
    }

    Write-Success "Bolt Framework copied (including Python integration)"
}

# ─── Create directory structure ──────────────────────────────────────────────

function New-ProjectStructure {
    param([hashtable]$Decisions)

    Write-Step "Creating project structure..."

    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null

    # Project-type directories
    if ($ProjectType -eq "green") {
        New-Item -ItemType Directory -Path "$OutputDirectory\origin" -Force | Out-Null
    } else {
        New-Item -ItemType Directory -Path "$OutputDirectory\legacy"    -Force | Out-Null
        New-Item -ItemType Directory -Path "$OutputDirectory\migration" -Force | Out-Null
    }

    # Scope-driven directories
    if ($Decisions.Scopes -contains "backend" -or $Decisions.Scopes -contains "ai") {
        New-Item -ItemType Directory -Path "$OutputDirectory\src\backend" -Force | Out-Null
    }
    if ($Decisions.Scopes -contains "frontend") {
        New-Item -ItemType Directory -Path "$OutputDirectory\src\frontend" -Force | Out-Null
    }
    if ($Decisions.Scopes -contains "cloud-platform") {
        New-Item -ItemType Directory -Path "$OutputDirectory\infra" -Force | Out-Null
    }
    if ($Decisions.Scopes -contains "data") {
        New-Item -ItemType Directory -Path "$OutputDirectory\data" -Force | Out-Null
    }

    New-Item -ItemType Directory -Path "$OutputDirectory\docs" -Force | Out-Null

    Write-Success "Project structure created"
}

# ─── Generate scopes.yaml ───────────────────────────────────────────────────

function New-ScopesYaml {
    param([hashtable]$Decisions)

    Write-Step "Generating scopes.yaml..."

    $scopesDir = "$OutputDirectory\.boltf"
    if (-not (Test-Path $scopesDir)) {
        New-Item -ItemType Directory -Path $scopesDir -Force | Out-Null
    }

    # Pre-compute yaml fragments
    $scopesYaml     = ($Decisions.Scopes | ForEach-Object { "  - $_" }) -join "`n"
    $envListYaml    = "[" + ($Decisions.Environments -join ", ") + "]"

    $autoDeployLines = ""
    foreach ($env in $Decisions.Environments) {
        $val = if ($Decisions.AutoDeploy.ContainsKey($env) -and $Decisions.AutoDeploy[$env]) { "true" } else { "false" }
        $autoDeployLines += "      ${env}: $val`n"
    }
    $autoDeployLines = $autoDeployLines.TrimEnd("`n")

    $appStagesYaml    = if ($Decisions.AppPipelineStages.Count -gt 0)   { "[" + ($Decisions.AppPipelineStages -join ", ") + "]" }   else { "[]" }
    $infraStagesYaml  = if ($Decisions.InfraPipelineStages.Count -gt 0) { "[" + ($Decisions.InfraPipelineStages -join ", ") + "]" } else { "[]" }
    $deployStagesYaml = if ($Decisions.DeployPipelineStages.Count -gt 0) {
        "[" + (($Decisions.DeployPipelineStages | ForEach-Object { "deploy-$_" }) -join ", ") + "]"
    } else { "[]" }
    $infraMonYaml     = if ($Decisions.InfraMonitoring.Count -gt 0)    { "[" + ($Decisions.InfraMonitoring -join ", ") + "]" }    else { "[]" }
    $complianceYaml   = "[" + ($Decisions.Compliance -join ", ") + "]"

    $vnet    = $Decisions.VNet.ToString().ToLower()
    $priv    = $Decisions.PrivateEndpoints.ToString().ToLower()
    $waf     = $Decisions.WAF.ToString().ToLower()

    $yaml = @"
# =============================================================================
# Bolt Framework — Active Scopes Configuration
# Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
# =============================================================================
# This file declares which scopes are active and records all wizard decisions.
# Each scope injects its own constitution sections from
#   .boltf/scopes/<scope>/memory/constitution.md
# The work-management scope is always active (transversal).
# =============================================================================

project:
  practice: $($Decisions.Practice)      # Practice selection (Phase 3)
  type: $($Decisions.ProjectType)       # derived from scopes
  migration-type: $ProjectType   # green | brown
  work-management-tool: $($Decisions.WorkManagementTool)    # Work item tracking integration (Step 1.5)

  # Development Environment (Step 1.6)
  local-orchestration: $($Decisions.LocalOrchestration)     # docker-compose | kubernetes | podman | aspire | none
  frontend-framework: $($Decisions.FrontendFramework)       # react | angular | vue | none
  cloud-dev-environment: $($Decisions.CloudDevEnvironment)  # codespaces | devcontainers | both | none
  container-runtime: $($Decisions.ContainerRuntime)         # docker | podman | none

active-scopes:
$scopesYaml

# Transversal (always active, not selectable)
transversal-scopes:
  - work-management

# ─── Wizard Decisions ───────────────────────────────────────────────────────
# These capture every choice made during initialization so downstream agents
# can read them without re-parsing the constitution markdown.

decisions:
  # Article X — Environments & Configuration
  environments:
    enabled: $envListYaml
    auto-deploy:
$autoDeployLines
  config-management: $($Decisions.ConfigManagement)
  secrets-dev: $($Decisions.SecretsDev)
  feature-flags: $($Decisions.FeatureFlags)

  # Article XI — CI/CD Pipeline
  cicd:
    platform: $($Decisions.CiCdPlatform)
    iac-tool: $($Decisions.IaCTool)
    deploy-strategy: $($Decisions.DeployStrategy)
    branch-strategy: $($Decisions.BranchStrategy)
    pipeline-stages:
      application: $appStagesYaml
      infrastructure: $infraStagesYaml
      deployment: $deployStagesYaml
    thresholds:
      unit-test-coverage: $($Decisions.UnitTestCoverage)
      mutation-score: $($Decisions.MutationScore)

  # Article XII — Observability
  observability: $($Decisions.Observability)
  infra-monitoring: $infraMonYaml

  # Article XVI — Security Policies
  security:
    vnet: $vnet
    private-endpoints: $priv
    waf: $waf
    encryption-keys: $($Decisions.EncryptionKeys)
    pii-handling: $($Decisions.PiiHandling)
    compliance: $complianceYaml

# Base constitution articles (always present):
#   I   — Project Scope & Type
#   X   — Environments & Configuration
#   XI  — CI/CD Pipeline
#   XII — Observability
#   XVI — Security Policies
#   XIX — Governance
"@

    Set-Content -Path "$scopesDir\scopes.yaml" -Value $yaml -Encoding UTF8
    Write-Success "scopes.yaml generated at .boltf/scopes.yaml"
}

# ─── Prefill constitution ────────────────────────────────────────────────────

function New-BasicConstitution {
    <#
    .SYNOPSIS  Generate separate constitution files per scope.
    .DESCRIPTION  Creates constitution-init.md (base) and <scope>-constitution.md for each active scope.
                  @Bolt Constitution agent will process each scope separately and merge at the end.
    #>
    param([hashtable]$D)

    Write-Step "Generating constitution files (init + per-scope)..."

    $memoryDir = "$OutputDirectory\.boltf\memory"
    if (-not (Test-Path $memoryDir)) {
        New-Item -ItemType Directory -Path $memoryDir -Force | Out-Null
    }

    $date = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $boltfRoot = $PSScriptRoot

    # Build scope list
    $scopesList = ($D.Scopes | ForEach-Object { "- **$_**: Scope provisions tech stack, patterns, and quality gates" }) -join "`n"

    # 1) Create constitution-init.md (base constitution with metadata)
    $initPath = "$memoryDir\constitution-init.md"
    $initContent = @"
# Project Constitution (Initial)

> **Generated**: $date
> **Practice**: $($D.Practice)
> **Active Scopes**: $($D.Scopes -join ', ')
> **Project Type**: $($D.ProjectType) ($ProjectType)

---

# Article I §1.1 — Active Scopes

The following scopes are active for this project:

$scopesList

---

# Processing Instructions

This is the base constitution file created during initialization.
Each active scope has its own constitution file: **<scope>-constitution.md**

The @Bolt Constitution agent will process each scope file separately and merge
all refinement decisions into a final **constitution.md** file.

## Scope Constitution Files

$($D.Scopes | ForEach-Object { "- [$_-constitution.md](./$_-constitution.md)" } | Out-String)

---

**Generated by Bolt Framework Init.ps1** on $date
"@

    Set-Content -Path $initPath -Value $initContent -Encoding UTF8
    Write-Success "Created base constitution: constitution-init.md"

    # 2) Create separate constitution file for each scope
    $copiedCount = 0
    foreach ($scope in $D.Scopes) {
        $scopeConstitutionPath = Join-Path $boltfRoot ".boltf\scopes\$scope\memory\constitution.md"

        if (Test-Path $scopeConstitutionPath) {
            Write-Info "Creating constitution for scope: $scope"
            $scopeContent = Get-Content $scopeConstitutionPath -Raw -Encoding UTF8

            $targetPath = "$memoryDir\$scope-constitution.md"

            # Add header with scope metadata
            $scopeFileContent = @"
<!-- ================================================================ -->
<!-- SCOPE: $scope -->
<!-- Generated: $date -->
<!-- Source: .boltf/scopes/$scope/memory/constitution.md -->
<!-- ================================================================ -->

$scopeContent

---

**Scope Constitution for $scope** | Generated by Bolt Framework Init.ps1 on $date
"@
            Set-Content -Path $targetPath -Value $scopeFileContent -Encoding UTF8
            Write-Success "Created: $scope-constitution.md"
            $copiedCount++
        } else {
            Write-Warn "Constitution not found for scope '$scope' at: $scopeConstitutionPath"
        }
    }

    Write-Info "Created $copiedCount scope constitution files"
    Write-Info "Next: Run '@Bolt Constitution' to refine and merge all constitutions"
}

# ─── Legacy Function (Deprecated in Practice-based workflow) ────────────────
# This function was used for single-step initialization. Now replaced by
# New-BasicConstitution (Phase 1) + bolt-setup-constitution skill (Phase 2).
# Kept for reference/rollback purposes.

function Set-ConstitutionDecisions_DEPRECATED {
    param([hashtable]$D)

    Write-Step "Prefilling constitution with your decisions..."

    $path = "$OutputDirectory\.boltf\memory\constitution.md"
    if (-not (Test-Path $path)) {
        Write-Warn "constitution.md not found — skipping prefill"
        return
    }

    $c = Get-Content $path -Raw

    # ── Article I §1.1 — Active Scopes ──────────────────────────────────
    foreach ($scope in $D.Scopes) {
        $c = $c -replace "\| \[ \] \| \*\*$scope\*\*", "| [x] | **$scope**"
    }

    # ── Article X §10.1 — Environments ──────────────────────────────────
    foreach ($env in $D.Environments) {
        $c = $c -replace "(\*\*$env\*\*\s+\|[^|]+\|)\s*\[ \] Yes", "`$1 [x] Yes"
    }

    # ── Article X §10.1 — Auto-Deploy ───────────────────────────────────
    foreach ($env in $D.Environments) {
        if ($D.AutoDeploy.ContainsKey($env) -and $D.AutoDeploy[$env]) {
            $c = $c -replace "(\*\*$env\*\*.*?\[x\] Yes \|)\s*\[ \]", "`$1 [x]"
        }
    }

    # ── Article X §10.2 — Config management ─────────────────────────────
    $configMap = @{
        "azure-app-config" = "Azure App Configuration"
        "env-vars"         = "Environment Variables"
        "config-files"     = "appsettings"
        "combination"      = "Combination"
    }
    $label = $configMap[$D.ConfigManagement]
    if ($label) { $c = $c -replace "\- \[ \] \*\*$label", "- [x] **$label" }

    # ── Article X §10.3 — Local dev secrets ─────────────────────────────
    $secretMap = @{
        "user-secrets"   = "User Secrets"
        "env-files"      = "\.env files"
        "local-keyvault" = "Local Key Vault"
    }
    $label = $secretMap[$D.SecretsDev]
    if ($label) { $c = $c -replace "\- \[ \] \*\*$label", "- [x] **$label" }

    # ── Article X §10.4 — Feature flags ─────────────────────────────────
    $ffMap = @{
        "none"             = "None"
        "azure-app-config" = "Azure App Configuration"
        "launchdarkly"     = "LaunchDarkly"
        "unleash"          = "Unleash"
    }
    $label = $ffMap[$D.FeatureFlags]
    if ($label) { $c = $c -replace "\- \[ \] \*\*$label\*\*(?!\s*-)", "- [x] **$label**" }

    # ── Article XI §11.1 — CI/CD ────────────────────────────────────────
    $cicdMap = @{
        "github-actions" = "GitHub Actions"
        "azure-devops"   = "Azure DevOps Pipelines"
    }
    $label = $cicdMap[$D.CiCdPlatform]
    if ($label) { $c = $c -replace "\- \[ \] \*\*$label\*\*", "- [x] **$label**" }

    # ── Article XI §11.3 — Deploy strategy ──────────────────────────────
    $deployMap = @{
        "rolling"       = "Rolling Update"
        "blue-green"    = "Blue-Green"
        "canary"        = "Canary"
        "feature-flags" = "Feature Flags"
    }
    $label = $deployMap[$D.DeployStrategy]
    if ($label) { $c = $c -replace "\- \[ \] \*\*$label\*\*", "- [x] **$label**" }

    # ── Article XI §11.4 — Branch strategy ──────────────────────────────
    $branchMap = @{
        "gitflow"      = "GitFlow"
        "github-flow"  = "GitHub Flow"
        "trunk-based"  = "Trunk-Based"
    }
    $label = $branchMap[$D.BranchStrategy]
    if ($label) { $c = $c -replace "\- \[ \] \*\*$label\*\*", "- [x] **$label**" }

    # ── Article XI §11.2 — App Pipeline Stages ──────────────────────────
    $appStageMap = @{
        "build"              = "Build"
        "lint-format"        = "Lint/Format"
        "unit-tests"         = "Unit Tests"
        "integration-tests"  = "Integration Tests"
        "architecture-tests" = "Architecture Tests"
        "mutation-tests"     = "Mutation Tests"
        "container-build"    = "Container Build"
        "container-scan"     = "Container Scan"
    }
    foreach ($stage in $D.AppPipelineStages) {
        if ($stage -eq "security-scan") { continue }
        $label = $appStageMap[$stage]
        if ($label) {
            $escaped = [regex]::Escape($label)
            $c = $c -replace "(\*\*$escaped\*\*\s*\|)\s*\[ \] Yes", "`$1 [x] Yes"
        }
    }
    if ($D.AppPipelineStages -contains "security-scan") {
        $c = $c -replace '(\*\*Security Scan\*\*\s*\|)\s*\[ \] Yes(\s*\|\s*0 Critical)', '$1 [x] Yes$2'
    }

    # Thresholds
    if ($D.UnitTestCoverage -gt 0) {
        $c = $c -replace 'Coverage >= \\_\\_%', "Coverage >= $($D.UnitTestCoverage)%"
    }
    if ($D.MutationScore -gt 0) {
        $c = $c -replace 'Score >= \\_\\_%', "Score >= $($D.MutationScore)%"
    }

    # ── Article XI §11.2 — Infra Pipeline Stages ────────────────────────
    $infraStageMap = @{
        "iac-lint"         = "IaC Lint"
        "iac-validation"   = "IaC Validation"
        "cost-estimation"  = "Cost Estimation"
        "compliance-check" = "Compliance Check"
    }
    foreach ($stage in $D.InfraPipelineStages) {
        if ($stage -eq "security-scan") { continue }
        $label = $infraStageMap[$stage]
        if ($label) {
            $escaped = [regex]::Escape($label)
            $c = $c -replace "(\*\*$escaped\*\*\s*\|)\s*\[ \] Yes", "`$1 [x] Yes"
        }
    }
    if ($D.InfraPipelineStages -contains "security-scan") {
        $c = $c -replace '(\*\*Security Scan\*\*\s*\|)\s*\[ \] Yes(\s*\|\s*Checkov)', '$1 [x] Yes$2'
    }

    # ── Article XI §11.2 — Deploy Stages ────────────────────────────────
    $deployMap2 = @{
        "dev"  = "Deploy Dev"
        "uat"  = "Deploy UAT"
        "pre"  = "Deploy Pre"
        "prod" = "Deploy Prod"
    }
    foreach ($env in $D.DeployPipelineStages) {
        $label = $deployMap2[$env]
        if ($label) {
            $escaped = [regex]::Escape($label)
            $c = $c -replace "(\*\*$escaped\*\*\s*\|)\s*\[ \] Yes", "`$1 [x] Yes"
        }
    }

    # ── Article XII §12.1 — Observability ───────────────────────────────
    $obsMap = @{
        "azure-native" = "Azure-Native"
        "otel-azure"   = "OpenTelemetry → Azure"
        "otel-grafana"  = "OpenTelemetry → Grafana Stack"
    }
    $label = $obsMap[$D.Observability]
    if ($label) { $c = $c -replace "\- \[ \] \*\*$label\*\*", "- [x] **$label**" }

    # ── Article XII §12.3 — Infra Monitoring ────────────────────────────
    $monitorMap = @{
        "resource-health" = "Resource Health"
        "activity-logs"   = "Activity Logs"
        "diagnostics"     = "Diagnostics"
        "alerts"          = "Alerts"
        "dashboards"      = "Dashboards"
    }
    foreach ($mon in $D.InfraMonitoring) {
        $label = $monitorMap[$mon]
        if ($label) {
            $escaped = [regex]::Escape($label)
            $c = $c -replace "($escaped\s*\|[^|]+\|)\s*\[ \] Yes", "`$1 [x] Yes"
        }
    }

    # ── Article XVI §16.1 — Network security ────────────────────────────
    if ($D.VNet)             { $c = $c -replace '\[ \] Azure VNet',             '[x] Azure VNet' }
    else                     { $c = $c -replace '\[ \] None(\s+\|)',            '[x] None$1' }
    if ($D.PrivateEndpoints) { $c = $c -replace '\[ \] Enabled',               '[x] Enabled' }
    else                     { $c = $c -replace '\[ \] Disabled',              '[x] Disabled' }
    if ($D.WAF)              { $c = $c -replace '\[ \] Azure Front Door WAF',  '[x] Azure Front Door WAF' }

    # ── Article XVI §16.2 — Data protection ─────────────────────────────
    switch ($D.EncryptionKeys) {
        "azure-managed"    { $c = $c -replace '\[ \] Azure-managed keys',    '[x] Azure-managed keys' }
        "customer-managed" { $c = $c -replace '\[ \] Customer-managed keys', '[x] Customer-managed keys' }
    }
    switch ($D.PiiHandling) {
        "anonymization"     { $c = $c -replace '\[ \] Anonymization',     '[x] Anonymization' }
        "pseudonymization"  { $c = $c -replace '\[ \] Pseudonymization',  '[x] Pseudonymization' }
        "encryption"        { $c = $c -replace '\[ \] Encryption(?!\s*\|)', '[x] Encryption' }
    }

    # ── Article XVI §16.3 — Compliance ──────────────────────────────────
    foreach ($std in $D.Compliance) {
        if ($std -eq "none") { continue }
        $upper = $std.ToUpper() -replace '-','-'
        # Mark "Yes" for the matching row
        $c = $c -replace "(\|\s*$upper\s+\|)\s*\[ \] Yes", "`$1 [x] Yes"
    }

    Set-Content -Path $path -Value $c -NoNewline -Encoding UTF8
    Write-Success "Constitution prefilled with all base decisions"
}

# ─── Demo content ────────────────────────────────────────────────────────────

function Add-DemoContent {
    $root = $PSScriptRoot
    if ($ProjectType -eq "green") {
        $src = "$root\demo\from_rfp"
        if (Test-Path $src) {
            Copy-Item "$src\*" "$OutputDirectory\origin\" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Info "Greenfield demo copied to origin/"
        }
    } else {
        $src = "$root\demo\from_old_src"
        if (Test-Path $src) {
            Copy-Item "$src\*" "$OutputDirectory\legacy\" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Info "Brownfield demo copied to legacy/"
        }
        if (-not [string]::IsNullOrEmpty($SourceDirectory)) {
            Copy-Item "$SourceDirectory\*" "$OutputDirectory\legacy\" -Recurse -Force
            Write-Info "Legacy source copied from $SourceDirectory"
        }
    }
}

# ─── Python Environment Setup (Optional) ──────────────────────────────────────

function Initialize-PythonEnvironment {
    <#
    .SYNOPSIS
    Optional Python environment setup during initialization

    .DESCRIPTION
    Attempts to configure Python virtual environment (.bolt-venv) for skills
    that require Python (e.g., skill-creator). Non-blocking - project initialization
    continues even if Python setup fails.

    .OUTPUTS
    Returns $true if Python was successfully configured, $false otherwise
    #>

    Write-Host ""
    Write-Step "Setting up Python environment (optional)..."

    $bootstrapScript = Join-Path $OutputDirectory ".boltf\scripts\powershell\Bootstrap-Python.ps1"

    # Check if Bootstrap-Python.ps1 exists
    if (-not (Test-Path $bootstrapScript)) {
        Write-Warn "Python bootstrap script not found (skills/Python features unavailable)"
        Write-Info "Some advanced skills may require Python - you can run bootstrap manually later"
        return $false
    }

    try {
        Write-Info "Checking Python availability..."

        # Execute Bootstrap-Python.ps1 in the target directory
        Push-Location $OutputDirectory
        try {
            & $bootstrapScript -ProjectRoot $OutputDirectory -SkipInstall *>&1 | Out-Null
            $exitCode = $LASTEXITCODE

            if ($exitCode -eq 0) {
                Write-Success "Python environment configured successfully"
                Write-Info "Virtual environment: .bolt-venv/"
                Write-Info "Python-based skills ready (e.g., skill-creator)"
                return $true
            } else {
                Write-Warn "Python setup completed with warnings (exit code: $exitCode)"
                Write-Info "Python features may have limited availability"
                return $false
            }
        } finally {
            Pop-Location
        }
    } catch {
        Write-Warn "Failed to configure Python environment: $($_.Exception.Message)"
        Write-Info "This is optional - you can setup Python later by running:"
        Write-Host "  .boltf\scripts\powershell\Bootstrap-Python.ps1" -ForegroundColor Yellow
        Write-Host ""
        Write-Info "Project initialization will continue without Python features"
        return $false
    }
}

# ─── Summary ─────────────────────────────────────────────────────────────────

function Show-Summary {
    param([hashtable]$D)

    Write-Host ""
    Write-Host "  ┌──────────────────────────────────────────────────────────────┐" -ForegroundColor Green
    Write-Host "  │   Bolt Framework Project Initialized! (Phase 1 of 2)         │" -ForegroundColor Green
    Write-Host "  └──────────────────────────────────────────────────────────────┘" -ForegroundColor Green
    Write-Host ""
    Write-Host "  ✓ Practice:   $($D.Practice)" -ForegroundColor Green
    Write-Host "  ✓ Scopes:     $($D.Scopes -join ', ')" -ForegroundColor Green

    # Python environment status
    if ($D.PythonConfigured) {
        Write-Host "  ✓ Python:     Configured (.bolt-venv/)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Python:     Not configured (optional)" -ForegroundColor Yellow
    }
    if ($D.IaCTool -ne "none") {
        Write-Host "  ✓ IaC Tool:   $($D.IaCTool)" -ForegroundColor Green
    }
    Write-Host "  ✓ Basic constitution created in .boltf/memory/constitution.md" -ForegroundColor Green
    Write-Host "  ✓ Scopes configuration saved to .boltf/scopes.yaml" -ForegroundColor Green
    Write-Host "  ✓ Bolt Framework agents and skills copied to .github/" -ForegroundColor Green
    Write-Host ""
    Write-Host "  ⚠ IMPORTANT: Two-Step Initialization" -ForegroundColor Yellow
    Write-Host "     Phase 1: Init.ps1 (completed) — Basic configuration" -ForegroundColor DarkGray
    Write-Host "     Phase 2: @Bolt Constitution — File provisioning & constitution merge" -ForegroundColor White
    Write-Host ""
    Write-Host "  AUTOMATED SETUP (Phase 2 of 2):" -ForegroundColor Cyan
    Write-Host ""

    # Check if GitHub Copilot CLI is available
    $cliAvailable = Get-Command copilot -ErrorAction SilentlyContinue

    if ($null -ne $cliAvailable) {
        Write-Host "  ✓ GitHub Copilot CLI detected" -ForegroundColor Green
        Write-Host "  🤖 Invoking @Bolt Constitution agent (INTERACTIVE MODE)..." -ForegroundColor Yellow
        Write-Host "  ⚠  You will be prompted to approve each provisioning step" -ForegroundColor Yellow
        Write-Host ""

        try {
            # Change to project directory and invoke agent
            Push-Location $OutputDirectory
            try {
                & copilot --agent="bolt-constitution" --banner --model claude-sonnet-4.5 -i "setup constitution"
                Write-Host ""
                Write-Host "  ✓ @Bolt Constitution agent completed" -ForegroundColor Green
                Write-Host "  📝 Review provision results above" -ForegroundColor Cyan
            }
            finally {
                Pop-Location
            }
        }
        catch {
            Write-Warn "Failed to invoke agent: $_"
            Write-Host "  📝 MANUAL FALLBACK:" -ForegroundColor Yellow
            Write-Host "     1. cd $OutputDirectory" -ForegroundColor White
            Write-Host "     2. Run: copilot" -ForegroundColor White
            Write-Host "     3. Prompt: Use Bolt Constitution agent to setup constitution" -ForegroundColor White
        }
    }
    else {
        Write-Host "  ⚠ GitHub Copilot CLI not detected" -ForegroundColor Yellow
        Write-Host "  📝 MANUAL STEP REQUIRED:" -ForegroundColor Cyan
        Write-Host "     1. cd $OutputDirectory" -ForegroundColor White
        Write-Host "     2. Install GitHub Copilot CLI: gh extension install github/gh-copilot" -ForegroundColor White
        Write-Host "     3. Run: copilot" -ForegroundColor White
        Write-Host "     4. Prompt: Use Bolt Constitution agent to setup constitution" -ForegroundColor White
        Write-Host ""
        Write-Host "  💡 After CLI installation, the agent will auto-invoke on next init" -ForegroundColor DarkGray
    }

    Write-Host ""
    Write-Host "  📚 Documentation:" -ForegroundColor Cyan
    Write-Host "     - README.md — Bolt Framework overview"
    Write-Host "     - .boltf/scopes/README.md — Practice-based initialization guide"
    Write-Host ""
}

# ─── Main ────────────────────────────────────────────────────────────────────

function Main {
    # Show help if requested or if required parameters are missing
    if ($Help) {
        Show-Banner
        Show-Usage
        return
    }

    if ([string]::IsNullOrWhiteSpace($OutputDirectory) -or [string]::IsNullOrWhiteSpace($ProjectType)) {
        Show-Banner
        Write-Err "Missing required parameters"
        Write-Host ""
        Show-Usage
        exit 1
    }

    # Validate ProjectType
    if ($ProjectType -notin @("green", "brown")) {
        Show-Banner
        Write-Err "Invalid ProjectType: '$ProjectType'. Must be 'green' or 'brown'"
        Write-Host ""
        Show-Usage
        exit 1
    }

    # Validate SourceDirectory for brownfield
    if ($ProjectType -eq "brown") {
        if ([string]::IsNullOrWhiteSpace($SourceDirectory)) {
            Show-Banner
            Write-Err "SourceDirectory is required when ProjectType is 'brown'"
            Write-Host ""
            Show-Usage
            exit 1
        }
        if (-not (Test-Path $SourceDirectory)) {
            Show-Banner
            Write-Err "SourceDirectory does not exist: $SourceDirectory"
            Write-Host ""
            Show-Usage
            exit 1
        }
    }

    Show-Banner
    Test-Prerequisites

    # Interactive wizard
    $decisions = Get-AllDecisions

    # Confirm
    Write-Host ""
    Write-Host "  Selected scopes: $($decisions.Scopes -join ', ')" -ForegroundColor White
    if (-not (Read-YesNo "Proceed with these choices?" $true)) {
        Write-Err "Cancelled by user"; exit 0
    }

    # Execute
    New-ProjectStructure -Decisions $decisions
    Copy-BoltFramework
    New-ScopesYaml       -Decisions $decisions
    New-BasicConstitution -D $decisions  # Phase 1: Basic template (NEW)
    Add-DemoContent

    # Optional: Setup Python environment for Python-based skills
    $pythonConfigured = Initialize-PythonEnvironment
    $decisions.PythonConfigured = $pythonConfigured

    Show-Summary -D $decisions
}

Main
