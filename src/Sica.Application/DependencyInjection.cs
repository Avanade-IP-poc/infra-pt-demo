using Microsoft.Extensions.DependencyInjection;
using Sica.Application.Abstractions;
using Sica.Application.Iam.AuthorizeTerminal;

namespace Sica.Application;

/// <summary>Registers Application-layer CQRS handlers in the DI container.</summary>
public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddScoped<
            IQueryHandler<AuthorizeTerminalQuery, AuthorizeTerminalResult>,
            AuthorizeTerminalQueryHandler>();

        return services;
    }
}
