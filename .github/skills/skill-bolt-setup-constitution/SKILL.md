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

**For each active scope:**

```text
FOR EACH scope IN active_scopes:

  # Step 2.1: Check if scope already processed
  IF exists(.boltf/memory/refinement-states/{scope}-refinement.yaml):
    READ state from {scope}-refinement.yaml
    IF state.status == 'completed':
      SKIP to next scope
    ELSE:
      RESUME from last processed article

  # Step 2.2: Read scope constitution
  READ .boltf/memory/{scope}-constitution.md

  # Step 2.3: Initialize refinement state (if new)
  CREATE .boltf/memory/refinement-states/{scope}-refinement.yaml:
    scope: {scope}
    status: in-progress
    total_articles: [count from constitution]
    articles: []
    decisions: []

  # Step 2.4: Extract articles from scope constitution
  EXTRACT articles (Article I, Article II, etc.)
  FOR EACH article:
    ADD to {scope}-refinement.yaml:
      - number: "I"
        title: "Article Title"
        criticality: HIGH | MEDIUM | LOW
        status: pending
        content: "Article markdown content"

  # Step 2.5: Sort articles by criticality
  SORT articles: HIGH → MEDIUM → LOW
  UPDATE {scope}-refinement.yaml with sorted_articles

  # Step 2.6: Iteratively refine each article
  FOR EACH article IN sorted_articles:
    IF article.status == 'refined':
      SKIP to next article

    # Criticality-based handling
    IF article.criticality == HIGH:
      - Present article to user with context
      - Ask for decision: include/exclude/modify
      - Record decision in decisions array

    ELSE IF article.criticality == MEDIUM:
      - Analyze article + generate recommendation
      - Present recommendation to user
      - Ask for approval/modification
      - OFFER: "Apply this to all remaining MEDIUM articles? [y/N]"
      - Record decision

    ELSE IF article.criticality == LOW:
      - Generate auto-recommendation
      - Present for approval
      - OFFER: "Apply this to all remaining LOW articles? [y/N]"
      - Record decision

    # Checkpoint after EACH decision
    UPDATE {scope}-refinement.yaml:
      article.status = 'refined'
      article.decision = [user's choice]
    SAVE FILE

  # Step 2.7: Mark scope as completed
  UPDATE {scope}-refinement.yaml:
    status: completed
    completed_at: [timestamp]
  SAVE FILE

  NEXT scope
```

### Phase 3: Merge All Refinement YAMLs

**After all scopes are processed:**

```text
# Step 3.1: Collect all scope refinement files
scope_yamls = [
  .boltf/memory/refinement-states/backend-refinement.yaml,
  .boltf/memory/refinement-states/frontend-refinement.yaml,
  .boltf/memory/refinement-states/cloud-platform-refinement.yaml
]

# Step 3.2: Merge into unified structure
CREATE .boltf/memory/refinement-states/merged-refinement.yaml:
  scopes:
    - scope: backend
      articles: [from backend-refinement.yaml]
      decisions: [from backend-refinement.yaml]
    - scope: frontend
      articles: [from frontend-refinement.yaml]
      decisions: [from frontend-refinement.yaml]
    - scope: cloud-platform
      articles: [from cloud-platform-refinement.yaml]
      decisions: [from cloud-platform-refinement.yaml]

  # Summary stats
  total_scopes: 3
  total_articles: [sum of all articles]
  total_decisions: [sum of all decisions]
  merge_timestamp: [timestamp]

# Step 3.3: Detect conflicts (same article number across scopes)
FOR EACH article_number:
  IF article appears in multiple scopes:
    # Flag for manual review
    ADD to merged-refinement.yaml:
      conflicts:
        - article: "Article III"
          scopes: [backend, frontend]
          resolution: pending
```

### Phase 4: Generate Final Constitution

**Source:** `merged-refinement.yaml`
**Output:** `.boltf/memory/constitution.md`

```text
# Step 4.1: Start with constitution-init.md header
READ .boltf/memory/constitution-init.md
EXTRACT header (metadata, active scopes)

# Step 4.2: Include only approved articles
CREATE .boltf/memory/constitution.md:

  # Header from constitution-init.md
  [metadata block]

  # For each scope
  FOR EACH scope IN merged-refinement.yaml.scopes:

    WRITE "## Scope: {scope.name}"

    FOR EACH article IN scope.articles:
      IF article.decision == 'include' OR article.decision == 'modified':
        WRITE article.content
        IF article.decision == 'modified':
          WRITE article.modified_content

    WRITE "---"

  # Footer
  WRITE "Generated from merged refinement decisions on [timestamp]"

# Step 4.3: Generate provision report
CREATE .boltf/memory/provision-report.md:
  - Total scopes processed: X
  - Total articles reviewed: Y
  - Articles included: Z
  - Articles excluded: W
  - Conflicts detected: C
  - Completion timestamp: [timestamp]
```

## Resume Capability

**Detect interruption:**

```text
IF exists(.boltf/memory/refinement-states/{scope}-refinement.yaml):
  READ state
  IF state.status == 'in-progress':
    # Find last processed article
    last_article = FIND article WHERE status == 'refined' (last one)
    next_article_index = last_article.index + 1

    ASK USER: "Resume scope '{scope}' from Article {next_article.number}? [Y/n]"

    IF yes:
      CONTINUE from next_article_index
    ELSE:
      START from beginning
```

## Quality Gates

- [ ] All scope constitutions exist in `.boltf/memory/`
- [ ] Each scope has a corresponding refinement YAML
- [ ] All HIGH criticality articles have explicit decisions
- [ ] All conflicts are resolved
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

## Example: Processing Backend Scope

```yaml
# .boltf/memory/refinement-states/backend-refinement.yaml
scope: backend
status: completed
total_articles: 8
articles:
  - number: 'III'
    title: 'Tech Stack'
    criticality: HIGH
    status: refined
    content: |
      # Article III — Tech Stack
      - Language: C# (.NET 10)
      - Framework: ASP.NET Core Minimal APIs
      - Database: PostgreSQL
    decision: include
    decided_at: '2026-03-04 10:23:45'

  - number: 'V'
    title: 'Code Quality'
    criticality: MEDIUM
    status: refined
    content: |
      # Article V — Code Quality
      - Coverage: 80%
      - Mutation: 70%
    decision: modified
    modified_content: |
      # Article V — Code Quality
      - Coverage: 85%
      - Mutation: 75%
    decided_at: '2026-03-04 10:25:12'

decisions:
  - article: 'III'
    action: include
    reason: 'Approved default .NET stack'
  - article: 'V'
    action: modified
    reason: 'Increased thresholds per team standards'
```

## Next Steps

After constitution refinement:

1. ✅ **Reviewed**: All scope constitutions processed
2. ✅ **Merged**: Single `merged-refinement.yaml` created
3. ✅ **Generated**: Final `constitution.md` with approved articles
4. ➡️ **Provision**: Run `@Bolt Provisioner` to download skills/agents
5. ➡️ **Commit**: Save constitution to version control
