# language: es
Característica: Identificación de Operador
  Como sistema SICA
  Quiero extraer la identidad del operador desde Windows Authentication
  Para vincular las acciones del operador con su cuenta corporativa
  
  Regla de negocio: RULE-002 — El nombre de usuario se extrae del header LOGON_USER sin el prefijo de dominio
  
  @smoke
  Escenario: Usuario autenticado con dominio REFER
    Dado que el header "LOGON_USER" contiene "REFER\ajsfernandes"
    Cuando se procesa la identidad del operador
    Entonces el nombre de usuario extraído es "ajsfernandes"
    Y el dominio "REFER" es descartado

  @smoke
  Escenario: Usuario autenticado con dominio en minúsculas
    Dado que el header "LOGON_USER" contiene "refer\tzcorreia"
    Cuando se procesa la identidad del operador
    Entonces el nombre de usuario extraído es "tzcorreia"

  Escenario: Usuario sin dominio (LOGON_USER vacío)
    Dado que el header "LOGON_USER" está vacío
    Cuando se procesa la identidad del operador
    Entonces el nombre de usuario extraído es una cadena vacía ""

  Escenario: Usuario sin dominio (LOGON_USER con 1 carácter)
    Dado que el header "LOGON_USER" contiene "a"
    Cuando se procesa la identidad del operador
    Entonces el nombre de usuario extraído es una cadena vacía ""

  @characterization
  Escenario: Comparación Legacy vs Modern - Extracción de identidad
    Dado que el header "LOGON_USER" contiene "REFER\operador123"
    Cuando se ejecuta la extracción en el sistema Legacy
    Y se ejecuta la extracción en el sistema Modern con los mismos parámetros
    Entonces ambos sistemas extraen "operador123"
    Y el resultado del Legacy es equivalente al resultado del Modern
