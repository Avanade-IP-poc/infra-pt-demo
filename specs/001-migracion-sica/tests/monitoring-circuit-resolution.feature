# language: es
Característica: Resolución de Circuitos Físicos
  Como sistema de monitorización
  Quiero resolver un circuito lógico (grupo) a sus circuitos físicos
  Para consultar eventos de acceso de todos los lectores del grupo
  
  Regla de negocio: RULE-010 — Un circuito grupo puede tener múltiples circuitos físicos
  
  Antecedentes:
    Dado que existen los siguientes circuitos físicos:
      | CircuitId | CircuitName            | CircuitGroupId |
      | 338       | Puerta Principal Ent   | 340            |
      | 342       | Puerta Principal Sal   | 340            |
      | 347       | Puerta Garaje Ent      | 345            |
      | 344       | Puerta Garaje Sal      | 345            |
      | 351       | Puerta Emergencia      | 351            |

  @smoke
  @characterization
  Escenario: Circuito grupo con múltiples circuitos físicos
    Dado que el usuario selecciona el circuito grupo "Puerta Principal" (ID: 340)
    Cuando se resuelven los circuitos físicos del grupo
    Entonces se obtienen los circuitos: 338, 342
    Y la consulta de eventos se ejecuta sobre "338,342"

  @smoke
  Escenario: Circuito simple sin jerarquía (grupo == físico)
    Dado que el usuario selecciona el circuito "Puerta Emergencia" (ID: 351)
    Cuando se resuelven los circuitos físicos del grupo
    Entonces se obtiene sólo el circuito: 351
    Y la consulta de eventos se ejecuta sobre "351"

  @smoke
  Escenario: Consulta de eventos de un circuito grupo
    Dado que el circuito grupo 340 tiene los circuitos físicos: 338, 342
    Cuando se solicitan los últimos eventos de acceso con:
      | Parámetro   | Valor |
      | CircuitId   | 340   |
      | Horas       | 72    |
      | MaxEventos  | 20    |
    Entonces la consulta SMI se ejecuta con "338,342" como parámetro
    Y se retornan hasta 20 eventos de las últimas 72 horas
    Y los eventos están ordenados por timestamp descendente

  @characterization
  Esquema del escenario: Comparación Legacy vs Modern - Resolución de circuitos
    Dado que el circuito grupo <GrupoId> tiene circuitos físicos <Fisicos>
    Cuando se resuelve el grupo en el sistema Legacy
    Y se resuelve el grupo en el sistema Modern con los mismos parámetros
    Entonces ambos sistemas resuelven los mismos circuitos físicos
    Y el resultado del Legacy es equivalente al resultado del Modern

    Ejemplos:
      | GrupoId | Fisicos   |
      | 340     | 338,342   |
      | 345     | 347,344   |
      | 351     | 351       |
