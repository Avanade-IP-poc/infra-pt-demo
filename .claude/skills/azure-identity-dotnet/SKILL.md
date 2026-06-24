---
name: azure-identity-dotnet
description: Azure Identity SDK for .NET. Authentication library for Azure SDK clients using Microsoft Entra ID. Use for DefaultAzureCredential, managed identity, service principals, and developer credentials in SICA Web API and Azure Functions. Triggers => "Azure Identity", "DefaultAzureCredential", "ManagedIdentityCredential", "ClientSecretCredential", "authentication .NET", "Azure auth", "credential chain", "Microsoft.Identity.Web", "Azure AD B2C".
provisioned_from: .boltf/available-skills/azure/azure-identity-dotnet
provisioned_at: "2026-06-19"
project: SICA Modernization
---

# Azure Identity (.NET) — SICA Modernization

Authentication library for Azure SDK clients using Microsoft Entra ID / Azure AD B2C.

## Installation

```bash
dotnet add package Azure.Identity
dotnet add package Microsoft.Extensions.Azure
dotnet add package Microsoft.Identity.Web        # ASP.NET Core JWT validation
dotnet add package Microsoft.Identity.Web.MicrosoftGraph  # Optional
```

## DefaultAzureCredential — Credential Chain

| Order | Credential                 | When Used                          |
| ----- | -------------------------- | ---------------------------------- |
| 1     | EnvironmentCredential      | CI/CD pipelines (service principal)|
| 2     | WorkloadIdentityCredential | AKS workload identity              |
| 3     | ManagedIdentityCredential  | Azure App Service (production)     |
| 4     | AzureCliCredential         | Local development                  |
| 5     | VisualStudioCredential     | Local development                  |

```csharp
// Production + Dev credential (recommended)
var credential = new DefaultAzureCredential();

// Explicit for production only
var credential = new ManagedIdentityCredential("<user-assigned-client-id>");
```

## ASP.NET Core — Azure AD B2C JWT Validation

```csharp
// Program.cs — SICA Web API
builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddMicrosoftIdentityWebApi(builder.Configuration.GetSection("AzureAdB2C"));

// appsettings.json
{
  "AzureAdB2C": {
    "Instance": "https://<tenant>.b2clogin.com",
    "ClientId": "<api-client-id>",
    "Domain": "<tenant>.onmicrosoft.com",
    "SignUpSignInPolicyId": "B2C_1_signupsignin",
    "TenantId": "<tenant-id>"
  }
}

// Controller
[Authorize]
[ApiController]
[Route("api/v1/[controller]")]
public class AccessController : ControllerBase
{
    // Claims from Azure AD B2C JWT
    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)!;
}
```

## Key Vault Integration (Managed Identity)

```csharp
// Access secrets without connection strings in code
builder.Configuration.AddAzureKeyVault(
    new Uri($"https://{builder.Configuration["KeyVaultName"]}.vault.azure.net/"),
    new DefaultAzureCredential());
```

## Azure Functions — Isolated Worker

```csharp
// Azure Functions .NET 8 Isolated
var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults(worker =>
    {
        worker.UseMiddleware<AuthenticationMiddleware>();
    })
    .ConfigureServices(services =>
    {
        services.AddAzureClients(clientBuilder =>
        {
            clientBuilder.AddServiceBusClient(
                new Uri("https://<namespace>.servicebus.windows.net"));
            clientBuilder.UseCredential(new DefaultAzureCredential());
        });
    })
    .Build();
```

## Environment Config

```bash
# Service Principal (CI/CD)
AZURE_CLIENT_ID=<app-client-id>
AZURE_TENANT_ID=<tenant-id>
AZURE_CLIENT_SECRET=<secret>     # Or certificate path

# User-assigned Managed Identity
AZURE_CLIENT_ID=<managed-identity-client-id>
```

## Production vs Development

```csharp
TokenCredential credential = builder.Environment.IsProduction()
    ? new ManagedIdentityCredential(configuration["ManagedIdentityClientId"])
    : new DefaultAzureCredential();   // AzureCLI in dev
```

## Policy-Based Authorization (.NET)

```csharp
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("OperatorOnly", policy =>
        policy.RequireClaim("extension_Role", "Operator", "Admin"));
    options.AddPolicy("AdminOnly", policy =>
        policy.RequireClaim("extension_Role", "Admin"));
});

// Usage
[Authorize(Policy = "OperatorOnly")]
public async Task<IActionResult> GetAccessLogs() { ... }
```

## References (source)

`.boltf/available-skills/azure/azure-identity-dotnet/`
