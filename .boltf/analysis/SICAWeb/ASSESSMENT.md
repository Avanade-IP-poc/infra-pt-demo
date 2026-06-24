# ASSESSMENT — SICAWeb (Legacy)

> **Fase Bolt**: DISCOVERY (brownfield)
> **Fecha análisis**: 2026-06-24
> **Fuente**: `demo/from_old_src/SICAWeb/SICAWeb/`
> **Analista**: Bolt Legacy Analyst

---

## 1. Inventario

### Resumen de ficheros

| Tipo | Ficheros | LOC estimadas |
|---|---|---|
| Code-behind (.ascx.vb / .aspx.vb) | 20 | ~1 100 |
| App_Code (.vb) | 2 | ~280 |
| ASPX/ASCX markup | ~25 | ~900 |
| Web.config / packages | 2 | ~130 |
| **Total** | **~49** | **~2 400** |

### Lenguajes y frameworks

| Tecnología | Versión | Rol |
|---|---|---|
| VB.NET | .NET 4.0 | Backend / code-behind |
| ASP.NET WebForms | 4.0 | Framework UI |
| AjaxControlToolkit | 3.5 | Componentes AJAX |
| Microsoft.ReportViewer | 8.0 | Informes (no confirmado uso activo) |
| System.DirectoryServices | 4.0 | Integración AD |
| WCF BasicHttpBinding | — | Cliente SOAP → wsSMIServer |

### Puntos de entrada (páginas)

| Página | Función | Complejidad |
|---|---|---|
| `Default.aspx` | Login por terminal (IP/hostname) | Media |
| `PagPrincipal.aspx` | Dashboard principal: circuito + log + usuario | Alta |
| `PagVisitantes.aspx` | Gestión de visitantes y asignación de tarjetas | Alta |
| `PagZonas.aspx` | Monitorización de zonas en tiempo real | Media |
| `PagAlarmes.aspx` | Panel de alarmas | Baja |
| `PagHistorico.aspx` | Consulta histórica de movimientos | Media |
| `PagConfigAcessos.aspx` | Configuración de accesos por terminal *(restringido)* | Alta |
| `ConfigurarAcessos.aspx` | **Stub vacío** — dead code | — |
| `AtribuicaoCartoes.aspx` | **Stub vacío** — dead code | — |
| `MonSeg.aspx` | Desconocido (sin code-behind analizable) | — |
| `Foto.aspx` | Servir foto de empleado | Baja |

---

## 2. Deuda técnica — Top 10

| # | Deuda | Severidad | Fichero:línea |
|---|---|---|---|
| DT-01 | **Credenciales de producción en claro en Web.config** (contraseña SQL hardcodeada) | 🔴 CRÍTICA | `Web.config:4-5` |
| DT-02 | **SQL Injection** — concatenación sin parámetros en consultas dinámicas | 🔴 CRÍTICA | Ver lista abajo |
| DT-03 | **Control de acceso por whitelist en config** — roles como cadena de texto (`AcessoDeConfiguracao`, `AcessoAHistorico`) | 🔴 ALTA | `Web.config:18-19`, `Menu.ascx.vb:22-23`, `Acessos.ascx.vb:10` |
| DT-04 | **Catch vacíos** — errores silenciados, imposible diagnosticar fallos en producción | 🟠 ALTA | `SQLMethods.vb:198`, `ActivarCartoes.ascx.vb:55` |
| DT-05 | **State en Session ASP.NET** — NomeTerminal, Utilizador, Circuitos, CartoesTerminal, FamiliasTerminal — imposible escalar horizontalmente | 🟠 ALTA | Todos los UserControls |
| DT-06 | **DML (INSERT/DELETE) ejecutado con `SelectQuery()`** — confusión semántica deliberada del DAL | 🟠 ALTA | `Acessos.ascx.vb:124-136` |
| DT-07 | **Sin ORM ni repositorio** — acceso directo a `SqlConnection` en code-behind | 🟡 MEDIA | Todos los code-behind |
| DT-08 | **Lógica de negocio mezclada con presentación** — validaciones, transformaciones y renders en el mismo método | 🟡 MEDIA | `DetalheVisitante.ascx.vb:60-150`, `ActivarCartoes.ascx.vb:70-120` |
| DT-09 | **Sin tests** — cero cobertura de test automatizado | 🟡 MEDIA | Todo el proyecto |
| DT-10 | **Fechas construidas manualmente con string concat** en lugar de parámetros SQL | 🟡 MEDIA | `LogHistorico.ascx.vb:26-32` |

### Hotspots de SQL Injection (DT-02)

| Fichero | Línea aprox. | Fragmento |
|---|---|---|
| `Default.aspx.vb` | 8 | `"...upper(nome)='" & NomePC.ToUpper & "' or ip='" & IP & "'"` |
| `ActivarCartoes.ascx.vb` | 22 | `"...vwFamilias where NomeTerminal='" & Nome & "'"` |
| `ActivarCartoes.ascx.vb` | 38 | `"...vwREFERFamilias" & strSQLWhere` (construido con concat) |
| `ActivarCartoes.ascx.vb` | 59 | `"...vwREFERVisitantes" & strSQLWhere` (construido con concat) |
| `Acessos.ascx.vb` | 49 | `"INSERT INTO tblCartoes ... VALUES (" & SMICartoes(i).idSmartCard & ",'"...` |
| `Acessos.ascx.vb` | 57 | `"INSERT INTO tblFamilias ... VALUES (" & SMIFamilias(i).idFamily ...` |
| `Acessos.ascx.vb` | 103 | `"Select ... WHERE tblCartoesTerminal.IDTerminal=" & ddlFiltroTerminais.SelectedValue` |
| `Acessos.ascx.vb` | 124 | `"delete from tblCartoesTerminal where idterminal=" & ddlFiltroTerminais.SelectedValue` |
| `DetalheUtilizador.ascx.vb` | 49 | `"SELECT wWWHomePage ... WHERE employeeID='" & NumEmpregado & "'"` |
| `DetalheVisitante.ascx.vb` | 55 | `"...vwAcessos where NumCartao='" & NumCartao & "' and NomeTerminal like '" & Session("NomeTerminal") & "%'"` |
| `LogHistorico.ascx.vb` | 26 | Fechas concatenadas directamente en SQL |
| `Visitantes.ascx.vb` | 22 | `"...vwCartoes where IPTerminal='" & Host & "'"` |

---

## 3. Dead Code

| Elemento | Evidencia |
|---|---|
| `ConfigurarAcessos.aspx.vb` | Clase vacía (`Partial Class ConfigurarAcessos` sin lógica) |
| `AtribuicaoCartoes.aspx.vb` | Clase vacía (`Partial Class AtribuicaoCartao` sin lógica) |
| `Historico.ascx.vb` | Clase vacía |
| `PagPrincipal.aspx.vb` | Clase vacía — la lógica está en los UserControls |
| `MasterPage.master.vb` | Clase vacía |
| `DetalheZona.ascx.vb` | Mínima — sólo `RefreshInfo` de 2 líneas, lógica delegada al datasource |
| `DetalheLog.ascx.vb` | Mínima — sólo dispara `DataBind` |
| `_app_offline.htm` | Página de mantenimiento (no es dead code, pero merece revisión) |
| `Comentario en ActivarCartoes.ascx.vb:199-205` | Bloque comentado con `MarcaMovimentoSessao` — lógica eliminada sin documentar |

---

## 4. Dependencias externas

| Dependencia | Tipo | Acoplamiento |
|---|---|---|
| `wsSMIServer` (SMIMethodsSoap) | SOAP WCF | 🔴 Alto — instanciado directamente en code-behind sin abstracción |
| SQL Server `rfsql01` / `SICA_V2` | Base de datos | 🔴 Alto — connection string hardcodeada con credenciales |
| SQL Server `rfsql01` / `ActiveDirectory` | BD réplica AD | 🟠 Medio — usada sólo para fotos de empleado |
| BD `AlizesConnectionString` | BD externa (Alizes/REFER) | 🟠 Medio — usada en ActivarCartoes, LogHistorico |
| Windows Authentication (`LOGON_USER`) | IIS / AD | 🟡 Bajo — sólo en Default.aspx |

---

## 5. Estimación de esfuerzo

| Fase | Descripción | Bolts estimados | Semanas |
|---|---|---|---|
| B1 | Tests de caracterización (golden-master) + rehost Azure | 2 | 1 sem |
| B2-B4 | Web API .NET 8: dominios IAM + Card Management + Access Control | 3 | 1,5 sem |
| B5-B6 | Web API: Physical Monitoring + SMI Adapter (anti-corruption layer) | 2 | 1 sem |
| B7-B9 | SPA React: páginas críticas (PagPrincipal, PagVisitantes, PagZonas) | 3 | 1,5 sem |
| B10-B11 | SPA React: ConfigAcessos, Histórico, Alarmas | 2 | 1 sem |
| B12 | Infraestructura Bicep + CI/CD + Observabilidad | 1 | 0,5 sem |
| **Total** | | **~13 Bolts** | **~6,5 sem** |

> Rango: 5–9 semanas equipo 2 personas (incertidumbre ±30% por dependencia SMI sin spec pública).

---

## 6. Patrón de migración recomendado

**Rearchitect** (Strangler Fig, ya documentado en `feature.md`)

Justificación:
- Arquitectura WebForms no migrable a .NET 8 sin reescritura.
- Deuda de seguridad crítica (SQL injection generalizado, credenciales en texto claro) que impide simplemente replatformar.
- El dominio es claro y acotado — los bounded contexts ya están modelados.
- La integración SMI es la mayor incógnita: priorizar anti-corruption layer temprano.
