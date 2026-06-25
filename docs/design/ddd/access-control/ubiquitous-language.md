# Access Control — Lenguaje Ubicuo

> **Bounded Context**: Access Control
> **Fase**: DISCOVERY (Domain Modeling)

---

## Términos del dominio

| Término             | Definición                                                           | Sinónimos legacy           |
| ------------------- | -------------------------------------------------------------------- | -------------------------- |
| **Access Family**   | Grupo de acceso que define permisos para circuitos/puertas          | Familia, Family            |
| **Access Policy**   | Regla que vincula Terminal ↔ Family ↔ Circuit                        | —                          |
| **Circuit**         | Circuito físico (puerta, lector) controlado por el sistema          | Circuito, Acces            |
| **Permission**      | Autorización para que una familia acceda a un circuito              | —                          |
| **Terminal Association** | Relación entre terminal y familias que puede gestionar        | tblFamiliasTerminal        |

---

## Reglas de negocio (lenguaje natural)

### Access Policy

- Una **Access Policy** define qué **Access Families** tienen permiso para acceder a
  qué **Circuits**.
- Las políticas se asocian a **Terminals**: un operador solo ve y gestiona las familias
  asociadas a su terminal.

### Family Membership

- Un **User** (empleado o visitante) puede pertenecer a múltiples **Access Families**.
- Una **Smart Card** hereda los permisos de las familias de su propietario.

### Terminal-scoped Authorization

- Un **Terminal** solo puede gestionar las familias que tiene asociadas (RULE-008 extensión).
- Si un terminal no tiene familias asociadas, no puede activar tarjetas de visitante.

---

## Invariantes

| Invariante                             | Descripción                                          |
| -------------------------------------- | ---------------------------------------------------- |
| Familia sin circuitos no tiene efecto  | Una familia debe tener al menos un circuito asociado |
| Terminal sin familias no puede operar  | Terminal debe tener al menos una familia para trabajar|
| Usuario puede pertenecer a N familias  | Sin límite de membresía                              |

---

## Ubiquitous Language — Verbos

| Verbo (Inglés)          | Verbo (Español)                | Significado en el dominio                              |
| ----------------------- | ------------------------------ | ------------------------------------------------------ |
| `GrantAccess`           | Conceder Acceso                | Añadir familia a un circuito                            |
| `RevokeAccess`          | Revocar Acceso                 | Eliminar familia de un circuito                         |
| `AssignFamilyToTerminal`| Asignar Familia a Terminal     | Permitir que un terminal gestione una familia           |
| `AddUserToFamily`       | Añadir Usuario a Familia       | Dar permisos de familia a un usuario                    |
| `RemoveUserFromFamily`  | Eliminar Usuario de Familia    | Quitar permisos de familia                              |
| `EvaluatePermission`    | Evaluar Permiso                | Verificar si tarjeta tiene acceso a circuito            |

---

## Casos de uso cubiertos

- [UC-004: Activación de tarjeta de visitante](../../../legacy/specs/use-cases/UC-004.md) (filtro por terminal)
- [UC-005: Consulta y modificación vía SOAP](../../../legacy/specs/use-cases/UC-005.md) (WebMethod AddUserFamily)
