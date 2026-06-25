# BUSINESS RULES — SICAWeb (Legacy)

> **Fase Bolt**: DISCOVERY (brownfield)
> **Fecha**: 2026-06-24
> **Fuente**: `demo/from_old_src/SICAWeb/SICAWeb/`
> **Confianza**: Alta = extraído directamente del código; Media = inferido de flujo; Baja = supuesto por contexto

---

## Dominio: Identity & Access Management (Terminal Auth)

---

### RULE-001: Autorización de terminal por IP o nombre
**Categoría:** Validación  
**Prioridad:** P0  
**Fuente:** `Default.aspx.vb:8`  
**En lenguaje natural:** Un terminal sólo puede acceder a SICA si su nombre de equipo o su IP están registrados en `tblTerminais`.

**Especificación:**
```
Given un equipo cliente carga Default.aspx
When el servidor recibe el nombre de host (txtComputerName) y la IP del cliente
Then consulta tblTerminais WHERE upper(nome) = NombrePC.ToUpper OR ip = IP
  And si hay resultado → Session("NomeTerminal") = nombre registrado → redirige a PagPrincipal.aspx
  And si no hay resultado → lblAcesso = "False", permanece en Default.aspx
```
**Parámetros:** tabla `tblTerminais` (nombre, IP)  
**Casos borde:** IP detrás de proxy → usa `HTTP_X_FORWARDED_FOR`; si hay múltiples IPs en el header, se toma la primera (`Default.aspx.vb:28`)  
**Defecto sospechoso:** No hay bloqueo por intentos fallidos; el timer sigue reintentando si no hay acceso  
**Confianza:** Alta

---

### RULE-002: Identidad del operador via Windows Authentication
**Categoría:** Ciclo de vida  
**Prioridad:** P0  
**Fuente:** `Default.aspx.vb:37-43`  
**En lenguaje natural:** El nombre de usuario se extrae del header `LOGON_USER` (Windows Auth / IIS) y se almacena en sesión sin el prefijo de dominio.

**Especificación:**
```
Given la página Default.aspx se carga por primera vez (Not IsPostBack)
When Request.ServerVariables("LOGON_USER") retorna "DOMINIO\usuario"
Then Session("Utilizador") = parte tras la última "\" (strip del dominio)
  And si LOGON_USER está vacío o tiene 1 char → Session("Utilizador") = ""
```
**Parámetros:** Separador `\`  
**Casos borde:** Usuario sin dominio (longitud ≤ 1 char) → sesión de usuario vacía  
**Confianza:** Alta

---

### RULE-003: Control de acceso a páginas restringidas por whitelist en config
**Categoría:** Política  
**Prioridad:** P0  
**Fuente:** `Web.config:18-19`, `Menu.ascx.vb:22-23`, `Acessos.ascx.vb:10`, `LogHistorico.ascx.vb:148`  
**En lenguaje natural:** Las páginas de Configuración de Accesos e Histórico son visibles/funcionales sólo si el username del usuario está en una lista separada por `;` definida en appSettings.

**Especificación:**
```
Given un usuario navega a PagConfigAcessos.aspx o activa el menú
When AppSettings("AcessoDeConfiguracao").IndexOf(Session("Utilizador")) < 0
Then el panel de configuración se oculta (updatePanelGeral.Visible = False)
  And el ítem de menú no se muestra (lbTituloConfiguracaoAcessos.Visible = False)

Given un usuario accede a PagHistorico.aspx
When AppSettings("AcessoAHistorico").IndexOf(Session("Utilizador")) < 0 OR Session("Utilizador").Length = 0
Then los paneles de consulta y resultado se ocultan
  And el ítem de menú no se muestra
```
**Parámetros:** `AcessoDeConfiguracao = "ajsfernandes;tzcorreia"`, `AcessoAHistorico = "ajsfernandes;tzcorreia;jcssilva"` (valores de producción en Web.config)  
**Defecto sospechoso:** `IndexOf` puede devolver falso positivo si un username es substring de otro (p.ej. "ana" aparece en "management")  
**Confianza:** Alta

---

## Dominio: Card Management

---

### RULE-004: Sincronización de tarjetas SMI → SICA (auto-registro)
**Categoría:** Ciclo de vida  
**Prioridad:** P1  
**Fuente:** `Acessos.ascx.vb:45-52`  
**En lenguaje natural:** Al cargar la configuración de accesos, las tarjetas del sistema SMI que no existan en SICA se insertan automáticamente.

**Especificación:**
```
Given el operador autorizado abre la pantalla de configuración de accesos
When SMI.GetExternalSmartCards() devuelve tarjetas
  And para cada tarjeta: no existe en tblCartoes (SELECT ID WHERE id = idSmartCard)
Then INSERT INTO tblCartoes (ID, NumCartao, Decricao) VALUES (idSmartCard, LogicalCode, Label[0..50])
```
**Parámetros:** Label truncado a 50 caracteres  
**Casos borde:** Label > 50 chars → truncado silencioso (`Left(label, 50)`)  
**Confianza:** Alta

---

### RULE-005: Sincronización de familias SMI → SICA (auto-registro)
**Categoría:** Ciclo de vida  
**Prioridad:** P1  
**Fuente:** `Acessos.ascx.vb:57-62`  
**En lenguaje natural:** Al cargar la configuración de accesos, las familias del sistema SMI que no existan en SICA se insertan automáticamente.

**Especificación:**
```
Given el operador autorizado abre la pantalla de configuración de accesos
When SMI.GetFamilies() devuelve familias
  And para cada familia: no existe en tblFamilias (SELECT ID WHERE id = idFamily)
Then INSERT INTO tblFamilias (ID, Nome) VALUES (idFamily, Label[0..50])
```
**Parámetros:** Label truncado a 50 chars  
**Confianza:** Alta

---

### RULE-006: Sincronización de circuitos SMI → SICA (auto-registro)
**Categoría:** Ciclo de vida  
**Prioridad:** P1  
**Fuente:** `Acessos.ascx.vb:65-75`  
**En lenguaje natural:** Al cargar la configuración de accesos, los circuitos del sistema SMI que no existan en SICA se insertan automáticamente; el IDCircuitoGrupo se inicializa igual al ID del circuito.

**Especificación:**
```
Given el operador autorizado abre la pantalla de configuración de accesos
When SMI.GetCircuits() devuelve circuitos
  And para cada circuito: no existe en tblCircuitos (SELECT ID WHERE id = idCircuit)
Then INSERT INTO tblCircuitos (ID, Nome, IDCircuitoGrupo) VALUES (idCircuit, Label[0..50], idCircuit)
  And IDCircuitoGrupo = idCircuit (self-referencing por defecto)
```
**Parámetros:** IDCircuitoGrupo bootstrapeado a idCircuit — puede requerir corrección manual posterior  
**Defecto sospechoso:** El IDCircuitoGrupo debería venir de SMI pero se autopone como el mismo ID  
**Confianza:** Alta

---

### RULE-007: Perfil de acceso de terminal (tarjetas + familias + circuitos)
**Categoría:** Ciclo de vida  
**Prioridad:** P0  
**Fuente:** `Acessos.ascx.vb:120-143`  
**En lenguaje natural:** Guardar el perfil de acceso de un terminal borra completamente sus relaciones actuales de tarjetas, familias y circuitos y las reemplaza por las seleccionadas.

**Especificación:**
```
Given el operador selecciona un terminal y marca tarjetas/familias/circuitos
When hace clic en "Aplicar" y ddlFiltroTerminais.SelectedValue != 0
Then DELETE FROM tblCartoesTerminal WHERE idterminal = selectedTerminalId
  And INSERT INTO tblCartoesTerminal (idcartao, idterminal) para cada tarjeta seleccionada
  And DELETE FROM tblFamiliasTerminal WHERE idterminal = selectedTerminalId
  And INSERT INTO tblFamiliasTerminal (idfamilia, idterminal) para cada familia seleccionada
  And DELETE FROM tblCircuitosTerminal WHERE idterminal = selectedTerminalId
  And INSERT INTO tblCircuitosTerminal (idcircuito, idterminal) para cada circuito seleccionado
```
**Parámetros:** No hay transacción explícita — riesgo de inconsistencia si falla a mitad  
**Defecto sospechoso:** Operación no envuelta en transacción SQL → si el INSERT falla tras el DELETE, el terminal queda sin acceso  
**Confianza:** Alta

---

### RULE-008: Tarjeta disponible para visitante sólo si tiene hora de salida (o nunca asignada)
**Categoría:** Validación  
**Prioridad:** P0  
**Fuente:** `ActivarCartoes.ascx.vb:87-103`  
**En lenguaje natural:** Una tarjeta sólo aparece en la lista de "disponibles" para asignar a un visitante si tiene hora de salida registrada, o si nunca fue asignada (sin hora de entrada ni salida).

**Especificación:**
```
Given la pantalla de activación de tarjetas carga la lista de disponibles
When se recorre vwREFERVisitantes con los datos de campos adicionales del cartão
Then una tarjeta es "disponible" si:
  - HoraSaida.Length > 0  (ya salió el visitante anterior)
  - O (HoraEntrada.Length = 0 AND HoraSaida.Length = 0)  (nunca fue usada)
  And una tarjeta NO disponible si:
  - HoraEntrada.Length > 0 AND HoraSaida.Length = 0  (visitante activo sin salida)
```
**Parámetros:** IDCampo 6 = hora entrada, IDCampo 7 = hora salida, IDCampo 5 = empresa  
**Confianza:** Alta

---

### RULE-009: Validación de asignación de tarjeta a visitante
**Categoría:** Validación  
**Prioridad:** P0  
**Fuente:** `ActivarCartoes.ascx.vb:214-240`  
**En lenguaje natural:** Para grabar la asignación de tarjeta a visitante deben estar completos al menos un campo del visitante, la familia de acceso seleccionada y al menos una tarjeta disponible.

**Especificación:**
```
Given el operador rellena el formulario de activación de tarjeta
When hace clic en "Grabar"
Then validar: al menos uno de (NombreVisitante, Empresa, EntidadVisitada, HoraEntrada, HoraSaida) no vacío
  And al menos una familia seleccionada en lbVisitanteAcessoFamilia
  And al menos una tarjeta seleccionada en lbCartoesDisponiveis
  And si todas las condiciones: GravaInfoAdicional(numCartao) para cada tarjeta seleccionada
  And si falla cualquiera: mostrar mensaje de error específico en lblStatus
```
**Confianza:** Alta

---

## Dominio: Physical Access Monitoring

---

### RULE-010: Resolución de circuitos físicos de un circuito grupo
**Categoría:** Cálculo  
**Prioridad:** P1  
**Fuente:** `Circuitos.ascx.vb:23-35`, `LogPorta.ascx.vb:12-24`  
**En lenguaje natural:** Un circuito de la vista lógica (grupo) corresponde a uno o más circuitos físicos en `tblCircuitos`; para obtener los eventos reales se consultan todos los circuitos físicos del grupo.

**Especificación:**
```
Given el usuario selecciona un circuito en el dropdown
When circuitID = ddlCircuit.SelectedItem.Value
Then SELECT IDCircuitoGrupo, ID as IDCircuito FROM tblCircuitos WHERE IDCircuitoGrupo IN (circuitIDs del terminal)
  And CircuitIDs = join de todos los IDCircuito del grupo separados por ","
  And SMI.GetLastCircuitEvents(CircuitIDs, 72, 20) → eventos de las últimas 72h, máximo 20
```
**Parámetros:** Ventana temporal: 72 horas; máximo eventos: 20  
**Confianza:** Alta

---

### RULE-011: Clasificación de movimiento como Entrada o Salida
**Categoría:** Cálculo  
**Prioridad:** P0  
**Fuente:** `LogHistorico.ascx.vb:38-52`  
**En lenguaje natural:** Un evento de acceso se clasifica como "Entrada" o "Salida" según el texto de descripción del circuito, o por el campo `parametre` si la descripción no es determinante.

**Especificación:**
```
Given un evento de movimiento (idEventement 130 o 133) de vwREFERLog
When descriptioncircuit.ToUpper.IndexOf("ENTRADA") > 0
Then posicao = Dentro (Entrada)
When descriptioncircuit.ToUpper.IndexOf("SAIDA") > 0
Then posicao = Fora (Salida)
When ninguna de las anteriores AND parametre = 1
Then posicao = Dentro
When ninguna de las anteriores AND parametre = 2
Then posicao = Fora
When ninguna de las anteriores
Then posicao = Desconhecido, dataPosicao = Nothing
```
**Parámetros:** idevenement: 130 (entrada), 133 (salida o acceso); parametre: 1=dentro, 2=fuera  
**Casos borde:** Posición "Desconhecido" → evento ignorado en el informe  
**Confianza:** Alta

---

### RULE-012: Periodo de búsqueda ampliado para determinar posición inicial
**Categoría:** Cálculo  
**Prioridad:** P1  
**Fuente:** `LogHistorico.ascx.vb:26-32`  
**En lenguaje natural:** La consulta de movimientos históricos amplía el rango de búsqueda en ±7 días para poder determinar si una persona ya estaba dentro del período antes de que comenzara.

**Especificación:**
```
Given el usuario solicita histórico para periodo [inicioPeriodo, finPeriodo]
When se construye la consulta SQL a vwREFERLog
Then WHERE dat > (inicioPeriodo - 7 días) AND dat < (finPeriodo + 7 días)
  And sólo se reportan movimientos con dat BETWEEN inicioPeriodo AND finPeriodo
  And la ampliación de 7 días sirve para trazar la posición de entrada previa al período
```
**Parámetros:** Ventana de contexto: 7 días antes y después del período solicitado  
**Confianza:** Alta

---

## Dominio: Visitor Management

---

### RULE-013: Acceso del terminal al cartão — verificación previa a cualquier operación
**Categoría:** Validación  
**Prioridad:** P0  
**Fuente:** `DetalheVisitante.ascx.vb:55-58`  
**En lenguaje natural:** Antes de operar sobre una tarjeta, se verifica que el terminal actual tenga acceso a esa tarjeta consultando la vista `vwAcessos`.

**Especificación:**
```
Given el operador introduce un número de tarjeta para gestionar
When SELECT DISTINCT IDCartao FROM vwAcessos WHERE NumCartao = numCartao AND NomeTerminal LIKE Session("NomeTerminal") + "%"
Then si rows.Count = 1 → el terminal tiene acceso → continuar con operación
  And si rows.Count = 0 → mostrar "Sem acesso ao cartão X" + sp_tblLog_Insert con aviso
```
**Parámetros:** `LIKE NomeTerminal%` — permite terminales con sufijos (p.ej. "TERM01A", "TERM01B")  
**Casos borde:** Si hay más de 1 fila en vwAcessos → `rows.Count = 1` fallaría (posible bug si el terminal aparece duplicado en la vista)  
**Defecto sospechoso:** La condición es `= 1` en lugar de `> 0` → riesgo de denegación de acceso si la vista retorna duplicados  
**Confianza:** Alta

---

### RULE-014: Sugerencia automática de hora de entrada/salida según estado del cartão
**Categoría:** Ciclo de vida  
**Prioridad:** P1  
**Fuente:** `DetalheVisitante.ascx.vb:112-137`  
**En lenguaje natural:** Al abrir una tarjeta, el sistema sugiere campos de entrada/salida según el estado actual de la visita.

**Especificación:**
```
Given se abre una tarjeta en DetalheVisitante
When HoraEntrada.Length = 0 AND HoraSaida.Length = 0 (nunca usada o ya cerrada)
Then sugerir: HoraEntrada = Now, ValidadeCartao = Now, Estado = Active (2)
  And marcar campos con fondo verde (LightGreen)
When HoraEntrada.Length = 0 AND HoraSaida.Length = 0 (visitante completó ciclo)
Then igual que arriba (nuevo ciclo)
When HoraEntrada.Length > 0 AND HoraSaida.Length = 0 (visitante dentro)
Then sugerir: HoraSaida = Now, Estado = Forbiden (4)
  And marcar HoraSaida y estado con fondo verde
```
**Parámetros:** Estado Active=2, Forbiden=4 (`SmartCardStatus` enum del SMI)  
**Confianza:** Alta

---

### RULE-015: Estados válidos de tarjeta inteligente
**Categoría:** Ciclo de vida  
**Prioridad:** P0  
**Fuente:** `DetalheVisitante.ascx.vb:74-86`  
**En lenguaje natural:** Las tarjetas tienen 6 estados posibles definidos en el enum `SmartCardStatus` del servicio SMI.

**Especificación:**
```
Given una tarjeta es consultada o actualizada
When se mapea SmartCardStatus del SMI a valor numérico de la UI
Then Active → 2
     Forbiden → 4
     Lost → 8
     Stolen → 16
     Destroied → 32
     [cualquier otro / desconocido] → 0
```
**Parámetros:** Enum `SMIMethodsWebService.SmartCardStatus`  
**Casos borde:** Estado 0 = "desconocido" — la UI lo permite seleccionar pero no tiene semántica definida  
**Confianza:** Alta

---

## Dominio: Monitoring (Alarmas y Zonas)

---

### RULE-016: Refresco periódico configurable por tipo de panel
**Categoría:** Política  
**Prioridad:** P2  
**Fuente:** `Web.config:15-17`, `Alarmes.ascx.vb:7`, `Circuitos.ascx.vb:49`, `Visitantes.ascx.vb:84`, `ResumoZonas.ascx.vb:14`  
**En lenguaje natural:** Cada panel de monitorización tiene su propio intervalo de refresco configurable en appSettings, expresado en segundos.

**Especificación:**
```
Given se carga cualquier panel de monitorización
When Page_Load (Not IsPostBack)
Then Timer.Interval = AppSettings("[NombreClave]") * 1000
  Donde: DisplayLogRefreshInterval (log porta), AlarmsRefreshInterval (alarmas), 
         CartoesForaRefreshInterval (tarjetas), ZonasRefreshInterval (zonas)
```
**Parámetros:** DisplayLogRefreshInterval=5s, AlarmDaysToShow=2, AlarmsRefreshInterval=60s, CartoesForaRefreshInterval=15s, ZonasRefreshInterval=60s  
**Confianza:** Alta

---

### RULE-017: Log de auditoría en toda acción sobre tarjeta
**Categoría:** Política  
**Prioridad:** P0  
**Fuente:** `ActivarCartoes.ascx.vb:131-140`, `Visitantes.ascx.vb:77-86`, `DetalheVisitante.ascx.vb` (implicado)  
**En lenguaje natural:** Toda acción sobre tarjetas (activación, error de acceso, operación de visitante) genera un registro en `tblLog` via stored procedure.

**Especificación:**
```
Given se produce cualquier acción relevante sobre una tarjeta o un error de acceso
When se llama a EscreveLog(texto, cartao)
Then sp_tblLog_Insert(@Texto = texto, @Cartao = cartao, @Terminal = Session("NomeTerminal"), @Utilizador = Session("Utilizador"))
```
**Parámetros:** SP `sp_tblLog_Insert`; @Cartao puede ser vacío para logs sin tarjeta específica  
**Confianza:** Alta
