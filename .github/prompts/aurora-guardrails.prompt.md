# Guardrails Definition Prompt

## Agent Reference

> **Primary Agent**: [Policy Guardian](../copilot/agents/aurora-policy-guardian.md)  
> **Phase**: Foundation / Cross-cutting  
> **Constitution**: Read `memory/constitution.md` for existing policies

## Context

Use this prompt when defining technical and ethical guardrails for the project. Guardrails are explicit boundaries that the AI and development team must respect. This prompt guides Copilot to act as the **Policy Guardian Agent** focused on guardrail definition.

## Instructions

When defining guardrails:

### 1. Constitution Alignment
- Read `memory/constitution.md` for existing policies
- Extract implicit guardrails from tech stack choices
- Identify compliance requirements
- Note security policies already defined

### 2. Guardrail Principles
- **Explicit Over Implicit**: Write down all boundaries clearly
- **Hard vs Soft**: Distinguish blocking rules from warnings
- **Justified**: Every guardrail needs a rationale
- **Testable**: Guardrails must be verifiable
- **Living**: Update as project evolves

### 3. Guardrail Categories

#### Technical Guardrails
- Approved technologies and versions
- Prohibited patterns or libraries
- Performance thresholds
- Resource limits

#### Security Guardrails
- Authentication requirements
- Data handling rules
- Secret management
- Vulnerability thresholds

#### Ethical Guardrails
- AI usage boundaries
- Data privacy limits
- Bias prevention
- Transparency requirements

#### Operational Guardrails
- Deployment restrictions
- Change management rules
- Incident response requirements
- SLA boundaries

### 4. Output Format

Generate `docs/guardrails/guardrails.md`:

```markdown
# Project Guardrails

## Document Info

| Property | Value |
|----------|-------|
| Version | [X.Y] |
| Last Updated | [YYYY-MM-DD] |
| Owner | [Team/Person] |
| Review Cycle | [Monthly/Quarterly] |
| Constitution Ref | memory/constitution.md |

---

## Guardrails System Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        🛡️ AI-DLC GUARDRAILS SYSTEM                          │
│                    (Lifecycle Protection Boundaries)                        │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
        ┌─────────────────────────────┼─────────────────────────────┐
        │                             │                             │
        ▼                             ▼                             ▼
┌───────────────────┐     ┌───────────────────┐     ┌───────────────────┐
│   🔴 HARD         │     │   🟡 SOFT         │     │   🔵 GUIDELINES   │
│      LIMITS       │     │      LIMITS       │     │                   │
│   (Blocking)      │     │   (Warnings)      │     │   (Suggestions)   │
├───────────────────┤     ├───────────────────┤     ├───────────────────┤
│ • Stops CI/CD     │     │ • Generates alerts│     │ • Informational   │
│ • Non-negotiable  │     │ • Manual review   │     │ • Best practices  │
│ • Requires fix    │     │ • Tech debt track │     │ • Documentation   │
└───────────────────┘     └───────────────────┘     └───────────────────┘
```

### Guardrail Categories

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         📋 GUARDRAIL CATEGORIES                             │
├─────────────────┬─────────────────┬─────────────────┬───────────────────────┤
│   🔧 TECHNICAL  │  🔐 SECURITY    │   ⚖️ ETHICAL   │   🏭 OPERATIONAL     │
├─────────────────┼─────────────────┼─────────────────┼───────────────────────┤
│ • Approved      │ • Authentication│ • Human AI      │ • Deployment          │
│   technologies  │ • Data handling │   oversight     │   restrictions        │
│ • Prohibited    │ • Secrets mgmt  │ • Privacy       │ • Change management   │
│   patterns      │ • Critical      │ • Bias prevent  │ • Incident response   │
│ • Performance   │   vulnerab.     │ • Transparency  │ • SLA boundaries      │
│   thresholds    │ • Zero-Trust    │ • Consent       │ • Rollback required   │
└─────────────────┴─────────────────┴─────────────────┴───────────────────────┘
```

### Enforcement Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          🔄 ENFORCEMENT FLOW                                │
│                                                                             │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐              │
│  │   📝     │    │   🔍     │    │   ⚡     │    │   ✅     │              │
│  │  Code    │───▶│  Static  │───▶│ Guardrail│───▶│ Decision │              │
│  │ /Config  │    │ Analysis │    │   Eval   │    │          │              │
│  └──────────┘    └──────────┘    └──────────┘    └────┬─────┘              │
│                                                       │                     │
│                    ┌──────────────────────────────────┼───────────────────┐ │
│                    │                                  │                   │ │
│                    ▼                                  ▼                   ▼ │
│             ┌──────────┐                       ┌──────────┐        ┌──────┐│
│             │ 🚫 BLOCK │                       │ ⚠️ WARN  │        │✅ OK ││
│             │ Pipeline │                       │ Continue │        │Pass  ││
│             │ Stopped  │                       │ +Report  │        │      ││
│             └──────────┘                       └──────────┘        └──────┘│
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Guardrail Summary

| Category | Hard Limits | Soft Limits | Total |
|----------|-------------|-------------|-------|
| Technical | [N] | [N] | [N] |
| Security | [N] | [N] | [N] |
| Ethical | [N] | [N] | [N] |
| Operational | [N] | [N] | [N] |

---

## 🔴 Hard Limits (Blocking)

These guardrails are **non-negotiable**. Violations must be fixed before proceeding.

### Technical Hard Limits

| ID | Rule | Rationale | Verification | ADR |
|----|------|-----------|--------------|-----|
| HT-001 | Only use approved languages from Constitution | Maintainability, team skills | Build pipeline | - |
| HT-002 | No deprecated APIs | Security, stability | Linter rules | - |
| HT-003 | Test coverage ≥ [X]% for new code | Quality assurance | CI gate | ADR-XXX |

### Security Hard Limits

| ID | Rule | Rationale | Verification | ADR |
|----|------|-----------|--------------|-----|
| HS-001 | No secrets in source code | Security | Secret scanner | - |
| HS-002 | No PII in logs | GDPR/Privacy | Log audit | ADR-XXX |
| HS-003 | All external inputs sanitized | OWASP | SAST scan | - |
| HS-004 | Zero critical vulnerabilities | Security | Dependency scan | - |
| HS-005 | Authentication required for all APIs | Security | API tests | ADR-XXX |

### Ethical Hard Limits

| ID | Rule | Rationale | Verification | ADR |
|----|------|-----------|--------------|-----|
| HE-001 | AI outputs reviewed by human | Accountability | Process | - |
| HE-002 | No training on user data without consent | Privacy | Audit | - |
| HE-003 | Transparent AI involvement in features | Trust | Documentation | - |

### Operational Hard Limits

| ID | Rule | Rationale | Verification | ADR |
|----|------|-----------|--------------|-----|
| HO-001 | No direct production access | Security | IAM policies | - |
| HO-002 | All deployments through CI/CD | Auditability | Pipeline | ADR-XXX |
| HO-003 | Rollback capability required | Reliability | Deploy scripts | - |

---

## 🟡 Soft Limits (Warnings)

These guardrails are **strongly recommended**. Violations generate warnings and should be addressed.

### Technical Soft Limits

| ID | Rule | Rationale | Threshold | Current |
|----|------|-----------|-----------|---------|
| ST-001 | Cyclomatic complexity | Maintainability | <15 per method | [X] |
| ST-002 | File size | Readability | <500 lines | [X] |
| ST-003 | Method parameters | Complexity | ≤5 params | [X] |
| ST-004 | Response time P95 | Performance | <200ms | [X]ms |

### Security Soft Limits

| ID | Rule | Rationale | Threshold | Current |
|----|------|-----------|-----------|---------|
| SS-001 | High vulnerabilities | Security | <5 | [X] |
| SS-002 | Dependency freshness | Security | <6 months old | [X] |
| SS-003 | Failed login attempts | Security | Rate limit 5/min | [X] |

### Quality Soft Limits

| ID | Rule | Rationale | Threshold | Current |
|----|------|-----------|-----------|---------|
| SQ-001 | Code duplication | Maintainability | <3% | [X]% |
| SQ-002 | Documentation coverage | Usability | >80% public APIs | [X]% |
| SQ-003 | Technical debt ratio | Sustainability | <5% | [X]% |

---

## Technology Constraints

### Approved Technologies

| Category | Approved | Version | Notes |
|----------|----------|---------|-------|
| Backend Language | [From Constitution] | [Version] | - |
| Frontend Framework | [From Constitution] | [Version] | - |
| Database | [From Constitution] | [Version] | - |
| Cloud Provider | [From Constitution] | - | - |

### Prohibited Technologies

| Technology | Reason | Alternative |
|------------|--------|-------------|
| [Tech] | [Why prohibited] | [What to use instead] |

### Approved Libraries

| Category | Library | Version | Approval Date |
|----------|---------|---------|---------------|
| [Cat] | [Lib] | [Ver] | [Date] |

---

## AI-Specific Guardrails

### AI Code Generation

| ID | Rule | Rationale |
|----|------|-----------|
| AI-001 | Review all AI-generated code before commit | Quality/Security |
| AI-002 | No AI generation of security-critical code without expert review | Security |
| AI-003 | Document AI involvement in code comments | Transparency |

### AI Behavior

| ID | Rule | Rationale |
|----|------|-----------|
| AI-004 | Respect Constitution as highest authority | Governance |
| AI-005 | Request clarification on ambiguous requirements | Quality |
| AI-006 | Flag potential security concerns proactively | Security |

---

## Enforcement

### Automated Checks

| Guardrail | Tool | Stage | Action |
|-----------|------|-------|--------|
| Secret detection | [Tool] | Pre-commit | Block |
| SAST | [Tool] | CI | Block on critical |
| Test coverage | [Tool] | CI | Block below threshold |
| Dependency scan | [Tool] | CI | Block on critical |
| Linting | [Tool] | Pre-commit | Warn |

### Manual Reviews

| Guardrail | Reviewer | Frequency |
|-----------|----------|-----------|
| Architecture compliance | Omega Architect | Per feature |
| Security review | Policy Guardian | Pre-release |
| Ethical review | [Role] | Quarterly |

---

## Exception Process

### Exception Process Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       📌 EXCEPTION PROCESS                                  │
│                                                                             │
│   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐    │
│   │ 1. Request  │──▶│ 2. Justify  │──▶│ 3. Define   │──▶│ 4. Approve  │    │
│   │  exception  │   │   the why   │   │  compens.   │   │  + set limit│    │
│   └─────────────┘   └─────────────┘   └─────────────┘   └─────────────┘    │
│                                                                             │
│   📋 Registry: ID | Guardrail | Scope | Expires | Owner | Approvers        │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Requesting an Exception

1. Document the guardrail being excepted
2. Explain why exception is needed
3. Define scope and duration
4. Identify compensating controls
5. Get required approvals

### Exception Template

```markdown
## Guardrail Exception Request

| Property | Value |
|----------|-------|
| Guardrail ID | [ID] |
| Requestor | [Name] |
| Date | [Date] |
| Duration | Permanent / Until [Date] |

### Justification
[Why this exception is needed]

### Scope
[What specifically is excepted]

### Compensating Controls
[Alternative protections in place]

### Approvals
- [ ] Tech Lead
- [ ] Security (if security guardrail)
- [ ] Architecture (if technical guardrail)
```

### Active Exceptions

| ID | Guardrail | Scope | Expires | Owner |
|----|-----------|-------|---------|-------|
| [ID] | [Guardrail] | [Scope] | [Date] | [Name] |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | [Date] | [Name] | Initial version |
```

## Example Usage

### Initial Guardrails Generation

```
#file:.github/prompts/aurora-guardrails.prompt.md

Generate project guardrails based on:
1. Constitution: memory/constitution.md
2. Tech stack: .NET 8, React, PostgreSQL
3. Compliance: GDPR, SOC2
4. Team size: 5 developers
```

### Adding New Guardrail

```
Add a new security guardrail:
- Rule: All API endpoints must implement rate limiting
- Threshold: 100 requests/minute per client
- Rationale: Prevent abuse and ensure availability
- Verification: Integration tests
```

### Reviewing Guardrail Violations

```
Review current guardrail status and identify violations:
1. Run all verification checks
2. List violations by severity
3. Propose remediation actions
4. Estimate effort to resolve
```

## Integration Points

### SAST/DAST Integration

```yaml
# Example CI integration for guardrail enforcement
guardrails:
  sast:
    tool: sonarqube
    fail_on: critical, high
    report: docs/security/sast_findings.md
    
  dast:
    tool: owasp-zap
    fail_on: critical
    report: docs/security/dast_findings.md
    
  dependencies:
    tool: snyk
    fail_on: critical
    report: docs/security/dependency_findings.md
```

### ADR Generation

When a guardrail requires architectural justification, generate ADR:

```
/aurora.adr Create ADR for guardrail [ID]: [Description]
```

## Collaboration Notes

- **Defines for**: All agents (Policy Guardian enforces across all outputs)
- **Informed by**: Constitution, security requirements, compliance needs
- **Updated by**: Policy Guardian, Architecture reviews, Security audits
- **Artifacts**: `docs/guardrails/guardrails.md`, linked ADRs
