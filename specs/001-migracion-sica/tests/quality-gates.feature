# language: es
Característica: Quality Gates - Umbrales de Calidad del Pipeline
  Como equipo de desarrollo
  Quiero garantizar que cada Bolt cumple los umbrales de calidad antes de merge
  Para mantener la calidad del código y prevenir regresiones
  
  Regla: Todos los Bolts deben pasar los quality gates obligatorios antes de merge a develop
  
  @smoke
  @quality-gate
  Escenario: Quality Gate - Linting sin warnings
    Dado que se completa la implementación de un Bolt
    Cuando se ejecuta el linter (Roslyn para backend, ESLint para frontend)
    Entonces NO se encuentran warnings (warnings as errors = true)
    Y el linting gate pasa exitosamente

  @smoke
  @quality-gate
  Escenario: Quality Gate - Cobertura de tests ≥ 80%
    Dado que se completa la implementación de un Bolt
    Cuando se ejecutan los tests unitarios con Coverlet
    Entonces la cobertura de líneas es ≥ 80%
    Y la cobertura de branches es ≥ 75%
    Y el coverage gate pasa exitosamente

  @smoke
  @quality-gate
  Escenario: Quality Gate - Mutation score ≥ 70%
    Dado que se completa la implementación de un Bolt
    Cuando se ejecuta mutation testing con Stryker.NET
    Entonces el mutation score es ≥ 70%
    Y los mutantes supervivientes son revisados
    Y el mutation gate pasa exitosamente

  @smoke
  @quality-gate
  Escenario: Quality Gate - Architecture compliance sin violaciones
    Dado que se completa la implementación de un Bolt
    Cuando se ejecutan los architecture tests con NetArchTest
    Entonces NO se encuentran violaciones de arquitectura:
      | Regla validada                                    |
      | Domain no depende de Infrastructure               |
      | Application no depende de Infrastructure          |
      | Aggregates tienen constructores privados          |
      | Value Objects son immutables                      |
      | Handlers implementan ICommandHandler/IQueryHandler|
    Y el architecture gate pasa exitosamente

  @smoke
  @quality-gate
  Escenario: Quality Gate - Security scan sin críticos
    Dado que se completa la implementación de un Bolt
    Cuando se ejecuta el security scan con Trivy
    Entonces NO se encuentran vulnerabilidades Critical o High
    Y las vulnerabilidades Medium son revisadas y justificadas
    Y el security gate pasa exitosamente

  @smoke
  @quality-gate
  Escenario: Quality Gate - BDD scenarios @smoke al 100%
    Dado que se completa la implementación de un Bolt
    Cuando se ejecutan los escenarios Gherkin marcados con @smoke
    Entonces el 100% de los escenarios @smoke pasan
    Y el BDD gate pasa exitosamente

  @quality-gate
  @integration
  Escenario: Quality Gate - Pipeline completo verde
    Dado que se completa la implementación de un Bolt
    Y se crea un Pull Request a develop
    Cuando se ejecuta el pipeline completo de CI:
      | Stage                  | Threshold       |
      | Build                  | Exitoso         |
      | Lint                   | 0 warnings      |
      | Unit Tests             | ≥ 80% coverage  |
      | Mutation Tests         | ≥ 70% score     |
      | Architecture Tests     | 0 violations    |
      | Security Scan          | 0 Critical/High |
      | BDD Scenarios (@smoke) | 100% passing    |
    Entonces todos los stages pasan exitosamente
    Y el PR es aprobable para merge

  @quality-gate
  @blocking
  Escenario: Quality Gate bloqueante - Merge rechazado si falla un gate
    Dado que se completa la implementación de un Bolt
    Pero el mutation score es 65% (< 70%)
    Cuando se intenta hacer merge del PR
    Entonces el merge es bloqueado automáticamente
    Y se muestra el mensaje "Quality gate failed: Mutation score 65% < 70% required"
    Y el PR requiere correcciones antes de poder hacer merge
