<#
.SYNOPSIS
    Discover sprints/iterations configured in Azure DevOps project

.DESCRIPTION
    This script retrieves all sprints (iterations) configured in the current Azure DevOps project.
    Use this to understand what sprints are available before assigning work items.

    Returns sprint details including:
    - Name
    - Path
    - Start Date
    - Finish Date
    - State (Current, Past, Future)

.PARAMETER OutputFormat
    Output format: "Table" (default), "List", "Json"

.PARAMETER IncludePast
    Include past sprints (defaults to $false)

.PARAMETER IncludeFuture
    Include future sprints (defaults to $true)

.PARAMETER TeamName
    Specific team name to get sprints for (optional)
    If not specified, uses project iterations

.EXAMPLE
    .\Get-DevOpsSprints.ps1
    List current and future sprints in table format

.EXAMPLE
    .\Get-DevOpsSprints.ps1 -IncludePast
    List all sprints including past ones

.EXAMPLE
    .\Get-DevOpsSprints.ps1 -OutputFormat Json
    Get sprints as JSON

.EXAMPLE
    .\Get-DevOpsSprints.ps1 -TeamName "Backend Team"
    Get sprints for a specific team

.NOTES
    Requires:
    - Azure DevOps CLI (az devops)
    - AZURE_DEVOPS_EXT_PAT environment variable set
    - az devops configure --defaults organization=... project=...
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("Table", "List", "Json")]
    [string]$OutputFormat = "Table",

    [Parameter(Mandatory = $false)]
    [switch]$IncludePast,

    [Parameter(Mandatory = $false)]
    [switch]$IncludeFuture = $true,

    [Parameter(Mandatory = $false)]
    [string]$TeamName
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

Write-Host "Discovering sprints/iterations in project: $project" -ForegroundColor Cyan
Write-Host "Organization: $organization" -ForegroundColor Gray
if ($TeamName) {
    Write-Host "Team: $TeamName" -ForegroundColor Gray
}
Write-Host ""

try {
    $sprints = @()
    $today = Get-Date

    if ($TeamName) {
        # Get team iterations
        Write-Verbose "Fetching iterations for team: $TeamName"
        $iterations = az boards iteration team list --team $TeamName --project $project --output json | ConvertFrom-Json

        foreach ($iteration in $iterations) {
            $startDate = if ($iteration.attributes.startDate) { [DateTime]::Parse($iteration.attributes.startDate) } else { $null }
            $finishDate = if ($iteration.attributes.finishDate) { [DateTime]::Parse($iteration.attributes.finishDate) } else { $null }

            $state = Get-SprintState -StartDate $startDate -FinishDate $finishDate -Today $today

            # Filter based on parameters
            if (($state -eq "Past" -and -not $IncludePast) -or ($state -eq "Future" -and -not $IncludeFuture)) {
                continue
            }

            $sprints += [PSCustomObject]@{
                Name = $iteration.name
                Path = $iteration.path
                State = $state
                StartDate = if ($startDate) { $startDate.ToString("yyyy-MM-dd") } else { "Not set" }
                FinishDate = if ($finishDate) { $finishDate.ToString("yyyy-MM-dd") } else { "Not set" }
                Id = $iteration.id
            }
        }
    }
    else {
        # Get project iterations (classification nodes)
        Write-Verbose "Fetching project iterations..."
        $iterationsJson = az boards iteration project list --project $project --depth 99 --output json
        $iterationTree = $iterationsJson | ConvertFrom-Json

        # Recursively process iteration nodes
        function Process-IterationNode {
            param($Node, $ParentPath = "")

            $currentPath = if ($ParentPath) { "$ParentPath\$($Node.name)" } else { $Node.name }

            # Check if this node has dates (is an actual sprint)
            if ($Node.attributes) {
                $startDate = if ($Node.attributes.startDate) { [DateTime]::Parse($Node.attributes.startDate) } else { $null }
                $finishDate = if ($Node.attributes.finishDate) { [DateTime]::Parse($Node.attributes.finishDate) } else { $null }

                $state = Get-SprintState -StartDate $startDate -FinishDate $finishDate -Today $today

                # Filter based on parameters
                if (($state -eq "Past" -and -not $IncludePast) -or ($state -eq "Future" -and -not $IncludeFuture)) {
                    # Skip, but continue to children
                }
                else {
                    $script:sprints += [PSCustomObject]@{
                        Name = $Node.name
                        Path = $currentPath
                        State = $state
                        StartDate = if ($startDate) { $startDate.ToString("yyyy-MM-dd") } else { "Not set" }
                        FinishDate = if ($finishDate) { $finishDate.ToString("yyyy-MM-dd") } else { "Not set" }
                        Id = $Node.identifier
                    }
                }
            }

            # Process children
            if ($Node.children) {
                foreach ($child in $Node.children) {
                    Process-IterationNode -Node $child -ParentPath $currentPath
                }
            }
        }

        # Process all iteration nodes
        foreach ($node in $iterationTree) {
            Process-IterationNode -Node $node
        }
    }

    if ($sprints.Count -eq 0) {
        Write-Warning "No sprints found matching the criteria."
        if (-not $IncludePast) {
            Write-Host "Tip: Use -IncludePast to see past sprints" -ForegroundColor Yellow
        }
        exit 0
    }

    # Sort by start date
    $sprints = $sprints | Sort-Object StartDate

    Write-Host "Sprints/Iterations:" -ForegroundColor Green
    Write-Host ""

    switch ($OutputFormat) {
        "Table" {
            $sprints | Format-Table -AutoSize
        }
        "List" {
            $sprints | Format-List
        }
        "Json" {
            $sprints | ConvertTo-Json -Depth 10
        }
    }

    Write-Host ""
    Write-Host "Total sprints: $($sprints.Count)" -ForegroundColor Green

    # Show state summary
    $stateGroups = $sprints | Group-Object State
    foreach ($group in $stateGroups) {
        Write-Host "  - $($group.Name): $($group.Count)" -ForegroundColor Gray
    }
}
catch {
    Write-Error "Failed to retrieve sprints: $_"
    Write-Verbose $_.Exception.Message
    exit 1
}

# Helper function to determine sprint state
function Get-SprintState {
    param(
        [DateTime]$StartDate,
        [DateTime]$FinishDate,
        [DateTime]$Today
    )

    if (-not $StartDate -or -not $FinishDate) {
        return "Not Scheduled"
    }

    if ($Today -lt $StartDate) {
        return "Future"
    }
    elseif ($Today -gt $FinishDate) {
        return "Past"
    }
    else {
        return "Current"
    }
}
