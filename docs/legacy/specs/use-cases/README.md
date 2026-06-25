# SICA — Índice de Casos de Uso (Legacy)

> **Fase Bolt**: DISCOVERY (brownfield)
> **Fuente**: Extraídos del análisis en `.boltf/analysis/SICA/BUSINESS_RULES.md`
> **Destino modernización**: `specs/001-migracion-sica/`

## Resumen

| UC ID  | Título                                             | Actor primario       | Reglas             | Prioridad |
| ------ | -------------------------------------------------- | -------------------- | ------------------ | --------- |
| [UC-001](UC-001.md) | Sincronización de empleados desde AD      | SICADataSync         | RULE-001, 002, 003 | P0/P1     |
| [UC-002](UC-002.md) | Clasificación y sincronización de tarjetas| SICADataSync         | RULE-004, 005      | P1        |
| [UC-003](UC-003.md) | Autorización de terminal y sesión         | Operador (humano)    | RULE-008, 009      | P0        |
| [UC-004](UC-004.md) | Activación de tarjeta de visitante        | Operador (humano)    | RULE-006, 007      | P1        |
| [UC-005](UC-005.md) | Consulta y modificación vía SOAP          | SICAWeb / externo    | (sin auth ⚠️)     | P0 (riesgo)|
| [UC-006](UC-006.md) | Monitorización de circuitos y eventos     | Operador (humano)    | —                  | P1        |
| [UC-007](UC-007.md) | Monitorización de alarmas de seguridad    | Operador (humano)    | —                  | P1        |
| [UC-008](UC-008.md) | Análisis de historial de accesos          | Supervisor (humano)  | RULE-008           | P1 (riesgo)|
| [UC-009](UC-009.md) | Dashboard de resumen de zonas             | Operador (humano)    | —                  | P2        |
| [UC-010](UC-010.md) | Consulta de tarjetas de visitante         | Recepción (humano)   | RULE-006, 007      | P1 (riesgo)|
| [UC-011](UC-011.md) | Edición de detalle de tarjeta de visitante| Recepción (humano)   | RULE-006, 007      | P0 (riesgo)|
| [UC-012](UC-012.md) | Configuración de permisos por terminal    | Administrador (humano)| RULE-008          | P0 (riesgo)|
| [UC-013](UC-013.md) | Navegación y control de acceso por menú   | Operador (humano)    | RULE-008, 009      | P1        |

## Cobertura de reglas

| Regla    | Cubierta por |
| -------- | ------------ |
| RULE-001 | UC-001       |
| RULE-002 | UC-001       |
| RULE-003 | UC-001       |
| RULE-004 | UC-002       |
| RULE-005 | UC-002       |
| RULE-006 | UC-004, UC-010, UC-011 |
| RULE-007 | UC-004, UC-010, UC-011 |
| RULE-008 | UC-003, UC-004, UC-008, UC-012, UC-013 |
| RULE-009 | UC-003, UC-013 |

## Cobertura funcional del legacy

Los UC-006 a UC-013 completan la cobertura de los componentes de `SICAWeb` que no se
analizaron en la primera pasada:

| UC     | Componentes legacy cubiertos                                          |
| ------ | --------------------------------------------------------------------- |
| UC-006 | `Circuitos.ascx`, `LogPorta.ascx`, `DetalheUtilizador.ascx`           |
| UC-007 | `Alarmes.ascx`, `PagAlarmes.aspx`                                     |
| UC-008 | `LogHistorico.ascx`, `Historico.ascx`, `DetalheLog.ascx`, `PagHistorico.aspx` |
| UC-009 | `ResumoZonas.ascx`, `DetalheZona.ascx`                                |
| UC-010 | `Visitantes.ascx`                                                     |
| UC-011 | `DetalheVisitante.ascx`, `AtribuicaoCartoes.aspx`                     |
| UC-012 | `Acessos.ascx`, `ConfigurarAcessos.aspx`, `PagConfigAcessos.aspx`     |
| UC-013 | `Menu.ascx`, `MonSeg.aspx`                                            |

> Las páginas contenedoras vacías (`ConfigurarAcessos.aspx`, `AtribuicaoCartoes.aspx`,
> `PagAlarmes.aspx`, `PagHistorico.aspx`, `PagConfigAcessos.aspx`) no tienen lógica propia;
> su comportamiento está en los UserControls referenciados arriba.

## Vulnerabilidades de seguridad detectadas (SQL Injection)

| UC     | Severidad | Ubicación legacy                                  |
| ------ | --------- | ------------------------------------------------- |
| UC-008 | CRÍTICA   | `LogHistorico.ascx.vb:24-30` (fechas)             |
| UC-011 | CRÍTICA   | `DetalheVisitante.ascx.vb:54,509`                 |
| UC-012 | SEVERA    | `Acessos.ascx.vb:48,64,78` (datos SMI)            |
| UC-010 | ALTA      | `Visitantes.ascx.vb:27,31,110`                    |
| UC-006 | MEDIA     | `DetalheUtilizador.ascx.vb:32`                    |
| UC-013 | MEDIA     | `MonSeg.aspx.vb:58`                               |

## Handoff

| Artefacto              | Consumidor siguiente                                        |
| ---------------------- | ----------------------------------------------------------- |
| UC-001 a UC-013        | `@Bolt Gherkin` → escenarios `.feature` para Reqnroll      |
| UC-003 (P0 auth)       | `@Bolt Security` → tests de caracterización RULE-008        |
| UC-005 (SOAP sin auth) | ADR de reemplazo de wsSMIServer por REST API + Azure AD     |
| UC-008/010/011/012 (SQLi) | `@Bolt Security` → remediación de inyección SQL parametrizada |
