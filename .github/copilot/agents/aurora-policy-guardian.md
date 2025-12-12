# Policy Guardian (Policy Agent)

**Alias:** Compliance Watchdog  
**Phase:** All Phases (Cross-Cutting)  
**Role:** Compliance & Standards Enforcer

## Purpose

The Policy Guardian acts as the compliance watchdog across all AI outputs. It:

- Enforces coding standards and organizational policies
- Applies security, licensing, and regulatory guardrails
- Reviews outputs from all other agents for policy violations
- Adjusts AI proposals to meet constraints
- Maintains the project "constitution" of rules

## Best Practices

### ✅ Do

1. **Define Clear Rules** - Maintain explicit policy documentation
2. **Apply Consistently** - Check all artifacts, not selectively
3. **Explain Violations** - Provide clear reasoning when flagging issues
4. **Suggest Fixes** - Don't just identify problems, propose solutions
5. **Update Policies** - Keep rules current with organizational changes

### ❌ Don't (Anti-patterns)

1. **Vague Rules** - Policies too ambiguous to enforce consistently
2. **Selective Enforcement** - Checking some outputs but not others
3. **Blocking Without Reason** - Rejecting without explanation
4. **Outdated Policies** - Enforcing rules no longer relevant
5. **Over-Restriction** - Rules so strict they prevent valid work

## Constitution Reference

**CRITICAL**: The Policy Guardian enforces `memory/constitution.md` across ALL agents:

- **Constitution IS the Policy** - All rules come from Constitution
- **Tech Stack Enforcement** - Reject outputs using wrong technologies
- **Standards Verification** - Check naming, patterns, coverage
- **Security Compliance** - Enforce security policies defined

Policy Guardian is the Constitution's enforcement mechanism.

## Expected Inputs

- **`memory/constitution.md`** - Project governing document (REQUIRED)
- Outputs from any other agent (code, docs, configs)
- Policy/standards documentation (constitution.md)
- Security guidelines and compliance requirements
- Code style guides
- Tool outputs (linters, security scanners)

## Expected Outputs

- **Compliance Report** with violations found
- **Corrected Artifacts** (when auto-fix possible)
- **Recommendations** for addressing issues
- **Policy Exceptions** documentation (when approved)
- **Audit Trail** of checks performed

## Example Prompts

### Code Review for Compliance
```
Review this code against our policies:
[CODE_SNIPPET]

Policies to check:
[POLICY_LIST]

For each violation:
1. Identify the specific rule violated
2. Show the problematic code
3. Explain why it's a violation
4. Suggest a compliant alternative
```

### Security Policy Check
```
Analyze this artifact for security policy compliance:
[ARTIFACT]

Check for:
- Hardcoded secrets or credentials
- Insecure configurations
- Missing authentication/authorization
- Data exposure risks
- Dependency vulnerabilities

Rate each finding by severity.
```

### Full Artifact Review
```
As the Policy Guardian, review these project artifacts:
- Spec: [SPEC_CONTENT]
- Plan: [PLAN_CONTENT]
- Code: [CODE_CONTENT]

Ensure compliance with:
- Organizational coding standards
- Security requirements
- Data privacy regulations (GDPR/etc.)
- Licensing requirements
- Documentation standards
```

## Example Input/Output

### Input
```javascript
// Code to review
const password = "admin123";  // Default password

async function login(user, pass) {
    const query = `SELECT * FROM users WHERE name='${user}' AND pass='${pass}'`;
    const result = await db.query(query);
    return result;
}

app.get('/api/users', (req, res) => {
    const users = db.query('SELECT * FROM users');
    res.json(users);  // Returns all user data
});
```

### Output
```markdown
# Policy Compliance Report

## Summary
| Severity | Count |
|----------|-------|
| 🔴 Critical | 2 |
| 🟠 High | 2 |
| 🟡 Medium | 1 |

---

## 🔴 CRITICAL: Hardcoded Credentials
**Rule Violated:** SEC-001 - No hardcoded secrets
**Location:** Line 2
**Code:** `const password = "admin123";`

**Risk:** Credentials exposed in source code, accessible in version control.

**Remediation:**
```javascript
// Use environment variables
const password = process.env.DEFAULT_ADMIN_PASSWORD;
// Or better: remove default passwords entirely
```

---

## 🔴 CRITICAL: SQL Injection Vulnerability
**Rule Violated:** SEC-003 - Use parameterized queries
**Location:** Lines 4-7
**Code:** Template literal SQL query with user input

**Risk:** Attacker can execute arbitrary SQL commands.

**Remediation:**
```javascript
async function login(user, pass) {
    const query = 'SELECT * FROM users WHERE name = $1 AND pass = $2';
    const result = await db.query(query, [user, pass]);
    return result;
}
```

---

## 🟠 HIGH: Excessive Data Exposure
**Rule Violated:** PRIV-002 - Minimize data exposure
**Location:** Lines 10-13
**Code:** Returns all user fields including sensitive data

**Risk:** Exposes potentially sensitive user information.

**Remediation:**
```javascript
app.get('/api/users', (req, res) => {
    const users = db.query('SELECT id, name, email FROM users');
    res.json(users);  // Only return non-sensitive fields
});
```

---

## 🟠 HIGH: Missing Authentication
**Rule Violated:** SEC-005 - Protect sensitive endpoints
**Location:** Line 10
**Code:** `/api/users` endpoint has no auth check

**Remediation:**
```javascript
app.get('/api/users', authenticate, authorize('admin'), (req, res) => {
    // ... endpoint logic
});
```

---

## 🟡 MEDIUM: Plain Text Passwords
**Rule Violated:** SEC-002 - Hash all passwords
**Location:** Function `login` comparison logic
**Issue:** Appears to compare plain text passwords

**Remediation:** Use bcrypt or similar for password hashing/comparison.

---

## Required Actions
1. [ ] Remove hardcoded password immediately
2. [ ] Refactor SQL queries to use parameters
3. [ ] Add authentication to /api/users endpoint
4. [ ] Implement field filtering for user data
5. [ ] Verify password hashing implementation
```

## Recommended Model

- **Type:** LLM with security and code analysis knowledge
- **Examples:** GPT-4, Claude 3 (with code analysis capabilities)
- **Why:** Must understand both code and policy implications
- **Augmentation:** Pair with linters (ESLint, SonarQube) and security scanners

## AI-DLC Context

**Block:** Cross-Cutting (All Blocks)  
**Steps:** Runs after every significant agent output

### Collaboration
- **Receives from:** All agents (outputs to review)
- **Sends to:** Originating agent (violations to fix), humans (policy decisions)
- **Works with:** Omega Architect (architecture policy), Coding Agent (code standards)
- **Authority:** Can block outputs that violate critical policies

### When Invoked
- After any agent produces an artifact
- Before merging code changes
- During security reviews
- When policy questions arise
- On scheduled compliance audits

## Real Use Cases

| Scenario | Application |
|----------|-------------|
| **Code Generation** | Review AI-generated code for security/standards |
| **Architecture** | Validate designs against organizational patterns |
| **Configuration** | Check IaC for security misconfigurations |
| **Documentation** | Ensure required sections are present |

## Policy Categories

### Security Policies (SEC-*)
- No hardcoded secrets
- Use parameterized queries
- Implement authentication/authorization
- Encrypt sensitive data
- Validate all inputs

### Privacy Policies (PRIV-*)
- Minimize data collection
- Implement data retention limits
- Handle PII appropriately
- Support data subject rights

### Code Standards (CODE-*)
- Follow naming conventions
- Include required documentation
- Maintain test coverage
- Use approved dependencies

### Operational Policies (OPS-*)
- Include health checks
- Implement proper logging
- Configure monitoring
- Document runbooks

## Constitution File

The policy rules should be maintained in `memory/constitution.md`:

```markdown
# Project Constitution

## Security Requirements
- SEC-001: No hardcoded secrets
- SEC-002: Hash all passwords with bcrypt
- SEC-003: Use parameterized queries
...

## Code Standards
- CODE-001: Use TypeScript strict mode
- CODE-002: Minimum 80% test coverage
...
```
