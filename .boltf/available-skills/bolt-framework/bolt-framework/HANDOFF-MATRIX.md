# Bolt Framework — Handoff Matrix

> Defines valid and invalid handoff paths between AURORA agents.
> Use this matrix to validate handoffs in agent frontmatter.

---

## Rules

1. **Bolt Framework** (orchestrator) can hand off to ANY agent ✅
2. **No self-handoffs** — an agent must NEVER hand off to itself ❌
3. **No circular chains** — A → B → C → A is invalid ❌
4. **No duplicate handoffs** — don't have multiple handoffs to the same agent with similar prompts ❌
5. **Respect lifecycle order** — don't skip phases without justification
6. **Each handoff needs context** — include prompt with what to do

---

## Orchestrator

### FROM: Bolt Framework → TO: Any

| Target Agent          | Valid | Reason                            |
| --------------------- | ----- | --------------------------------- |
| Any specialized agent | ✅    | Orchestrator role — routes to all |

---

## INCEPTION Phase

### FROM: Aurora Constitution

| Target Agent     | Valid | Reason                                     |
| ---------------- | ----- | ------------------------------------------ |
| Aurora Clarify   | ✅    | Resolve ambiguities before ratifying       |
| Aurora Feature   | ✅    | Start defining features after constitution |
| Aurora Templates | ✅    | Generate project templates                 |

### FROM: Aurora Clarify

| Target Agent        | Valid | Reason                                |
| ------------------- | ----- | ------------------------------------- |
| Aurora Constitution | ✅    | Apply clarifications to constitution  |
| Aurora Feature      | ✅    | Clarified requirements → feature spec |
| Aurora Specify      | ✅    | Clarified → detailed spec             |

---

## DISCOVERY Phase

### FROM: Aurora Feature

| Target Agent     | Valid | Reason                                  |
| ---------------- | ----- | --------------------------------------- |
| Aurora Use Case  | ✅    | Detail use cases from stories           |
| Aurora Gherkin   | ✅    | BDD scenarios from acceptance criteria  |
| Aurora DDD       | ✅    | Domain model from feature context       |
| Aurora Plan      | ✅    | Implementation plan from spec           |
| Aurora Specify   | ✅    | Detailed specification                  |
| Aurora Implement | ✅    | Direct implementation (simple features) |
| Aurora Status    | ❌    | Not related to feature creation         |
| Aurora Ops       | ❌    | Too early in lifecycle                  |

### FROM: Aurora Plan

| Target Agent     | Valid | Reason                             |
| ---------------- | ----- | ---------------------------------- |
| Aurora Tasks     | ✅    | Breakdown plan into Bolt tasks     |
| Aurora Analyze   | ✅    | Verify plan consistency with specs |
| Aurora Architect | ✅    | Validate architecture decisions    |
| Aurora Implement | ❌    | Must go through Tasks first        |
| Aurora Release   | ❌    | Too early in lifecycle             |

### FROM: Aurora Tasks

| Target Agent          | Valid | Reason                         |
| --------------------- | ----- | ------------------------------ |
| Aurora Implement      | ✅    | Start implementing tasks       |
| Aurora Micro Iterator | ✅    | Start Bolt iteration           |
| Aurora Plan           | ❌    | Tasks come FROM plan, not back |

### FROM: Aurora Specify

| Target Agent   | Valid | Reason                   |
| -------------- | ----- | ------------------------ |
| Aurora Feature | ✅    | Refine feature from spec |
| Aurora Gherkin | ✅    | BDD from spec            |
| Aurora Plan    | ✅    | Plan from spec           |

### FROM: Aurora Use Case

| Target Agent   | Valid | Reason              |
| -------------- | ----- | ------------------- |
| Aurora Gherkin | ✅    | BDD from use cases  |
| Aurora Plan    | ✅    | Plan from use cases |
| Aurora Feature | ✅    | Refine feature      |

### FROM: Aurora Gherkin

| Target Agent   | Valid | Reason                          |
| -------------- | ----- | ------------------------------- |
| Aurora Testing | ✅    | Step definitions from scenarios |
| Aurora Feature | ✅    | Refine feature from scenarios   |
| Aurora Plan    | ✅    | Plan informed by BDD            |

### FROM: Aurora DDD

| Target Agent     | Valid | Reason                         |
| ---------------- | ----- | ------------------------------ |
| Aurora Architect | ✅    | Architecture from domain model |
| Aurora Feature   | ✅    | Refine features from domain    |
| Aurora Plan      | ✅    | Plan from domain model         |

---

## CONSTRUCTION Phase

### FROM: Aurora Implement

| Target Agent   | Valid | Reason                                  |
| -------------- | ----- | --------------------------------------- |
| Aurora Testing | ✅    | Generate tests for implementation       |
| Aurora Analyze | ✅    | Verify consistency with spec            |
| Aurora Review  | ✅    | Code review                             |
| Aurora Feature | ❌    | Circular — impl doesn't create features |
| Aurora Plan    | ❌    | Already has plan                        |
| Aurora Release | ❌    | Must pass review first                  |

### FROM: Aurora Testing

| Target Agent     | Valid | Reason                            |
| ---------------- | ----- | --------------------------------- |
| Aurora Implement | ✅    | TDD green phase — make tests pass |
| Aurora Gherkin   | ✅    | Generate BDD scenarios            |
| Aurora Review    | ✅    | Review test quality               |
| Aurora Analyze   | ✅    | Coverage analysis                 |
| Aurora Feature   | ❌    | Tests come from feature, not back |

### FROM: Aurora Review

| Target Agent     | Valid | Reason                           |
| ---------------- | ----- | -------------------------------- |
| Aurora Implement | ✅    | Fix issues found in review       |
| Aurora Testing   | ✅    | Improve coverage                 |
| Bolt ADR         | ✅    | Document architectural decision  |
| Aurora Analyze   | ✅    | Deep analysis of findings        |
| Aurora Feature   | ❌    | Review doesn't create features   |
| Aurora Release   | ❌    | Should go through Bolt Framework |

### FROM: Aurora Micro Iterator

| Target Agent     | Valid | Reason                         |
| ---------------- | ----- | ------------------------------ |
| Aurora Tasks     | ✅    | Get task list for current Bolt |
| Aurora Implement | ✅    | Execute implementation         |
| Aurora Testing   | ✅    | Run tests for Bolt             |
| Aurora Review    | ✅    | Review Bolt completion         |

### FROM: Aurora Analyze

| Target Agent     | Valid | Reason                |
| ---------------- | ----- | --------------------- |
| Aurora Implement | ✅    | Fix inconsistencies   |
| Aurora Feature   | ✅    | Update spec if needed |
| Aurora Review    | ✅    | Quality findings      |

### FROM: Bolt ADR

| Target Agent     | Valid | Reason                    |
| ---------------- | ----- | ------------------------- |
| Aurora Architect | ✅    | Architecture implications |
| Aurora Implement | ✅    | Apply decision            |

### FROM: Aurora Architect

| Target Agent     | Valid | Reason                         |
| ---------------- | ----- | ------------------------------ |
| Bolt ADR         | ✅    | Document architecture decision |
| Aurora Plan      | ✅    | Inform plan with architecture  |
| Aurora DDD       | ✅    | Domain modeling                |
| Aurora Implement | ✅    | Guide implementation           |

---

## TRANSITION Phase

### FROM: Aurora Release

| Target Agent  | Valid | Reason                 |
| ------------- | ----- | ---------------------- |
| Aurora CI/CD  | ✅    | Pipeline configuration |
| Aurora Ops    | ✅    | Deployment operations  |
| Aurora Status | ✅    | Release status update  |

### FROM: Aurora CI/CD

| Target Agent   | Valid | Reason                    |
| -------------- | ----- | ------------------------- |
| Aurora Release | ✅    | Release process           |
| Aurora Ops     | ✅    | Deployment                |
| Aurora Testing | ✅    | Pipeline test integration |

---

## PRODUCTION Phase

### FROM: Aurora Ops

| Target Agent      | Valid | Reason                              |
| ----------------- | ----- | ----------------------------------- |
| Aurora Improve    | ✅    | Identify improvements from ops data |
| Aurora Postmortem | ✅    | Incident analysis                   |
| Aurora Status     | ✅    | Operational status                  |
| Aurora Release    | ✅    | New deployment needed               |
| Aurora Monitoring | ✅    | Configure monitoring                |
| Aurora Feature    | ❌    | Ops doesn't create features         |

### FROM: Aurora Status

| Target Agent     | Valid | Reason                    |
| ---------------- | ----- | ------------------------- |
| Aurora Analyze   | ✅    | Deep analysis             |
| Aurora Improve   | ✅    | Improvement opportunities |
| Aurora Alignment | ✅    | Check alignment           |
| Aurora Ops       | ✅    | Operational health        |
| Aurora Implement | ❌    | Status is read-only       |

### FROM: Aurora Improve

| Target Agent     | Valid | Reason                     |
| ---------------- | ----- | -------------------------- |
| Aurora Feature   | ✅    | Improvement → new feature  |
| Aurora Implement | ✅    | Apply improvement          |
| Aurora Analyze   | ✅    | Analyze improvement impact |

### FROM: Aurora Alignment

| Target Agent   | Valid | Reason                     |
| -------------- | ----- | -------------------------- |
| Aurora Improve | ✅    | Misalignment → improvement |
| Aurora Status  | ✅    | Alignment status           |
| Aurora Analyze | ✅    | Deep alignment analysis    |

### FROM: Aurora Monitoring

| Target Agent   | Valid | Reason                |
| -------------- | ----- | --------------------- |
| Aurora Ops     | ✅    | Alert → operations    |
| Aurora Improve | ✅    | Metrics → improvement |

---

## RETIREMENT Phase

### FROM: Aurora Retire

| Target Agent      | Valid | Reason                     |
| ----------------- | ----- | -------------------------- |
| Aurora Ops        | ✅    | Decommissioning operations |
| Aurora Status     | ✅    | Retirement status          |
| Aurora Postmortem | ✅    | Lessons learned            |

### FROM: Aurora Postmortem

| Target Agent   | Valid | Reason                 |
| -------------- | ----- | ---------------------- |
| Aurora Improve | ✅    | Lessons → improvements |
| Bolt ADR       | ✅    | Document decisions     |

---

## Cross-Phase Agents

### FROM: Aurora Security

| Target Agent        | Valid | Reason                     |
| ------------------- | ----- | -------------------------- |
| Aurora Constitution | ✅    | Update security standards  |
| Aurora Implement    | ✅    | Fix vulnerabilities        |
| Aurora Testing      | ✅    | Security test suites       |
| Aurora Review       | ✅    | Security review findings   |
| Aurora Security     | ❌    | **SELF-HANDOFF — INVALID** |

### FROM: Aurora Dependencies

| Target Agent        | Valid | Reason                      |
| ------------------- | ----- | --------------------------- |
| Aurora Implement    | ✅    | Install dependencies        |
| Aurora Security     | ✅    | Check dependency security   |
| Aurora Constitution | ✅    | Update allowed dependencies |

### FROM: Aurora Docs

| Target Agent   | Valid | Reason                     |
| -------------- | ----- | -------------------------- |
| Bolt ADR       | ✅    | Architecture documentation |
| Aurora Feature | ✅    | Feature documentation      |

### FROM: Aurora Templates

| Target Agent        | Valid | Reason                    |
| ------------------- | ----- | ------------------------- |
| Aurora Constitution | ✅    | Template for constitution |
| Aurora Feature      | ✅    | Template for features     |
| Aurora Implement    | ✅    | Code templates            |

---

## Anti-Patterns ❌

| Anti-Pattern          | Example                                 | Why Invalid                                |
| --------------------- | --------------------------------------- | ------------------------------------------ |
| **Self-handoff**      | Security → Security                     | Infinite loop, no progress                 |
| **Circular chain**    | Plan → Tasks → Implement → Plan         | Never terminates                           |
| **Phase skip**        | Discovery → Production                  | Skips Construction entirely                |
| **Duplicate handoff** | Two handoffs to same agent, same prompt | Confusing, redundant                       |
| **Reverse flow**      | Testing → Feature                       | Tests validate features, don't create them |
| **Premature release** | Implement → Release                     | Must pass review and quality gates first   |
