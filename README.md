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

   ```
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

```
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

```
my-project/
├── .github/                    # GitHub Actions, Issue Templates, PR Templates
│   ├── agents/                 # 31 specialized AI agents
│   ├── workflows/              # CI/CD pipelines
│   └── prompts/                # Reusable AI prompts
├── .aurora/                    # Bolt framework
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

The **`.aurora/memory/constitution.md`** file acts as your project's **DNA**. All AI agents and development decisions reference this single source of truth.

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

| Agent             | Purpose             | Usage                   |
| ----------------- | ------------------- | ----------------------- |
| `@Bolt Framework` | Main orchestrator   | Project coordination    |
| `@Bolt Feature`   | Feature creation    | New feature development |
| `@Bolt Legacy`    | Legacy analysis     | Brownfield migration    |
| `@Bolt Architect` | Architecture design | System architecture     |
| `@Bolt Testing`   | Test generation     | Test automation         |
| `@Bolt Ops`       | Operations          | Deployment & monitoring |

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

## 📞 Support

- 📖 **Documentation**: `.aurora/docs/`
- 🤖 **AI Help**: `@Bolt Framework` agent in your project
- 🔧 **Scripts**: `.aurora/scripts/` for development automation
- 📝 **Issues**: Create GitHub issues for bugs or feature requests

---

**Bolt Framework v2.0.0** - AI-Driven Development Lifecycle
