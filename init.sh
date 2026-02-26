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
D_PROJECT_TYPE=""
D_SCOPES=()
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

  --source, -s   Directory containing legacy source code
                 • Required when: --type is 'brown'
                 • Optional when: --type is 'green'
                 • Accepts: Absolute path (/home/user/legacy) or relative path (./legacy)
                 • Must exist and contain source files

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
    if [[ -d "$OUTPUT_DIR" ]]; then
        log_error "Output directory '$OUTPUT_DIR' already exists"; exit 1
    fi
}

# --- Collect decisions --------------------------------------------------------

collect_all_decisions() {

    echo ""
    log_step "Article I — Active Scopes"

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

    read_yes_no "§16.1  Azure Virtual Network?" "true"
    D_VNET="$REPLY_YN"

    read_yes_no "§16.1  Private Endpoints?" "true"
    D_PRIVATE_ENDPOINTS="$REPLY_YN"

    read_yes_no "§16.1  Web Application Firewall (Front Door)?" "false"
    D_WAF="$REPLY_YN"

    read_choice "§16.2  Encryption at rest" 1 \
        "Azure-managed keys" "Customer-managed keys" \
        --- "azure-managed" "customer-managed"
    D_ENCRYPTION_KEYS="$REPLY_CHOICE"

    read_choice "§16.2  PII handling" 3 \
        "Anonymization" "Pseudonymization" "Encryption" \
        --- "anonymization" "pseudonymization" "encryption"
    D_PII_HANDLING="$REPLY_CHOICE"

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
  type: ${D_PROJECT_TYPE}               # derived from scopes
  migration-type: ${PROJECT_TYPE}   # green | brown

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
    log_step "Prefilling constitution with your decisions..."

    local path="$OUTPUT_DIR/.boltf/memory/constitution.md"
    if [[ ! -f "$path" ]]; then
        log_warn "constitution.md not found -- skipping prefill"
        return
    fi

    # Use a temp file for sed operations
    local tmp="${path}.tmp"
    cp "$path" "$tmp"

    # Article I §1.1 -- Active Scopes
    for scope in "${D_SCOPES[@]}"; do
        sed -i "s/| \[ \] | \*\*${scope}\*\*/| [x] | **${scope}**/" "$tmp"
    done

    # Article X §10.1 -- Environments
    for env in "${D_ENVIRONMENTS[@]}"; do
        sed -i "s/\(\*\*${env}\*\*[^|]*|[^|]*|\) \[ \] Yes/\1 [x] Yes/" "$tmp"
    done

    # Article X §10.1 -- Auto-Deploy
    for env in "${D_ENVIRONMENTS[@]}"; do
        local varname="D_AUTO_DEPLOY_${env^^}"
        local val="${!varname}"
        if [[ "$val" == "true" ]]; then
            sed -i "s/\(\*\*${env}\*\*.*\[x\] Yes |\) \[ \]/\1 [x]/" "$tmp"
        fi
    done

    # Article X §10.2 -- Config management
    local config_label=""
    case "$D_CONFIG_MANAGEMENT" in
        azure-app-config) config_label="Azure App Configuration" ;;
        env-vars)         config_label="Environment Variables" ;;
        config-files)     config_label="appsettings" ;;
        combination)      config_label="Combination" ;;
    esac
    [[ -n "$config_label" ]] && sed -i "s/- \[ \] \*\*${config_label}/- [x] **${config_label}/" "$tmp"

    # Article X §10.3 -- Local dev secrets
    local secret_label=""
    case "$D_SECRETS_DEV" in
        user-secrets)   secret_label="User Secrets" ;;
        env-files)      secret_label="\.env files" ;;
        local-keyvault) secret_label="Local Key Vault" ;;
    esac
    [[ -n "$secret_label" ]] && sed -i "s/- \[ \] \*\*${secret_label}/- [x] **${secret_label}/" "$tmp"

    # Article X §10.4 -- Feature flags
    local ff_label=""
    case "$D_FEATURE_FLAGS" in
        none)             ff_label="None" ;;
        azure-app-config) ff_label="Azure App Configuration" ;;
        launchdarkly)     ff_label="LaunchDarkly" ;;
        unleash)          ff_label="Unleash" ;;
    esac
    [[ -n "$ff_label" ]] && sed -i "s/- \[ \] \*\*${ff_label}\*\*/- [x] **${ff_label}**/" "$tmp"

    # Article XI §11.1 -- CI/CD
    local cicd_label=""
    case "$D_CICD_PLATFORM" in
        github-actions) cicd_label="GitHub Actions" ;;
        azure-devops)   cicd_label="Azure DevOps Pipelines" ;;
    esac
    [[ -n "$cicd_label" ]] && sed -i "s/- \[ \] \*\*${cicd_label}\*\*/- [x] **${cicd_label}**/" "$tmp"

    # Article XI §11.3 -- Deploy strategy
    local deploy_label=""
    case "$D_DEPLOY_STRATEGY" in
        rolling)       deploy_label="Rolling Update" ;;
        blue-green)    deploy_label="Blue-Green" ;;
        canary)        deploy_label="Canary" ;;
        feature-flags) deploy_label="Feature Flags" ;;
    esac
    [[ -n "$deploy_label" ]] && sed -i "s/- \[ \] \*\*${deploy_label}\*\*/- [x] **${deploy_label}**/" "$tmp"

    # Article XI §11.4 -- Branch strategy
    local branch_label=""
    case "$D_BRANCH_STRATEGY" in
        gitflow)     branch_label="GitFlow" ;;
        github-flow) branch_label="GitHub Flow" ;;
        trunk-based) branch_label="Trunk-Based" ;;
    esac
    [[ -n "$branch_label" ]] && sed -i "s/- \[ \] \*\*${branch_label}\*\*/- [x] **${branch_label}**/" "$tmp"

    # Article XI §11.2 -- App Pipeline Stages
    declare -A app_stage_map=(
        ["build"]="Build" ["lint-format"]="Lint/Format"
        ["unit-tests"]="Unit Tests" ["integration-tests"]="Integration Tests"
        ["architecture-tests"]="Architecture Tests" ["mutation-tests"]="Mutation Tests"
        ["container-build"]="Container Build" ["container-scan"]="Container Scan"
    )
    for stage in "${D_APP_PIPELINE_STAGES[@]}"; do
        if [[ "$stage" == "security-scan" ]]; then
            # Disambiguate: app table has "0 Critical"
            sed -i 's/\(\*\*Security Scan\*\*\s*|\)\s*\[ \] Yes\(\s*|\s*0 Critical\)/\1 [x] Yes\2/' "$tmp"
            continue
        fi
        local label="${app_stage_map[$stage]}"
        if [[ -n "$label" ]]; then
            sed -i "s/\(\*\*${label}\*\*\s*|\)\s*\[ \] Yes/\1 [x] Yes/" "$tmp"
        fi
    done

    # Thresholds
    if [[ "$D_UNIT_TEST_COVERAGE" -gt 0 ]]; then
        sed -i "s/Coverage >= \\_\\_%/Coverage >= ${D_UNIT_TEST_COVERAGE}%/" "$tmp"
    fi
    if [[ "$D_MUTATION_SCORE" -gt 0 ]]; then
        sed -i "s/Score >= \\_\\_%/Score >= ${D_MUTATION_SCORE}%/" "$tmp"
    fi

    # Article XI §11.2 -- Infra Pipeline Stages
    declare -A infra_stage_map=(
        ["iac-lint"]="IaC Lint" ["iac-validation"]="IaC Validation"
        ["cost-estimation"]="Cost Estimation" ["compliance-check"]="Compliance Check"
    )
    for stage in "${D_INFRA_PIPELINE_STAGES[@]}"; do
        if [[ "$stage" == "security-scan" ]]; then
            # Disambiguate: infra table has "Checkov"
            sed -i 's/\(\*\*Security Scan\*\*\s*|\)\s*\[ \] Yes\(\s*|\s*Checkov\)/\1 [x] Yes\2/' "$tmp"
            continue
        fi
        local label="${infra_stage_map[$stage]}"
        if [[ -n "$label" ]]; then
            sed -i "s/\(\*\*${label}\*\*\s*|\)\s*\[ \] Yes/\1 [x] Yes/" "$tmp"
        fi
    done

    # Article XI §11.2 -- Deploy Stages
    declare -A deploy_stage_map=(
        ["dev"]="Deploy Dev" ["uat"]="Deploy UAT"
        ["pre"]="Deploy Pre" ["prod"]="Deploy Prod"
    )
    for env in "${D_DEPLOY_PIPELINE_STAGES[@]}"; do
        local label="${deploy_stage_map[$env]}"
        if [[ -n "$label" ]]; then
            sed -i "s/\(\*\*${label}\*\*\s*|\)\s*\[ \] Yes/\1 [x] Yes/" "$tmp"
        fi
    done

    # Article XII §12.1 -- Observability
    local obs_label=""
    case "$D_OBSERVABILITY" in
        azure-native) obs_label="Azure-Native" ;;
        otel-azure)   obs_label="OpenTelemetry → Azure" ;;
        otel-grafana) obs_label="OpenTelemetry → Grafana Stack" ;;
    esac
    [[ -n "$obs_label" ]] && sed -i "s/- \[ \] \*\*${obs_label}\*\*/- [x] **${obs_label}**/" "$tmp"

    # Article XII §12.3 -- Infra Monitoring
    declare -A monitor_map=(
        ["resource-health"]="Resource Health" ["activity-logs"]="Activity Logs"
        ["diagnostics"]="Diagnostics" ["alerts"]="Alerts"
        ["dashboards"]="Dashboards"
    )
    for mon in "${D_INFRA_MONITORING[@]}"; do
        local label="${monitor_map[$mon]}"
        if [[ -n "$label" ]]; then
            sed -i "s/\(${label}\s*|[^|]*|\)\s*\[ \] Yes/\1 [x] Yes/" "$tmp"
        fi
    done

    # Article XVI §16.1 -- Network security
    if [[ "$D_VNET" == "true" ]]; then
        sed -i 's/\[ \] Azure VNet/[x] Azure VNet/' "$tmp"
    else
        sed -i 's/\[ \] None/[x] None/' "$tmp"
    fi
    if [[ "$D_PRIVATE_ENDPOINTS" == "true" ]]; then
        sed -i 's/\[ \] Enabled/[x] Enabled/' "$tmp"
    else
        sed -i 's/\[ \] Disabled/[x] Disabled/' "$tmp"
    fi
    if [[ "$D_WAF" == "true" ]]; then
        sed -i 's/\[ \] Azure Front Door WAF/[x] Azure Front Door WAF/' "$tmp"
    fi

    # Article XVI §16.2 -- Data protection
    case "$D_ENCRYPTION_KEYS" in
        azure-managed)    sed -i 's/\[ \] Azure-managed keys/[x] Azure-managed keys/' "$tmp" ;;
        customer-managed) sed -i 's/\[ \] Customer-managed keys/[x] Customer-managed keys/' "$tmp" ;;
    esac
    case "$D_PII_HANDLING" in
        anonymization)    sed -i 's/\[ \] Anonymization/[x] Anonymization/' "$tmp" ;;
        pseudonymization) sed -i 's/\[ \] Pseudonymization/[x] Pseudonymization/' "$tmp" ;;
        encryption)       sed -i 's/\[ \] Encryption/[x] Encryption/' "$tmp" ;;
    esac

    # Article XVI §16.3 -- Compliance
    for std in "${D_COMPLIANCE[@]}"; do
        if [[ "$std" == "none" ]]; then continue; fi
        local upper
        upper=$(echo "$std" | tr '[:lower:]' '[:upper:]')
        sed -i "s/\(|\s*${upper}\s*|[^|]*|\) \[ \] Yes/\1 [x] Yes/" "$tmp"
    done

    mv "$tmp" "$path"
    log_success "Constitution prefilled with all base decisions"
}

# --- Demo content -------------------------------------------------------------

add_demo_content() {
    if [[ "$PROJECT_TYPE" == "green" ]]; then
        local src="$SCRIPT_DIR/demo/from_rfp"
        if [[ -d "$src" ]]; then
            cp -r "$src"/* "$OUTPUT_DIR/origin/" 2>/dev/null || true
            log_info "Greenfield demo copied to origin/"
        fi
    else
        local src="$SCRIPT_DIR/demo/from_old_src"
        if [[ -d "$src" ]]; then
            cp -r "$src"/* "$OUTPUT_DIR/legacy/" 2>/dev/null || true
            log_info "Brownfield demo copied to legacy/"
        fi
        if [[ -n "$SOURCE_DIR" ]]; then
            cp -r "$SOURCE_DIR"/* "$OUTPUT_DIR/legacy/"
            log_info "Legacy source copied from $SOURCE_DIR"
        fi
    fi
}

# --- Summary ------------------------------------------------------------------

show_summary() {
    echo ""
    echo -e "  ${GREEN}┌──────────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${GREEN}│   Bolt Framework Project Initialized! (Phase 1 of 2)         │${NC}"
    echo -e "  ${GREEN}└──────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    log_info "✓ Practice:   $D_PROJECT_TYPE"
    log_info "✓ Scopes:     ${D_SCOPES[*]}"
    if [[ "$D_IAC_TOOL" != "none" ]]; then
        log_info "✓ IaC Tool:   $D_IAC_TOOL"
    fi
    log_info "✓ Basic constitution created in .boltf/memory/constitution.md"
    log_info "✓ Scopes configuration saved to .boltf/scopes.yaml"
    log_info "✓ Bolt Framework agents and skills copied to .github/"
    echo ""
    echo -e "  ${YELLOW}⚠ IMPORTANT: Two-Step Initialization${NC}"
    echo -e "     ${WHITE}Phase 1: init.sh (completed) — Basic configuration${NC}"
    echo -e "     ${WHITE}Phase 2: @Bolt Constitution — File provisioning & constitution merge${NC}"
    echo ""
    echo -e "  ${CYAN}AUTOMATED SETUP (Phase 2 of 2):${NC}"
    echo ""

    # Check if GitHub Copilot CLI is available
    if command -v copilot &> /dev/null; then
        echo -e "  ${GREEN}✓ GitHub Copilot CLI detected${NC}"
        echo -e "  ${YELLOW}🤖 Invoking @Bolt Constitution agent (INTERACTIVE MODE)...${NC}"
        echo -e "  ${YELLOW}⚠  You will be prompted to approve each provisioning step${NC}"
        echo ""

        # Change to project directory and invoke agent
        if (cd "$OUTPUT_DIR" && copilot --agent="bolt-constitution" --banner --model claude-sonnet-4.5 -i "setup constitution"); then
            echo ""
            echo -e "  ${GREEN}✓ @Bolt Constitution agent completed${NC}"
            echo -e "  ${CYAN}📝 Review provision results above${NC}"
        else
            log_warn "Failed to invoke agent"
            echo -e "  ${YELLOW}📝 MANUAL FALLBACK:${NC}"
            echo -e "     ${WHITE}1. cd $OUTPUT_DIR${NC}"
            echo -e "     ${WHITE}2. Run: copilot${NC}"
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

    show_summary
}

main "$@"
