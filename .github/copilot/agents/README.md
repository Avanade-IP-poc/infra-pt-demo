# AURORA-IA / AI-DLC Agent Directory

This directory contains documentation for all AI agents used in the AURORA-IA methodology combined with AI-DLC (AI-Driven
Development Lifecycle).

> **Note**: These agents are **internal references** for prompts. They are not visible in the GitHub Copilot agent dropdown.

## Agent Catalog

| Agent Name                   | Role                       | Phase        | File                                                               |
| ---------------------------- | -------------------------- | ------------ | ------------------------------------------------------------------ |
| Aurora Business Explorer     | Product/PO Agent           | Inception    | [aurora-business-explorer.md](aurora-business-explorer.md)         |
| Aurora Cosmic Planner        | Planning Agent             | Inception    | [aurora-cosmic-planner.md](aurora-cosmic-planner.md)               |
| Aurora Domain Sage           | Domain Expert Agent        | Discovery    | [aurora-domain-sage.md](aurora-domain-sage.md)                     |
| Aurora Technical Detective   | Technical Discovery Agent  | Discovery    | [aurora-technical-detective.md](aurora-technical-detective.md)     |
| Aurora Legacy Archaeologist  | Legacy Modeling Agent      | Discovery    | [aurora-legacy-archaeologist.md](aurora-legacy-archaeologist.md)   |
| Aurora DDD Master            | DDD Agent                  | Design       | [aurora-ddd-master.md](aurora-ddd-master.md)                       |
| Aurora Omega Architect       | Architect Agent            | Design       | [aurora-omega-architect.md](aurora-omega-architect.md)             |
| Aurora Micro-Iterator        | Iteration Agent            | Construction | [aurora-micro-iterator.md](aurora-micro-iterator.md)               |
| Aurora Policy Guardian       | Policy Agent               | All Phases   | [aurora-policy-guardian.md](aurora-policy-guardian.md)             |
| Aurora Coding Agent          | Coding Agent               | Construction | [aurora-coding-agent.md](aurora-coding-agent.md)                   |
| Aurora Test Inspector        | Testing Agent              | Construction | [aurora-test-inspector.md](aurora-test-inspector.md)               |
| Aurora Infra Builder         | IaC Agent                  | Operations   | [aurora-infra-builder.md](aurora-infra-builder.md)                 |
| Aurora Release Orchestrator  | Release Agent              | Operations   | [aurora-release-orchestrator.md](aurora-release-orchestrator.md)   |
| Aurora Proactive Operator    | Ops Agent                  | Operations   | [aurora-proactive-operator.md](aurora-proactive-operator.md)       |
| Aurora Surgical Refactorer   | Refactor Agent             | Evolution    | [aurora-surgical-refactorer.md](aurora-surgical-refactorer.md)     |
| Aurora Continuous Evolver    | Continuous Evolution Agent | Evolution    | [aurora-continuous-evolver.md](aurora-continuous-evolver.md)       |
| Aurora Final Archiver        | Decommission Agent         | End-of-Life  | [aurora-final-archiver.md](aurora-final-archiver.md)               |
| Aurora Ops-Bugfix Autonomous | Autonomous Ops Agent       | Operations   | [aurora-ops-bugfix-autonomous.md](aurora-ops-bugfix-autonomous.md) |

## AI-DLC Lifecycle Phases

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AURORA-IA / AI-DLC LIFECYCLE                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  BLOCK 1: INCEPTION          BLOCK 2: DISCOVERY        BLOCK 3: DESIGN     │
│  ┌─────────────────┐        ┌─────────────────┐       ┌─────────────────┐  │
│  │ Business        │        │ Domain Sage     │       │ DDD Master      │  │
│  │ Explorer        │───────▶│                 │──────▶│                 │  │
│  │                 │        │ Technical       │       │ Omega           │  │
│  │ Cosmic          │        │ Detective       │       │ Architect       │  │
│  │ Planner         │        │                 │       └─────────────────┘  │
│  └─────────────────┘        │ Legacy          │              │             │
│                             │ Archaeologist   │              │             │
│                             └─────────────────┘              ▼             │
│                                                       BLOCK 4: CONSTRUCT   │
│  BLOCK 7: EVOLUTION         BLOCK 6: OPS             ┌─────────────────┐  │
│  ┌─────────────────┐       ┌─────────────────┐       │ Micro-Iterator  │  │
│  │ Surgical        │◀──────│ Proactive       │◀──────│                 │  │
│  │ Refactorer      │       │ Operator        │       │ Coding Agent    │  │
│  │                 │       │                 │       │                 │  │
│  │ Continuous      │       │ Ops-Bugfix      │       │ Test Inspector  │  │
│  │ Evolver         │       │ Autonomous      │       └─────────────────┘  │
│  │                 │       └─────────────────┘              │             │
│  │ Final           │              ▲                         │             │
│  │ Archiver        │              │                         ▼             │
│  └─────────────────┘       BLOCK 5: RELEASE          ┌─────────────────┐  │
│                            ┌─────────────────┐       │ Infra Builder   │  │
│                            │ Release         │◀──────│                 │  │
│                            │ Orchestrator    │       └─────────────────┘  │
│                            └─────────────────┘                             │
│                                                                             │
│  ═══════════════════════════════════════════════════════════════════════   │
│  │ CROSS-CUTTING: Policy Guardian monitors all phases                 │    │
│  ═══════════════════════════════════════════════════════════════════════   │
└─────────────────────────────────────────────────────────────────────────────┘
```

## How to Use Agents

Each agent can be invoked via:

1. **GitHub Copilot Chat** - Use the prompts in `.github/prompts/`
2. **init.sh Script** - Automated orchestration
3. **Manual Prompting** - Copy prompts from agent docs

## Agent Communication Flow

Agents communicate through artifacts in the specs structure:

```text
specs/XXX-feature-name/
├── requirements/         # requirements.md, use-cases/, data-model.md
├── contracts/            # openapi.yaml, events.yaml
├── tests/                # feature.feature (Gherkin)
└── planning/             # plan.md, tasks.md, research.md
```

All outputs are version-controlled for traceability.
