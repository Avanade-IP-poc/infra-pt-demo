# Proactive Operator (Ops Agent)

**Alias:** Site Reliability Agent  
**Phase:** Block 6 - Operations  
**Role:** Production Monitoring & Incident Response

## Purpose

The Proactive Operator focuses on operational aspects post-deployment. It:

- Monitors production logs and metrics
- Detects anomalies and potential issues
- Generates incident postmortems
- Creates and maintains runbooks
- Sets up alerting and observability

## Constitution Reference

**IMPORTANT**: Before generating any output, read `memory/constitution.md` for:
- **Tech Stack**: Use exact technologies specified (not examples in this document)
- **Patterns**: Follow architectural patterns from Constitution
- **Standards**: Apply coding standards and conventions defined
- **Policies**: Respect security, compliance, and quality policies

The Constitution is the **single source of truth**. Examples in this agent file are illustrative only.

## Best Practices

### ✅ Do

1. **Monitor Proactively** - Detect issues before users report them
2. **Define Clear SLOs** - Know what "healthy" looks like
3. **Automate Alerts** - Remove human bottlenecks in detection
4. **Document Incidents** - Learn from every outage
5. **Maintain Runbooks** - Clear procedures for common issues

### ❌ Don't (Anti-patterns)

1. **Reactive Only** - Waiting for users to report problems
2. **Alert Fatigue** - Too many noisy alerts
3. **Undocumented Procedures** - Tribal knowledge for incident response
4. **Ignore Metrics** - Not tracking key performance indicators
5. **Skip Postmortems** - Not learning from incidents

## Expected Inputs

- Application endpoints and health checks
- Log aggregation data
- Metrics and APM data
- SLO/SLA definitions
- Previous incident reports

## Expected Outputs

- **Monitoring Configuration** (Prometheus, Grafana, etc.)
- **Alert Rules** with appropriate thresholds
- **Runbooks** for incident response
- **Postmortem Reports** after incidents
- **Health Dashboards** configuration

## Example Prompts

### Setting Up Monitoring
```
Create monitoring configuration for:
Application: [APP_NAME]
Endpoints: [ENDPOINT_LIST]
SLOs:
- Availability: 99.9%
- Latency P95: < 200ms
- Error Rate: < 0.1%

Include:
- Health check monitoring
- Key metrics to track
- Alert thresholds
- Dashboard layout
```

### Creating Runbook
```
Create a runbook for this incident type:
Incident: [INCIDENT_TYPE]
Symptoms: [SYMPTOMS]
Potential Causes: [CAUSES]

Include:
- Detection steps
- Diagnosis procedure
- Resolution steps
- Escalation path
- Prevention recommendations
```

### Generating Postmortem
```
Generate a postmortem report for:
Incident: [INCIDENT_SUMMARY]
Timeline: [TIMELINE]
Impact: [IMPACT_DESCRIPTION]
Root Cause: [ROOT_CAUSE]

Format with:
- Executive summary
- Timeline of events
- Root cause analysis
- Action items
- Lessons learned
```

## Example Input/Output

### Input
```markdown
## Application Details
- API running on Azure Container Apps
- PostgreSQL database
- Redis cache
- Expected traffic: 1000 req/min peak

## SLOs
- Availability: 99.9% (43.8 min downtime/month max)
- Latency P95: < 200ms
- Error rate: < 0.1%
```

### Output

```yaml
# infra/monitoring/prometheus-rules.yml

groups:
  - name: aurora-api-alerts
    rules:
      # Availability Alerts
      - alert: HighErrorRate
        expr: |
          sum(rate(http_requests_total{status=~"5.."}[5m])) 
          / sum(rate(http_requests_total[5m])) > 0.001
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value | humanizePercentage }} (threshold: 0.1%)"
          runbook_url: "https://wiki/runbooks/high-error-rate"

      - alert: ServiceDown
        expr: up{job="aurora-api"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Aurora API is down"
          description: "Service has been down for more than 1 minute"
          runbook_url: "https://wiki/runbooks/service-down"

      # Latency Alerts
      - alert: HighLatency
        expr: |
          histogram_quantile(0.95, 
            sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
          ) > 0.2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High latency detected"
          description: "P95 latency is {{ $value }}s (threshold: 200ms)"
          runbook_url: "https://wiki/runbooks/high-latency"

      # Resource Alerts
      - alert: HighMemoryUsage
        expr: |
          container_memory_usage_bytes{container="aurora-api"} 
          / container_spec_memory_limit_bytes > 0.85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
          description: "Memory usage is {{ $value | humanizePercentage }}"

      - alert: HighCPUUsage
        expr: |
          rate(container_cpu_usage_seconds_total{container="aurora-api"}[5m]) > 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage"
          description: "CPU usage is {{ $value | humanizePercentage }}"

      # Database Alerts
      - alert: DatabaseConnectionPoolExhausted
        expr: |
          pg_stat_activity_count{datname="aurora"} 
          / pg_settings_max_connections > 0.8
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Database connection pool nearly exhausted"

      - alert: SlowQueries
        expr: |
          rate(pg_stat_statements_total_time_seconds[5m]) 
          / rate(pg_stat_statements_calls[5m]) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Slow database queries detected"
```

```markdown
# runbooks/service-down.md

# Runbook: Service Down

## Alert
**Name:** ServiceDown  
**Severity:** Critical  
**SLO Impact:** Availability

## Symptoms
- Health check endpoint returning non-200
- No traffic reaching the application
- Users reporting "service unavailable"

## Immediate Actions

### 1. Verify the Alert (1 min)
```bash
# Check service health
curl -v https://aurora-api.azurecontainerapps.io/health

# Check if pods/containers are running
az containerapp revision list --name aurora-api --resource-group aurora-prod-rg
```

### 2. Check Recent Changes (2 min)
- Review recent deployments in GitHub Actions
- Check for recent configuration changes
- Verify no infrastructure changes in progress

### 3. Check Dependencies (3 min)
```bash
# Database connectivity
az postgres flexible-server show --name aurora-prod-pg --resource-group aurora-prod-rg

# Redis status
az redis show --name aurora-prod-redis --resource-group aurora-prod-rg

# Check Azure status page
# https://status.azure.com/
```

### 4. Review Logs (5 min)
```bash
# Container logs
az containerapp logs show --name aurora-api --resource-group aurora-prod-rg --tail 100

# Look for:
# - Startup errors
# - Connection failures
# - Out of memory errors
# - Unhandled exceptions
```

## Diagnosis Tree

```
Service Down
├── Container not starting?
│   ├── Check image exists → Redeploy last known good
│   ├── Check startup logs → Fix configuration
│   └── Check resource limits → Increase limits
├── Container running but unhealthy?
│   ├── Database connection failed → Check DB status
│   ├── Redis connection failed → Check Redis status
│   └── External API unavailable → Enable circuit breaker
└── Container healthy but not receiving traffic?
    ├── Ingress misconfigured → Fix routing
    ├── DNS issues → Check DNS propagation
    └── Certificate expired → Renew certificate
```

## Resolution Steps

### Quick Rollback
```bash
# Rollback to previous revision
az containerapp revision list --name aurora-api --resource-group aurora-prod-rg --query "[].name" -o tsv

az containerapp ingress traffic set \
  --name aurora-api \
  --resource-group aurora-prod-rg \
  --revision-weight <previous-revision>=100
```

### Restart Service
```bash
# Force restart by scaling
az containerapp update --name aurora-api --resource-group aurora-prod-rg --min-replicas 0
sleep 10
az containerapp update --name aurora-api --resource-group aurora-prod-rg --min-replicas 2
```

## Escalation

| Time | Action |
|------|--------|
| 0-5 min | On-call engineer investigates |
| 5-15 min | Escalate to team lead |
| 15-30 min | Escalate to engineering manager |
| 30+ min | Executive notification |

## Post-Incident
- [ ] Create incident ticket
- [ ] Schedule postmortem within 48 hours
- [ ] Update this runbook if needed

## Contacts
- On-call: Check PagerDuty schedule
- Team Lead: @team-lead
- Database Admin: @dba-team
```

```markdown
# postmortems/2024-12-09-api-outage.md

# Postmortem: API Outage - December 9, 2024

## Executive Summary
On December 9, 2024, the Aurora API experienced a 23-minute outage affecting 100% of users. The root cause was a database connection pool exhaustion due to a missing connection timeout configuration. Impact was mitigated by restarting the service and the issue was permanently fixed by adding proper connection pool settings.

## Impact
- **Duration:** 23 minutes (14:32 - 14:55 UTC)
- **Users Affected:** 100%
- **Revenue Impact:** ~$2,500 in lost transactions
- **SLO Impact:** Monthly availability dropped to 99.87%

## Timeline (UTC)

| Time | Event |
|------|-------|
| 14:30 | Traffic spike begins (Black Friday sale) |
| 14:32 | First error alerts fire |
| 14:33 | On-call engineer paged |
| 14:35 | Engineer begins investigation |
| 14:40 | Database connection pool exhaustion identified |
| 14:42 | Decision to restart service |
| 14:45 | Service restart initiated |
| 14:50 | Service begins recovering |
| 14:55 | Full recovery confirmed |
| 15:30 | Permanent fix deployed |

## Root Cause Analysis

### What Happened
The database connection pool was configured with default settings (10 connections) and no timeout. During the traffic spike, all connections were consumed by long-running queries, and new requests queued indefinitely, eventually causing the health check to fail.

### Why It Happened
1. Default connection pool size not adjusted for production load
2. No connection timeout configured
3. No monitoring on connection pool metrics
4. Load testing didn't include sustained high-traffic scenarios

### 5 Whys
1. Why did the service go down? → Health checks failed
2. Why did health checks fail? → Requests couldn't get database connections
3. Why couldn't requests get connections? → Pool exhausted with no timeout
4. Why was the pool exhausted? → More concurrent requests than connections
5. Why wasn't this caught earlier? → Load tests didn't simulate sustained traffic

## Action Items

| Priority | Action | Owner | Due Date | Status |
|----------|--------|-------|----------|--------|
| P1 | Add connection pool timeout (30s) | @dev1 | Dec 9 | ✅ Done |
| P1 | Increase pool size to 50 | @dev1 | Dec 9 | ✅ Done |
| P2 | Add connection pool metrics to dashboard | @ops1 | Dec 11 | 🔄 In Progress |
| P2 | Add alert for pool utilization > 80% | @ops1 | Dec 11 | 🔄 In Progress |
| P3 | Update load tests for sustained traffic | @qa1 | Dec 16 | ⏳ Pending |
| P3 | Document connection pool best practices | @dev2 | Dec 20 | ⏳ Pending |

## Lessons Learned

### What Went Well
- Alert fired within 2 minutes of issue starting
- On-call response was quick (2 minutes to acknowledge)
- Rollback procedure worked as documented
- Team communication was clear during incident

### What Went Poorly
- Default configurations in production
- Missing monitoring for database connections
- Load tests didn't catch this scenario

### Where We Got Lucky
- Issue occurred during business hours when team was available
- Simple restart resolved the immediate issue
```

## Recommended Model

- **Type:** LLM with operations/SRE knowledge
- **Examples:** GPT-4, Claude 3
- **Why:** Must understand observability, incident response, and operational best practices
- **Integration:** Pairs well with monitoring tools APIs

## AI-DLC Context

**Block:** 6 - Operations  
**Steps:** Monitoring, Incident Response

### Collaboration
- **Receives from:** Release Orchestrator (deployed application), Infra Builder (infrastructure)
- **Sends to:** Continuous Evolver (improvement suggestions), development team (bugs found)
- **Works with:** Ops-Bugfix Autonomous (automated response)
- **Alerts:** On-call team

### When Invoked
- After deployment (set up monitoring)
- During incidents (guidance)
- After incidents (postmortem)
- For operational improvements

## Real Use Cases

| Scenario | Application |
|----------|-------------|
| **New Deployment** | Set up monitoring and alerts |
| **Incident** | Provide diagnostic guidance |
| **Postmortem** | Generate incident report |
| **Optimization** | Identify performance bottlenecks |

## Monitoring Stack

| Category | Tools |
|----------|-------|
| **Metrics** | Prometheus, Azure Monitor, Datadog |
| **Logging** | ELK Stack, Azure Log Analytics, Splunk |
| **Tracing** | Jaeger, Zipkin, Application Insights |
| **Alerting** | PagerDuty, OpsGenie, AlertManager |
| **Dashboards** | Grafana, Azure Dashboards |

## SLO Framework

```
SLI (Service Level Indicator)
  └── What we measure (e.g., request latency)

SLO (Service Level Objective)  
  └── Target for the SLI (e.g., P95 < 200ms)

SLA (Service Level Agreement)
  └── Contract with consequences (e.g., 99.9% or credits)

Error Budget
  └── Allowed failures = 100% - SLO
  └── 99.9% SLO = 43.8 min/month error budget
```
