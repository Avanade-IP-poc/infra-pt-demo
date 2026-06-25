# ADR-003: Infraestructura Azure — App Service + Bicep + GitHub Actions + Blue-Green

> **Estado**: Accepted
> **Fecha**: 2026-06-19
> **Proyecto**: SICA Modernization
> **Scope**: cloud-platform

---

## Contexto

El sistema legacy SICA se asume on-premises o en un hosting sin CI/CD. La arquitectura
destino especifica Azure como cloud provider. Se necesita definir:
- Plataforma de cómputo (PaaS vs Containers)
- IaC tooling
- CI/CD platform
- Deployment strategy

## Decisión

### Plataforma de Cómputo

- **Azure App Service (Standard S2)** para Web API .NET 8 y WebForms legacy rehost
- **Azure Functions Consumption Plan** para procesamiento asíncrono
- **Sin contenedores en Fase 1-3** — PaaS puro para reducir complejidad operacional

### IaC

- **Bicep** (nativo Azure) para todos los recursos de Azure
- Módulos por recurso, parámetros por entorno (`dev.bicepparam`, `uat.bicepparam`…)

### CI/CD

- **GitHub Actions** (OIDC federation, sin client secrets en GitHub)
- Estrategia: **Blue-Green** mediante Azure Deployment Slots

### Observabilidad

- **OpenTelemetry → Azure Monitor / Application Insights**

## Opciones Consideradas

| Opción | Pros | Contras | Decisión |
| ------ | ---- | ------- | -------- |
| Azure App Service (PaaS) | Sin gestión de infra, Deployment Slots nativos, fácil rehost | Menos flexible para microservicios | ✅ Fase 1-3 |
| Azure Container Apps | Serverless containers, KEDA, Dapr | Complejidad operacional, no necesario para Fase 1-3 | ❌ (Fase 4+) |
| AKS | Máximo control | Overkill, alto costo operacional para Fase 1-3 | ❌ |
| Bicep | Nativo Azure, primera clase en tooling, sin Terraform provider lag | Solo Azure | ✅ |
| Terraform | Multi-cloud, ecosistema maduro | Provider lag, innecesario (single Azure) | ❌ |
| GitHub Actions | Nativo GitHub, OIDC, mercado laboral | — | ✅ |
| Azure DevOps Pipelines | Integración Azure, YAML pipelines | Mayor complejidad, requiere ADO org | ❌ |
| Blue-Green (Slots) | Zero-downtime, rollback instantáneo, nativo App Service | Coste del slot | ✅ |
| Canary | Tráfico granular | Complejidad no justificada para Fase 1-3 | ❌ |

## Consecuencias

**Positivas**:
- Azure App Service simplifica el rehost del WebForms (Fase 1) sin cambios de código
- Bicep + Azure Policy garantiza compliance GDPR desde el día 1
- GitHub Actions OIDC elimina la rotación manual de secrets
- Blue-Green con Deployment Slots permite rollback en < 1 minuto
- Infracost en PR da visibilidad de costes antes de cada merge

**Negativas / Riesgos**:
- App Service Standard S2 tiene coste fijo (vs serverless)
- Migración a contenedores en Fase 4 requirirá nuevo ADR
- Bicep no es portable a otros clouds (aceptado por decisión single-Azure)

## Compliance

- ✅ Constitution Art. VIII §8.1-8.2: None/PaaS, Azure App Service
- ✅ Constitution Art. VIII-B §8B.1: Workload Infrastructure
- ✅ Constitution Art. IX: Bicep, `bicep lint`, `az what-if`, Checkov, Infracost
- ✅ Constitution Art. XI: GitHub Actions, GitFlow, Blue-Green
- ✅ Constitution Art. XII: OpenTelemetry → Azure Monitor, SLOs
