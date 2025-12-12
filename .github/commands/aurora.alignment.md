---
description: Analyze alignment between RFP, legacy code, requirements, implementation and AURORA methodology. Detects gaps, coverage percentages, and tracks migration/implementation progress iteratively.
handoffs: 
  - label: Generate Missing Specs
    agent: aurora.specify
    prompt: Generate specifications for uncovered RFP items
    send: true
  - label: Analyze Legacy Code
    agent: aurora.analyze
    prompt: Deep analysis of legacy code for migration gaps
    send: true
  - label: Create Migration Plan
    agent: aurora.plan
    prompt: Create migration plan for identified gaps
    send: true
  - label: Review Compliance
    agent: aurora.review
    prompt: Review compliance with constitution and methodology
    send: true
scripts:
  sh: scripts/bash/alignment-analysis.sh
  ps: scripts/powershell/Get-AlignmentAnalysis.ps1
---

## User Input

```text
$ARGUMENTS
```

**Arguments supported:**
- `full` - Complete alignment analysis (all dimensions)
- `rfp` - RFP coverage analysis only
- `legacy` - Legacy code migration analysis
- `methodology` - AURORA methodology compliance
- `gaps` - Gap analysis summary with recommendations
- `progress` - Progress tracking over time
- `--baseline` - Create baseline for future comparisons
- `--compare [file]` - Compare with previous baseline
- (empty) - Executive summary with top gaps

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

Provide comprehensive alignment analysis to track progress in Greenfield, Brownfield, and Migration projects. Identifies gaps between source materials (RFP, legacy code) and target implementation following AURORA-IA methodology.

**AURORA Stage**: ALL (Meta-command for alignment tracking)

**Responsible Agent**: Alignment Analyzer (Cross-functional)

## Analysis Dimensions

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     ALIGNMENT ANALYSIS DIMENSIONS                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐ │
│  │     RFP     │   │   LEGACY    │   │  AURORA     │   │   TARGET    │ │
│  │  COVERAGE   │   │  MIGRATION  │   │ METHODOLOGY │   │   STATE     │ │
│  └──────┬──────┘   └──────┬──────┘   └──────┬──────┘   └──────┬──────┘ │
│         │                 │                 │                 │        │
│         ▼                 ▼                 ▼                 ▼        │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                      GAP ANALYSIS ENGINE                        │   │
│  │                                                                 │   │
│  │  • Functional Requirements Gap                                  │   │
│  │  • Non-Functional Requirements Gap                              │   │
│  │  • Code Migration Gap                                           │   │
│  │  • Methodology Compliance Gap                                   │   │
│  │  • Documentation Gap                                            │   │
│  │  • Testing Gap                                                  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              │                                         │
│                              ▼                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    ALIGNMENT REPORT                             │   │
│  │         Coverage %, Gaps, Recommendations, Progress             │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Project Type Detection

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    PROJECT TYPE DETECTION                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Read memory/constitution.md Article XVII Section 17.1                  │
│                                                                         │
│  ┌───────────────┐    ┌───────────────┐    ┌───────────────┐           │
│  │  GREENFIELD   │    │  BROWNFIELD   │    │   MIGRATION   │           │
│  │               │    │               │    │               │           │
│  │ • RFP → Specs │    │ • Legacy code │    │ • Full legacy │           │
│  │ • No legacy   │    │ • Enhancement │    │ • Strangler   │           │
│  │ • Clean start │    │ • Hybrid      │    │ • Rewrite     │           │
│  └───────┬───────┘    └───────┬───────┘    └───────┬───────┘           │
│          │                    │                    │                    │
│          ▼                    ▼                    ▼                    │
│  ┌───────────────┐    ┌───────────────┐    ┌───────────────┐           │
│  │ Analyze:      │    │ Analyze:      │    │ Analyze:      │           │
│  │ • RFP coverage│    │ • RFP coverage│    │ • RFP coverage│           │
│  │ • Methodology │    │ • Legacy gaps │    │ • Legacy map  │           │
│  │ • Specs done  │    │ • Methodology │    │ • Migration % │           │
│  │               │    │ • Integration │    │ • Methodology │           │
│  └───────────────┘    └───────────────┘    └───────────────┘           │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Execution Flow

### Step 1: Detect Project Context

```markdown
# Read from memory/constitution.md:

## Project Context
- Type: [ ] Greenfield [ ] Brownfield [ ] Migration
- Scope: [ ] App Only [ ] Infra Only [ ] Full Stack

## Source Materials
- RFP Location: [path or none]
- Legacy Code: [path or none]
- Existing Specs: [specs/ folder]

## Migration Strategy (if applicable)
- [ ] Big Bang
- [ ] Strangler Fig
- [ ] Branch by Abstraction
```

### Step 2: Scan Source Materials

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    SOURCE MATERIAL LOCATIONS                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  📄 RFP / REQUIREMENTS SOURCE                                           │
│  └── demo/from_rfp/              # Original RFP documents               │
│      ├── RFP-*.md                # RFP markdown files                   │
│      ├── *.pdf                   # PDF requirements                     │
│      └── requirements/           # Extracted requirements               │
│                                                                         │
│  📦 LEGACY CODE (Brownfield/Migration)                                  │
│  └── demo/from_old_src/          # Legacy source code                   │
│      ├── *.cbl                   # COBOL files                          │
│      ├── *.vb                    # VB files                             │
│      ├── *.java                  # Java files                           │
│      └── ...                     # Other legacy files                   │
│                                                                         │
│  📋 TARGET SPECIFICATIONS                                               │
│  └── specs/                      # AURORA specs                         │
│      └── [XXX-feature]/                                                 │
│          ├── requirements/       # Requirements                         │
│          ├── planning/           # Plans and tasks                      │
│          ├── contracts/          # API contracts                        │
│          └── tests/              # Test scenarios                       │
│                                                                         │
│  💻 TARGET IMPLEMENTATION                                               │
│  └── src/                        # New implementation                   │
│      ├── domain/                                                        │
│      ├── application/                                                   │
│      ├── infrastructure/                                                │
│      └── presentation/                                                  │
│                                                                         │
│  📊 ANALYSIS OUTPUT                                                     │
│  └── demo/to_rfp/                # RFP analysis results                 │
│  └── demo/to_old_src/            # Legacy analysis results              │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Step 3: RFP Coverage Analysis

For Greenfield and Migration projects:

```markdown
## RFP Coverage Analysis

### RFP Documents Found

| Document | Items | Covered | Pending | Coverage |
|----------|-------|---------|---------|----------|
| RFP-Calculator.md | 15 | 8 | 7 | 53% |
| RFP-UserManagement.md | 22 | 22 | 0 | 100% |
| RFP-Reporting.md | 18 | 5 | 13 | 28% |
| **TOTAL** | **55** | **35** | **20** | **64%** |

### Requirement Traceability Matrix

| RFP ID | Requirement | Feature | User Story | Status |
|--------|-------------|---------|------------|--------|
| RFP-001 | User login | 001-auth | US-001 | ✅ Implemented |
| RFP-002 | Password reset | 001-auth | US-002 | 🔄 In Progress |
| RFP-003 | Calculate tax | 002-calc | - | ❌ Not Started |
| RFP-004 | Generate PDF | 003-report | - | ❌ Not Started |

### Uncovered RFP Items

| Priority | RFP ID | Requirement | Recommended Action |
|----------|--------|-------------|-------------------|
| 🔴 HIGH | RFP-003 | Calculate tax | Create feature spec |
| 🔴 HIGH | RFP-004 | Generate PDF | Create feature spec |
| 🟡 MEDIUM | RFP-008 | Export to Excel | Add to existing feature |
| 🟢 LOW | RFP-012 | Dark mode | Defer to v2 |
```

### Step 4: Legacy Code Analysis (Brownfield/Migration)

```markdown
## Legacy Code Analysis

### Legacy Codebase Summary

| Language | Files | Lines | Functions | Migrated | Coverage |
|----------|-------|-------|-----------|----------|----------|
| COBOL | 12 | 8,500 | 45 | 18 | 40% |
| VB6 | 25 | 12,000 | 120 | 48 | 40% |
| SQL Stored Procs | 35 | 4,200 | 35 | 35 | 100% |
| **TOTAL** | **72** | **24,700** | **200** | **101** | **51%** |

### Legacy to New Mapping

| Legacy Component | New Component | Migration Status | Notes |
|------------------|---------------|------------------|-------|
| CALCMAIN.cbl | CalculatorService | ✅ Complete | Full rewrite |
| CALCENGN.cbl | CalculationEngine | 🔄 In Progress | 60% done |
| UserMgmt.vb | UserModule | ❌ Not Started | Planned Bolt 5 |
| sp_GetReport | ReportingService | ✅ Complete | Using EF Core |

### Untranslated Legacy Functions

| Priority | File | Function | Lines | Complexity | Action |
|----------|------|----------|-------|------------|--------|
| 🔴 HIGH | CALCENGN.cbl | PERFORM-TAX-CALC | 250 | High | Immediate |
| 🔴 HIGH | CALCENGN.cbl | PERFORM-DISCOUNT | 120 | Medium | Immediate |
| 🟡 MEDIUM | UserMgmt.vb | ValidateUser | 80 | Low | Bolt 5 |
| 🟢 LOW | Reports.vb | ExportPDF | 200 | Medium | Bolt 7 |

### Business Rules Extraction

| Rule ID | Description | Source | Extracted | Validated | Implemented |
|---------|-------------|--------|-----------|-----------|-------------|
| BR-001 | Tax calculation 21% | CALCENGN.cbl:45 | ✅ | ✅ | ✅ |
| BR-002 | Discount tiers | CALCENGN.cbl:120 | ✅ | 🔄 | ❌ |
| BR-003 | User permissions | UserMgmt.vb:200 | ❌ | ❌ | ❌ |
| BR-004 | Report formatting | Reports.vb:50 | ✅ | ✅ | 🔄 |
```

### Step 5: AURORA Methodology Compliance

```markdown
## AURORA Methodology Compliance

### AI-DLC Phase Coverage

| Phase | Expected Artifacts | Present | Complete | Compliance |
|-------|-------------------|---------|----------|------------|
| **INCEPTION** | constitution.md | ✅ | 100% | ✅ |
| **DISCOVERY** | RFP analysis, domain model | ✅ | 80% | ⚠️ |
| **SPECIFY** | requirements.md per feature | ✅ | 60% | ⚠️ |
| **PLAN** | plan.md, tasks.md | ✅ | 45% | ⚠️ |
| **EXECUTE** | Source code, tests | ✅ | 40% | ⚠️ |
| **VALIDATE** | Coverage, mutation reports | ❌ | 0% | ❌ |
| **OPERATE** | CI/CD, monitoring | ❌ | 0% | ❌ |

### Artifact Completeness by Feature

| Feature | Req | Data Model | Contracts | Gherkin | Plan | Tasks | Code | Tests |
|---------|-----|------------|-----------|---------|------|-------|------|-------|
| 001-auth | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | 🔄 |
| 002-calc | ✅ | 🔄 | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 003-report | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

### Constitution Compliance

| Article | Section | Compliant | Issues |
|---------|---------|-----------|--------|
| I | Project Scope | ✅ | - |
| II | Application Config | ✅ | - |
| III | Architecture | ⚠️ | CQRS not fully implemented |
| XIII | Testing Standards | ❌ | Coverage below 80% |
| XIV | Code Standards | ✅ | - |

### Missing Methodology Elements

| Priority | Element | Impact | Recommendation |
|----------|---------|--------|----------------|
| 🔴 HIGH | Gherkin scenarios for 002-calc | No BDD tests | Run /aurora.gherkin |
| 🔴 HIGH | Coverage reports | No quality gate | Configure coverage tool |
| 🟡 MEDIUM | API contracts | No contract tests | Run /aurora.specify |
| 🟡 MEDIUM | ADRs for key decisions | Missing documentation | Run /aurora.adr |
```

### Step 6: Gap Summary & Recommendations

```markdown
## Gap Analysis Summary

### Overall Alignment Score

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     OVERALL ALIGNMENT: 52%                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  RFP Coverage      [████████████░░░░░░░░] 64%                          │
│  Legacy Migration  [██████████░░░░░░░░░░] 51%                          │
│  Methodology       [████████░░░░░░░░░░░░] 42%                          │
│  Documentation     [████████████████░░░░] 80%                          │
│  Testing           [██████░░░░░░░░░░░░░░] 30%                          │
│  Infrastructure    [████░░░░░░░░░░░░░░░░] 20%                          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Gap Categories

| Category | Gap Count | Critical | High | Medium | Low |
|----------|-----------|----------|------|--------|-----|
| RFP Requirements | 20 | 3 | 8 | 6 | 3 |
| Legacy Functions | 99 | 12 | 25 | 40 | 22 |
| Methodology | 15 | 2 | 5 | 5 | 3 |
| Testing | 8 | 2 | 3 | 2 | 1 |
| Documentation | 5 | 0 | 2 | 2 | 1 |
| **TOTAL** | **147** | **19** | **43** | **55** | **30** |

### Priority Action Plan

| Priority | Action | Gap Addressed | Effort | Command |
|----------|--------|---------------|--------|---------|
| 1 | Complete CALCENGN.cbl migration | 12 functions | 3d | `/aurora.implement` |
| 2 | Create 002-calc feature spec | RFP-003 to RFP-010 | 1d | `/aurora.feature 002-calc` |
| 3 | Add Gherkin for auth feature | 5 scenarios missing | 0.5d | `/aurora.gherkin` |
| 4 | Configure test coverage | Methodology gap | 0.5d | `/aurora.test coverage` |
| 5 | Generate API contracts | 3 endpoints missing | 1d | `/aurora.specify` |

### Projected Timeline to Full Alignment

| Milestone | Current | Target | Gap | ETA |
|-----------|---------|--------|-----|-----|
| RFP Coverage | 64% | 100% | 36% | +15 days |
| Legacy Migration | 51% | 100% | 49% | +25 days |
| Methodology | 42% | 100% | 58% | +10 days |
| Testing | 30% | 80% | 50% | +8 days |
| **Full Alignment** | **52%** | **90%** | **38%** | **+30 days** |
```

### Step 7: Progress Tracking

```markdown
## Progress Tracking

### Historical Alignment Scores

| Date | Overall | RFP | Legacy | Methodology | Testing | Delta |
|------|---------|-----|--------|-------------|---------|-------|
| 2024-01-01 | 15% | 20% | 10% | 15% | 5% | - |
| 2024-01-08 | 28% | 35% | 25% | 25% | 15% | +13% |
| 2024-01-15 | 42% | 50% | 40% | 35% | 25% | +14% |
| 2024-01-22 | 52% | 64% | 51% | 42% | 30% | +10% |

### Progress Chart

```
100% ┤
 90% ┤                                              ┌─ Target
 80% ┤                                         ┌────┘
 70% ┤                                    ┌────┘
 60% ┤                               ┌────┘
 50% ┤                          ┌────┼──── Current (52%)
 40% ┤                     ┌────┘
 30% ┤                ┌────┘
 20% ┤           ┌────┘
 10% ┤      ┌────┘
  0% ┼──────┴────┴────┴────┴────┴────┴────┴────┴────┴────
     W1   W2   W3   W4   W5   W6   W7   W8   W9   W10
```

### Velocity Analysis

| Week | Gaps Closed | Avg/Week | Remaining | ETA at Current Pace |
|------|-------------|----------|-----------|---------------------|
| W1-W2 | 25 | 12.5 | 147 | 12 weeks |
| W3-W4 | 35 | 17.5 | 112 | 6 weeks |
| W4 | 18 | 18 | 94 | 5 weeks |

### Burndown

```
Gaps
150 ┤ ■
125 ┤   ■
100 ┤     ■──■ ← Current (94 gaps)
 75 ┤         ╲
 50 ┤           ╲
 25 ┤             ╲
  0 ┼───────────────╲─────
    W1  W2  W3  W4  W5  W6
```
```

## Output Formats

### Summary Mode (default)

Quick overview with top gaps and recommended actions.

### Full Report

Complete analysis across all dimensions with detailed matrices.

### JSON Export

```json
{
  "alignment": {
    "overall": 52,
    "rfp": 64,
    "legacy": 51,
    "methodology": 42,
    "testing": 30,
    "infrastructure": 20
  },
  "gaps": {
    "total": 147,
    "critical": 19,
    "high": 43,
    "medium": 55,
    "low": 30
  },
  "progress": {
    "velocity": 18,
    "eta_weeks": 5,
    "trend": "improving"
  }
}
```

### Baseline Mode

Create baseline for future comparisons:

```bash
./scripts/bash/alignment-analysis.sh --baseline
# Creates: memory/baselines/alignment_2024-01-22.json
```

Compare with previous baseline:

```bash
./scripts/bash/alignment-analysis.sh --compare memory/baselines/alignment_2024-01-15.json
# Shows: Delta analysis between dates
```

## Integration with Demo Folders

The analysis uses the `demo/` folder structure:

```
demo/
├── from_rfp/           # 📥 INPUT: Original RFP documents
│   └── RFP-Calculator.md
├── from_old_src/       # 📥 INPUT: Legacy code to migrate
│   ├── CALCENGN.cbl
│   └── CALCMAIN.cbl
├── to_rfp/             # 📤 OUTPUT: RFP analysis results
│   └── README.md       # Analysis reports go here
└── to_old_src/         # 📤 OUTPUT: Legacy analysis results
    └── README.md       # Migration analysis goes here
```

## Iterative Usage

### Daily Standup

```bash
# Quick gap status for standup
./scripts/bash/alignment-analysis.sh --gaps
```

### Sprint Planning

```bash
# Full analysis for sprint planning
./scripts/bash/alignment-analysis.sh full --save
```

### Sprint Review

```bash
# Compare with sprint start baseline
./scripts/bash/alignment-analysis.sh --compare memory/baselines/sprint_start.json
```

### Release Readiness

```bash
# Full alignment check before release
./scripts/bash/alignment-analysis.sh full
# Must show: Overall >= 90%, Critical gaps = 0
```

## AI Agent Collaboration

When asked about project alignment:

```
@aurora /aurora.alignment          # Quick summary
@aurora /aurora.alignment full     # Complete analysis
@aurora /aurora.alignment rfp      # RFP coverage only
@aurora /aurora.alignment legacy   # Legacy migration only
@aurora /aurora.alignment gaps     # Gap summary
```

The agent will:
1. Detect project type (Greenfield/Brownfield/Migration)
2. Scan all source materials
3. Calculate alignment percentages
4. Identify critical gaps
5. Recommend prioritized actions

## Constitution Reference

| Article | Section | Relevance |
|---------|---------|-----------|
| Article I | 1.0 | Project scope determines analysis type |
| Article XVII | 17.1 | Migration context (Greenfield/Brownfield/Migration) |
| Article XVII | 17.2 | Migration strategy (Strangler Fig, etc.) |
| Article XIII | 13.1-13.4 | Testing standards for compliance check |
| Article XIX | 19.2 | AI Agent compliance checklist |
