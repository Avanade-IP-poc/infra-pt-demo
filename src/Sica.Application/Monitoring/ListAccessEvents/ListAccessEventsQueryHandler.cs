using Sica.Application.Abstractions;
using Sica.Application.Integration.Smi;
using Sica.Domain.Monitoring;
using Sica.Shared;

namespace Sica.Application.Monitoring.ListAccessEvents;

/// <summary>
/// Fetches recent access events from the SMI ACL and classifies each movement
/// (RULE-011) using the circuit description and event parameter.
/// </summary>
public sealed class ListAccessEventsQueryHandler(ISmiService smi)
    : IQueryHandler<ListAccessEventsQuery, IReadOnlyList<AccessEventDto>>
{
    private const int MinHours = 1;
    private const int MaxHours = 168;
    private const int MinEvents = 1;
    private const int MaxEvents = 100;

    private readonly ISmiService _smi = Guard.AgainstNull(smi, nameof(smi));

    public async Task<Result<IReadOnlyList<AccessEventDto>>> HandleAsync(
        ListAccessEventsQuery query,
        CancellationToken cancellationToken = default)
    {
        var hours = Math.Clamp(query.Hours, MinHours, MaxHours);
        var maxEvents = Math.Clamp(query.MaxEvents, MinEvents, MaxEvents);

        var events = await _smi.GetLastCircuitEventsAsync(
            [query.CircuitId],
            hours,
            maxEvents,
            cancellationToken);

        IReadOnlyList<AccessEventDto> result = events
            .Select(e => new AccessEventDto(
                e.Timestamp,
                e.LogicalCode,
                e.Name,
                e.CircuitId,
                e.Circuit,
                MovementClassifier.Classify(e.Circuit, e.EventId).ToString()))
            .ToList();

        return Result.Success(result);
    }
}
