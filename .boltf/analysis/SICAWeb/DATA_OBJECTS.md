# DATA OBJECTS — SICAWeb (Legacy)

> **Fase Bolt**: DISCOVERY (brownfield)
> **Fecha**: 2026-06-24
> **Fuente**: `demo/from_old_src/SICAWeb/SICAWeb/`

---

## Tablas propias (BD SICA_V2)

### tblTerminais
| Campo | Tipo inferido | Notas |
|---|---|---|
| ID | int (PK) | Identificador interno |
| Nome | nvarchar | Nombre de equipo (hostname) — búsqueda case-insensitive |
| IP | nvarchar | Dirección IP del terminal |
| Descricao | nvarchar | Descripción legible |

**Reglas que la usan:** RULE-001  
**Vistas relacionadas:** `vwTerminais` (expone ID, Nome, Descricao)

---

### tblCartoes
| Campo | Tipo inferido | Notas |
|---|---|---|
| ID | int/nvarchar (PK) | = idSmartCard del SMI |
| NumCartao | nvarchar | Código lógico de la tarjeta |
| Decricao | nvarchar(50) | Descripción (Label de SMI, truncado a 50) |

**Reglas que la usan:** RULE-004, RULE-008  
**Vistas relacionadas:** `vwCartoes` (añade IPTerminal, NomeTerminal)

---

### tblFamilias
| Campo | Tipo inferido | Notas |
|---|---|---|
| ID | int (PK) | = idFamily del SMI |
| Nome | nvarchar(50) | Label de SMI, truncado |

**Reglas que la usan:** RULE-005  
**Vistas relacionadas:** `vwFamilias` (añade IDFamilia, NomeTerminal)

---

### tblCircuitos
| Campo | Tipo inferido | Notas |
|---|---|---|
| ID | int (PK) | = idCircuit del SMI |
| Nome | nvarchar(50) | Label del SMI, truncado |
| IDCircuitoGrupo | int | Auto-seteado a ID en el bootstrap (RULE-006) |

**Reglas que la usan:** RULE-006, RULE-010

---

### tblCartoesTerminal
| Campo | Tipo inferido | Notas |
|---|---|---|
| IDCartao | int (FK → tblCartoes) | |
| IDTerminal | int (FK → tblTerminais) | |

**Reglas que la usan:** RULE-007

---

### tblFamiliasTerminal
| Campo | Tipo inferido | Notas |
|---|---|---|
| IDFamilia | int (FK → tblFamilias) | |
| IDTerminal | int (FK → tblTerminais) | |

**Reglas que la usan:** RULE-007

---

### tblCircuitosTerminal
| Campo | Tipo inferido | Notas |
|---|---|---|
| IDCircuito | int (FK → tblCircuitos) | |
| IDTerminal | int (FK → tblTerminais) | |

**Reglas que la usan:** RULE-007

---

### tblVisitantes
| Campo | Tipo inferido | Notas |
|---|---|---|
| ID | int (PK) | |
| IDTipoVisitante | int | Tipo (radio button: externo, empleado, etc.) |
| NomeVisitante | nvarchar | Puede ser NULL |
| EmpresaVisitante | nvarchar | Puede ser NULL |
| EntidadeVisitada | nvarchar | Puede ser NULL |
| NumEmpregado | nvarchar | Puede ser NULL |
| MatriculaViatura | nvarchar | Puede ser NULL |
| HoraEntrada | time/datetime | Puede ser NULL |
| HoraSaida | time/datetime | Puede ser NULL |

**Reglas que la usan:** RULE-009, RULE-013, RULE-014  
**SPs relacionados:** `sp_tblVisitantes_SelectAtribuidosByNomeTerminal(@NomeTerminal)`, `sp_tblVisitantes_SelectUltimaAtribuicao(@NumCartao)`

---

### tblLog
| Campo | Tipo inferido | Notas |
|---|---|---|
| ID | int (PK, autoincrement) | |
| Texto | nvarchar | Descripción del evento |
| Cartao | nvarchar | Número de tarjeta (opcional) |
| Terminal | nvarchar | NomeTerminal de la sesión |
| Utilizador | nvarchar | Username del operador |
| [Fecha] | datetime | Inferida — no confirmada en SP |

**Reglas que la usan:** RULE-017  
**SPs:** `sp_tblLog_Insert(@Texto, @Cartao, @Terminal, @Utilizador)`

---

## Vistas propias (BD SICA_V2)

| Vista | Campos conocidos | Uso |
|---|---|---|
| `vwTerminais` | ID, Nome, Descricao | Acessos.ascx — dropdown terminales |
| `vwCartoes` | NumCartao, IPTerminal, NomeTerminal | Visitantes.ascx — cartões por terminal |
| `vwFamilias` | IDFamilia, NomeTerminal | ActivarCartoes.ascx, Visitantes.ascx |
| `vwAcessos` | IDCartao, NumCartao, NomeTerminal | DetalheVisitante.ascx — autorización |

---

## Tablas externas — BD ActiveDirectory (rfsql01)

### tblAD_AD_SQL
| Campo | Tipo inferido | Notas |
|---|---|---|
| employeeID | nvarchar | Número de empleado (= LogicalCode de la tarjeta) |
| wWWHomePage | nvarchar | URL de la foto del empleado |

**Reglas que la usan:** RULE-013 (implícita — lookup de foto)  
**Módulo:** `DetalheUtilizador.ascx.vb:49`

---

## Vistas externas — BD Alizes/REFER

| Vista | Campos conocidos | Uso |
|---|---|---|
| `vwREFERFamilias` | ID, Nome | ActivarCartoes.ascx — familias para visitante |
| `vwREFERVisitantes` | NumCartao, Nome, IDCampo, TipoValor, ValorTipo1, ValorTipo2, ValorTipo3, ValidadeCartao | ActivarCartoes.ascx — tarjetas disponibles |
| `vwREFERLog` | idevenement, idcircuit, dat, codelogique, parametre, Prenom, nom, libellecircuit, descriptioncircuit | LogHistorico.ascx — movimientos históricos |
| `vwREFERCircuitos` | idcircuit, Descricao | LogHistorico.ascx — selector circuitos |

---

## DTOs del servicio SMI (SMIMethodsWebService)

### SmartCardProperties
| Campo | Tipo | Notas |
|---|---|---|
| idSmartCard | int/string | PK en SMI |
| LogicalCode | string | NumCartao equivalente |
| Label | string | Descripción |
| ExpirationDate | DateTime | Fecha de expiración |
| Status | SmartCardStatus | Enum: Active=2, Forbiden=4, Lost=8, Stolen=16, Destroied=32 |
| idUser | string | ID del usuario asignado en SMI |

### Family
| Campo | Tipo | Notas |
|---|---|---|
| idFamily | int | PK en SMI |
| Label | string | Nombre de la familia |

### CircuitProperties
| Campo | Tipo | Notas |
|---|---|---|
| idCircuit | int | PK en SMI |
| Label | string | Nombre del circuito |

### EventProperties
| Campo | Tipo | Notas |
|---|---|---|
| LogicalCode | string | Código lógico de tarjeta |
| Name | string | Nombre del titular |
| Company | string | Empresa |
| DateTime | string | Fecha/hora del evento |
| GeoZone | string | Zona geográfica |

### UserFamilies
| Campo | Tipo | Notas |
|---|---|---|
| idFamily | int | FK → Family |

### ZoneCount (inferido de CountUsersByZone)
| Campo | Tipo | Notas |
|---|---|---|
| [IDZona] | int | Identificador de zona |
| [Count] | int | Número de personas presentes |

---

## Struct internas (code-behind — no persistidas)

### InfoCartao (ActivarCartoes.ascx.vb)
```vb
Structure InfoCartao
    NumCartao    As String
    Descricao    As String
    HoraEntrada  As String
    HoraSaida    As String
    ValidadeCartao As Date
End Structure
```
**Uso:** Construcción de la tabla de tarjetas disponibles en memoria antes de bindear al GridView.

### InfoCartao (Visitantes.ascx.vb — distinta a la anterior)
```vb
Structure InfoCartao
    NumCartao    As String
    Visitante    As String
    HoraEntrada  As String
    HoraSaida    As String
    ValidadeCartao As Date
End Structure
```
**Nota:** Hay dos `InfoCartao` distintos definidos en dos clases diferentes — duplicación de concepto.

---

## Mapa de reglas → objetos de datos

| Regla | Entidades afectadas |
|---|---|
| RULE-001 | tblTerminais |
| RULE-002 | Session (Utilizador) |
| RULE-003 | Session (Utilizador), appSettings |
| RULE-004 | tblCartoes, SMI:SmartCardProperties |
| RULE-005 | tblFamilias, SMI:Family |
| RULE-006 | tblCircuitos, SMI:CircuitProperties |
| RULE-007 | tblCartoesTerminal, tblFamiliasTerminal, tblCircuitosTerminal |
| RULE-008 | vwREFERVisitantes, Session(CartoesTerminal), InfoCartao |
| RULE-009 | tblVisitantes, SMI:SmartCardProperties, SMI:UserFamilies |
| RULE-010 | tblCircuitos, SMI:CircuitProperties, SMI:EventProperties |
| RULE-011 | vwREFERLog |
| RULE-012 | vwREFERLog |
| RULE-013 | vwAcessos, tblLog |
| RULE-014 | tblVisitantes, SMI:SmartCardProperties |
| RULE-015 | SMI:SmartCardStatus |
| RULE-016 | appSettings (intervalos) |
| RULE-017 | tblLog |
