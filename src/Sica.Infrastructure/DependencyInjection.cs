using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Sica.Domain.Iam;
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

        services.AddScoped<ITerminalRepository, TerminalRepository>();

        return services;
    }
}
