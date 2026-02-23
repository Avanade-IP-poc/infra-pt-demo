# Brownfield Workflow — Legacy Modernization

> Workflow example for migrating legacy code (e.g., COBOL) to a modern stack.

---

## Overview

```text
Init (brownfield) → Constitution → Analyze Legacy → Feature Map → Plan → [Bolt Loop with Parity Tests] → Release
```

## Step-by-Step

### 1. Initialize with Legacy Source

**Bash**:

```bash
./init.sh my-modern-app brown --source ./legacy-cobol --scope full-stack --backend csharp
```

**PowerShell**:

```powershell
.\Init.ps1 -ProjectName "my-modern-app" -Type brownfield -SourceDir "./legacy-cobol"
```

This creates:

```text
my-modern-app/
├── memory/
│   └── constitution.md
├── legacy/                  # ← Legacy code copied here for analysis
│   ├── CALCMAIN.cbl
│   └── CALCENGN.cbl
├── specs/
├── src/
└── scripts/
```

### 2. Define Modern Constitution

Invoke `@Aurora Constitution`:

```text
"Define constitution for modernizing a COBOL calculator application to
.NET 8 Web API with React frontend. Must maintain functional parity
with the legacy COBOL code in the legacy/ folder."
```

The constitution MUST include:

- Modern tech stack
- **Parity testing requirement** — all legacy functions must have equivalent modern tests
- Migration strategy (strangler fig, big bang, etc.)

### 3. Analyze Legacy Code

Invoke `@Aurora Analyze`:

```text
"Analyze the legacy COBOL code in legacy/ folder. Identify:
- All business functions and calculations
- Data structures and record layouts
- Control flow and decision logic
- External dependencies
Map each to a modern equivalent."
```

**Output**: Analysis document with legacy function inventory.

### 4. Create Feature Map

Invoke `@Aurora Feature`:

```text
"Create feature specifications that map each legacy COBOL function to a
modern feature. Include parity acceptance criteria."
```

**Output**: Feature specs with:

- Each legacy function → modern user story
- Parity acceptance criteria (same inputs → same outputs)
- Edge cases from legacy code

### 5. Plan Migration

Invoke `@Aurora Plan`:

```text
"Create migration plan. Use strangler fig pattern — implement modern
features alongside legacy, with parity tests validating equivalence."
```

### 6. Implement with Parity Tests

For each Bolt, `@Aurora Implement` will:

1. Read legacy code for reference
2. Implement modern equivalent
3. Write **parity tests** — same inputs/outputs as legacy
4. Validate functional equivalence

```bash
# Example parity test
test("legacy COBOL calculation matches modern", () => {
  const legacyResult = 42.50;  // Known COBOL output for input X
  const modernResult = calculator.compute(inputX);
  expect(modernResult).toBeCloseTo(legacyResult, 2);
});
```

### 7. Validate & Release

- `@Aurora Testing` — Ensure 100% parity with legacy functions
- `@Aurora Review` — Verify no legacy behavior lost
- `@Aurora Release` — Deploy modern replacement

---

## Key Differences from Greenfield

| Aspect | Greenfield | Brownfield |
|--------|-----------|------------|
| Init type | `green` | `brown --source` |
| Legacy folder | None | `legacy/` with source code |
| Tests focus | New features | Parity with legacy |
| Constitution | Defines new stack | Defines modern stack + migration strategy |
| Feature specs | New user stories | Mapped from legacy functions |
| Risk | Lower | Higher — must maintain equivalence |
