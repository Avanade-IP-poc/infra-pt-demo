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
  # CRITICAL: Decision values determine final constitution inclusion
  #   'include'  → Article WILL appear in final constitution (as-is)
  #   'modified' → Article WILL appear (with modifications)
  #   'exclude'  → Article WILL NOT appear in final constitution
  #   'skip'     → Article WILL NOT appear (deferred/not applicable)

  FOR EACH article IN sorted_articles:
    IF article.status == 'refined':
      SKIP to next article

    # Criticality-based handling
    IF article.criticality == HIGH:
      # High criticality: Explicit user decision required
      - Present article to user with full context
      - Explain implications for the project
      - Ask: "Include this article? [include/exclude/modify]"
      - IF user says 'modify':
          - Prompt for modifications
          - Store in article.modified_content
          - Set decision = 'modified'
      - ELSE IF user says 'include':
          - Set decision = 'include'
      - ELSE IF user says 'exclude':
          - Set decision = 'exclude'
      - Record decision with timestamp and reason

    ELSE IF article.criticality == MEDIUM:
      # Medium criticality: Agent recommends, user approves
      - Analyze article + generate recommendation
      - Present: "Recommendation: [include/modify/exclude] because [reason]"
      - Ask user: "Accept recommendation? [y/n/modify]"
      - IF user accepts:
          - Set decision = recommended value
      - ELSE IF user says 'modify':
          - Prompt for changes
          - Set decision = 'modified'
      - ELSE:
          - Ask for manual decision (include/exclude)
      - OFFER: "Apply this decision to all remaining MEDIUM articles? [y/N]"
          - IF yes: Set bulk_decision_medium = current_decision
      - Record decision

    ELSE IF article.criticality == LOW:
      # Low criticality: Auto-recommend, quick approval
      - Generate auto-recommendation (usually 'include' for low-impact)
      - Present: "Auto-recommendation: [include] - [brief reason]"
      - Ask: "Approve? [Y/n]"
      - IF user approves (or no response):
          - Set decision = 'include'
      - ELSE:
          - Ask for manual decision (include/exclude/modify)
      - OFFER: "Apply to all remaining LOW articles? [y/N]"
          - IF yes: Set bulk_decision_low = current_decision
      - Record decision

    # Checkpoint after EACH decision
    UPDATE {scope}-refinement.yaml:
      articles[current].status = 'refined'
      articles[current].decision = [user's choice: include|modified|exclude|skip]
      articles[current].decided_at = [timestamp]
      articles[current].reason = [brief reason]
      IF decision == 'modified':
        articles[current].modified_content = [user's modified version]
    SAVE FILE

    LOG INFO: "Article {article.number}: decision='{decision}' | Will appear in final: {decision IN ['include', 'modified']}"
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

**Goal:** Create a concise, focused constitution containing ONLY user-approved articles.

**Source:** `merged-refinement.yaml`
**Output:** `.boltf/memory/constitution.md`

**CRITICAL FILTERING RULES:**

1. ✅ **Include** articles with `decision='include'` (original content)
2. ✅ **Include** articles with `decision='modified'` (modified content only)
3. ❌ **Exclude** articles with `decision='exclude'`
4. ❌ **Exclude** articles with `decision='skip'`
5. ❌ **Exclude** articles with `decision=null` or no decision
6. 💡 **Length Goal**: Keep final constitution focused and maintainable (typically 200-500 lines)

**Why This Matters:**

- Prevents information overload
- Makes constitution easier to reference during development
- Focuses on project-specific decisions, not generic boilerplate
- Ensures constitution reflects actual team choices, not defaults

````text
# Step 4.1: Start with constitution-init.md header (metadata only, NO articles)
READ .boltf/memory/constitution-init.md
EXTRACT header ONLY:
  - Project name
  - Generated timestamp
  - Practice
  - Active Scopes list
  - Project Type
DO NOT EXTRACT: Any article content from constitution-init.md

# Step 4.2: Filter and include ONLY approved articles
# Decision types and actions:
#   'include'   → Include original article content
#   'modified'  → Include modified_content (NOT original)
#   'exclude'   → SKIP completely (do not write)
#   'pending'   → SKIP completely (do not write)
#   null/empty  → SKIP completely (do not write)

CREATE .boltf/memory/constitution.md:

  # Header from constitution-init.md (metadata ONLY)
  WRITE [metadata block]
  WRITE "---"
  WRITE ""
  WRITE "# Final Constitution"
  WRITE ""
  WRITE "This constitution contains only articles explicitly approved during refinement."
  WRITE ""

  # Track statistics
  included_count = 0
  excluded_count = 0

  # For each scope
  FOR EACH scope IN merged-refinement.yaml.scopes:

    # Filter articles before writing scope header
    approved_articles = FILTER scope.articles WHERE
      decision IN ['include', 'modified']

    # Only write scope section if it has approved articles
    IF approved_articles.length > 0:

      WRITE "# Scope: {scope.name}"
      WRITE ""

      FOR EACH article IN approved_articles:

        # Validate decision before writing
        IF article.decision == 'include':
          # Use original article content
          WRITE article.content
          WRITE ""
          included_count++

        ELSE IF article.decision == 'modified':
          # Use modified content ONLY (discard original)
          IF article.modified_content IS NOT EMPTY:
            WRITE article.modified_content
            WRITE ""
            included_count++
          ELSE:
            # Fallback if modified_content is missing
            LOG WARNING: "Article {article.number} marked 'modified' but no modified_content"
            WRITE article.content
            WRITE "<!-- ⚠️  Marked as modified but changes not found -->"
            WRITE ""
            included_count++

        ELSE:
          # Safety catch: should never reach here due to filter
          LOG WARNING: "Article {article.number} has unexpected decision: {article.decision}"
          excluded_count++

      WRITE "---"
      WRITE ""

    ELSE:
      # Scope has no approved articles - skip entirely
      LOG INFO: "Scope '{scope.name}' has no approved articles - skipping section"

  # Footer with statistics
  WRITE "---"
  WRITE ""
  WRITE "## Constitution Metadata"
  WRITE ""
  WRITE "- **Generated**: [timestamp]"
  WRITE "- **Source**: Merged refinement from {total_scopes} scopes"
  WRITE "- **Articles Included**: {included_count}"
  WRITE "- **Articles Excluded**: {excluded_count}"
  WRITE "- **Total Reviewed**: {included_count + excluded_count}"
  WRITE ""
  WRITE "*Only articles with decision='include' or decision='modified' are present in this constitution.*"

# Step 4.3: Validate constitution length
constitution_size = GET FILE SIZE of constitution.md
constitution_lines = COUNT LINES in constitution.md

IF constitution_lines < 10:
  LOG WARNING: "Constitution is suspiciously short ({constitution_lines} lines)"
  LOG WARNING: "Verify that articles were properly approved during refinement"

IF constitution_lines > 2000:
  LOG WARNING: "Constitution is very long ({constitution_lines} lines)"
  LOG WARNING: "Consider reviewing which articles are truly necessary"

LOG INFO: "Final constitution: {included_count} articles, {constitution_lines} lines"

# Step 4.4: Generate provision report
CREATE .boltf/memory/provision-report.md:
  ## Constitution Refinement Report

  **Generated**: [timestamp]

  ### Summary
  - **Total Scopes Processed**: {total_scopes}
  - **Total Articles Reviewed**: {included_count + excluded_count}
  - **Articles Included**: {included_count}
  - **Articles Excluded**: {excluded_count}
  - **Inclusion Rate**: {(included_count / total) * 100}%
  - **Conflicts Detected**: {conflict_count}

  ### Per-Scope Breakdown
  FOR EACH scope:
    - **{scope.name}**: {scope.included}/{scope.total} articles included

  ### Final Constitution
  - **File**: .boltf/memory/constitution.md
  - **Size**: {constitution_lines} lines
  - **Status**: ✅ Generated successfully

  ### Next Steps
  1. Review final constitution for completeness
  2. Resolve any flagged conflicts
  3. Run `@Bolt Provisioner` to download resources
  4. Commit constitution to version control

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
````

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
total_articles: 10
articles:
  # ✅ INCLUDED: decision='include'
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
    reason: 'Approved default .NET stack for backend'
    decided_at: '2026-03-04 10:23:45'

  # ✅ INCLUDED: decision='modified' (uses modified_content, NOT original)
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
      # Article V — Code Quality (Enhanced)
      - Unit Test Coverage: 85%
      - Integration Test Coverage: 75%
      - Mutation Score: 75%
      - Static Analysis: SonarQube with Quality Gate
    reason: 'Increased thresholds and added static analysis per team standards'
    decided_at: '2026-03-04 10:25:12'

  # ❌ EXCLUDED: decision='exclude'
  - number: 'VII'
    title: 'API Versioning Strategy'
    criticality: MEDIUM
    status: refined
    content: |
      # Article VII — API Versioning
      - Versioning: URL-based (e.g., /api/v1/)
      - Deprecation: 6-month notice period
    decision: exclude
    reason: 'Project uses single-version API, versioning not needed at this stage'
    decided_at: '2026-03-04 10:26:30'

  # ✅ INCLUDED: decision='include' (LOW criticality auto-approved)
  - number: 'IX'
    title: 'Logging Standards'
    criticality: LOW
    status: refined
    content: |
      # Article IX — Logging
      - Framework: Serilog
      - Levels: Debug, Info, Warning, Error, Fatal
      - Structured logging: JSON format
    decision: include
    reason: 'Auto-approved: standard logging configuration'
    decided_at: '2026-03-04 10:27:15'

  # ❌ EXCLUDED: decision='skip'
  - number: 'XII'
    title: 'Mobile App Guidelines'
    criticality: LOW
    status: refined
    content: |
      # Article XII — Mobile Development
      - Platform: React Native
      - Offline support: Required
    decision: skip
    reason: 'Not applicable: backend-only project, no mobile app'
    decided_at: '2026-03-04 10:28:00'

# Summary: 3 included, 2 excluded
# Final constitution will contain ONLY articles III, V (modified), and IX
```

### Resulting Final Constitution

```markdown
# Final Constitution

This constitution contains only articles explicitly approved during refinement.

# Scope: backend

# Article III — Tech Stack

- Language: C# (.NET 10)
- Framework: ASP.NET Core Minimal APIs
- Database: PostgreSQL

# Article V — Code Quality (Enhanced)

- Unit Test Coverage: 85%
- Integration Test Coverage: 75%
- Mutation Score: 75%
- Static Analysis: SonarQube with Quality Gate

# Article IX — Logging

- Framework: Serilog
- Levels: Debug, Info, Warning, Error, Fatal
- Structured logging: JSON format

---

## Constitution Metadata

- **Generated**: 2026-03-04 10:30:00
- **Source**: Merged refinement from 1 scopes
- **Articles Included**: 3
- **Articles Excluded**: 2
- **Total Reviewed**: 5

_Only articles with decision='include' or decision='modified' are present in this constitution._
```

**Note:** Articles VII and XII do not appear because their decisions were 'exclude' and 'skip' respectively.

## Next Steps

After constitution refinement:

1. ✅ **Reviewed**: All scope constitutions processed
2. ✅ **Merged**: Single `merged-refinement.yaml` created
3. ✅ **Generated**: Final `constitution.md` with approved articles
4. ➡️ **Provision**: Run `@Bolt Provisioner` to download skills/agents
5. ➡️ **Commit**: Save constitution to version control
