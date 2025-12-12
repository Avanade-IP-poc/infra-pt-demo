#!/bin/bash
# =============================================================================
# AURORA-IA / AI-DLC - Quality Gates Script
# =============================================================================
# Runs quality checks including linting, testing, and security scanning.
#
# Usage:
#   ./quality-gates.sh [--check|--fix] [--full]
#
# Options:
#   --check   Run checks without fixing (default)
#   --fix     Attempt to auto-fix issues
#   --full    Run full suite including security scan
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default options
MODE="check"
FULL_SUITE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --check)
            MODE="check"
            shift
            ;;
        --fix)
            MODE="fix"
            shift
            ;;
        --full)
            FULL_SUITE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_section() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
}

# Track results
PASSED=0
FAILED=0
WARNINGS=0

run_check() {
    local name="$1"
    local command="$2"
    
    log_info "Running: ${name}"
    
    if eval "${command}"; then
        log_success "${name} passed"
        ((PASSED++))
        return 0
    else
        log_error "${name} failed"
        ((FAILED++))
        return 1
    fi
}

# Detect package manager and project type
detect_project() {
    if [ -f "package.json" ]; then
        echo "node"
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        echo "python"
    elif [ -f "go.mod" ]; then
        echo "go"
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    else
        echo "unknown"
    fi
}

PROJECT_TYPE=$(detect_project)
log_info "Detected project type: ${PROJECT_TYPE}"

# =============================================================================
# Quality Gate 1: Type Checking
# =============================================================================
log_section "Type Checking"

case $PROJECT_TYPE in
    node)
        if [ -f "tsconfig.json" ]; then
            run_check "TypeScript" "npx tsc --noEmit" || true
        else
            log_warning "No tsconfig.json found, skipping type check"
            ((WARNINGS++))
        fi
        ;;
    python)
        if command -v mypy &> /dev/null; then
            run_check "MyPy" "mypy ." || true
        else
            log_warning "mypy not installed, skipping type check"
            ((WARNINGS++))
        fi
        ;;
    *)
        log_info "Type checking not configured for ${PROJECT_TYPE}"
        ;;
esac

# =============================================================================
# Quality Gate 2: Linting
# =============================================================================
log_section "Linting"

case $PROJECT_TYPE in
    node)
        if [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ] || [ -f "eslint.config.js" ]; then
            if [ "$MODE" = "fix" ]; then
                run_check "ESLint" "npx eslint . --fix" || true
            else
                run_check "ESLint" "npx eslint ." || true
            fi
        else
            log_warning "No ESLint config found"
            ((WARNINGS++))
        fi
        ;;
    python)
        if command -v ruff &> /dev/null; then
            if [ "$MODE" = "fix" ]; then
                run_check "Ruff" "ruff check --fix ." || true
            else
                run_check "Ruff" "ruff check ." || true
            fi
        elif command -v flake8 &> /dev/null; then
            run_check "Flake8" "flake8 ." || true
        else
            log_warning "No Python linter found"
            ((WARNINGS++))
        fi
        ;;
    go)
        run_check "Go Vet" "go vet ./..." || true
        if command -v golint &> /dev/null; then
            run_check "Golint" "golint ./..." || true
        fi
        ;;
    *)
        log_info "Linting not configured for ${PROJECT_TYPE}"
        ;;
esac

# =============================================================================
# Quality Gate 3: Formatting
# =============================================================================
log_section "Formatting"

case $PROJECT_TYPE in
    node)
        if [ -f ".prettierrc" ] || [ -f ".prettierrc.json" ] || [ -f "prettier.config.js" ]; then
            if [ "$MODE" = "fix" ]; then
                run_check "Prettier" "npx prettier --write ." || true
            else
                run_check "Prettier" "npx prettier --check ." || true
            fi
        fi
        ;;
    python)
        if command -v black &> /dev/null; then
            if [ "$MODE" = "fix" ]; then
                run_check "Black" "black ." || true
            else
                run_check "Black" "black --check ." || true
            fi
        fi
        ;;
    go)
        if [ "$MODE" = "fix" ]; then
            run_check "Go Fmt" "go fmt ./..." || true
        else
            run_check "Go Fmt" "test -z \"\$(gofmt -l .)\"" || true
        fi
        ;;
    rust)
        if [ "$MODE" = "fix" ]; then
            run_check "Rustfmt" "cargo fmt" || true
        else
            run_check "Rustfmt" "cargo fmt -- --check" || true
        fi
        ;;
    *)
        log_info "Formatting not configured for ${PROJECT_TYPE}"
        ;;
esac

# =============================================================================
# Quality Gate 4: Unit Tests
# =============================================================================
log_section "Unit Tests"

case $PROJECT_TYPE in
    node)
        if grep -q "\"test\"" package.json 2>/dev/null; then
            run_check "Jest/Vitest" "npm test -- --passWithNoTests" || true
        else
            log_warning "No test script in package.json"
            ((WARNINGS++))
        fi
        ;;
    python)
        if command -v pytest &> /dev/null; then
            run_check "Pytest" "pytest" || true
        elif [ -d "tests" ]; then
            run_check "Unittest" "python -m unittest discover tests" || true
        else
            log_warning "No test framework detected"
            ((WARNINGS++))
        fi
        ;;
    go)
        run_check "Go Test" "go test ./..." || true
        ;;
    rust)
        run_check "Cargo Test" "cargo test" || true
        ;;
    *)
        log_info "Testing not configured for ${PROJECT_TYPE}"
        ;;
esac

# =============================================================================
# Quality Gate 5: Coverage (if --full)
# =============================================================================
if [ "$FULL_SUITE" = true ]; then
    log_section "Test Coverage"
    
    case $PROJECT_TYPE in
        node)
            run_check "Coverage" "npm test -- --coverage --passWithNoTests" || true
            ;;
        python)
            if command -v pytest &> /dev/null; then
                run_check "Coverage" "pytest --cov=. --cov-report=term-missing" || true
            fi
            ;;
        go)
            run_check "Coverage" "go test -cover ./..." || true
            ;;
        *)
            log_info "Coverage not configured for ${PROJECT_TYPE}"
            ;;
    esac
fi

# =============================================================================
# Quality Gate 6: Security Scan (if --full)
# =============================================================================
if [ "$FULL_SUITE" = true ]; then
    log_section "Security Scan"
    
    case $PROJECT_TYPE in
        node)
            run_check "NPM Audit" "npm audit --audit-level=high" || true
            ;;
        python)
            if command -v safety &> /dev/null; then
                run_check "Safety" "safety check" || true
            elif command -v pip-audit &> /dev/null; then
                run_check "Pip Audit" "pip-audit" || true
            else
                log_warning "No Python security scanner found"
                ((WARNINGS++))
            fi
            ;;
        go)
            if command -v govulncheck &> /dev/null; then
                run_check "Govulncheck" "govulncheck ./..." || true
            fi
            ;;
        rust)
            if command -v cargo-audit &> /dev/null; then
                run_check "Cargo Audit" "cargo audit" || true
            fi
            ;;
        *)
            log_info "Security scanning not configured for ${PROJECT_TYPE}"
            ;;
    esac
fi

# =============================================================================
# Summary
# =============================================================================
log_section "Quality Gate Summary"

echo ""
echo -e "  ${GREEN}Passed:${NC}   ${PASSED}"
echo -e "  ${RED}Failed:${NC}   ${FAILED}"
echo -e "  ${YELLOW}Warnings:${NC} ${WARNINGS}"
echo ""

if [ $FAILED -gt 0 ]; then
    log_error "Quality gates FAILED"
    echo ""
    echo "Run with --fix to attempt automatic fixes"
    exit 1
else
    log_success "All quality gates PASSED"
    exit 0
fi
