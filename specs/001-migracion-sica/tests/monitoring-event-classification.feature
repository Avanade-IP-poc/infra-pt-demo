# language: es
Característica: Clasificación de Movimientos como Entrada o Salida
  Como sistema de monitorización
  Quiero clasificar cada evento de acceso como Entrada o Salida
  Para poder calcular presencia y tránsito de personas
  
  Regla de negocio: RULE-011 — Clasificación por descripción del circuito o parámetro del evento
  
  Antecedentes:
    Dado que existen los siguientes eventos en el log del SMI:
      | EventId | CardCode | CircuitDescription        | Parametre | Timestamp           |
      | 1001    | EMP0001  | Puerta Principal ENTRADA  | 1         | 2026-06-24 08:00:00 |
      | 1002    | EMP0001  | Puerta Principal SALIDA   | 2         | 2026-06-24 17:30:00 |
      | 1003    | VIS001   | Lector Garaje             | 1         | 2026-06-24 09:15:00 |
      | 1004    | VIS001   | Lector Garaje             | 2         | 2026-06-24 18:00:00 |
      | 1005    | EMP0002  | Pasillo Acceso            | 0         | 2026-06-24 10:00:00 |

  @smoke
  @characterization
  Escenario: Clasificación por descripción - ENTRADA en descripción
    Dado que el evento 1001 tiene descripción "Puerta Principal ENTRADA"
    Cuando se clasifica el movimiento
    Entonces el tipo de evento es "Entry"
    Y se registra el timestamp de entrada: 2026-06-24 08:00:00

  @smoke
  @characterization
  Escenario: Clasificación por descripción - SALIDA en descripción
    Dado que el evento 1002 tiene descripción "Puerta Principal SALIDA"
    Cuando se clasifica el movimiento
    Entonces el tipo de evento es "Exit"
    Y se registra el timestamp de salida: 2026-06-24 17:30:00

  @smoke
  Escenario: Clasificación por parámetro - parametre = 1 (Entrada)
    Dado que el evento 1003 tiene descripción "Lector Garaje" (sin ENTRADA/SALIDA)
    Y el parámetro del evento es 1
    Cuando se clasifica el movimiento
    Entonces el tipo de evento es "Entry"

  @smoke
  Escenario: Clasificación por parámetro - parametre = 2 (Salida)
    Dado que el evento 1004 tiene descripción "Lector Garaje" (sin ENTRADA/SALIDA)
    Y el parámetro del evento es 2
    Cuando se clasifica el movimiento
    Entonces el tipo de evento es "Exit"

  Escenario: Movimiento desconocido - Sin clasificación posible
    Dado que el evento 1005 tiene descripción "Pasillo Acceso" (sin ENTRADA/SALIDA)
    Y el parámetro del evento es 0 (no clasificable)
    Cuando se clasifica el movimiento
    Entonces el tipo de evento es "Unknown"
    Y el evento es ignorado en el cálculo de presencia

  @smoke
  Escenario: Prioridad descripción sobre parámetro
    Dado que un evento tiene descripción "Puerta ENTRADA"
    Pero el parámetro es 2 (contradicción)
    Cuando se clasifica el movimiento
    Entonces se usa la descripción
    Y el tipo de evento es "Entry"

  @characterization
  Esquema del escenario: Comparación Legacy vs Modern - Clasificación de movimientos
    Dado que un evento tiene descripción "<Descripcion>" y parámetro <Parametro>
    Cuando se clasifica en el sistema Legacy
    Y se clasifica en el sistema Modern con los mismos parámetros
    Entonces ambos sistemas clasifican como "<TipoEvento>"
    Y el resultado del Legacy es equivalente al resultado del Modern

    Ejemplos:
      | Descripcion               | Parametro | TipoEvento |
      | Puerta Principal ENTRADA  | 1         | Entry      |
      | Puerta Principal SALIDA   | 2         | Exit       |
      | Lector Garaje             | 1         | Entry      |
      | Lector Garaje             | 2         | Exit       |
      | Pasillo Acceso            | 0         | Unknown    |
