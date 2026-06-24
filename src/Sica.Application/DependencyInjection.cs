using Microsoft.Extensions.DependencyInjection;
using Sica.Application.Abstractions;
using Sica.Application.Cards.AssignVisitorCard;
using Sica.Application.Cards.ListAvailableVisitorCards;
using Sica.Application.Cards.RecordVisitorExit;
using Sica.Application.Iam.AuthorizeTerminal;

namespace Sica.Application;

/// <summary>Registers Application-layer CQRS handlers in the DI container.</summary>
public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.TryAddSingletonTimeProvider();

        services.AddScoped<
            IQueryHandler<AuthorizeTerminalQuery, AuthorizeTerminalResult>,
            AuthorizeTerminalQueryHandler>();

        services.AddScoped<
            IQueryHandler<ListAvailableVisitorCardsQuery, IReadOnlyList<AvailableVisitorCard>>,
            ListAvailableVisitorCardsQueryHandler>();

        services.AddScoped<
            ICommandHandler<AssignVisitorCardCommand, AssignVisitorCardResult>,
            AssignVisitorCardCommandHandler>();

        services.AddScoped<
            ICommandHandler<RecordVisitorExitCommand>,
            RecordVisitorExitCommandHandler>();

        return services;
    }

    private static void TryAddSingletonTimeProvider(this IServiceCollection services)
    {
        if (!services.Any(d => d.ServiceType == typeof(TimeProvider)))
        {
            services.AddSingleton(TimeProvider.System);
        }
    }
}
