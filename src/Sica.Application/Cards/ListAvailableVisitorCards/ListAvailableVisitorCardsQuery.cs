using Sica.Application.Abstractions;

namespace Sica.Application.Cards.ListAvailableVisitorCards;

/// <summary>Lists visitor cards that are available to assign (RULE-008).</summary>
public sealed record ListAvailableVisitorCardsQuery
    : IQuery<IReadOnlyList<AvailableVisitorCard>>;

/// <summary>A visitor card available for assignment.</summary>
public sealed record AvailableVisitorCard(
    Guid CardId,
    string CardCode,
    string? Label,
    DateTime? LastUsed);
