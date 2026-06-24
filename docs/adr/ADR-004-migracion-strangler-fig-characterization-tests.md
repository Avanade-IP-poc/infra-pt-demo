# ADR-004: Estrategia de Migración Legacy — Strangler Fig + Characterization Tests + ACL

> **Estado**: Accepted
> **Fecha**: 2026-06-19
> **Proyecto**: SICA Modernization
> **Scope**: backend, frontend, integration

---

## Contexto

El sistema legacy tiene:
- 29 violaciones críticas de código (SQL injection como principal)
- Alta duplicación de `SQLMethods.vb` (múltiples copias)
- Lógica de negocio mezclada con presentación en code-behind
- Sin tests, sin separación de responsabilidades

Una reescritura total ("Big Bang") implica alto riesgo de pérdida de comportamiento
no documentado. Se necesita una estrategia de migración incremental.

## Decisión

Adoptamos el patrón **Strangler Fig** con 4 fases, con **tests de caracterización
(golden-master) obligatorios** antes de reescribir cualquier módulo, y una
**Anti-Corruption Layer (ACL)** entre el dominio nuevo y el esquema legacy.

### Fases

| Fase   | Descripción                                           | Resultado                      |
| ------ | ----------------------------------------------------- | ------------------------------ |
| Fase 1 | Rehost WebForms en Azure App Service                  | Legacy operativo en Azure      |
| Fase 2 | Extracción de APIs y lógica de negocio (.NET 8)       | Web API + dominio modelado     |
| Fase 3 | Migración de UI a React SPA                           | Frontend moderno en producción |
| Fase 4 | Sustitución de integraciones y decomisión del monolito| Sin deuda técnica              |

### Reglas de migración

1. **Characterization tests PRIMERO**: Antes de tocar cualquier módulo del legacy,
   capturar su comportamiento real como tests golden-master.
2. **ACL obligatoria**: El dominio nuevo nunca accede directamente al esquema legacy.
   Toda interacción pasa por un Adapter o ACL.
3. **Outbox Pattern**: Para garantía de entrega de eventos de dominio vía Service Bus.
4. **WebForms read-only** durante la transición: El WebForms legacy no escribe
   en la base de datos una vez que la nueva API está en producción.
5. **SQL zero-tolerance**: Ninguna query concatenada en código nuevo.

## Opciones Consideradas

| Opción | Pros | Contras | Decisión |
| ------ | ---- | ------- | -------- |
| Strangler Fig incremental | Bajo riesgo, entrega valor continua, tests de paridad | Más lento que Big Bang | ✅ |
| Big Bang rewrite | Código limpio desde día 1 | Alto riesgo, pérdida de comportamiento no documentado | ❌ |
| Branch by Abstraction | Útil dentro de un módulo | No sirve para migración de toda la aplicación | Complementario |
| Characterization tests | Capturan comportamiento real, son el oráculo | Requieren acceso al legacy en test | ✅ MANDATORY |
| Strangler sin tests de paridad | Más rápido | No se puede verificar equivalencia → bugs en producción | ❌ |

## Consecuencias

**Positivas**:
- Los tests de caracterización actúan como oráculo: demuestran que el nuevo código
  reproduce exactamente el comportamiento del legacy.
- La migración módulo a módulo permite despliegue incremental sin interrupciones.
- La ACL protege el dominio nuevo de la podredumbre del esquema legacy.
- El Outbox Pattern garantiza la consistencia eventual en la sincronización de datos.

**Negativas / Riesgos**:
- La convivencia de WebForms y la nueva API añade complejidad temporal de operación.
- Los tests de caracterización requieren un entorno con la base de datos legacy real.
- La ACL añade una capa extra de código (justificada por el beneficio de protección del dominio).

## Compliance

- ✅ Constitution Art. XVII: Strangler Fig, WebForms read-only, ACL, Outbox
- ✅ Constitution Art. XIII: Characterization tests MANDATORY before rewrite
- ✅ Constitution Art. V: Zero SQL injection, EF Core parametrizado
- ✅ Constitution Art. XVIII: APIM como intermediario entre WebForms legacy y nueva API
