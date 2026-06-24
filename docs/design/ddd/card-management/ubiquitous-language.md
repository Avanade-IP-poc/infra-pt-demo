# Card Management — Lenguaje Ubicuo

> **Bounded Context**: Card Management
> **Fase**: DISCOVERY (Domain Modeling)

---

## Términos del dominio

| Término             | Definición                                                           | Sinónimos legacy           |
| ------------------- | -------------------------------------------------------------------- | -------------------------- |
| **Smart Card**      | Tarjeta inteligente con chip RFID para control de accesos           | Badge, Cartão              |
| **Card Code**       | Código único de la tarjeta (prefijo + número)                        | codelogique, NumCartao     |
| **Card Type**       | Clasificación: Visitante(1), Mantenimiento(2), Corporativo(3), etc. | Tipo, idTipoCartao         |
| **Card Status**     | Estado: Activo(2), Inactivo(4)                                        | statutbadge                |
| **Expiration Date** | Fecha de caducidad de la tarjeta                                      | dateperemption             |
| **Visitor Card**    | Tarjeta temporal asignada a visitantes                                | —                          |
| **Availability**    | Estado que indica si la tarjeta puede asignarse a un nuevo visitante  | —                          |
| **Entry Time**      | Hora de entrada del usuario con la tarjeta                            | HoraEntrada                |
| **Exit Time**       | Hora de salida del usuario con la tarjeta                             | HoraSaida                  |
| **Validity Window** | Período durante el cual la tarjeta de visitante es válida            | ValidadeCartao             |

---

## Reglas de negocio (lenguaje natural)

### Card Classification

- El **Card Type** se determina por el primer carácter del **Card Code**:
  - V → Visitante
  - M → Mantenimiento
  - C → Corporativo
  - R → Restringido
  - A → Admin
  - Default → Visitante

### Card Lifecycle

- Una **Smart Card** se crea al sincronizar desde el sistema maestro (Alizes).
- Solo se sincronizan tarjetas con `Card Code` que empiece por (C, V, M, A, R).
- Una tarjeta existe en un solo estado: Activo o Inactivo.

### Visitor Card Availability

- Una **Visitor Card** está **disponible** si:
  - Tiene `Exit Time` registrado (visitante anterior salió), OR
  - Nunca ha sido usada (`Entry Time` y `Exit Time` vacíos).
- Una tarjeta está **en uso** si tiene `Entry Time` pero no `Exit Time`.

### Validity Window

- Al activar una **Visitor Card**, se establece `Validity Window` = fecha actual.
- (Gap del legacy: no se observa validación de caducidad en el flujo de acceso.)

---

## Invariantes

| Invariante                             | Descripción                                          |
| -------------------------------------- | ---------------------------------------------------- |
| `CardCode` único                       | No puede haber dos tarjetas con el mismo código      |
| `CardType` derivado de prefijo         | El tipo se infiere, no se asigna arbitrariamente     |
| Visitor Card solo para tipo Visitante  | Una tarjeta de visitante tiene `CardType = Visitor`  |
| Tarjeta activa no puede estar en uso   | Si `Status = Inactive`, no tiene `EntryTime` sin salida |

---

## Ubiquitous Language — Verbos

| Verbo (Inglés)         | Verbo (Español)         | Significado en el dominio                              |
| ---------------------- | ----------------------- | ------------------------------------------------------ |
| `ClassifyCard`         | Clasificar Tarjeta      | Determinar el tipo por el prefijo del código           |
| `SyncCard`             | Sincronizar Tarjeta     | Crear o actualizar desde el sistema maestro            |
| `ActivateVisitorCard`  | Activar Tarjeta Visitante | Asignar tarjeta a visitante y fijar validez         |
| `CheckAvailability`    | Verificar Disponibilidad | Determinar si una tarjeta de visitante está libre     |
| `RecordEntry`          | Registrar Entrada       | Marcar `Entry Time` al pasar la tarjeta                |
| `RecordExit`           | Registrar Salida        | Marcar `Exit Time` al salir                            |
| `Expire`               | Caducar                 | Tarjeta supera su `Expiration Date`                    |
| `Deactivate`           | Desactivar              | Cambiar estado a Inactivo                              |

---

## Casos de uso cubiertos

- [UC-002: Clasificación y sincronización de tarjetas](../../../legacy/specs/use-cases/UC-002.md)
- [UC-004: Activación de tarjeta de visitante](../../../legacy/specs/use-cases/UC-004.md)
