# Data Model — Migración SICAWeb

> **Feature**: 001-migracion-sica
> **Fase Bolt**: REASON (Planning)
> **Fecha**: 2026-06-24
> **Fuente**: DDD domain models + análisis legacy

---

## 1. Estrategia de datos

### 1.1 Migración de esquema

| Decisión | Elección |
|---|---|
| **Estrategia** | **Incremental** — migrar tablas por bounded context |
| **ORM** | Entity Framework Core 8 con Migrations |
| **Naming** | PascalCase (C#) en dominio, snake_case en BD (convención Azure) |
| **Soft delete** | Sí — columna `IsDeleted` + índice filtrado |
| **Audit** | Sí — `CreatedAt`, `CreatedBy`, `ModifiedAt`, `ModifiedBy` |
| **Multitenancy** | Futuro — columna `OrganizationId` (preparado, no implementado en MVP) |

### 1.2 Compatibilidad con legacy

Durante Strangler Fig, **ambos sistemas** (legacy WebForms + nueva API) acceden a la
misma BD. Estrategia:

- **Fase 1-2**: Legacy + API leen/escriben en tablas originales (`tbl*`, `vw*`).
- **Fase 3**: Nueva API migra datos a nuevas tablas (`sica.*`), legacy pasa a read-only via vistas de compatibilidad.
- **Fase 4**: Decomisión legacy, drop de tablas antiguas.

**Vistas de compatibilidad** (fase 3):
```sql
CREATE VIEW dbo.vwTerminais AS
SELECT Id, Hostname AS Nome, Description AS Descricao
FROM sica.Terminals;
```

---

## 2. Bounded Context: Identity & Access Management

### 2.1 Aggregate: User

**Tabla**: `sica.Users`

| Columna | Tipo | Constraints | Notas |
|---|---|---|---|
| `Id` | uniqueidentifier | PK, default newid() | GUID para evitar colisión en sync AD |
| `LogicalCode` | nvarchar(50) | UNIQUE, NOT NULL | Código lógico único (ej: empleado 7 dígitos) |
| `UserType` | nvarchar(20) | NOT NULL | 'Employee' \| 'Visitor' (discriminador) |
| `EmployeeId` | nvarchar(7) | NULL, UNIQUE (si Employee) | Número de empleado |
| `FirstName` | nvarchar(100) | NOT NULL | |
| `LastName` | nvarchar(100) | NOT NULL | |
| `Email` | nvarchar(255) | NULL | |
| `PhotoUrl` | nvarchar(500) | NULL | URL foto (migrado de AD.wWWHomePage) |
| `OrganizationId` | uniqueidentifier | NULL, FK | Preparado para multitenancy |
| `IsActive` | bit | NOT NULL, default 1 | |
| `IsDeleted` | bit | NOT NULL, default 0 | Soft delete |
| `CreatedAt` | datetime2 | NOT NULL, default getutcdate() | |
| `CreatedBy` | nvarchar(255) | NULL | |
| `ModifiedAt` | datetime2 | NULL | |
| `ModifiedBy` | nvarchar(255) | NULL | |

**Índices**:
```sql
CREATE UNIQUE INDEX IX_Users_LogicalCode ON sica.Users(LogicalCode) WHERE IsDeleted = 0;
CREATE INDEX IX_Users_EmployeeId ON sica.Users(EmployeeId) WHERE IsDeleted = 0 AND UserType = 'Employee';
CREATE INDEX IX_Users_OrganizationId ON sica.Users(OrganizationId) WHERE IsDeleted = 0;
```

**Mapeo legacy**:
- Legacy no tiene tabla `Users` unificada — se infiere de `vwREFERVisitantes` (visitantes) + AD (empleados).
- Nueva tabla centraliza ambos tipos con discriminador `UserType`.

---

### 2.2 Aggregate: Terminal

**Tabla**: `sica.Terminals`

| Columna | Tipo | Constraints | Notas |
|---|---|---|---|
| `Id` | int | PK, IDENTITY(1,1) | |
| `Hostname` | nvarchar(100) | UNIQUE, NOT NULL | Mayúsculas automáticas |
| `IpAddress` | nvarchar(45) | NULL | IPv4 o IPv6 |
| `Description` | nvarchar(255) | NULL | |
| `IsActive` | bit | NOT NULL, default 1 | |
| `IsDeleted` | bit | NOT NULL, default 0 | |
| `CreatedAt` | datetime2 | NOT NULL, default getutcdate() | |
| `ModifiedAt` | datetime2 | NULL | |

**Índices**:
```sql
CREATE UNIQUE INDEX IX_Terminals_Hostname ON sica.Terminals(Hostname) WHERE IsDeleted = 0;
CREATE INDEX IX_Terminals_IpAddress ON sica.Terminals(IpAddress) WHERE IsDeleted = 0;
```

**Mapeo legacy**: `tblTerminais` (columnas: ID, Nome, IP, Descricao)

---

### 2.3 Aggregate: Session (no persistida)

Las sesiones se gestionan en **Azure AD B2C tokens** (no tabla SQL). El legacy usaba
`ASP.NET Session` (in-memory), que se elimina completamente.

---

## 3. Bounded Context: Card Management

### 3.1 Aggregate: SmartCard

**Tabla**: `sica.SmartCards`

| Columna | Tipo | Constraints | Notas |
|---|---|---|---|
| `Id` | uniqueidentifier | PK, default newid() | |
| `CardCode` | nvarchar(50) | UNIQUE, NOT NULL | Código lógico de tarjeta |
| `CardType` | nvarchar(20) | NOT NULL | 'Employee' \| 'Visitor' \| 'Service' (clasificado por prefijo) |
| `Label` | nvarchar(100) | NULL | Descripción |
| `Status` | nvarchar(20) | NOT NULL | 'Active' \| 'Inactive' \| 'Lost' \| 'Stolen' \| 'Destroyed' |
| `ExpirationDate` | datetime2 | NULL | |
| `OwnerId` | uniqueidentifier | NULL, FK → Users | |
| `SMICardId` | int | NULL, UNIQUE | ID en sistema SMI (sincronizado) |
| `IsDeleted` | bit | NOT NULL, default 0 | |
| `CreatedAt` | datetime2 | NOT NULL, default getutcdate() | |
| `ModifiedAt` | datetime2 | NULL | |

**Índices**:
```sql
CREATE UNIQUE INDEX IX_SmartCards_CardCode ON sica.SmartCards(CardCode) WHERE IsDeleted = 0;
CREATE INDEX IX_SmartCards_OwnerId ON sica.SmartCards(OwnerId) WHERE IsDeleted = 0;
CREATE UNIQUE INDEX IX_SmartCards_SMICardId ON sica.SmartCards(SMICardId) WHERE SMICardId IS NOT NULL;
```

**Mapeo legacy**: `tblCartoes` (columnas: ID, NumCartao, Decricao)

---

### 3.2 Aggregate: VisitorCard (extensión)

No hay tabla separada — `SmartCard` con `CardType = 'Visitor'` + tabla hija:

**Tabla**: `sica.VisitorCardAssignments`

| Columna | Tipo | Constraints | Notas |
|---|---|---|---|
| `Id` | uniqueidentifier | PK, default newid() | |
| `CardId` | uniqueidentifier | NOT NULL, FK → SmartCards | |
| `VisitorId` | uniqueidentifier | NOT NULL, FK → Users | User con UserType='Visitor' |
| `VisitedEntity` | nvarchar(255) | NULL | Entidad visitada |
| `Company` | nvarchar(255) | NULL | Empresa del visitante |
| `VehiclePlate` | nvarchar(20) | NULL | Matrícula |
| `EntryTime` | datetime2 | NULL | Hora entrada |
| `ExitTime` | datetime2 | NULL | Hora salida |
| `ValidFrom` | datetime2 | NOT NULL | Inicio ventana de validez |
| `ValidUntil` | datetime2 | NOT NULL | Fin ventana de validez |
| `CreatedAt` | datetime2 | NOT NULL, default getutcdate() | |
| `CreatedBy` | nvarchar(255) | NULL | |
| `ModifiedAt` | datetime2 | NULL | |

**Índices**:
```sql
CREATE INDEX IX_VisitorCardAssignments_CardId ON sica.VisitorCardAssignments(CardId);
CREATE INDEX IX_VisitorCardAssignments_VisitorId ON sica.VisitorCardAssignments(VisitorId);
CREATE INDEX IX_VisitorCardAssignments_EntryExit ON sica.VisitorCardAssignments(EntryTime, ExitTime);
```

**Mapeo legacy**: `tblVisitantes` (columnas: ID, IDTipoVisitante, NomeVisitante, EmpresaVisitante, EntidadeVisitada, NumEmpregado, MatriculaViatura, HoraEntrada, HoraSaida)

---

## 4. Bounded Context: Access Control

### 4.1 Aggregate: AccessFamily

**Tabla**: `sica.AccessFamilies`

| Columna | Tipo | Constraints | Notas |
|---|---|---|---|
| `Id` | uniqueidentifier | PK, default newid() | |
| `Name` | nvarchar(100) | UNIQUE, NOT NULL | |
| `SMIFamilyId` | int | NULL, UNIQUE | ID en sistema SMI |
| `IsDeleted` | bit | NOT NULL, default 0 | |
| `CreatedAt` | datetime2 | NOT NULL, default getutcdate() | |
| `ModifiedAt` | datetime2 | NULL | |

**Tabla de relación**: `sica.FamilyMemberships`

| Columna | Tipo | Constraints | Notas |
|---|---|---|---|
| `FamilyId` | uniqueidentifier | PK, FK → AccessFamilies | |
| `UserId` | uniqueidentifier | PK, FK → Users | |
| `AssignedAt` | datetime2 | NOT NULL, default getutcdate() | |

**Índices**:
```sql
CREATE INDEX IX_FamilyMemberships_UserId ON sica.FamilyMemberships(UserId);
```

**Mapeo legacy**: `tblFamilias` (ID, Nome) + `tblFamiliasTerminal` (relación terminal-familia, no usuario-familia — diferencia)

---

### 4.2 Aggregate: Circuit

**Tabla**: `sica.Circuits`

| Columna | Tipo | Constraints | Notas |
|---|---|---|---|
| `Id` | int | PK, IDENTITY(1,1) | |
| `Name` | nvarchar(100) | UNIQUE, NOT NULL | |
| `CircuitGroupId` | int | NULL, FK → Circuits (self) | Jerarquía de grupos |
| `SMICircuitId` | int | NULL, UNIQUE | ID en sistema SMI |
| `IsDeleted` | bit | NOT NULL, default 0 | |
| `CreatedAt` | datetime2 | NOT NULL, default getutcdate() | |
| `ModifiedAt` | datetime2 | NULL | |

**Índices**:
```sql
CREATE INDEX IX_Circuits_CircuitGroupId ON sica.Circuits(CircuitGroupId) WHERE CircuitGroupId IS NOT NULL;
CREATE UNIQUE INDEX IX_Circuits_SMICircuitId ON sica.Circuits(SMICircuitId) WHERE SMICircuitId IS NOT NULL;
```

**Mapeo legacy**: `tblCircuitos` (ID, Nome, IDCircuitoGrupo)

---

### 4.3 Aggregate: AccessPolicy

**Tabla**: `sica.TerminalAccessPolicies`

| Columna | Tipo | Constraints | Notas |
|---|---|---|---|
| `Id` | uniqueidentifier | PK, default newid() | |
| `TerminalId` | int | NOT NULL, FK → Terminals | |
| `IsDeleted` | bit | NOT NULL, default 0 | |
| `CreatedAt` | datetime2 | NOT NULL, default getutcdate() | |
| `ModifiedAt` | datetime2 | NULL | |

**Tabla de relación triple**: `sica.TerminalPolicyRules`

| Columna | Tipo | Constraints | Notas |
|---|---|---|---|
| `PolicyId` | uniqueidentifier | PK, FK → TerminalAccessPolicies | |
| `FamilyId` | uniqueidentifier | PK, FK → AccessFamilies | |
| `CircuitId` | int | PK, FK → Circuits | |

**Constraint**:
```sql
ALTER TABLE sica.TerminalPolicyRules
ADD CONSTRAINT UQ_TerminalPolicy_FamilyCircuit UNIQUE (PolicyId, FamilyId, CircuitId);
```

**Mapeo legacy**: `tblCartoesTerminal`, `tblFamiliasTerminal`, `tblCircuitosTerminal` (3 tablas separadas → unificadas en modelo policy)

---

## 5. Bounded Context: Physical Access Monitoring

### 5.1 Aggregate: AccessEvent (read-only desde SMI)

**Tabla**: `sica.AccessEvents`

| Columna | Tipo | Constraints | Notas |
|---|---|---|---|
| `Id` | uniqueidentifier | PK, default newid() | |
| `CircuitId` | int | NOT NULL, FK → Circuits | |
| `CardCode` | nvarchar(50) | NOT NULL | |
| `UserId` | uniqueidentifier | NULL, FK → Users | Resuelto a posteriori |
| `EventType` | nvarchar(20) | NOT NULL | 'Entry' \| 'Exit' \| 'AccessDenied' |
| `Timestamp` | datetime2 | NOT NULL | Timestamp del SMI |
| `SMIEventId` | int | NULL, UNIQUE | ID en sistema SMI |
| `CreatedAt` | datetime2 | NOT NULL, default getutcdate() | |

**Índices**:
```sql
CREATE INDEX IX_AccessEvents_CircuitId_Timestamp ON sica.AccessEvents(CircuitId, Timestamp DESC);
CREATE INDEX IX_AccessEvents_UserId_Timestamp ON sica.AccessEvents(UserId, Timestamp DESC) WHERE UserId IS NOT NULL;
CREATE INDEX IX_AccessEvents_Timestamp ON sica.AccessEvents(Timestamp DESC);
```

**Mapeo legacy**: No hay tabla legacy — los eventos se consultan directamente del SMI via `GetLastCircuitEvents()` y `vwREFERLog` (BD Alizes).

---

### 5.2 Aggregate: Alarm (futuro, no MVP)

**Tabla**: `sica.Alarms` (preparada, no implementada en Fase 2)

| Columna | Tipo | Constraints | Notas |
|---|---|---|---|
| `Id` | uniqueidentifier | PK, default newid() | |
| `AlarmType` | nvarchar(50) | NOT NULL | 'ForcedEntry' \| 'TailgatingDetected' \| 'SystemFailure' |
| `CircuitId` | int | NULL, FK → Circuits | |
| `Timestamp` | datetime2 | NOT NULL | |
| `Status` | nvarchar(20) | NOT NULL | 'Active' \| 'Acknowledged' \| 'Resolved' |
| `AcknowledgedBy` | uniqueidentifier | NULL, FK → Users | |
| `AcknowledgedAt` | datetime2 | NULL | |
| `CreatedAt` | datetime2 | NOT NULL, default getutcdate() | |

---

## 6. Tabla transversal: AuditLog

**Tabla**: `sica.AuditLogs`

| Columna | Tipo | Constraints | Notas |
|---|---|---|---|
| `Id` | bigint | PK, IDENTITY(1,1) | |
| `EventType` | nvarchar(50) | NOT NULL | 'CardAssigned', 'PolicyUpdated', 'TerminalAuthorized', etc. |
| `EntityType` | nvarchar(50) | NULL | 'SmartCard', 'Terminal', 'User' |
| `EntityId` | nvarchar(50) | NULL | GUID o int como string |
| `Message` | nvarchar(max) | NOT NULL | |
| `TerminalId` | int | NULL, FK → Terminals | Terminal donde ocurrió (si aplica) |
| `UserId` | uniqueidentifier | NULL, FK → Users | Usuario responsable |
| `Timestamp` | datetime2 | NOT NULL, default getutcdate() | |

**Índices**:
```sql
CREATE INDEX IX_AuditLogs_Timestamp ON sica.AuditLogs(Timestamp DESC);
CREATE INDEX IX_AuditLogs_EntityType_EntityId ON sica.AuditLogs(EntityType, EntityId);
```

**Mapeo legacy**: `tblLog` (columnas: ID, Texto, Cartao, Terminal, Utilizador, [Fecha])

---

## 7. Vistas de compatibilidad (Fase 3)

Creadas para mantener legacy read-only mientras nueva API es activa:

```sql
-- Vista: vwTerminais (compatible con legacy)
CREATE VIEW dbo.vwTerminais AS
SELECT 
    Id,
    Hostname AS Nome,
    Description AS Descricao
FROM sica.Terminals
WHERE IsDeleted = 0;

-- Vista: vwCartoes (compatible con legacy)
CREATE VIEW dbo.vwCartoes AS
SELECT 
    sc.CardCode AS NumCartao,
    t.IpAddress AS IPTerminal,
    t.Hostname AS NomeTerminal
FROM sica.SmartCards sc
LEFT JOIN sica.VisitorCardAssignments vca ON vca.CardId = sc.Id
LEFT JOIN sica.TerminalPolicyRules tpr ON tpr.FamilyId IN (
    SELECT FamilyId FROM sica.FamilyMemberships WHERE UserId = sc.OwnerId
)
LEFT JOIN sica.Terminals t ON t.Id = tpr.PolicyId -- simplificado
WHERE sc.IsDeleted = 0;
```

---

## 8. Diagrama ER consolidado

```mermaid
erDiagram
    Users ||--o{ SmartCards : owns
    Users ||--o{ FamilyMemberships : belongs_to
    Users ||--o{ VisitorCardAssignments : visitor
    Users ||--o{ AccessEvents : performed_by
    Users ||--o{ AuditLogs : responsible

    SmartCards ||--o{ VisitorCardAssignments : assigned
    SmartCards }o--|| AccessFamilies : via_membership

    Terminals ||--o{ TerminalAccessPolicies : has
    Terminals ||--o{ AuditLogs : source

    AccessFamilies ||--o{ FamilyMemberships : includes
    AccessFamilies ||--o{ TerminalPolicyRules : grants

    Circuits ||--o{ TerminalPolicyRules : secured_by
    Circuits ||--o{ AccessEvents : occurred_at
    Circuits ||--o| Circuits : grouped_in

    TerminalAccessPolicies ||--o{ TerminalPolicyRules : defines

    Users {
        uniqueidentifier Id PK
        nvarchar LogicalCode UK
        nvarchar UserType
        nvarchar EmployeeId UK
    }

    Terminals {
        int Id PK
        nvarchar Hostname UK
        nvarchar IpAddress
    }

    SmartCards {
        uniqueidentifier Id PK
        nvarchar CardCode UK
        nvarchar CardType
        nvarchar Status
        uniqueidentifier OwnerId FK
    }

    AccessFamilies {
        uniqueidentifier Id PK
        nvarchar Name UK
        int SMIFamilyId UK
    }

    Circuits {
        int Id PK
        nvarchar Name UK
        int CircuitGroupId FK
    }

    TerminalAccessPolicies {
        uniqueidentifier Id PK
        int TerminalId FK
    }

    TerminalPolicyRules {
        uniqueidentifier PolicyId PK_FK
        uniqueidentifier FamilyId PK_FK
        int CircuitId PK_FK
    }

    VisitorCardAssignments {
        uniqueidentifier Id PK
        uniqueidentifier CardId FK
        uniqueidentifier VisitorId FK
        datetime2 EntryTime
        datetime2 ExitTime
    }

    AccessEvents {
        uniqueidentifier Id PK
        int CircuitId FK
        nvarchar CardCode
        nvarchar EventType
        datetime2 Timestamp
    }

    AuditLogs {
        bigint Id PK
        nvarchar EventType
        datetime2 Timestamp
    }
```

---

## 9. Migrations plan

| Migration | Descripción |
|---|---|
| `01_InitialSchema` | Crea esquema `sica` + tablas core (Users, Terminals, SmartCards, AccessFamilies, Circuits) |
| `02_AccessControl` | Crea TerminalAccessPolicies + TerminalPolicyRules |
| `03_VisitorManagement` | Crea VisitorCardAssignments + FamilyMemberships |
| `04_Monitoring` | Crea AccessEvents + índices de performance |
| `05_Audit` | Crea AuditLogs |
| `06_CompatibilityViews` | Crea vistas `dbo.vw*` para compatibilidad legacy |

---

## 10. Seeding de datos legacy

| Tabla | Fuente legacy | Estrategia |
|---|---|---|
| `Terminals` | `tblTerminais` | Migración directa via EF |
| `SmartCards` | `tblCartoes` + SMI sync | Migración + clasificación por prefijo CardCode |
| `AccessFamilies` | `tblFamilias` | Migración directa |
| `Circuits` | `tblCircuitos` | Migración directa + resolver jerarquía |
| `Users` (Employee) | AD replica (`tblAD_AD_SQL`) | Importación batch, mapear EmployeeId → LogicalCode |
| `Users` (Visitor) | `tblVisitantes` (últimos 90 días) | Importación filtrada |
| `TerminalAccessPolicies` | Reconstruir de `tblCartoesTerminal`, `tblFamiliasTerminal`, `tblCircuitosTerminal` | Script de migración complejo |
