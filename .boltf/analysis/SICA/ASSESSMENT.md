# SICA — Legacy Assessment

> **Sistema**: SICA (Sistema Integrado de Controlo de Acessos)
> **Fase Bolt**: DISCOVERY (brownfield)
> **Fecha**: 2026-06-19
> **Fuente**: `demo/from_old_src/`
> **Analista**: Bolt Legacy Analyst
> **Alcance**: Análisis de solo lectura. **No se modifica el legacy.**

---

## 1. Resumen ejecutivo

SICA es una plataforma de **control de accesos físicos** en VB.NET que gestiona tarjetas,
zonas, permisos de acceso, visitantes, alarmas, puertas/circuitos y registros de auditoría
para 4 organizaciones (REFER, REFERTelecom, REFERPatrimonio, REFEREngineering).

Se compone de tres proyectos:

| Proyecto         | Tipo                       | Rol                                                       |
| ---------------- | -------------------------- | -------------------------------------------------------- |
| **SICAWeb**      | ASP.NET WebForms           | UI de operación (terminales de seguridad)                |
| **SICADataSync** | App VB.NET (Windows Forms) | Sincronización Active Directory → Alizes → SICA          |
| **wsSMIServer**  | Servicio web ASMX (SOAP)   | Wrapper de datos sobre la base de datos `Alizes`         |

**Hallazgo crítico**: vulnerabilidades extensas de inyección SQL por concatenación de cadenas,
modelo de autenticación débil (solo terminal + Windows Auth), servicio SOAP sin autenticación,
y credenciales de base de datos en texto plano en ficheros de configuración.

---

## 2. Inventario tecnológico

| Lenguaje / Framework      | Observado en                                        |
| ------------------------- | --------------------------------------------------- |
| VB.NET                    | Toda la lógica de negocio y acceso a datos          |
| ASP.NET Web Forms         | `SICAWeb` (.aspx, .ascx, code-behind .vb)           |
| ASMX SOAP Web Services    | `wsSMIServer/SMIMethods.asmx`                        |
| ADO.NET (`SqlClient`)     | `SQLMethods.vb` (3 copias duplicadas)               |
| `System.DirectoryServices`| `SICADataSync/ADMethods.vb` (LDAP)                  |
| `System.Net.Mail`         | `SICADataSync/Email.vb` (SMTP)                       |

### Estimación de LOC (orden de magnitud)

| Proyecto         | LOC aprox. | Componentes principales                                            |
| ---------------- | ---------- | ------------------------------------------------------------------ |
| SICADataSync     | ~1.990     | `DataSync.vb` (~650), `ADMethods.vb` (~550), `SQLMethods.vb` (~450)|
| wsSMIServer      | ~1.250     | `SMIMethods.asmx.vb` (~800), `SQLMethods.vb` (~450)               |
| SICAWeb          | ~1.215     | UserControls + code-behind + `App_Code`                            |
| **Total**        | **~4.500** | Rango estimado: 4.500 – 5.000 LOC                                  |

> Confianza: Media — basada en conteo de líneas y lectura de muestra (no todos los `.ascx`
> fueron leídos en su totalidad: `MonSeg.aspx.vb`, `DetalheLog.ascx.vb`, etc.).

### Dependencias externas

| Dependencia                       | Uso                                    | Fuente                                  |
| --------------------------------- | -------------------------------------- | --------------------------------------- |
| SQL Server `rfsql01` / `Alizes`   | Base de datos maestra (producción)     | `SICADataSync/app.config:9-10`          |
| SQL Server `rfsql01` / `SICA`     | Base de datos sombra/local             | `SICADataSync/app.config:11`            |
| Active Directory `refer.pt`       | Maestro de usuarios/empleados          | `SICADataSync/app.config:14-15`         |
| SMTP `hubmail.refer.pt`           | Notificaciones de sincronización       | `SICADataSync/app.config:26`            |
| `RJS PopCalendar.Net.2008`        | Control de calendario en UI            | `SICAWeb/SICAWeb/PopCalendar2008/`      |

---

## 3. Patrones y anti-patrones

### Patrones identificados

- Monolito WebForms con lógica en code-behind.
- Data Access Layer procedural (`SQLMethods.vb`), sin ORM.
- Sincronización batch AD → Alizes → SICA.
- Caché de datos sombra (`SICA` replica subconjuntos de `Alizes`).

### Anti-patrones

- **Inyección SQL por concatenación** — generalizado (ver §4).
- Triple duplicación de `SQLMethods.vb` (SICADataSync, wsSMIServer, App_Code).
- Mezcla de presentación, negocio y datos en el mismo `.ascx.vb`.
- Credenciales en texto plano en `app.config` / `Web.config`.
- Servicio SOAP (`wsSMIServer`) sin autenticación ni autorización.
- Números mágicos hardcoded (códigos de empresa, prefijos de tarjeta, IDs de evento).
- Código muerto comentado (lógica antigua de usuarios cesados en `DataSync.vb`).

---

## 4. Deuda técnica — Top 10 (por valor de remediación)

| #  | Deuda                                                            | Severidad | Fuente                                                        |
| -- | --------------------------------------------------------------- | --------- | ------------------------------------------------------------- |
| 1  | Inyección SQL — bypass de autenticación de terminal             | 🔴 Crítico | `SICAWeb/SICAWeb/Default.aspx.vb:12`                          |
| 2  | Credenciales de BD en texto plano                               | 🔴 Crítico | `SICADataSync/app.config:9-11`                               |
| 3  | Servicio SOAP sin autenticación/autorización (8+ WebMethods)    | 🔴 Crítico | `wsSMIServer/SMIMethods.asmx.vb`                             |
| 4  | Autorización basada solo en terminal (sin RBAC por usuario)     | 🔴 Crítico | `SICAWeb/SICAWeb/Default.aspx.vb:6-21`                       |
| 5  | Inyección SQL en inserciones de tarjetas/circuitos              | 🟠 Alto    | `SICAWeb/SICAWeb/Acessos.ascx.vb:50-66`                      |
| 6  | Construcción ad-hoc de WHERE en bucle                           | 🟠 Alto    | `SICAWeb/SICAWeb/ActivarCartoes.ascx.vb:25-30`              |
| 7  | Triple duplicación de `SQLMethods.vb`                           | 🟠 Alto    | `SICADataSync/`, `wsSMIServer/`, `SICAWeb/.../App_Code/`     |
| 8  | Sin validación de entrada en formularios y endpoints SOAP       | 🟠 Alto    | Todos los `.ascx.vb` y `SMIMethods.asmx.vb`                 |
| 9  | Sin cifrado en tránsito (SOAP/SQL en claro)                     | 🟡 Medio   | Conexiones SQL y llamadas SOAP                               |
| 10 | Sin manejo de excepciones en acceso a datos                     | 🟡 Medio   | `SQLMethods.vb` (las 3 copias)                              |

> Las inyecciones SQL se detallan con `fichero:línea` en
> [DATA_OBJECTS.md](DATA_OBJECTS.md#riesgos-de-inyeccion-sql).

---

## 5. Candidatos a código muerto

| Candidato                                              | Evidencia                                  | Confianza |
| ------------------------------------------------------ | ------------------------------------------ | --------- |
| Lógica antigua de usuarios cesados (comentada)         | `SICADataSync/DataSync.vb` (bloques comentados) | Media |
| Configuraciones de empresa `*Cessado` no usadas        | `SICADataSync/app.config` (REFERCessado=1653, etc.) | Media |
| Filtros OU marcados como `n/a`                          | `SICADataSync/app.config:16-24`            | Media     |
| `Visitantes.aspx.vb` sin `.aspx` correspondiente listado | Estructura de `SICAWeb/SICAWeb/`         | Baja      |

> Confirmar con SME antes de eliminar — ver footer.

---

## 6. Estimación de esfuerzo y recomendación

| Dominio                       | Patrón recomendado | Justificación                                                |
| ----------------------------- | ------------------ | ------------------------------------------------------------ |
| `wsSMIServer` (ASMX)          | **Rearchitect**    | Reescribir como REST API .NET 8 con autenticación            |
| `SICADataSync` (sync AD)      | **Rearchitect**    | Azure Functions + Service Bus (ver ADR-004)                  |
| `SICAWeb` (UI)                | **Rebuild**        | SPA React (ver ADR-002), módulo a módulo                     |
| Data layer (`SQLMethods.vb`)  | **Refactor**       | EF Core parametrizado, eliminar inyección SQL (ver ADR-001)  |
| Base de datos `SICA`/`Alizes` | **Replatform**     | Azure SQL Database (ver ADR-003)                             |

**Estrategia global**: Strangler Fig (ver
[ADR-004](../../../docs/adr/ADR-004-migracion-strangler-fig-characterization-tests.md)).

**Esfuerzo** (orden de magnitud): proyecto mediano. La complejidad principal no está en el
volumen (~4.500 LOC) sino en:

1. Reglas de negocio no documentadas en code-behind (ver [BUSINESS_RULES.md](BUSINESS_RULES.md)).
2. La eliminación segura de las inyecciones SQL preservando el comportamiento.
3. La sustitución del modelo de autorización por terminal por RBAC moderno.

> Las reglas **P0** forman el *behavior contract* de equivalencia: requieren tests de
> caracterización (golden-master) antes de cualquier reescritura.

---

## 7. Handoff a Bolt

| Salida                                | Consumidor Bolt                                          |
| ------------------------------------- | ------------------------------------------------------- |
| Este `ASSESSMENT.md`                  | Contexto para `@Bolt Plan` / `@Bolt Architect`          |
| [TOPOLOGY.md](../../../docs/SICA/TOPOLOGY.md) | `@Bolt Architect` (call graph, data lineage)      |
| [BUSINESS_RULES.md](BUSINESS_RULES.md) | `@Bolt Feature` → `@Bolt Specify` → `@Bolt Gherkin`     |
| [DATA_OBJECTS.md](DATA_OBJECTS.md)    | `@Bolt DDD` / data model de `@Bolt Plan`                |
| Reglas P0                             | *Behavior contract* de `skill-characterization-testing` |
| Candidatos a código muerto            | `@Bolt Retire`                                          |

---

## 8. Confianza y gaps

- **Confianza global**: Media-Alta. Las afirmaciones citadas con `fichero:línea` y verificadas
  directamente son de confianza Alta; las estimaciones de LOC y código muerto son Media.
- **Gaps conocidos**:
  - No se leyeron en su totalidad: `MonSeg.aspx.vb`, `DetalheLog.ascx.vb`,
    `DetalheUtilizador.ascx.vb`, `Historico.ascx.vb`, `LogHistorico.ascx.vb`.
  - El esquema real de `Alizes` y `SICA` se infiere de las consultas SQL, no del DDL.
  - La frecuencia real de sincronización de `SICADataSync` no está clara (¿tarea programada?).
- **Preguntas a SME**:
  - ¿Están realmente desactivándose los usuarios cesados? (lógica comentada).
  - ¿Cuál es la ventana de validez real de las tarjetas de visitante?
  - ¿Qué eventos representan los IDs 249 / 253 / 255 filtrados en los logs?
