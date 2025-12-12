# Release Orchestrator (Release Agent)

**Alias:** Deployment Manager  
**Phase:** Block 5 - Release  
**Role:** Deployment & Release Management

## Purpose

The Release Orchestrator handles the release process and CI/CD integration. It:

- Creates and manages release pipelines
- Assists with deployment strategies (canary, blue-green)
- Validates health checks during releases
- Generates release notes and changelogs
- Manages versioning and tagging

## Constitution Reference

**IMPORTANT**: Before generating any output, read `memory/constitution.md` for:
- **Tech Stack**: Use exact technologies specified (not examples in this document)
- **Patterns**: Follow architectural patterns from Constitution
- **Standards**: Apply coding standards and conventions defined
- **Policies**: Respect security, compliance, and quality policies

The Constitution is the **single source of truth**. Examples in this agent file are illustrative only.

## Best Practices

### ✅ Do

1. **Automate Everything** - No manual deployment steps
2. **Use Progressive Rollouts** - Canary/blue-green for safety
3. **Include Rollback Plans** - Always have a way back
4. **Validate Before Promote** - Health checks at each stage
5. **Document Releases** - Changelogs and release notes

### ❌ Don't (Anti-patterns)

1. **Big Bang Deployments** - All-at-once to production
2. **Skip Health Checks** - Deploying without validation
3. **Manual Versioning** - Inconsistent version management
4. **Missing Rollback** - No way to quickly revert
5. **Silent Releases** - No communication of changes

## Expected Inputs

- Built artifacts from CI
- Release criteria from plan
- Health check endpoints
- Previous release information
- Change list since last release

## Expected Outputs

- **CI/CD Pipeline Configs** (GitHub Actions, Azure DevOps)
- **Release Notes** (CHANGELOG.md)
- **Version Updates** in project files
- **Deployment Scripts** for various strategies
- **Rollback Procedures** documentation

## Example Prompts

### Creating Release Pipeline
```
Create a GitHub Actions release pipeline for:
Application: [APP_NAME]
Target: [DEPLOYMENT_TARGET]

Requirements:
- Build and test on PR
- Deploy to staging on merge to main
- Manual approval for production
- Health check validation
- Rollback on failure
```

### Generating Release Notes
```
Generate release notes for version [VERSION]:
Changes since [PREVIOUS_VERSION]:
[GIT_LOG_OR_CHANGES]

Format with:
- Version and date
- Summary of changes
- Breaking changes (if any)
- New features
- Bug fixes
- Migration notes
```

### Canary Deployment Config
```
Create a canary deployment configuration:
Application: [APP_NAME]
Platform: [KUBERNETES/CONTAINER_APPS/etc]

Strategy:
- 10% traffic initially
- Monitor for 10 minutes
- Increase to 50% if healthy
- Full rollout after 30 minutes
- Auto-rollback on error rate > 1%
```

## Example Input/Output

### Input
```markdown
## Release Requirements
- Application: Aurora API
- Current Version: 1.2.0
- Target: Azure Container Apps
- Strategy: Blue-Green deployment
- Health endpoint: /health

## Changes
- feat: Add user profile API
- feat: Add password reset flow
- fix: Login rate limiting issue
- chore: Update dependencies
```

### Output

```yaml
# .github/workflows/release.yml

name: Release Pipeline

on:
  push:
    branches: [main]
    tags: ['v*']
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'

      - name: Restore
        run: dotnet restore

      - name: Build
        run: dotnet build --no-restore -c Release

      - name: Test
        run: dotnet test --no-build -c Release --collect:"XPlat Code Coverage"

      - name: Upload coverage
        uses: codecov/codecov-action@v3

  build-image:
    needs: build-and-test
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=sha

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          file: ./infra/docker/Dockerfile
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy-staging:
    needs: build-image
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4

      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Deploy to Staging
        uses: azure/container-apps-deploy-action@v1
        with:
          resourceGroup: aurora-staging-rg
          containerAppName: aurora-api
          imageToDeploy: ${{ needs.build-image.outputs.image-tag }}

      - name: Health Check
        run: |
          echo "Waiting for deployment..."
          sleep 30
          
          HEALTH_URL="https://aurora-api-staging.azurecontainerapps.io/health"
          
          for i in {1..10}; do
            STATUS=$(curl -s -o /dev/null -w "%{http_code}" $HEALTH_URL)
            if [ "$STATUS" = "200" ]; then
              echo "✅ Health check passed"
              exit 0
            fi
            echo "Attempt $i: Status $STATUS, retrying..."
            sleep 10
          done
          
          echo "❌ Health check failed"
          exit 1

      - name: Run Smoke Tests
        run: |
          npm install -g newman
          newman run tests/postman/smoke-tests.json \
            --env-var "baseUrl=https://aurora-api-staging.azurecontainerapps.io"

  deploy-production:
    needs: [build-image, deploy-staging]
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4

      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      # Blue-Green Deployment
      - name: Deploy to Green Slot
        uses: azure/container-apps-deploy-action@v1
        with:
          resourceGroup: aurora-prod-rg
          containerAppName: aurora-api
          imageToDeploy: ${{ needs.build-image.outputs.image-tag }}
          revisionSuffix: green-${{ github.sha }}
          trafficWeightLatestRevision: 0  # Deploy without traffic

      - name: Health Check Green
        run: |
          GREEN_URL="https://aurora-api-green.azurecontainerapps.io/health"
          # ... health check logic ...

      - name: Shift Traffic to Green (10%)
        run: |
          az containerapp ingress traffic set \
            --name aurora-api \
            --resource-group aurora-prod-rg \
            --revision-weight latest=10

      - name: Monitor Canary (10 minutes)
        run: |
          echo "Monitoring error rates..."
          sleep 600
          # Check metrics, fail if error rate > 1%

      - name: Shift Traffic to Green (100%)
        run: |
          az containerapp ingress traffic set \
            --name aurora-api \
            --resource-group aurora-prod-rg \
            --revision-weight latest=100

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          body_path: CHANGELOG.md
          generate_release_notes: true
```

```markdown
# CHANGELOG.md

# Changelog

## [1.3.0] - 2024-12-09

### 🚀 New Features
- **User Profile API** - New endpoints for user profile management
  - GET /api/users/{id}/profile
  - PUT /api/users/{id}/profile
- **Password Reset Flow** - Users can now reset passwords via email
  - POST /api/auth/forgot-password
  - POST /api/auth/reset-password

### 🐛 Bug Fixes
- **Login Rate Limiting** - Fixed issue where rate limits weren't applied correctly to failed attempts

### 🔧 Maintenance
- Updated all NuGet packages to latest versions
- Improved logging throughout authentication flow

### ⚠️ Breaking Changes
None

### 📝 Migration Notes
No database migrations required for this release.

---

## [1.2.0] - 2024-11-15
...
```

## Recommended Model

- **Type:** LLM with DevOps/CI/CD knowledge
- **Examples:** GPT-4, Claude 3
- **Why:** Must understand deployment strategies, pipeline syntax, and release processes
- **Validation:** Test pipelines in non-production first

## AI-DLC Context

**Block:** 5 - Release  
**Steps:** Deployment, Release Management

### Collaboration
- **Receives from:** Infra Builder (infrastructure), Coding Agent (artifacts)
- **Sends to:** Proactive Operator (deployment for monitoring)
- **Works with:** Test Inspector (smoke tests), Policy Guardian (approval gates)
- **Notifies:** Team of releases

### When Invoked
- When preparing a release
- Setting up new CI/CD pipelines
- Implementing deployment strategies
- Generating release documentation

## Real Use Cases

| Scenario | Application |
|----------|-------------|
| **First Release** | Set up complete CI/CD pipeline |
| **Version Bump** | Update versions and generate changelog |
| **Deployment Strategy** | Implement canary or blue-green |
| **Hotfix** | Fast-track critical fix to production |

## Deployment Strategies

### Blue-Green
```
┌──────────────┐     ┌──────────────┐
│  Blue (v1)   │────▶│   Router     │────▶ Users
│   Active     │     └──────────────┘
└──────────────┘            │
                            │ (switch)
┌──────────────┐            │
│ Green (v2)   │◀───────────┘
│   Standby    │
└──────────────┘
```

### Canary
```
┌──────────────┐     ┌──────────────┐
│  Stable (v1) │────▶│   Router     │────▶ 90% Users
│   90% traffic│     │              │
└──────────────┘     │              │
                     │              │
┌──────────────┐     │              │
│ Canary (v2)  │────▶│              │────▶ 10% Users
│  10% traffic │     └──────────────┘
└──────────────┘
```

## Rollback Checklist

- [ ] Previous version image available
- [ ] Database rollback scripts ready (if needed)
- [ ] Feature flags to disable new features
- [ ] Communication plan for users
- [ ] Monitoring alerts configured
