using Sica.Api.Endpoints;
using Sica.Application;
using Sica.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration);

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.MapGet("/health", () => Results.Ok(new HealthStatus("Healthy", "001-migracion-sica")))
    .WithName("HealthCheck")
    .WithOpenApi();

app.MapIamEndpoints();

app.Run();

internal sealed record HealthStatus(string Status, string Feature);

/// <summary>Exposed so integration/E2E test hosts can reference the API entry point.</summary>
public partial class Program;
