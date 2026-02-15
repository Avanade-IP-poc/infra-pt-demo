# Azure DevOps Sync Scripts

PowerShell scripts for bidirectional synchronization between AURORA specifications and Azure DevOps work items.

## Prerequisites

```powershell
# Install Azure CLI
winget install -e --id Microsoft.AzureCLI

# Install Azure DevOps extension
az extension add --name azure-devops

# Configure credentials (create PAT at https://dev.azure.com/<your-org>/_usersSettings/tokens)
$env:AZURE_DEVOPS_EXT_PAT = "your-personal-access-token"

# Set defaults
az devops configure --defaults organization=https://dev.azure.com/<your-org> project="<your-project>"
```

## Discovery Scripts

Use these scripts to explore your Azure DevOps configuration before syncing.

### Get-DevOpsWorkItemTypes.ps1

Discover available work item types in your project.

```powershell
# List all work item types
.\Get-DevOpsWorkItemTypes.ps1

# Get as JSON
.\Get-DevOpsWorkItemTypes.ps1 -OutputFormat Json

# Include detailed information
.\Get-DevOpsWorkItemTypes.ps1 -IncludeDetails
```

**Output:** Epic, Feature, Product Backlog Item, Task, Bug, etc.

### Get-DevOpsFields.ps1

Discover fields available for work item types.

```powershell
# List common system fields
.\Get-DevOpsFields.ps1

# Get fields for a specific work item type
.\Get-DevOpsFields.ps1 -WorkItemType "Feature"

# Get as JSON
.\Get-DevOpsFields.ps1 -WorkItemType "Task" -OutputFormat Json
```

**Output:** System.Title, System.State, System.AreaPath, custom fields, etc.

### Get-DevOpsSprints.ps1

List sprints/iterations configured in your project.

```powershell
# List current and future sprints
.\Get-DevOpsSprints.ps1

# Include past sprints
.\Get-DevOpsSprints.ps1 -IncludePast

# Get sprints for a specific team
.\Get-DevOpsSprints.ps1 -TeamName "Backend Team"

# Get as JSON
.\Get-DevOpsSprints.ps1 -OutputFormat Json
```

**Output:** Sprint name, path, state (Current/Past/Future), dates

### Get-DevOpsAreas.ps1

List area paths configured in your project.

```powershell
# List all areas
.\Get-DevOpsAreas.ps1

# Display as tree
.\Get-DevOpsAreas.ps1 -OutputFormat Tree

# Get areas for a specific team
.\Get-DevOpsAreas.ps1 -TeamName "Mobile Team"

# Limit depth
.\Get-DevOpsAreas.ps1 -Depth 2
```

**Output:** Area name, path, level, hierarchy

## Resource Creation Scripts

Use these scripts to create sprints and areas as needed.

### New-DevOpsSprint.ps1

Create a new sprint/iteration.

```powershell
# Create a 2-week sprint
.\New-DevOpsSprint.ps1 -Name "Sprint 1" -StartDate "2026-03-01" -FinishDate "2026-03-14"

# Create under a parent path
.\New-DevOpsSprint.ps1 -Name "Q1 Planning" `
    -StartDate "2026-01-01" `
    -FinishDate "2026-03-31" `
    -ParentPath "MyProject\2026"

# Create and assign to a team
.\New-DevOpsSprint.ps1 -Name "Sprint 2" `
    -StartDate "2026-03-15" `
    -FinishDate "2026-03-28" `
    -TeamName "Backend Team"

# Preview without creating
.\New-DevOpsSprint.ps1 -Name "Sprint 3" `
    -StartDate "2026-04-01" `
    -FinishDate "2026-04-14" `
    -DryRun
```

### New-DevOpsArea.ps1

Create a new area path.

```powershell
# Create an area at root level
.\New-DevOpsArea.ps1 -Name "Backend"

# Create under a parent
.\New-DevOpsArea.ps1 -Name "API" -ParentPath "MyProject\Backend"

# Create and assign to a team as default
.\New-DevOpsArea.ps1 -Name "Mobile" -TeamName "Mobile Team" -SetAsDefault

# Preview without creating
.\New-DevOpsArea.ps1 -Name "Services" -DryRun
```

## Synchronization Scripts

Use these scripts to sync between AURORA specs and Azure DevOps.

### Sync-AuroraToDevOps.ps1

Push AURORA specifications to Azure DevOps.

```powershell
# Preview sync (dry run)
.\Sync-AuroraToDevOps.ps1 -FeaturePath "specs/001-feature-name" -DryRun

# Sync only new/changed items
.\Sync-AuroraToDevOps.ps1 -FeaturePath "specs/001-feature-name" -Mode Incremental

# Full sync (recreate all)
.\Sync-AuroraToDevOps.ps1 -FeaturePath "specs/001-feature-name" -Mode Full
```

### Sync-DevOpsStatus.ps1

Pull status updates from Azure DevOps to AURORA.

```powershell
# Pull status updates
.\Sync-DevOpsStatus.ps1 -FeaturePath "specs/001-feature-name"
```

### Import-DevOpsToAurora.ps1

Import existing Azure DevOps work items into AURORA format.

```powershell
# Import a single work item
.\Import-DevOpsToAurora.ps1 -WorkItemId 12345 -OutputPath "specs/002-imported"

# Import with all child items
.\Import-DevOpsToAurora.ps1 -WorkItemId 12345 -OutputPath "specs/002-imported" -IncludeChildren
```

## Typical Workflow

### 1. Initial Setup

```powershell
# Discover project configuration
.\Get-DevOpsWorkItemTypes.ps1
.\Get-DevOpsFields.ps1 -WorkItemType "Feature"
.\Get-DevOpsSprints.ps1
.\Get-DevOpsAreas.ps1 -OutputFormat Tree
```

### 2. Create Structure

```powershell
# Create areas
.\New-DevOpsArea.ps1 -Name "Backend"
.\New-DevOpsArea.ps1 -Name "Frontend"

# Create sprints
.\New-DevOpsSprint.ps1 -Name "Sprint 1" -StartDate "2026-03-01" -FinishDate "2026-03-14"
.\New-DevOpsSprint.ps1 -Name "Sprint 2" -StartDate "2026-03-15" -FinishDate "2026-03-28"
```

### 3. Sync Features

```powershell
# Push feature to DevOps
.\Sync-AuroraToDevOps.ps1 -FeaturePath "specs/001-feature-name"

# Work in Azure DevOps (update statuses, add details, etc.)

# Pull updates back to AURORA
.\Sync-DevOpsStatus.ps1 -FeaturePath "specs/001-feature-name"
```

### 4. Import Existing Work

```powershell
# Import existing DevOps items
.\Import-DevOpsToAurora.ps1 -WorkItemId 12345 -OutputPath "specs/002-imported"
```

## Common Parameters

Most scripts support these common parameters:

- **`-OutputFormat`**: `Table` (default), `List`, `Json`, `Tree` (areas only)
- **`-DryRun`**: Preview changes without executing
- **`-Verbose`**: Show detailed execution logs

## Troubleshooting

### Authentication Issues

```powershell
# Verify PAT is set
$env:AZURE_DEVOPS_EXT_PAT

# Verify configuration
az devops configure --list

# Test connection
az devops project list --output table
```

### Script Execution Policy

```powershell
# If scripts don't run, update execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Path Issues

```powershell
# Use full paths for area/iteration
$fullPath = "$project\$name"

# Encode spaces in paths
$path = [System.Web.HttpUtility]::UrlEncode("My Path\With Spaces")
```

## Related Documentation

- [Azure DevOps CLI Reference](https://learn.microsoft.com/en-us/cli/azure/devops)
- [Work Items REST API](https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/work-items)
- [AURORA Methodology](../../README.md)
- [Field Mappings](../mappings/README.md)

## Support

For issues or questions:

1. Check script help: `Get-Help .\ScriptName.ps1 -Detailed`
2. Run with `-Verbose` for detailed logs
3. Review [Azure DevOps CLI docs](https://learn.microsoft.com/en-us/cli/azure/devops)
