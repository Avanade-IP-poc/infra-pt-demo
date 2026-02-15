<#
.SYNOPSIS
    Create a new sprint/iteration in Azure DevOps project

.DESCRIPTION
    This script creates a new sprint (iteration) in the current Azure DevOps project.
    Sprints are used to organize work into time-boxed periods.

    The script:
    - Creates the iteration node in the classification hierarchy
    - Sets start and finish dates
    - Optionally assigns the sprint to a team

.PARAMETER Name
    Sprint name (e.g., "Sprint 1", "Q1 2026", "March Release")

.PARAMETER StartDate
    Sprint start date (format: yyyy-MM-dd)

.PARAMETER FinishDate
    Sprint end date (format: yyyy-MM-dd)

.PARAMETER ParentPath
    Parent iteration path (default: project root)
    Example: "ProjectName\2026\Q1"

.PARAMETER TeamName
    Team name to assign this sprint to (optional)

.PARAMETER DryRun
    Preview the sprint creation without actually creating it

.EXAMPLE
    .\New-DevOpsSprint.ps1 -Name "Sprint 1" -StartDate "2026-03-01" -FinishDate "2026-03-14"
    Create a 2-week sprint starting March 1, 2026

.EXAMPLE
    .\New-DevOpsSprint.ps1 -Name "Q1 Planning" -StartDate "2026-01-01" -FinishDate "2026-03-31" -ParentPath "MyProject\2026"
    Create a quarter sprint under a specific parent path

.EXAMPLE
    .\New-DevOpsSprint.ps1 -Name "Sprint 2" -StartDate "2026-03-15" -FinishDate "2026-03-28" -TeamName "Backend Team"
    Create a sprint and assign it to a specific team

.EXAMPLE
    .\New-DevOpsSprint.ps1 -Name "Sprint 3" -StartDate "2026-04-01" -FinishDate "2026-04-14" -DryRun
    Preview sprint creation without actually creating it

.NOTES
    Requires:
    - Azure DevOps CLI (az devops)
    - AZURE_DEVOPS_EXT_PAT environment variable set
    - az devops configure --defaults organization=... project=...
    - Permissions to create iterations in the project
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [ValidateScript({
        try {
            [DateTime]::ParseExact($_, "yyyy-MM-dd", $null)
            $true
        }
        catch {
            throw "StartDate must be in format yyyy-MM-dd"
        }
    })]
    [string]$StartDate,

    [Parameter(Mandatory = $true)]
    [ValidateScript({
        try {
            [DateTime]::ParseExact($_, "yyyy-MM-dd", $null)
            $true
        }
        catch {
            throw "FinishDate must be in format yyyy-MM-dd"
        }
    })]
    [string]$FinishDate,

    [Parameter(Mandatory = $false)]
    [string]$ParentPath,

    [Parameter(Mandatory = $false)]
    [string]$TeamName,

    [Parameter(Mandatory = $false)]
    [switch]$DryRun
)

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

# Validate dates
$start = [DateTime]::ParseExact($StartDate, "yyyy-MM-dd", $null)
$finish = [DateTime]::ParseExact($FinishDate, "yyyy-MM-dd", $null)

if ($finish -le $start) {
    Write-Error "FinishDate must be after StartDate"
    exit 1
}

$duration = ($finish - $start).Days
Write-Host "Creating sprint in project: $project" -ForegroundColor Cyan
Write-Host "Organization: $organization" -ForegroundColor Gray
Write-Host ""

Write-Host "Sprint Details:" -ForegroundColor Green
Write-Host "  Name        : $Name" -ForegroundColor White
Write-Host "  Start Date  : $StartDate" -ForegroundColor White
Write-Host "  Finish Date : $FinishDate" -ForegroundColor White
Write-Host "  Duration    : $duration days" -ForegroundColor White
if ($ParentPath) {
    Write-Host "  Parent Path : $ParentPath" -ForegroundColor White
}
if ($TeamName) {
    Write-Host "  Team        : $TeamName" -ForegroundColor White
}
Write-Host ""

if ($DryRun) {
    Write-Host "[DRY RUN] Sprint would be created with the above details" -ForegroundColor Yellow
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

    Write-Host "Creating iteration node..." -ForegroundColor Cyan

    # Create the iteration
    $createParams = @(
        "boards", "iteration", "project", "create",
        "--project", $project,
        "--name", $Name,
        "--start-date", $StartDate,
        "--finish-date", $FinishDate
    )

    if ($ParentPath) {
        $createParams += "--path", $ParentPath
    }

    $createParams += "--output", "json"

    Write-Verbose "Executing: az $($createParams -join ' ')"
    $iteration = & az $createParams | ConvertFrom-Json

    if (-not $iteration) {
        Write-Error "Failed to create iteration"
        exit 1
    }

    Write-Host "✓ Sprint created successfully" -ForegroundColor Green
    Write-Host "  ID   : $($iteration.identifier)" -ForegroundColor Gray
    Write-Host "  Path : $($iteration.path)" -ForegroundColor Gray
    Write-Host ""

    # Assign to team if specified
    if ($TeamName) {
        Write-Host "Assigning sprint to team '$TeamName'..." -ForegroundColor Cyan

        try {
            $teamAddParams = @(
                "boards", "iteration", "team", "add",
                "--team", $TeamName,
                "--project", $project,
                "--id", $iteration.identifier,
                "--output", "json"
            )

            Write-Verbose "Executing: az $($teamAddParams -join ' ')"
            $teamIteration = & az $teamAddParams | ConvertFrom-Json

            Write-Host "✓ Sprint assigned to team successfully" -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed to assign sprint to team: $_"
            Write-Host "The sprint was created but not assigned to the team. You can assign it manually." -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host "Sprint '$Name' is ready to use!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Assign work items to this sprint using System.IterationPath = '$fullPath'" -ForegroundColor Gray
    Write-Host "  2. View sprints: .\Get-DevOpsSprints.ps1" -ForegroundColor Gray
    if (-not $TeamName) {
        Write-Host "  3. Assign to a team: az boards iteration team add --team '<team-name>' --id $($iteration.identifier)" -ForegroundColor Gray
    }
}
catch {
    Write-Error "Failed to create sprint: $_"
    Write-Verbose $_.Exception.Message

    # Check if it's a duplicate
    if ($_.Exception.Message -like "*already exists*") {
        Write-Host ""
        Write-Host "Tip: A sprint with this name may already exist. Use Get-DevOpsSprints.ps1 to list existing sprints." -ForegroundColor Yellow
    }

    exit 1
}
