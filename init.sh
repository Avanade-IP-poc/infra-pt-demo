#!/bin/bash
# =============================================================================
# AURORA-IA / AI-DLC - Project Initialization Script v1.0.0
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Configuration variables
PROJECT_SCOPE=""
INFRA_SCOPE=""
BACKEND_LANGUAGE=""
BACKEND_VERSION=""
BACKEND_FRAMEWORK=""
ARCHITECTURE=""
FRONTEND_FRAMEWORK=""
CQRS_ENABLED=""
DOCKER_ENABLED=""
ORCHESTRATION=""
IAC_TOOL=""
CICD_PLATFORM=""
DATABASE=""
DATA_ACCESS=""
ENVIRONMENTS=""
OBSERVABILITY=""
AUTO_MODE=false
AUTO_PROFILE=""
OUTPUT_DIR=""
PROJECT_TYPE=""
SOURCE_DIR=""
AURORA_ROOT=""

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${CYAN}[STEP]${NC} $1"; }

print_banner() {
    echo -e "${MAGENTA}"
    echo "╔═════════════════════════════════════════════════════════════╗"
    echo "║                                                             ║"
    echo "║       █████╗ ██╗   ██╗██████╗  ██████╗ ██████╗  █████╗      ║"
    echo "║      ██╔══██╗██║   ██║██╔══██╗██╔═══██╗██╔══██╗██╔══██╗     ║"
    echo "║      ███████║██║   ██║██████╔╝██║   ██║██████╔╝███████║     ║"
    echo "║      ██╔══██║██║   ██║██╔══██╗██║   ██║██╔══██╗██╔══██║     ║"
    echo "║      ██║  ██║╚██████╔╝██║  ██║╚██████╔╝██║  ██║██║  ██║     ║"
    echo "║      ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝     ║"
    echo "║                                                             ║"
    echo "╚═════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

validate_command_line_config() {
    # Set defaults if not specified
    [ -z "$PROJECT_SCOPE" ] && PROJECT_SCOPE="app-only"
    [ -z "$FRONTEND_FRAMEWORK" ] && FRONTEND_FRAMEWORK="none"
    [ -z "$BACKEND_LANGUAGE" ] && BACKEND_LANGUAGE="csharp"
    [ -z "$ARCHITECTURE" ] && ARCHITECTURE="modular-monolith"
    [ -z "$INFRA_SCOPE" ] && INFRA_SCOPE="workload"
    [ -z "$IAC_TOOL" ] && IAC_TOOL="bicep"
    [ -z "$DOCKER_ENABLED" ] && DOCKER_ENABLED="yes"
    [ -z "$CQRS_ENABLED" ] && CQRS_ENABLED="no"
    
    # Validate project scope
    if [[ "$PROJECT_SCOPE" != "infra-only" && "$PROJECT_SCOPE" != "app-only" && "$PROJECT_SCOPE" != "full-stack" ]]; then
        log_error "Invalid --scope value: $PROJECT_SCOPE. Must be: infra-only, app-only, or full-stack"
        exit 1
    fi
    
    # Validate backend language
    if [[ "$BACKEND_LANGUAGE" != "csharp" && "$BACKEND_LANGUAGE" != "nodejs" ]]; then
        log_error "Invalid --backend value: $BACKEND_LANGUAGE. Must be: csharp or nodejs"
        exit 1
    fi
    
    # Validate frontend framework
    if [[ "$FRONTEND_FRAMEWORK" != "none" && "$FRONTEND_FRAMEWORK" != "react" && "$FRONTEND_FRAMEWORK" != "vue" && "$FRONTEND_FRAMEWORK" != "angular" && "$FRONTEND_FRAMEWORK" != "blazor" ]]; then
        log_error "Invalid --frontend value: $FRONTEND_FRAMEWORK. Must be: none, react, vue, angular, or blazor"
        exit 1
    fi
    
    # Validate architecture
    if [[ "$ARCHITECTURE" != "modular-monolith" && "$ARCHITECTURE" != "microservices" && "$ARCHITECTURE" != "monolith" && "$ARCHITECTURE" != "serverless" && "$ARCHITECTURE" != "event-driven" ]]; then
        log_error "Invalid --architecture value: $ARCHITECTURE. Must be: modular-monolith, microservices, monolith, serverless, or event-driven"
        exit 1
    fi
    
    # Validate infra scope
    if [[ "$INFRA_SCOPE" != "landing-zone" && "$INFRA_SCOPE" != "workload" && "$INFRA_SCOPE" != "both" ]]; then
        log_error "Invalid --infra-scope value: $INFRA_SCOPE. Must be: landing-zone, workload, or both"
        exit 1
    fi
    
    # Validate IAC tool
    if [[ "$IAC_TOOL" != "bicep" && "$IAC_TOOL" != "terraform" && "$IAC_TOOL" != "pulumi" ]]; then
        log_error "Invalid --iac value: $IAC_TOOL. Must be: bicep, terraform, or pulumi"
        exit 1
    fi
    
    # Validate boolean flags
    if [[ "$DOCKER_ENABLED" != "yes" && "$DOCKER_ENABLED" != "no" ]]; then
        log_error "Invalid --docker value: $DOCKER_ENABLED. Must be: yes or no"
        exit 1
    fi
    
    if [[ "$CQRS_ENABLED" != "yes" && "$CQRS_ENABLED" != "no" ]]; then
        log_error "Invalid --cqrs value: $CQRS_ENABLED. Must be: yes or no"
        exit 1
    fi
    
    # Set derived values
    if [ "$BACKEND_LANGUAGE" = "csharp" ]; then
        BACKEND_VERSION=".NET 10"
        BACKEND_FRAMEWORK="Minimal APIs"
        DATA_ACCESS="Entity Framework Core"
    else
        BACKEND_VERSION="Node.js 22"
        BACKEND_FRAMEWORK="NestJS"
        DATA_ACCESS="Prisma"
    fi
    
    DATABASE="PostgreSQL"
    ORCHESTRATION="Docker Compose"
    CICD_PLATFORM="GitHub Actions"
    ENVIRONMENTS="dev,staging,prod"
    OBSERVABILITY="Application Insights"
    
    log_success "Command-line configuration validated successfully"
}

apply_auto_profile() {
    local profile="$1"
    log_step "Applying auto profile: $profile"
    
    case "$profile" in
        "app-dotnet")
            PROJECT_SCOPE="app-only"
            BACKEND_LANGUAGE="csharp"
            ARCHITECTURE="modular-monolith"
            FRONTEND_FRAMEWORK="none"
            DOCKER_ENABLED="yes"
            CQRS_ENABLED="no"
            ;;
        "app-node")
            PROJECT_SCOPE="app-only"
            BACKEND_LANGUAGE="nodejs"
            ARCHITECTURE="modular-monolith"
            FRONTEND_FRAMEWORK="none"
            DOCKER_ENABLED="yes"
            CQRS_ENABLED="no"
            ;;
        "infra-landing")
            PROJECT_SCOPE="infra-only"
            INFRA_SCOPE="landing-zone"
            IAC_TOOL="bicep"
            FRONTEND_FRAMEWORK="none"
            ;;
        "infra-workload")
            PROJECT_SCOPE="infra-only"
            INFRA_SCOPE="workload"
            IAC_TOOL="bicep"
            FRONTEND_FRAMEWORK="none"
            ;;
        "fullstack-react")
            PROJECT_SCOPE="full-stack"
            BACKEND_LANGUAGE="csharp"
            ARCHITECTURE="modular-monolith"
            FRONTEND_FRAMEWORK="react"
            DOCKER_ENABLED="yes"
            CQRS_ENABLED="yes"
            IAC_TOOL="bicep"
            ;;
        "fullstack-vue")
            PROJECT_SCOPE="full-stack"
            BACKEND_LANGUAGE="csharp"
            ARCHITECTURE="modular-monolith"
            FRONTEND_FRAMEWORK="vue"
            DOCKER_ENABLED="yes"
            CQRS_ENABLED="yes"
            IAC_TOOL="bicep"
            ;;
        *)
            log_error "Unknown auto profile: $profile"
            exit 1
            ;;
    esac
    
    # Apply validation after setting profile values
    validate_command_line_config
    
    log_success "Auto profile '$profile' applied successfully"
}

create_project_structure() {
    log_step "Creating new project structure..."
    
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR/docs"
    
    if [ "$PROJECT_SCOPE" = "app-only" ] || [ "$PROJECT_SCOPE" = "full-stack" ]; then
        mkdir -p "$OUTPUT_DIR/src/backend"
        log_info "Created src/backend/ directory (PROJECT_SCOPE: $PROJECT_SCOPE)"
    fi
    
    if [ "$FRONTEND_FRAMEWORK" != "none" ] && ([ "$PROJECT_SCOPE" = "app-only" ] || [ "$PROJECT_SCOPE" = "full-stack" ]); then
        mkdir -p "$OUTPUT_DIR/src/frontend"
        log_info "Created src/frontend/ directory (FRONTEND_FRAMEWORK: $FRONTEND_FRAMEWORK)"
    fi
    
    if [ "$PROJECT_SCOPE" = "infra-only" ] || [ "$PROJECT_SCOPE" = "full-stack" ]; then
        mkdir -p "$OUTPUT_DIR/infra"
        log_info "Created infra/ directory (PROJECT_SCOPE: $PROJECT_SCOPE)"
    fi
    
    if [ "$PROJECT_TYPE" = "brown" ]; then
        mkdir -p "$OUTPUT_DIR/legacy"
        log_info "Created legacy/ directory for brownfield project"
    else
        mkdir -p "$OUTPUT_DIR/origin"
        log_info "Created origin/ directory for greenfield project"
    fi
    
    log_success "Project structure created successfully"
}

copy_legacy_source() {
    if [ "$PROJECT_TYPE" = "brown" ] && [ -n "$SOURCE_DIR" ] && [ -d "$SOURCE_DIR" ]; then
        log_step "Copying legacy source files to legacy/ directory..."
        cp -r "$SOURCE_DIR/"* "$OUTPUT_DIR/legacy/" 2>/dev/null || true
        log_success "Legacy source copied to legacy/"
    fi
}

copy_aurora_framework() {
    log_step "Copying complete AURORA-IA framework..."
    
    AURORA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    log_info "AURORA root detected: $AURORA_ROOT"
    
    log_info "Copying complete .github directory..."
    if [ -d "$AURORA_ROOT/.github" ]; then
        rm -rf "$OUTPUT_DIR/.github" 2>/dev/null || true
        cp -r "$AURORA_ROOT/.github" "$OUTPUT_DIR/" 2>/dev/null || true
        log_success "Complete .github directory copied successfully"
    fi
    
    log_info "Copying complete .aurora directory..."
    if [ -d "$AURORA_ROOT/.aurora" ]; then
        rm -rf "$OUTPUT_DIR/.aurora" 2>/dev/null || true
        cp -r "$AURORA_ROOT/.aurora" "$OUTPUT_DIR/" 2>/dev/null || true
        log_success ".aurora directory copied"
    fi
    
    # Copy framework documentation files from .aurora to project root
    log_info "Copying AURORA framework documentation..."
    if [ -f "$AURORA_ROOT/.aurora/README.md" ]; then
        cp "$AURORA_ROOT/.aurora/README.md" "$OUTPUT_DIR/" 2>/dev/null || true
        log_info "README.md copied to project root"
    fi
    if [ -f "$AURORA_ROOT/.aurora/CHANGELOG.md" ]; then
        cp "$AURORA_ROOT/.aurora/CHANGELOG.md" "$OUTPUT_DIR/" 2>/dev/null || true
        log_info "CHANGELOG.md copied to project root"
    fi
    if [ -f "$AURORA_ROOT/.aurora/CONTRIBUTING.md" ]; then
        cp "$AURORA_ROOT/.aurora/CONTRIBUTING.md" "$OUTPUT_DIR/" 2>/dev/null || true
        log_info "CONTRIBUTING.md copied to project root"
    fi
    if [ -f "$AURORA_ROOT/.aurora/LICENSE" ]; then
        cp "$AURORA_ROOT/.aurora/LICENSE" "$OUTPUT_DIR/" 2>/dev/null || true
        log_info "LICENSE copied to project root"
    fi
    if [ -f "$AURORA_ROOT/.aurora/PENDIENTES.md" ]; then
        cp "$AURORA_ROOT/.aurora/PENDIENTES.md" "$OUTPUT_DIR/" 2>/dev/null || true
        log_info "PENDIENTES.md copied to project root"
    fi
    
    # Copy additional files from AURORA root
    if [ -f "$AURORA_ROOT/INITIALIZER.md" ]; then
        cp "$AURORA_ROOT/INITIALIZER.md" "$OUTPUT_DIR/" 2>/dev/null || true
        log_info "INITIALIZER.md copied to project root"
    fi
    if [ -f "$AURORA_ROOT/USAGE.md" ]; then
        cp "$AURORA_ROOT/USAGE.md" "$OUTPUT_DIR/" 2>/dev/null || true
        log_info "USAGE.md copied to project root"
    fi
    
    log_success "AURORA framework copied successfully"
}

prefill_constitution() {
    log_step "Customizing constitution.md with your configuration..."
    
    local constitution_file="$OUTPUT_DIR/.aurora/memory/constitution.md"
    
    if [ ! -f "$constitution_file" ]; then
        log_warning "Constitution file not found: $constitution_file"
        return
    fi
    
    # ─────────────────────────────────────────────────────────────────────────
    # PROJECT SCOPE
    # ─────────────────────────────────────────────────────────────────────────
    case "$PROJECT_SCOPE" in
        "infra-only")
            sed -i 's/- \[ \] \*\*🏗️ Infrastructure Only\*\*/- [x] **🏗️ Infrastructure Only**/' "$constitution_file"
            ;;
        "app-only")
            sed -i 's/- \[ \] \*\*💻 Application Development Only\*\*/- [x] **💻 Application Development Only**/' "$constitution_file"
            ;;
        "full-stack")
            sed -i 's/- \[ \] \*\*🚀 Full Stack (App + Infrastructure)\*\*/- [x] **🚀 Full Stack (App + Infrastructure)**/' "$constitution_file"
            ;;
    esac
    
    # ─────────────────────────────────────────────────────────────────────────
    # INFRASTRUCTURE SCOPE (for infra-only and full-stack)
    # ─────────────────────────────────────────────────────────────────────────
    if [ "$PROJECT_SCOPE" = "infra-only" ] || [ "$PROJECT_SCOPE" = "full-stack" ]; then
        case "$INFRA_SCOPE" in
            "landing-zone")
                sed -i 's/- \[ \] \*\*Landing Zone\*\*/- [x] **Landing Zone**/' "$constitution_file"
                ;;
            "workload")
                sed -i 's/- \[ \] \*\*Workload Infrastructure\*\*/- [x] **Workload Infrastructure**/' "$constitution_file"
                ;;
            "both")
                sed -i 's/- \[ \] \*\*Both\*\* - Landing Zone + Workload/- [x] **Both** - Landing Zone + Workload/' "$constitution_file"
                ;;
        esac
        
        # IaC Tool
        case "$IAC_TOOL" in
            "bicep")
                sed -i 's/- \[ \] \*\*Azure Bicep\*\*/- [x] **Azure Bicep**/' "$constitution_file"
                ;;
            "terraform")
                sed -i 's/- \[ \] \*\*Terraform\*\*/- [x] **Terraform**/' "$constitution_file"
                ;;
            "pulumi")
                sed -i 's/- \[ \] \*\*Pulumi\*\*/- [x] **Pulumi**/' "$constitution_file"
                ;;
        esac
    fi
    
    # ─────────────────────────────────────────────────────────────────────────
    # BACKEND CONFIGURATION (for app-only and full-stack)
    # ─────────────────────────────────────────────────────────────────────────
    if [ "$PROJECT_SCOPE" = "app-only" ] || [ "$PROJECT_SCOPE" = "full-stack" ]; then
        # Backend Language
        if [ "$BACKEND_LANGUAGE" = "csharp" ]; then
            sed -i 's/- \[ \] \*\*C# \/ \.NET\*\*/- [x] **C# \/ .NET**/' "$constitution_file"
            sed -i 's/Version: \[ \] \.NET 10/Version: [x] .NET 10/' "$constitution_file"
            sed -i 's/API Style: \[ \] Minimal APIs/API Style: [x] Minimal APIs/' "$constitution_file"
            sed -i 's/ORM: \[ \] Entity Framework Core/ORM: [x] Entity Framework Core/' "$constitution_file"
        elif [ "$BACKEND_LANGUAGE" = "nodejs" ]; then
            sed -i 's/- \[ \] \*\*Node\.js \/ TypeScript\*\*/- [x] **Node.js \/ TypeScript**/' "$constitution_file"
            sed -i 's/Version: \[ \] Node\.js 22/Version: [x] Node.js 22/' "$constitution_file"
            sed -i 's/Framework: \[ \] NestJS/Framework: [x] NestJS/' "$constitution_file"
            sed -i 's/ORM: \[ \] Prisma/ORM: [x] Prisma/' "$constitution_file"
        fi
        
        # Architecture Pattern
        case "$ARCHITECTURE" in
            "modular-monolith")
                sed -i 's/- \[ \] \*\*Modular Monolith\*\*/- [x] **Modular Monolith**/' "$constitution_file"
                ;;
            "microservices")
                sed -i 's/- \[ \] \*\*Microservices\*\*/- [x] **Microservices**/' "$constitution_file"
                ;;
            "monolith")
                sed -i 's/- \[ \] \*\*Monolith\*\*/- [x] **Monolith**/' "$constitution_file"
                ;;
            "serverless")
                sed -i 's/- \[ \] \*\*Serverless\*\*/- [x] **Serverless**/' "$constitution_file"
                ;;
            "event-driven")
                sed -i 's/- \[ \] \*\*Event-Driven\*\*/- [x] **Event-Driven**/' "$constitution_file"
                ;;
        esac
        
        # CQRS
        if [ "$CQRS_ENABLED" = "yes" ]; then
            sed -i 's/- \[ \] \*\*CQRS + Event Sourcing\*\*/- [x] **CQRS + Event Sourcing**/' "$constitution_file"
        fi
        
        # Docker
        if [ "$DOCKER_ENABLED" = "yes" ]; then
            sed -i 's/- \[ \] \*\*Docker\*\*/- [x] **Docker**/' "$constitution_file"
            sed -i 's/- \[ \] \*\*Docker Compose\*\*/- [x] **Docker Compose**/' "$constitution_file"
        fi
    fi
    
    # ─────────────────────────────────────────────────────────────────────────
    # FRONTEND FRAMEWORK
    # ─────────────────────────────────────────────────────────────────────────
    if [ "$FRONTEND_FRAMEWORK" != "none" ]; then
        case "$FRONTEND_FRAMEWORK" in
            "react")
                sed -i 's/- \[ \] \*\*React\*\*/- [x] **React**/' "$constitution_file"
                ;;
            "vue")
                sed -i 's/- \[ \] \*\*Vue\.js\*\*/- [x] **Vue.js**/' "$constitution_file"
                ;;
            "angular")
                sed -i 's/- \[ \] \*\*Angular\*\*/- [x] **Angular**/' "$constitution_file"
                ;;
            "blazor")
                sed -i 's/- \[ \] \*\*Blazor\*\*/- [x] **Blazor**/' "$constitution_file"
                ;;
        esac
    fi
    
    log_success "Constitution.md customized with your configuration"
}

generate_project_structure() {
    log_step "Generating project structure for $BACKEND_LANGUAGE + $ARCHITECTURE..."
    
    # ─────────────────────────────────────────────────────────────────────────
    # INFRASTRUCTURE ONLY
    # ─────────────────────────────────────────────────────────────────────────
    if [ "$PROJECT_SCOPE" = "infra-only" ]; then
        generate_infrastructure_only_structure
        return
    fi
    
    # ─────────────────────────────────────────────────────────────────────────
    # C# / .NET STRUCTURES
    # ─────────────────────────────────────────────────────────────────────────
    if [ "$BACKEND_LANGUAGE" = "csharp" ]; then
        case "$ARCHITECTURE" in
            "modular-monolith")
                generate_csharp_modular_monolith
                ;;
            "microservices")
                generate_csharp_microservices
                ;;
            "monolith")
                generate_csharp_monolith
                ;;
            "serverless")
                generate_csharp_serverless
                ;;
            "event-driven")
                generate_csharp_modular_monolith  # Uses modular + CQRS+ES
                ;;
        esac
    # ─────────────────────────────────────────────────────────────────────────
    # NODE.JS / TYPESCRIPT STRUCTURES
    # ─────────────────────────────────────────────────────────────────────────
    else
        case "$ARCHITECTURE" in
            "modular-monolith")
                generate_nodejs_modular_monolith
                ;;
            "microservices")
                generate_nodejs_microservices
                ;;
            "monolith")
                generate_nodejs_monolith
                ;;
            "serverless")
                generate_nodejs_serverless
                ;;
            "event-driven")
                generate_nodejs_modular_monolith  # Uses modular + CQRS+ES
                ;;
        esac
    fi
    
    # ─────────────────────────────────────────────────────────────────────────
    # INFRASTRUCTURE (for full-stack)
    # ─────────────────────────────────────────────────────────────────────────
    if [ "$PROJECT_SCOPE" = "full-stack" ]; then
        generate_infrastructure_structure
    fi
    
    # ─────────────────────────────────────────────────────────────────────────
    # FRONTEND (if selected)
    # ─────────────────────────────────────────────────────────────────────────
    if [ "$FRONTEND_FRAMEWORK" != "none" ]; then
        generate_frontend_placeholder
    fi
    
    log_success "Project structure generated!"
}

populate_origin_directory() {
    if [ "$PROJECT_TYPE" = "green" ]; then
        log_step "Copying greenfield demo from demo/from_rfp/..."
        
        # Get script directory to find demo files
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        
        # Copy RFP demo content ONLY what actually exists
        if [ -d "$SCRIPT_DIR/demo/from_rfp" ]; then
            cp -r "$SCRIPT_DIR/demo/from_rfp/"* "$OUTPUT_DIR/origin/" 2>/dev/null || true
            log_success "Greenfield demo content copied from demo/from_rfp/"
        else
            log_warning "demo/from_rfp/ directory not found"
            echo "# Place your RFP and initial project documents here" > "$OUTPUT_DIR/origin/README.md"
        fi
    fi
}

enhance_brownfield_structure() {
    if [ "$PROJECT_TYPE" = "brown" ]; then
        log_step "Copying legacy demo code from demo/from_old_src/..."
        
        # Get script directory to find demo files
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        
        # Copy legacy COBOL demo content ONLY what actually exists
        if [ -d "$SCRIPT_DIR/demo/from_old_src" ]; then
            cp -r "$SCRIPT_DIR/demo/from_old_src/"* "$OUTPUT_DIR/legacy/" 2>/dev/null || true
            log_success "Legacy demo code copied from demo/from_old_src/"
        else
            log_warning "demo/from_old_src/ directory not found"
            echo "# Place your legacy source code here for analysis" > "$OUTPUT_DIR/legacy/README.md"
        fi
    fi
}

generate_infrastructure_only_structure() {
    log_info "Creating infrastructure-only project structure..."
    
    case "$INFRA_SCOPE" in
        "landing-zone")
            generate_landing_zone_structure
            ;;
        "workload")
            generate_workload_infra_structure
            ;;
        "both")
            generate_landing_zone_structure
            generate_workload_infra_structure
            ;;
    esac
}

generate_landing_zone_structure() {
    log_info "Creating Landing Zone structure..."
    
    mkdir -p "$OUTPUT_DIR/infra/landing-zone/bicep/modules"
    mkdir -p "$OUTPUT_DIR/infra/landing-zone/policies"
    mkdir -p "$OUTPUT_DIR/infra/landing-zone/rbac"
    mkdir -p "$OUTPUT_DIR/infra/landing-zone/scripts"
    
    if [ "$IAC_TOOL" = "terraform" ]; then
        mkdir -p "$OUTPUT_DIR/infra/landing-zone/terraform/modules"
    fi
}

generate_workload_infra_structure() {
    log_info "Creating Workload Infrastructure structure..."
    
    mkdir -p "$OUTPUT_DIR/infra/workload/compute"
    mkdir -p "$OUTPUT_DIR/infra/workload/storage"
    mkdir -p "$OUTPUT_DIR/infra/workload/networking"
    mkdir -p "$OUTPUT_DIR/infra/workload/security"
    mkdir -p "$OUTPUT_DIR/infra/workload/monitoring"
    
    if [ "$IAC_TOOL" = "terraform" ]; then
        mkdir -p "$OUTPUT_DIR/infra/workload/terraform"
    fi
}

generate_infrastructure_structure() {
    log_info "Creating infrastructure structure for full-stack..."
    
    mkdir -p "$OUTPUT_DIR/infra/bicep"
    mkdir -p "$OUTPUT_DIR/infra/scripts"
    mkdir -p "$OUTPUT_DIR/infra/environments/dev"
    mkdir -p "$OUTPUT_DIR/infra/environments/staging"
    mkdir -p "$OUTPUT_DIR/infra/environments/prod"
    
    if [ "$IAC_TOOL" = "terraform" ]; then
        mkdir -p "$OUTPUT_DIR/infra/terraform"
    fi
}

generate_csharp_modular_monolith() {
    log_info "Creating C# Modular Monolith structure..."
    
    # Shared Kernel with CQRS
    mkdir -p "$OUTPUT_DIR/src/backend/Shared/SharedKernel/CQRS"
    mkdir -p "$OUTPUT_DIR/src/backend/Shared/SharedKernel/Domain"
    mkdir -p "$OUTPUT_DIR/src/backend/Shared/SharedKernel/Results"
    mkdir -p "$OUTPUT_DIR/src/backend/Shared/Contracts/IntegrationEvents"
    
    # Sample module structure
    mkdir -p "$OUTPUT_DIR/src/backend/Modules/SampleModule/SampleModule.Domain/Entities"
    mkdir -p "$OUTPUT_DIR/src/backend/Modules/SampleModule/SampleModule.Domain/ValueObjects"
    mkdir -p "$OUTPUT_DIR/src/backend/Modules/SampleModule/SampleModule.Domain/Events"
    mkdir -p "$OUTPUT_DIR/src/backend/Modules/SampleModule/SampleModule.Application/Commands"
    mkdir -p "$OUTPUT_DIR/src/backend/Modules/SampleModule/SampleModule.Application/Queries"
    mkdir -p "$OUTPUT_DIR/src/backend/Modules/SampleModule/SampleModule.Infrastructure/Persistence"
    mkdir -p "$OUTPUT_DIR/src/backend/Modules/SampleModule/SampleModule.Infrastructure/External"
    
    # API Host
    mkdir -p "$OUTPUT_DIR/src/backend/Host/SampleApp.Host"
}

generate_csharp_microservices() {
    log_info "Creating C# Microservices structure..."
    
    # Shared libraries
    mkdir -p "$OUTPUT_DIR/src/backend/Shared/SharedKernel"
    mkdir -p "$OUTPUT_DIR/src/backend/Shared/Contracts"
    mkdir -p "$OUTPUT_DIR/src/backend/Shared/EventBus"
    
    # Sample microservice
    mkdir -p "$OUTPUT_DIR/src/backend/Services/SampleService/SampleService.API"
    mkdir -p "$OUTPUT_DIR/src/backend/Services/SampleService/SampleService.Domain"
    mkdir -p "$OUTPUT_DIR/src/backend/Services/SampleService/SampleService.Application"
    mkdir -p "$OUTPUT_DIR/src/backend/Services/SampleService/SampleService.Infrastructure"
    
    # API Gateway
    mkdir -p "$OUTPUT_DIR/src/backend/Gateway/ApiGateway"
}

generate_csharp_monolith() {
    log_info "Creating C# Monolith structure..."
    
    mkdir -p "$OUTPUT_DIR/src/backend/SampleApp.API/Controllers"
    mkdir -p "$OUTPUT_DIR/src/backend/SampleApp.Domain/Entities"
    mkdir -p "$OUTPUT_DIR/src/backend/SampleApp.Application/Services"
    mkdir -p "$OUTPUT_DIR/src/backend/SampleApp.Infrastructure/Data"
}

generate_csharp_serverless() {
    log_info "Creating C# Serverless structure..."
    
    mkdir -p "$OUTPUT_DIR/src/backend/Functions/SampleFunctions"
    mkdir -p "$OUTPUT_DIR/src/backend/Shared/Models"
    mkdir -p "$OUTPUT_DIR/src/backend/Shared/Services"
}

generate_nodejs_modular_monolith() {
    log_info "Creating Node.js Modular Monolith structure..."
    
    mkdir -p "$OUTPUT_DIR/src/backend/src/shared/domain"
    mkdir -p "$OUTPUT_DIR/src/backend/src/shared/infrastructure"
    mkdir -p "$OUTPUT_DIR/src/backend/src/modules/sample-module/domain"
    mkdir -p "$OUTPUT_DIR/src/backend/src/modules/sample-module/application"
    mkdir -p "$OUTPUT_DIR/src/backend/src/modules/sample-module/infrastructure"
    mkdir -p "$OUTPUT_DIR/src/backend/src/modules/sample-module/presentation"
}

generate_nodejs_microservices() {
    log_info "Creating Node.js Microservices structure..."
    
    mkdir -p "$OUTPUT_DIR/src/backend/shared/contracts"
    mkdir -p "$OUTPUT_DIR/src/backend/shared/utils"
    mkdir -p "$OUTPUT_DIR/src/backend/services/sample-service/src"
    mkdir -p "$OUTPUT_DIR/src/backend/gateway/api-gateway/src"
}

generate_nodejs_monolith() {
    log_info "Creating Node.js Monolith structure..."
    
    mkdir -p "$OUTPUT_DIR/src/backend/src/controllers"
    mkdir -p "$OUTPUT_DIR/src/backend/src/services"
    mkdir -p "$OUTPUT_DIR/src/backend/src/models"
    mkdir -p "$OUTPUT_DIR/src/backend/src/middleware"
}

generate_nodejs_serverless() {
    log_info "Creating Node.js Serverless structure..."
    
    mkdir -p "$OUTPUT_DIR/src/backend/functions"
    mkdir -p "$OUTPUT_DIR/src/backend/shared"
    mkdir -p "$OUTPUT_DIR/src/backend/layers"
}

generate_frontend_placeholder() {
    log_info "Creating frontend placeholder for $FRONTEND_FRAMEWORK..."
    
    cat > "$OUTPUT_DIR/src/frontend/README.md" << EOF
# Frontend - $FRONTEND_FRAMEWORK

> **Note**: This is a placeholder. Generate the actual frontend using:

## React
\`\`\`bash
cd src/frontend && npm create vite@latest . -- --template react-ts
\`\`\`

## Vue.js
\`\`\`bash
cd src/frontend && npm create vue@latest .
\`\`\`

## Angular
\`\`\`bash
cd src/frontend && npx @angular/cli new app --directory .
\`\`\`

## Blazor
\`\`\`bash
cd src/frontend && dotnet new blazorserver  # or blazorwasm
\`\`\`
EOF
}

show_usage() {
    echo "Usage: $0 <output-directory> <project-type> [source-directory] [OPTIONS]"
    echo ""
    echo "Parameters:"
    echo "  output-directory  : Where to create the project structure"
    echo "  project-type      : 'brown' for Brownfield, 'green' for Greenfield"
    echo "  source-directory  : (Required for brown) Directory with existing code/docs"
    echo ""
    echo "Options:"
    echo "  --auto <profile>        : Use predefined configuration profile"
    echo "  --scope <scope>         : Project scope (infra-only, app-only, full-stack)"
    echo "  --backend <lang>        : Backend language (csharp, nodejs)"
    echo "  --frontend <fw>         : Frontend framework (none, react, vue, angular, blazor)"
    echo "  --architecture <arch>   : Architecture pattern (modular-monolith, microservices, monolith, serverless, event-driven)"
    echo "  --infra-scope <scope>   : Infrastructure scope for infra-only (landing-zone, workload, both)"
    echo "  --iac <tool>            : Infrastructure as Code tool (bicep, terraform, pulumi)"
    echo "  --docker <yes/no>       : Enable Docker support"
    echo "  --cqrs <yes/no>         : Enable CQRS pattern"
    echo ""
    echo "Examples:"
    echo "  $0 ~/my-app green --scope app-only --backend csharp --architecture modular-monolith"
    echo "  $0 ~/my-app green --scope full-stack --backend nodejs --frontend react --docker yes"
    echo "  $0 ~/my-infra green --scope infra-only --infra-scope landing-zone --iac bicep"
    exit 1
}

# Parse arguments
if [ $# -lt 2 ]; then
    log_error "Missing required arguments"
    show_usage
fi

OUTPUT_DIR="$1"
PROJECT_TYPE="$2"
shift 2

# Parse source directory (positional argument before flags)
if [ -n "$1" ] && [[ "$1" != --* ]]; then
    SOURCE_DIR="$1"
    shift
fi

# Parse command-line options
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto)
            AUTO_MODE=true
            AUTO_PROFILE="$2"
            shift 2
            ;;
        --scope)
            PROJECT_SCOPE="$2"
            shift 2
            ;;
        --backend)
            BACKEND_LANGUAGE="$2"
            shift 2
            ;;
        --frontend)
            FRONTEND_FRAMEWORK="$2"
            shift 2
            ;;
        --architecture)
            ARCHITECTURE="$2"
            shift 2
            ;;
        --infra-scope)
            INFRA_SCOPE="$2"
            shift 2
            ;;
        --iac)
            IAC_TOOL="$2"
            shift 2
            ;;
        --docker)
            DOCKER_ENABLED="$2"
            shift 2
            ;;
        --cqrs)
            CQRS_ENABLED="$2"
            shift 2
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            ;;
    esac
done

# Validate arguments
if [ "$PROJECT_TYPE" != "green" ] && [ "$PROJECT_TYPE" != "brown" ]; then
    log_error "project-type must be 'green' or 'brown'"
    show_usage
fi

if [ "$PROJECT_TYPE" = "brown" ] && [ -z "$SOURCE_DIR" ]; then
    log_error "source-directory is required for brownfield projects"
    show_usage
fi

if [ "$PROJECT_TYPE" = "brown" ] && [ ! -d "$SOURCE_DIR" ]; then
    log_error "source-directory '$SOURCE_DIR' does not exist"
    exit 1
fi

main() {
    print_banner
    
    log_info "Initializing AURORA-IA project..."
    log_info "  Output Directory: $OUTPUT_DIR"
    if [ "$PROJECT_TYPE" = "green" ]; then
        log_info "  Project Type: $PROJECT_TYPE - Greenfield New Project"
    else
        log_info "  Project Type: $PROJECT_TYPE - Brownfield Legacy Migration"
    fi
    [ -n "$SOURCE_DIR" ] && log_info "  Source Directory: $SOURCE_DIR"
    
    # Determine configuration method
    if [ "$AUTO_MODE" = true ]; then
        apply_auto_profile "$AUTO_PROFILE"
    elif [ -n "$PROJECT_SCOPE" ] || [ -n "$BACKEND_LANGUAGE" ] || [ -n "$FRONTEND_FRAMEWORK" ]; then
        log_info "Using command-line configuration"
        validate_command_line_config
    else
        # Set default values for brownfield or simple configuration
        PROJECT_SCOPE="app-only"
        FRONTEND_FRAMEWORK="react"
        BACKEND_LANGUAGE="csharp"
        log_info "Using default configuration: app-only, React, C#/.NET"
    fi
    
    # Create directory structure
    create_project_structure
    
    # Generate architecture-specific project structure
    generate_project_structure
    
    # Copy AURORA framework
    copy_aurora_framework
    
    # Copy legacy source if brownfield
    copy_legacy_source
    
    # Customize constitution.md with user configuration
    prefill_constitution
    
    # Populate directories based on project type
    populate_origin_directory
    enhance_brownfield_structure
    
    log_success "AURORA-IA project initialization completed!"
    log_info "Project created in: $OUTPUT_DIR"
    log_info ""
    log_info "Configuration used:"
    log_info "  - Project Scope: $PROJECT_SCOPE"
    if [ "$PROJECT_SCOPE" != "infra-only" ]; then
        log_info "  - Backend Language: $BACKEND_LANGUAGE ($BACKEND_VERSION)"
        log_info "  - Architecture: $ARCHITECTURE"
        [ "$CQRS_ENABLED" = "yes" ] && log_info "  - CQRS: Enabled"
        [ "$DOCKER_ENABLED" = "yes" ] && log_info "  - Docker: Enabled"
    fi
    [ "$FRONTEND_FRAMEWORK" != "none" ] && log_info "  - Frontend Framework: $FRONTEND_FRAMEWORK"
    if [ "$PROJECT_SCOPE" = "infra-only" ] || [ "$PROJECT_SCOPE" = "full-stack" ]; then
        log_info "  - Infrastructure Scope: $INFRA_SCOPE"
        log_info "  - IaC Tool: $IAC_TOOL"
    fi
    log_info ""
    log_info "🚀 NEXT STEPS:"
    log_info ""
    log_info "📁 1. Navigate to your project:"
    log_info "   cd $OUTPUT_DIR"
    log_info ""
    
    if [ "$PROJECT_TYPE" = "green" ]; then
        log_info "🌱 GREENFIELD PROJECT SETUP:"
        log_info ""
        log_info "📋 2. Configure project constitution (MANDATORY FIRST STEP):"
        log_info "   - Edit .aurora/memory/constitution.md"
        log_info "   - Mark your project scope: 🏗️ Infra-only, 💻 App-only, or 🚀 Full-stack"
        log_info "   - Select frontend framework, database, deployment options"
        log_info ""
        log_info "📖 3. Review demo requirements in origin/:"
        log_info "   - RFP-Calculator.md shows example requirements format"
        log_info "   - Replace with your actual project requirements"
        log_info ""
        log_info "🔧 4. Start development:"
        if [ "$PROJECT_SCOPE" = "app-only" ] || [ "$PROJECT_SCOPE" = "full-stack" ]; then
            [ -d "$OUTPUT_DIR/src/backend" ] && log_info "   - Backend ($BACKEND_LANGUAGE): src/backend/"
            [ -d "$OUTPUT_DIR/src/frontend" ] && log_info "   - Frontend: src/frontend/"
        fi
        if [ "$PROJECT_SCOPE" = "infra-only" ] || [ "$PROJECT_SCOPE" = "full-stack" ]; then
            log_info "   - Infrastructure: infra/"
        fi
        log_info ""
        log_info "🎯 5. Create your first feature:"
        log_info "   @Aurora Feature"
    else
        log_info "🔄 BROWNFIELD MIGRATION SETUP:"
        log_info ""
        log_info "📋 2. Configure project constitution (MANDATORY FIRST STEP):"
        log_info "   - Edit .aurora/memory/constitution.md"  
        log_info "   - Mark project scope (usually 💻 App-only for migrations)"
        log_info "   - Select target architecture: $ARCHITECTURE"
        log_info "   - Choose modern tech stack vs legacy: $BACKEND_LANGUAGE"
        log_info ""
        log_info "🔍 3. Analyze legacy code in legacy/:"
        log_info "   - CALCMAIN.cbl & CALCENGN.cbl (demo files)"
        log_info "   - Replace with your actual legacy code"
        log_info "   - Document current system architecture and business logic"
        log_info ""
        log_info "📊 4. Create migration strategy:"
        log_info "   - Create analysis docs for architecture, dependencies, risks"
        log_info "   - Plan migration phases (Big Bang vs Incremental)"
        log_info "   - Map COBOL business logic to modern $BACKEND_LANGUAGE patterns"
        log_info ""
        log_info "🔧 5. Start modern development:"
        if [ "$PROJECT_SCOPE" = "app-only" ] || [ "$PROJECT_SCOPE" = "full-stack" ]; then
            [ -d "$OUTPUT_DIR/src/backend" ] && log_info "   - New backend ($BACKEND_LANGUAGE): src/backend/"
            [ -d "$OUTPUT_DIR/src/frontend" ] && log_info "   - Modern frontend: src/frontend/"
        fi
        log_info ""
        log_info "🎯 6. Begin migration analysis:"
        log_info "   @Aurora Legacy"
    fi
    
    log_info ""
    log_info "🛠️  Available AURORA tools:"
    log_info "   .aurora/scripts/ - Development automation scripts"
    log_info "   .github/agents/ - 31 specialized AI agents for different tasks"
    log_info "   @AURORA - Main orchestrator agent"
    log_info ""
    log_info "📚 Need help? Check .aurora/docs/ for guides and documentation"
}

# Run main function
main "$@"