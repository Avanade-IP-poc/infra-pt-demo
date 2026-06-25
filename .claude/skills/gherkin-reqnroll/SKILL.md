---
name: gherkin-reqnroll
description: BDD with Gherkin syntax and Reqnroll for .NET acceptance testing. Use when writing acceptance tests from user stories and acceptance criteria, creating executable specifications, or generating Reqnroll step definitions for .NET projects. Triggers => "Gherkin", "Reqnroll", "BDD", "acceptance tests", "feature file", "Given When Then", "step definitions", "executable spec".
provisioned_from: .boltf/available-skills/functional-tests/gherkin-reqnroll
provisioned_at: "2026-06-19"
project: SICA Modernization
---

# Gherkin & Reqnroll BDD Testing

## When to Use

- Writing acceptance tests from SICA user stories / ACs
- Creating executable specifications for migration features
- Generating Reqnroll step definitions for .NET projects
- Automating acceptance testing per Bolt Framework @smoke classification

## Quick Start

```bash
dotnet add package Reqnroll
dotnet add package Reqnroll.xUnit
dotnet add package Microsoft.AspNetCore.Mvc.Testing
```

Feature file location: `specs/{feature-name}/tests/{feature}.feature`

## Feature File Structure

```gherkin
# language: en
@access @US-001
Feature: Access Control
  As a security operator
  I want to manage card access to zones
  So that I can control entry to secured areas

  Background:
    Given the SICA system is running
    And the database is initialized

  @smoke @AC-001.1 @happy-path
  Scenario: Activate card for zone access
    Given a card "CARD-001" exists in the system
    And zone "ZONE-A" requires card access
    When I activate card "CARD-001" for zone "ZONE-A"
    Then the access log shows "CARD-001" entered "ZONE-A"
    And the access status is "ACTIVE"

  @AC-001.2 @validation
  Scenario: Reject deactivated card
    Given card "CARD-DISABLED" is deactivated
    When card "CARD-DISABLED" attempts to access zone "ZONE-A"
    Then access is denied
    And an alarm is triggered for zone "ZONE-A"
```

## Step Definitions (.NET / Reqnroll)

```csharp
using Reqnroll;
using FluentAssertions;

[Binding]
public class AccessControlSteps
{
    private readonly ScenarioContext _context;
    private readonly HttpClient _client;
    private HttpResponseMessage _response = null!;

    public AccessControlSteps(ScenarioContext context, SicaWebApplicationFactory factory)
    {
        _context = context;
        _client = factory.CreateClient();
    }

    [Given(@"a card ""(.*)"" exists in the system")]
    public async Task GivenCardExists(string cardId)
    {
        // Seed test data
        await SeedCardAsync(cardId);
        _context["cardId"] = cardId;
    }

    [When(@"I activate card ""(.*)"" for zone ""(.*)""")]
    public async Task WhenActivateCard(string cardId, string zoneId)
    {
        _response = await _client.PostAsJsonAsync(
            "/api/v1/access/activate",
            new { CardId = cardId, ZoneId = zoneId });
    }

    [Then(@"the access status is ""(.*)""")]
    public async Task ThenAccessStatus(string expectedStatus)
    {
        _response.EnsureSuccessStatusCode();
        var body = await _response.Content.ReadFromJsonAsync<AccessResponse>();
        body!.Status.Should().Be(expectedStatus);
    }
}
```

## @smoke Classification Rules (Bolt Framework)

| Tag         | When to Apply                                  |
| ----------- | ---------------------------------------------- |
| `@smoke`    | Critical happy-path; blocks deployment if fail |
| `@regression`| Full suite on every PR merge                  |
| `@manual`   | Never runs in CI                               |

**Rule for SICA**: All scenarios in `MonSeg.aspx`, `Acessos.ascx`, `ActivarCartoes.ascx`
migrations must have at least one `@smoke` scenario.

## reqnroll.json

```json
{
  "language": { "feature": "en" },
  "bindingCulture": { "name": "en-US" },
  "trace": {
    "traceSuccessfulSteps": true,
    "traceTimings": true
  }
}
```

## Best Practices

- ✅ One scenario per acceptance criterion — map `@AC-NNN.N` tags
- ✅ `Background` for common preconditions
- ✅ `Scenario Outline` + `Examples` for data-driven tests
- ✅ Tag with: `@feature @US-id @AC-id @smoke|@regression`
- ✅ Link to spec: comment `# Spec: ../requirements/requirements.md`
- ❌ Don't embed implementation details in Gherkin steps
- ❌ Don't share step definition state via static fields

## References (source)

`.boltf/available-skills/functional-tests/gherkin-reqnroll/`
