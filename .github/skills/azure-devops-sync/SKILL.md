---
name: azure-devops-sync
description: Bidirectional sync between AURORA specs/ and Azure DevOps work items (Features, User Stories, Tasks)
---

# Azure DevOps Sync

## When to Use

- Push feature specs from `specs/XXX/` to Azure DevOps backlog
- Pull task status updates from DevOps to AURORA
- Import existing DevOps work items into AURORA format
- When creating or updating a feature manually or with @Aurora Feature, @Aurora Clarify or @Aurora Specify agents
- When creating the Technical Plan with @Aurora Plan agent
- When creating the Bolt tasks with @Aurora Bolt agent
- When creating or updating User Stories with @Aurora Use Case agent
- Whenever the user wantks to synchronize with Azure DevOps

## Setup

```powershell
# Install CLI
winget install -e --id Microsoft.AzureCLI
az extension add --name azure-devops

# Configure (create PAT at https://dev.azure.com/<your-org>/_usersSettings/tokens)
$env:AZURE_DEVOPS_EXT_PAT = "your-pat-here"  # Never commit
az devops configure --defaults organization=https://dev.azure.com/<your-org> project="<your-project>"

# Verify configuration
az devops project list --output table
```

## Discovery Scripts

Before syncing, use these scripts to explore your Azure DevOps configuration:

```powershell
# Discover available work item types
.\scripts\Get-DevOpsWorkItemTypes.ps1

# Discover all fields for a work item type
.\scripts\Get-DevOpsFields.ps1 -WorkItemType "Feature"

# List sprints/iterations
.\scripts\Get-DevOpsSprints.ps1

# List areas
.\scripts\Get-DevOpsAreas.ps1
```

## Resource Creation

Create sprints and areas as needed:

```powershell
# Create a new sprint/iteration
.\scripts\New-DevOpsSprint.ps1 -Name "Sprint 1" -StartDate "2026-03-01" -EndDate "2026-03-14"

# Create a new area
.\scripts\New-DevOpsArea.ps1 -Name "Backend" -ParentPath "ProjectName"
```

## Mappings

| AURORA → DevOps   | Source                         | State Mapping                                          |
| ----------------- | ------------------------------ | ------------------------------------------------------ |
| Feature → Feature | `specs/XXX/feature.md`         | DISCOVERY=New, CONSTRUCTION=Active, PRODUCTION=Closed  |
| User Story → PBI  | `requirements/requirements.md` | not-started=New, in-progress=Committed, completed=Done |
| Task → Task       | `planning/tasks.md`            | `[ ]`=To Do, `[x]`=Done                                |

📘 See [mappings/](mappings/) for field mapping JSON files

## Usage

```powershell
# Push specs to DevOps
.\scripts\Sync-AuroraToDevOps.ps1 -FeaturePath "specs/001-feature-name"

# Pull status updates
.\scripts\Sync-DevOpsStatus.ps1 -FeaturePath "specs/001-feature-name"

# Import existing work item
.\scripts\Import-DevOpsToAurora.ps1 -WorkItemId 12345 -OutputPath "specs/002-imported"
```

## Git Integration

Link commits to work items using the `AB#` syntax:

```bash
git commit -m "feat(AB#12345): Implement core feature logic"
```

**Note:** Replace `AB#` with your organization's prefix (e.g., `WI#`, `ID#`, etc.)

## Work flow

1. Check the current feature we are working on (e.g. check the current branch)
2. If the branch is a feature, check if there is a reference to a DevOps work item (e.g. AB#12345) in the commit messages
3. If there is a reference, check if the work item exists in DevOps
4. If it does not exist, create it based on the Bolt Framework documentation, link it to the commit and update the documentation with the new work item ID
5. If the branch is a bolt, check if there is any work item in the documentation.
6. If there is a reference, check if the work item exists in DevOps
7. If it does not exist, create it based on the Bolt Framework documentation, ensure its parent id is the feature, link it to the commit and update the documentation with the new work item ID
8. If it exists, ensure the parent id is correct, link it to the commit and update the documentation if needed

**IMPORTANT**

- This workflow assumes that the branch naming convention includes the feature name (e.g. `feature/time-tracking`) and that commits reference work items using the `AB#` syntax. Adjust as needed for your specific workflow.

## Relationships

- All work items MUST be created with the appropriate parent-child relationships to maintain a clear hierarchy and traceability between features, user stories, and tasks. This ensures that the work items are organized correctly and can be easily navigated within Azure DevOps.
- All work items MSUT be updated with dependences using 'predecessor' and 'successor' links to ensure that the relationships between work items are accurately represented and can be easily tracked within Azure DevOps. This is crucial for effective project management and ensuring that all team members have a clear understanding of the dependencies between different pieces of work.

## Sprints

- All work items MUST be assigned to the correct sprint based on the current development phase and timeline. This ensures that the work is properly scheduled and can be tracked effectively within Azure DevOps, allowing for better planning and resource allocation throughout the project lifecycle.
- The synchronizatiion process MUST review first which Sprints are already available in Azure DevOps and create any missing ones based on the AURORA documentation. This ensures that all work items are assigned to the correct sprint and that the project timeline is accurately reflected in Azure DevOps, facilitating better project management and tracking.

## Areas

- All work items MUST be assigned to the correct area based on the project structure and team organization. This ensures that the work is properly categorized and can be easily filtered and managed within Azure DevOps, allowing for better organization and visibility of the work being done across different teams and components of the project.

## Commits and Status

- Any work item created MUST include the tag 'Bolt Framework' to ensure it is easily identifiable and can be managed appropriately within Azure DevOps.
- All commits that reference a work item MUST be linked to that work item in Azure DevOps to maintain traceability between code changes and the corresponding work items, facilitating better project management and tracking of progress.

## References

- [Azure DevOps CLI Docs](https://learn.microsoft.com/en-us/cli/azure/devops)
- [Work Items REST API](https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/work-items)
- Scripts: `.github/skills/azure-devops-sync/scripts/`
- Mappings: `.github/skills/azure-devops-sync/mappings/`
