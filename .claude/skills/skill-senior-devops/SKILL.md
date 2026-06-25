---
name: skill-senior-devops
description: Comprehensive DevOps for CI/CD, infrastructure automation (Bicep, Terraform), containerization, and Azure cloud platforms. Use when setting up GitHub Actions pipelines, deploying to Azure App Service or Functions, managing Bicep IaC, implementing monitoring, or optimizing deployments for SICA. Triggers => "CI/CD pipeline", "Bicep", "GitHub Actions", "deploy Azure", "infrastructure as code", "IaC", "DevOps automation", "Azure DevOps", "pipeline setup", "deployment strategy".
provisioned_from: .boltf/available-skills/skill-senior-devops
provisioned_at: "2026-06-19"
project: SICA Modernization
---

# Senior DevOps — Azure + GitHub Actions + Bicep (SICA)

Complete DevOps toolkit for SICA migration: GitHub Actions CI/CD pipelines, Bicep IaC,
Azure App Service deployments, and Blue-Green strategy.

## When to Use

- Creating GitHub Actions workflows for .NET 8 Web API, React SPA, or Azure Functions
- Writing Bicep modules for SICA Azure resources
- Implementing Blue-Green deployments via Azure Deployment Slots
- Setting up Checkov security scans and Infracost estimates
- Configuring multi-environment deployment (dev/uat/pre/prod)

## GitHub Actions — .NET 8 Web API Pipeline

```yaml
# .github/workflows/api-ci.yml
name: API CI/CD

on:
  push:
    branches: [develop, main]
  pull_request:
    branches: [develop, main]

jobs:
  build-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET 8
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.x'

      - name: Restore
        run: dotnet restore Sica.sln

      - name: Build
        run: dotnet build Sica.sln --no-restore -warnaserror

      - name: Lint (format check)
        run: dotnet format --verify-no-changes Sica.sln

      - name: Unit tests + coverage
        run: |
          dotnet test --filter "Category=Unit" \
            /p:CollectCoverage=true \
            /p:CoverageThreshold=80 \
            /p:ThresholdType=line \
            /p:CoverletOutputFormat=cobertura

      - name: Integration tests
        run: |
          dotnet test --filter "Category=Integration" \
            -e USE_TESTCONTAINERS=true

      - name: Security scan (Snyk / OWASP)
        uses: snyk/actions/dotnet@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

  deploy-dev:
    needs: build-test
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    environment: dev
    steps:
      - uses: actions/checkout@v4
      - name: Azure Login
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Deploy to App Service (slot)
        uses: azure/webapps-deploy@v3
        with:
          app-name: sica-api-dev
          slot-name: staging
          package: ./publish
```

## GitHub Actions — React SPA Pipeline

```yaml
# .github/workflows/spa-ci.yml
jobs:
  build-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint
      - run: npm run type-check
      - run: npm run test:coverage -- --coverage.thresholds.lines=80
      - run: npm run build
```

## Bicep — SICA Workload Infrastructure

```bicep
// infra/main.bicep
param environment string = 'dev'
param location string = resourceGroup().location

module appService 'modules/app-service.bicep' = {
  name: 'appService'
  params: {
    name: 'sica-api-${environment}'
    location: location
    sku: environment == 'prod' ? 'S2' : 'B1'
  }
}

module sqlDatabase 'modules/sql-database.bicep' = {
  name: 'sqlDatabase'
  params: {
    serverName: 'sica-sql-${environment}'
    databaseName: 'SicaDb'
    location: location
  }
}

module keyVault 'modules/key-vault.bicep' = {
  name: 'keyVault'
  params: {
    name: 'sica-kv-${environment}'
    location: location
  }
}
```

## Bicep Validation in CI

```yaml
- name: Bicep lint
  run: az bicep build --file infra/main.bicep

- name: What-if (dev)
  run: |
    az deployment group what-if \
      --resource-group sica-rg-dev \
      --template-file infra/main.bicep \
      --parameters @infra/environments/dev.bicepparam

- name: Checkov security scan
  uses: bridgecrewio/checkov-action@v12
  with:
    directory: infra/
    framework: bicep

- name: Infracost estimate
  uses: infracost/actions/setup@v3
  with:
    api-key: ${{ secrets.INFRACOST_API_KEY }}
```

## Blue-Green Deployment (Azure Slots)

```bash
# Deploy to staging slot
az webapp deployment source config-zip \
  --resource-group sica-rg-prod \
  --name sica-api-prod \
  --slot staging \
  --src ./publish.zip

# Health check on staging
curl -f https://sica-api-prod-staging.azurewebsites.net/health/ready

# Swap slots (zero-downtime)
az webapp deployment slot swap \
  --resource-group sica-rg-prod \
  --name sica-api-prod \
  --slot staging \
  --target-slot production
```

## Environment Secrets (GitHub)

| Secret                  | Used by               |
| ----------------------- | --------------------- |
| `AZURE_CLIENT_ID`       | GitHub Actions OIDC   |
| `AZURE_TENANT_ID`       | GitHub Actions OIDC   |
| `AZURE_SUBSCRIPTION_ID` | GitHub Actions OIDC   |
| `SNYK_TOKEN`            | Security scan         |
| `INFRACOST_API_KEY`     | Cost estimation       |

Use **OIDC federation** (not client secrets) for GitHub Actions → Azure auth.

## References (source)

`.boltf/available-skills/skill-senior-devops/`
- `references/cicd_pipeline_guide.md`
- `references/infrastructure_as_code.md`
- `references/deployment_strategies.md`
