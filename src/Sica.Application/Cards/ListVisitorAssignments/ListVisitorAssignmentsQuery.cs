using Sica.Application.Abstractions;

namespace Sica.Application.Cards.ListVisitorAssignments;

/// <summary>
/// Lists visitor card assignments, optionally filtered by active/completed state.
/// <paramref name="TerminalId"/> is currently accepted for API compatibility and
/// future filtering, but is not applied in the MVP data model.
/// </summary>
public sealed record ListVisitorAssignmentsQuery(int? TerminalId, bool? Active)
    : IQuery<IReadOnlyList<VisitorAssignmentDto>>;

/// <summary>Read model of a visitor card assignment for UI consumption.</summary>
public sealed record VisitorAssignmentDto(
    Guid AssignmentId,
    Guid CardId,
    string CardCode,
    Guid VisitorId,
    string Company,
    string? VisitedEntity,
    string? VehiclePlate,
    IReadOnlyList<Guid> AccessFamilyIds,
    DateTime ValidFrom,
    DateTime ValidUntil,
    DateTime? EntryTime,
    DateTime? ExitTime,
    bool IsCompleted);
