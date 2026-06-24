# SICA — Topología del Sistema Legacy

> **Sistema**: SICA (Sistema Integrado de Controlo de Acessos)
> **Fase Bolt**: DISCOVERY (brownfield)
> **Fuente**: `demo/from_old_src/`
> **Propósito**: Mapa de componentes, call graph, data lineage y ruta crítica.

---

## 1. Contexto del sistema (C4 — nivel 1)

```mermaid
flowchart TB
    AD["Active Directory<br/>refer.pt"]
    SMTP["SMTP<br/>hubmail.refer.pt"]
    Alizes[("BD Alizes<br/>rfsql01 · maestra")]
    SICA[("BD SICA<br/>rfsql01 · sombra")]

    subgraph Legacy["Sistema SICA (legacy)"]
        DataSync["SICADataSync<br/>(App VB.NET)"]
        SICAWeb["SICAWeb<br/>(ASP.NET WebForms)"]
        SMI["wsSMIServer<br/>(ASMX SOAP)"]
    end

    Guard["Operador de seguridad<br/>(terminal)"]

    AD -->|LDAP read| DataSync
    DataSync -->|sync usuarios/tarjetas| Alizes
    DataSync -->|cache tarjetas| SICA
    DataSync -->|informe| SMTP
    Guard -->|HTTP / Windows Auth| SICAWeb
    SICAWeb -->|lee config/terminal| SICA
    SICAWeb -->|SOAP| SMI
    SMI -->|consultas| Alizes
```

---

## 2. Componentes y puntos de entrada (call graph)

Los puntos de entrada se resaltan con **negrita**. Severidad de seguridad entre paréntesis.

```mermaid
flowchart LR
    subgraph DS["SICADataSync"]
        direction TB
        Run["**cmdRun_Click**<br/>DataSync.vb:10 (P0)"]
        Proc["ProcessaActualizacoes<br/>DataSync.vb:159"]
        ProcEmp["ProcessaActualizacoesPorEmpresa<br/>DataSync.vb:211"]
        NewU["NovoUtilizadorSICA"]
        UpdU["ActualizaUtilizadorSICA"]
        SyncC["SincronizaCartoesParaSICAWeb<br/>DataSync.vb:245"]
        AD["ADMethods.LeUtilizadoresREFER<br/>ADMethods.vb"]
        Run --> Proc --> ProcEmp
        ProcEmp --> AD
        ProcEmp --> NewU
        ProcEmp --> UpdU
        ProcEmp --> SyncC
    end

    subgraph WEB["SICAWeb"]
        direction TB
        Def["**Default.Page_Load**<br/>Default.aspx.vb:37 (P0)"]
        Verif["VerificaAcesso<br/>Default.aspx.vb:7 (P0 SQLi)"]
        Acc["**Acessos.ascx**<br/>Acessos.ascx.vb (P1)"]
        Act["**ActivarCartoes.ascx**<br/>ActivarCartoes.ascx.vb (P1)"]
        Vis["**Visitantes.ascx**"]
        Cir["**Circuitos.ascx**"]
        Def --> Verif
        Acc --> SMIcall["SOAP →"]
        Act --> SMIcall
        Vis --> SMIcall
        Cir --> SMIcall
    end

    subgraph SMI["wsSMIServer (SOAP, sin auth · P0)"]
        direction TB
        GU["**GetUsers**<br/>:15"]
        GUL["**GetUsersByLogicalCode**<br/>:44"]
        GF["**GetFamilies**<br/>:69"]
        AUF["**AddUserFamily**<br/>:134"]
        GSC["**GetSmartCardByID**<br/>:187"]
        USC["**UpdateSmartCard**<br/>:347"]
        GLE["**GetLastCircuitEvents**<br/>:380"]
        CUZ["**CountUsersByZone**<br/>:440"]
    end

    SMIcall --> SMI
```

---

## 3. Data lineage (flujo de datos extremo a extremo)

```mermaid
flowchart TB
    AD["Active Directory<br/>(refer.pt)"]
    Usager[("Alizes.Usager")]
    Badge[("Alizes.Badge")]
    Champ[("Alizes.ChampExplElem")]
    tblCartoes[("SICA.tblCartoes")]
    tblTerm[("SICA.tblTerminais")]
    Histo[("Alizes.VueHisto / Acces")]
    UI["SICAWeb UI"]
    Mail["Informe email<br/>ajsfernandes@refer.pt"]

    AD -->|"R: sAMAccountName, employeeID,<br/>company, memberOf<br/>(ADMethods.vb:259)"| DataSync
    DataSync -->|"W: usuarios filtrados<br/>(DataSync.vb:211-224)"| Usager
    DataSync -->|"R: badges supprime=0<br/>(DataSync.vb:245)"| Badge
    Badge --> Champ
    DataSync -->|"W: insert tarjetas<br/>(DataSync.vb:264 · SQLi)"| tblCartoes
    DataSync -->|"W: contadores"| Mail

    UI -->|"R: terminal whitelist<br/>(Default.aspx.vb:12 · SQLi)"| tblTerm
    UI -->|"R/W: tarjetas, familias"| tblCartoes
    UI -->|"SOAP R: eventos/circuitos"| Histo
```

| Almacén                | Lectura por                                  | Escritura por                         |
| ---------------------- | -------------------------------------------- | ------------------------------------- |
| Active Directory       | `SICADataSync` (ADMethods)                    | — (solo lectura)                      |
| `Alizes.Usager`        | `SICADataSync`, `wsSMIServer`                 | `SICADataSync`                        |
| `Alizes.Badge`         | `SICADataSync`, `wsSMIServer`                 | `wsSMIServer` (UpdateSmartCard)       |
| `SICA.tblCartoes`      | `SICAWeb`, `SICADataSync`                     | `SICADataSync`, `SICAWeb` (Acessos)   |
| `SICA.tblTerminais`    | `SICAWeb` (VerificaAcesso)                    | — (administración manual)             |
| `Alizes.VueHisto`      | `wsSMIServer` (GetLastCircuitEvents)          | — (solo lectura)                      |

---

## 4. Ruta crítica — Autorización de un acceso en terminal

```mermaid
sequenceDiagram
    actor Op as Operador
    participant IIS as IIS / Windows Auth
    participant Web as Default.aspx
    participant DB as SICA DB
    participant SMI as wsSMIServer
    participant Alz as Alizes DB

    Op->>IIS: GET Default.aspx
    IIS->>Web: LOGON_USER = REFER\\usuario
    Web->>Web: extrae SAM → Session("Utilizador")<br/>(Default.aspx.vb:39-41)
    Web->>DB: VerificaAcesso(NomePC, IP)<br/>(Default.aspx.vb:12 · ⚠️ SQLi)
    DB-->>Web: nombre terminal | vacío
    alt terminal autorizado
        Web->>Web: Session("NomeTerminal")
        Web->>SMI: SOAP GetLastCircuitEvents / CountUsersByZone
        SMI->>Alz: SELECT VueHisto / Acces
        Alz-->>SMI: eventos
        SMI-->>Web: datos de acceso
        Web-->>Op: panel de monitorización
    else terminal no autorizado
        Web-->>Op: acceso denegado (cadena vacía)
    end
```

> ⚠️ La única frontera de autorización efectiva es `VerificaAcesso`. Si la inyección SQL en
> `Default.aspx.vb:12` se explota, se evita **todo** el control de acceso.

---

## 5. Mapa de despliegue (inferido)

```mermaid
flowchart LR
    subgraph Term["Terminales de seguridad"]
        Browser["Navegador<br/>(Windows Auth)"]
    end
    subgraph IISsrv["Servidor IIS"]
        SICAWeb["SICAWeb"]
        SMI["wsSMIServer"]
    end
    subgraph Batch["Servidor batch"]
        DataSync["SICADataSync<br/>(tarea programada?)"]
    end
    subgraph DBsrv["rfsql01 (SQL Server)"]
        Alizes[("Alizes")]
        SICA[("SICA")]
    end
    ADsrv["Active Directory<br/>refer.pt"]

    Browser --> SICAWeb
    SICAWeb --> SMI
    SICAWeb --> SICA
    SMI --> Alizes
    DataSync --> ADsrv
    DataSync --> Alizes
    DataSync --> SICA
```

---

## 6. Confianza y gaps

- **Confianza**: Alta para componentes y call graph (verificados con `fichero:línea`);
  Media para el mapa de despliegue (inferido, sin acceso a la infraestructura real).
- **Gaps**:
  - La separación física de servidores (IIS vs batch) es una inferencia.
  - No se confirmó si `SICADataSync` corre como servicio Windows o tarea programada.
  - Faltan por mapear los UserControls de detalle (`DetalheLog`, `DetalheUtilizador`, etc.).
