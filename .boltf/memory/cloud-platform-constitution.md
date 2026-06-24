# BOLT Framework — Scope Constitution: Cloud Platform

> **Proyecto**: SICA Modernization — Infraestructura Azure
> **Scope**: `cloud-platform`
> **Estado**: Ratificado — 2026-06-19
> **Destino**: `demo/destino.md` (Azure App Service, Azure Functions, Azure SQL, API Gateway, Bicep)

---

## Article VIII §8.1-8.2: Containers & Orchestration

### §8.1: Container Strategy

- [x] **None** — PaaS only en Fase 1 y 2. Docker opcional en Fase 4 si se extraen servicios.

### §8.2: Orchestration Platform

- [x] **Azure App Service** — PaaS (Code, no containers inicialmente)
  - Plan: Standard S2 para Web API y WebForms legacy
  - Azure Functions: Consumption Plan

### §8.4: Cloud-Native Extensions

- KEDA: [ ] No — no necesario sin contenedores.
- Dapr: [ ] No — Strangler Fig no requiere Dapr en fases iniciales.

---

## Article VIII-B: Infrastructure Scope

### §8B.1: Infrastructure Scope 🔴 CRITICAL

- [x] **Workload Infrastructure** — Recursos específicos de la aplicación sobre plataforma existente.

No se provisiona Landing Zone — se asume suscripción Azure existente.

### §8B.3: Workload Infrastructure Components

**Compute**:
- [x] App Services (Web API + WebForms legacy rehost)
- [x] Serverless (Azure Functions — procesamiento async, DataSync)
- [ ] AKS — No en fases 1-3

**Data**:
- [x] Azure SQL Database (S3 estándar, escalado automático)
- [x] Azure Cache for Redis
- [x] Storage Accounts (blobs para fotos `Foto.aspx`, logs)

**Integration**:
- [x] Azure Service Bus (Standard tier — colas + topics)
- [x] Azure API Management (Developer/Standard tier)
- [x] Application Gateway (WAF v2)

**Security & Identity**:
- [x] Azure Key Vault (secretos, certificados)
- [x] Azure AD B2C (tenant dedicado)
- [x] Azure VNet + Private Endpoints (SQL, Redis, Service Bus)

**Observability**:
- [x] Application Insights (conectado a la API + Azure Functions)
- [x] Log Analytics Workspace
- [x] Azure Monitor Alerts

---

## Article IX: Infrastructure as Code (IaC)

- [x] **Bicep** — IaC nativo Azure (preferido sobre Terraform).
- Módulos: uno por recurso, parámetros por entorno (dev/uat/pre/prod).
- Validación: `az bicep build` + `az deployment what-if` en CI.
- Lint: `bicep lint` (cero warnings).
- Cost estimation: Infracost en PR.
- Compliance: Azure Policy (GDPR baseline).

Estructura IaC:
```
infra/
├── modules/
│   ├── app-service.bicep
│   ├── sql-database.bicep
│   ├── functions.bicep
│   ├── api-management.bicep
│   ├── service-bus.bicep
│   ├── key-vault.bicep
│   └── networking.bicep
├── environments/
│   ├── dev.bicepparam
│   ├── uat.bicepparam
│   ├── pre.bicepparam
│   └── prod.bicepparam
└── main.bicep
```

---

## Article XII §12.3: Infrastructure Monitoring

| Componente      | Herramienta              | Habilitado |
| --------------- | ------------------------ | ---------- |
| Resource Health | Azure Resource Health    | [x] Yes    |
| Activity Logs   | Azure Monitor            | [x] Yes    |
| Diagnostics     | Log Analytics Workspace  | [x] Yes    |
| Alerts          | Azure Monitor Alerts     | [x] Yes    |
| Dashboards      | Azure Workbooks          | [x] Yes    |

SLOs definidos:
- API p95 latency < 500ms
- Availability > 99.5%
- Error rate < 0.1%

---

## Article XIII §13.4: Infrastructure Testing

| Tipo          | Herramienta            | Cuándo          |
| ------------- | ---------------------- | --------------- |
| Bicep lint    | `bicep lint`           | En cada commit  |
| What-if       | `az deployment what-if`| En PR a develop |
| Security scan | Checkov                | En CI           |
| Cost estimate | Infracost              | En PR           |
| Smoke tests   | Azure CLI / Pester     | Post-deploy     |

---

## Skills Provisionados (Cloud Platform)

- `skill-senior-devops` — Bicep, GitHub Actions, Azure DevOps patterns, IaC best practices
- `github-actions-templates` — Pipelines CI/CD reutilizables para .NET y Bicep
