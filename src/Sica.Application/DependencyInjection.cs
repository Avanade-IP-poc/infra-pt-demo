using Microsoft.Extensions.DependencyInjection;
using Sica.Application.AccessControl.CreateAccessFamily;
using Sica.Application.AccessControl.GetTerminalPolicy;
using Sica.Application.AccessControl.ListAccessFamilies;
using Sica.Application.AccessControl.ListCircuits;
using Sica.Application.AccessControl.UpdateFamilyMembers;
using Sica.Application.AccessControl.UpdateTerminalPolicy;
using Sica.Application.Abstractions;
using Sica.Application.Cards.AssignVisitorCard;
using Sica.Application.Cards.ListAvailableVisitorCards;
using Sica.Application.Cards.ListVisitorAssignments;
using Sica.Application.Cards.RecordVisitorExit;
using Sica.Application.Iam.AuthorizeTerminal;
using Sica.Application.Monitoring.CountUsersByZone;
using Sica.Application.Monitoring.ListAccessEvents;

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
            IQueryHandler<ListVisitorAssignmentsQuery, IReadOnlyList<VisitorAssignmentDto>>,
            ListVisitorAssignmentsQueryHandler>();

        services.AddScoped<
            ICommandHandler<AssignVisitorCardCommand, AssignVisitorCardResult>,
            AssignVisitorCardCommandHandler>();

        services.AddScoped<
            ICommandHandler<RecordVisitorExitCommand>,
            RecordVisitorExitCommandHandler>();

        services.AddScoped<
            IQueryHandler<ListAccessFamiliesQuery, IReadOnlyList<AccessFamilyDto>>,
            ListAccessFamiliesQueryHandler>();

        services.AddScoped<
            ICommandHandler<CreateAccessFamilyCommand, Guid>,
            CreateAccessFamilyCommandHandler>();

        services.AddScoped<
            ICommandHandler<UpdateFamilyMembersCommand>,
            UpdateFamilyMembersCommandHandler>();

        services.AddScoped<
            IQueryHandler<ListCircuitsQuery, IReadOnlyList<CircuitDto>>,
            ListCircuitsQueryHandler>();

        services.AddScoped<
            IQueryHandler<GetTerminalPolicyQuery, TerminalPolicyDto>,
            GetTerminalPolicyQueryHandler>();

        services.AddScoped<
            ICommandHandler<UpdateTerminalPolicyCommand>,
            UpdateTerminalPolicyCommandHandler>();

        services.AddScoped<
            IQueryHandler<ListAccessEventsQuery, IReadOnlyList<AccessEventDto>>,
            ListAccessEventsQueryHandler>();

        services.AddScoped<
            IQueryHandler<CountUsersByZoneQuery, IReadOnlyList<ZoneOccupancyDto>>,
            CountUsersByZoneQueryHandler>();

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
