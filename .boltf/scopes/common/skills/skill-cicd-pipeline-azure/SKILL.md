---
name: skill-cicd-pipeline-azure
description: Design CI/CD pipelines with GitHub Actions or Azure DevOps Pipelines for automated Azure deployments. Use when setting up deployments, implementing infrastructure as code (Bicep/Terraform), configuring deployment strategies (blue-green, canary, rolling), or automating release processes. Critical because CI/CD affects entire team's deployment cadence, rollback procedures, and operational stability.
---

# CI/CD Pipeline Azure

## When to Use This Skill

Invoke this skill when you need to:

- **Set up CI/CD pipelines** for Azure deployments (GitHub Actions, Azure DevOps Pipelines)
- **Automate infrastructure provisioning** with Bicep or Terraform alongside application code
- **Implement deployment strategies** (blue-green with deployment slots, canary deployment, rolling updates)
- **Configure multi-environment promotion** (dev → staging → prod) with approval gates
- **Troubleshoot deployment failures** or optimize pipeline performance

**Critical because**: CI/CD pipeline configuration affects entire team's deployment cadence (how fast can we release?), rollback capabilities (can we revert bad deployments?), operational stability (automated gates prevent broken production deploys), and security posture (secrets management, least privilege service connections). Well-designed pipelines enable continuous delivery; poorly designed pipelines block releases or introduce production outages.

---

## Decision Framework: GitHub Actions vs Azure DevOps Pipelines

### GitHub Actions

**When to Choose**:

- GitHub repository hosting (GitHub.com or GitHub Enterprise)
- Cloud-native projects, open source, or greenfield applications
- OIDC authentication with Azure (Workload Identity Federation—no long-lived secrets)
- Simpler approval workflows (environment protection rules in GitHub)
- GitHub Marketplace actions (1000s of community actions)

**Trade-Offs**: Less mature approval/gate features vs Azure DevOps, minutes-based pricing for private repos, fewer enterprise on-prem integration options.

### Azure DevOps Pipelines

**When to Choose**:

- Azure DevOps organization (existing investment or enterprise requirement)
- Complex multi-stage pipelines with conditional deployments
- Advanced approval gates (automated quality checks, timeout policies, pre-deployment/post-deployment gates)
- On-premises build agents or hybrid cloud scenarios
- Existing Azure DevOps Boards/Repos integration

**Trade-Offs**: Steeper learning curve (more verbose YAML), requires Azure DevOps organization setup, more complex service connection configuration.

---

## Deployment Strategies

### Blue-Green Deployment

**Pattern**: Deploy new version to staging slot (blue), validate, swap staging to production (green), keep previous version in staging for instant rollback.

**When to Use**: Azure App Service with deployment slots, zero-downtime deployments, instant rollback capability (DNS pointer swap).

**Trade-Offs**: Requires deployment slots (additional cost), not all Azure services support slots (e.g., Container Apps uses revisions instead).

### Canary Deployment

**Pattern**: Roll out new version to small percentage of users (5-10%), monitor metrics, gradually increase traffic if stable.

**When to Use**: Azure Container Apps with traffic splitting, high-risk changes, gradual rollout to validate stability before full deployment.

**Trade-Offs**: Complex monitoring requirements (track metrics per revision), longer deployment duration, requires traffic management configuration.

### Rolling Deployment

**Pattern**: Update instances gradually (1 at a time, or batches), replacing old version incrementally.

**When to Use**: Azure DevOps deployment jobs with `rolling` strategy, Kubernetes/AKS deployments, stateless applications where gradual replacement acceptable.

**Trade-Offs**: Mixed version state during deployment (old and new running simultaneously), not suitable for breaking database schema changes.

---

## Pipeline Stages and Best Practices

### Typical Pipeline Flow

1. **Build Stage**: Compile code, run unit tests, publish artifact (Docker image or deployment package)
2. **Infrastructure Stage**: Provision/update Azure resources via Bicep or Terraform (idempotent, versioned)
3. **Deploy to Dev**: Automatic deployment on develop branch, fast feedback cycle
4. **Deploy to Staging**: Automatic deployment on main branch, smoke tests validate staging environment
5. **Approval Gate**: Manual approval (product owner, QA sign-off) before production
6. **Deploy to Production**: Blue-green swap or canary rollout, post-deployment verification

### Authentication Best Practices

- **GitHub Actions**: Use OIDC (Workload Identity Federation) via `azure/login@v2` with `client-id`, `tenant-id`, `subscription-id` (no secrets!)
- **Azure DevOps**: Use Workload Identity service connections (OIDC) or Managed Identity from self-hosted agents
- **Avoid**: Long-lived service principal secrets (security risk, rotation overhead)

### Secrets Management

- **GitHub Actions**: Store secrets in GitHub Secrets (repository or environment-level), or fetch from Azure Key Vault via `Azure/get-keyvault-secrets` action
- **Azure DevOps**: Use Azure Key Vault-backed variable groups, or pipeline secrets with Azure Key Vault task
- **Best Practice**: Never hardcode secrets in YAML; rotate secrets regularly; use least privilege RBAC roles

---

## How to Proceed

1. **Choose CI/CD Tool**:
   - GitHub repository → GitHub Actions (OIDC default)
   - Azure DevOps organization or enterprise requirements → Azure DevOps Pipelines

2. **Set Up Authentication**:
   - GitHub Actions: Configure OIDC (Workload Identity Federation) for passwordless Azure access
   - Azure DevOps: Create Azure Resource Manager service connection with Workload Identity or service principal

3. **Define Pipeline Stages**:
   - Build (compile, test, publish artifact)
   - Infrastructure (Bicep/Terraform provisioning)
   - Deploy to environments (dev, staging, prod) with conditional logic

4. **Select Deployment Strategy**:
   - Zero-downtime required + App Service → Blue-green with deployment slots
   - Gradual rollout + Container Apps → Canary with traffic splitting
   - Stateless apps + AKS → Rolling deployment

5. **Configure Environments and Approvals**:
   - GitHub: Create environments ("staging", "production") with protection rules (required reviewers, deployment branches)
   - Azure DevOps: Create environments with pre-deployment approvals, gates (e.g., "require all tests pass before deploy")

6. **Review Bundled Code Examples**:
   - `references/code-examples.md`: 6 complete workflows (GitHub Actions for Static Web Apps, Container Apps, deployment slots; Azure DevOps multi-stage pipelines, Bicep/Terraform)
   - Comparison table: GitHub Actions vs Azure DevOps features, use cases, trade-offs

7. **Consult Official Documentation**:
   - `references/microsoft-learn.md`: GitHub Actions Azure deployment guides, Azure DevOps Pipelines YAML schema, deployment strategies, secrets management

8. **Validate with Constitution**:
   - Check `memory/constitution.md` Article XIII (CI/CD Pipeline) for pipeline standards (branch policies, deployment approval requirements, automated testing gates)
   - Document pipeline architecture as ADR if introducing new deployment strategy

---

**Remember**: CI/CD pipeline failures block entire team's deployments. Invest time in proper authentication (OIDC, not secrets), automated testing gates (fail fast in dev, not prod), and deployment strategy (blue-green for instant rollback, canary for gradual validation). Monitor pipeline metrics (build duration, failure rate, deployment frequency) to identify bottlenecks.
