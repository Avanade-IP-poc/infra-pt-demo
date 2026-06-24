using Sica.Application.Abstractions;
using Sica.Application.Monitoring.CountUsersByZone;
using Sica.Application.Monitoring.ListAccessEvents;

namespace Sica.Api.Endpoints;

/// <summary>Minimal API endpoints for the Physical Access Monitoring bounded context.</summary>
public static class MonitoringEndpoints
{
    public static IEndpointRouteBuilder MapMonitoringEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/v1/monitoring").WithTags("Monitoring");

        group.MapGet("/events", ListAccessEventsAsync)
            .WithName("listAccessEvents")
            .WithOpenApi();

        group.MapGet("/zones", CountUsersByZoneAsync)
            .WithName("countUsersByZone")
            .WithOpenApi();

        return app;
    }

    private static async Task<IResult> ListAccessEventsAsync(
        int circuitId,
        IQueryHandler<ListAccessEventsQuery, IReadOnlyList<AccessEventDto>> handler,
        CancellationToken cancellationToken,
        int hours = 72,
        int maxEvents = 20)
    {
        var query = new ListAccessEventsQuery(circuitId, hours, maxEvents);
        var result = await handler.HandleAsync(query, cancellationToken);
        return Results.Ok(new { items = result.Value });
    }

    private static async Task<IResult> CountUsersByZoneAsync(
        IQueryHandler<CountUsersByZoneQuery, IReadOnlyList<ZoneOccupancyDto>> handler,
        CancellationToken cancellationToken)
    {
        var result = await handler.HandleAsync(new CountUsersByZoneQuery(), cancellationToken);
        return Results.Ok(new { items = result.Value });
    }
}
