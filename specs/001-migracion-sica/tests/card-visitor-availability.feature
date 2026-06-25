# language: es
Característica: Disponibilidad de Tarjetas de Visitante
  Como operador de seguridad
  Quiero ver sólo las tarjetas disponibles para asignar a nuevos visitantes
  Para evitar asignar tarjetas que ya están en uso
  
  Regla de negocio: RULE-008 — Una tarjeta está disponible si tiene hora de salida O nunca fue usada
  
  Antecedentes:
    Dado que existen las siguientes tarjetas de visitante:
      | CardCode | CardType | HoraEntrada      | HoraSaida        | Estado     |
      | VIS001   | Visitor  | <null>           | <null>           | Disponible |
      | VIS002   | Visitor  | 2026-06-24 08:00 | 2026-06-24 17:00 | Disponible |
      | VIS003   | Visitor  | 2026-06-24 09:00 | <null>           | En uso     |
      | VIS004   | Visitor  | 2026-06-23 14:00 | 2026-06-23 18:30 | Disponible |

  @smoke
  @characterization
  Escenario: Tarjeta nunca usada está disponible
    Cuando se solicita la lista de tarjetas disponibles para el terminal "TERM01"
    Entonces la tarjeta "VIS001" aparece en la lista de disponibles
    Y la descripción indica "Nunca usada"

  @smoke
  @characterization
  Escenario: Tarjeta con salida registrada está disponible
    Cuando se solicita la lista de tarjetas disponibles para el terminal "TERM01"
    Entonces la tarjeta "VIS002" aparece en la lista de disponibles
    Y la última salida registrada es "2026-06-24 17:00"

  @smoke
  Escenario: Tarjeta con visitante activo (sin salida) NO está disponible
    Cuando se solicita la lista de tarjetas disponibles para el terminal "TERM01"
    Entonces la tarjeta "VIS003" NO aparece en la lista de disponibles

  Escenario: Tarjeta usada anteriormente (ciclo completo) está disponible
    Cuando se solicita la lista de tarjetas disponibles para el terminal "TERM01"
    Entonces la tarjeta "VIS004" aparece en la lista de disponibles
    Y la última salida registrada es "2026-06-23 18:30"

  @characterization
  Esquema del escenario: Comparación Legacy vs Modern - Disponibilidad de tarjetas
    Dado que la tarjeta "<CardCode>" tiene entrada "<Entrada>" y salida "<Salida>"
    Cuando se consulta la disponibilidad en el sistema Legacy
    Y se consulta la disponibilidad en el sistema Modern con los mismos parámetros
    Entonces ambos sistemas reportan disponibilidad = <Disponible>
    Y el resultado del Legacy es equivalente al resultado del Modern

    Ejemplos:
      | CardCode | Entrada              | Salida               | Disponible |
      | VIS001   | <null>               | <null>               | true       |
      | VIS002   | 2026-06-24 08:00     | 2026-06-24 17:00     | true       |
      | VIS003   | 2026-06-24 09:00     | <null>               | false      |
      | VIS004   | 2026-06-23 14:00     | 2026-06-23 18:30     | true       |
