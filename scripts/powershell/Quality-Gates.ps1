<#
.SYNOPSIS
    AURORA-IA / AI-DLC - Quality Gates Script

.DESCRIPTION
    Runs quality checks including linting, testing, and security scanning.

.PARAMETER Check
    Run checks without fixing (default behavior).

.PARAMETER Fix
    Attempt to auto-fix issues where possible.

.PARAMETER Full
    Run full suite including security scan and coverage.

.EXAMPLE
    .\Quality-Gates.ps1 -Check

.EXAMPLE
    .\Quality-Gates.ps1 -Fix -Full
#>

param(
    [switch]$Check,
    [switch]$Fix,
    [switch]$Full
)

# Default to check mode if neither specified
if (-not $Check -and -not $Fix) {
    $Check = $true
}

# Track results
$Script:Passed = 0
$Script:Failed = 0
$Script:Warnings = 0

# Helper functions
function Write-Info { Write-Host "[INFO] $args" -ForegroundColor Blue }
function Write-Success { 
    Write-Host "[✓] $args" -ForegroundColor Green 
    $Script:Passed++
}
function Write-Warning { 
    Write-Host "[⚠] $args" -ForegroundColor Yellow 
    $Script:Warnings++
}
function Write-Fail { 
    Write-Host "[✗] $args" -ForegroundColor Red 
    $Script:Failed++
}
function Write-Section {
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Blue
    Write-Host "  $args" -ForegroundColor Blue
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Blue
}

function Invoke-Check {
    param(
        [string]$Name,
        [scriptblock]$Command
    )
    
    Write-Info "Running: $Name"
    
    try {
        & $Command
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Success "$Name passed"
            return $true
        } else {
            Write-Fail "$Name failed"
            return $false
        }
    } catch {
        Write-Fail "$Name failed: $_"
        return $false
    }
}

# Detect project type
function Get-ProjectType {
    if (Test-Path "package.json") { return "node" }
    if (Test-Path "requirements.txt" -or Test-Path "pyproject.toml") { return "python" }
    if (Test-Path "go.mod") { return "go" }
    if (Test-Path "Cargo.toml") { return "rust" }
    return "unknown"
}

$ProjectType = Get-ProjectType
Write-Info "Detected project type: $ProjectType"

# =============================================================================
# Quality Gate 1: Type Checking
# =============================================================================
Write-Section "Type Checking"

switch ($ProjectType) {
    "node" {
        if (Test-Path "tsconfig.json") {
            Invoke-Check "TypeScript" { npx tsc --noEmit }
        } else {
            Write-Warning "No tsconfig.json found, skipping type check"
        }
    }
    "python" {
        if (Get-Command mypy -ErrorAction SilentlyContinue) {
            Invoke-Check "MyPy" { mypy . }
        } else {
            Write-Warning "mypy not installed, skipping type check"
        }
    }
    default {
        Write-Info "Type checking not configured for $ProjectType"
    }
}

# =============================================================================
# Quality Gate 2: Linting
# =============================================================================
Write-Section "Linting"

switch ($ProjectType) {
    "node" {
        if (Test-Path ".eslintrc.js" -or Test-Path ".eslintrc.json" -or Test-Path "eslint.config.js") {
            if ($Fix) {
                Invoke-Check "ESLint" { npx eslint . --fix }
            } else {
                Invoke-Check "ESLint" { npx eslint . }
            }
        } else {
            Write-Warning "No ESLint config found"
        }
    }
    "python" {
        if (Get-Command ruff -ErrorAction SilentlyContinue) {
            if ($Fix) {
                Invoke-Check "Ruff" { ruff check --fix . }
            } else {
                Invoke-Check "Ruff" { ruff check . }
            }
        } elseif (Get-Command flake8 -ErrorAction SilentlyContinue) {
            Invoke-Check "Flake8" { flake8 . }
        } else {
            Write-Warning "No Python linter found"
        }
    }
    "go" {
        Invoke-Check "Go Vet" { go vet ./... }
    }
    default {
        Write-Info "Linting not configured for $ProjectType"
    }
}

# =============================================================================
# Quality Gate 3: Formatting
# =============================================================================
Write-Section "Formatting"

switch ($ProjectType) {
    "node" {
        if (Test-Path ".prettierrc" -or Test-Path ".prettierrc.json" -or Test-Path "prettier.config.js") {
            if ($Fix) {
                Invoke-Check "Prettier" { npx prettier --write . }
            } else {
                Invoke-Check "Prettier" { npx prettier --check . }
            }
        }
    }
    "python" {
        if (Get-Command black -ErrorAction SilentlyContinue) {
            if ($Fix) {
                Invoke-Check "Black" { black . }
            } else {
                Invoke-Check "Black" { black --check . }
            }
        }
    }
    "go" {
        if ($Fix) {
            Invoke-Check "Go Fmt" { go fmt ./... }
        } else {
            Invoke-Check "Go Fmt Check" { 
                $output = gofmt -l .
                if ($output) { throw "Files need formatting" }
            }
        }
    }
    "rust" {
        if ($Fix) {
            Invoke-Check "Rustfmt" { cargo fmt }
        } else {
            Invoke-Check "Rustfmt" { cargo fmt -- --check }
        }
    }
    default {
        Write-Info "Formatting not configured for $ProjectType"
    }
}

# =============================================================================
# Quality Gate 4: Unit Tests
# =============================================================================
Write-Section "Unit Tests"

switch ($ProjectType) {
    "node" {
        $packageJson = Get-Content "package.json" -Raw | ConvertFrom-Json
        if ($packageJson.scripts.test) {
            Invoke-Check "Jest/Vitest" { npm test -- --passWithNoTests }
        } else {
            Write-Warning "No test script in package.json"
        }
    }
    "python" {
        if (Get-Command pytest -ErrorAction SilentlyContinue) {
            Invoke-Check "Pytest" { pytest }
        } elseif (Test-Path "tests") {
            Invoke-Check "Unittest" { python -m unittest discover tests }
        } else {
            Write-Warning "No test framework detected"
        }
    }
    "go" {
        Invoke-Check "Go Test" { go test ./... }
    }
    "rust" {
        Invoke-Check "Cargo Test" { cargo test }
    }
    default {
        Write-Info "Testing not configured for $ProjectType"
    }
}

# =============================================================================
# Quality Gate 5: Coverage (MANDATORY - not optional)
# =============================================================================
Write-Section "Test Coverage"

switch ($ProjectType) {
    "node" {
        Invoke-Check "Coverage" { npm test -- --coverage --passWithNoTests }
    }
    "python" {
        if (Get-Command pytest -ErrorAction SilentlyContinue) {
            Invoke-Check "Coverage" { pytest --cov=. --cov-report=term-missing --cov-fail-under=80 }
        }
    }
    "go" {
        Invoke-Check "Coverage" { go test -cover ./... }
    }
    default {
        Write-Info "Coverage not configured for $ProjectType"
    }
}

# =============================================================================
# Quality Gate 6: Mutation Testing (MANDATORY)
# =============================================================================
Write-Section "Mutation Testing"

switch ($ProjectType) {
    "node" {
        if (Test-Path "stryker.conf.js" -or Test-Path "stryker.conf.json" -or Test-Path "stryker.config.mjs") {
            Invoke-Check "Stryker Mutation" { npx stryker run --concurrency 2 }
        } else {
            Write-Warning "Stryker not configured. Run: npx stryker init"
            Write-Info "To install: npm install --save-dev @stryker-mutator/core @stryker-mutator/jest-runner"
        }
    }
    "python" {
        if (Get-Command mutmut -ErrorAction SilentlyContinue) {
            Invoke-Check "Mutmut" { mutmut run --paths-to-mutate=src/ }
        } else {
            Write-Warning "mutmut not installed. Run: pip install mutmut"
        }
    }
    default {
        Write-Info "Mutation testing not configured for $ProjectType"
    }
}

# =============================================================================
# Quality Gate 7: Security Scan (if -Full)
# =============================================================================
if ($Full) {
    Write-Section "Security Scan"
    
    switch ($ProjectType) {
        "node" {
            Invoke-Check "NPM Audit" { npm audit --audit-level=high }
        }
        "python" {
            if (Get-Command safety -ErrorAction SilentlyContinue) {
                Invoke-Check "Safety" { safety check }
            } elseif (Get-Command pip-audit -ErrorAction SilentlyContinue) {
                Invoke-Check "Pip Audit" { pip-audit }
            } else {
                Write-Warning "No Python security scanner found"
            }
        }
        "go" {
            if (Get-Command govulncheck -ErrorAction SilentlyContinue) {
                Invoke-Check "Govulncheck" { govulncheck ./... }
            }
        }
        "rust" {
            if (Get-Command cargo-audit -ErrorAction SilentlyContinue) {
                Invoke-Check "Cargo Audit" { cargo audit }
            }
        }
        default {
            Write-Info "Security scanning not configured for $ProjectType"
        }
    }
}

# =============================================================================
# Summary
# =============================================================================
Write-Section "Quality Gate Summary"

Write-Host ""
Write-Host "  Passed:   $Script:Passed" -ForegroundColor Green
Write-Host "  Failed:   $Script:Failed" -ForegroundColor Red
Write-Host "  Warnings: $Script:Warnings" -ForegroundColor Yellow
Write-Host ""

if ($Script:Failed -gt 0) {
    Write-Host "[ERROR] Quality gates FAILED" -ForegroundColor Red
    Write-Host ""
    Write-Host "Run with -Fix to attempt automatic fixes"
    exit 1
} else {
    Write-Host "[SUCCESS] All quality gates PASSED" -ForegroundColor Green
    exit 0
}
