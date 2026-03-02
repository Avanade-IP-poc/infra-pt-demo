# CI/CD Pipeline Azure - Microsoft Learn Resources

Curated official Microsoft documentation for implementing CI/CD pipelines with GitHub Actions and Azure DevOps Pipelines for Azure deployments.

---

## GitHub Actions with Azure

### Core Documentation

- [GitHub Actions documentation](https://docs.github.com/en/actions) - Official GitHub Actions overview
- [Deploy to Azure using GitHub Actions](https://learn.microsoft.com/en-us/azure/developer/github/github-actions) - Azure deployment with GitHub Actions overview
- [GitHub Actions for Azure](https://learn.microsoft.com/en-us/azure/developer/github/github-actions-overview) - Azure-specific actions catalog

### Authentication

- [Use GitHub Actions to connect to Azure](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure) - OIDC authentication (Workload Identity Federation)
- [Configure OpenID Connect in Azure](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure) - GitHub OIDC setup guide
- [Azure Login action](https://github.com/Azure/login) - `Azure/login@v2` action documentation

### Azure Static Web Apps

- [Deploy to Azure Static Web Apps](https://learn.microsoft.com/en-us/azure/static-web-apps/github-actions-workflow) - Static Web Apps deployment workflow
- [Build configuration for Static Web Apps](https://learn.microsoft.com/en-us/azure/static-web-apps/build-configuration) - Build settings and output locations
- [Preview environments in Static Web Apps](https://learn.microsoft.com/en-us/azure/static-web-apps/review-publish-pull-requests) - PR preview deployments

### Azure Container Apps

- [Deploy to Azure Container Apps with GitHub Actions](https://learn.microsoft.com/en-us/azure/container-apps/github-actions) - Container Apps workflow guide
- [Build and deploy with GitHub Actions](https://learn.microsoft.com/en-us/azure/container-apps/github-actions-cli) - Azure CLI deployment approach
- [Continuous deployment with Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/overview) - Container Apps CI/CD overview

### Azure App Service

- [Deploy to Azure App Service](https://learn.microsoft.com/en-us/azure/app-service/deploy-github-actions) - App Service deployment workflows
- [Deployment slots with GitHub Actions](https://learn.microsoft.com/en-us/azure/app-service/deploy-staging-slots) - Blue-green deployment strategy
- [Azure Web Apps Deploy action](https://github.com/Azure/webapps-deploy) - `Azure/webapps-deploy@v3` action

### Infrastructure as Code

- [Deploy Bicep with GitHub Actions](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-github-actions) - Bicep deployment workflows
- [ARM Deploy action](https://github.com/Azure/arm-deploy) - `Azure/arm-deploy@v2` for Bicep/ARM templates
- [Deploy Terraform with GitHub Actions](https://learn.microsoft.com/en-us/azure/developer/terraform/deploy-terraform-using-github-actions) - Terraform workflow guide

---

## Azure DevOps Pipelines

### Core Documentation

- [Azure Pipelines documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/) - Azure DevOps Pipelines overview
- [YAML pipeline schema](https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema/) - Complete YAML reference
- [Classic vs YAML pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/get-started/pipelines-get-started) - Pipeline types comparison

### Multi-Stage Pipelines

- [Multi-stage pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/stages) - Stages, dependencies, conditions
- [Deployment jobs](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/deployment-jobs) - Deployment strategies (runOnce, rolling, canary)
- [Environments](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/environments) - Environment approvals and gates

### Azure Deployment Tasks

- [Azure Web App task](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/azure-web-app-v1) - Deploy to App Service
- [Azure Resource Manager Deployment task](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/azure-resource-manager-template-deployment-v3) - ARM/Bicep deployment
- [Azure CLI task](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/azure-cli-v2) - Azure CLI commands in pipeline

### Service Connections

- [Service connections](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints) - Azure service connections overview
- [Azure Resource Manager service connection](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/connect-to-azure) - ARM connection setup
- [Workload Identity Federation for Azure DevOps](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/connect-to-azure#create-an-azure-resource-manager-service-connection-using-workload-identity-federation) - OIDC authentication

### Infrastructure as Code

- [Terraform task](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/terraform-task-v4) - Terraform integration
- [Deploy Bicep files](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-azure-pipelines) - Bicep deployment guide
- [Pipeline templates](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/templates) - Reusable YAML templates

---

## Deployment Strategies

### Blue-Green Deployment

- [Blue-green deployment pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/deployment-stamp) - Architectural pattern overview
- [Deployment slots (App Service)](https://learn.microsoft.com/en-us/azure/app-service/deploy-staging-slots) - Staging slot configuration
- [Swap deployment slots](https://learn.microsoft.com/en-us/azure/app-service/deploy-staging-slots#swap-deployment-slots) - Slot swap mechanics

### Canary Deployment

- [Canary deployment pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/deployment-stamp#canary-deployment) - Gradual rollout strategy
- [Traffic splitting in Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/revisions-manage#traffic-splitting) - Container Apps revision traffic management
- [Azure Traffic Manager](https://learn.microsoft.com/en-us/azure/traffic-manager/traffic-manager-routing-methods#weighted-traffic-routing-method) - DNS-level traffic splitting

### Rolling Deployment

- [Rolling deployment strategy](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/deployment-jobs#rolling-deployment) - Azure DevOps rolling deployments
- [Update strategies for Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/revisions) - Revision management

---

## Container Registry Integration

### Azure Container Registry

- [Push images to ACR](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-docker-cli) - Docker push to ACR
- [Authenticate with ACR](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-authentication) - ACR authentication methods
- [ACR Tasks](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-tasks-overview) - Build images in ACR (cloud-based builds)

### Docker Build and Push

- [Build Docker images](https://learn.microsoft.com/en-us/azure/devops/pipelines/ecosystems/containers/build-image) - Azure Pipelines Docker task
- [Docker@2 task](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/docker-v2) - Docker task reference
- [GitHub Actions Docker Buildx](https://github.com/docker/build-push-action) - `docker/build-push-action@v5`

---

## Secrets Management

### GitHub Secrets

- [Encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) - GitHub repository/environment secrets
- [Using secrets in workflows](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions) - Secret access patterns

### Azure Key Vault

- [Azure Key Vault task](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/azure-key-vault-v2) - Fetch secrets in Azure Pipelines
- [Use Key Vault from GitHub Actions](https://learn.microsoft.com/en-us/azure/developer/github/github-key-vault) - Key Vault integration with GitHub Actions
- [Key Vault references in App Service](https://learn.microsoft.com/en-us/azure/app-service/app-service-key-vault-references) - Direct Key Vault integration

### Variable Groups

- [Variable groups in Azure DevOps](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups) - Shared variables across pipelines
- [Link Azure Key Vault to variable group](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups#link-secrets-from-an-azure-key-vault) - Key Vault-backed variable groups

---

## Testing and Quality Gates

### Testing in Pipelines

- [Run tests in pipeline](https://learn.microsoft.com/en-us/azure/devops/pipelines/ecosystems/dotnet-core#run-your-tests) - .NET test task
- [Publish test results](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/publish-test-results-v2) - Test result reporting
- [Code coverage](https://learn.microsoft.com/en-us/azure/devops/pipelines/test/review-code-coverage-results) - Code coverage visualization

### Approvals and Gates

- [Approvals in GitHub Actions](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#required-reviewers) - Environment protection rules
- [Approvals in Azure DevOps](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/approvals) - Manual approval configuration
- [Gates in Azure DevOps](https://learn.microsoft.com/en-us/azure/devops/pipelines/release/approvals/gates) - Automated quality gates

---

## Monitoring and Troubleshooting

### Pipeline Monitoring

- [Monitor pipeline runs](https://learn.microsoft.com/en-us/azure/devops/pipelines/reports/pipelinereport) - Azure Pipelines analytics
- [GitHub Actions logs](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/using-workflow-run-logs) - View workflow run logs
- [Deployment history](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/environments#deployment-history) - Azure DevOps environment history

### Troubleshooting

- [Troubleshoot pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/troubleshooting/troubleshooting) - Common pipeline issues
- [Debug GitHub Actions](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/enabling-debug-logging) - Enable debug logging
- [Pipeline caching](https://learn.microsoft.com/en-us/azure/devops/pipelines/release/caching) - Speed up builds with caching

---

## Best Practices

### Security

- [Security hardening for GitHub Actions](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions) - GitHub Actions security best practices
- [Secure Azure Pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/security/overview) - Azure DevOps security guidance
- [Least privilege service connections](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints#secure-a-service-connection) - RBAC for service connections

### Performance

- [Optimize pipeline performance](https://learn.microsoft.com/en-us/azure/devops/pipelines/build/triggers) - Trigger optimization, parallel jobs
- [Caching dependencies](https://docs.github.com/en/actions/using-workflows/caching-dependencies-to-speed-up-workflows) - GitHub Actions caching strategies
- [Self-hosted runners](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners) - Custom GitHub Actions runners

---

**Note**: Always reference official Microsoft Learn documentation for Azure deployment tasks and GitHub Docs for Actions-specific features. Cross-reference both when designing CI/CD pipelines for Azure workloads.
