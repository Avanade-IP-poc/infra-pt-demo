# CI/CD Pipeline Azure - Code Examples

Complete examples demonstrating GitHub Actions and Azure DevOps Pipelines for Azure deployment automation with infrastructure as code, multi-stage environments, and deployment strategies.

---

## Example 1: GitHub Actions - Azure Static Web Apps Deployment

**Pattern**: Automatic deployment of React/Angular/Vue SPA to Azure Static Web Apps on push to main branch, plus preview environments for pull requests.

**When to Use**: Static frontend apps (React, Angular, Vue, Blazor WebAssembly) deployed to Azure Static Web Apps with automatic PR preview environments.

```yaml
# .github/workflows/azure-static-web-apps.yml
name: Deploy to Azure Static Web Apps

on:
  push:
    branches:
      - main
  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches:
      - main

jobs:
  build_and_deploy:
    if: github.event_name == 'push' || (github.event_name == 'pull_request' && github.event.action != 'closed')
    runs-on: ubuntu-latest
    name: Build and Deploy
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: true

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm run test -- --coverage --watchAll=false

      - name: Build application
        run: npm run build
        env:
          CI: true
          REACT_APP_API_URL: ${{ secrets.API_URL }}

      - name: Deploy to Azure Static Web Apps
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: 'upload'
          app_location: '/'
          api_location: 'api'
          output_location: 'build'

  close_pull_request:
    if: github.event_name == 'pull_request' && github.event.action == 'closed'
    runs-on: ubuntu-latest
    name: Close Pull Request
    steps:
      - name: Close Pull Request
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          action: 'close'
```

**Explanation**: Azure Static Web Apps Action automatically provisions preview environments for PRs (unique URL per PR) and deploys to production on push to main. No manual environment management. Secrets stored in GitHub repository settings. Test failures block deployment.

---

## Example 2: GitHub Actions - Azure Container Apps Deployment

**Pattern**: Build Docker image, push to Azure Container Registry (ACR), deploy to Azure Container Apps with infrastructure provisioned via Bicep.

**When to Use**: Containerized applications (APIs, microservices, backend services) deployed to Azure Container Apps with automatic scaling and ingress.

```yaml
# .github/workflows/azure-container-apps.yml
name: Deploy to Azure Container Apps

on:
  push:
    branches: [main]
  workflow_dispatch:

env:
  AZURE_RESOURCE_GROUP: rg-myapp-prod
  AZURE_CONTAINER_APP_NAME: ca-api-prod
  ACR_NAME: acrmyappprod
  IMAGE_NAME: myapp-api

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read

    steps:
      - uses: actions/checkout@v4

      - name: Azure Login (OIDC)
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Azure Container Registry
        run: |
          az acr login --name ${{ env.ACR_NAME }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: ./src
          push: true
          tags: |
            ${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:${{ github.sha }}
            ${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:latest
          cache-from: type=registry,ref=${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:buildcache
          cache-to: type=registry,ref=${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:buildcache,mode=max

      - name: Deploy Bicep infrastructure
        uses: azure/arm-deploy@v2
        with:
          subscriptionId: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          resourceGroupName: ${{ env.AZURE_RESOURCE_GROUP }}
          template: ./infra/main.bicep
          parameters: >
            containerAppName=${{ env.AZURE_CONTAINER_APP_NAME }}
            containerImage=${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:${{ github.sha }}
            acrName=${{ env.ACR_NAME }}
          failOnStdErr: false

      - name: Deploy Container App revision
        run: |
          az containerapp update \
            --name ${{ env.AZURE_CONTAINER_APP_NAME }} \
            --resource-group ${{ env.AZURE_RESOURCE_GROUP }} \
            --image ${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:${{ github.sha }} \
            --set-env-vars "COMMIT_SHA=${{ github.sha }}" "BUILD_ID=${{ github.run_number }}"

      - name: Verify deployment
        run: |
          FQDN=$(az containerapp show \
            --name ${{ env.AZURE_CONTAINER_APP_NAME }} \
            --resource-group ${{ env.AZURE_RESOURCE_GROUP }} \
            --query properties.configuration.ingress.fqdn -o tsv)
          echo "Application deployed to https://${FQDN}"

          # Health check
          curl -f https://${FQDN}/health || exit 1
```

**Explanation**: OIDC authentication eliminates long-lived secrets. Docker Buildx with layer caching speeds up builds. Bicep provisions infrastructure (Container App, Managed Environment, ACR integration). Container Apps automatically creates new revision with zero-downtime deployment. Health check verifies deployment success.

---

## Example 3: GitHub Actions - Deployment Slots (Blue-Green Deployment)

**Pattern**: Deploy to Azure App Service staging slot, run smoke tests, swap to production slot for zero-downtime deployment with rollback capability.

**When to Use**: Azure App Service deployments requiring zero-downtime, smoke testing in staging environment before production, quick rollback capability.

```yaml
# .github/workflows/azure-app-service-slots.yml
name: Deploy with Blue-Green Strategy

on:
  push:
    branches: [main]

env:
  AZURE_WEBAPP_NAME: app-myapi-prod
  AZURE_WEBAPP_PACKAGE_PATH: './publish'
  DOTNET_VERSION: '8.0.x'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: ${{ env.DOTNET_VERSION }}

      - name: Restore dependencies
        run: dotnet restore

      - name: Build
        run: dotnet build --configuration Release --no-restore

      - name: Test
        run: dotnet test --no-build --verbosity normal --collect:"XPlat Code Coverage"

      - name: Publish
        run: dotnet publish --configuration Release --output ${{ env.AZURE_WEBAPP_PACKAGE_PATH }}

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: webapp
          path: ${{ env.AZURE_WEBAPP_PACKAGE_PATH }}

  deploy-to-staging:
    runs-on: ubuntu-latest
    needs: build
    environment:
      name: staging
      url: ${{ steps.deploy.outputs.webapp-url }}

    steps:
      - name: Download artifact
        uses: actions/download-artifact@v4
        with:
          name: webapp

      - name: Azure Login
        uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Deploy to staging slot
        id: deploy
        uses: azure/webapps-deploy@v3
        with:
          app-name: ${{ env.AZURE_WEBAPP_NAME }}
          slot-name: staging
          package: .

      - name: Get staging slot URL
        run: |
          STAGING_URL=$(az webapp show \
            --name ${{ env.AZURE_WEBAPP_NAME }} \
            --resource-group ${{ secrets.AZURE_RESOURCE_GROUP }} \
            --slot staging \
            --query "defaultHostName" -o tsv)
          echo "STAGING_URL=https://${STAGING_URL}" >> $GITHUB_ENV

      - name: Run smoke tests on staging
        run: |
          # Health check
          curl -f ${{ env.STAGING_URL }}/health || exit 1

          # API endpoint validation
          RESPONSE=$(curl -s ${{ env.STAGING_URL }}/api/version)
          echo "Version response: $RESPONSE"

          # Expected version check
          if [[ "$RESPONSE" != *"${{ github.sha }}"* ]]; then
            echo "Version mismatch! Expected ${{ github.sha }}"
            exit 1
          fi

  swap-to-production:
    runs-on: ubuntu-latest
    needs: deploy-to-staging
    environment:
      name: production
      url: https://${{ env.AZURE_WEBAPP_NAME }}.azurewebsites.net

    steps:
      - name: Azure Login
        uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Swap staging to production
        run: |
          az webapp deployment slot swap \
            --name ${{ env.AZURE_WEBAPP_NAME }} \
            --resource-group ${{ secrets.AZURE_RESOURCE_GROUP }} \
            --slot staging \
            --target-slot production

      - name: Verify production deployment
        run: |
          PROD_URL="https://${{ env.AZURE_WEBAPP_NAME }}.azurewebsites.net"
          echo "Production URL: $PROD_URL"

          # Wait for swap to complete (Azure DNS propagation)
          sleep 30

          # Health check
          curl -f ${PROD_URL}/health || exit 1

          # Version verification
          RESPONSE=$(curl -s ${PROD_URL}/api/version)
          if [[ "$RESPONSE" != *"${{ github.sha }}"* ]]; then
            echo "Production version mismatch! Rolling back..."
            az webapp deployment slot swap \
              --name ${{ env.AZURE_WEBAPP_NAME }} \
              --resource-group ${{ secrets.AZURE_RESOURCE_GROUP }} \
              --slot production \
              --target-slot staging
            exit 1
          fi

          echo "Deployment successful!"
```

**Explanation**: Three-job workflow: build artifact → deploy to staging slot → swap to production after smoke tests pass. GitHub Environments track deployment history. Staging slot receives traffic for validation. Slot swap is instant (DNS pointer swap). Automatic rollback on production verification failure. Previous production version remains in staging slot for quick rollback via Azure Portal if issues discovered post-deployment.

---

## Example 4: Azure DevOps Pipeline - Multi-Stage YAML with Environments

**Pattern**: Azure DevOps multi-stage pipeline with artifact build, dev deployment, staging deployment with approval gate, production deployment.

**When to Use**: Azure DevOps organization, multi-environment promotion (dev → staging → prod), manual approval gates between environments, Enterprise Azure integration.

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main
      - develop

pool:
  vmImage: 'ubuntu-latest'

variables:
  buildConfiguration: 'Release'
  azureSubscription: 'Azure-Service-Connection'

stages:
  - stage: Build
    displayName: 'Build and Test'
    jobs:
      - job: BuildJob
        displayName: 'Build Application'
        steps:
          - task: UseDotNet@2
            displayName: 'Install .NET SDK'
            inputs:
              packageType: 'sdk'
              version: '8.0.x'

          - task: DotNetCoreCLI@2
            displayName: 'Restore NuGet packages'
            inputs:
              command: 'restore'
              projects: '**/*.csproj'

          - task: DotNetCoreCLI@2
            displayName: 'Build solution'
            inputs:
              command: 'build'
              arguments: '--configuration $(buildConfiguration) --no-restore'

          - task: DotNetCoreCLI@2
            displayName: 'Run unit tests'
            inputs:
              command: 'test'
              arguments: '--configuration $(buildConfiguration) --no-build --collect:"XPlat Code Coverage"'
              publishTestResults: true

          - task: PublishCodeCoverageResults@2
            displayName: 'Publish code coverage'
            inputs:
              codeCoverageTool: 'Cobertura'
              summaryFileLocation: '$(Agent.TempDirectory)/**/coverage.cobertura.xml'

          - task: DotNetCoreCLI@2
            displayName: 'Publish application'
            inputs:
              command: 'publish'
              publishWebProjects: true
              arguments: '--configuration $(buildConfiguration) --output $(Build.ArtifactStagingDirectory)'
              zipAfterPublish: true

          - task: PublishPipelineArtifact@1
            displayName: 'Publish artifact'
            inputs:
              targetPath: '$(Build.ArtifactStagingDirectory)'
              artifactName: 'webapp'
              publishLocation: 'pipeline'

  - stage: DeployDev
    displayName: 'Deploy to Development'
    dependsOn: Build
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/develop'))
    jobs:
      - deployment: DeployDevJob
        displayName: 'Deploy to Dev Environment'
        environment: 'development'
        strategy:
          runOnce:
            deploy:
              steps:
                - task: DownloadPipelineArtifact@2
                  inputs:
                    artifactName: 'webapp'
                    targetPath: '$(Pipeline.Workspace)/webapp'

                - task: AzureWebApp@1
                  displayName: 'Deploy to Azure App Service (Dev)'
                  inputs:
                    azureSubscription: '$(azureSubscription)'
                    appType: 'webAppLinux'
                    appName: 'app-myapi-dev'
                    package: '$(Pipeline.Workspace)/webapp/**/*.zip'

  - stage: DeployStaging
    displayName: 'Deploy to Staging'
    dependsOn: Build
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployStagingJob
        displayName: 'Deploy to Staging Environment'
        environment: 'staging'
        strategy:
          runOnce:
            deploy:
              steps:
                - task: DownloadPipelineArtifact@2
                  inputs:
                    artifactName: 'webapp'
                    targetPath: '$(Pipeline.Workspace)/webapp'

                - task: AzureRmWebAppDeployment@4
                  displayName: 'Deploy to App Service staging slot'
                  inputs:
                    azureSubscription: '$(azureSubscription)'
                    appType: 'webAppLinux'
                    WebAppName: 'app-myapi-prod'
                    deployToSlotOrASE: true
                    ResourceGroupName: 'rg-myapi-prod'
                    SlotName: 'staging'
                    packageForLinux: '$(Pipeline.Workspace)/webapp/**/*.zip'

                - task: AzureCLI@2
                  displayName: 'Run smoke tests on staging slot'
                  inputs:
                    azureSubscription: '$(azureSubscription)'
                    scriptType: 'bash'
                    scriptLocation: 'inlineScript'
                    inlineScript: |
                      STAGING_URL=$(az webapp show \
                        --name app-myapi-prod \
                        --resource-group rg-myapi-prod \
                        --slot staging \
                        --query "defaultHostName" -o tsv)

                      echo "Testing https://${STAGING_URL}/health"
                      curl -f https://${STAGING_URL}/health || exit 1

                      echo "Smoke tests passed!"

  - stage: DeployProduction
    displayName: 'Deploy to Production'
    dependsOn: DeployStaging
    condition: succeeded()
    jobs:
      - deployment: DeployProductionJob
        displayName: 'Deploy to Production Environment'
        environment: 'production'
        strategy:
          runOnce:
            deploy:
              steps:
                - task: AzureCLI@2
                  displayName: 'Swap staging to production'
                  inputs:
                    azureSubscription: '$(azureSubscription)'
                    scriptType: 'bash'
                    scriptLocation: 'inlineScript'
                    inlineScript: |
                      az webapp deployment slot swap \
                        --name app-myapi-prod \
                        --resource-group rg-myapi-prod \
                        --slot staging \
                        --target-slot production

                      echo "Deployment successful! Swapped staging to production."

                - task: AzureCLI@2
                  displayName: 'Verify production deployment'
                  inputs:
                    azureSubscription: '$(azureSubscription)'
                    scriptType: 'bash'
                    scriptLocation: 'inlineScript'
                    inlineScript: |
                      PROD_URL="https://app-myapi-prod.azurewebsites.net"

                      # Wait for DNS propagation
                      sleep 30

                      # Health check
                      curl -f ${PROD_URL}/health || exit 1
                      echo "Production health check passed!"
```

**Explanation**: Multi-stage pipeline with explicit stage dependencies. `environment` keyword enables deployment history, approvals (configured in Azure DevOps UI), and gates. Develop branch deploys to dev environment automatically. Main branch deploys to staging, then requires manual approval before production (configured in Azure DevOps Environments). Service connection (`azureSubscription`) manages Azure credentials securely. Artifact published once, deployed multiple times. Staging slot validation before production swap.

---

## Example 5: GitHub Actions - Infrastructure as Code with Bicep

**Pattern**: Provision Azure infrastructure (Resource Group, Container Apps, Cosmos DB, Key Vault) via Bicep before deploying application code.

**When to Use**: Infrastructure and application code in same repository, infrastructure changes deployed alongside code, Azure-native deployments.

```yaml
# .github/workflows/deploy-with-bicep.yml
name: Deploy Infrastructure and Application

on:
  push:
    branches: [main]
  workflow_dispatch:

env:
  AZURE_RESOURCE_GROUP: rg-myapp-prod
  LOCATION: eastus

jobs:
  provision-infrastructure:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    outputs:
      containerAppFqdn: ${{ steps.bicep-deploy.outputs.containerAppFqdn }}
      cosmosDbEndpoint: ${{ steps.bicep-deploy.outputs.cosmosDbEndpoint }}

    steps:
      - uses: actions/checkout@v4

      - name: Azure Login (OIDC)
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Create Resource Group
        run: |
          az group create \
            --name ${{ env.AZURE_RESOURCE_GROUP }} \
            --location ${{ env.LOCATION }}

      - name: Validate Bicep template
        uses: azure/arm-deploy@v2
        with:
          subscriptionId: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          resourceGroupName: ${{ env.AZURE_RESOURCE_GROUP }}
          template: ./infra/main.bicep
          parameters: ./infra/main.parameters.prod.json
          deploymentMode: Validate

      - name: Deploy Bicep infrastructure
        id: bicep-deploy
        uses: azure/arm-deploy@v2
        with:
          subscriptionId: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          resourceGroupName: ${{ env.AZURE_RESOURCE_GROUP }}
          template: ./infra/main.bicep
          parameters: >
            ./infra/main.parameters.prod.json
            location=${{ env.LOCATION }}
            commitSha=${{ github.sha }}
          failOnStdErr: false

      - name: Capture infrastructure outputs
        run: |
          echo "Container App FQDN: ${{ steps.bicep-deploy.outputs.containerAppFqdn }}"
          echo "Cosmos DB Endpoint: ${{ steps.bicep-deploy.outputs.cosmosDbEndpoint }}"

  deploy-application:
    runs-on: ubuntu-latest
    needs: provision-infrastructure
    permissions:
      id-token: write
      contents: read

    steps:
      - uses: actions/checkout@v4

      - name: Azure Login (OIDC)
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Get ACR name
        id: acr
        run: |
          ACR_NAME=$(az deployment group show \
            --resource-group ${{ env.AZURE_RESOURCE_GROUP }} \
            --name main \
            --query properties.outputs.acrName.value -o tsv)
          echo "ACR_NAME=${ACR_NAME}" >> $GITHUB_ENV
          echo "acrName=${ACR_NAME}" >> $GITHUB_OUTPUT

      - name: Login to Azure Container Registry
        run: |
          az acr login --name ${{ steps.acr.outputs.acrName }}

      - name: Build and push Docker image
        run: |
          docker build -t ${{ steps.acr.outputs.acrName }}.azurecr.io/myapp:${{ github.sha }} ./src
          docker push ${{ steps.acr.outputs.acrName }}.azurecr.io/myapp:${{ github.sha }}

      - name: Update Container App with new image
        run: |
          CONTAINER_APP_NAME=$(az deployment group show \
            --resource-group ${{ env.AZURE_RESOURCE_GROUP }} \
            --name main \
            --query properties.outputs.containerAppName.value -o tsv)

          az containerapp update \
            --name ${CONTAINER_APP_NAME} \
            --resource-group ${{ env.AZURE_RESOURCE_GROUP }} \
            --image ${{ steps.acr.outputs.acrName }}.azurecr.io/myapp:${{ github.sha }}

      - name: Run integration tests
        run: |
          FQDN="${{ needs.provision-infrastructure.outputs.containerAppFqdn }}"
          echo "Testing https://${FQDN}"

          # Health check
          curl -f https://${FQDN}/health || exit 1

          # API endpoint test
          RESPONSE=$(curl -s https://${FQDN}/api/data)
          echo "API Response: $RESPONSE"
```

**Bicep Template (`infra/main.bicep`)**:

```bicep
param location string = resourceGroup().location
param containerAppName string = 'ca-myapp-${uniqueString(resourceGroup().id)}'
param acrName string = 'acr${uniqueString(resourceGroup().id)}'
param cosmosDbName string = 'cosmos-${uniqueString(resourceGroup().id)}'
param commitSha string = 'latest'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: { name: 'Basic' }
  properties: {
    adminUserEnabled: true
  }
}

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: cosmosDbName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      { locationName: location, failoverPriority: 0 }
    ]
  }
}

resource managedEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: 'env-${containerAppName}'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'log-${containerAppName}'
  location: location
  properties: {
    sku: { name: 'PerGB2018' }
  }
}

resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: managedEnvironment.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 8080
        transport: 'auto'
      }
      registries: [
        {
          server: containerRegistry.properties.loginServer
          username: containerRegistry.listCredentials().username
          passwordSecretRef: 'acr-password'
        }
      ]
      secrets: [
        {
          name: 'acr-password'
          value: containerRegistry.listCredentials().passwords[0].value
        }
        {
          name: 'cosmos-connection-string'
          value: cosmosDbAccount.listConnectionStrings().connectionStrings[0].connectionString
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'myapp'
          image: '${containerRegistry.properties.loginServer}/myapp:${commitSha}'
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          env: [
            {
              name: 'COSMOS_DB_ENDPOINT'
              value: cosmosDbAccount.properties.documentEndpoint
            }
            {
              name: 'COSMOS_DB_CONNECTION_STRING'
              secretRef: 'cosmos-connection-string'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 10
      }
    }
  }
}

output containerAppFqdn string = containerApp.properties.configuration.ingress.fqdn
output cosmosDbEndpoint string = cosmosDbAccount.properties.documentEndpoint
output acrName string = containerRegistry.name
output containerAppName string = containerApp.name
```

**Explanation**: Two-job workflow: provision infrastructure → deploy application. Bicep template creates Resource Group, ACR, Cosmos DB, Log Analytics, Container Apps Managed Environment, Container App. Template validation runs before deployment (fail fast). Outputs captured for downstream jobs (FQDN, Cosmos DB endpoint, ACR name). Application deployment queries outputs from infrastructure deployment. Infrastructure changes and application code deployed together, ensuring environment consistency.

---

## Example 6: Azure DevOps Pipeline - Infrastructure as Code with Terraform

**Pattern**: Multi-stage Azure DevOps pipeline with Terraform for infrastructure provisioning, artifact deployment, and environment-specific variable groups.

**When to Use**: Azure DevOps organization with Terraform preference (multi-cloud support, HCL syntax), separate infrastructure and application deployment stages.

```yaml
# azure-pipelines-terraform.yml
trigger:
  branches:
    include:
      - main
  paths:
    include:
      - 'terraform/**'
      - 'src/**'

pool:
  vmImage: 'ubuntu-latest'

variables:
  - group: terraform-prod-vars
  - name: tfBackendResourceGroup
    value: 'rg-terraform-state'
  - name: tfBackendStorageAccount
    value: 'sttfstate$(Build.BuildId)'
  - name: tfBackendContainer
    value: 'tfstate'

stages:
  - stage: TerraformValidate
    displayName: 'Terraform Validation'
    jobs:
      - job: Validate
        steps:
          - task: TerraformInstaller@1
            displayName: 'Install Terraform'
            inputs:
              terraformVersion: 'latest'

          - task: TerraformTaskV4@4
            displayName: 'Terraform Init'
            inputs:
              provider: 'azurerm'
              command: 'init'
              workingDirectory: '$(System.DefaultWorkingDirectory)/terraform'
              backendServiceArm: 'Azure-Service-Connection'
              backendAzureRmResourceGroupName: '$(tfBackendResourceGroup)'
              backendAzureRmStorageAccountName: '$(tfBackendStorageAccount)'
              backendAzureRmContainerName: '$(tfBackendContainer)'
              backendAzureRmKey: 'terraform.tfstate'

          - task: TerraformTaskV4@4
            displayName: 'Terraform Validate'
            inputs:
              provider: 'azurerm'
              command: 'validate'
              workingDirectory: '$(System.DefaultWorkingDirectory)/terraform'

          - task: TerraformTaskV4@4
            displayName: 'Terraform Plan'
            inputs:
              provider: 'azurerm'
              command: 'plan'
              workingDirectory: '$(System.DefaultWorkingDirectory)/terraform'
              environmentServiceNameAzureRM: 'Azure-Service-Connection'
              commandOptions: '-var="environment=prod" -out=tfplan'

          - task: PublishPipelineArtifact@1
            displayName: 'Publish Terraform Plan'
            inputs:
              targetPath: '$(System.DefaultWorkingDirectory)/terraform/tfplan'
              artifactName: 'terraform-plan'

  - stage: TerraformApply
    displayName: 'Terraform Apply'
    dependsOn: TerraformValidate
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: ApplyInfrastructure
        displayName: 'Apply Infrastructure Changes'
        environment: 'production-infrastructure'
        strategy:
          runOnce:
            deploy:
              steps:
                - task: DownloadPipelineArtifact@2
                  inputs:
                    artifactName: 'terraform-plan'
                    targetPath: '$(Pipeline.Workspace)/terraform'

                - task: TerraformInstaller@1
                  displayName: 'Install Terraform'
                  inputs:
                    terraformVersion: 'latest'

                - task: TerraformTaskV4@4
                  displayName: 'Terraform Init'
                  inputs:
                    provider: 'azurerm'
                    command: 'init'
                    workingDirectory: '$(System.DefaultWorkingDirectory)/terraform'
                    backendServiceArm: 'Azure-Service-Connection'
                    backendAzureRmResourceGroupName: '$(tfBackendResourceGroup)'
                    backendAzureRmStorageAccountName: '$(tfBackendStorageAccount)'
                    backendAzureRmContainerName: '$(tfBackendContainer)'
                    backendAzureRmKey: 'terraform.tfstate'

                - task: TerraformTaskV4@4
                  displayName: 'Terraform Apply'
                  inputs:
                    provider: 'azurerm'
                    command: 'apply'
                    workingDirectory: '$(System.DefaultWorkingDirectory)/terraform'
                    environmentServiceNameAzureRM: 'Azure-Service-Connection'
                    commandOptions: '$(Pipeline.Workspace)/terraform/tfplan'

                - task: AzureCLI@2
                  displayName: 'Capture Terraform Outputs'
                  inputs:
                    azureSubscription: 'Azure-Service-Connection'
                    scriptType: 'bash'
                    scriptLocation: 'inlineScript'
                    inlineScript: |
                      cd $(System.DefaultWorkingDirectory)/terraform

                      APP_NAME=$(terraform output -raw container_app_name)
                      ACR_NAME=$(terraform output -raw acr_name)

                      echo "##vso[task.setvariable variable=containerAppName;isOutput=true]${APP_NAME}"
                      echo "##vso[task.setvariable variable=acrName;isOutput=true]${ACR_NAME}"
                  name: TerraformOutputs

  - stage: BuildApplication
    displayName: 'Build Application'
    dependsOn: []
    jobs:
      - job: Build
        steps:
          - task: Docker@2
            displayName: 'Build Docker Image'
            inputs:
              command: 'build'
              Dockerfile: '$(System.DefaultWorkingDirectory)/src/Dockerfile'
              tags: '$(Build.BuildId)'

          - task: PublishPipelineArtifact@1
            displayName: 'Publish Dockerfile'
            inputs:
              targetPath: '$(System.DefaultWorkingDirectory)/src'
              artifactName: 'application'

  - stage: DeployApplication
    displayName: 'Deploy Application'
    dependsOn:
      - TerraformApply
      - BuildApplication
    condition: succeeded()
    variables:
      containerAppName: $[ stageDependencies.TerraformApply.ApplyInfrastructure.outputs['TerraformOutputs.containerAppName'] ]
      acrName: $[ stageDependencies.TerraformApply.ApplyInfrastructure.outputs['TerraformOutputs.acrName'] ]
    jobs:
      - deployment: DeployApp
        displayName: 'Deploy Application to Container Apps'
        environment: 'production-application'
        strategy:
          runOnce:
            deploy:
              steps:
                - task: DownloadPipelineArtifact@2
                  inputs:
                    artifactName: 'application'
                    targetPath: '$(Pipeline.Workspace)/app'

                - task: AzureCLI@2
                  displayName: 'Build and Push to ACR'
                  inputs:
                    azureSubscription: 'Azure-Service-Connection'
                    scriptType: 'bash'
                    scriptLocation: 'inlineScript'
                    inlineScript: |
                      cd $(Pipeline.Workspace)/app

                      # ACR build (builds in cloud, no local Docker daemon needed)
                      az acr build \
                        --registry $(acrName) \
                        --image myapp:$(Build.BuildId) \
                        --image myapp:latest \
                        --file Dockerfile \
                        .

                - task: AzureCLI@2
                  displayName: 'Update Container App'
                  inputs:
                    azureSubscription: 'Azure-Service-Connection'
                    scriptType: 'bash'
                    scriptLocation: 'inlineScript'
                    inlineScript: |
                      az containerapp update \
                        --name $(containerAppName) \
                        --resource-group $(terraformResourceGroup) \
                        --image $(acrName).azurecr.io/myapp:$(Build.BuildId)

                - task: AzureCLI@2
                  displayName: 'Verify Deployment'
                  inputs:
                    azureSubscription: 'Azure-Service-Connection'
                    scriptType: 'bash'
                    scriptLocation: 'inlineScript'
                    inlineScript: |
                      FQDN=$(az containerapp show \
                        --name $(containerAppName) \
                        --resource-group $(terraformResourceGroup) \
                        --query properties.configuration.ingress.fqdn -o tsv)

                      echo "Application deployed to https://${FQDN}"
                      curl -f https://${FQDN}/health || exit 1
```

**Explanation**: Four-stage pipeline: Terraform validation → Terraform apply → Build application → Deploy application. Terraform state stored in Azure Storage backend. Plan artifact published for auditability. Infrastructure outputs (Container App name, ACR name) passed to downstream stages via output variables. ACR build command builds Docker image in Azure (no local Docker daemon), simplifying agent requirements. Environment deployment history tracked in Azure DevOps.

---

## CI/CD Tool Comparison Table

| Aspect                     | GitHub Actions                                                                | Azure DevOps Pipelines                                                                      |
| -------------------------- | ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| **Primary Use Case**       | GitHub repositories, open source, cloud-native                                | Enterprise DevOps, Azure integration, on-prem support                                       |
| **Configuration**          | YAML in `.github/workflows/`                                                  | YAML in `azure-pipelines.yml` (repo root)                                                   |
| **Authentication**         | GitHub Secrets, OIDC (Workload Identity)                                      | Service Connections, Managed Identity                                                       |
| **Environments**           | GitHub Environments (approval gates, secrets, protection rules)               | Azure DevOps Environments (approvals, gates, deployment history)                            |
| **Artifact Storage**       | GitHub Artifacts (90 days retention)                                          | Azure DevOps Artifacts (indefinite retention with policies)                                 |
| **Deployment Slots**       | Manual scripting with Azure CLI                                               | Native support via `AzureRmWebAppDeployment@4` task                                         |
| **Infrastructure as Code** | Bicep/Terraform via actions (`azure/arm-deploy`, `hashicorp/setup-terraform`) | Native Terraform/Bicep tasks (`TerraformTaskV4`, `AzureResourceManagerTemplateDeployment`)  |
| **Cost**                   | Free for public repos, minutes for private repos                              | Free tier (1 parallel job, 1800 minutes/month), paid tiers for scale                        |
| **Marketplace**            | GitHub Actions Marketplace (1000s of actions)                                 | Azure DevOps Extensions Marketplace (extensions, tasks)                                     |
| **Multi-Stage Pipelines**  | Multi-job workflows with dependencies                                         | Multi-stage YAML with explicit `dependsOn`, conditions                                      |
| **Best For**               | GitHub-native projects, open source, cloud-native apps, OIDC authentication   | Enterprise organizations, Azure-heavy workloads, on-prem agents, complex approval workflows |
| **Trade-Offs**             | Less mature approval gates vs Azure DevOps, minutes-based pricing             | Steeper learning curve, more verbose YAML, requires Azure DevOps organization               |
