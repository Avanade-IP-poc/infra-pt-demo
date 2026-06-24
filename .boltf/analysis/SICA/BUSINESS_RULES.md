# SICA — Reglas de Negocio Extraídas

> **Sistema**: SICA (Sistema Integrado de Controlo de Acessos)
> **Fase Bolt**: DISCOVERY (brownfield)
> **Fuente**: `demo/from_old_src/`
> **Formato**: Rule Cards con especificación Given/When/Then.
> **Uso**: Las reglas **P0** forman el *behavior contract* para tests de caracterización
> (golden-master) antes de cualquier reescritura.

---

## Índice de reglas

| ID       | Nombre                                          | Categoría       | Prioridad | Confianza |
| -------- | ----------------------------------------------- | --------------- | --------- | --------- |
| RULE-001 | Validación de Employee ID                       | Validación      | P0        | Alta      |
| RULE-002 | Estrategia crear-o-actualizar (merge AD)        | Ciclo de vida   | P1        | Alta      |
| RULE-003 | Segmentación por organización (multi-tenant)    | Política        | P0        | Alta      |
| RULE-004 | Clasificación de tipo de tarjeta por prefijo    | Validación      | P1        | Alta      |
| RULE-005 | Sincronización de tarjetas a SICAWeb            | Ciclo de vida   | P1        | Alta      |
| RULE-006 | Filtro de disponibilidad de tarjeta de visitante| Ciclo de vida   | P1        | Alta      |
| RULE-007 | Ventana de validez de tarjeta de visitante      | Política        | P1        | Media     |
| RULE-008 | Autorización por lista blanca de terminal       | Política        | P0        | Alta      |
| RULE-009 | Extracción del principal de Windows Auth        | Autenticación   | P0        | Alta      |

> Prioridad: **P0** = seguridad / integridad crítica · **P1** = lógica de negocio core
> · **P2** = operacional.

---

## RULE-001: Validación de Employee ID

- **Categoría**: Validación
- **Prioridad**: P0
- **Fuente**: [DataSync.vb:250-251](../../../demo/from_old_src/SICADataSync/DataSync.vb)
- **Confianza**: Alta

### En lenguaje natural

Antes de sincronizar un usuario de AD a SICA, solo se procesa si su `employeeID` tiene
exactamente 7 caracteres y **no** empieza por los códigos reservados `999999`, `888888`
o `777777` (cuentas genéricas/de servicio).

### Especificación

```gherkin
Dado un registro de usuario de Active Directory con campo employeeID
Cuando DataSync procesa el registro
Entonces se sincroniza solo si employeeID.Length = 7
  Y los primeros 6 caracteres NO están en (999999, 888888, 777777)
  En caso contrario el registro se descarta
```

### Parámetros

| Parámetro              | Valor                          |
| ---------------------- | ------------------------------ |
| Longitud de employeeID | 7 (exacta)                     |
| Prefijos excluidos     | `999999`, `888888`, `777777`   |

### Casos borde

- `employeeID` nulo o vacío → descartado.
- `employeeID` de longitud distinta de 7 → descartado.
- Registros AD incompletos / importación masiva.

---

## RULE-002: Estrategia crear-o-actualizar (merge AD → SICA)

- **Categoría**: Ciclo de vida
- **Prioridad**: P1
- **Fuente**: [DataSync.vb:212-224](../../../demo/from_old_src/SICADataSync/DataSync.vb)
- **Confianza**: Alta

### En lenguaje natural

Al sincronizar un usuario de AD, se busca en SICA un registro con el mismo `codelogique`
(igual al `employeeID` de AD). Si no existe, se crea (`NovoUtilizadorSICA`); si existe,
se actualiza (`ActualizaUtilizadorSICA`). El `codelogique` es la clave natural de unión.

### Especificación

```gherkin
Dado un usuario de AD con employeeID válido
Cuando se busca en SICA por codelogique = employeeID
Entonces si el conjunto de resultados tiene longitud 0
  Se invoca NovoUtilizadorSICA()
Y si el conjunto de resultados tiene longitud > 0
  Se invoca ActualizaUtilizadorSICA()
```

### Parámetros

| Parámetro       | Valor                              |
| --------------- | ---------------------------------- |
| Clave de unión  | `codelogique` (= AD `employeeID`)  |

### Casos borde

- Duplicados de `codelogique` en SICA (no contemplado explícitamente).
- Cambio de `employeeID` en AD → se crearía un usuario nuevo en lugar de actualizar.

---

## RULE-003: Segmentación por organización (multi-tenant)

- **Categoría**: Política
- **Prioridad**: P0
- **Fuente**: [DataSync.vb:211](../../../demo/from_old_src/SICADataSync/DataSync.vb),
  enum en [DataSync.vb:425](../../../demo/from_old_src/SICADataSync/DataSync.vb)
- **Confianza**: Alta

### En lenguaje natural

Los usuarios se filtran por el campo `company` de AD, que se corresponde con la organización
que se está procesando. Cada organización tiene un identificador numérico fijo.

### Especificación

```gherkin
Dado un bosque de AD con múltiples organizaciones
Cuando se invoca ProcessaActualizacoesPorEmpresa(emp)
Entonces solo se sincronizan usuarios donde company = empresaAProcessar
```

### Parámetros

| Organización          | ID (enum) | Variante "Cessado" |
| --------------------- | --------- | ------------------ |
| REFER                 | 4         | 1653               |
| REFERTelecom          | 1480      | 1654               |
| REFERPatrimonio       | 1656      | 1657               |
| REFEREngineering      | 1658      | 1659               |

### Casos borde

- Usuario sin `company` o con valor desconocido → no se asocia a ninguna organización.
- Las variantes `Cessado` están definidas pero su uso aparece comentado (ver
  [ASSESSMENT.md §5](ASSESSMENT.md#5-candidatos-a-código-muerto)).

> ❓ **Pregunta a SME**: ¿Deben las variantes `*Cessado` desactivar usuarios o son código muerto?

---

## RULE-004: Clasificación de tipo de tarjeta por prefijo

- **Categoría**: Validación
- **Prioridad**: P1
- **Fuente**: [DataSync.vb:246-261](../../../demo/from_old_src/SICADataSync/DataSync.vb)
- **Confianza**: Alta

### En lenguaje natural

El tipo de una tarjeta se determina por el primer carácter de su código (`codelogique`).
Se reconocen 5 tipos; cualquier otro prefijo se trata como Visitante (1) por defecto.

### Especificación

```gherkin
Dado un código de tarjeta (p. ej. "V12345")
Cuando se extrae el primer carácter con Substring(0, 1)
Entonces se mapea a idTipoCartao según la tabla de prefijos
```

### Parámetros

| Prefijo | idTipoCartao | Tipo         |
| ------- | ------------ | ------------ |
| `V`     | 1            | Visitante    |
| `M`     | 2            | Mantenimiento|
| `C`     | 3            | Corporativo  |
| `R`     | 4            | Restringido  |
| `A`     | 5            | Admin        |
| (otro)  | 1            | Visitante (default) |

### Casos borde

- Código vacío → `Substring(0,1)` lanzaría excepción (sin manejo explícito).
- Prefijo en minúscula → caería en el `Case Else` (default Visitante).

---

## RULE-005: Sincronización de tarjetas a SICAWeb

- **Categoría**: Ciclo de vida
- **Prioridad**: P1
- **Fuente**: [DataSync.vb:245-273](../../../demo/from_old_src/SICADataSync/DataSync.vb)
- **Confianza**: Alta

### En lenguaje natural

Las tarjetas activas (`supprime = 0`) de la tabla `Badge` cuyo `codelogique` empieza por
`C`, `V`, `M`, `A` o `R` se sincronizan a `SICA.tblCartoes`. Las que ya existen se omiten
(no duplicación). La descripción de la tarjeta toma el nombre (`prenom`) del usuario.

### Especificación

```gherkin
Dado los badges activos (supprime = 0) cuyo codelogique empieza por (C|V|M|A|R)
Cuando se comprueba si NumCartao ya existe en tblCartoes
Entonces si no existe
  Se inserta (NumCartao, Decricao = prenom, Tipo = idTipoCartao)
Y si existe
  Se omite
```

### Parámetros

| Parámetro          | Valor                                  |
| ------------------ | -------------------------------------- |
| Filtro de prefijos | `C`, `V`, `M`, `A`, `R`                |
| Filtro de estado   | `supprime = 0` (activo)                |

### Casos borde / riesgos

- ⚠️ **Inyección SQL** en el `INSERT`:
  [DataSync.vb:264-266](../../../demo/from_old_src/SICADataSync/DataSync.vb) concatena
  `codelogique` y `prenom` sin parametrizar.
- `prenom` con apóstrofo rompería la consulta o permitiría inyección.

---

## RULE-006: Filtro de disponibilidad de tarjeta de visitante

- **Categoría**: Ciclo de vida
- **Prioridad**: P1
- **Fuente**: [ActivarCartoes.ascx.vb:46-79](../../../demo/from_old_src/SICAWeb/SICAWeb/ActivarCartoes.ascx.vb)
- **Confianza**: Alta

### En lenguaje natural

Una tarjeta de visitante se considera "disponible" solo si tiene hora de salida registrada
(`HoraSaida`) **o** si no tiene ni hora de entrada ni de salida (nunca usada). Si tiene
entrada pero no salida, está en uso y no se ofrece.

### Especificación

```gherkin
Dada una tarjeta de vwREFERVisitantes
Cuando se evalúa su disponibilidad por NumCartao
Entonces si HoraSaida.Length > 0 (ya salió)
  Se marca como disponible
Y si HoraEntrada.Length = 0 Y HoraSaida.Length = 0 (nunca usada)
  Se marca como disponible
Y si tiene HoraEntrada pero HoraSaida vacía (en uso)
  NO se marca como disponible
```

### Casos borde

- Datos inconsistentes (salida sin entrada) → se trataría como disponible.

---

## RULE-007: Ventana de validez de tarjeta de visitante

- **Categoría**: Política
- **Prioridad**: P1
- **Fuente**: [ActivarCartoes.ascx.vb:10](../../../demo/from_old_src/SICAWeb/SICAWeb/ActivarCartoes.ascx.vb)
- **Confianza**: Media

### En lenguaje natural

Al activar una tarjeta de visitante se establece una fecha de validez (`ValidadeCartao`)
con la fecha actual (`FormataData(Now)`). No se observa una validación posterior que impida
el acceso si la tarjeta ha caducado.

### Especificación

```gherkin
Dada la activación de una tarjeta de visitante
Cuando se asigna ValidadeCartao = FormataData(Now)
Entonces la validez se fija a la fecha de hoy
  Pero no se observa enforcement de caducidad en el flujo de entrada
```

### Casos borde

- Sin validación visible de "tarjeta aún válida" en la entrada.

> ❓ **Pregunta a SME**: ¿`ValidadeCartao` es fecha de inicio o de caducidad? ¿Dónde se
> valida la caducidad en la entrada física?

---

## RULE-008: Autorización por lista blanca de terminal

- **Categoría**: Política
- **Prioridad**: P0
- **Fuente**: [Default.aspx.vb:7-21](../../../demo/from_old_src/SICAWeb/SICAWeb/Default.aspx.vb)
- **Confianza**: Alta

### En lenguaje natural

Solo los terminales (PCs/clientes) registrados en `tblTerminais` por hostname **o** IP
obtienen acceso a SICAWeb. La comprobación se hace en la primera carga de página y el nombre
del terminal se guarda en sesión (`Session("NomeTerminal")`) para acotar el acceso a tarjetas.

### Especificación

```gherkin
Dada una petición de carga desde un PC cliente
Cuando se consulta tblTerminais por hostname o IP del cliente
Entonces si hay al menos 1 resultado
  Se concede acceso y se guarda el nombre del terminal en sesión
Y si no hay resultados
  Se deniega el acceso (se devuelve cadena vacía)
```

### Parámetros

| Parámetro          | Valor                              |
| ------------------ | ---------------------------------- |
| Tabla              | `tblTerminais`                     |
| Criterios          | `upper(nome) = hostname` o `ip = IP` |
| Variable de sesión | `Session("NomeTerminal")`          |

### Casos borde / riesgos

- 🔴 **Inyección SQL CRÍTICA** en
  [Default.aspx.vb:12](../../../demo/from_old_src/SICAWeb/SICAWeb/Default.aspx.vb): `NomePC`
  e `IP` se concatenan sin parametrizar. Es la **única** frontera de autorización efectiva,
  por lo que su bypass otorga acceso total.
- La autorización es por terminal, no por usuario (sin RBAC).

---

## RULE-009: Extracción del principal de Windows Auth

- **Categoría**: Autenticación
- **Prioridad**: P0
- **Fuente**: [Default.aspx.vb:38-44](../../../demo/from_old_src/SICAWeb/SICAWeb/Default.aspx.vb)
- **Confianza**: Alta

### En lenguaje natural

SICAWeb usa autenticación integrada de Windows (`LOGON_USER`). El nombre de usuario de la
sesión se obtiene eliminando el prefijo de dominio y conservando solo la cuenta SAM.

### Especificación

```gherkin
Dado Request.ServerVariables("LOGON_USER") = "REFER\usuario"
Cuando la longitud de la cadena es > 1
Entonces Session("Utilizador") = subcadena tras el primer "\" → "usuario"
Y si la longitud es <= 1
  Session("Utilizador") = ""
```

### Casos borde

- `LOGON_USER` sin `\` → comportamiento dependiente del índice (`IndexOf("\")`).
- Cadena vacía → `Session("Utilizador") = ""` (sesión sin usuario identificado).
- Sin MFA; depende únicamente de las credenciales de Windows.

---

## Confianza y gaps

- **Confianza global**: Alta para RULE-001 a 006, 008, 009 (extraídas de bloques explícitos
  `SELECT CASE` / `IF` / consultas SQL y verificadas con `fichero:línea`). Media para RULE-007.
- **Gaps / preguntas a SME**:
  - RULE-003: uso real de variantes `*Cessado`.
  - RULE-007: semántica de `ValidadeCartao` y dónde se valida la caducidad.
  - Reglas de alarmas, históricos y monitorización (`Alarmes.ascx`, `MonSeg.aspx`,
    `Historico.ascx`) **no analizadas en profundidad** — pendientes de una segunda pasada.
  - Significado de los IDs de evento filtrados `249 / 253 / 255` en los logs de circuito.
- **Comportamiento contrato (P0)**: RULE-001, RULE-003, RULE-008, RULE-009 deben pinearse con
  tests de caracterización antes de reescribir (ver `skill-characterization-testing`).
