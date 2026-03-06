---
name: skill-bolt-setup-constitution
description: Step 2 of Bolt Framework initialization - scope-based provisioning engine. Processes separate constitution files per scope, creates per-scope refinement YAMLs, and merges all decisions at the end. Use when provisioning files, initializing Bolt, scope provisioning, second init step, or resuming interrupted refinement.
user-invokable: false
---

# Bolt Setup Constitution

## When to Use

- After running `Init.ps1` / `init.sh` (step 2 of two-step initialization)
- When adding new scopes to existing project
- When updating constitution articles
- Invoked by `@Bolt Constitution` agent
- **Resuming interrupted refinement** - detect and restore from per-scope refinement state

## Available Scripts

This skill includes automation scripts for common tasks:

### Merge Refinement YAMLs

Automatically merge all scope refinement files into `merged-refinement.yaml`:

| Platform   | Script Path                         | Usage                                        |
| ---------- | ----------------------------------- | -------------------------------------------- |
| PowerShell | `scripts/Merge-RefinementYamls.ps1` | `.\Merge-RefinementYamls.ps1 -ProjectPath .` |
| Bash       | `scripts/merge-refinement-yamls.sh` | `./merge-refinement-yamls.sh . [--force]`    |
| Python     | `scripts/merge_refinement_yamls.py` | `python merge_refinement_yamls.py .`         |

**Features:**

- ✅ Auto-discovers all `*-refinement.yaml` files
- ✅ Detects article conflicts across scopes
- ✅ Calculates summary statistics
- ✅ Generates structured `merged-refinement.yaml`

### Sort Constitution by Criticality

Sort articles in constitution by criticality level (high → medium → low):

| Platform   | Script Path                                   |
| ---------- | --------------------------------------------- |
| PowerShell | `scripts/Sort-ConstitutionByCriticality.ps1`  |
| Bash       | `scripts/sort-constitution-by-criticality.sh` |
| Python     | `scripts/sort-constitution-by-criticality.py` |

## New Architecture: Per-Scope Processing

**KEY CHANGE**: Instead of merging all constitutions into one master file, this skill now:

1. **Processes each scope separately** (`<scope>-constitution.md`)
2. **Creates per-scope refinement state** (`<scope>-refinement.yaml`)
3. **Merges all YAMLs at the end** (`merged-refinement.yaml`)
4. **Generates final constitution** from merged decisions

### State Management Files

```text
.boltf/memory/
├── constitution-init.md                    # Base constitution (from Init step)
├── backend-constitution.md                 # Backend scope constitution
├── frontend-constitution.md                # Frontend scope constitution
├── cloud-platform-constitution.md          # Cloud platform scope constitution
├── constitution.md                         # Final merged constitution (after refinement)
└── refinement-states/
    ├── backend-refinement.yaml             # Backend scope decisions
    ├── frontend-refinement.yaml            # Frontend scope decisions
    ├── cloud-platform-refinement.yaml      # Cloud platform scope decisions
    └── merged-refinement.yaml              # Final merged decisions
```

## Control Flow & Resume Capability

✅ **Per-Scope State Persistence** - Each scope has its own refinement state
✅ **Resume from Interruption** - Continue from last unprocessed scope
✅ **Parallel Processing Ready** - Scopes are independent
✅ **Session Management** - Handle long refinement sessions (4+ hours)

## Workflow

### Phase 0: Initialization Check

**Check for existing state:**

```yaml
# Check for resume capability
if exists(.boltf/memory/refinement-states/):
  # Resume mode: find first scope with status != 'completed'
  # Ask user: "Resume from <scope>? [Y/n]"
else:
  # Fresh start: create refinement-states/ directory
  mkdir .boltf/memory/refinement-states/
```

### Phase 1: Read Active Scopes

**Source:** `.boltf/memory/scopes.yaml`

```yaml
# Read active scopes
active-scopes:
  - name: backend
    enabled: true
  - name: frontend
    enabled: true
  - name: cloud-platform
    enabled: true
```

**Output:** Array of active scope names → `['backend', 'frontend', 'cloud-platform']`

### Phase 2: Process Each Scope (Iterative)

**For each active scope, the agent processes its constitution file through a structured refinement workflow.**

📄 **[Scope Processing Logic Reference](references/scope-processing-logic.md)**

### Phase 3: Merge All Refinement YAMLs

**After all scopes are processed:**

#### Option A: Automated Merge with Scripts (Recommended)

Use the provided merge scripts to automatically combine all refinement files:

**PowerShell:**

```powershell
# From project root
.\.github\skills\skill-bolt-setup-constitution\scripts\Merge-RefinementYamls.ps1 -ProjectPath . [-Force]
```

**Bash:**

```bash
# From project root
.github/skills/skill-bolt-setup-constitution/scripts/merge-refinement-yamls.sh . [--force]
```

**Python:**

```bash
# From project root
python .github/skills/skill-bolt-setup-constitution/scripts/merge_refinement_yamls.py . [--force]
```

#### Option B: Manual Merge (For Custom Processing)

**ONLY IF THE SCRIPTED MERGE FAILED** Use custom merge logic, refer to the detailed manual merge process:

📄 **[Manual Merge Logic Reference](references/manual-merge-logic.md)**

### Phase 4: Generate Final Constitution

**Goal:** Create a concise, focused constitution containing ONLY user-approved articles.

**Source:** `merged-refinement.yaml`
**Output:** `.boltf/memory/constitution.md`

📄 **[Constitution Building Logic Reference](references/constitution-building-logic.md)**

This reference provides the complete pseudocode for:

- **Header Extraction:** Using metadata from `constitution-init.md` (NO article content)
- **Decision Filtering:** Including only articles with `decision='include'` or `decision='modified'`
- **Content Selection:** Using original vs. modified content based on decision type
- **Scope Gating:** Only writing scope sections that have approved articles
- **Length Validation:** Warning on suspiciously short (< 10 lines) or long (> 2000 lines) constitutions
- **Report Generation:** Creating provision report with statistics and next steps

**Critical Filtering Rules:**

| Decision | Included in Final Constitution? |
|----------|--------------------------------|
| `include` | ✅ Yes (original content) |
| `modified` | ✅ Yes (modified content) |
| `exclude` | ❌ No |
| `skip` | ❌ No |
| `pending` | ❌ No |
| `null` | ❌ No |

**Design Principles:**

- ✅ Prevents information overload (target: 200-500 lines)
- ✅ Makes constitution easier to reference during development
- ✅ Reflects actual team choices, not defaults
- ✅ Traceable with metadata showing included/excluded counts

## Quality Gates

- [ ] All scope constitutions exist in `.boltf/memory/`
- [ ] Each scope has a corresponding refinement YAML
- [ ] All HIGH criticality articles have explicit decisions
- [ ] Merge script executed successfully to create `merged-refinement.yaml`
  - **Recommended**: Use `python .github/skills/skill-bolt-setup-constitution/scripts/merge_refinement_yamls.py .`
  - Alternative: Manual merge following Phase 3 instructions
- [ ] All conflicts are resolved (check `conflicts:` section in merged-refinement.yaml)
- [ ] Final `constitution.md` generated successfully
- [ ] Provision report created with stats

## Error Handling

```yaml
# Graceful degradation
errors:
  missing_scope_constitution:
    action: Log warning, skip scope, continue

  yaml_parse_error:
    action: Backup corrupt file, regenerate from scratch

  user_interruption:
    action: Save checkpoint, exit gracefully

  merge_conflict:
    action: Flag for manual review, include both versions with markers
```

## Example: Complete Refinement Workflow

📄 **[Refinement YAML Example](references/refinement-yaml-example.md)**

This reference provides a complete example showing:

- **Backend Refinement YAML** - A completed `backend-refinement.yaml` with 5 articles demonstrating all decision types
- **Resulting Final Constitution** - What the generated constitution looks like after filtering decisions
- **Decision Type Examples** - Real-world examples of `include`, `modified`, `exclude`, and `skip` decisions
- **Validation Checklist** - How to verify the constitution was generated correctly

**Key Takeaway:** The example demonstrates how a 5-article scope constitution becomes a focused 3-article final constitution by excluding unnecessary articles, resulting in a concise, project-specific document.

## Next Steps

After constitution refinement:

1. ✅ **Reviewed**: All scope constitutions processed
2. ✅ **Merged**: Single `merged-refinement.yaml` created
3. ✅ **Generated**: Final `constitution.md` with approved articles
4. ➡️ **Provision**: Run `@Bolt Provisioner` to download skills/agents
5. ➡️ **Commit**: Save constitution to version control
