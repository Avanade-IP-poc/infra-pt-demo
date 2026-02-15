<#
.SYNOPSIS
    Discover available work item types in Azure DevOps project

.DESCRIPTION
    This script retrieves all work item types configured in the current Azure DevOps project.
    Use this to understand what types are available before creating or mapping work items.

    Common types include:
    - Epic
    - Feature
    - Product Backlog Item (PBI) / User Story
    - Task
    - Bug
    - Test Case

.PARAMETER OutputFormat
    Output format: "Table" (default), "List", "Json"

.PARAMETER IncludeDetails
    Include detailed information about each work item type (states, fields, rules)

.EXAMPLE
    .\Get-DevOpsWorkItemTypes.ps1
    List all work item types in table format

.EXAMPLE
    .\Get-DevOpsWorkItemTypes.ps1 -OutputFormat Json
    Get work item types as JSON

.EXAMPLE
    .\Get-DevOpsWorkItemTypes.ps1 -IncludeDetails
    Get detailed information about each work item type

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
    [switch]$IncludeDetails
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

Write-Host "Discovering work item types in project: $project" -ForegroundColor Cyan
Write-Host "Organization: $organization" -ForegroundColor Gray
Write-Host ""

try {
    # Get process template
    $projectInfo = az devops project show --project $project --output json | ConvertFrom-Json
    $processId = $projectInfo.capabilities.processTemplate.templateTypeId

    Write-Verbose "Process Template ID: $processId"

    # Get work item types
    $witTypes = az boards work-item list --project $project --query "[].fields.'System.WorkItemType'" --output json | ConvertFrom-Json | Select-Object -Unique | Sort-Object

    if ($witTypes.Count -eq 0) {
        Write-Warning "No work item types found. The project may be empty or inaccessible."
        exit 0
    }

    if ($IncludeDetails) {
        Write-Host "Work Item Types (with details):" -ForegroundColor Green
        Write-Host ""

        $detailedTypes = @()

        foreach ($typeName in $witTypes) {
            Write-Verbose "Fetching details for: $typeName"

            # Get sample work item of this type to extract states
            $sampleItems = az boards work-item list --project $project --wiql "SELECT [System.Id] FROM WorkItems WHERE [System.WorkItemType] = '$typeName'" --output json | ConvertFrom-Json

            $states = @()
            if ($sampleItems.Count -gt 0) {
                $sampleItem = az boards work-item show --id $sampleItems[0].id --output json | ConvertFrom-Json
                # Try to get available states (this is simplified, real states would need process template API)
                $currentState = $sampleItem.fields.'System.State'
                $states += $currentState
            }

            $detailedTypes += [PSCustomObject]@{
                Name = $typeName
                Category = Get-WorkItemCategory -TypeName $typeName
                SampleStates = ($states -join ", ")
                Count = $sampleItems.Count
            }
        }

        switch ($OutputFormat) {
            "Table" {
                $detailedTypes | Format-Table -AutoSize
            }
            "List" {
                $detailedTypes | Format-List
            }
            "Json" {
                $detailedTypes | ConvertTo-Json -Depth 10
            }
        }
    }
    else {
        Write-Host "Work Item Types:" -ForegroundColor Green
        Write-Host ""

        $typeObjects = @()
        foreach ($typeName in $witTypes) {
            $typeObjects += [PSCustomObject]@{
                WorkItemType = $typeName
                Category = Get-WorkItemCategory -TypeName $typeName
            }
        }

        switch ($OutputFormat) {
            "Table" {
                $typeObjects | Format-Table -AutoSize
            }
            "List" {
                $typeObjects | Format-List
            }
            "Json" {
                $typeObjects | ConvertTo-Json -Depth 10
            }
        }
    }

    Write-Host ""
    Write-Host "Total types found: $($witTypes.Count)" -ForegroundColor Green
}
catch {
    Write-Error "Failed to retrieve work item types: $_"
    exit 1
}

# Helper function to categorize work item types
function Get-WorkItemCategory {
    param([string]$TypeName)

    switch -Regex ($TypeName) {
        "Epic" { return "Epic" }
        "Feature" { return "Feature" }
        "Product Backlog Item|User Story|PBI" { return "Requirement" }
        "Task" { return "Task" }
        "Bug" { return "Bug" }
        "Test Case|Test Suite" { return "Test" }
        "Issue" { return "Issue" }
        default { return "Other" }
    }
}
