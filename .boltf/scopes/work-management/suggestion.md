# Suggestion: work-management

## Evidencia encontrada en el proyecto

- Metodología AURORA-IA define Features, Use Cases, Bolts y Tasks como artefactos de planificación gestionables.
- Agentes existentes (`@Aurora Plan`, `@Aurora Tasks`, `@Aurora Feature`, `@Aurora Status`) generan artefactos de trabajo que necesitan sincronización con herramientas externas.
- Skills disponibles de sincronización con Azure DevOps en `.boltf/available-skills/azure-devops-sync`.
- Estructura `specs/XXX-feature-name/planning/` contiene task lists y dependencias que pueden proyectarse a work items.

## Sugerencia de contenido para este scope

- Mapeo de artefactos AURORA (Feature → Epic, Use Case → User Story, Bolt → Task, Dependency → Link) a sistemas de gestión.
- Sincronización bidireccional de estado entre specs y Azure DevOps Boards / GitHub Projects / Jira.
- Automatización de creación de work items desde feature specs y task lists.
- Trazabilidad end-to-end: Spec → Work Item → Branch → PR → Deployment.
- Dashboards y queries predefinidos para seguimiento de progreso por fase AURORA.
- Gobernanza de campos personalizados y taxonomía de work items alineada con AURORA.

## Fuentes

- `.boltf/memory/constitution.md` — Article XI (CI/CD), Article XIX (Governance)
- `.github/agents/aurora-plan.agent.md`
- `.github/agents/aurora-tasks.agent.md`
- `.github/agents/aurora-feature.agent.md`
- `.github/agents/aurora-status.agent.md`
- `.boltf/available-skills/azure-devops-sync/SKILL.md`
