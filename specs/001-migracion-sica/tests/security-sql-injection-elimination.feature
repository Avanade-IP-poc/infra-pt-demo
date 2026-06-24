# language: es
Característica: Seguridad - Eliminación de SQL Injection
  Como responsable de seguridad
  Quiero garantizar que no exista concatenación de SQL sin parametrizar
  Para eliminar las vulnerabilidades OWASP A03 del sistema legacy
  
  Antecedentes:
    Dado que el sistema Legacy tiene 12 puntos de SQL Injection identificados
    Y el sistema Modern debe usar consultas parametrizadas en el 100% de los casos

  @smoke
  @security
  Escenario: Autorización de terminal - Parametrización correcta
    Dado que se solicita autorización para el terminal "TERM01'; DROP TABLE tblTerminais; --"
    Cuando se ejecuta la consulta en el sistema Modern
    Entonces la consulta usa parámetros SQL parametrizados
    Y NO se ejecuta concatenación de cadenas
    Y la inyección SQL es prevenida
    Y la consulta retorna 0 resultados (sin match)

  @smoke
  @security
  @characterization
  Escenario: Defecto Legacy - SQL Injection en autorización de terminal
    Dado que el sistema Legacy concatena SQL directamente:
      """
      "select nome from tblTerminais where upper(nome)='" & NomePC.ToUpper & "' or ip='" & IP & "'"
      """
    Y el hostname del cliente es "TERM99' OR '1'='1"
    Cuando se ejecuta la consulta en el sistema Legacy
    Entonces la inyección SQL es exitosa (defecto)
    Y se retornan TODOS los terminales (bypass de seguridad)
    Pero cuando se ejecuta en el sistema Modern con parametrización
    Entonces la inyección SQL es prevenida
    Y se retornan 0 resultados (sin match real)

  @smoke
  @security
  Escenario: Búsqueda de visitante - Parametrización correcta
    Dado que se busca un visitante con empresa "Empresa'; DELETE FROM tblVisitantes; --"
    Cuando se ejecuta la búsqueda en el sistema Modern
    Entonces la consulta usa Entity Framework con parámetros seguros
    Y NO se permite ejecución de código SQL arbitrario
    Y la consulta retorna 0 resultados (sin match)

  @security
  Escenario: Actualización de familia - Parametrización correcta
    Dado que se actualiza la familia con ID "1; DROP TABLE tblFamilias; --"
    Cuando se ejecuta la actualización en el sistema Modern
    Entonces la consulta usa parámetros seguros
    Y la inyección SQL es prevenida
    Y se retorna un error de tipo de datos (ID no es integer válido)

  @security
  @static-analysis
  Escenario: Security Scan - Sin vulnerabilidades críticas
    Dado que se ejecuta un escaneo de seguridad con Trivy en el código Modern
    Cuando se analiza el código fuente y las dependencias
    Entonces NO se encuentran vulnerabilidades críticas (Critical/High)
    Y el security gate del pipeline pasa exitosamente
    Y se genera un reporte de seguridad

  @security
  @static-analysis
  Escenario: Code Review - Sin concatenación SQL detectada
    Dado que se ejecuta un análisis estático del código con Roslyn Analyzers
    Cuando se buscan patrones de concatenación de SQL
    Entonces NO se detectan concatenaciones de cadenas en consultas SQL
    Y el 100% de las consultas usan parámetros o EF Core
    Y el quality gate del pipeline pasa exitosamente
