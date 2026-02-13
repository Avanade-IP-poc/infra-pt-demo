# =============================================================================
# AURORA-IA / AI-DLC - Project Initialization Script v1.0.0
# =============================================================================

param(
    [Parameter(Mandatory = $true)]
    [string]$OutputDirectory,

    [Parameter(Mandatory = $true)]
    [ValidateSet("green", "brown")]
    [string]$ProjectType,

    [Parameter(Mandatory = $false)]
    [string]$SourceDirectory = "",

    [Parameter(Mandatory = $false)]
    [ValidateSet("infra-only", "app-only", "full-stack")]
    [string]$Scope = "app-only",

    [Parameter(Mandatory = $false)]
    [ValidateSet("csharp", "nodejs")]
    [string]$Backend = "csharp",

    [Parameter(Mandatory = $false)]
    [ValidateSet("none", "react", "vue", "angular", "blazor")]
    [string]$Frontend = "none",

    [Parameter(Mandatory = $false)]
    [ValidateSet("modular-monolith", "microservices", "monolith", "serverless", "event-driven")]
    [string]$Architecture = "modular-monolith",

    [Parameter(Mandatory = $false)]
    [ValidateSet("landing-zone", "workload", "both")]
    [string]$InfraScope = "workload",

    [Parameter(Mandatory = $false)]
    [ValidateSet("bicep", "terraform", "pulumi")]
    [string]$IaC = "bicep",

    [Parameter(Mandatory = $false)]
    [ValidateSet("yes", "no")]
    [string]$Docker = "yes",

    [Parameter(Mandatory = $false)]
    [ValidateSet("yes", "no")]
    [string]$CQRS = "no",

    [Parameter(Mandatory = $false)]
    [switch]$Help
)

# Configuration variables
$script:BackendVersion = switch ($Backend) {
    "csharp" { ".NET 10" }
    "nodejs" { "22" }
    default { "" }
}

# Color functions for cross-platform compatibility
function Write-Info { param([string]$Message) Write-Host "[INFO] $Message" -ForegroundColor Blue }
function Write-Success { param([string]$Message) Write-Host "[SUCCESS] $Message" -ForegroundColor Green }
function Write-Warning { param([string]$Message) Write-Host "[WARNING] $Message" -ForegroundColor Yellow }
function Write-Error { param([string]$Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }
function Write-Step { param([string]$Message) Write-Host "[STEP] $Message" -ForegroundColor Cyan }

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
║        Avanade AI-Driven Development Framework v1.0.1       ║
║                                                             ║
╚═════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Magenta
}

function Show-Usage {
    Write-Host @"

Usage: ./init.ps1 -OutputDirectory <path> -ProjectType <green|brown> [options]

Parameters:
  -OutputDirectory  : Where to create the project structure
  -ProjectType      : 'green' for Greenfield, 'brown' for Brownfield
  -SourceDirectory  : (Required for brown) Directory with existing code/docs

Options:
  -Scope <scope>         : Project scope (infra-only, app-only, full-stack)
  -Backend <lang>        : Backend language (csharp, nodejs)
  -Frontend <fw>         : Frontend framework (none, react, vue, angular, blazor)
  -Architecture <arch>   : Architecture pattern (modular-monolith, microservices, monolith, serverless, event-driven)
  -InfraScope <scope>    : Infrastructure scope for infra-only (landing-zone, workload, both)
  -IaC <tool>           : Infrastructure as Code tool (bicep, terraform, pulumi)
  -Docker <yes/no>      : Enable Docker support
  -CQRS <yes/no>        : Enable CQRS pattern
  -Help                 : Show this help message

Examples:
  ./init.ps1 -OutputDirectory "C:\projects\my-app" -ProjectType green -Scope app-only -Backend csharp -Architecture modular-monolith
  ./init.ps1 -OutputDirectory "C:\projects\my-app" -ProjectType green -Scope full-stack -Backend nodejs -Frontend react -Docker yes
  ./init.ps1 -OutputDirectory "C:\projects\my-infra" -ProjectType green -Scope infra-only -InfraScope landing-zone -IaC bicep

"@
}

function Test-Prerequisites {
    Write-Step "Checking prerequisites..."

    # Validate brownfield requirements
    if ($ProjectType -eq "brown" -and [string]::IsNullOrEmpty($SourceDirectory)) {
        Write-Error "SourceDirectory is required for brownfield projects"
        Show-Usage
        exit 1
    }

    if ($ProjectType -eq "brown" -and -not (Test-Path $SourceDirectory)) {
        Write-Error "Source directory '$SourceDirectory' does not exist"
        exit 1
    }

    # Ensure output directory doesn't exist
    if (Test-Path $OutputDirectory) {
        Write-Error "Output directory '$OutputDirectory' already exists"
        exit 1
    }

    Write-Success "Prerequisites validated successfully"
}

function New-ProjectStructure {
    Write-Step "Creating project structure..."

    # Create main directory
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null

    # Create basic structure based on scope
    if ($Scope -ne "infra-only") {
        New-Item -ItemType Directory -Path "$OutputDirectory\src\backend" -Force | Out-Null
        Write-Info "Created src\backend\ directory (PROJECT_SCOPE: $Scope)"

        if ($Frontend -ne "none") {
            New-Item -ItemType Directory -Path "$OutputDirectory\src\frontend" -Force | Out-Null
            Write-Info "Created src\frontend\ directory"
        }
    }

    if ($Scope -eq "infra-only" -or $Scope -eq "full-stack") {
        New-Item -ItemType Directory -Path "$OutputDirectory\infra" -Force | Out-Null
        Write-Info "Created infra\ directory"
    }

    # Create project-type specific directories
    if ($ProjectType -eq "green") {
        New-Item -ItemType Directory -Path "$OutputDirectory\origin" -Force | Out-Null
        Write-Info "Created origin\ directory for greenfield project"
    } else {
        New-Item -ItemType Directory -Path "$OutputDirectory\legacy" -Force | Out-Null
        New-Item -ItemType Directory -Path "$OutputDirectory\migration" -Force | Out-Null
        Write-Info "Created legacy\ and migration\ directories for brownfield project"
    }

    Write-Success "Project structure created successfully"
}

function New-ArchitectureStructure {
    if ($Scope -eq "infra-only") { return }

    Write-Step "Generating project structure for $Backend + $Architecture..."

    switch ($Backend) {
        "csharp" {
            switch ($Architecture) {
                "modular-monolith" { New-CSharpModularMonolith }
                "microservices" { New-CSharpMicroservices }
                "monolith" { New-CSharpMonolith }
                "serverless" { New-CSharpServerless }
                "event-driven" { New-CSharpEventDriven }
            }
        }
        "nodejs" {
            switch ($Architecture) {
                "modular-monolith" { New-NodeJSModularMonolith }
                "microservices" { New-NodeJSMicroservices }
                "monolith" { New-NodeJSMonolith }
                "serverless" { New-NodeJSServerless }
                "event-driven" { New-NodeJSEventDriven }
            }
        }
    }

    Write-Success "Project structure generated!"
}

function New-CSharpModularMonolith {
    Write-Info "Creating C# Modular Monolith structure..."

    @(
        "$OutputDirectory\src\backend\Shared\SharedKernel",
        "$OutputDirectory\src\backend\Modules\SampleModule\Domain",
        "$OutputDirectory\src\backend\Modules\SampleModule\Application",
        "$OutputDirectory\src\backend\Modules\SampleModule\Infrastructure",
        "$OutputDirectory\src\backend\Modules\SampleModule\API"
    ) | ForEach-Object { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

function New-CSharpMicroservices {
    Write-Info "Creating C# Microservices structure..."

    @(
        "$OutputDirectory\src\backend\Shared\SharedKernel",
        "$OutputDirectory\src\backend\Services\SampleService\API",
        "$OutputDirectory\src\backend\Services\SampleService\Domain",
        "$OutputDirectory\src\backend\Services\SampleService\Application",
        "$OutputDirectory\src\backend\Services\SampleService\Infrastructure",
        "$OutputDirectory\src\backend\Gateway\ApiGateway"
    ) | ForEach-Object { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

function New-CSharpMonolith {
    Write-Info "Creating C# Monolith structure..."

    @(
        "$OutputDirectory\src\backend\SampleApp.API\Controllers",
        "$OutputDirectory\src\backend\SampleApp.Domain\Entities",
        "$OutputDirectory\src\backend\SampleApp.Application\Services",
        "$OutputDirectory\src\backend\SampleApp.Infrastructure\Data"
    ) | ForEach-Object { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

function New-CSharpServerless {
    Write-Info "Creating C# Serverless structure..."

    @(
        "$OutputDirectory\src\backend\Functions\SampleFunctions",
        "$OutputDirectory\src\backend\Shared\Models",
        "$OutputDirectory\src\backend\Shared\Services"
    ) | ForEach-Object { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

function New-CSharpEventDriven {
    Write-Info "Creating C# Event-Driven structure..."

    @(
        "$OutputDirectory\src\backend\Events\Handlers",
        "$OutputDirectory\src\backend\Events\Publishers",
        "$OutputDirectory\src\backend\Shared\Contracts"
    ) | ForEach-Object { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

function New-NodeJSModularMonolith {
    Write-Info "Creating Node.js Modular Monolith structure..."

    @(
        "$OutputDirectory\src\backend\src\shared\domain",
        "$OutputDirectory\src\backend\src\shared\infrastructure",
        "$OutputDirectory\src\backend\src\modules\sample-module\domain",
        "$OutputDirectory\src\backend\src\modules\sample-module\application",
        "$OutputDirectory\src\backend\src\modules\sample-module\infrastructure",
        "$OutputDirectory\src\backend\src\modules\sample-module\presentation"
    ) | ForEach-Object { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

function New-NodeJSMicroservices {
    Write-Info "Creating Node.js Microservices structure..."

    @(
        "$OutputDirectory\src\backend\shared\contracts",
        "$OutputDirectory\src\backend\shared\utils",
        "$OutputDirectory\src\backend\services\sample-service\src",
        "$OutputDirectory\src\backend\gateway\api-gateway\src"
    ) | ForEach-Object { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

function New-NodeJSMonolith {
    Write-Info "Creating Node.js Monolith structure..."

    @(
        "$OutputDirectory\src\backend\src\controllers",
        "$OutputDirectory\src\backend\src\services",
        "$OutputDirectory\src\backend\src\models",
        "$OutputDirectory\src\backend\src\middleware"
    ) | ForEach-Object { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

function New-NodeJSServerless {
    Write-Info "Creating Node.js Serverless structure..."

    @(
        "$OutputDirectory\src\backend\functions",
        "$OutputDirectory\src\backend\shared"
    ) | ForEach-Object { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

function New-NodeJSEventDriven {
    Write-Info "Creating Node.js Event-Driven structure..."

    @(
        "$OutputDirectory\src\backend\events\handlers",
        "$OutputDirectory\src\backend\events\publishers",
        "$OutputDirectory\src\backend\shared\contracts"
    ) | ForEach-Object { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

function Copy-AuroraFramework {
    Write-Step "Copying complete AURORA-IA framework..."

    $ScriptDir = $PSScriptRoot
    Write-Info "AURORA root detected: $ScriptDir"

    # Copy .github directory
    if (Test-Path "$ScriptDir\.github") {
        Write-Info "Copying complete .github directory..."
        Copy-Item -Path "$ScriptDir\.github" -Destination "$OutputDirectory\.github" -Recurse -Force
        Write-Success "Complete .github directory copied successfully"
    }

    # Copy .aurora directory
    if (Test-Path "$ScriptDir\.aurora") {
        Write-Info "Copying complete .aurora directory..."
        Copy-Item -Path "$ScriptDir\.aurora" -Destination "$OutputDirectory\.aurora" -Recurse -Force
        Write-Success ".aurora directory copied"
    }

    # Copy framework documentation files from .aurora to project root
    Write-Info "Copying AURORA framework documentation..."
    @("README.md", "CHANGELOG.md", "CONTRIBUTING.md", "LICENSE", "PENDIENTES.md") | ForEach-Object {
        if (Test-Path "$ScriptDir\.aurora\$_") {
            Copy-Item -Path "$ScriptDir\.aurora\$_" -Destination "$OutputDirectory\$_" -Force
            Write-Info "$_ copied to project root"
        }
    }

    # Copy additional files from AURORA root
    @("INITIALIZER.md", "USAGE.md") | ForEach-Object {
        if (Test-Path "$ScriptDir\$_") {
            Copy-Item -Path "$ScriptDir\$_" -Destination "$OutputDirectory\$_" -Force
            Write-Info "$_ copied to project root"
        }
    }

    Write-Success "AURORA framework copied successfully"
}

function Copy-LegacySource {
    if ($ProjectType -ne "brown" -or [string]::IsNullOrEmpty($SourceDirectory)) { return }

    Write-Step "Copying legacy source files to legacy\ directory..."
    Copy-Item -Path "$SourceDirectory\*" -Destination "$OutputDirectory\legacy\" -Recurse -Force
    Write-Success "Legacy source copied to legacy\"
}

function Set-ConstitutionConfiguration {
    Write-Step "Customizing constitution.md with your configuration..."

    $constitutionPath = "$OutputDirectory\.aurora\memory\constitution.md"
    if (-not (Test-Path $constitutionPath)) {
        Write-Warning "Constitution.md not found at $constitutionPath"
        return
    }

    $content = Get-Content $constitutionPath -Raw

    # Mark selected options
    switch ($Backend) {
        "csharp" {
            $content = $content -replace '- \[ \] \*\*C# / \.NET\*\*', '- [x] **C# / .NET**'
            $content = $content -replace '  - API Style: \[ \] Minimal APIs', '  - API Style: [x] Minimal APIs'
        }
        "nodejs" {
            $content = $content -replace '- \[ \] \*\*Node\.js / TypeScript\*\*', '- [x] **Node.js / TypeScript**'
        }
    }

    # Mark architecture
    switch ($Architecture) {
        "modular-monolith" {
            $content = $content -replace '- \[ \] \*\*Modular Monolith\*\*', '- [x] **Modular Monolith**'
        }
        "microservices" {
            $content = $content -replace '- \[ \] \*\*Microservices\*\*', '- [x] **Microservices**'
        }
        "monolith" {
            $content = $content -replace '- \[ \] \*\*Traditional Monolith\*\*', '- [x] **Traditional Monolith**'
        }
        "serverless" {
            $content = $content -replace '- \[ \] \*\*Serverless\*\*', '- [x] **Serverless**'
        }
        "event-driven" {
            $content = $content -replace '- \[ \] \*\*Event-Driven\*\*', '- [x] **Event-Driven**'
        }
    }

    # Mark Docker if enabled
    if ($Docker -eq "yes") {
        $content = $content -replace '- \[ \] \*\*Docker\*\*', '- [x] **Docker**'
        $content = $content -replace '- \[ \] \*\*Docker Compose\*\*', '- [x] **Docker Compose**'
    }

    # Mark CQRS if enabled
    if ($CQRS -eq "yes") {
        $content = $content -replace '- \[ \] \*\*CQRS\*\*', '- [x] **CQRS**'
    }

    Set-Content -Path $constitutionPath -Value $content -NoNewline
    Write-Success "Constitution.md customized with your configuration"
}

function Add-DemoContent {
    if ($ProjectType -eq "green") {
        Write-Step "Copying greenfield demo from demo\from_rfp\..."

        $ScriptDir = $PSScriptRoot
        $demoPath = "$ScriptDir\demo\from_rfp"

        if (Test-Path $demoPath) {
            Copy-Item -Path "$demoPath\*" -Destination "$OutputDirectory\origin\" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Success "Greenfield demo content copied from demo\from_rfp\"
        } else {
            Write-Warning "demo\from_rfp\ directory not found"
            "# Place your RFP and initial project documents here" | Set-Content "$OutputDirectory\origin\README.md"
        }
    }
}

function Add-BrownfieldContent {
    if ($ProjectType -ne "brown") { return }

    Write-Step "Copying legacy demo code from demo\from_old_src\..."

    $ScriptDir = $PSScriptRoot
    $demoPath = "$ScriptDir\demo\from_old_src"

    if (Test-Path $demoPath) {
        Copy-Item -Path "$demoPath\*" -Destination "$OutputDirectory\legacy\" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Success "Legacy demo code copied from demo\from_old_src\"
    } else {
        Write-Warning "demo\from_old_src\ directory not found"
        "# Place your legacy source code here for analysis" | Set-Content "$OutputDirectory\legacy\README.md"
    }
}

function Show-NextSteps {
    Write-Info "🚀 NEXT STEPS:"
    Write-Info ""
    Write-Info "📁 1. Navigate to your project:"
    Write-Info "   cd $OutputDirectory"
    Write-Info ""

    if ($ProjectType -eq "green") {
        Write-Info "🌱 GREENFIELD PROJECT SETUP:"
        Write-Info ""
        Write-Info "📋 2. Configure project constitution (MANDATORY FIRST STEP):"
        Write-Info "   - Edit .aurora\memory\constitution.md"
        Write-Info "   - Mark your project scope: 🏗️ Infra-only, 💻 App-only, or 🚀 Full-stack"
        Write-Info "   - Select frontend framework, database, deployment options"
        Write-Info ""
        Write-Info "📖 3. Review demo requirements in origin\:"
        Write-Info "   - RFP-Calculator.md shows example requirements format"
        Write-Info "   - Replace with your actual project requirements"
        Write-Info ""
        Write-Info "🔧 4. Start development:"
        if ($Scope -eq "app-only" -or $Scope -eq "full-stack") {
            if (Test-Path "$OutputDirectory\src\backend") { Write-Info "   - Backend ($Backend): src\backend\" }
            if (Test-Path "$OutputDirectory\src\frontend") { Write-Info "   - Frontend: src\frontend\" }
        }
        if ($Scope -eq "infra-only" -or $Scope -eq "full-stack") {
            Write-Info "   - Infrastructure: infra\"
        }
        Write-Info ""
        Write-Info "🎯 5. Create your first feature:"
        Write-Info "   @Aurora Feature"
    } else {
        Write-Info "🔄 BROWNFIELD MIGRATION SETUP:"
        Write-Info ""
        Write-Info "📋 2. Configure project constitution (MANDATORY FIRST STEP):"
        Write-Info "   - Edit .aurora\memory\constitution.md"
        Write-Info "   - Mark project scope (usually 💻 App-only for migrations)"
        Write-Info "   - Select target architecture: $Architecture"
        Write-Info "   - Choose modern tech stack vs legacy: $Backend"
        Write-Info ""
        Write-Info "🔍 3. Analyze legacy code in legacy\:"
        Write-Info "   - CALCMAIN.cbl & CALCENGN.cbl (demo files)"
        Write-Info "   - Replace with your actual legacy code"
        Write-Info "   - Document current system architecture and business logic"
        Write-Info ""
        Write-Info "📊 4. Create migration strategy:"
        Write-Info "   - Create analysis docs for architecture, dependencies, risks"
        Write-Info "   - Plan migration phases (Big Bang vs Incremental)"
        Write-Info "   - Map COBOL business logic to modern $Backend patterns"
        Write-Info ""
        Write-Info "🔧 5. Start modern development:"
        if ($Scope -eq "app-only" -or $Scope -eq "full-stack") {
            if (Test-Path "$OutputDirectory\src\backend") { Write-Info "   - New backend ($Backend): src\backend\" }
            if (Test-Path "$OutputDirectory\src\frontend") { Write-Info "   - Modern frontend: src\frontend\" }
        }
        Write-Info ""
        Write-Info "🎯 6. Begin migration analysis:"
        Write-Info "   @Aurora Legacy"
    }

    Write-Info ""
    Write-Info "🛠️  Available AURORA tools:"
    Write-Info "   .aurora\scripts\ - Development automation scripts"
    Write-Info "   .github\agents\ - 31 specialized AI agents for different tasks"
    Write-Info "   @AURORA - Main orchestrator agent"
    Write-Info ""
    Write-Info "📚 Need help? Check .aurora\docs\ for guides and documentation"
}

# Main execution
function Main {
    if ($Help) {
        Show-Usage
        return
    }

    Show-Banner

    Write-Info "Initializing AURORA-IA project..."
    Write-Info "  Output Directory: $OutputDirectory"
    if ($ProjectType -eq "green") {
        Write-Info "  Project Type: $ProjectType - Greenfield New Project"
    } else {
        Write-Info "  Project Type: $ProjectType - Brownfield Legacy Migration"
    }
    if ($SourceDirectory) { Write-Info "  Source Directory: $SourceDirectory" }
    Write-Info "Using command-line configuration"

    Test-Prerequisites
    New-ProjectStructure
    New-ArchitectureStructure
    Copy-AuroraFramework
    Copy-LegacySource
    Set-ConstitutionConfiguration
    Add-DemoContent
    Add-BrownfieldContent

    Write-Success "AURORA-IA project initialization completed!"
    Write-Info "Project created in: $OutputDirectory"
    Write-Info ""
    Write-Info "Configuration used:"
    Write-Info "  - Project Scope: $Scope"
    if ($Scope -ne "infra-only") {
        Write-Info "  - Backend Language: $Backend ($script:BackendVersion)"
        Write-Info "  - Architecture: $Architecture"
        if ($CQRS -eq "yes") { Write-Info "  - CQRS: Enabled" }
        if ($Docker -eq "yes") { Write-Info "  - Docker: Enabled" }
    }
    if ($Frontend -ne "none") { Write-Info "  - Frontend Framework: $Frontend" }
    if ($Scope -eq "infra-only" -or $Scope -eq "full-stack") {
        Write-Info "  - Infrastructure Scope: $InfraScope"
        Write-Info "  - IaC Tool: $IaC"
    }
    Write-Info ""

    Show-NextSteps
}

# Run main function
Main
