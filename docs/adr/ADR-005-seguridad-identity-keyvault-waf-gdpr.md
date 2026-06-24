# ADR-005: Seguridad e Identidad — Azure AD B2C + Key Vault + WAF + GDPR

> **Estado**: Accepted
> **Fecha**: 2026-06-19
> **Proyecto**: SICA Modernization
> **Scope**: backend, frontend, cloud-platform, integration

---

## Contexto

El sistema legacy tiene 29 violaciones críticas, siendo las principales:
- SQL injection por concatenación sin parametrizar
- Gestión de credenciales insegura (connection strings en `app.config` / `web.config`)
- Sin autenticación moderna (se asume basada en Forms Authentication o Windows Auth del WebForms)
- Sin cifrado de PII (datos de visitantes, empleados)
- Sin cumplimiento GDPR demostrable

El sistema de destino debe ser seguro desde el diseño.

## Decisión

Adoptamos una arquitectura de seguridad en capas:

1. **Identidad**: Azure AD B2C / Entra ID (OIDC, Authorization Code + PKCE)
2. **API Auth**: JWT Bearer tokens via Microsoft.Identity.Web
3. **Secretos**: Azure Key Vault (ZERO secretos en código o config files)
4. **Red**: Azure VNet + Private Endpoints + WAF v2 (Azure Application Gateway)
5. **Datos**: TDE (Azure SQL), TLS 1.2+, cifrado de PII
6. **Cumplimiento**: GDPR (datos de visitantes y empleados en scope)

## Opciones Consideradas

| Área | Opción elegida | Alternativas rechazadas | Motivo |
| ---- | -------------- | ----------------------- | ------ |
| Identity | Azure AD B2C | Auth0, Okta, Custom | Ecosistema Azure nativo, sin coste adicional hasta 50k MAU |
| API Auth | JWT Bearer (Microsoft.Identity.Web) | API Keys, Basic Auth | Estándar de la industria, integrado con Azure AD B2C |
| Secrets | Azure Key Vault | Env vars en App Service, Azure App Config (solo) | Key Vault es el estándar para secretos críticos en Azure |
| Network | VNet + Private Endpoints | Public endpoints | Private Endpoints eliminan el vector de ataque de internet para DB y cache |
| WAF | Azure Application Gateway WAF v2 | Azure Front Door WAF | Application Gateway es suficiente para una única región |
| Cifrado | TDE Azure-managed | Customer-managed keys | CMK añade complejidad operacional sin beneficio proporcional para este proyecto |
| Compliance | GDPR | HIPAA, SOC2, PCI-DSS | Solo datos de visitantes y empleados en scope; no datos financieros ni sanitarios |

## Reglas Obligatorias

1. **ZERO SQL injection**: Toda query vía EF Core LINQ o `SqlParameter` parametrizado.
   Verificado en PR con Roslyn Analyzer `EF0001` / SonarQube `cs:S2077`.
2. **ZERO secretos en código**: Connection strings, API keys y certificados
   exclusivamente en Azure Key Vault.
3. **ZERO HTTP**: TLS 1.2+ en todos los endpoints (forzado en App Service + WAF).
4. **PII cifrada**: Datos de visitantes y empleados cifrados en reposo (SQL TDE).
5. **GDPR Log**: Audit log de acceso a datos de PII (Azure SQL Audit → Log Analytics).

## Consecuencias

**Positivas**:
- Azure AD B2C elimina la gestión de credenciales de usuario de la aplicación
- Key Vault elimina el principal vector de fuga de credenciales del legacy (`app.config`)
- Private Endpoints reducen la superficie de ataque a zero para DB, Redis y Service Bus
- WAF v2 protege contra OWASP Top 10 en el perímetro
- Los architecture tests verifican automáticamente que no hay SQL concatenado en CI

**Negativas / Riesgos**:
- Azure AD B2C tiene límite de 50k MAU gratis; por encima es coste adicional
- Private Endpoints requieren configuración de DNS privado (Azure Private DNS Zones)
- La migración de credenciales del legacy (`app.config`) requiere un paso de hardening

## Compliance

- ✅ Constitution Art. VII: Azure AD B2C, JWT Bearer, Policy-Based Auth
- ✅ Constitution Art. XVI §16.1: VNet, Private Endpoints, WAF
- ✅ Constitution Art. XVI §16.2: TDE, TLS 1.2+, PII encryption
- ✅ Constitution Art. XVI §16.3: GDPR ✅
- ✅ Constitution Art. V: Zero SQL injection, Key Vault para connection strings
