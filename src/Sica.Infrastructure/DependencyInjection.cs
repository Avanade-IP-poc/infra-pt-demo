using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Sica.Application.Abstractions;
using Sica.Application.Integration.Smi;
using Sica.Domain.Cards;
using Sica.Domain.Iam;
using Sica.Infrastructure.Integration.Smi;
using Sica.Infrastructure.Persistence;
using Sica.Infrastructure.Persistence.Repositories;

namespace Sica.Infrastructure;

/// <summary>Registers Infrastructure-layer services (EF Core, repositories).</summary>
public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddDbContext<SicaDbContext>(options =>
            options.UseSqlServer(configuration.GetConnectionString("SicaDatabase")));

        services.AddScoped<IUnitOfWork>(sp => sp.GetRequiredService<SicaDbContext>());

        services.AddScoped<ITerminalRepository, TerminalRepository>();
        services.AddScoped<ISmartCardRepository, SmartCardRepository>();
        services.AddScoped<IVisitorCardAssignmentRepository, VisitorCardAssignmentRepository>();

        services.AddSmiIntegration(configuration);

        return services;
    }

    /// <summary>Wires the SMI Anti-Corruption Layer adapter based on <c>Smi:Mode</c>.</summary>
    private static IServiceCollection AddSmiIntegration(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.Configure<SmiOptions>(configuration.GetSection(SmiOptions.SectionName));

        var mode = configuration
            .GetSection(SmiOptions.SectionName)
            .GetValue<SmiMode>(nameof(SmiOptions.Mode));

        if (mode == SmiMode.Soap)
        {
            services.AddSingleton<ISmiService, SmiSoapAdapter>();
        }
        else
        {
            services.AddSingleton<ISmiService, SmiMockAdapter>();
        }

        return services;
    }
}
