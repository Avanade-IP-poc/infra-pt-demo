# Identity & Access Management — Lenguaje Ubicuo

> **Bounded Context**: Identity & Access Management (IAM)
> **Fase**: DISCOVERY (Domain Modeling)

---

## Términos del dominio

| Término             | Definición                                                           | Sinónimos legacy           |
| ------------------- | -------------------------------------------------------------------- | -------------------------- |
| **User**            | Persona que puede acceder al sistema SICA                             | Usager, Utilizador         |
| **Employee**        | Usuario empleado de una organización, sincronizado desde AD          | —                          |
| **Visitor**         | Usuario temporal sin cuenta en AD, registrado manualmente             | Visitante                  |
| **Employee ID**     | Identificador único del empleado en AD (7 dígitos)                    | employeeID, codelogique    |
| **Session**         | Sesión activa de un operador en un terminal autorizado               | —                          |
| **Terminal**        | PC/cliente registrado como punto de acceso autorizado                 | NomeTerminal               |
| **Principal**       | Identidad autenticada (SAM de Windows Auth)                           | LOGON_USER, Utilizador     |
| **Organization**    | Entidad multi-tenant (REFER, REFERTelecom, etc.)                      | Company, Empresa           |
| **User Type**       | Clasificación: Desconocido=0, Empleado>0                              | type                       |
| **Validity Date**   | Fecha hasta la cual el usuario puede acceder                          | datevalidite               |
| **Logical Code**    | Código único que identifica al usuario en SICA                        | codelogique                |
| **Suppressed**      | Usuario/entidad marcado como borrado lógico (soft delete)             | supprime                   |

---

## Reglas de negocio (lenguaje natural)

### User Lifecycle

- Un **Employee** solo se crea si su `Employee ID` tiene exactamente 7 dígitos y **no**
  empieza por 999999, 888888 o 777777 (cuentas de servicio).
- La estrategia de sincronización es **merge**: si existe por `Logical Code` se actualiza,
  si no, se crea.
- Un **Visitor** se crea manualmente y no tiene `Employee ID`.

### Session & Authorization

- Una **Session** solo se establece si el **Terminal** está registrado en la lista blanca
  (por hostname o IP).
- El **Principal** se extrae de Windows Auth eliminando el prefijo de dominio.
- Sin **Terminal** autorizado, no hay acceso (RULE-008).

### Multi-tenancy

- Cada **User** pertenece a una **Organization** única.
- Al sincronizar desde AD, solo se procesan usuarios del campo `company` correspondiente.

---

## Invariantes

| Invariante                          | Descripción                                                        |
| ----------------------------------- | ------------------------------------------------------------------ |
| `EmployeeID.Length == 7`            | Todo Employee debe tener ID de 7 caracteres                         |
| `EmployeeID NOT IN (999999, ...)`   | IDs reservados no son válidos                                       |
| `LogicalCode` único por Organization| Dentro de una organización, no puede haber duplicados              |
| `Terminal` debe estar registrado    | Solo terminales en la lista blanca pueden iniciar sesión           |
| `Session` requiere Principal y Terminal | Ambos deben estar establecidos                                  |

---

## Ubiquitous Language — Verbos

| Verbo (Inglés)       | Verbo (Español)          | Significado en el dominio                              |
| -------------------- | ------------------------ | ------------------------------------------------------ |
| `SyncUser`           | Sincronizar Usuario      | Crear o actualizar desde AD                             |
| `AuthorizeTerminal`  | Autorizar Terminal       | Validar que el terminal está en la lista blanca         |
| `ExtractPrincipal`   | Extraer Principal        | Obtener SAM desde LOGON_USER                            |
| `EstablishSession`   | Establecer Sesión        | Crear sesión con terminal + principal validados         |
| `FilterByOrganization` | Filtrar por Organización | Aplicar segmentación multi-tenant                      |
| `SoftDelete`         | Borrar Lógicamente       | Marcar `Suppressed = true` sin eliminar físicamente     |

---

## Casos de uso cubiertos

- [UC-001: Sincronización de empleados desde AD](../../../legacy/specs/use-cases/UC-001.md)
- [UC-003: Autorización de terminal y sesión](../../../legacy/specs/use-cases/UC-003.md)
