---
name: github-actions-templates
description: Create production-ready GitHub Actions workflows for automated testing, building, and deploying .NET 8 Web API, React SPA, Azure Functions, and Bicep IaC. Use when setting up CI/CD with GitHub Actions, automating development workflows, or creating reusable workflow templates for SICA. Triggers => "GitHub Actions", "workflow", "CI/CD", "pipeline", "deploy workflow", "dotnet workflow", "react workflow", "bicep pipeline", "reusable workflow".
provisioned_from: .boltf/available-skills/github/github-actions-templates
provisioned_at: "2026-06-19"
project: SICA Modernization
---

# GitHub Actions Templates — SICA Modernization

Production-ready GitHub Actions workflow templates for SICA's CI/CD:
.NET 8 Web API, React SPA, Azure Functions, Bicep IaC.

## When to Use

- Scaffolding new GitHub Actions workflows
- Setting up multi-environment deployments (dev/uat/pre/prod)
- Creating reusable workflows for DRY CI/CD
- Adding security scans, coverage gates, or IaC validation to pipelines

## Workflow Inventory

| Workflow                | Trigger                    | Output              |
| ----------------------- | -------------------------- | ------------------- |
| `api-ci.yml`            | push/PR to develop & main  | Build, test, deploy |
| `spa-ci.yml`            | push/PR to develop & main  | Build, test, deploy |
| `functions-ci.yml`      | push/PR to develop & main  | Build, test, deploy |
| `infra-ci.yml`          | push/PR to develop & main  | Lint, what-if, cost |
| `release.yml`           | manual / tag push          | Release artifact    |

## Reusable Workflow Pattern

```yaml
# .github/workflows/reusable-dotnet-build.yml
name: Reusable .NET Build

on:
  workflow_call:
    inputs:
      dotnet-version:
        type: string
        default: '8.x'
      project-path:
        type: string
        required: true
      coverage-threshold:
        type: number
        default: 80

jobs:
  build-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: ${{ inputs.dotnet-version }}

      - name: Restore
        run: dotnet restore ${{ inputs.project-path }}

      - name: Build (warnings as errors)
        run: dotnet build ${{ inputs.project-path }} --no-restore -warnaserror

      - name: Unit Tests + Coverage
        run: |
          dotnet test ${{ inputs.project-path }} \
            --filter "Category=Unit" \
            /p:CollectCoverage=true \
            /p:CoverageThreshold=${{ inputs.coverage-threshold }} \
            /p:ThresholdType=line \
            /p:CoverletOutputFormat=cobertura

      - name: Upload coverage
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: '**/coverage.cobertura.xml'
```

## Callers using Reusable Workflow

```yaml
# .github/workflows/api-ci.yml
name: API CI
on: [push, pull_request]

jobs:
  build:
    uses: ./.github/workflows/reusable-dotnet-build.yml
    with:
      project-path: 'Sica.sln'
      coverage-threshold: 80

  deploy-dev:
    needs: build
    if: github.ref == 'refs/heads/develop'
    uses: ./.github/workflows/reusable-azure-deploy.yml
    with:
      app-name: 'sica-api-dev'
      environment: 'dev'
    secrets: inherit
```

## OIDC Azure Authentication (No Secrets)

```yaml
# Federated credentials — no client secret stored in GitHub
permissions:
  id-token: write
  contents: read

steps:
  - name: Azure Login (OIDC)
    uses: azure/login@v2
    with:
      client-id: ${{ vars.AZURE_CLIENT_ID }}
      tenant-id: ${{ vars.AZURE_TENANT_ID }}
      subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}
```

## Security Scan (OWASP / Snyk)

```yaml
- name: OWASP Dependency Check
  uses: dependency-check/Dependency-Check_Action@main
  with:
    project: 'Sica'
    path: '.'
    format: 'HTML'
    args: --failOnCVSS 7

- name: Snyk Security Scan
  uses: snyk/actions/dotnet@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
  with:
    args: --severity-threshold=high
```

## Mutation Testing Gate

```yaml
- name: Mutation Testing (Stryker)
  run: |
    dotnet tool install -g dotnet-stryker
    dotnet stryker \
      --threshold-high 80 \
      --threshold-low 70 \
      --threshold-break 60 \
      --output StrykerOutput
```

## Environment Protection Rules

```yaml
# Recommended environment settings in GitHub:
# dev   → no approval required, auto-deploy from develop
# uat   → no approval required, auto-deploy from release/*
# pre   → 1 reviewer, manual trigger
# prod  → 2 reviewers, manual approval
```

## Artifacts & Cache Strategy

```yaml
- name: Cache NuGet packages
  uses: actions/cache@v4
  with:
    path: ~/.nuget/packages
    key: ${{ runner.os }}-nuget-${{ hashFiles('**/*.csproj') }}
    restore-keys: |
      ${{ runner.os }}-nuget-

- name: Cache npm
  uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}
```

## References (source)

`.boltf/available-skills/github/github-actions-templates/`
- `assets/test-workflow.yml`
- `assets/deploy-workflow.yml`
- `assets/matrix-build.yml`
