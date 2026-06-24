# BOLT Framework — Scope Constitution: Data

> **Proyecto**: SICA Modernization — Data Layer Migration
> **Scope**: `data`
> **Estado**: Ratificado — 2026-06-19
> **Nota**: Este proyecto usa el scope `data` para la migración del Data Access Layer
> transaccional (`SQLMethods.vb`), NO para analytics/Lakehouse (que correspondería a
> plataformas como Fabric o Databricks, fuera del alcance).

---

## Contexto Data (Transaccional)

El sistema legacy tiene múltiples copias de `SQLMethods.vb` con SQL concatenado
sin parametrizar — la principal fuente de vulnerabilidades críticas (SQL injection).

La estrategia de datos se gobierna principalmente en el scope `backend`
(EF Core, Azure SQL). Este fichero documenta las decisiones de migración
específicas del data layer.

---

## Decisiones de Migración del Data Layer

### Motor de base de datos

- [x] **Azure SQL Database** — Migración del SQL Server on-premises/legacy.
  - Tier: General Purpose (GP_S_Gen5_2 serverless para dev, Standard S3 para prod)
  - Compatibilidad: SQL Server 2022
  - Backup: Geo-redundante, retención 35 días
  - Auditoría: [x] Azure SQL Audit → Log Analytics

### Estrategia de migración de esquema

- [x] **EF Core Migrations sobre esquema existente** (Database-First inicial →
  Code-First evolutivo)
- Herramienta: `dotnet ef dbcontext scaffold` para el esquema legacy →
  limpieza y re-modelado DDD.
- Sin cambios de esquema destructivos hasta que el legacy esté en read-only.

### Reemplazos críticos

| Componente Legacy          | Reemplazo                             |
| -------------------------- | ------------------------------------- |
| `SQLMethods.vb` (múltiples)| Repositorios EF Core por Bounded Context |
| SQL concatenado sin params | EF Core LINQ / `SqlParameter` params  |
| `DataSync.vb` sync directo | Azure Functions + Service Bus         |
| `wsSMIServer` ASMX queries | REST endpoints Web API                |

### Calidad de datos

- Zero-tolerance: ninguna query sin parametrizar en código nuevo.
- Revisión en PR: Roslyn Analyzer `EF0001` / SonarQube `cs:S2077`.
- Tests de paridad de datos: fixtures de integración con datos reales (anonimizados).

### Seguridad de datos

- PII: [x] Cifrado en reposo (Azure SQL TDE, Azure-managed keys)
- Conexiones: Private Endpoint dentro de la VNet
- Secretos: connection string exclusivamente en Azure Key Vault
- GDPR: [x] Sí — datos de visitantes y empleados en scope

---

## Skills Provisionados (Data)

- `integration-e2e-testing` — Testcontainers SQL Server real para pruebas de repositorio
