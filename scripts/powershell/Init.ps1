<#
.SYNOPSIS
    AURORA-IA Project Initializer - Interactive Project Setup Wizard
.DESCRIPTION
    Initializes a new AURORA-IA project structure with interactive configuration wizard.
    Supports Greenfield (new projects) and Brownfield (migration) scenarios.
    
    Auto-profiles available:
    - app-dotnet: .NET 8 modular monolith with CQRS, Azure SQL, Container Apps
    - app-node: Node.js 20 NestJS modular monolith with PostgreSQL, Container Apps
    - infra-landing: Landing Zone infrastructure with Bicep
    - infra-workload: Workload infrastructure with Bicep
    - fullstack-dotnet: Full stack .NET with Bicep infrastructure
.PARAMETER OutputDirectory
    Target directory for the new project
.PARAMETER ProjectType
    Type of project: 'green' for greenfield, 'brown' for brownfield
.PARAMETER SourceDirectory
    Source directory for brownfield migrations
.PARAMETER Auto
    Auto-profile name to skip interactive wizard
.EXAMPLE
    .\Init.ps1 -OutputDirectory "C:\Projects\MyApp"
    .\Init.ps1 -Auto "app-dotnet" -OutputDirectory "C:\Projects\MyApi"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$OutputDirectory = (Join-Path (Get-Location) "aurora-project"),

    [Parameter(Mandatory = $false)]
    [ValidateSet("green", "brown")]
    [string]$ProjectType = "green",

    [Parameter(Mandatory = $false)]
    [string]$SourceDirectory,

    [Parameter(Mandatory = $false)]
    [ValidateSet("app-dotnet", "app-node", "infra-landing", "infra-workload", "fullstack-dotnet")]
    [string]$Auto
)

# =============================================================================
# SCRIPT CONFIGURATION
# =============================================================================
$ErrorActionPreference = "Stop"
$SCRIPT_VERSION = "2.1.0"

# Configuration variables (will be set by wizard or auto-profile)
$script:PROJECT_SCOPE = "app-only"
$script:INFRA_SCOPE = "workload"
$script:BACKEND_LANGUAGE = "csharp"
$script:BACKEND_VERSION = "dotnet8"
$script:BACKEND_FRAMEWORK = "minimal-api"
$script:ARCHITECTURE = "modular-monolith"
$script:CQRS_ENABLED = "true"
$script:FRONTEND_FRAMEWORK = "none"
$script:DATABASE = "azure-sql"
$script:DATA_ACCESS = "ef-core"
$script:DOCKER_ENABLED = "true"
$script:ORCHESTRATION = "container-apps"
$script:IAC_TOOL = "bicep"
$script:CICD_PLATFORM = "github-actions"
$script:OBSERVABILITY = "azure-native"
$script:ENVIRONMENTS = "dev,staging,prod"
$script:AUTO_MODE = $false
$script:AUTO_PROFILE = ""

# =============================================================================
# OUTPUT FUNCTIONS
# =============================================================================
function Write-Color {
    param([string]$Text, [string]$Color = "White")
    $colorMap = @{
        "Red" = "Red"; "Green" = "Green"; "Yellow" = "Yellow"
        "Blue" = "Blue"; "Magenta" = "Magenta"; "Cyan" = "Cyan"; "White" = "White"
    }
    Write-Host $Text -ForegroundColor $colorMap[$Color]
}

function Log-Info { param([string]$msg) Write-Color "[INFO] $msg" Blue }
function Log-Success { param([string]$msg) Write-Color "[OK] $msg" Green }
function Log-Warning { param([string]$msg) Write-Color "[WARN] $msg" Yellow }
function Log-Error { param([string]$msg) Write-Color "[ERROR] $msg" Red }
function Log-Step { param([string]$msg) Write-Color "[STEP] $msg" Cyan }

# =============================================================================
# INTERACTIVE MENU FUNCTIONS
# =============================================================================
function Select-Option {
    param([string]$Prompt, [string[]]$Options)
    
    Write-Host ""
    Write-Host $Prompt -ForegroundColor Cyan
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host "  [$i] $($Options[$i])"
    }
    
    do {
        $selection = Read-Host "Enter selection (0-$($Options.Count - 1))"
        $num = $selection -as [int]
    } while ($null -eq $num -or $num -lt 0 -or $num -ge $Options.Count)
    
    return $num
}

function Ask-YesNo {
    param([string]$Prompt, [bool]$Default = $true)
    
    $defaultStr = if ($Default) { "Y/n" } else { "y/N" }
    $response = Read-Host "$Prompt [$defaultStr]"
    
    if ([string]::IsNullOrWhiteSpace($response)) { return $Default }
    return $response -match "^[Yy]"
}

function Multi-Select {
    param([string]$Prompt, [string[]]$Options, [int[]]$Defaults = @())
    
    Write-Host ""
    Write-Host $Prompt -ForegroundColor Cyan
    for ($i = 0; $i -lt $Options.Count; $i++) {
        $marker = if ($Defaults -contains $i) { "[x]" } else { "[ ]" }
        Write-Host "  $marker [$i] $($Options[$i])"
    }
    
    $input = Read-Host "Enter selections (comma-separated, e.g., 0,2,3)"
    if ([string]::IsNullOrWhiteSpace($input)) { return $Defaults }
    
    return ($input -split ',' | ForEach-Object { $_.Trim() -as [int] } | Where-Object { $_ -ne $null })
}

# =============================================================================
# AUTO-PROFILE CONFIGURATION
# =============================================================================
function Apply-AutoProfile {
    param([string]$Profile)
    
    Log-Info "Applying auto-profile: $Profile"
    
    switch ($Profile) {
        "app-dotnet" {
            $script:PROJECT_SCOPE = "app-only"
            $script:BACKEND_LANGUAGE = "csharp"
            $script:BACKEND_VERSION = "dotnet8"
            $script:BACKEND_FRAMEWORK = "minimal-api"
            $script:ARCHITECTURE = "modular-monolith"
            $script:CQRS_ENABLED = "true"
            $script:FRONTEND_FRAMEWORK = "none"
            $script:DATABASE = "azure-sql"
            $script:DATA_ACCESS = "ef-core"
            $script:DOCKER_ENABLED = "true"
            $script:ORCHESTRATION = "container-apps"
            $script:CICD_PLATFORM = "github-actions"
            $script:OBSERVABILITY = "azure-native"
        }
        "app-node" {
            $script:PROJECT_SCOPE = "app-only"
            $script:BACKEND_LANGUAGE = "nodejs"
            $script:BACKEND_VERSION = "node20"
            $script:BACKEND_FRAMEWORK = "nestjs"
            $script:ARCHITECTURE = "modular-monolith"
            $script:CQRS_ENABLED = "true"
            $script:FRONTEND_FRAMEWORK = "none"
            $script:DATABASE = "postgresql"
            $script:DATA_ACCESS = "prisma"
            $script:DOCKER_ENABLED = "true"
            $script:ORCHESTRATION = "container-apps"
            $script:CICD_PLATFORM = "github-actions"
            $script:OBSERVABILITY = "azure-native"
        }
        "infra-landing" {
            $script:PROJECT_SCOPE = "infra-only"
            $script:INFRA_SCOPE = "landing-zone"
            $script:IAC_TOOL = "bicep"
            $script:CICD_PLATFORM = "github-actions"
        }
        "infra-workload" {
            $script:PROJECT_SCOPE = "infra-only"
            $script:INFRA_SCOPE = "workload"
            $script:IAC_TOOL = "bicep"
            $script:CICD_PLATFORM = "github-actions"
        }
        "fullstack-dotnet" {
            $script:PROJECT_SCOPE = "full-stack"
            $script:INFRA_SCOPE = "workload"
            $script:BACKEND_LANGUAGE = "csharp"
            $script:BACKEND_VERSION = "dotnet8"
            $script:BACKEND_FRAMEWORK = "minimal-api"
            $script:ARCHITECTURE = "modular-monolith"
            $script:CQRS_ENABLED = "true"
            $script:FRONTEND_FRAMEWORK = "vue"
            $script:DATABASE = "azure-sql"
            $script:DATA_ACCESS = "ef-core"
            $script:DOCKER_ENABLED = "true"
            $script:ORCHESTRATION = "container-apps"
            $script:IAC_TOOL = "bicep"
            $script:CICD_PLATFORM = "github-actions"
            $script:OBSERVABILITY = "azure-native"
        }
    }
    
    Log-Success "Auto-profile '$Profile' applied"
}

# =============================================================================
# CONFIGURATION WIZARD
# =============================================================================
function Run-ConfigurationWizard {
    Write-Host ""
    Write-Color "===============================================================================" Cyan
    Write-Color "                    AURORA-IA Configuration Wizard                             " Cyan
    Write-Color "===============================================================================" Cyan
    Write-Host ""

    # 1/10: Project Scope
    Write-Color "  1/10: PROJECT SCOPE" Yellow
    Write-Color "-------------------------------------------------------------------------------" Yellow
    $scope = Select-Option "What type of project are you building?" @(
        "Infrastructure Only (Landing Zone or Workload)",
        "Application Development Only (code on existing infra)",
        "Full Stack (App + Infrastructure)"
    )
    switch ($scope) {
        0 { $script:PROJECT_SCOPE = "infra-only" }
        1 { $script:PROJECT_SCOPE = "app-only" }
        2 { $script:PROJECT_SCOPE = "full-stack" }
    }

    # Infrastructure scope (if applicable)
    if ($script:PROJECT_SCOPE -in @("infra-only", "full-stack")) {
        $infraScope = Select-Option "Select infrastructure scope:" @(
            "Landing Zone (platform/foundation)",
            "Workload Infrastructure (application resources)",
            "Both - Landing Zone + Workload"
        )
        switch ($infraScope) {
            0 { $script:INFRA_SCOPE = "landing-zone" }
            1 { $script:INFRA_SCOPE = "workload" }
            2 { $script:INFRA_SCOPE = "both" }
        }
    }

    # Application configuration (if applicable)
    if ($script:PROJECT_SCOPE -in @("app-only", "full-stack")) {
        # Backend Language
        Write-Host ""
        Write-Color "  2/10: BACKEND TECHNOLOGY" Yellow
        Write-Color "-------------------------------------------------------------------------------" Yellow
        $backend = Select-Option "Select backend language:" @("C# / .NET", "Node.js / TypeScript")
        
        if ($backend -eq 0) {
            $script:BACKEND_LANGUAGE = "csharp"
            $ver = Select-Option "Select .NET version:" @(".NET 8 (LTS)", ".NET 10")
            $script:BACKEND_VERSION = if ($ver -eq 0) { "dotnet8" } else { "dotnet10" }
            
            $api = Select-Option "Select API style:" @("Minimal APIs", "Controllers/MVC", "Azure Functions")
            switch ($api) {
                0 { $script:BACKEND_FRAMEWORK = "minimal-api" }
                1 { $script:BACKEND_FRAMEWORK = "controllers" }
                2 { $script:BACKEND_FRAMEWORK = "azure-functions" }
            }
        } else {
            $script:BACKEND_LANGUAGE = "nodejs"
            $ver = Select-Option "Select Node.js version:" @("Node.js 20 LTS", "Node.js 22")
            $script:BACKEND_VERSION = if ($ver -eq 0) { "node20" } else { "node22" }
            
            $fw = Select-Option "Select framework:" @("Express", "Fastify", "NestJS", "Azure Functions")
            switch ($fw) {
                0 { $script:BACKEND_FRAMEWORK = "express" }
                1 { $script:BACKEND_FRAMEWORK = "fastify" }
                2 { $script:BACKEND_FRAMEWORK = "nestjs" }
                3 { $script:BACKEND_FRAMEWORK = "azure-functions" }
            }
        }

        # Architecture
        Write-Host ""
        Write-Color "  3/10: ARCHITECTURE STYLE" Yellow
        Write-Color "-------------------------------------------------------------------------------" Yellow
        $arch = Select-Option "Select architecture style:" @(
            "Modular Monolith",
            "Microservices",
            "Traditional Monolith",
            "Serverless",
            "Event-Driven / CQRS+ES"
        )
        switch ($arch) {
            0 { $script:ARCHITECTURE = "modular-monolith" }
            1 { $script:ARCHITECTURE = "microservices" }
            2 { $script:ARCHITECTURE = "monolith" }
            3 { $script:ARCHITECTURE = "serverless" }
            4 { $script:ARCHITECTURE = "event-driven" }
        }

        # CQRS
        Write-Host ""
        Write-Color "  4/10: CQRS PATTERN" Yellow
        Write-Color "-------------------------------------------------------------------------------" Yellow
        $script:CQRS_ENABLED = if (Ask-YesNo "Enable CQRS pattern?" $true) { "true" } else { "false" }

        # Frontend
        Write-Host ""
        Write-Color "  5/10: FRONTEND" Yellow
        Write-Color "-------------------------------------------------------------------------------" Yellow
        $fe = Select-Option "Select frontend framework:" @("None (API only)", "Vue.js", "React", "Angular", "Blazor")
        switch ($fe) {
            0 { $script:FRONTEND_FRAMEWORK = "none" }
            1 { $script:FRONTEND_FRAMEWORK = "vue" }
            2 { $script:FRONTEND_FRAMEWORK = "react" }
            3 { $script:FRONTEND_FRAMEWORK = "angular" }
            4 { $script:FRONTEND_FRAMEWORK = "blazor" }
        }

        # Database
        Write-Host ""
        Write-Color "  6/10: DATABASE" Yellow
        Write-Color "-------------------------------------------------------------------------------" Yellow
        $db = Select-Option "Select primary database:" @("Azure SQL Database", "PostgreSQL", "Azure Cosmos DB", "MongoDB")
        switch ($db) {
            0 { $script:DATABASE = "azure-sql" }
            1 { $script:DATABASE = "postgresql" }
            2 { $script:DATABASE = "cosmos-db" }
            3 { $script:DATABASE = "mongodb" }
        }

        # Data Access
        if ($script:BACKEND_LANGUAGE -eq "csharp") {
            $da = Select-Option "Select data access pattern:" @("Entity Framework Core", "Dapper", "EF Core + Dapper")
            switch ($da) {
                0 { $script:DATA_ACCESS = "ef-core" }
                1 { $script:DATA_ACCESS = "dapper" }
                2 { $script:DATA_ACCESS = "ef-dapper" }
            }
        } else {
            $da = Select-Option "Select data access pattern:" @("Prisma", "TypeORM", "Drizzle", "Knex.js")
            switch ($da) {
                0 { $script:DATA_ACCESS = "prisma" }
                1 { $script:DATA_ACCESS = "typeorm" }
                2 { $script:DATA_ACCESS = "drizzle" }
                3 { $script:DATA_ACCESS = "knex" }
            }
        }

        # Containers
        Write-Host ""
        Write-Color "  7/10: CONTAINERS & ORCHESTRATION" Yellow
        Write-Color "-------------------------------------------------------------------------------" Yellow
        $script:DOCKER_ENABLED = if (Ask-YesNo "Enable Docker containerization?" $true) { "true" } else { "false" }
        
        if ($script:DOCKER_ENABLED -eq "true") {
            $orch = Select-Option "Select orchestration platform:" @("Azure Container Apps", "Azure Kubernetes Service", "Azure App Service")
            switch ($orch) {
                0 { $script:ORCHESTRATION = "container-apps" }
                1 { $script:ORCHESTRATION = "aks" }
                2 { $script:ORCHESTRATION = "app-service" }
            }
        }
    }

    # IaC Tool (if infrastructure)
    if ($script:PROJECT_SCOPE -in @("infra-only", "full-stack")) {
        Write-Host ""
        Write-Color "  8/10: INFRASTRUCTURE AS CODE" Yellow
        Write-Color "-------------------------------------------------------------------------------" Yellow
        $iac = Select-Option "Select IaC tool:" @("Bicep (Azure-native)", "Terraform", "Pulumi")
        switch ($iac) {
            0 { $script:IAC_TOOL = "bicep" }
            1 { $script:IAC_TOOL = "terraform" }
            2 { $script:IAC_TOOL = "pulumi" }
        }
    }

    # CI/CD
    Write-Host ""
    Write-Color "  9/10: CI/CD PLATFORM" Yellow
    Write-Color "-------------------------------------------------------------------------------" Yellow
    $cicd = Select-Option "Select CI/CD platform:" @("GitHub Actions", "Azure DevOps Pipelines")
    $script:CICD_PLATFORM = if ($cicd -eq 0) { "github-actions" } else { "azure-devops" }

    # Environments
    Write-Host ""
    Write-Color "  10/10: ENVIRONMENTS" Yellow
    Write-Color "-------------------------------------------------------------------------------" Yellow
    $envInput = Read-Host "Enter environments (comma-separated) [dev,staging,prod]"
    if (-not [string]::IsNullOrWhiteSpace($envInput)) {
        $script:ENVIRONMENTS = $envInput
    }

    Log-Success "Configuration wizard completed!"
}

# =============================================================================
# BANNER
# =============================================================================
function Print-Banner {
    $banner = @"

    ___   __  ______  ____  ____  ___       _________ 
   /   | / / / / __ \/ __ \/ __ \/   |     /  _/   _/
  / /| |/ / / / /_/ / / / / /_/ / /| |     / // /| | 
 / ___ / /_/ / _, _/ /_/ / _, _/ ___ |   _/ // ___ | 
/_/  |_\____/_/ |_|\____/_/ |_/_/  |_|  /___/_/  |_| 
                                                      
         AI-Driven Lifecycle v$SCRIPT_VERSION
"@
    Write-Color $banner Magenta
}

# =============================================================================
# C# STRUCTURE GENERATORS
# =============================================================================
function Generate-CSharpModularMonolith {
    Log-Info "Generating C# Modular Monolith structure..."
    
    # Shared Kernel with CQRS
    @(
        "src/Shared/SharedKernel/CQRS",
        "src/Shared/SharedKernel/Domain",
        "src/Shared/SharedKernel/Results",
        "src/Shared/Contracts/IntegrationEvents"
    ) | ForEach-Object { 
        New-Item -ItemType Directory -Path (Join-Path $OutputDirectory $_) -Force | Out-Null 
    }
    
    # Sample module structure
    @(
        "src/Modules/SampleModule/SampleModule.Domain/Entities",
        "src/Modules/SampleModule/SampleModule.Domain/ValueObjects",
        "src/Modules/SampleModule/SampleModule.Domain/Events",
        "src/Modules/SampleModule/SampleModule.Domain/Repositories",
        "src/Modules/SampleModule/SampleModule.Application/Commands",
        "src/Modules/SampleModule/SampleModule.Application/Queries",
        "src/Modules/SampleModule/SampleModule.Application/EventHandlers",
        "src/Modules/SampleModule/SampleModule.Infrastructure/Persistence",
        "src/Modules/SampleModule/SampleModule.Infrastructure/Persistence/Configurations",
        "src/Modules/SampleModule/SampleModule.Api/Endpoints"
    ) | ForEach-Object { 
        New-Item -ItemType Directory -Path (Join-Path $OutputDirectory $_) -Force | Out-Null 
    }
    
    # API Host (composition root)
    New-Item -ItemType Directory -Path (Join-Path $OutputDirectory "src/Api.Host") -Force | Out-Null
    
    # Tests
    @(
        "tests/SampleModule.UnitTests/Domain",
        "tests/SampleModule.UnitTests/Application",
        "tests/SampleModule.IntegrationTests",
        "tests/Architecture.Tests",
        "tests/Common.Tests/Fixtures",
        "tests/Common.Tests/Builders"
    ) | ForEach-Object { 
        New-Item -ItemType Directory -Path (Join-Path $OutputDirectory $_) -Force | Out-Null 
    }
    
    # Generate CQRS interfaces if enabled
    if ($script:CQRS_ENABLED -eq "true") {
        Generate-CSharpCqrsInterfaces
    }
}

function Generate-CSharpMicroservices {
    Log-Info "Generating C# Microservices structure..."
    
    # Building Blocks
    @(
        "src/BuildingBlocks/SharedKernel/CQRS",
        "src/BuildingBlocks/SharedKernel/Domain",
        "src/BuildingBlocks/EventBus",
        "src/BuildingBlocks/ServiceDiscovery"
    ) | ForEach-Object { 
        New-Item -ItemType Directory -Path (Join-Path $OutputDirectory $_) -Force | Out-Null 
    }
    
    # API Gateway
    New-Item -ItemType Directory -Path (Join-Path $OutputDirectory "src/ApiGateway") -Force | Out-Null
    
    # Sample Service
    @(
        "src/Services/SampleService/SampleService.Api",
        "src/Services/SampleService/SampleService.Domain/Entities",
        "src/Services/SampleService/SampleService.Domain/ValueObjects",
        "src/Services/SampleService/SampleService.Application/Commands",
        "src/Services/SampleService/SampleService.Application/Queries",
        "src/Services/SampleService/SampleService.Infrastructure/Persistence"
    ) | ForEach-Object { 
        New-Item -ItemType Directory -Path (Join-Path $OutputDirectory $_) -Force | Out-Null 
    }
    
    # Tests
    @(
        "tests/SampleService.UnitTests",
        "tests/SampleService.IntegrationTests",
        "tests/Architecture.Tests"
    ) | ForEach-Object { 
        New-Item -ItemType Directory -Path (Join-Path $OutputDirectory $_) -Force | Out-Null 
    }
    
    # Docker compose for local dev
    New-Item -ItemType File -Path (Join-Path $OutputDirectory "docker-compose.yml") -Force | Out-Null
    New-Item -ItemType File -Path (Join-Path $OutputDirectory "docker-compose.override.yml") -Force | Out-Null
    
    if ($script:CQRS_ENABLED -eq "true") {
        Generate-CSharpCqrsInterfaces "src/BuildingBlocks/SharedKernel/CQRS"
    }
}

function Generate-CSharpMonolith {
    Log-Info "Generating C# Traditional Monolith structure..."
    
    @(
        "src/Domain/Entities",
        "src/Domain/ValueObjects",
        "src/Domain/Events",
        "src/Domain/Services",
        "src/Application/UseCases",
        "src/Application/DTOs",
        "src/Application/Interfaces",
        "src/Infrastructure/Persistence",
        "src/Infrastructure/External",
        "src/Presentation/Api",
        "tests/Unit",
        "tests/Integration",
        "tests/E2E"
    ) | ForEach-Object { 
        New-Item -ItemType Directory -Path (Join-Path $OutputDirectory $_) -Force | Out-Null 
    }
}

function Generate-CSharpServerless {
    Log-Info "Generating C# Serverless (Azure Functions) structure..."
    
    @(
        "src/Functions/HttpTriggers",
        "src/Functions/QueueTriggers",
        "src/Functions/TimerTriggers",
        "src/Core/Domain",
        "src/Core/Application",
        "src/Core/Infrastructure",
        "tests/Functions.UnitTests",
        "tests/Functions.IntegrationTests"
    ) | ForEach-Object { 
        New-Item -ItemType Directory -Path (Join-Path $OutputDirectory $_) -Force | Out-Null 
    }
}

function Generate-CSharpCqrsInterfaces {
    param([string]$TargetDir = "src/Shared/SharedKernel/CQRS")
    
    Log-Info "Generating native CQRS interfaces (NO MediatR)..."
    
    $interfacesPath = Join-Path $OutputDirectory $TargetDir
    New-Item -ItemType Directory -Path $interfacesPath -Force | Out-Null
    
    # ICommand.cs
    @"
namespace SharedKernel.CQRS;

/// <summary>
/// Marker interface for commands (write operations)
/// </summary>
public interface ICommand { }

/// <summary>
/// Command handler without result
/// </summary>
public interface ICommandHandler<in TCommand> where TCommand : ICommand
{
    Task HandleAsync(TCommand command, CancellationToken ct = default);
}

/// <summary>
/// Command handler with result
/// </summary>
public interface ICommandHandler<in TCommand, TResult> where TCommand : ICommand
{
    Task<TResult> HandleAsync(TCommand command, CancellationToken ct = default);
}
"@ | Out-File -FilePath (Join-Path $interfacesPath "ICommand.cs") -Encoding utf8
    
    # IQuery.cs
    @"
namespace SharedKernel.CQRS;

/// <summary>
/// Marker interface for queries (read operations)
/// </summary>
public interface IQuery<TResult> { }

/// <summary>
/// Query handler
/// </summary>
public interface IQueryHandler<in TQuery, TResult> where TQuery : IQuery<TResult>
{
    Task<TResult> HandleAsync(TQuery query, CancellationToken ct = default);
}
"@ | Out-File -FilePath (Join-Path $interfacesPath "IQuery.cs") -Encoding utf8
    
    # IDispatcher.cs
    @"
namespace SharedKernel.CQRS;

/// <summary>
/// Command dispatcher - resolves and executes command handlers via DI
/// </summary>
public interface ICommandDispatcher
{
    Task DispatchAsync<TCommand>(TCommand command, CancellationToken ct = default) 
        where TCommand : ICommand;
    
    Task<TResult> DispatchAsync<TCommand, TResult>(TCommand command, CancellationToken ct = default) 
        where TCommand : ICommand;
}

/// <summary>
/// Query dispatcher - resolves and executes query handlers via DI
/// </summary>
public interface IQueryDispatcher
{
    Task<TResult> DispatchAsync<TQuery, TResult>(TQuery query, CancellationToken ct = default) 
        where TQuery : IQuery<TResult>;
}
"@ | Out-File -FilePath (Join-Path $interfacesPath "IDispatcher.cs") -Encoding utf8
    
    # IDomainEvent.cs
    @"
namespace SharedKernel.CQRS;

/// <summary>
/// Domain event base interface
/// </summary>
public interface IDomainEvent
{
    Guid EventId { get; }
    DateTime OccurredOn { get; }
}

/// <summary>
/// Domain event handler
/// </summary>
public interface IDomainEventHandler<in TEvent> where TEvent : IDomainEvent
{
    Task HandleAsync(TEvent domainEvent, CancellationToken ct = default);
}

/// <summary>
/// Event dispatcher for publishing domain events
/// </summary>
public interface IEventDispatcher
{
    Task PublishAsync<TEvent>(TEvent domainEvent, CancellationToken ct = default) 
        where TEvent : IDomainEvent;
}
"@ | Out-File -FilePath (Join-Path $interfacesPath "IDomainEvent.cs") -Encoding utf8
}

function Generate-DotNetSolutionFiles {
    Log-Info "Generating .NET solution files..."
    
    $projectName = Split-Path -Leaf $OutputDirectory
    
    # Directory.Build.props
    @"
<Project>
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
  </PropertyGroup>
</Project>
"@ | Out-File -FilePath (Join-Path $OutputDirectory "Directory.Build.props") -Encoding utf8
    
    # global.json
    @"
{
  "sdk": {
    "version": "8.0.0",
    "rollForward": "latestMinor"
  }
}
"@ | Out-File -FilePath (Join-Path $OutputDirectory "global.json") -Encoding utf8
    
    # .editorconfig
    @"
root = true

[*]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.cs]
dotnet_sort_system_directives_first = true
csharp_new_line_before_open_brace = all
"@ | Out-File -FilePath (Join-Path $OutputDirectory ".editorconfig") -Encoding utf8
}

# =============================================================================
# NODE.JS STRUCTURE GENERATORS
# =============================================================================
function Generate-NodeJsModularMonolith {
    Log-Info "Generating Node.js Modular Monolith structure..."
    
    @(
        "src/shared/domain/common",
        "src/shared/domain/events",
        "src/shared/application/behaviors",
        "src/shared/application/interfaces",
        "src/shared/infrastructure/persistence",
        "src/modules/sample-module/domain/entities",
        "src/modules/sample-module/domain/value-objects",
        "src/modules/sample-module/domain/events",
        "src/modules/sample-module/application/commands",
        "src/modules/sample-module/application/queries",
        "src/modules/sample-module/application/dtos",
        "src/modules/sample-module/infrastructure/persistence",
        "src/modules/sample-module/infrastructure/repositories",
        "src/modules/sample-module/api/controllers",
        "src/modules/sample-module/api/routes",
        "src/api-host/config",
        "src/api-host/middleware",
        "tests/unit/shared",
        "tests/unit/modules/sample-module",
        "tests/integration/api",
        "tests/e2e"
    ) | ForEach-Object { 
        New-Item -ItemType Directory -Path (Join-Path $OutputDirectory $_) -Force | Out-Null 
    }
}

function Generate-NodeJsMicroservices {
    Log-Info "Generating Node.js Microservices structure..."
    
    @(
        "packages/shared-contracts/events",
        "packages/shared-contracts/messages",
        "packages/shared-libs/domain",
        "packages/shared-libs/application"
    ) | ForEach-Object { 
        New-Item -ItemType Directory -Path (Join-Path $OutputDirectory $_) -Force | Out-Null 
    }
    
    @("sample-service", "another-service") | ForEach-Object {
        $svc = $_
        @(
            "services/$svc/src/domain",
            "services/$svc/src/application",
            "services/$svc/src/infrastructure",
            "services/$svc/src/api",
            "services/$svc/tests"
        ) | ForEach-Object { 
            New-Item -ItemType Directory -Path (Join-Path $OutputDirectory $_) -Force | Out-Null 
        }
    }
    
    New-Item -ItemType Directory -Path (Join-Path $OutputDirectory "gateway") -Force | Out-Null
}

function Generate-NodeJsMonolith {
    Log-Info "Generating Node.js Traditional Monolith structure..."
    
    @(
        "src/domain/entities",
        "src/domain/interfaces",
        "src/application/services",
        "src/application/dtos",
        "src/infrastructure/persistence",
        "src/infrastructure/repositories",
        "src/api/controllers",
        "src/api/routes",
        "src/api/middleware",
        "tests/unit",
        "tests/integration"
    ) | ForEach-Object { 
        New-Item -ItemType Directory -Path (Join-Path $OutputDirectory $_) -Force | Out-Null 
    }
}

function Generate-NodeJsServerless {
    Log-Info "Generating Node.js Serverless structure..."
    
    @(
        "src/functions/http",
        "src/functions/timer",
        "src/functions/queue",
        "src/shared/models",
        "src/shared/services",
        "tests/unit",
        "tests/integration"
    ) | ForEach-Object { 
        New-Item -ItemType Directory -Path (Join-Path $OutputDirectory $_) -Force | Out-Null 
    }
}

function Generate-NodeJsCqrsInterfaces {
    Log-Info "Generating Node.js CQRS interfaces..."
    
    $interfacesPath = Join-Path $OutputDirectory "src/shared/application/interfaces"
    New-Item -ItemType Directory -Path $interfacesPath -Force | Out-Null
    
    @"
export interface ICommand<TResult = void> {
  readonly type: string;
}

export interface IQuery<TResult> {
  readonly type: string;
}

export interface ICommandHandler<TCommand extends ICommand<TResult>, TResult = void> {
  handle(command: TCommand): Promise<TResult>;
}

export interface IQueryHandler<TQuery extends IQuery<TResult>, TResult> {
  handle(query: TQuery): Promise<TResult>;
}
"@ | Out-File -FilePath (Join-Path $interfacesPath "cqrs.ts") -Encoding utf8
}

function Generate-NodeJsConfigFiles {
    Log-Info "Generating Node.js config files..."
    
    # package.json
    @"
{
  "name": "$(Split-Path -Leaf $OutputDirectory)",
  "version": "1.0.0",
  "description": "Generated by AURORA-IA",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "ts-node-dev src/index.ts",
    "test": "jest",
    "lint": "eslint src --ext .ts"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.0.0",
    "ts-node-dev": "^2.0.0",
    "jest": "^29.0.0",
    "@types/jest": "^29.0.0",
    "eslint": "^8.0.0"
  }
}
"@ | Out-File -FilePath (Join-Path $OutputDirectory "package.json") -Encoding utf8
    
    # tsconfig.json
    @"
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
"@ | Out-File -FilePath (Join-Path $OutputDirectory "tsconfig.json") -Encoding utf8
}

# =============================================================================
# INFRASTRUCTURE GENERATORS
# =============================================================================
function Generate-InfrastructureOnlyStructure {
    Log-Info "Generating infrastructure-only structure..."
    
    @(
        "infra/modules",
        "infra/environments",
        "docs/architecture",
        "docs/runbooks",
        "pipelines",
        "tests/validation",
        "scripts"
    ) | ForEach-Object { 
        New-Item -ItemType Directory -Path (Join-Path $OutputDirectory $_) -Force | Out-Null 
    }
}

function Generate-LandingZoneStructure {
    Log-Info "Generating Landing Zone structure..."
    
    if ($script:IAC_TOOL -eq "bicep") {
        @(
            "infra/landing-zone/modules/management-groups",
            "infra/landing-zone/modules/policy-definitions",
            "infra/landing-zone/modules/policy-assignments",
            "infra/landing-zone/modules/rbac",
            "infra/landing-zone/modules/networking/hub",
            "infra/landing-zone/modules/networking/dns",
            "infra/landing-zone/modules/security/defender",
            "infra/landing-zone/modules/security/sentinel",
            "infra/landing-zone/modules/monitoring/log-analytics",
            "infra/landing-zone/modules/identity",
            "infra/landing-zone/environments"
        ) | ForEach-Object { 
            New-Item -ItemType Directory -Path (Join-Path $OutputDirectory $_) -Force | Out-Null 
        }
        
        # Create main.bicep placeholder
        New-Item -ItemType File -Path (Join-Path $OutputDirectory "infra/landing-zone/main.bicep") -Force | Out-Null
    } else {
        @(
            "infra/landing-zone/modules",
            "infra/landing-zone/environments"
        ) | ForEach-Object { 
            New-Item -ItemType Directory -Path (Join-Path $OutputDirectory $_) -Force | Out-Null 
        }
    }
}

function Generate-WorkloadInfraStructure {
    Log-Info "Generating Workload Infrastructure structure..."
    
    if ($script:IAC_TOOL -eq "bicep") {
        @(
            "infra/bicep/modules/compute",
            "infra/bicep/modules/storage",
            "infra/bicep/modules/networking",
            "infra/bicep/modules/security",
            "infra/bicep/modules/monitoring",
            "infra/bicep/environments"
        ) | ForEach-Object { 
            New-Item -ItemType Directory -Path (Join-Path $OutputDirectory $_) -Force | Out-Null 
        }
        
        New-Item -ItemType File -Path (Join-Path $OutputDirectory "infra/bicep/main.bicep") -Force | Out-Null
        New-Item -ItemType File -Path (Join-Path $OutputDirectory "infra/bicep/parameters.bicepparam") -Force | Out-Null
    }
    
    if ($script:IAC_TOOL -eq "terraform") {
        @(
            "infra/terraform/modules",
            "infra/terraform/environments"
        ) | ForEach-Object { 
            New-Item -ItemType Directory -Path (Join-Path $OutputDirectory $_) -Force | Out-Null 
        }
        
        @("main.tf", "variables.tf", "outputs.tf", "providers.tf") | ForEach-Object {
            New-Item -ItemType File -Path (Join-Path $OutputDirectory "infra/terraform/$_") -Force | Out-Null
        }
        
        $script:ENVIRONMENTS -split ',' | ForEach-Object {
            New-Item -ItemType File -Path (Join-Path $OutputDirectory "infra/terraform/environments/$_.tfvars") -Force | Out-Null
        }
    }
    
    # K8s structure
    @(
        "infra/k8s/helm",
        "infra/k8s/kustomize/base"
    ) | ForEach-Object { 
        New-Item -ItemType Directory -Path (Join-Path $OutputDirectory $_) -Force | Out-Null 
    }
    
    $script:ENVIRONMENTS -split ',' | ForEach-Object {
        New-Item -ItemType Directory -Path (Join-Path $OutputDirectory "infra/k8s/kustomize/overlays/$_") -Force | Out-Null
    }
}

function Generate-InfrastructureStructure {
    Log-Info "Generating infrastructure structure ($($script:IAC_TOOL))..."
    Generate-WorkloadInfraStructure
}

function Generate-InfraPipelines {
    Log-Info "Generating infrastructure pipelines..."
    
    New-Item -ItemType Directory -Path (Join-Path $OutputDirectory "pipelines") -Force | Out-Null
    
    if ($script:CICD_PLATFORM -eq "github-actions") {
        New-Item -ItemType Directory -Path (Join-Path $OutputDirectory ".github/workflows") -Force | Out-Null
        
        if ($script:INFRA_SCOPE -in @("landing-zone", "both")) {
            New-Item -ItemType File -Path (Join-Path $OutputDirectory ".github/workflows/platform-deploy.yml") -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $OutputDirectory ".github/workflows/landing-zone-deploy.yml") -Force | Out-Null
        }
        if ($script:INFRA_SCOPE -in @("workload", "both")) {
            New-Item -ItemType File -Path (Join-Path $OutputDirectory ".github/workflows/infra-deploy.yml") -Force | Out-Null
        }
    } else {
        if ($script:INFRA_SCOPE -in @("landing-zone", "both")) {
            New-Item -ItemType File -Path (Join-Path $OutputDirectory "pipelines/platform-deploy.yml") -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $OutputDirectory "pipelines/landing-zone-deploy.yml") -Force | Out-Null
        }
        if ($script:INFRA_SCOPE -in @("workload", "both")) {
            New-Item -ItemType File -Path (Join-Path $OutputDirectory "pipelines/infra-deploy.yml") -Force | Out-Null
        }
    }
}

function Generate-InfraTests {
    Log-Info "Generating infrastructure tests..."
    
    @(
        "tests/bicep-lint",
        "tests/security",
        "tests/policy-compliance",
        "tests/post-deploy"
    ) | ForEach-Object { 
        New-Item -ItemType Directory -Path (Join-Path $OutputDirectory $_) -Force | Out-Null 
    }
    
    New-Item -ItemType File -Path (Join-Path $OutputDirectory "tests/README.md") -Force | Out-Null
}

function Generate-FrontendPlaceholder {
    Log-Info "Creating frontend placeholder for $($script:FRONTEND_FRAMEWORK)..."
    
    New-Item -ItemType Directory -Path (Join-Path $OutputDirectory "frontend") -Force | Out-Null
    
    @"
# Frontend - $($script:FRONTEND_FRAMEWORK)

> **Note**: This is a placeholder. Generate the actual frontend using:

## Vue.js
``````bash
cd frontend && npm create vue@latest .
``````

## React
``````bash
cd frontend && npm create vite@latest . -- --template react-ts
``````

## Angular
``````bash
cd frontend && npx @angular/cli new app --directory .
``````

## Blazor
``````bash
cd frontend && dotnet new blazorserver
``````
"@ | Out-File -FilePath (Join-Path $OutputDirectory "frontend/README.md") -Encoding utf8
}

# =============================================================================
# APPLICATION STRUCTURE GENERATOR
# =============================================================================
function Generate-ApplicationStructure {
    Log-Info "Generating application structure..."
    
    if ($script:BACKEND_LANGUAGE -eq "csharp") {
        switch ($script:ARCHITECTURE) {
            "modular-monolith" { Generate-CSharpModularMonolith }
            "microservices" { Generate-CSharpMicroservices }
            "monolith" { Generate-CSharpMonolith }
            "serverless" { Generate-CSharpServerless }
            default { Generate-CSharpModularMonolith }
        }
        
        if ($script:CQRS_ENABLED -eq "true") {
            Generate-CSharpCqrsInterfaces
        }
        
        Generate-DotNetSolutionFiles
    } else {
        switch ($script:ARCHITECTURE) {
            "modular-monolith" { Generate-NodeJsModularMonolith }
            "microservices" { Generate-NodeJsMicroservices }
            "monolith" { Generate-NodeJsMonolith }
            "serverless" { Generate-NodeJsServerless }
            default { Generate-NodeJsModularMonolith }
        }
        
        if ($script:CQRS_ENABLED -eq "true") {
            Generate-NodeJsCqrsInterfaces
        }
        
        Generate-NodeJsConfigFiles
    }
    
    if ($script:FRONTEND_FRAMEWORK -ne "none") {
        Generate-FrontendPlaceholder
    }
}

# =============================================================================
# CONSTITUTION PRE-FILL
# =============================================================================
function Prefill-Constitution {
    Log-Step "Pre-filling constitution with your configuration..."
    
    $constitutionFile = Join-Path $OutputDirectory "memory/constitution.md"
    if (-not (Test-Path $constitutionFile)) {
        Log-Warning "Constitution file not found"
        return
    }
    
    $content = Get-Content $constitutionFile -Raw
    
    # Project Scope
    switch ($script:PROJECT_SCOPE) {
        "infra-only" { $content = $content -replace '\- \[ \] \*\*Infrastructure Only\*\*', '- [x] **Infrastructure Only**' }
        "app-only" { $content = $content -replace '\- \[ \] \*\*Application Development Only\*\*', '- [x] **Application Development Only**' }
        "full-stack" { $content = $content -replace '\- \[ \] \*\*Full Stack\*\*', '- [x] **Full Stack**' }
    }
    
    # Infrastructure scope
    switch ($script:INFRA_SCOPE) {
        "landing-zone" { $content = $content -replace '\- \[ \] \*\*Landing Zone\*\*', '- [x] **Landing Zone**' }
        "workload" { $content = $content -replace '\- \[ \] \*\*Workload Infrastructure\*\*', '- [x] **Workload Infrastructure**' }
        "both" { $content = $content -replace '\- \[ \] \*\*Both\*\*', '- [x] **Both**' }
    }
    
    # Backend
    if ($script:BACKEND_LANGUAGE -eq "csharp") {
        $content = $content -replace '\- \[ \] \*\*C# / \.NET\*\*', '- [x] **C# / .NET**'
    } elseif ($script:BACKEND_LANGUAGE -eq "nodejs") {
        $content = $content -replace '\- \[ \] \*\*Node\.js / TypeScript\*\*', '- [x] **Node.js / TypeScript**'
    }
    
    # Architecture
    switch ($script:ARCHITECTURE) {
        "modular-monolith" { $content = $content -replace '\- \[ \] \*\*Modular Monolith\*\*', '- [x] **Modular Monolith**' }
        "microservices" { $content = $content -replace '\- \[ \] \*\*Microservices\*\*', '- [x] **Microservices**' }
        "monolith" { $content = $content -replace '\- \[ \] \*\*Traditional Monolith\*\*', '- [x] **Traditional Monolith**' }
        "serverless" { $content = $content -replace '\- \[ \] \*\*Serverless\*\*', '- [x] **Serverless**' }
    }
    
    # CQRS
    if ($script:CQRS_ENABLED -eq "true") {
        $content = $content -replace 'CQRS Enabled: \[ \] Yes', 'CQRS Enabled: [x] Yes'
    }
    
    # Frontend
    switch ($script:FRONTEND_FRAMEWORK) {
        "none" { $content = $content -replace '\- \[ \] \*\*None\*\*', '- [x] **None**' }
        "vue" { $content = $content -replace '\- \[ \] \*\*Vue\.js\*\*', '- [x] **Vue.js**' }
        "react" { $content = $content -replace '\- \[ \] \*\*React\*\*', '- [x] **React**' }
        "angular" { $content = $content -replace '\- \[ \] \*\*Angular\*\*', '- [x] **Angular**' }
    }
    
    # Database
    switch ($script:DATABASE) {
        "azure-sql" { $content = $content -replace '\- \[ \] \*\*Azure SQL Database\*\*', '- [x] **Azure SQL Database**' }
        "postgresql" { $content = $content -replace '\- \[ \] \*\*PostgreSQL\*\*', '- [x] **PostgreSQL**' }
        "cosmos-db" { $content = $content -replace '\- \[ \] \*\*Azure Cosmos DB\*\*', '- [x] **Azure Cosmos DB**' }
    }
    
    # Docker
    if ($script:DOCKER_ENABLED -eq "true") {
        $content = $content -replace '\- \[ \] \*\*Docker\*\*', '- [x] **Docker**'
    }
    
    # Orchestration
    switch ($script:ORCHESTRATION) {
        "aks" { $content = $content -replace '\- \[ \] \*\*Azure Kubernetes Service\*\*', '- [x] **Azure Kubernetes Service**' }
        "container-apps" { $content = $content -replace '\- \[ \] \*\*Azure Container Apps\*\*', '- [x] **Azure Container Apps**' }
        "app-service" { $content = $content -replace '\- \[ \] \*\*Azure App Service\*\*', '- [x] **Azure App Service**' }
    }
    
    # IaC
    switch ($script:IAC_TOOL) {
        "bicep" { $content = $content -replace '\- \[ \] \*\*Bicep\*\*', '- [x] **Bicep**' }
        "terraform" { $content = $content -replace '\- \[ \] \*\*Terraform\*\*', '- [x] **Terraform**' }
        "pulumi" { $content = $content -replace '\- \[ \] \*\*Pulumi\*\*', '- [x] **Pulumi**' }
    }
    
    # CI/CD
    switch ($script:CICD_PLATFORM) {
        "github-actions" { $content = $content -replace '\- \[ \] \*\*GitHub Actions\*\*', '- [x] **GitHub Actions**' }
        "azure-devops" { $content = $content -replace '\- \[ \] \*\*Azure DevOps Pipelines\*\*', '- [x] **Azure DevOps Pipelines**' }
    }
    
    # Greenfield/Brownfield
    if ($ProjectType -eq "green") {
        $content = $content -replace '\- \[ \] \*\*Greenfield\*\*', '- [x] **Greenfield**'
    } else {
        $content = $content -replace '\- \[ \] \*\*Brownfield\*\*', '- [x] **Brownfield**'
    }
    
    $content | Out-File -FilePath $constitutionFile -Encoding utf8 -NoNewline
    Log-Success "Constitution pre-filled with your configuration"
}

# =============================================================================
# COPY CONSTITUTION TEMPLATE
# =============================================================================
function Copy-ConstitutionTemplate {
    Log-Step "Copying constitution template..."
    
    # Get script directory - handle both direct execution and dot-sourcing
    $scriptDir = $PSScriptRoot
    if (-not $scriptDir) {
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
    }
    if (-not $scriptDir) {
        $scriptDir = Get-Location
    }
    
    $possiblePaths = @(
        (Join-Path $scriptDir "../../memory/constitution.md"),
        (Join-Path $scriptDir "../memory/constitution.md"),
        (Join-Path (Get-Location) "memory/constitution.md")
    )
    
    $templatePath = $null
    foreach ($path in $possiblePaths) {
        try {
            if (Test-Path $path -ErrorAction SilentlyContinue) {
                $templatePath = (Resolve-Path $path -ErrorAction Stop).Path
                break
            }
        } catch {
            continue
        }
    }
    
    if ($templatePath) {
        Copy-Item -Path $templatePath -Destination (Join-Path $OutputDirectory "memory/constitution.md") -Force
        Log-Success "Constitution template copied"
    } else {
        Log-Warning "Constitution template not found. Creating placeholder..."
        @"
# PROJECT CONSTITUTION
> This file defines the fundamental rules and decisions for this project.
"@ | Out-File -FilePath (Join-Path $OutputDirectory "memory/constitution.md") -Encoding utf8
    }
}

# =============================================================================
# INITIALIZE GIT REPOSITORY
# =============================================================================
function Initialize-GitRepo {
    Log-Step "Initializing Git repository..."
    
    Push-Location $OutputDirectory
    try {
        if (-not (Test-Path ".git")) {
            git init 2>&1 | Out-Null
            
            # Create .gitignore
            @'
# Build outputs
bin/
obj/
dist/
build/
node_modules/

# IDE
.vs/
.vscode/
.idea/
*.suo
*.user

# OS
.DS_Store
Thumbs.db

# Environment
.env
.env.local
*.local

# Logs
logs/
*.log
npm-debug.log*

# Test coverage
coverage/
TestResults/

# Terraform
.terraform/
*.tfstate
*.tfstate.*
'@ | Out-File -FilePath ".gitignore" -Encoding utf8
            
            git add . 2>&1 | Out-Null
            git commit -m "Initial commit - Project structure generated by Aurora Init" 2>&1 | Out-Null
            Log-Success "Git repository initialized"
        } else {
            Log-Warning "Git repository already exists"
        }
    } catch {
        Log-Warning "Git initialization failed: $_"
    } finally {
        Pop-Location
    }
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

# Check for auto mode
if ($Auto) {
    $script:AUTO_MODE = $true
    $script:AUTO_PROFILE = $Auto
}

# Print banner
Print-Banner

# Log initialization
Log-Info "Initializing AURORA-IA project..."
Log-Info "  Output Directory: $OutputDirectory"
$projectTypeDesc = if ($ProjectType -eq 'brown') { 'Brownfield - Migration' } else { 'Greenfield - New Project' }
Log-Info "  Project Type: $ProjectType ($projectTypeDesc)"
if ($SourceDirectory) { Log-Info "  Source Directory: $SourceDirectory" }
if ($script:AUTO_MODE) { Log-Info "  Auto Mode: $($script:AUTO_PROFILE)" }

# Run configuration
if ($ProjectType -eq "green") {
    if ($script:AUTO_MODE) {
        Apply-AutoProfile $script:AUTO_PROFILE
    } else {
        Run-ConfigurationWizard
    }
}

# Create output directory
Log-Step "Creating output directory structure..."
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null

# Create main folder structure
@(
    ".github/copilot/agents",
    ".github/commands",
    ".github/prompts",
    ".github/workflows",
    "memory",
    "specs/.template/contracts",
    "specs/.template/requirements",
    "specs/.template/tests",
    "specs/.template/planning",
    "docs/adr",
    "docs/architecture",
    "scripts/bash",
    "scripts/powershell",
    "infra/scripts"
) | ForEach-Object { 
    New-Item -ItemType Directory -Path (Join-Path $OutputDirectory $_) -Force | Out-Null 
}

# Generate structure based on project scope
if ($ProjectType -eq "green") {
    switch ($script:PROJECT_SCOPE) {
        "infra-only" {
            Generate-InfrastructureOnlyStructure
            if ($script:INFRA_SCOPE -in @("landing-zone", "both")) {
                Generate-LandingZoneStructure
            }
            if ($script:INFRA_SCOPE -in @("workload", "both")) {
                Generate-WorkloadInfraStructure
            }
            Generate-InfraPipelines
            Generate-InfraTests
        }
        "app-only" {
            Generate-ApplicationStructure
        }
        "full-stack" {
            Generate-ApplicationStructure
            Generate-InfrastructureStructure
            Generate-InfraPipelines
        }
    }
} else {
    # Brownfield - create legacy analysis structure
    @(
        "legacy/source",
        "legacy/analysis",
        "legacy/documentation",
        "migration/plan",
        "migration/mappings"
    ) | ForEach-Object { 
        New-Item -ItemType Directory -Path (Join-Path $OutputDirectory $_) -Force | Out-Null 
    }
    
    if ($SourceDirectory -and (Test-Path $SourceDirectory)) {
        Log-Info "Copying source files..."
        Copy-Item -Path "$SourceDirectory\*" -Destination (Join-Path $OutputDirectory "legacy/source") -Recurse -Force
    }
}

# Create specs template files
Log-Step "Creating specs template files..."

# Specs README
@"
# Feature Specifications

This directory contains all feature specifications organized by feature.

## Structure

Each feature has its own directory with the following structure:

- ``contracts/`` - API contracts (OpenAPI, AsyncAPI, etc.)
- ``requirements/`` - Business requirements and user stories
- ``tests/`` - Gherkin feature files
- ``planning/`` - Implementation plans and task breakdowns

## Creating a New Feature

Copy the ``.template`` folder:
``````bash
cp -r specs/.template specs/001-my-feature-name
``````

Then fill in the templates for your specific feature.
"@ | Out-File -FilePath (Join-Path $OutputDirectory "specs/README.md") -Encoding utf8

# Copy constitution and prefill
Copy-ConstitutionTemplate
if ($ProjectType -eq "green") {
    Prefill-Constitution
}

# Initialize git
Initialize-GitRepo

# Create README
$readmePath = Join-Path $OutputDirectory "README.md"
$projectName = Split-Path -Leaf $OutputDirectory
$dateStr = Get-Date -Format "yyyy-MM-dd"

if ($ProjectType -eq "green") {
    @"
# $projectName

> Project initialized with **AURORA-IA + AI-DLC** methodology
>
> **Type**: Greenfield (New Project)
> **Created**: $dateStr

---

## Quick Start

1. Review ``memory/constitution.md`` (already pre-filled!)
2. Complete any remaining configuration sections
3. Start with: ``/aurora.feature [your-first-feature]``

## Configuration

- **Backend**: $($script:BACKEND_LANGUAGE) ($($script:BACKEND_VERSION)) - $($script:BACKEND_FRAMEWORK)
- **Architecture**: $($script:ARCHITECTURE)
- **CQRS**: $($script:CQRS_ENABLED)
- **Frontend**: $($script:FRONTEND_FRAMEWORK)
- **Database**: $($script:DATABASE)
- **Container**: $($script:ORCHESTRATION)
- **IaC**: $($script:IAC_TOOL)
- **CI/CD**: $($script:CICD_PLATFORM)

---

Happy coding with AURORA-IA!
"@ | Out-File -FilePath $readmePath -Encoding utf8
} else {
    @"
# $projectName

> Project initialized with **AURORA-IA + AI-DLC** methodology
>
> **Type**: Brownfield (Migration Project)
> **Created**: $dateStr
> **Source**: ``$SourceDirectory``

---

## Brownfield Migration Quick Start

1. Open ``memory/constitution.md``
2. Fill in your technology choices
3. Analyze legacy code in ``legacy/source/``
4. Document findings in ``legacy/analysis/``

---

Happy coding with AURORA-IA!
"@ | Out-File -FilePath $readmePath -Encoding utf8
}

Log-Success "README.md created"

# Final summary
Write-Host ""
Write-Color "===============================================================================" Green
Write-Color "                    AURORA-IA Project Initialized!                             " Green
Write-Color "===============================================================================" Green
Write-Host ""
Write-Color "Project Location: $OutputDirectory" Cyan
$typeLabel = if ($ProjectType -eq 'brown') { 'Brownfield (Migration)' } else { 'Greenfield (New Project)' }
Write-Color "Project Type: $typeLabel" Cyan
Write-Host ""

if ($ProjectType -eq "green") {
    Write-Color "Configuration Applied:" Cyan
    Write-Host "   Project Scope: $($script:PROJECT_SCOPE)"
    
    if ($script:PROJECT_SCOPE -in @("app-only", "full-stack")) {
        Write-Host "   Backend:      $($script:BACKEND_LANGUAGE) ($($script:BACKEND_VERSION)) - $($script:BACKEND_FRAMEWORK)"
        Write-Host "   Architecture: $($script:ARCHITECTURE)"
        Write-Host "   CQRS:         $($script:CQRS_ENABLED)"
        Write-Host "   Frontend:     $($script:FRONTEND_FRAMEWORK)"
        Write-Host "   Database:     $($script:DATABASE) ($($script:DATA_ACCESS))"
        Write-Host "   Container:    $($script:ORCHESTRATION)"
    }
    
    if ($script:PROJECT_SCOPE -in @("infra-only", "full-stack")) {
        Write-Host "   Infra Scope:  $($script:INFRA_SCOPE)"
        Write-Host "   IaC:          $($script:IAC_TOOL)"
    }
    
    Write-Host "   CI/CD:        $($script:CICD_PLATFORM)"
}

Write-Host ""
Write-Color "Next Steps:" Yellow
Write-Host "   1. cd $OutputDirectory"
if ($ProjectType -eq "green") {
    Write-Host "   2. Review memory/constitution.md (already pre-filled!)"
    Write-Host "   3. Complete any remaining configuration sections"
    Write-Host "   4. Start with: /aurora.feature [your-first-feature]"
} else {
    Write-Host "   2. Open memory/constitution.md"
    Write-Host "   3. Fill in your technology choices"
    Write-Host "   4. Or use: /aurora.constitution in GitHub Copilot Chat"
}

Write-Host ""
Write-Color "Happy coding with AURORA-IA!" Magenta
Write-Host ""
