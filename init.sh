#!/bin/bash
# =============================================================================
# Bolt Framework - Project Initialization Script v2.0.0
# =============================================================================
# Simplified: fills base constitution articles + generates scopes.yaml
# =============================================================================

set -e

# --- Colors -------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'

# --- Script globals -----------------------------------------------------------
OUTPUT_DIR=""
PROJECT_TYPE=""
SOURCE_DIR=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Decision variables -------------------------------------------------------
D_PRACTICE=""
D_PROJECT_TYPE=""
D_SCOPES=()
D_USE_ASPIRE="false"
D_WORK_MANAGEMENT_TOOL="none"
D_LOCAL_ORCHESTRATION="none"
D_FRONTEND_FRAMEWORK="none"
D_CLOUD_DEV_ENVIRONMENT="none"
D_CONTAINER_RUNTIME="none"
D_ENVIRONMENTS=()
D_CONFIG_MANAGEMENT=""
D_SECRETS_DEV=""
D_FEATURE_FLAGS=""
D_CICD_PLATFORM=""
D_IAC_TOOL=""
D_DEPLOY_STRATEGY=""
D_BRANCH_STRATEGY=""
D_OBSERVABILITY=""
D_VNET=""
D_PRIVATE_ENDPOINTS=""
D_WAF=""
D_ENCRYPTION_KEYS=""
D_PII_HANDLING=""
D_COMPLIANCE=()
D_AUTO_DEPLOY_DEV=""
D_AUTO_DEPLOY_UAT=""
D_AUTO_DEPLOY_PRE=""
D_AUTO_DEPLOY_PROD=""
D_APP_PIPELINE_STAGES=()
D_UNIT_TEST_COVERAGE=0
D_MUTATION_SCORE=0
D_INFRA_PIPELINE_STAGES=()
D_DEPLOY_PIPELINE_STAGES=()
D_INFRA_MONITORING=()

# --- Logging ------------------------------------------------------------------
log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]  ${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERR] ${NC} $1"; }
log_step()    { echo -e "${CYAN}[STEP]${NC} $1"; }

# --- Banner -------------------------------------------------------------------
show_banner() {
    echo -e "${MAGENTA}"
    cat << 'EOF'
╔═════════════════════════════════════════════════════════════╗
║                                                             ║
║       ██████╗  ██████╗ ██╗  ████████╗    ███████╗           ║
║       ██╔══██╗██╔═══██╗██║  ╚══██╔══╝    ██╔════╝           ║
║       ██████╔╝██║   ██║██║     ██║       █████╗             ║
║       ██╔══██╗██║   ██║██║     ██║       ██╔══╝             ║
║       ██████╔╝╚██████╔╝███████╗██║       ██╗     ██║        ║
║       ╚═════╝  ╚═════╝ ╚══════╝╚═╝       ╚═╝     ╚═╝        ║
║                                                             ║
║           Bolt Framework — AI-DLC v2.0.0                    ║
║                                                             ║
╚═════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# --- Usage --------------------------------------------------------------------
show_usage() {
    cat << EOF
Usage:
  ./init.sh --output <path> --type <green|brown> [--source <path>] [--help]

Parameters:
  --output, -o   Where to create the new project
                 • Accepts: Absolute path (/home/user/MyApp) or relative path (./MyApp)
                 • Creates the directory if it doesn't exist

  --type, -t     Type of project to initialize
                 • green  = Greenfield (new project from scratch)
                 • brown  = Brownfield (migration from existing legacy code)

  --source, -s   Source directory — meaning depends on --type:
                 • green: RFP / functional docs folder (copied to origin/)
                 • brown: Legacy source code folder (copied to legacy/) — REQUIRED
                 • Accepts: Absolute path (/home/user/legacy) or relative path (./legacy)
                 • Must exist

  --help, -h     Show this message

The wizard walks you through the mandatory constitution decisions
and generates a scopes.yaml with the selected scopes.
EOF
}

# --- Parse arguments ----------------------------------------------------------
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --output|-o)  OUTPUT_DIR="$2";   shift 2 ;;
            --type|-t)    PROJECT_TYPE="$2"; shift 2 ;;
            --source|-s)  SOURCE_DIR="$2";   shift 2 ;;
            --help|-h)    show_banner; show_usage; exit 0 ;;
            *) log_error "Unknown option: $1"; echo ""; show_usage; exit 1 ;;
        esac
    done
}

# --- Interactive helpers ------------------------------------------------------

REPLY_CHOICE=""
read_choice() {
    local title="$1"; shift
    local default_idx="$1"; shift
    local -a options=()
    local -a values=()

    while [[ $# -gt 0 && "$1" != "---" ]]; do
        options+=("$1"); shift
    done
    shift  # consume ---
    while [[ $# -gt 0 ]]; do
        values+=("$1"); shift
    done

    echo ""
    echo -e "  ${CYAN}${title}${NC}"
    for i in "${!options[@]}"; do
        local n=$(($i + 1))
        local marker=""
        [[ $n -eq $default_idx ]] && marker=" (default)"
        echo "    ${n}. ${options[$i]}${marker}"
    done

    echo -ne "${YELLOW}  Select [1-${#options[@]}] > ${NC}"
    read -r input
    if [[ -z "$input" ]]; then
        input=$default_idx
    fi
    local idx=$(($input - 1))
    if [[ $idx -lt 0 || $idx -ge ${#values[@]} ]]; then
        idx=$(($default_idx - 1))
    fi
    REPLY_CHOICE="${values[$idx]}"
}

REPLY_MULTI=()
read_multi_choice() {
    local title="$1"; shift
    local -a options=()
    local -a values=()

    while [[ $# -gt 0 && "$1" != "---" ]]; do
        options+=("$1"); shift
    done
    shift
    while [[ $# -gt 0 ]]; do
        values+=("$1"); shift
    done

    echo ""
    echo -e "  ${CYAN}${title}${NC}"
    for i in "${!options[@]}"; do
        echo "    $(($i + 1)). ${options[$i]}"
    done

    echo -ne "${YELLOW}  Select (comma-separated, e.g. 1,2,4) > ${NC}"
    read -r raw

    REPLY_MULTI=()
    IFS=',' read -ra tokens <<< "$raw"
    for tok in "${tokens[@]}"; do
        tok=$(echo "$tok" | tr -d ' ')
        if [[ "$tok" =~ ^[0-9]+$ ]]; then
            local idx=$(($tok - 1))
            if [[ $idx -ge 0 && $idx -lt ${#values[@]} ]]; then
                REPLY_MULTI+=("${values[$idx]}")
            fi
        fi
    done
}

REPLY_YN=""
read_yes_no() {
    local question="$1"
    local default_val="$2"
    local hint="y/N"
    [[ "$default_val" == "true" ]] && hint="Y/n"

    echo -ne "${YELLOW}  ${question} [${hint}] > ${NC}"
    read -r ans
    if [[ -z "$ans" ]]; then
        REPLY_YN="$default_val"
        return
    fi
    ans=$(echo "$ans" | tr '[:upper:]' '[:lower:]')
    if [[ "$ans" == "y" ]]; then
        REPLY_YN="true"
    else
        REPLY_YN="false"
    fi
}

test_scope_active() {
    # Check if any of the specified scopes are active
    # Usage: test_scope_active "backend frontend" "${D_SCOPES[@]}"
    # Returns: 0 (true) if any required scope is active, 1 (false) otherwise
    local required_scopes="$1"; shift
    local -a active_scopes=("$@")

    for required in $required_scopes; do
        for active in "${active_scopes[@]}"; do
            if [[ "$active" == "$required" ]]; then
                return 0  # true
            fi
        done
    done
    return 1  # false
}

get_copilot_cli_models() {
    # Query available models from GitHub Copilot CLI
    # Parses 'copilot --help' output to extract the list of available models
    # Returns: Array of model names, or empty array if CLI not available
    local help_text
    help_text=$(copilot --help 2>&1 || true)

    # Parse: --model <model>  Set the AI model to use (choices: "model1", "model2", ...)
    if echo "$help_text" | grep -q "--model <model>.*choices:"; then
        # Extract model names from quoted strings: "claude-sonnet-4.6", "gpt-5.4", etc.
        echo "$help_text" | grep -oP '"\K[^"]+(?=")' | grep -E '^(claude|gpt|gemini)'
    fi
}

REPLY_MODEL=""
select_copilot_model() {
    # Let user select a model from available Copilot CLI models
    # Returns: Selected model name or fallback default
    echo ""
    echo -e "  ${WHITE}🔍 Querying available models from Copilot CLI...${NC}"

    local -a models=()
    mapfile -t models < <(get_copilot_cli_models)

    if [[ ${#models[@]} -eq 0 ]]; then
        log_warn "Could not retrieve model list from CLI. Using default."
        REPLY_MODEL="gpt-5.1"  # Fallback default
        return
    fi

    # Group models by family for better display
    local -a claude_models=()
    local -a gpt_models=()
    local -a gemini_models=()
    local -a other_models=()

    for model in "${models[@]}"; do
        if [[ "$model" == claude* ]]; then
            claude_models+=("$model")
        elif [[ "$model" == gpt* ]]; then
            gpt_models+=("$model")
        elif [[ "$model" == gemini* ]]; then
            gemini_models+=("$model")
        else
            other_models+=("$model")
        fi
    done

    # Reorder: Claude first (best for agents), then GPT, then Gemini, then others
    local -a ordered_models=()
    ordered_models+=("${claude_models[@]}")
    ordered_models+=("${gpt_models[@]}")
    ordered_models+=("${gemini_models[@]}")
    ordered_models+=("${other_models[@]}")

    # Find a sensible default (prefer claude-sonnet-4 or gpt-5.1)
    local default_idx=1
    for i in "${!ordered_models[@]}"; do
        if [[ "${ordered_models[$i]}" == "claude-sonnet-4" ]]; then
            default_idx=$((i + 1))
            break
        elif [[ "${ordered_models[$i]}" == "gpt-5.1" ]]; then
            default_idx=$((i + 1))
        fi
    done

    read_choice "Select AI model for @Bolt Constitution agent:" "$default_idx" \
        "${ordered_models[@]}" \
        --- "${ordered_models[@]}"
    REPLY_MODEL="$REPLY_CHOICE"
}

test_copilot_cli_version() {
    # Check if Copilot CLI is up-to-date
    # Compares installed version against latest available in npm registry
    # Sets: CLI_VERSION_CHECK_RESULT="up-to-date" | "needs-update" | "unknown"
    #       CLI_CURRENT_VERSION, CLI_LATEST_VERSION
    CLI_VERSION_CHECK_RESULT="unknown"
    CLI_CURRENT_VERSION="unknown"
    CLI_LATEST_VERSION="unknown"

    # Get installed version
    local version_output
    version_output=$(copilot --version 2>&1 || true)

    # Parse version: "GitHub Copilot CLI 1.0.4." or similar
    if [[ "$version_output" =~ ([0-9]+\.[0-9]+\.[0-9]+) ]]; then
        CLI_CURRENT_VERSION="${BASH_REMATCH[1]}"
    else
        return 0  # Can't determine version
    fi

    # Get latest version from npm registry (if npm is available)
    if command -v npm &> /dev/null; then
        local latest_version
        latest_version=$(npm view @github/copilot version 2>&1 || true)
        latest_version=$(echo "$latest_version" | tr -d '[:space:]')

        if [[ "$latest_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            CLI_LATEST_VERSION="$latest_version"

            # Simple version comparison (works for semver)
            if [[ "$CLI_CURRENT_VERSION" == "$CLI_LATEST_VERSION" ]] || \
               [[ "$(printf '%s\n' "$CLI_LATEST_VERSION" "$CLI_CURRENT_VERSION" | sort -V | head -n1)" == "$CLI_LATEST_VERSION" ]]; then
                CLI_VERSION_CHECK_RESULT="up-to-date"
            else
                CLI_VERSION_CHECK_RESULT="needs-update"
            fi
        else
            # Could not fetch latest, assume current is ok
            CLI_VERSION_CHECK_RESULT="up-to-date"
        fi
    else
        # npm not available, can't check latest - assume current is ok
        CLI_VERSION_CHECK_RESULT="up-to-date"
    fi
}

# --- Prerequisite checks -----------------------------------------------------
check_prerequisites() {
    if [[ -z "$OUTPUT_DIR" ]]; then
        log_error "OutputDirectory is required (--output)"; exit 1
    fi
    if [[ -z "$PROJECT_TYPE" ]]; then
        log_error "ProjectType is required (--type)"; exit 1
    fi
    if [[ "$PROJECT_TYPE" != "green" && "$PROJECT_TYPE" != "brown" ]]; then
        log_error "ProjectType must be 'green' or 'brown'"; exit 1
    fi
    if [[ "$PROJECT_TYPE" == "brown" && -z "$SOURCE_DIR" ]]; then
        log_error "SourceDirectory is required for brownfield projects (--source)"; exit 1
    fi
    if [[ "$PROJECT_TYPE" == "brown" && ! -d "$SOURCE_DIR" ]]; then
        log_error "Source directory '$SOURCE_DIR' does not exist"; exit 1
    fi
    if [[ -e "$OUTPUT_DIR" && ! -d "$OUTPUT_DIR" ]]; then
        log_error "Output path '$OUTPUT_DIR' exists but is not a directory"; exit 1
    fi
    if [[ -d "$OUTPUT_DIR" ]]; then
        read_yes_no "Output directory '$OUTPUT_DIR' already exists. Overwrite it?" "false"
        if [[ "$REPLY_YN" != "true" ]]; then
            log_error "Cancelled by user"; exit 1
        fi

        local resolved_output_dir
        resolved_output_dir="$(cd "$OUTPUT_DIR" && pwd)"
        local current_dir
        current_dir="$(pwd)"

        if [[ "$resolved_output_dir" == "/" ]]; then
            log_error "Refusing to overwrite the filesystem root"; exit 1
        fi
        if [[ "$resolved_output_dir" == "$current_dir" ]]; then
            log_error "Refusing to overwrite the current working directory"; exit 1
        fi

        rm -rf "$OUTPUT_DIR"
        log_warn "Existing output directory removed: $OUTPUT_DIR"
    fi
}

# --- Collect decisions --------------------------------------------------------

collect_all_decisions() {

    # ── Step 0 — Practice Selection ────────────────────────────────────────
    echo ""
    log_step "Step 0 — Practice Selection"

    echo ""
    echo -e "  ${CYAN}Select a Practice to guide initialization:${NC}"
    echo -e "  ${WHITE}Practice = pre-configured Scopes + specialized workflows${NC}"
    echo ""

    read_choice "Select your Practice" 1 \
        "Apps & Infra    — Web/mobile apps + cloud infrastructure" \
        "Data & AI       — Data platforms, analytics, AI/ML" \
        "CRM             — Dynamics 365, Power Platform" \
        "Custom          — Manual scope selection" \
        --- "Apps & Infra" "Data & AI" "CRM" "Custom"
    D_PRACTICE="$REPLY_CHOICE"

    # ── Article I §1.1 — Active Scopes ──────────────────────────────────────
    echo ""
    log_step "Article I — Active Scopes"

    # Practice → Scopes mapping
    declare -A practice_scopes
    practice_scopes["Apps & Infra"]="backend frontend cloud-platform"
    practice_scopes["Data & AI"]="data ai integration"
    practice_scopes["CRM"]="crm"

    if [[ "$D_PRACTICE" == "Custom" ]]; then
        # Manual selection (original flow)
        echo -e "  ${WHITE}ℹ Manual scope selection mode${NC}"
        read_multi_choice "§1.1  Active scopes (select all that apply)" \
            "backend        — Server-side APIs, services, domain logic" \
            "frontend       — Web/mobile UI, SPA, design system" \
            "cloud-platform — Infrastructure, Landing Zones, IaC" \
            "data           — Databases, ETL/ELT, analytics" \
            "integration    — API management, messaging, connectors" \
            "ai             — AI/ML models, agents, prompt engineering" \
            "crm            — Dynamics 365, Power Platform, Dataverse" \
            --- "backend" "frontend" "cloud-platform" "data" "integration" "ai" "crm"
        D_SCOPES=("${REPLY_MULTI[@]}")
    else
        # Practice-based pre-selection
        local preselected_scopes=(${practice_scopes[$D_PRACTICE]})
        echo -e "  ${GREEN}ℹ Practice '$D_PRACTICE' pre-selects: ${preselected_scopes[*]}${NC}"

        read_yes_no "  Confirm these scopes?" "true"
        if [[ "$REPLY_YN" == "true" ]]; then
            D_SCOPES=("${preselected_scopes[@]}")
        else
            # User wants to customize
            echo -e "  ${WHITE}ℹ Customizing scopes for '$D_PRACTICE' practice${NC}"
            read_multi_choice "§1.1  Active scopes (select all that apply)" \
                "backend        — Server-side APIs, services, domain logic" \
                "frontend       — Web/mobile UI, SPA, design system" \
                "cloud-platform — Infrastructure, Landing Zones, IaC" \
                "data           — Databases, ETL/ELT, analytics" \
                "integration    — API management, messaging, connectors" \
                "ai             — AI/ML models, agents, prompt engineering" \
                "crm            — Dynamics 365, Power Platform, Dataverse" \
                --- "backend" "frontend" "cloud-platform" "data" "integration" "ai" "crm"
            D_SCOPES=("${REPLY_MULTI[@]}")
        fi
    fi

    if [[ ${#D_SCOPES[@]} -eq 0 ]]; then
        log_warn "No scopes selected -- defaulting to 'backend'"
        D_SCOPES=("backend")
    fi

    # Derive project type from selected scopes (replaces former §1.0)
    local has_cloud=false has_app_scope=false
    for s in "${D_SCOPES[@]}"; do
        [[ "$s" == "cloud-platform" ]] && has_cloud=true
        [[ "$s" == "backend" || "$s" == "frontend" || "$s" == "ai" ]] && has_app_scope=true
    done
    if [[ "$has_cloud" == "true" && "$has_app_scope" == "true" ]]; then
        D_PROJECT_TYPE="full-stack"
    elif [[ "$has_cloud" == "true" ]]; then
        D_PROJECT_TYPE="infra-only"
    else
        D_PROJECT_TYPE="app-only"
    fi

    # ── Step 1.5 — .NET Aspire Orchestration (Optional) ────────────────────
    echo ""
    log_step "Step 1.5 — Service Orchestration (.NET Aspire)"

    # Detect multi-service architecture
    local service_count=0
    for s in "${D_SCOPES[@]}"; do
        [[ "$s" == "backend" ]] && ((service_count++))
        [[ "$s" == "frontend" ]] && ((service_count++))
        [[ "$s" == "cloud-platform" || "$s" == "data" || "$s" == "integration" ]] && ((service_count++))
    done

    D_USE_ASPIRE="false"

    # Only recommend Aspire for multi-service architectures with Apps & Infra practice
    if [[ "$D_PRACTICE" == "Apps & Infra" && $service_count -ge 2 ]]; then
        echo ""
        echo -e "  ${CYAN}ℹ Multi-service architecture detected ($service_count+ services)${NC}"
        echo -e "  ${WHITE}.NET Aspire streamlines orchestration for distributed applications.${NC}"
        echo ""
        echo -e "  ${GREEN}✅ Benefits:${NC}"
        echo -e "     ${WHITE}• Automatic service discovery (no hardcoded URLs)${NC}"
        echo -e "     ${WHITE}• Built-in observability dashboard (OpenTelemetry)${NC}"
        echo -e "     ${WHITE}• Simplified local development (one command launches all)${NC}"
        echo -e "     ${WHITE}• Unified deployment to Azure with 'azd'${NC}"
        echo ""
        echo -e "  ${YELLOW}⚠️  Requirements:${NC}"
        echo -e "     ${WHITE}• .NET 8+ SDK${NC}"
        echo -e "     ${WHITE}• Docker Desktop (for local development)${NC}"
        echo -e "     ${WHITE}• AppHost project (orchestrator created during provisioning)${NC}"
        echo ""

        read_yes_no "  Use .NET Aspire for service orchestration?" "true"
        D_USE_ASPIRE="$REPLY_YN"

        if [[ "$D_USE_ASPIRE" == "true" ]]; then
            log_success "Aspire enabled — AppHost and ServiceDefaults will be provisioned"
        else
            log_info "Aspire disabled — using traditional service deployment"
        fi
    else
        # Don't ask for simple architectures
        echo -e "  ${WHITE}ℹ Single-service architecture detected — Aspire not recommended${NC}"
        echo -e "  ${WHITE}.NET Aspire is designed for 2+ services with external resources${NC}"
        D_USE_ASPIRE="false"
    fi

    # ── Step 1.6 — Work Management Tool Integration (Optional) ─────────────
    echo ""
    log_step "Step 1.6 — Work Management Tool Integration"

    echo ""
    echo -e "  ${CYAN}ℹ Bolt Framework can integrate with work management tools${NC}"
    echo -e "  ${WHITE}This enables automatic sync of:${NC}"
    echo -e "     ${WHITE}• Feature specs → Work items/Issues${NC}"
    echo -e "     ${WHITE}• Implementation plans → Tasks${NC}"
    echo -e "     ${WHITE}• Bolt iterations → Status updates${NC}"
    echo ""

    read_choice "Select work management tool (or None for manual tracking)" 1 \
        "None (manual tracking)" \
        "Azure Boards (Azure DevOps work items)" \
        "GitHub Projects (GitHub Issues integration)" \
        "Jira (Atlassian work management)" \
        --- "none" "azure-boards" "github-projects" "jira"
    D_WORK_MANAGEMENT_TOOL="$REPLY_CHOICE"

    if [[ "$D_WORK_MANAGEMENT_TOOL" != "none" ]]; then
        log_success "Work management tool: $D_WORK_MANAGEMENT_TOOL"
        echo -e "  ${WHITE}ℹ Configure connection details in constitution after provisioning${NC}"
    else
        log_info "Manual tracking — no automatic sync configured"
    fi

    # ── Step 1.7 — Development Environment Configuration ───────────────────
    echo ""
    log_step "Step 1.7 — Development Environment Configuration"

    echo ""
    echo -e "  ${CYAN}ℹ Configure your local development environment${NC}"
    echo -e "  ${WHITE}This determines which tools and configurations are provisioned${NC}"
    echo ""

    # Local Orchestration (if multi-service)
    D_LOCAL_ORCHESTRATION="none"
    if [[ $service_count -ge 2 ]]; then
        if [[ "$D_USE_ASPIRE" == "true" ]]; then
            # Aspire selected — use it as orchestration
            D_LOCAL_ORCHESTRATION="aspire"
            log_info "Local orchestration: .NET Aspire (selected in Step 1.5)"
        else
            # Aspire not selected — ask for alternative
            echo -e "  ${YELLOW}Multi-service architecture requires local orchestration${NC}"
            read_choice "Select local orchestration tool" 1 \
                "Docker Compose (YAML-based, simple)" \
                "Kubernetes (minikube/kind for local dev)" \
                "Podman Compose (rootless alternative)" \
                "None (manual service startup)" \
                --- "docker-compose" "kubernetes" "podman" "none"
            D_LOCAL_ORCHESTRATION="$REPLY_CHOICE"
        fi
    fi

    # Frontend Framework (if frontend scope active)
    D_FRONTEND_FRAMEWORK="none"
    local has_frontend=false
    for s in "${D_SCOPES[@]}"; do
        [[ "$s" == "frontend" ]] && has_frontend=true
    done
    if [[ "$has_frontend" == "true" ]]; then
        echo ""
        read_choice "Select frontend framework (provisions matching instructions)" 1 \
            "React (hooks, components, state management)" \
            "Angular (standalone components, signals)" \
            "Vue.js (Composition API, Pinia)" \
            "None or multiple (will provision manually)" \
            --- "react" "angular" "vue" "none"
        D_FRONTEND_FRAMEWORK="$REPLY_CHOICE"

        if [[ "$D_FRONTEND_FRAMEWORK" != "none" ]]; then
            log_success "Framework: $D_FRONTEND_FRAMEWORK — matching instructions enabled"
        fi
    fi

    # Cloud Development Environment
    echo ""
    read_choice "Will you use cloud-based development environments?" 1 \
        "No (local development only)" \
        "GitHub Codespaces (cloud-based VS Code)" \
        "VS Code Remote - Containers (devcontainer.json)" \
        "Both Codespaces + Devcontainers" \
        --- "none" "codespaces" "devcontainers" "both"
    D_CLOUD_DEV_ENVIRONMENT="$REPLY_CHOICE"

    if [[ "$D_CLOUD_DEV_ENVIRONMENT" != "none" ]]; then
        log_success "Cloud dev: $D_CLOUD_DEV_ENVIRONMENT — devcontainer configs will be provisioned"
    fi

    # Container Runtime
    echo ""
    read_choice "Select container runtime (for local development)" 1 \
        "Docker Desktop (standard, includes Compose)" \
        "Podman (rootless, Docker-compatible)" \
        "None (no containerization)" \
        --- "docker" "podman" "none"
    D_CONTAINER_RUNTIME="$REPLY_CHOICE"

    if [[ "$D_CONTAINER_RUNTIME" != "none" ]]; then
        log_success "Container runtime: $D_CONTAINER_RUNTIME"
    fi

    echo ""
    log_step "Article X — Environments & Configuration"

    read_multi_choice "§10.1  Enabled environments" \
        "dev" "uat" "pre" "prod" \
        --- "dev" "uat" "pre" "prod"
    D_ENVIRONMENTS=("${REPLY_MULTI[@]}")
    [[ ${#D_ENVIRONMENTS[@]} -eq 0 ]] && D_ENVIRONMENTS=("dev" "prod")

    # §10.1 Auto-Deploy per environment
    declare -A trigger_map=(["dev"]="On commit to develop" ["uat"]="On PR merge" ["pre"]="Manual trigger" ["prod"]="Manual approval")
    for env in "${D_ENVIRONMENTS[@]}"; do
        local def="false"
        [[ "$env" == "dev" ]] && def="true"
        read_yes_no "§10.1  Auto-deploy ${env}: ${trigger_map[$env]}?" "$def"
        eval "D_AUTO_DEPLOY_${env^^}=\"$REPLY_YN\""
    done

    read_choice "§10.2  Configuration management" 3 \
        "Environment Variables" \
        "appsettings / .env files" \
        "Azure App Config + Key Vault (recommended)" \
        --- "env-vars" "config-files" "app-config-keyvault"
    D_CONFIG_MANAGEMENT="$REPLY_CHOICE"

    read_choice "§10.3  Local dev secrets" 1 \
        "User Secrets (.NET: dotnet user-secrets)" \
        ".env files (gitignored)" \
        "Local Key Vault (dev instance)" \
        --- "user-secrets" "env-files" "local-keyvault"
    D_SECRETS_DEV="$REPLY_CHOICE"

    read_choice "§10.4  Feature flag provider" 1 \
        "None" "Azure App Configuration" "LaunchDarkly" "Unleash" \
        --- "none" "azure-app-config" "launchdarkly" "unleash"
    D_FEATURE_FLAGS="$REPLY_CHOICE"

    echo ""
    log_step "Article XI — CI/CD Pipeline"

    read_choice "§11.1  CI/CD platform" 1 \
        "GitHub Actions" "Azure DevOps Pipelines" \
        --- "github-actions" "azure-devops"
    D_CICD_PLATFORM="$REPLY_CHOICE"

    # §11.1b Infrastructure as Code (if cloud-platform active)
    local has_infra_for_iac=false
    for s in "${D_SCOPES[@]}"; do
        [[ "$s" == "cloud-platform" ]] && has_infra_for_iac=true
    done
    if [[ "$has_infra_for_iac" == "true" ]]; then
        read_choice "§11.1b Infrastructure as Code (IaC) tool" 1 \
            "Bicep          — Azure-native, type-safe (recommended)" \
            "ARM Templates  — Azure-native JSON (legacy)" \
            "Terraform      — Multi-cloud HCL" \
            "Pulumi         — Multi-cloud with programming languages" \
            --- "bicep" "arm" "terraform" "pulumi"
        D_IAC_TOOL="$REPLY_CHOICE"
    else
        D_IAC_TOOL="none"
    fi

    # §11.2 Pipeline Stages — Application
    local has_app=false
    for s in "${D_SCOPES[@]}"; do
        [[ "$s" == "backend" || "$s" == "frontend" || "$s" == "ai" ]] && has_app=true
    done
    if [[ "$has_app" == "true" ]]; then
        read_multi_choice "§11.2  Application pipeline stages" \
            "Build" "Lint/Format" "Unit Tests" "Integration Tests" \
            "Architecture Tests" "Mutation Tests" "Security Scan" \
            "Container Build" "Container Scan" \
            --- "build" "lint-format" "unit-tests" "integration-tests" \
            "architecture-tests" "mutation-tests" "security-scan" \
            "container-build" "container-scan"
        D_APP_PIPELINE_STAGES=("${REPLY_MULTI[@]}")
        if [[ ${#D_APP_PIPELINE_STAGES[@]} -eq 0 ]]; then
            D_APP_PIPELINE_STAGES=("build" "lint-format" "unit-tests" "security-scan")
        fi

        # Thresholds
        local has_ut=false has_mut=false
        for st in "${D_APP_PIPELINE_STAGES[@]}"; do
            [[ "$st" == "unit-tests" ]] && has_ut=true
            [[ "$st" == "mutation-tests" ]] && has_mut=true
        done
        if [[ "$has_ut" == "true" ]]; then
            echo -ne "${YELLOW}  §11.2  Unit test coverage threshold (%) [80] > ${NC}"
            read -r cov
            D_UNIT_TEST_COVERAGE="${cov:-80}"
        fi
        if [[ "$has_mut" == "true" ]]; then
            echo -ne "${YELLOW}  §11.2  Mutation test score threshold (%) [60] > ${NC}"
            read -r mut
            D_MUTATION_SCORE="${mut:-60}"
        fi
    fi

    # §11.2 Pipeline Stages — Infrastructure
    local has_infra=false
    for s in "${D_SCOPES[@]}"; do
        [[ "$s" == "cloud-platform" ]] && has_infra=true
    done
    if [[ "$has_infra" == "true" ]]; then
        read_multi_choice "§11.2  Infrastructure pipeline stages" \
            "IaC Lint" "IaC Validation" "Security Scan" \
            "Cost Estimation" "Compliance Check" \
            --- "iac-lint" "iac-validation" "security-scan" \
            "cost-estimation" "compliance-check"
        D_INFRA_PIPELINE_STAGES=("${REPLY_MULTI[@]}")
        if [[ ${#D_INFRA_PIPELINE_STAGES[@]} -eq 0 ]]; then
            D_INFRA_PIPELINE_STAGES=("iac-lint" "iac-validation" "security-scan")
        fi
    fi

    # §11.2 Deployment Stages (derived from environments)
    D_DEPLOY_PIPELINE_STAGES=("${D_ENVIRONMENTS[@]}")

    read_choice "§11.3  Deployment strategy" 1 \
        "Rolling Update" "Blue-Green" "Canary" "Feature Flags" \
        --- "rolling" "blue-green" "canary" "feature-flags"
    D_DEPLOY_STRATEGY="$REPLY_CHOICE"

    read_choice "§11.4  Branch strategy" 2 \
        "GitFlow  (feature/, develop, release/, main)" \
        "GitHub Flow  (feature/, main)" \
        "Trunk-Based  (short-lived branches, main)" \
        --- "gitflow" "github-flow" "trunk-based"
    D_BRANCH_STRATEGY="$REPLY_CHOICE"

    echo ""
    log_step "Article XII — Observability"

    read_choice "§12.1  Observability strategy" 2 \
        "Azure-Native (Azure Monitor + Application Insights)" \
        "OpenTelemetry -> Azure Monitor Exporter (recommended)" \
        "OpenTelemetry -> Grafana Stack (self-hosted)" \
        --- "azure-native" "otel-azure" "otel-grafana"
    D_OBSERVABILITY="$REPLY_CHOICE"

    # §12.3 Infrastructure Monitoring (conditional)
    local has_infra2=false
    for s in "${D_SCOPES[@]}"; do
        [[ "$s" == "cloud-platform" ]] && has_infra2=true
    done
    if [[ "$has_infra2" == "true" ]]; then
        read_multi_choice "§12.3  Infrastructure monitoring components" \
            "Resource Health (Azure Resource Health)" \
            "Activity Logs (Azure Monitor)" \
            "Diagnostics (Log Analytics)" \
            "Alerts (Azure Monitor Alerts)" \
            "Dashboards (Azure Workbooks / Grafana)" \
            --- "resource-health" "activity-logs" "diagnostics" "alerts" "dashboards"
        D_INFRA_MONITORING=("${REPLY_MULTI[@]}")
        if [[ ${#D_INFRA_MONITORING[@]} -eq 0 ]]; then
            D_INFRA_MONITORING=("resource-health" "activity-logs" "diagnostics" "alerts" "dashboards")
        fi
    fi

    echo ""
    log_step "Article XVI — Security Policies"

    # §16.1 — Network Security (cloud-platform scope only)
    if test_scope_active "cloud-platform" "${D_SCOPES[@]}"; then
        read_yes_no "§16.1  Azure Virtual Network?" "true"
        D_VNET="$REPLY_YN"

        read_yes_no "§16.1  Private Endpoints?" "true"
        D_PRIVATE_ENDPOINTS="$REPLY_YN"

        read_yes_no "§16.1  Web Application Firewall (Front Door)?" "false"
        D_WAF="$REPLY_YN"
    else
        # Default values for projects without cloud-platform scope
        D_VNET="false"
        D_PRIVATE_ENDPOINTS="false"
        D_WAF="false"
        log_info "Network security (VNet, Private Endpoints, WAF) — skipped (no cloud-platform scope)"
    fi

    # §16.2 — Data Security (backend, data, ai scopes)
    if test_scope_active "backend data ai" "${D_SCOPES[@]}"; then
        read_choice "§16.2  Encryption at rest" 1 \
            "Azure-managed keys" "Customer-managed keys" \
            --- "azure-managed" "customer-managed"
        D_ENCRYPTION_KEYS="$REPLY_CHOICE"

        read_choice "§16.2  PII handling" 3 \
            "Anonymization" "Pseudonymization" "Encryption" \
            --- "anonymization" "pseudonymization" "encryption"
        D_PII_HANDLING="$REPLY_CHOICE"
    else
        # Default values for projects without data-related scopes
        D_ENCRYPTION_KEYS="azure-managed"
        D_PII_HANDLING="encryption"
        log_info "Data security (Encryption, PII) — skipped (no backend/data/ai scope)"
    fi

    # §16.3 — Compliance (applies to all scopes)
    read_multi_choice "§16.3  Compliance requirements" \
        "GDPR" "HIPAA" "SOC 2" "PCI-DSS" "None" \
        --- "gdpr" "hipaa" "soc2" "pci-dss" "none"
    D_COMPLIANCE=("${REPLY_MULTI[@]}")
    [[ ${#D_COMPLIANCE[@]} -eq 0 ]] && D_COMPLIANCE=("none")
}

# --- Copy Bolt Framework ------------------------------------------------------

copy_bolt_framework() {
    log_step "Copying Bolt Framework..."

    [[ -d "$SCRIPT_DIR/.github" ]] && cp -r "$SCRIPT_DIR/.github" "$OUTPUT_DIR/.github"
    [[ -d "$SCRIPT_DIR/.boltf" ]] && cp -r "$SCRIPT_DIR/.boltf" "$OUTPUT_DIR/.boltf"

    for f in README.md CHANGELOG.md CONTRIBUTING.md LICENSE PENDIENTES.md; do
        [[ -f "$SCRIPT_DIR/.boltf/$f" ]] && cp "$SCRIPT_DIR/.boltf/$f" "$OUTPUT_DIR/$f"
    done
    for f in INITIALIZER.md USAGE.md; do
        [[ -f "$SCRIPT_DIR/$f" ]] && cp "$SCRIPT_DIR/$f" "$OUTPUT_DIR/$f"
    done

    log_success "Bolt Framework copied"
}

# --- Create directory structure -----------------------------------------------

create_project_structure() {
    log_step "Creating project structure..."

    mkdir -p "$OUTPUT_DIR"

    if [[ "$PROJECT_TYPE" == "green" ]]; then
        mkdir -p "$OUTPUT_DIR/origin"
    else
        mkdir -p "$OUTPUT_DIR/legacy"
        mkdir -p "$OUTPUT_DIR/migration"
    fi

    local has_scope
    has_scope() { printf '%s\n' "${D_SCOPES[@]}" | grep -qx "$1"; }

    if has_scope "backend" || has_scope "ai"; then
        mkdir -p "$OUTPUT_DIR/src/backend"
    fi
    if has_scope "frontend"; then
        mkdir -p "$OUTPUT_DIR/src/frontend"
    fi
    if has_scope "cloud-platform"; then
        mkdir -p "$OUTPUT_DIR/infra"
    fi
    if has_scope "data"; then
        mkdir -p "$OUTPUT_DIR/data"
    fi

    mkdir -p "$OUTPUT_DIR/docs"

    log_success "Project structure created"
}

# --- Generate scopes.yaml ----------------------------------------------------

generate_scopes_yaml() {
    log_step "Generating scopes.yaml..."

    local scopes_dir="$OUTPUT_DIR/.boltf"
    mkdir -p "$scopes_dir"

    local scopes_yaml=""
    for s in "${D_SCOPES[@]}"; do
        scopes_yaml+="  - ${s}
"
    done

    # Pre-compute yaml fragments
    local env_list=""
    for e in "${D_ENVIRONMENTS[@]}"; do
        [[ -n "$env_list" ]] && env_list+=", "
        env_list+="$e"
    done

    local auto_deploy_lines=""
    for env in "${D_ENVIRONMENTS[@]}"; do
        local varname="D_AUTO_DEPLOY_${env^^}"
        local val="${!varname:-false}"
        auto_deploy_lines+="      ${env}: ${val}
"
    done

    local app_stages=""
    for st in "${D_APP_PIPELINE_STAGES[@]}"; do
        [[ -n "$app_stages" ]] && app_stages+=", "
        app_stages+="$st"
    done
    [[ -z "$app_stages" ]] && app_stages=""

    local infra_stages=""
    for st in "${D_INFRA_PIPELINE_STAGES[@]}"; do
        [[ -n "$infra_stages" ]] && infra_stages+=", "
        infra_stages+="$st"
    done
    [[ -z "$infra_stages" ]] && infra_stages=""

    local deploy_stages=""
    for env in "${D_DEPLOY_PIPELINE_STAGES[@]}"; do
        [[ -n "$deploy_stages" ]] && deploy_stages+=", "
        deploy_stages+="deploy-${env}"
    done
    [[ -z "$deploy_stages" ]] && deploy_stages=""

    local infra_mon=""
    for m in "${D_INFRA_MONITORING[@]}"; do
        [[ -n "$infra_mon" ]] && infra_mon+=", "
        infra_mon+="$m"
    done
    [[ -z "$infra_mon" ]] && infra_mon=""

    local compliance=""
    for c in "${D_COMPLIANCE[@]}"; do
        [[ -n "$compliance" ]] && compliance+=", "
        compliance+="$c"
    done

    cat > "$scopes_dir/scopes.yaml" << YAML
# =============================================================================
# Bolt Framework -- Active Scopes Configuration
# Generated: $(date '+%Y-%m-%d %H:%M:%S')
# =============================================================================
# This file declares which scopes are active and records all wizard decisions.
# Each scope injects its own constitution sections from
#   .boltf/scopes/<scope>/memory/constitution.md
# The work-management scope is always active (transversal).
# =============================================================================

project:
  practice: ${D_PRACTICE}               # Apps & Infra | Data & AI | CRM | Custom
  type: ${D_PROJECT_TYPE}               # derived from scopes
  migration-type: ${PROJECT_TYPE}       # green | brown
  use-aspire: ${D_USE_ASPIRE}           # Aspire orchestration (Step 1.5)
  work-management-tool: ${D_WORK_MANAGEMENT_TOOL}  # azure-boards | github-projects | jira | none

  # Development Environment (Step 1.7)
  local-orchestration: ${D_LOCAL_ORCHESTRATION}     # docker-compose | kubernetes | podman | aspire | none
  frontend-framework: ${D_FRONTEND_FRAMEWORK}       # react | angular | vue | none
  cloud-dev-environment: ${D_CLOUD_DEV_ENVIRONMENT} # codespaces | devcontainers | both | none
  container-runtime: ${D_CONTAINER_RUNTIME}         # docker | podman | none

active-scopes:
${scopes_yaml}
# Transversal (always active, not selectable)
transversal-scopes:
  - work-management

# --- Wizard Decisions --------------------------------------------------------
# These capture every choice made during initialization so downstream agents
# can read them without re-parsing the constitution markdown.

decisions:
  # Article X -- Environments & Configuration
  environments:
    enabled: [${env_list}]
    auto-deploy:
${auto_deploy_lines}  config-management: ${D_CONFIG_MANAGEMENT}
  secrets-dev: ${D_SECRETS_DEV}
  feature-flags: ${D_FEATURE_FLAGS}

  # Article XI -- CI/CD Pipeline
  cicd:
    platform: ${D_CICD_PLATFORM}
    iac-tool: ${D_IAC_TOOL}
    deploy-strategy: ${D_DEPLOY_STRATEGY}
    branch-strategy: ${D_BRANCH_STRATEGY}
    pipeline-stages:
      application: [${app_stages}]
      infrastructure: [${infra_stages}]
      deployment: [${deploy_stages}]
    thresholds:
      unit-test-coverage: ${D_UNIT_TEST_COVERAGE}
      mutation-score: ${D_MUTATION_SCORE}

  # Article XII -- Observability
  observability: ${D_OBSERVABILITY}
  infra-monitoring: [${infra_mon}]

  # Article XVI -- Security Policies
  security:
    vnet: ${D_VNET}
    private-endpoints: ${D_PRIVATE_ENDPOINTS}
    waf: ${D_WAF}
    encryption-keys: ${D_ENCRYPTION_KEYS}
    pii-handling: ${D_PII_HANDLING}
    compliance: [${compliance}]

# Base constitution articles (always present):
#   I   -- Project Scope & Type
#   X   -- Environments & Configuration
#   XI  -- CI/CD Pipeline
#   XII -- Observability
#   XVI -- Security Policies
#   XIX -- Governance
YAML

    log_success "scopes.yaml generated at .boltf/scopes.yaml"
}

# --- Prefill constitution -----------------------------------------------------

prefill_constitution() {
    log_step "Generating constitution files (init + per-scope)..."

    local memory_dir="$OUTPUT_DIR/.boltf/memory"
    mkdir -p "$memory_dir"

    local date=$(date '+%Y-%m-%d %H:%M:%S')
    local boltf_root="$SCRIPT_DIR"

    # Build scope list
    local scopes_list=""
    for scope in "${D_SCOPES[@]}"; do
        scopes_list+="- **${scope}**: Scope provisions tech stack, patterns, and quality gates"$'\n'
    done

    # Build scope file links
    local scope_links=""
    for scope in "${D_SCOPES[@]}"; do
        scope_links+="- [${scope}-constitution.md](./${scope}-constitution.md)"$'\n'
    done

    # 1) Create constitution-init.md (base constitution with metadata)
    local init_path="$memory_dir/constitution-init.md"
    cat > "$init_path" << EOF
# Project Constitution (Initial)

> **Generated**: $date
> **Practice**: $D_PRACTICE
> **Active Scopes**: ${D_SCOPES[*]}
> **Project Type**: $D_PROJECT_TYPE ($PROJECT_TYPE)

---

# Article I §1.1 — Active Scopes

The following scopes are active for this project:

$scopes_list

---

# Processing Instructions

This is the base constitution file created during initialization.
Each active scope has its own constitution file: **<scope>-constitution.md**

The @Bolt Constitution agent will process each scope file separately and merge
all refinement decisions into a final **constitution.md** file.

## Scope Constitution Files

$scope_links

---

**Generated by Bolt Framework init.sh** on $date
EOF

    log_success "Created base constitution: constitution-init.md"

    # 2) Create separate constitution file for each scope
    local copied_count=0
    for scope in "${D_SCOPES[@]}"; do
        local scope_constitution_path="$boltf_root/.boltf/scopes/$scope/memory/constitution.md"

        if [[ -f "$scope_constitution_path" ]]; then
            log_info "Creating constitution for scope: $scope"

            local target_path="$memory_dir/${scope}-constitution.md"

            # Create file with header
            cat > "$target_path" << EOF
<!-- ================================================================ -->
<!-- SCOPE: $scope -->
<!-- Generated: $date -->
<!-- Source: .boltf/scopes/$scope/memory/constitution.md -->
<!-- ================================================================ -->

EOF
            # Append scope constitution content
            cat "$scope_constitution_path" >> "$target_path"

            # Add footer
            cat >> "$target_path" << EOF

---

**Scope Constitution for $scope** | Generated by Bolt Framework init.sh on $date
EOF

            log_success "Created: ${scope}-constitution.md"
            ((copied_count++))
        else
            log_warn "Constitution not found for scope '$scope' at: $scope_constitution_path"
        fi
    done

    log_info "Created $copied_count scope constitution files"
    log_info "Next: Run '@Bolt Constitution' to refine and merge all constitutions"
}


# --- Demo content -------------------------------------------------------------

add_demo_content() {
    if [[ "$PROJECT_TYPE" == "green" ]]; then
        # ── Greenfield: copy user-provided RFP/functional docs to origin/ ──
        if [[ -n "$SOURCE_DIR" ]]; then
            cp -r "$SOURCE_DIR"/* "$OUTPUT_DIR/origin/"
            log_success "RFP/functional docs copied from $SOURCE_DIR to origin/"
        else
            # No real docs supplied — copy demo RFP as illustrative example
            local src="$SCRIPT_DIR/demo/from_rfp"
            if [[ -d "$src" ]]; then
                cp -r "$src"/* "$OUTPUT_DIR/origin/" 2>/dev/null || true
                log_info "Greenfield demo (RFP example) copied to origin/"
            fi
        fi
    else
        # ── Brownfield: copy real legacy source to legacy/ ──
        if [[ -n "$SOURCE_DIR" ]]; then
            cp -r "$SOURCE_DIR"/* "$OUTPUT_DIR/legacy/"
            log_success "Legacy source copied from $SOURCE_DIR to legacy/"
        else
            # No real source supplied — copy demo legacy code as illustrative example
            local src="$SCRIPT_DIR/demo/from_old_src"
            if [[ -d "$src" ]]; then
                cp -r "$src"/* "$OUTPUT_DIR/legacy/" 2>/dev/null || true
                log_info "Brownfield demo (legacy example) copied to legacy/"
            fi
        fi
    fi
}

# --- Python Environment Setup (Optional) --------------------------------------

initialize_python_environment() {
    #
    # Optional Python environment setup during initialization
    #
    # Attempts to configure Python virtual environment (.bolt-venv) for skills
    # that require Python (e.g., skill-creator). Non-blocking - project initialization
    # continues even if Python setup fails.
    #
    # Returns 0 if Python was successfully configured, 1 otherwise
    #

    echo ""
    log_step "Setting up Python environment (optional)..."

    local bootstrap_script="$OUTPUT_DIR/.boltf/scripts/bash/bootstrap-python.sh"

    # Check if bootstrap-python.sh exists
    if [[ ! -f "$bootstrap_script" ]]; then
        log_warn "Python bootstrap script not found (skills/Python features unavailable)"
        log_info "Some advanced skills may require Python - you can run bootstrap manually later"
        return 1
    fi

    log_info "Checking Python availability..."

    # Execute bootstrap-python.sh in the target directory
    if "$bootstrap_script" --project-root "$OUTPUT_DIR" --skip-install >/dev/null 2>&1; then
        log_success "Python environment configured successfully"
        log_info "Virtual environment: .bolt-venv/"
        log_info "Python-based skills ready (e.g., skill-creator)"
        return 0
    else
        local exit_code=$?
        log_warn "Python setup completed with warnings (exit code: $exit_code)"
        log_info "Python features may have limited availability"
        echo ""
        log_info "This is optional - you can setup Python later by running:"
        echo -e "  ${YELLOW}.boltf/scripts/bash/bootstrap-python.sh --project-root .${NC}"
        echo ""
        log_info "Project initialization will continue without Python features"
        return 1
    fi
}

# --- Summary ------------------------------------------------------------------

show_summary() {
    echo ""
    echo -e "  ${GREEN}┌──────────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${GREEN}│   Bolt Framework Project Initialized! (Phase 1 of 2)         │${NC}"
    echo -e "  ${GREEN}└──────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    log_info "✓ Practice:   $D_PRACTICE"
    log_info "✓ Project Type: $D_PROJECT_TYPE"
    log_info "✓ Scopes:     ${D_SCOPES[*]}"
    if [[ "$D_USE_ASPIRE" == "true" ]]; then
        log_info "✓ Orchestration: .NET Aspire"
    fi
    if [[ "$D_WORK_MANAGEMENT_TOOL" != "none" ]]; then
        log_info "✓ Work Mgmt:  $D_WORK_MANAGEMENT_TOOL"
    fi
    if [[ "$D_IAC_TOOL" != "none" ]]; then
        log_info "✓ IaC Tool:   $D_IAC_TOOL"
    fi
    log_info "✓ Basic constitution created in .boltf/memory/constitution.md"
    log_info "✓ Scopes configuration saved to .boltf/scopes.yaml"
    log_info "✓ Bolt Framework agents and skills copied to .github/"

    # Python environment status
    if [[ "$D_PYTHON_CONFIGURED" == "true" ]]; then
        log_info "✓ Python environment: Configured (.bolt-venv/)"
        log_info "  - Advanced skills available: skill-creator (AI-powered)"
    else
        log_warn "⚠ Python environment: Not configured"
        log_info "  - Run later: .boltf/scripts/bash/bootstrap-python.sh"
        log_info "  - Enables: skill-creator and other Python-based features"
    fi

    echo ""
    echo -e "  ${YELLOW}⚠ IMPORTANT: Two-Step Initialization${NC}"
    echo -e "     ${WHITE}Phase 1: init.sh (completed) — Basic configuration${NC}"
    echo -e "     ${WHITE}Phase 2: @Bolt Constitution — File provisioning & constitution merge${NC}"
    echo ""
    echo -e "  ${CYAN}AUTOMATED SETUP (Phase 2 of 2):${NC}"
    echo ""

    # Check if GitHub Copilot CLI is available and up-to-date
    if command -v copilot &> /dev/null; then
        # Check if there's a newer version available
        echo -e "  ${WHITE}🔍 Checking Copilot CLI version...${NC}"
        test_copilot_cli_version

        if [[ "$CLI_VERSION_CHECK_RESULT" == "needs-update" ]] && [[ "$CLI_LATEST_VERSION" != "unknown" ]]; then
            echo ""
            echo -e "  ${YELLOW}⚠ GitHub Copilot CLI update available${NC}"
            echo -e "    ${RED}Installed: $CLI_CURRENT_VERSION${NC}"
            echo -e "    ${GREEN}Latest:    $CLI_LATEST_VERSION${NC}"
            echo ""
            echo -e "  ${CYAN}📦 UPDATE RECOMMENDED:${NC}"
            echo -e "     ${WHITE}Run: copilot update${NC}"
            echo -e "     ${WHITE}Or:  npm install -g @github/copilot${NC}"
            echo ""

            read_yes_no "Continue with current version anyway?" "false"
            if [[ "$REPLY_YN" != "true" ]]; then
                echo ""
                echo -e "  ${YELLOW}📝 AFTER UPDATING, RUN:${NC}"
                echo -e "     ${WHITE}1. cd $OUTPUT_DIR${NC}"
                echo -e "     ${WHITE}2. Run: copilot${NC}"
                echo -e "     ${WHITE}3. Prompt: @Bolt Constitution setup constitution${NC}"
                echo ""
                return 0
            fi
            echo ""
        fi

        echo -e "  ${GREEN}✓ GitHub Copilot CLI v$CLI_CURRENT_VERSION detected${NC}"
        echo -e "  ${YELLOW}🤖 Invoking @Bolt Constitution agent (INTERACTIVE MODE)...${NC}"
        echo -e "  ${YELLOW}⚠  You will be prompted to approve each provisioning step${NC}"
        echo ""

        # Let user select which AI model to use
        select_copilot_model
        echo ""
        echo -e "  ${CYAN}📦 Using model: $REPLY_MODEL${NC}"
        echo ""

        # Change to project directory and invoke agent
        if (cd "$OUTPUT_DIR" && copilot --agent="bolt-constitution" --banner --model "$REPLY_MODEL" --yolo --allow-tool 'shell' -i "setup constitution" --add-dir "$OUTPUT_DIR"); then
            echo ""
            echo -e "  ${GREEN}✓ @Bolt Constitution agent completed${NC}"
            echo -e "  ${CYAN}📝 Review provision results above${NC}"
        else
            log_warn "Failed to invoke agent"
            echo -e "  ${YELLOW}📝 MANUAL FALLBACK:${NC}"
            echo -e "     ${WHITE}1. cd $OUTPUT_DIR${NC}"
            echo -e "     ${WHITE}2. Run: copilot --model $REPLY_MODEL${NC}"
            echo -e "     ${WHITE}3. Prompt: Use Bolt Constitution agent to setup constitution${NC}"
        fi
    else
        echo -e "  ${YELLOW}⚠ GitHub Copilot CLI not detected${NC}"
        echo -e "  ${CYAN}📝 MANUAL STEP REQUIRED:${NC}"
        echo -e "     ${WHITE}1. cd $OUTPUT_DIR${NC}"
        echo -e "     ${WHITE}2. Install GitHub Copilot CLI: gh extension install github/gh-copilot${NC}"
        echo -e "     ${WHITE}3. Run: copilot${NC}"
        echo -e "     ${WHITE}4. Prompt: Use Bolt Constitution agent to setup constitution${NC}"
        echo ""
        echo -e "  ${WHITE}💡 After CLI installation, the agent will auto-invoke on next init${NC}"
    fi

    echo ""
    echo -e "  ${CYAN}📚 Documentation:${NC}"
    echo "     - README.md — Bolt Framework overview"
    echo "     - .boltf/scopes/README.md — Practice-based initialization guide"
    echo ""
}

# --- Main ---------------------------------------------------------------------

main() {
    parse_args "$@"

    # Validate required parameters
    if [[ -z "$OUTPUT_DIR" || -z "$PROJECT_TYPE" ]]; then
        show_banner
        log_error "Missing required parameters"
        echo ""
        show_usage
        exit 1
    fi

    # Validate ProjectType
    if [[ "$PROJECT_TYPE" != "green" && "$PROJECT_TYPE" != "brown" ]]; then
        show_banner
        log_error "Invalid ProjectType: '$PROJECT_TYPE'. Must be 'green' or 'brown'"
        echo ""
        show_usage
        exit 1
    fi

    # Validate SourceDirectory for brownfield
    if [[ "$PROJECT_TYPE" == "brown" ]]; then
        if [[ -z "$SOURCE_DIR" ]]; then
            show_banner
            log_error "SourceDirectory is required when ProjectType is 'brown'"
            echo ""
            show_usage
            exit 1
        fi
        if [[ ! -d "$SOURCE_DIR" ]]; then
            show_banner
            log_error "SourceDirectory does not exist: $SOURCE_DIR"
            echo ""
            show_usage
            exit 1
        fi
    fi

    # Validate SourceDirectory for greenfield (optional — if provided, must exist)
    if [[ "$PROJECT_TYPE" == "green" && -n "$SOURCE_DIR" ]]; then
        if [[ ! -d "$SOURCE_DIR" ]]; then
            show_banner
            log_error "SourceDirectory does not exist: $SOURCE_DIR"
            echo ""
            show_usage
            exit 1
        fi
    fi

    show_banner
    check_prerequisites

    collect_all_decisions

    echo ""
    echo -e "  ${WHITE}Selected scopes: ${D_SCOPES[*]}${NC}"
    read_yes_no "Proceed with these choices?" "true"
    if [[ "$REPLY_YN" != "true" ]]; then
        log_error "Cancelled by user"
        exit 0
    fi

    create_project_structure
    copy_bolt_framework
    generate_scopes_yaml
    prefill_constitution
    add_demo_content

    # Python environment setup (optional, non-blocking)
    D_PYTHON_CONFIGURED=false
    if initialize_python_environment; then
        D_PYTHON_CONFIGURED=true
    fi

    show_summary
}

main "$@"
