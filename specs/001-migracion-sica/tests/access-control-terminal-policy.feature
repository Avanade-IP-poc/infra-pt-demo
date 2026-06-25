# language: es
Característica: Política de Acceso de Terminal
  Como administrador de seguridad
  Quiero gestionar el perfil de acceso de cada terminal
  Para controlar qué familias, tarjetas y circuitos están autorizados por terminal
  
  Regla de negocio: RULE-007 — Perfil de acceso reemplaza completamente las relaciones (DELETE + INSERT transaccional)
  
  Antecedentes:
    Dado que el terminal "TERM01" (ID: 1) tiene actualmente configurado:
      | Tipo     | Elementos                    |
      | Familias | Visitantes Generales (ID: 1) |
      | Circuitos| Puerta Principal (ID: 10)    |

  @smoke
  @characterization
  Escenario: Actualización exitosa de política de acceso
    Dado que el administrador selecciona el terminal "TERM01"
    Y marca las siguientes familias:
      | FamilyId | FamilyName           |
      | 1        | Visitantes Generales |
      | 2        | Visitantes VIP       |
    Y marca los siguientes circuitos:
      | CircuitId | CircuitName       |
      | 10        | Puerta Principal  |
      | 11        | Puerta Garaje     |
    Cuando se aplica la configuración
    Entonces la operación es exitosa
    Y la configuración anterior es eliminada completamente
    Y la nueva configuración contiene 2 familias y 2 circuitos
    Y se registra un log de auditoría con evento "PolicyUpdated"

  @smoke
  Escenario: Eliminación total de permisos (terminal sin acceso)
    Dado que el administrador selecciona el terminal "TERM01"
    Y NO marca ninguna familia
    Y NO marca ningún circuito
    Cuando se aplica la configuración
    Entonces la operación es exitosa
    Y todas las relaciones previas son eliminadas
    Y el terminal queda sin permisos de acceso

  @critical
  @transaction
  Escenario: Garantía de transacción - Rollback en caso de error
    Dado que el administrador selecciona el terminal "TERM01"
    Y marca 3 familias y 5 circuitos
    Cuando se aplica la configuración
    Pero ocurre un error al insertar el circuito 3
    Entonces se hace rollback de TODA la operación
    Y la configuración original permanece intacta
    Y NO se eliminan las relaciones previas
    Y se registra un log de error

  @characterization
  Escenario: Comparación Legacy vs Modern - Actualización de política
    Dado un terminal con configuración inicial conocida
    Y una nueva configuración con 2 familias y 3 circuitos
    Cuando se ejecuta la actualización en el sistema Legacy
    Y se ejecuta la actualización en el sistema Modern con los mismos parámetros
    Entonces ambos sistemas aplican la nueva configuración
    Y el estado final del terminal es el mismo en ambos sistemas
    Y las relaciones persistidas son equivalentes

  @bug
  @legacy-issue
  Escenario: Defecto Legacy - Sin transacción provoca inconsistencia
    Dado que el sistema Legacy NO usa transacciones
    Y el terminal "TERM01" tiene 3 familias configuradas
    Cuando se intenta actualizar a 5 familias
    Pero el INSERT de la familia 3 falla
    Entonces el sistema Legacy elimina las 3 familias anteriores (DELETE exitoso)
    Pero sólo inserta 2 familias nuevas (INSERT parcial)
    Y el terminal queda con sólo 2 familias en lugar de 3 o 5 (inconsistencia)
    Pero el sistema Modern con transacción hace rollback completo
    Y mantiene las 3 familias originales (consistente)
