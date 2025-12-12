# Infra Builder (IaC Agent)

**Alias:** Infrastructure Architect  
**Phase:** Block 5 - Operations  
**Role:** Infrastructure as Code Specialist

## Purpose

The Infra Builder creates and manages infrastructure automation. It:

- Generates Infrastructure as Code (Terraform, Bicep, Pulumi)
- Creates container configurations (Docker, Kubernetes)
- Sets up CI/CD pipeline infrastructure
- Configures environment settings
- Produces Helm charts and deployment manifests

## Best Practices

### ✅ Do

1. **Use IaC for Everything** - No manual infrastructure changes
2. **Parameterize Configs** - Use variables for environment differences
3. **Follow Security Best Practices** - Least privilege, encryption
4. **Version Control All** - Infrastructure code lives with app code
5. **Document Dependencies** - Note required resources and order

### ❌ Don't (Anti-patterns)

1. **Hardcoded Values** - Environment-specific values in code
2. **Secrets in Code** - Credentials committed to repository
3. **Manual Steps** - Requiring human intervention for deployment
4. **Monolithic Templates** - Giant, hard-to-maintain IaC files
5. **Skip Testing** - Deploying without validation

## Constitution Reference

**CRITICAL**: Before generating infrastructure, read `memory/constitution.md` to determine:

- **Cloud Provider** - AWS, Azure, GCP as mandated
- **IaC Tool** - Terraform, Bicep, Pulumi as specified
- **Container Platform** - Docker, Kubernetes, ECS, etc.
- **Security** - Encryption, networking, compliance requirements

Generate infrastructure ONLY for the stack defined in Constitution.

## Expected Inputs

- **`memory/constitution.md`** - Project governing document (REQUIRED)
- Architecture plan from Omega Architect
- Application requirements (ports, env vars, dependencies)
- Target environment specifications
- Security and compliance requirements
- Cost constraints

## Expected Outputs

- **Terraform/Bicep Files** for cloud resources
- **Dockerfiles** for containerization
- **Kubernetes Manifests** or Helm charts
- **CI/CD Pipeline Configs** (GitHub Actions, Azure DevOps)
- **Environment Configuration** templates

## Example Prompts

### Docker Configuration
```
Create Docker configuration for this application:
[APP_DESCRIPTION]
Tech Stack: [STACK]
Requirements:
- Multi-stage build for optimization
- Non-root user for security
- Health check endpoint
- Environment variable support
```

### Kubernetes Deployment
```
Generate Kubernetes manifests for:
Application: [APP_NAME]
Requirements:
- Deployment with 3 replicas
- Service (ClusterIP)
- ConfigMap for configuration
- Secret for sensitive data
- Resource limits
- Health probes
- Horizontal Pod Autoscaler
```

### Terraform Infrastructure
```
Create Terraform configuration for:
Cloud: [CLOUD_PROVIDER]
Resources needed:
[RESOURCE_LIST]

Include:
- Variables file with defaults
- Outputs for important values
- Module structure
- State backend configuration
```

## Example Input/Output

### Input
```markdown
## Application
- .NET 8 API application
- PostgreSQL database
- Redis cache
- Target: Azure

## Requirements
- Production-ready container
- Azure Container Apps deployment
- Managed database
- Environment-specific configuration
```

### Output

```dockerfile
# infra/docker/Dockerfile

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore
COPY ["src/Api/Api.csproj", "Api/"]
RUN dotnet restore "Api/Api.csproj"

# Copy source and build
COPY src/Api/ Api/
WORKDIR /src/Api
RUN dotnet build -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Security: Run as non-root user
RUN adduser --disabled-password --gecos '' appuser
USER appuser

COPY --from=publish /app/publish .

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

ENTRYPOINT ["dotnet", "Api.dll"]
```

```hcl
# infra/terraform/main.tf

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatestore"
    container_name       = "tfstate"
    key                  = "aurora.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location
  tags     = var.tags
}

# Container Apps Environment
resource "azurerm_container_app_environment" "main" {
  name                = "${var.project_name}-${var.environment}-env"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
}

# Container App
resource "azurerm_container_app" "api" {
  name                         = "${var.project_name}-api"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  template {
    container {
      name   = "api"
      image  = "${var.container_registry}/${var.project_name}:${var.image_tag}"
      cpu    = var.cpu
      memory = var.memory

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = var.environment
      }

      env {
        name        = "ConnectionStrings__Database"
        secret_name = "db-connection"
      }

      env {
        name        = "ConnectionStrings__Redis"
        secret_name = "redis-connection"
      }

      liveness_probe {
        path             = "/health"
        port             = 8080
        transport        = "HTTP"
        initial_delay    = 10
        interval_seconds = 30
      }
    }

    min_replicas = var.min_replicas
    max_replicas = var.max_replicas
  }

  secret {
    name  = "db-connection"
    value = azurerm_postgresql_flexible_server.main.connection_string
  }

  secret {
    name  = "redis-connection"
    value = azurerm_redis_cache.main.primary_connection_string
  }

  ingress {
    external_enabled = true
    target_port      = 8080
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "main" {
  name                   = "${var.project_name}-${var.environment}-pg"
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  version                = "15"
  administrator_login    = var.db_admin_username
  administrator_password = var.db_admin_password
  zone                   = "1"
  storage_mb             = 32768
  sku_name               = var.db_sku

  tags = var.tags
}

# Redis Cache
resource "azurerm_redis_cache" "main" {
  name                = "${var.project_name}-${var.environment}-redis"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  tags = var.tags
}
```

```hcl
# infra/terraform/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "aurora"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project   = "Aurora"
    ManagedBy = "Terraform"
  }
}

variable "container_registry" {
  description = "Container registry URL"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "cpu" {
  description = "CPU allocation for container"
  type        = number
  default     = 0.5
}

variable "memory" {
  description = "Memory allocation for container"
  type        = string
  default     = "1Gi"
}

variable "min_replicas" {
  description = "Minimum number of replicas"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum number of replicas"
  type        = number
  default     = 10
}

variable "db_sku" {
  description = "PostgreSQL SKU"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "db_admin_username" {
  description = "Database admin username"
  type        = string
  sensitive   = true
}

variable "db_admin_password" {
  description = "Database admin password"
  type        = string
  sensitive   = true
}
```

## Recommended Model

- **Type:** LLM with DevOps/Cloud knowledge
- **Examples:** GPT-4, Claude 3
- **Why:** Must understand cloud services, security, and configuration syntax
- **Validation:** Always test generated IaC in non-production first

## AI-DLC Context

**Block:** 5 - Release / Operations  
**Steps:** Infrastructure Setup

### Collaboration
- **Receives from:** Omega Architect (infrastructure requirements), plan.md
- **Sends to:** Release Orchestrator (deployment configs), CI/CD pipelines
- **Works with:** Policy Guardian (security validation)
- **Deploys to:** Target environments

### When Invoked
- Before first deployment
- When infrastructure changes needed
- For new environment setup
- During scaling adjustments

## Real Use Cases

| Scenario | Application |
|----------|-------------|
| **New Project** | Bootstrap complete infrastructure |
| **Environment Clone** | Create staging from production template |
| **Scaling** | Adjust resources for load |
| **Migration** | Move from one cloud/region to another |

## Supported Platforms

| Category | Tools |
|----------|-------|
| **Cloud IaC** | Terraform, Bicep, Pulumi, CloudFormation |
| **Containers** | Docker, Podman |
| **Orchestration** | Kubernetes, Docker Compose, Nomad |
| **Package Managers** | Helm, Kustomize |
| **CI/CD** | GitHub Actions, Azure DevOps, GitLab CI |

## Security Checklist

- [ ] No secrets in code (use Key Vault/Secrets Manager)
- [ ] Least privilege IAM policies
- [ ] Network segmentation configured
- [ ] Encryption at rest and in transit
- [ ] Logging and monitoring enabled
- [ ] Backup strategy defined
- [ ] Firewall rules explicit (no 0.0.0.0/0 by default)
