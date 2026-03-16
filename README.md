# Bolt Framework Initializer Scripts v2.0.0

> 🚀 **Project initialization scripts for Bolt Framework AI-Driven Development Lifecycle**

Bolt Framework provides multiple initialization scripts to bootstrap your development projects with the complete Bolt framework, specialized AI agents, and modern architecture patterns.

## 📋 Available Scripts

| Script     | Platform             | Purpose                                                    |
| ---------- | -------------------- | ---------------------------------------------------------- |
| `init.sh`  | Bash/Linux/macOS/WSL | **Primary** - Full-featured initialization script          |
| `init.ps1` | PowerShell/Windows   | **Native Windows** - PowerShell version with same features |

## 🎯 Quick Start

### 🤖 **Interactive Agent (Recommended)**

Use the Bolt Framework agent with the handoffs for guided project creation:

1. **Open GitHub Copilot Chat** in VS Code
2. **Select the Bolt Framework agent** from available agents
3. **Use handoffs** for guided workflows
4. **Answer interactive questions** - the agent will:
   - Dynamically read `init.sh` parameters
   - Ask for destination directory (use relative paths like `../my-project`)
   - Ask for project type (greenfield/brownfield)
   - Ask for all available configuration options
   - Execute the appropriate script automatically

**Benefits:**

- ✅ **No manual script execution** required
- ✅ **Dynamic parameter discovery** - adapts if script changes
- ✅ **Cross-platform compatibility** (automatically uses `bash ./init.sh` on Windows)
- ✅ **Guided configuration** with validation
- ✅ **Always up-to-date** with current script capabilities

### 💻 **Manual Script Execution**

#### Windows (PowerShell)

```powershell
# Greenfield .NET Microservices
./init.ps1 -OutputDirectory "C:\projects\my-app" -ProjectType green -Scope app-only -Backend csharp -Architecture microservices

# Brownfield COBOL Migration
./init.ps1 -OutputDirectory "C:\projects\legacy-migration" -ProjectType brown -SourceDirectory "C:\legacy\cobol" -Backend csharp -Architecture microservices
```

### Linux/macOS/WSL (Bash)

```bash
# Greenfield Node.js Full-Stack
./init.sh ../my-app green --scope full-stack --backend nodejs --frontend react --architecture modular-monolith

# Infrastructure-Only Project
./init.sh ../my-infra green --scope infra-only --infra-scope landing-zone --iac bicep
```

## 📊 Project Types

### 🌱 **Greenfield Projects** (`green`)

- **New projects** starting from scratch
- Copies demo RFP from `demo/from_rfp/` to `origin/`
- Provides requirements template and project organization structure
- Ideal for: New applications, proof of concepts, fresh starts

### 🔄 **Brownfield Projects** (`brown`)

- **Legacy system migration** and modernization
- Copies existing code from source directory to `legacy/`
- Copies demo COBOL files from `demo/from_old_src/` as examples
- Provides migration planning and analysis structure
- Ideal for: COBOL modernization, legacy .NET upgrades, system rewrites

## 🏗️ Project Scopes

### 💻 **App-Only** (`app-only`)

- Application code only (src/backend/, src/frontend/)
- Assumes infrastructure already exists
- Best for: Application development teams

### 🏗️ **Infrastructure-Only** (`infra-only`)

- Infrastructure as Code only (infra/)
- No application code structure
- Best for: Platform teams, DevOps teams

### 🚀 **Full-Stack** (`full-stack`)

- Complete project with both app and infrastructure

## 🚀 Agent-Based Workflow

### How the Init Workspace Agent Works

1. **Dynamic Script Analysis**
   - Reads `init.sh` in real-time to discover available parameters
   - Parses validation rules and option lists automatically
   - Adapts to script changes without manual updates

2. **Interactive Configuration**

   ```text
   Agent asks step-by-step:
   ├── Destination directory (../my-project)
   ├── Project type (green/brown)
   ├── Source directory (if brownfield)
   ├── Scope (app-only/full-stack/infra-only)
   ├── Backend language (csharp/nodejs)
   ├── Frontend framework (react/vue/angular/blazor)
   ├── Architecture pattern (microservices/monolith/etc.)
   └── Additional options (docker, cqrs, etc.)
   ```

3. **Automatic Execution**
   - Builds correct command with all parameters
   - Uses `bash ./init.sh` on Windows for compatibility
   - Handles path conversion (Windows → Unix-style)
   - Shows real-time progress and results

### Example Agent Interaction

```text
🤖 Agent: "Destination directory?"
👤 You: "../my-ecommerce-app"

🤖 Agent: "Project type (green/brown)?"
👤 You: "green"

🤖 Agent: "Scope (app-only/full-stack/infra-only)?"
👤 You: "full-stack"

... (continues with all options) ...

🤖 Agent: Executing: bash ./init.sh ../my-ecommerce-app green --scope full-stack --backend csharp --frontend react --architecture microservices --docker yes
✅ Project created successfully!
```

- Comprehensive structure for end-to-end development
- Best for: Complete solutions, new product development

## 🔧 Architecture Patterns

| Pattern              | Description                           | Best For                         |
| -------------------- | ------------------------------------- | -------------------------------- |
| **Modular Monolith** | Single deployment, modular boundaries | Most teams, easier deployment    |
| **Microservices**    | Independent deployable services       | Large teams, complex domains     |
| **Monolith**         | Traditional layered architecture      | Simple applications, small teams |
| **Serverless**       | Function-as-a-Service architecture    | Event-driven, cost-optimized     |
| **Event-Driven**     | Asynchronous message-based            | High scalability, loose coupling |

## 🛠️ Technology Stacks

### Backend Options

- **C# / .NET 10** - Minimal APIs, Clean Architecture
- **Node.js 22 / TypeScript** - Express, NestJS patterns

### Frontend Options

- **React** - Modern hooks, TypeScript
- **Vue 3** - Composition API
- **Angular** - Latest version
- **Blazor** - Server/WebAssembly
- **None** - Backend-only projects

### Infrastructure Tools

- **Azure Bicep** - Native Azure IaC
- **Terraform** - Multi-cloud IaC
- **Pulumi** - Code-based IaC

## 📁 Generated Structure

```text
my-project/
├── .github/                    # GitHub Actions, Issue Templates, PR Templates
│   ├── agents/                 # 31 specialized AI agents
│   ├── workflows/              # CI/CD pipelines
│   └── prompts/                # Reusable AI prompts
├── .boltf/                    # Bolt framework
│   ├── docs/                   # Framework documentation
│   ├── memory/                 # Project constitution & context
│   └── scripts/                # Development automation
├── origin/                     # Greenfield: RFP & initial docs
├── legacy/                     # Brownfield: Existing code
├── migration/                  # Brownfield: Migration planning
├── src/                        # Application source code
│   ├── backend/                # Backend architecture-specific structure
│   └── frontend/               # Frontend framework structure
├── infra/                      # Infrastructure as Code
└── README.md                   # Project-specific documentation
```

## 🧬 Constitution-Based Development

The **`.boltf/memory/constitution.md`** file acts as your project's **DNA**. All AI agents and development decisions reference this single source of truth.

### Auto-Configured Options

Scripts automatically mark your selected options:

- ✅ Backend language and version
- ✅ Architecture pattern
- ✅ Docker/containerization
- ✅ CQRS pattern (if selected)

### Manual Configuration Required

You must select:

- Project scope (🏗️ Infra-only, 💻 App-only, 🚀 Full-stack)
- Frontend framework (if app development)
- Database technology
- Cloud deployment options
- CI/CD preferences

## 🤖 Bolt Framework Agents

After initialization, use specialized AI agents:

| Agent                 | Purpose               | Usage                               |
| --------------------- | --------------------- | ----------------------------------- |
| `@Bolt Framework`     | Main orchestrator     | Project coordination                |
| `@Bolt Constitution`  | Constitution setup    | Two-step initialization (Step 2)    |
| `@Bolt Provisioner`   | Resource provisioning | Download skills from online sources |
| `@Bolt Feature`       | Feature creation      | New feature development             |
| `@Bolt Implement`     | Code implementation   | Micro-iteration (Bolts) execution   |
| `@Bolt Testing`       | Test generation       | TDD/BDD test automation             |
| `@Bolt Skill Creator` | Skill development     | AI-powered skill creation & testing |
| `@Bolt Architect`     | Architecture design   | System architecture & ADRs          |
| `@Bolt Ops`           | Operations            | Deployment & monitoring             |

### 🚀 Bolt Provisioner - Multi-Source Skill Downloading

The `@Bolt Provisioner` agent automatically provisions resources from multiple sources:

#### Supported Sources

1. **Local Files** (`.boltf/available-skills/`)
   - Auto-selects relevant skills based on your tech stack
   - Example: `.NET backend` → copies all `dotnet-backend/*` skills

2. **Context7** (via MCP)
   - Downloads documentation from Microsoft Learn and other sources
   - Example: Azure Bicep templates, API documentation

3. **Awesome Copilot** (via MCP)
   - Downloads instructions from [Awesome Copilot](https://github.com/github/awesome-copilot) repository
   - Example: Best practices, code patterns

4. **GitHub/Awesome Skills** (via MCP)
   - Clones skill directories from public repositories
   - Example: Terraform modules, specialized testing skills

#### Usage

After running Init.ps1 (Step 1), invoke `@Bolt Constitution` which will offer to provision resources:

```text
User: @Bolt Constitution setup constitution

Agent Response:
✓ Constitution generated
✓ Scopes: backend, frontend, cloud-platform
Ready to provision resources from:
- Local: 8 skills auto-selected
- Context7: 3 templates available
- Awesome Copilot: 2 instructions available

[🚀 Provision Resources] ← Click here

→ Handoff to @Bolt Provisioner
→ Downloads all resources
→ Generates provision report
```

#### Example Provision Report

```markdown
## Provision Report - 2026-02-26

### ✓ Local Files (8 skills)

- backend-testing-dotnet (from .boltf/available-skills/dotnet-backend/)
- tdd-red-green-refactor (from .boltf/available-skills/testing-must/)

### ✓ Context7 Downloads (3 templates)

- Azure App Service Bicep template (Microsoft Learn)
- Source: https://learn.microsoft.com/azure/app-service/...

### ✓ Awesome Copilot Downloads (2 instructions)

- bicep-code-best-practices (azure-cloud-development collection)
- Source: github.com/github/awesome-copilot/...

**Total**: 13 resources provisioned to .github/
```

## 📈 Semantic Versioning

Bolt Framework follows semantic versioning:

- **v2.0.0** - Current stable release
- **v1.x.y** - Feature additions and bug fixes
- **v2.0.0** - Breaking changes (future)

## 🔄 Cross-Platform Usage

### Bash vs PowerShell Equivalence

```bash
# Bash version
./init.sh ../my-project green --scope app-only --backend csharp --architecture microservices

# PowerShell equivalent
./init.ps1 -OutputDirectory ../my-project -ProjectType green -Scope app-only -Backend csharp -Architecture microservices
```

## 🚨 Common Issues

### Windows Path Issues

```powershell
# ❌ Don't use forward slashes on Windows
./init.ps1 -OutputDirectory "../my-project"

# ✅ Use Windows-style paths
./init.ps1 -OutputDirectory "..\my-project"
```

### Missing Source Directory

```bash
# ❌ Missing source for brownfield
./init2.sh ../migration brown

# ✅ Provide source directory
./init2.sh ../migration brown ./existing-code --scope app-only
```

### Permission Issues

```bash
# Make script executable on Unix systems
chmod +x init2.sh
```

## � Python Integration (Optional)

Bolt Framework includes **optional** Python-based scripts for advanced features:

- ✅ **AI-powered skill optimization** - Automatically improve skill descriptions using Claude
- ✅ **Skill evaluation** - Test and benchmark skill triggering accuracy
- ✅ **Advanced scaffolding** - Code generation for frontend components and IaC

### Quick Setup

**Windows (PowerShell):**

```powershell
# One-time setup
.\.boltf\scripts\powershell\Bootstrap-Python.ps1

# Run Python scripts
.\Invoke-PythonScript.ps1 .github\skills\skill-creator\scripts\quick_validate.py my-skill\
```

**Linux/macOS (Bash):**

```bash
# One-time setup
source .boltf/scripts/bash/bootstrap-python.sh

# Activate environment
source .bolt-venv/bin/activate

# Run Python scripts
python .github/skills/skill-creator/scripts/quick_validate.py my-skill/
```

### Requirements

- **Python 3.9+** (download from <https://python.org/downloads/>)
- Packages installed automatically: `anthropic`, `pyyaml`
- **GitHub Copilot** VS Code extension ([`GitHub.copilot`](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot))
- **GitHub Copilot Chat** VS Code extension ([`GitHub.copilot-chat`](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat))
- **Awesome Copilot** plugin ([`kinfey.awesome-copilots`](https://marketplace.visualstudio.com/items?itemName=kinfey.awesome-copilots))

📚 **Full guide**: [docs/python-integration.md](docs/python-integration.md)

> **Note**: Python is NOT required for basic Bolt Framework functionality (init, constitution, specs). It's only needed for advanced AI-powered features.

## �📞 Support

- 📖 **Documentation**: `.boltf/docs/`
- 🤖 **AI Help**: `@Bolt Framework` agent in your project
- 🔧 **Scripts**: `.boltf/scripts/` for development automation
- 📝 **Issues**: Create GitHub issues for bugs or feature requests

---

**Bolt Framework v2.0.0** - AI-Driven Development Lifecycle
