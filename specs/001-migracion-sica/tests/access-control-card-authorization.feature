# language: es
Característica: Autorización de Acceso a Tarjeta por Terminal
  Como sistema SICA
  Quiero verificar que un terminal tenga acceso a una tarjeta antes de operar sobre ella
  Para garantizar la segmentación de permisos por terminal
  
  Regla de negocio: RULE-013 — Antes de operar sobre una tarjeta, verificar acceso del terminal vía vwAcessos
  
  Antecedentes:
    Dado que existen los siguientes terminales:
      | TerminalId | Hostname |
      | 1          | TERM01   |
      | 2          | TERM02   |
    Y las siguientes tarjetas:
      | CardId | CardCode |
      | 101    | VIS001   |
      | 102    | VIS002   |
      | 103    | EMP0001  |
    Y las siguientes relaciones de acceso terminal-tarjeta:
      | TerminalId | CardId |
      | 1          | 101    |
      | 1          | 103    |
      | 2          | 102    |

  @smoke
  @characterization
  Escenario: Terminal con acceso a la tarjeta - Operación permitida
    Dado que el terminal actual es "TERM01" (ID: 1)
    Y el operador solicita operar sobre la tarjeta "VIS001" (ID: 101)
    Cuando se verifica el acceso del terminal a la tarjeta
    Entonces el acceso es concedido
    Y se permite la operación sobre la tarjeta

  @smoke
  @characterization
  Escenario: Terminal sin acceso a la tarjeta - Operación denegada
    Dado que el terminal actual es "TERM01" (ID: 1)
    Y el operador solicita operar sobre la tarjeta "VIS002" (ID: 102)
    Cuando se verifica el acceso del terminal a la tarjeta
    Entonces el acceso es denegado
    Y se muestra el mensaje "Sem acesso ao cartão VIS002"
    Y se registra un log de auditoría con evento "UnauthorizedCardAccess"

  Escenario: Tarjeta no existe - Operación denegada
    Dado que el terminal actual es "TERM01" (ID: 1)
    Y el operador solicita operar sobre la tarjeta "VIS999" que NO existe
    Cuando se verifica el acceso del terminal a la tarjeta
    Entonces el acceso es denegado
    Y se muestra el mensaje "Cartão não encontrado"

  @smoke
  Escenario: Operaciones múltiples requieren verificación por cada tarjeta
    Dado que el terminal actual es "TERM01" (ID: 1)
    Y el operador solicita operar sobre las tarjetas:
      | CardCode |
      | VIS001   |
      | VIS002   |
      | EMP0001  |
    Cuando se verifica el acceso para cada tarjeta
    Entonces las tarjetas con acceso son: VIS001, EMP0001
    Y las tarjetas sin acceso son: VIS002
    Y se permiten operaciones sólo sobre VIS001 y EMP0001

  @characterization
  Escenario: Comparación Legacy vs Modern - Terminal con acceso
    Dado un terminal "TERM01" con acceso a la tarjeta "VIS001"
    Cuando se verifica el acceso en el sistema Legacy
    Y se verifica el acceso en el sistema Modern con los mismos parámetros
    Entonces ambos sistemas conceden el acceso
    Y el resultado del Legacy es equivalente al resultado del Modern

  @characterization
  Escenario: Comparación Legacy vs Modern - Terminal sin acceso
    Dado un terminal "TERM01" sin acceso a la tarjeta "VIS002"
    Cuando se verifica el acceso en el sistema Legacy
    Y se verifica el acceso en el sistema Modern con los mismos parámetros
    Entonces ambos sistemas deniegan el acceso
    Y los mensajes de error son equivalentes
    Y los logs de auditoría son equivalentes
