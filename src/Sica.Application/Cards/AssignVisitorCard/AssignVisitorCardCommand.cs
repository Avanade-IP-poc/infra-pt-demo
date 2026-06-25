using Sica.Application.Abstractions;

namespace Sica.Application.Cards.AssignVisitorCard;

/// <summary>Assigns an available visitor card to a visitor (RULE-009).</summary>
public sealed record AssignVisitorCardCommand(
    Guid CardId,
    Guid VisitorId,
    string? FirstName,
    string? LastName,
    string? Company,
    string? VisitedEntity,
    string? VehiclePlate,
    IReadOnlyList<Guid> AccessFamilyIds,
    DateTime ValidFrom,
    DateTime ValidUntil) : ICommand<AssignVisitorCardResult>;

/// <summary>Result of a successful visitor card assignment.</summary>
public sealed record AssignVisitorCardResult(Guid AssignmentId, DateTime EntryTime);
