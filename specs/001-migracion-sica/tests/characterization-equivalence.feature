# language: es
Característica: Tests de Caracterización - Equivalencia Legacy vs Modern
  Como equipo de desarrollo
  Quiero garantizar que el sistema Modern preserva el comportamiento del Legacy
  Para evitar regresiones durante la migración
  
  Regla: El comportamiento del Legacy se captura como "golden master" antes de la reescritura
  
  @smoke
  @characterization
  @golden-master
  Escenario: Terminal Authorization - Golden Master
    Dado que se captura el comportamiento del Legacy para "TerminalAuthorization"
    Y se ejecutan 100 casos de prueba con combinaciones de hostname/IP:
      | Casos                 | Cantidad |
      | Terminales válidos    | 40       |
      | Terminales inválidos  | 30       |
      | Casos borde           | 20       |
      | Inyección SQL         | 10       |
    Cuando se ejecuta cada caso en el Legacy
    Y se captura la salida completa como snapshot (ApprovalTests)
    Entonces se genera el archivo golden master "TerminalAuthorization.approved.json"
    Y cada ejecución del Modern debe producir la misma salida

  @smoke
  @characterization
  @parity
  Escenario: Card Availability - Parity Test
    Dado que se definen 50 escenarios de disponibilidad de tarjetas:
      | Escenario                      | Cantidad |
      | Nunca usadas                   | 10       |
      | Con salida registrada          | 15       |
      | Sin salida (visitante activo)  | 15       |
      | Ciclos múltiples               | 10       |
    Cuando se ejecuta cada escenario en ambos sistemas (Legacy y Modern)
    Entonces para cada escenario, las salidas deben ser idénticas:
      | Campo            | Comparación              |
      | IsAvailable      | Exacto (boolean)         |
      | LastEntryTime    | Exacto (timestamp)       |
      | LastExitTime     | Exacto (timestamp o null)|

  @characterization
  @golden-master
  Escenario: Access Policy Update - Golden Master con estado completo
    Dado que se captura el comportamiento del Legacy para "UpdateTerminalAccessPolicy"
    Y se ejecutan 30 casos de actualización de política:
      | Casos                              | Cantidad |
      | Agregar familias/circuitos         | 10       |
      | Eliminar familias/circuitos        | 8        |
      | Reemplazar completamente           | 8        |
      | Sin cambios (idempotente)          | 4        |
    Cuando se ejecuta cada caso en el Legacy
    Y se captura el estado ANTES y DESPUÉS de la BD
    Entonces se genera el golden master con:
      | Datos capturados                   |
      | Estado inicial de relaciones       |
      | Estado final de relaciones         |
      | Logs de auditoría generados        |
    Y el Modern debe producir transiciones de estado idénticas

  @characterization
  @mutation-testing
  Escenario: Mutation Testing - Validar robustez de los caracterization tests
    Dado que se ejecutan los characterization tests sobre el código Modern
    Cuando se aplica mutation testing con Stryker.NET
    Y se generan mutantes en la lógica de negocio:
      | Tipo de mutante                  | Ejemplo                              |
      | Boolean inverter                 | `isActive == true` → `isActive == false` |
      | Relational operator mutator      | `>` → `>=`                           |
      | Arithmetic operator mutator      | `+` → `-`                            |
    Entonces el mutation score debe ser ≥ 70%
    Y los mutantes supervivientes son revisados y justificados

  @characterization
  @data-migration
  Escenario: Data Migration Validation - Comparación de datasets
    Dado que se migran los datos del esquema Legacy al esquema Modern
    Cuando se ejecuta el script de migración sobre una copia de producción
    Entonces para cada tabla migrada se valida:
      | Validación                              |
      | Row count exacto                        |
      | Checksums de columnas críticas          |
      | Integridad referencial (FKs válidas)    |
      | Datos transformados correctamente       |
    Y se genera un reporte de diferencias (expected: 0 diferencias)

  @characterization
  @end-to-end
  Escenario: E2E - Flujo completo de asignación de visitante (Legacy vs Modern)
    Dado que se ejecuta el flujo completo de "Asignación de tarjeta a visitante"
    Cuando se registran todas las interacciones en ambos sistemas:
      | Paso                              | Captura                          |
      | 1. Autorización de terminal       | Request/Response                 |
      | 2. Listar tarjetas disponibles    | Request/Response + dataset       |
      | 3. Crear visitante                | Request/Response + ID generado   |
      | 4. Asignar tarjeta                | Request/Response + estado tarjeta|
      | 5. Registrar entrada              | Request/Response + evento creado |
      | 6. Logs de auditoría              | Eventos generados                |
    Entonces todas las capturas del Legacy son equivalentes a las del Modern
    Y el estado final de la BD es idéntico en ambos sistemas
