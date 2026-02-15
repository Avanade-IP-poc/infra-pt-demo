<#
.SYNOPSIS
    Discover areas configured in Azure DevOps project

.DESCRIPTION
    This script retrieves all area paths configured in the current Azure DevOps project.
    Use this to understand what areas are available before assigning work items.

    Areas are used to organize work items by:
    - Teams
    - Components
    - Features
    - Product areas

    Returns area details including:
    - Name
    - Full Path
    - Level (depth in hierarchy)

.PARAMETER OutputFormat
    Output format: "Table" (default), "List", "Json", "Tree"

.PARAMETER Depth
    Maximum depth to traverse (default: 99 for all levels)

.PARAMETER TeamName
    Specific team name to get areas for (optional)
    If not specified, shows all project areas

.EXAMPLE
    .\Get-DevOpsAreas.ps1
    List all areas in table format

.EXAMPLE
    .\Get-DevOpsAreas.ps1 -OutputFormat Tree
    Display areas as a tree structure

.EXAMPLE
    .\Get-DevOpsAreas.ps1 -OutputFormat Json
    Get areas as JSON

.EXAMPLE
    .\Get-DevOpsAreas.ps1 -TeamName "Backend Team"
    Get areas for a specific team

.EXAMPLE
    .\Get-DevOpsAreas.ps1 -Depth 2
    Get areas up to 2 levels deep

.NOTES
    Requires:
    - Azure DevOps CLI (az devops)
    - AZURE_DEVOPS_EXT_PAT environment variable set
    - az devops configure --defaults organization=... project=...
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("Table", "List", "Json", "Tree")]
    [string]$OutputFormat = "Table",

    [Parameter(Mandatory = $false)]
    [int]$Depth = 99,

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

Write-Host "Discovering areas in project: $project" -ForegroundColor Cyan
Write-Host "Organization: $organization" -ForegroundColor Gray
if ($TeamName) {
    Write-Host "Team: $TeamName" -ForegroundColor Gray
}
Write-Host ""

try {
    $areas = @()

    if ($TeamName) {
        # Get team areas
        Write-Verbose "Fetching areas for team: $TeamName"
        $teamAreas = az boards area team list --team $TeamName --project $project --output json | ConvertFrom-Json

        foreach ($area in $teamAreas) {
            $pathParts = $area.path -split '\\'
            $level = $pathParts.Count - 1

            $areas += [PSCustomObject]@{
                Name = $area.name
                Path = $area.path
                Level = $level
                Id = $area.id
                IsDefault = $area.attributes.isDefault -eq $true
            }
        }
    }
    else {
        # Get project areas (classification nodes)
        Write-Verbose "Fetching project areas..."
        $areasJson = az boards area project list --project $project --depth $Depth --output json
        $areaTree = $areasJson | ConvertFrom-Json

        # Recursively process area nodes
        function Process-AreaNode {
            param(
                $Node,
                $ParentPath = "",
                $Level = 0
            )

            $currentPath = if ($ParentPath) { "$ParentPath\$($Node.name)" } else { $Node.name }

            $script:areas += [PSCustomObject]@{
                Name = $Node.name
                Path = $currentPath
                Level = $Level
                Id = $Node.identifier
                HasChildren = ($Node.children -and $Node.children.Count -gt 0)
            }

            # Process children
            if ($Node.children) {
                foreach ($child in $Node.children) {
                    Process-AreaNode -Node $child -ParentPath $currentPath -Level ($Level + 1)
                }
            }
        }

        # Process all area nodes
        foreach ($node in $areaTree) {
            Process-AreaNode -Node $node -Level 0
        }
    }

    if ($areas.Count -eq 0) {
        Write-Warning "No areas found."
        exit 0
    }

    # Sort by path
    $areas = $areas | Sort-Object Path

    Write-Host "Areas:" -ForegroundColor Green
    Write-Host ""

    switch ($OutputFormat) {
        "Table" {
            $areas | Format-Table -AutoSize
        }
        "List" {
            $areas | Format-List
        }
        "Json" {
            $areas | ConvertTo-Json -Depth 10
        }
        "Tree" {
            # Display as tree
            Write-Host "Area Tree:" -ForegroundColor Green
            Write-Host ""

            foreach ($area in $areas) {
                $indent = "  " * $area.Level
                $marker = if ($area.HasChildren) { "└─" } else { "  " }
                Write-Host "$indent$marker $($area.Name)" -ForegroundColor $(if ($area.Level -eq 0) { "Cyan" } else { "White" })
            }
        }
    }

    if ($OutputFormat -ne "Tree") {
        Write-Host ""
        Write-Host "Total areas: $($areas.Count)" -ForegroundColor Green

        # Show level distribution
        $levelGroups = $areas | Group-Object Level
        Write-Host ""
        Write-Host "Level distribution:" -ForegroundColor Gray
        foreach ($group in ($levelGroups | Sort-Object Name)) {
            Write-Host "  - Level $($group.Name): $($group.Count)" -ForegroundColor Gray
        }
    }
}
catch {
    Write-Error "Failed to retrieve areas: $_"
    Write-Verbose $_.Exception.Message
    exit 1
}
