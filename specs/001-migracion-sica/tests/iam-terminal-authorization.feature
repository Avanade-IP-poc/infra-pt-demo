# language: es
Característica: Autorización de Terminal
  Como sistema SICA
  Quiero autorizar terminales por nombre de host o dirección IP
  Para garantizar que sólo equipos registrados pueden acceder al sistema
  
  Regla de negocio: RULE-001 — Un terminal sólo puede acceder si su nombre o IP están registrados en tblTerminais
  
  Antecedentes:
    Dado que existen los siguientes terminales registrados:
      | Id | Hostname | IP            | Activo |
      | 1  | TERM01   | 192.168.1.100 | true   |
      | 2  | TERM02   | 192.168.1.101 | true   |
      | 3  | TERM03   | 192.168.1.102 | false  |

  @smoke
  @characterization
  Escenario: Terminal autorizado por nombre de host (mayúsculas insensible)
    Dado que el cliente tiene el hostname "term01"
    Y la dirección IP del cliente es "192.168.1.100"
    Cuando se solicita autorización del terminal
    Entonces el terminal es autorizado
    Y se retorna el ID de terminal 1
    Y se retorna el nombre registrado "TERM01"

  @smoke
  @characterization
  Escenario: Terminal autorizado por dirección IP
    Dado que el cliente tiene el hostname "UNKNOWN"
    Y la dirección IP del cliente es "192.168.1.101"
    Cuando se solicita autorización del terminal
    Entonces el terminal es autorizado
    Y se retorna el ID de terminal 2
    Y se retorna el nombre registrado "TERM02"

  @smoke
  Escenario: Terminal no registrado es rechazado
    Dado que el cliente tiene el hostname "TERM99"
    Y la dirección IP del cliente es "192.168.1.999"
    Cuando se solicita autorización del terminal
    Entonces el terminal NO es autorizado
    Y se retorna un mensaje de error "Terminal no registrado"

  Escenario: Terminal registrado pero inactivo es rechazado
    Dado que el cliente tiene el hostname "TERM03"
    Y la dirección IP del cliente es "192.168.1.102"
    Cuando se solicita autorización del terminal
    Entonces el terminal NO es autorizado
    Y se retorna un mensaje de error "Terminal inactivo"

  @smoke
  Escenario: Cliente detrás de proxy (X-Forwarded-For)
    Dado que el cliente está detrás de un proxy
    Y el header "X-Forwarded-For" es "192.168.1.100, 10.0.0.1"
    Cuando se solicita autorización del terminal
    Entonces se usa la primera IP "192.168.1.100" para la autorización
    Y el terminal es autorizado

  @characterization
  Escenario: Comparación de comportamiento Legacy vs Modern - Terminal autorizado
    Dado un terminal registrado con hostname "TERM01" e IP "192.168.1.100"
    Cuando se ejecuta la autorización en el sistema Legacy
    Y se ejecuta la autorización en el sistema Modern con los mismos parámetros
    Entonces ambos sistemas autorizan el terminal
    Y el resultado del Legacy es equivalente al resultado del Modern

  @characterization
  Escenario: Comparación de comportamiento Legacy vs Modern - Terminal no registrado
    Dado un terminal NO registrado con hostname "TERM99" e IP "192.168.1.999"
    Cuando se ejecuta la autorización en el sistema Legacy
    Y se ejecuta la autorización en el sistema Modern con los mismos parámetros
    Entonces ambos sistemas rechazan el terminal
    Y el resultado del Legacy es equivalente al resultado del Modern
