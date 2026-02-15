<#
.SYNOPSIS
    Discover fields available for work item types in Azure DevOps

.DESCRIPTION
    This script retrieves all fields available for a specific work item type or all types.
    Use this to understand what fields can be set when creating or updating work items.

    Common fields include:
    - System.Title
    - System.State
    - System.AssignedTo
    - System.AreaPath
    - System.IterationPath
    - System.Description
    - Microsoft.VSTS.Common.Priority
    - Custom fields

.PARAMETER WorkItemType
    Work item type to get fields for (e.g., "Feature", "Task", "Bug")
    If not specified, shows common system fields

.PARAMETER OutputFormat
    Output format: "Table" (default), "List", "Json"

.PARAMETER IncludeSystemFields
    Include system fields (defaults to $true for comprehensive view)

.PARAMETER IncludeCustomFields
    Include custom fields (defaults to $true)

.EXAMPLE
    .\Get-DevOpsFields.ps1 -WorkItemType "Feature"
    List all fields for Feature work items

.EXAMPLE
    .\Get-DevOpsFields.ps1 -WorkItemType "Task" -OutputFormat Json
    Get task fields as JSON

.EXAMPLE
    .\Get-DevOpsFields.ps1
    List common system fields

.NOTES
    Requires:
    - Azure DevOps CLI (az devops)
    - AZURE_DEVOPS_EXT_PAT environment variable set
    - az devops configure --defaults organization=... project=...
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$WorkItemType,

    [Parameter(Mandatory = $false)]
    [ValidateSet("Table", "List", "Json")]
    [string]$OutputFormat = "Table",

    [Parameter(Mandatory = $false)]
    [bool]$IncludeSystemFields = $true,

    [Parameter(Mandatory = $false)]
    [bool]$IncludeCustomFields = $true
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

Write-Host "Discovering fields in project: $project" -ForegroundColor Cyan
Write-Host "Organization: $organization" -ForegroundColor Gray
if ($WorkItemType) {
    Write-Host "Work Item Type: $WorkItemType" -ForegroundColor Gray
}
Write-Host ""

try {
    if ($WorkItemType) {
        # Get a sample work item of this type to extract its fields
        Write-Verbose "Querying for $WorkItemType work items..."

        $query = "SELECT [System.Id] FROM WorkItems WHERE [System.WorkItemType] = '$WorkItemType'"
        $workItems = az boards query --wiql $query --project $project --output json | ConvertFrom-Json

        if ($workItems.Count -eq 0) {
            Write-Warning "No work items of type '$WorkItemType' found. Cannot determine fields."
            Write-Host "Tip: Create at least one work item of this type first, or check available types with Get-DevOpsWorkItemTypes.ps1" -ForegroundColor Yellow
            exit 0
        }

        # Get the first work item to examine its fields
        $sampleId = $workItems[0].id
        Write-Verbose "Examining work item ID: $sampleId"

        $workItem = az boards work-item show --id $sampleId --output json | ConvertFrom-Json

        $fields = @()
        foreach ($fieldName in $workItem.fields.PSObject.Properties.Name) {
            $value = $workItem.fields.$fieldName
            $isSystemField = $fieldName -match "^(System|Microsoft\.VSTS)\."
            $isCustomField = -not $isSystemField

            # Filter based on parameters
            if (($isSystemField -and -not $IncludeSystemFields) -or ($isCustomField -and -not $IncludeCustomFields)) {
                continue
            }

            $fields += [PSCustomObject]@{
                FieldName = $fieldName
                Type = Get-FieldType -Value $value
                Category = if ($isSystemField) { "System" } else { "Custom" }
                SampleValue = if ($value -is [string] -and $value.Length -gt 50) { $value.Substring(0, 47) + "..." } else { $value }
            }
        }

        $fields = $fields | Sort-Object Category, FieldName

        Write-Host "Fields for '$WorkItemType' (from sample ID: $sampleId):" -ForegroundColor Green
        Write-Host ""
    }
    else {
        # Show common system fields
        Write-Host "Common System Fields (work item type not specified):" -ForegroundColor Green
        Write-Host ""

        $fields = @(
            [PSCustomObject]@{ FieldName = "System.Id"; Type = "Integer"; Category = "System"; Description = "Unique identifier" }
            [PSCustomObject]@{ FieldName = "System.Title"; Type = "String"; Category = "System"; Description = "Work item title" }
            [PSCustomObject]@{ FieldName = "System.WorkItemType"; Type = "String"; Category = "System"; Description = "Type (Epic, Feature, Task, etc.)" }
            [PSCustomObject]@{ FieldName = "System.State"; Type = "String"; Category = "System"; Description = "Current state" }
            [PSCustomObject]@{ FieldName = "System.AssignedTo"; Type = "Identity"; Category = "System"; Description = "Assigned user" }
            [PSCustomObject]@{ FieldName = "System.AreaPath"; Type = "TreePath"; Category = "System"; Description = "Area classification" }
            [PSCustomObject]@{ FieldName = "System.IterationPath"; Type = "TreePath"; Category = "System"; Description = "Sprint/iteration" }
            [PSCustomObject]@{ FieldName = "System.Description"; Type = "HTML"; Category = "System"; Description = "Description/details" }
            [PSCustomObject]@{ FieldName = "System.Tags"; Type = "String"; Category = "System"; Description = "Tags (semicolon-separated)" }
            [PSCustomObject]@{ FieldName = "System.CreatedDate"; Type = "DateTime"; Category = "System"; Description = "Creation timestamp" }
            [PSCustomObject]@{ FieldName = "System.ChangedDate"; Type = "DateTime"; Category = "System"; Description = "Last modified timestamp" }
            [PSCustomObject]@{ FieldName = "Microsoft.VSTS.Common.Priority"; Type = "Integer"; Category = "System"; Description = "Priority (1-4)" }
            [PSCustomObject]@{ FieldName = "Microsoft.VSTS.Common.AcceptanceCriteria"; Type = "HTML"; Category = "System"; Description = "Acceptance criteria" }
            [PSCustomObject]@{ FieldName = "Microsoft.VSTS.Scheduling.StoryPoints"; Type = "Double"; Category = "System"; Description = "Story points estimation" }
        )
    }

    switch ($OutputFormat) {
        "Table" {
            $fields | Format-Table -AutoSize -Wrap
        }
        "List" {
            $fields | Format-List
        }
        "Json" {
            $fields | ConvertTo-Json -Depth 10
        }
    }

    Write-Host ""
    Write-Host "Total fields: $($fields.Count)" -ForegroundColor Green

    if (-not $WorkItemType) {
        Write-Host ""
        Write-Host "Tip: Use -WorkItemType parameter to see actual fields for a specific type" -ForegroundColor Yellow
        Write-Host "Example: .\Get-DevOpsFields.ps1 -WorkItemType 'Feature'" -ForegroundColor Yellow
    }
}
catch {
    Write-Error "Failed to retrieve fields: $_"
    exit 1
}

# Helper function to determine field type
function Get-FieldType {
    param($Value)

    if ($null -eq $Value) { return "Null" }
    if ($Value -is [int]) { return "Integer" }
    if ($Value -is [double]) { return "Double" }
    if ($Value -is [bool]) { return "Boolean" }
    if ($Value -is [datetime]) { return "DateTime" }
    if ($Value -is [string]) {
        if ($Value -match "^<.*>$") { return "HTML" }
        if ($Value -match "@") { return "Identity/String" }
        return "String"
    }
    if ($Value -is [array]) { return "Array" }
    if ($Value -is [hashtable] -or $Value.GetType().Name -eq "PSCustomObject") { return "Object" }

    return $Value.GetType().Name
}
