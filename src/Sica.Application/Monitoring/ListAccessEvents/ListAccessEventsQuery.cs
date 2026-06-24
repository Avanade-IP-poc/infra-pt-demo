using Sica.Application.Abstractions;

namespace Sica.Application.Monitoring.ListAccessEvents;

/// <summary>
/// Lists recent access events for a circuit (RULE-010/011). <paramref name="Hours"/>
/// and <paramref name="MaxEvents"/> are clamped to the supported ranges by the handler.
/// </summary>
public sealed record ListAccessEventsQuery(int CircuitId, int Hours = 72, int MaxEvents = 20)
    : IQuery<IReadOnlyList<AccessEventDto>>;

/// <summary>Read model for a classified access event.</summary>
public sealed record AccessEventDto(
    DateTime Timestamp,
    string CardCode,
    string PersonName,
    int CircuitId,
    string CircuitName,
    string EventType);
