<#
.SYNOPSIS
    Create a new area in Azure DevOps project

.DESCRIPTION
    This script creates a new area path in the current Azure DevOps project.
    Areas are used to organize work items by teams, components, or product areas.

    The script:
    - Creates the area node in the classification hierarchy
    - Optionally assigns the area to a team
    - Supports hierarchical area structures

.PARAMETER Name
    Area name (e.g., "Backend", "Frontend", "Mobile", "API")

.PARAMETER ParentPath
    Parent area path (default: project root)
    Example: "ProjectName\Services"

.PARAMETER TeamName
    Team name to assign this area to (optional)

.PARAMETER SetAsDefault
    Set this area as the default for the team (only valid with -TeamName)

.PARAMETER DryRun
    Preview the area creation without actually creating it

.EXAMPLE
    .\New-DevOpsArea.ps1 -Name "Backend"
    Create a new area at the root level

.EXAMPLE
    .\New-DevOpsArea.ps1 -Name "API" -ParentPath "MyProject\Backend"
    Create a new area under an existing parent

.EXAMPLE
    .\New-DevOpsArea.ps1 -Name "Mobile" -TeamName "Mobile Team" -SetAsDefault
    Create an area and set it as default for a team

.EXAMPLE
    .\New-DevOpsArea.ps1 -Name "Services" -DryRun
    Preview area creation without actually creating it

.NOTES
    Requires:
    - Azure DevOps CLI (az devops)
    - AZURE_DEVOPS_EXT_PAT environment variable set
    - az devops configure --defaults organization=... project=...
    - Permissions to create areas in the project
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $false)]
    [string]$ParentPath,

    [Parameter(Mandatory = $false)]
    [string]$TeamName,

    [Parameter(Mandatory = $false)]
    [switch]$SetAsDefault,

    [Parameter(Mandatory = $false)]
    [switch]$DryRun
)

# Validate parameters
if ($SetAsDefault -and -not $TeamName) {
    Write-Error "-SetAsDefault can only be used with -TeamName"
    exit 1
}

# Ensure Azure DevOps CLI is available
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI not found. Install with: winget install -e --id Microsoft.AzureCLI"
    exit 1
}

# Ensure devops extension is installed
$extensions = az extension list --output json | ConvertFrom-Json
if (-not ($extensions | Where-Object { $_.name -eq 'azure-devops' })) {
    Write-Error "Azure DevOps extension not found. Install with: az extension add --name azure-devops"
    exit 1
}

# Verify PAT is set
if (-not $env:AZURE_DEVOPS_EXT_PAT) {
    Write-Error "AZURE_DEVOPS_EXT_PAT environment variable not set"
    Write-Host "Create a PAT at: https://dev.azure.com/<your-org>/_usersSettings/tokens" -ForegroundColor Yellow
    exit 1
}

# Get current defaults
$defaults = az devops configure --list --output json | ConvertFrom-Json
$organization = ($defaults | Where-Object { $_.name -eq 'organization' }).value
$project = ($defaults | Where-Object { $_.name -eq 'project' }).value

if (-not $organization -or -not $project) {
    Write-Error "Azure DevOps defaults not configured"
    Write-Host "Configure with: az devops configure --defaults organization=https://dev.azure.com/<your-org> project=`"<your-project>`"" -ForegroundColor Yellow
    exit 1
}

Write-Host "Creating area in project: $project" -ForegroundColor Cyan
Write-Host "Organization: $organization" -ForegroundColor Gray
Write-Host ""

Write-Host "Area Details:" -ForegroundColor Green
Write-Host "  Name        : $Name" -ForegroundColor White
if ($ParentPath) {
    Write-Host "  Parent Path : $ParentPath" -ForegroundColor White
}
if ($TeamName) {
    Write-Host "  Team        : $TeamName" -ForegroundColor White
    if ($SetAsDefault) {
        Write-Host "  Set Default : Yes" -ForegroundColor White
    }
}
Write-Host ""

if ($DryRun) {
    Write-Host "[DRY RUN] Area would be created with the above details" -ForegroundColor Yellow
    exit 0
}

try {
    # Determine the full path
    if ($ParentPath) {
        $fullPath = "$ParentPath\$Name"
    }
    else {
        $fullPath = "$project\$Name"
    }

    Write-Host "Creating area node..." -ForegroundColor Cyan

    # Create the area
    $createParams = @(
        "boards", "area", "project", "create",
        "--project", $project,
        "--name", $Name
    )

    if ($ParentPath) {
        $createParams += "--path", $ParentPath
    }

    $createParams += "--output", "json"

    Write-Verbose "Executing: az $($createParams -join ' ')"
    $area = & az $createParams | ConvertFrom-Json

    if (-not $area) {
        Write-Error "Failed to create area"
        exit 1
    }

    Write-Host "✓ Area created successfully" -ForegroundColor Green
    Write-Host "  ID   : $($area.identifier)" -ForegroundColor Gray
    Write-Host "  Path : $($area.path)" -ForegroundColor Gray
    Write-Host ""

    # Assign to team if specified
    if ($TeamName) {
        Write-Host "Assigning area to team '$TeamName'..." -ForegroundColor Cyan

        try {
            $teamAddParams = @(
                "boards", "area", "team", "add",
                "--team", $TeamName,
                "--project", $project,
                "--path", $area.path
            )

            if ($SetAsDefault) {
                $teamAddParams += "--set-as-default"
            }

            $teamAddParams += "--output", "json"

            Write-Verbose "Executing: az $($teamAddParams -join ' ')"
            $teamArea = & az $teamAddParams | ConvertFrom-Json

            Write-Host "✓ Area assigned to team successfully" -ForegroundColor Green
            if ($SetAsDefault) {
                Write-Host "✓ Set as default area for team" -ForegroundColor Green
            }
        }
        catch {
            Write-Warning "Failed to assign area to team: $_"
            Write-Host "The area was created but not assigned to the team. You can assign it manually." -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host "Area '$Name' is ready to use!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Assign work items to this area using System.AreaPath = '$fullPath'" -ForegroundColor Gray
    Write-Host "  2. View areas: .\Get-DevOpsAreas.ps1" -ForegroundColor Gray
    if (-not $TeamName) {
        Write-Host "  3. Assign to a team: az boards area team add --team '<team-name>' --path '$fullPath'" -ForegroundColor Gray
    }
    Write-Host "  4. Create sub-areas: .\New-DevOpsArea.ps1 -Name '<sub-area>' -ParentPath '$fullPath'" -ForegroundColor Gray
}
catch {
    Write-Error "Failed to create area: $_"
    Write-Verbose $_.Exception.Message

    # Check if it's a duplicate
    if ($_.Exception.Message -like "*already exists*") {
        Write-Host ""
        Write-Host "Tip: An area with this name may already exist. Use Get-DevOpsAreas.ps1 to list existing areas." -ForegroundColor Yellow
    }

    exit 1
}
