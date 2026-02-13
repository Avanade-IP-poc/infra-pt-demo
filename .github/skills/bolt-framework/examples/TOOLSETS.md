# Bolt Framework — Toolset Definitions

> Reference for VS Code built-in tools and MCP server tools used by AURORA agents.
>
> Updated: 2026-02-13 | Based on greedy.agent.md tool inventory

---

## MCP Servers - Complete Catalog

### 1. Context7 — Library Documentation

Up-to-date documentation for any library or framework.

| Tool                          | Description                         |
| ----------------------------- | ----------------------------------- |
| `context7/resolve-library-id` | Resolve library name to Context7 ID |
| `context7/query-docs`         | Query documentation for a library   |

**Wildcard**: `'context7/*'`
**Use when**: Researching frameworks, libraries, APIs, or need current documentation

---

### 2. Awesome Copilot — Templates & Examples

Curated collections of agents, prompts, skills, and instructions.

| Tool                                  | Description                       |
| ------------------------------------- | --------------------------------- |
| `awesome-copilot/list_collections`    | List all available collections    |
| `awesome-copilot/load_collection`     | Load a specific collection        |
| `awesome-copilot/load_instruction`    | Load a specific instruction/agent |
| `awesome-copilot/search_instructions` | Search across all instructions    |

**Wildcard**: `'awesome-copilot/*'`
**Use when**: Creating constitutions, initializing workspaces, finding templates, agent examples
**Critical for**: Bolt Framework, Aurora Constitution, Aurora Templates

---

### 3. Microsoft Docs — Official Documentation

Official Microsoft and Azure documentation.

| Tool                                         | Description                   |
| -------------------------------------------- | ----------------------------- |
| `microsoftdocs/microsoft_docs_search`        | Search Microsoft Learn docs   |
| `microsoftdocs/microsoft_docs_fetch`         | Fetch full documentation page |
| `microsoftdocs/microsoft_code_sample_search` | Search code samples           |

**Wildcard**: `'microsoftdocs/mcp/*'` or `'microsoftdocs/*'`
**Use when**: Microsoft/.NET/Azure stacks, official Microsoft best practices

---

### 4. GitHub — Repository Operations

GitHub repository management and operations.

| Tool                             | Description                              |
| -------------------------------- | ---------------------------------------- |
| `github/assign_copilot_to_issue` | Assign Copilot agent to resolve an issue |
| `github/create_branch`           | Create new branch                        |
| `github/create_or_update_file`   | Create or update single file             |
| `github/create_pull_request`     | Create new pull request                  |
| `github/create_repository`       | Create new GitHub repository             |
| `github/issue_write`             | Create or update issue                   |
| `github/list_branches`           | List repository branches                 |
| `github/list_commits`            | List commits on branch                   |
| `github/list_issue_types`        | List supported issue types for org       |
| `github/list_issues`             | List issues in repository                |
| `github/list_pull_requests`      | List pull requests                       |
| `github/list_releases`           | List releases                            |
| `github/list_tags`               | List tags                                |
| `github/search_code`             | Search code in repositories              |
| `github/search_issues`           | Search issues                            |
| `github/search_pull_requests`    | Search pull requests                     |
| `github/search_repositories`     | Search repositories                      |
| `github/search_users`            | Search users                             |
| `github/merge_pull_request`      | Merge pull request                       |
| `github/update_pull_request`     | Update pull request                      |
| `github/get_commit`              | Get commit details                       |
| `github/get_file_contents`       | Get file contents                        |
| `github/fork_repository`         | Fork repository                          |
| `github/delete_file`             | Delete file                              |
| `github/push_files`              | Push multiple files                      |

**Wildcard**: `'github/*'`
**Use when**: GitHub operations, repository management, CI/CD integration

---

### 5. Azure MCP — Azure Cloud Operations

Comprehensive Azure cloud resource management (hierarchical with `learn=true`).

| Tool                                    | Description                                  |
| --------------------------------------- | -------------------------------------------- |
| `azure-mcp/acr`                         | Azure Container Registry operations          |
| `azure-mcp/advisor`                     | Azure Advisor recommendations                |
| `azure-mcp/aks`                         | Azure Kubernetes Service operations          |
| `azure-mcp/appconfig`                   | App Configuration stores and key-values      |
| `azure-mcp/applens`                     | **Primary diagnostic tool** for Azure issues |
| `azure-mcp/applicationinsights`         | Application Insights components              |
| `azure-mcp/appservice`                  | App Service web apps and databases           |
| `azure-mcp/azd`                         | Azure Developer CLI operations               |
| `azure-mcp/azuremigrate`                | Azure Landing Zone guidance and generation   |
| `azure-mcp/azureterraformbestpractices` | Terraform best practices for Azure           |
| `azure-mcp/bicepschema`                 | Bicep schema and templates                   |
| `azure-mcp/cloudarchitect`              | Cloud architecture guidance                  |
| `azure-mcp/communication`               | Azure Communication Services                 |
| `azure-mcp/compute`                     | Compute resources (VMs, etc.)                |
| `azure-mcp/confidentialledger`          | Confidential Ledger operations               |
| `azure-mcp/cosmos`                      | Cosmos DB operations                         |
| `azure-mcp/documentation`               | Azure documentation search                   |
| `azure-mcp/eventgrid`                   | Event Grid operations                        |
| `azure-mcp/eventhubs`                   | Event Hubs operations                        |
| `azure-mcp/fileshares`                  | File Shares management                       |
| `azure-mcp/foundry`                     | Azure AI Foundry operations                  |
| `azure-mcp/functionapp`                 | Azure Functions management                   |
| `azure-mcp/grafana`                     | Azure Managed Grafana                        |
| `azure-mcp/keyvault`                    | Key Vault operations                         |
| `azure-mcp/kusto`                       | Azure Data Explorer (Kusto)                  |
| `azure-mcp/loadtesting`                 | Load Testing operations                      |
| `azure-mcp/managedlustre`               | Managed Lustre file systems                  |
| `azure-mcp/marketplace`                 | Azure Marketplace operations                 |
| `azure-mcp/monitor`                     | Azure Monitor operations                     |
| `azure-mcp/mysql`                       | Azure Database for MySQL                     |
| `azure-mcp/policy`                      | Azure Policy operations                      |
| `azure-mcp/postgres`                    | Azure Database for PostgreSQL                |
| `azure-mcp/pricing`                     | Azure pricing information                    |
| `azure-mcp/quota`                       | Subscription quotas                          |
| `azure-mcp/redis`                       | Azure Cache for Redis                        |
| `azure-mcp/resourcehealth`              | Resource health status                       |
| `azure-mcp/role`                        | Role assignments and RBAC                    |
| `azure-mcp/search`                      | Azure Cognitive Search                       |
| `azure-mcp/servicebus`                  | Service Bus operations                       |
| `azure-mcp/signalr`                     | Azure SignalR Service                        |
| `azure-mcp/speech`                      | Azure Speech Services                        |
| `azure-mcp/sql`                         | Azure SQL Database                           |
| `azure-mcp/storage`                     | Storage accounts and blobs                   |
| `azure-mcp/storagesync`                 | Azure File Sync                              |
| `azure-mcp/virtualdesktop`              | Azure Virtual Desktop                        |
| `azure-mcp/workbooks`                   | Azure Monitor Workbooks                      |

**Wildcard**: `'azure-mcp/*'`
**Pattern**: Hierarchical - call with `learn=true` to discover sub-commands
**Use when**: Azure cloud operations, resource management, diagnostics

---

### 6. Bicep — Azure IaC

Azure Infrastructure as Code with <bcp language.

| Tool                                        | Description                                   |
| ------------------------------------------- | --------------------------------------------- |
| `bicep/decompile_arm_parameters_file`       | Convert ARM JSON parameters to .bicepparam    |
| `bicep/decompile_arm_template_file`         | Convert ARM JSON template to .bicep           |
| `bicep/format_bicep_file`                   | Format .bicep or .bicepparam files            |
| `bicep/get_az_resource_type_schema`         | Get JSON schema for Azure resource type       |
| `bicep/get_bicep_best_practices`            | Get Bicep coding standards and best practices |
| `bicep/get_bicep_file_diagnostics`          | Analyze Bicep file for errors/warnings        |
| `bicep/get_deployment_snapshot`             | Preview deployment without executing          |
| `bicep/get_file_references`                 | List all file dependencies                    |
| `bicep/list_avm_metadata`                   | List Azure Verified Modules metadata          |
| `bicep/list_az_resource_types_for_provider` | List resource types for provider              |

**Wildcard**: `'bicep/*'`
**Use when**: Azure IaC, Bicep templates, ARM template migration

---

### 7. Azure DevOps — DevOps Platform

Azure DevOps operations (repos, pipelines, work items, wiki).

| Category       | Tools                                                                                                                                            |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Core**       | `list_projects`, `list_project_teams`, `get_identity_ids`                                                                                        |
| **Repos**      | `create_branch`, `create_pull_request`, `update_pull_request`, `list_branches`, `list_pull_requests`, `search_commits`, `get_repo`, `list_repos` |
| **Pipelines**  | `run_pipeline`, `list_runs`, `get_build_status`, `get_builds`, `get_build_definitions`, `get_build_log`                                          |
| **Work Items** | `create_work_item`, `update_work_item`, `get_work_item`, `list_backlog_work_items`, `link_work_item_to_pull_request`                             |
| **Wiki**       | `create_or_update_page`, `get_page`, `get_page_content`, `list_pages`, `list_wikis`                                                              |
| **Search**     | `search_code`, `search_wiki`, `search_workitem`                                                                                                  |
| **Test Plans** | `create_test_plan`, `create_test_suite`, `add_test_cases_to_suite`, `list_test_cases`                                                            |
| **Security**   | `get_alerts`, `get_alert_details` (Advanced Security)                                                                                            |

**Wildcard**: `'azure-devops/*'`
**Use when**: Azure DevOps operations, CI/CD, work item tracking

---

### 8. Angular CLI — Angular Development

Angular CLI operations and documentation.

| Tool                                    | Description                                   |
| --------------------------------------- | --------------------------------------------- |
| `angular-cli/list_projects`             | List Angular workspaces and projects          |
| `angular-cli/get_best_practices`        | Get Angular best practices (version-specific) |
| `angular-cli/search_documentation`      | Search Angular.dev documentation              |
| `angular-cli/ai_tutor`                  | AI tutor for Angular questions                |
| `angular-cli/onpush_zoneless_migration` | Migrate to OnPush + Zoneless                  |

**Wildcard**: `'angular-cli/*'`
**Use when**: Angular development, component generation, best practices

---

### 9. Playwright — Browser Automation

Web browser automation and testing.

| Tool                                  | Description                 |
| ------------------------------------- | --------------------------- |
| `playwright/browser_navigate`         | Navigate to URL             |
| `playwright/browser_click`            | Click element               |
| `playwright/browser_fill_form`        | Fill multiple form fields   |
| `playwright/browser_type`             | Type text                   |
| `playwright/browser_press_key`        | Press keyboard key          |
| `playwright/browser_take_screenshot`  | Capture screenshot          |
| `playwright/browser_snapshot`         | Get page snapshot           |
| `playwright/browser_evaluate`         | Execute JavaScript          |
| `playwright/browser_hover`            | Hover over element          |
| `playwright/browser_drag`             | Drag and drop               |
| `playwright/browser_select_option`    | Select dropdown option      |
| `playwright/browser_file_upload`      | Upload files                |
| `playwright/browser_wait_for`         | Wait for condition          |
| `playwright/browser_console_messages` | Get console messages        |
| `playwright/browser_network_requests` | Get network requests        |
| `playwright/browser_handle_dialog`    | Handle dialog/alert         |
| `playwright/browser_tabs`             | Manage tabs                 |
| `playwright/browser_resize`           | Resize viewport             |
| `playwright/browser_navigate_back`    | Navigate back               |
| `playwright/browser_close`            | Close browser               |
| `playwright/browser_install`          | Install browser             |
| `playwright/browser_run_code`         | Run browser automation code |

**Wildcard**: `'playwright/*'`
**Use when**: Browser automation, E2E testing, web scraping

---

### 10. PrimeNG — Angular UI Components

PrimeNG component documentation and helpers.

| Tool                                   | Description                          |
| -------------------------------------- | ------------------------------------ |
| `primeng/get_component`                | Get detailed component information   |
| `primeng/list_components`              | List all PrimeNG components          |
| `primeng/get_categories`               | Get component categories             |
| `primeng/search_components`            | Search components                    |
| `primeng/get_component_props`          | Get component properties             |
| `primeng/get_component_events`         | Get component events                 |
| `primeng/get_component_methods`        | Get component methods                |
| `primeng/get_component_styles`         | Get component styling options        |
| `primeng/get_component_pt`             | Get PassThrough API                  |
| `primeng/get_component_tokens`         | Get design tokens                    |
| `primeng/get_component_sections`       | Get component sections               |
| `primeng/get_component_slots`          | Get component slots                  |
| `primeng/get_component_import`         | Get import statement                 |
| `primeng/get_component_url`            | Get documentation URL                |
| `primeng/get_example`                  | Get component example                |
| `primeng/list_examples`                | List all examples                    |
| `primeng/generate_component_template`  | Generate basic template              |
| `primeng/find_by_prop`                 | Find components by property          |
| `primeng/find_by_event`                | Find components by event             |
| `primeng/find_components_with_feature` | Find by feature (filter, lazy, etc.) |
| `primeng/compare_components`           | Compare two components               |
| `primeng/export_component_docs`        | Export docs as markdown              |
| `primeng/get_accessibility_info`       | Get WCAG/ARIA info                   |
| `primeng/get_theming_guide`            | Get theming guide                    |
| `primeng/get_icons_guide`              | Get icons guide                      |
| `primeng/migrate_v18_to_v19`           | Migration guide v18→v19              |
| `primeng/migrate_v19_to_v20`           | Migration guide v19→v20              |
| `primeng/migrate_v20_to_v21`           | Migration guide v20→v21              |

**Wildcard**: `'primeng/*'`
**Use when**: PrimeNG Angular components, UI development

---

### 11. SQL Server — Database Operations

Microsoft SQL Server operations.

| Tool                                          | Description                |
| --------------------------------------------- | -------------------------- |
| `ms-mssql.mssql/mssql_connect`                | Connect to SQL Server      |
| `ms-mssql.mssql/mssql_disconnect`             | Disconnect from SQL Server |
| `ms-mssql.mssql/mssql_list_servers`           | List available servers     |
| `ms-mssql.mssql/mssql_list_databases`         | List databases on server   |
| `ms-mssql.mssql/mssql_get_connection_details` | Get connection details     |
| `ms-mssql.mssql/mssql_change_database`        | Change active database     |
| `ms-mssql.mssql/mssql_list_tables`            | List tables in database    |
| `ms-mssql.mssql/mssql_list_schemas`           | List schemas               |
| `ms-mssql.mssql/mssql_list_views`             | List views                 |
| `ms-mssql.mssql/mssql_list_functions`         | List functions             |
| `ms-mssql.mssql/mssql_run_query`              | Execute SQL query          |
| `ms-mssql.mssql/mssql_show_schema`            | Show table/view schema     |

**Wildcard**: `'ms-mssql.mssql/*'`
**Use when**: SQL Server database operations, queries, schema inspection

---

## MCP Server Usage by Domain

| Domain                  | MCP Servers                                           | Priority |
| ----------------------- | ----------------------------------------------------- | -------- |
| **Azure Cloud**         | `'azure-mcp/*'`, `'bicep/*'`, `'microsoftdocs/mcp/*'` | ⭐⭐⭐   |
| **DevOps**              | `'azure-devops/*'`, `'github/*'`                      | ⭐⭐⭐   |
| **Angular Development** | `'angular-cli/*'`, `'primeng/*'`                      | ⭐⭐     |
| **Testing/Automation**  | `'playwright/*'`                                      | ⭐⭐     |
| **Database**            | `'ms-mssql.mssql/*'`                                  | ⭐       |
| **Documentation**       | `'context7/*'`, `'microsoftdocs/mcp/*'`               | ⭐⭐⭐   |
| **Templates/Examples**  | `'awesome-copilot/*'`                                 | ⭐⭐⭐   |

---

## VS Code Built-in Tools

> ⚠️ **IMPORTANT**: All tool names below are the OFFICIAL VS Code tool names.
> Do NOT use short names in isolation - these are NOT recognized by VS Code.

### Tool Namespace Shortcuts

**Namespace shortcuts** automatically include ALL their subtools:

- `search` → includes `search/codebase`, `search/usages`, `search/changes`, and all other search tools
- `execute` → includes `execute/runTests`, `execute/testFailure`, `execute/runInTerminal`, `execute/getTerminalOutput`, `execute/createAndRunTask`, and all other execute tools
- `read` → includes all read/ prefixed tools
- `edit` → includes all edit/ prefixed tools

**Use shortcuts in agent definitions** instead of listing individual subtools.

### Specialized Tools (Not Covered by Shortcuts)

| Tool                     | Description                    | Category   |
| ------------------------ | ------------------------------ | ---------- |
| `extensions`             | VS Code extensions             | Read-only  |
| `installExtension`       | Install extension              | Execute    |
| `problems`               | Problems panel errors/warnings | Read-only  |
| `terminalLastCommand`    | Last terminal command output   | Read-only  |
| `terminalSelection`      | Terminal selection text        | Read-only  |
| `selection`              | Current editor selection       | Read-only  |
| `getProjectSetupInfo`    | Project setup info             | Read-only  |
| `editNotebook`           | Edit notebook                  | Write      |
| `readNotebookCellOutput` | Read notebook cell output      | Read-only  |
| `getNotebookSummary`     | Notebook summary               | Read-only  |
| `newJupyterNotebook`     | Create Jupyter notebook        | Write      |
| `newWorkspace`           | Create workspace               | Write      |
| `vscode`                 | VS Code API operations         | Multi-tool |
| `agent`                  | Agent operations               | Multi-tool |
| `todo`                   | Task management                | Multi-tool |
| `web`                    | Web fetch operations           | Multi-tool |
| `memory`                 | Context memory operations      | Multi-tool |

---

## Toolset Categories for AURORA Agents

> **RECOMMENDED**: Use namespace shortcuts (`search`, `execute`, `read`, `edit`) instead of specific subtools for cleaner, future-proof definitions.

### 1. FULL_PLANNING (Read-Only Analysis)

```yaml
tools: [search, read, problems, agent, 'context7/*', 'awesome-copilot/*', 'microsoftdocs/mcp/*']
```

**Used by**: Plan, Analyze, Status, Alignment, Architect, Tasks, Improve, Retire, Deps

### 2. FULL_IMPLEMENTATION (Read + Write + Execute)

```yaml
tools:
  [
    search,
    read,
    edit,
    execute,
    problems,
    todo,
    agent,
    'context7/*',
    'awesome-copilot/*',
    'microsoftdocs/mcp/*',
  ]
```

**Used by**: Implement, Testing, Review, Micro Iterator

### 3. SPEC_FOCUSED (Specifications)

```yaml
tools:
  [search, read, edit, web, agent, vscode, 'context7/*', 'awesome-copilot/*', 'microsoftdocs/mcp/*']
```

**Used by**: Feature, Specify, Clarify, Use Case, Gherkin, DDD

### 4. DOCS_FOCUSED (Documentation)

```yaml
tools:
  [search, read, edit, web, agent, vscode, 'context7/*', 'awesome-copilot/*', 'microsoftdocs/mcp/*']
```

**Used by**: Documentation, ADR, Postmortem

### 5. OPS_FOCUSED (Operations)

```yaml
tools: [search, read, edit, execute, problems, agent, vscode, 'context7/*', 'microsoftdocs/mcp/*']
```

**Used by**: Ops, Release, Monitoring

### 6. CONSTITUTION_BUILDER (Project Configuration)

```yaml
tools:
  [search, read, edit, web, agent, vscode, 'context7/*', 'awesome-copilot/*', 'microsoftdocs/mcp/*']
```

**Used by**: Constitution

### 7. CICD_FOCUSED (CI/CD & Pipelines)

```yaml
tools:
  [
    search,
    read,
    edit,
    execute,
    web,
    agent,
    vscode,
    'context7/*',
    'awesome-copilot/*',
    'microsoftdocs/mcp/*',
    'azure-devops/*',
  ]
```

**Used by**: CI/CD

### 8. SECURITY_FOCUSED (Security Analysis)

```yaml
tools: [search, read, problems, web, vscode, agent, 'github/*', 'context7/*', 'microsoftdocs/mcp/*']
```

**Used by**: Security

### 9. INIT_WORKSPACE (Workspace Initialization)

```yaml
tools:
  [
    search,
    read,
    edit,
    execute,
    todo,
    web,
    vscode,
    agent,
    memory,
    'github/*',
    'context7/*',
    'awesome-copilot/*',
    'microsoftdocs/mcp/*',
  ]
```

**Used by**: Bolt Framework, Templates

### 10. AZURE_CLOUD (Azure Development)

```yaml
tools:
  [search, read, edit, execute, web, vscode, agent, 'azure-mcp/*', 'bicep/*', 'microsoftdocs/mcp/*']
```

**Use when**: Azure cloud development, Bicep IaC, Azure resource operations

### 11. ANGULAR_DEV (Angular Development)

```yaml
tools:
  [
    search,
    read,
    edit,
    execute,
    web,
    vscode,
    agent,
    'angular-cli/*',
    'primeng/*',
    'context7/*',
    'playwright/*',
  ]
```

**Use when**: Angular application development, component creation

### 12. DATABASE_OPS (Database Operations)

```yaml
tools: [search, read, edit, vscode, agent, 'ms-mssql.mssql/*', 'context7/*']
```

**Use when**: Database operations, SQL queries, schema management

---

## Agent-to-Toolset Mapping

| Agent                 | Toolset              | MCP Servers                                            |
| --------------------- | -------------------- | ------------------------------------------------------ |
| **Bolt Framework**    | INIT_WORKSPACE       | context7, awesome-copilot, microsoftdocs               |
| aurora-constitution   | CONSTITUTION_BUILDER | context7, awesome-copilot, microsoftdocs               |
| aurora-templates      | INIT_WORKSPACE       | context7, awesome-copilot, microsoftdocs               |
| aurora-plan           | FULL_PLANNING        | context7, awesome-copilot, microsoftdocs               |
| aurora-implement      | FULL_IMPLEMENTATION  | context7, awesome-copilot, microsoftdocs               |
| aurora-testing        | FULL_IMPLEMENTATION  | context7, awesome-copilot, microsoftdocs               |
| aurora-review         | FULL_IMPLEMENTATION  | context7, awesome-copilot, microsoftdocs               |
| aurora-micro-iterator | FULL_IMPLEMENTATION  | context7, awesome-copilot, microsoftdocs               |
| aurora-feature        | SPEC_FOCUSED         | context7, awesome-copilot, microsoftdocs               |
| aurora-specify        | SPEC_FOCUSED         | context7, awesome-copilot, microsoftdocs               |
| aurora-clarify        | SPEC_FOCUSED         | context7, awesome-copilot, microsoftdocs               |
| aurora-usecase        | SPEC_FOCUSED         | context7, awesome-copilot, microsoftdocs               |
| aurora-gherkin        | SPEC_FOCUSED         | context7, awesome-copilot, microsoftdocs               |
| aurora-ddd            | SPEC_FOCUSED         | context7, awesome-copilot, microsoftdocs               |
| aurora-docs           | DOCS_FOCUSED         | context7, awesome-copilot, microsoftdocs               |
| bolt-adr              | DOCS_FOCUSED         | context7, awesome-copilot, microsoftdocs               |
| aurora-postmortem     | DOCS_FOCUSED         | context7, awesome-copilot, microsoftdocs               |
| aurora-ops            | OPS_FOCUSED          | context7, microsoftdocs                                |
| aurora-release        | OPS_FOCUSED          | context7, microsoftdocs                                |
| aurora-monitoring     | OPS_FOCUSED          | context7, microsoftdocs                                |
| aurora-cicd           | CICD_FOCUSED         | context7, awesome-copilot, microsoftdocs, azure-devops |
| aurora-security       | SECURITY_FOCUSED     | context7, microsoftdocs                                |
| aurora-analyze        | FULL_PLANNING        | context7, awesome-copilot, microsoftdocs               |
| aurora-status         | FULL_PLANNING        | context7, awesome-copilot, microsoftdocs               |
| aurora-alignment      | FULL_PLANNING        | context7, awesome-copilot, microsoftdocs               |
| aurora-improve        | FULL_PLANNING        | context7, awesome-copilot, microsoftdocs               |
| aurora-tasks          | FULL_PLANNING        | context7, awesome-copilot, microsoftdocs               |
| aurora-architect      | FULL_PLANNING        | context7, awesome-copilot, microsoftdocs               |
| aurora-retire         | FULL_PLANNING        | context7, awesome-copilot, microsoftdocs               |
| aurora-deps           | FULL_PLANNING        | context7, awesome-copilot, microsoftdocs               |

---

## Tool Name Reference

### Namespace Shortcuts (Recommended for Agents)

✅ `search`, `execute`, `read`, `edit`, `web`, `vscode`, `agent`, `todo`, `memory`

**Benefits:**

- Each namespace includes ALL its subtools automatically
- Shorter, cleaner agent definitions
- Future-proof (new subtools automatically included)

### Specialized Tools (Not in Namespaces)

✅ `problems`, `terminalLastCommand`, `selection`, `extensions`, `installExtension`, `getProjectSetupInfo`, `editNotebook`, `readNotebookCellOutput`, `getNotebookSummary`, `newJupyterNotebook`, `newWorkspace`

### MCP Servers (Always Quote Wildcards)

✅ `'context7/*'`, `'awesome-copilot/*'`, `'microsoftdocs/mcp/*'`, `'azure-mcp/*'`, `'bicep/*'`, `'angular-cli/*'`, `'azure-devops/*'`, `'github/*'`, `'playwright/*'`, `'primeng/*'`, `'ms-mssql.mssql/*'`

**Note**: Only `microsoftdocs` uses `/mcp/` in path. All other MCP servers use direct namespace wildcards.
