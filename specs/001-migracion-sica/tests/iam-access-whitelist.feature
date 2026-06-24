# language: es
Característica: Control de Acceso por Whitelist
  Como sistema SICA
  Quiero restringir el acceso a páginas sensibles mediante whitelist
  Para garantizar que sólo usuarios autorizados gestionan configuración e histórico
  
  Regla de negocio: RULE-003 — Páginas ConfigAcessos e Histórico restringidas por whitelist en appSettings
  
  Antecedentes:
    Dado que la configuración "AcessoDeConfiguracao" es "ajsfernandes;tzcorreia"
    Y la configuración "AcessoAHistorico" es "ajsfernandes;tzcorreia;jcssilva"

  @smoke
  Escenario: Usuario autorizado accede a Configuración de Accesos
    Dado que el usuario actual es "ajsfernandes"
    Cuando el usuario intenta acceder a la página "ConfigurarAcessos"
    Entonces el acceso es permitido
    Y el panel de configuración es visible
    Y el ítem de menú "Configurar Accesos" es visible

  @smoke
  Escenario: Usuario NO autorizado intenta acceder a Configuración de Accesos
    Dado que el usuario actual es "usuario_normal"
    Cuando el usuario intenta acceder a la página "ConfigurarAcessos"
    Entonces el acceso es denegado
    Y el panel de configuración NO es visible
    Y el ítem de menú "Configurar Accesos" NO es visible

  @smoke
  Escenario: Usuario autorizado accede a Histórico
    Dado que el usuario actual es "jcssilva"
    Cuando el usuario intenta acceder a la página "Historico"
    Entonces el acceso es permitido
    Y los paneles de consulta y resultado son visibles
    Y el ítem de menú "Histórico" es visible

  Escenario: Usuario sin sesión intenta acceder a Histórico
    Dado que no hay usuario en sesión (Session("Utilizador") vacío)
    Cuando el usuario intenta acceder a la página "Historico"
    Entonces el acceso es denegado
    Y los paneles de consulta y resultado NO son visibles

  @bug
  Escenario: Defecto substring - Usuario "ana" autorizado indebidamente
    Dado que la configuración "AcessoDeConfiguracao" es "management"
    Y el usuario actual es "ana"
    Cuando se verifica el acceso usando IndexOf("ana") en "management"
    Entonces el sistema legacy PERMITE el acceso (defecto - "ana" está en "management")
    Pero el sistema modern DENIEGA el acceso correctamente (match exacto)

  @characterization
  Escenario: Comparación Legacy vs Modern - Usuario autorizado
    Dado que la configuración "AcessoDeConfiguracao" es "ajsfernandes;tzcorreia"
    Y el usuario actual es "ajsfernandes"
    Cuando se verifica el acceso en el sistema Legacy
    Y se verifica el acceso en el sistema Modern con los mismos parámetros
    Entonces ambos sistemas permiten el acceso

  @characterization
  Escenario: Comparación Legacy vs Modern - Usuario NO autorizado
    Dado que la configuración "AcessoDeConfiguracao" es "ajsfernandes;tzcorreia"
    Y el usuario actual es "usuario_no_autorizado"
    Cuando se verifica el acceso en el sistema Legacy
    Y se verifica el acceso en el sistema Modern con los mismos parámetros
    Entonces ambos sistemas deniegan el acceso
