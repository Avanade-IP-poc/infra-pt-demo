# language: es
Característica: Asignación de Tarjeta a Visitante
  Como operador de seguridad
  Quiero asignar tarjetas de visitante con todos los datos obligatorios
  Para garantizar el registro completo de las visitas
  
  Regla de negocio: RULE-009 — Validar visitante, familia y tarjeta antes de asignar
  
  Antecedentes:
    Dado que existen las siguientes familias de acceso disponibles para el terminal "TERM01":
      | FamilyId | FamilyName           |
      | 1        | Visitantes Generales |
      | 2        | Visitantes VIP       |
    Y la tarjeta "VIS005" está disponible

  @smoke
  Escenario: Asignación completa y válida de tarjeta a visitante
    Dado que el operador rellena el formulario de asignación con:
      | Campo             | Valor                     |
      | CardCode          | VIS005                    |
      | NombreVisitante   | Juan García               |
      | Empresa           | Empresa XYZ               |
      | EntidadVisitada   | Departamento IT           |
      | FamiliaAcceso     | Visitantes Generales (1)  |
      | ValidezDesde      | 2026-06-24 08:00          |
      | ValidezHasta      | 2026-06-24 18:00          |
    Cuando se confirma la asignación
    Entonces la asignación es exitosa
    Y se registra la entrada con timestamp actual
    Y el estado de la tarjeta cambia a "Active"
    Y se crea un log de auditoría con el evento "CardAssigned"

  @smoke
  Escenario: Validación falla - Sin familia de acceso seleccionada
    Dado que el operador rellena el formulario de asignación con:
      | Campo             | Valor                     |
      | CardCode          | VIS005                    |
      | NombreVisitante   | Juan García               |
      | Empresa           | Empresa XYZ               |
    Pero NO selecciona ninguna familia de acceso
    Cuando se intenta confirmar la asignación
    Entonces la validación falla
    Y se muestra el mensaje de error "Seleccione el acceso pretendido"
    Y NO se crea ninguna asignación

  @smoke
  Escenario: Validación falla - Sin identificación del visitante
    Dado que el operador selecciona la tarjeta "VIS005"
    Y selecciona la familia "Visitantes Generales"
    Pero NO rellena ningún campo de identificación (nombre, empresa, entidad visitada)
    Cuando se intenta confirmar la asignación
    Entonces la validación falla
    Y se muestra el mensaje de error "Identifique el destinatario del cartão"
    Y NO se crea ninguna asignación

  Escenario: Validación falla - Sin tarjeta seleccionada
    Dado que el operador rellena todos los datos del visitante
    Y selecciona la familia "Visitantes Generales"
    Pero NO selecciona ninguna tarjeta
    Cuando se intenta confirmar la asignación
    Entonces la validación falla
    Y se muestra el mensaje de error "Seleccione un o mais cartões disponíveis"

  @characterization
  Escenario: Comparación Legacy vs Modern - Asignación válida
    Dado una asignación con todos los datos completos y válidos
    Cuando se ejecuta la asignación en el sistema Legacy
    Y se ejecuta la asignación en el sistema Modern con los mismos parámetros
    Entonces ambos sistemas crean la asignación exitosamente
    Y el estado final de la tarjeta es el mismo en ambos sistemas
    Y los logs de auditoría son equivalentes

  @characterization
  Escenario: Comparación Legacy vs Modern - Validación sin familia
    Dado una asignación sin familia de acceso seleccionada
    Cuando se ejecuta la validación en el sistema Legacy
    Y se ejecuta la validación en el sistema Modern con los mismos parámetros
    Entonces ambos sistemas rechazan la asignación
    Y los mensajes de error son equivalentes
