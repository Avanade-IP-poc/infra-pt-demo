namespace Sica.Domain.Cards;

/// <summary>Persistence abstraction for the <see cref="VisitorCardAssignment"/> aggregate.</summary>
public interface IVisitorCardAssignmentRepository
{
    Task<VisitorCardAssignment?> GetByIdAsync(
        VisitorCardAssignmentId id,
        CancellationToken cancellationToken = default);

    /// <summary>Returns the most recent assignment for a card, or null if it was never assigned.</summary>
    Task<VisitorCardAssignment?> GetLatestForCardAsync(
        CardId cardId,
        CancellationToken cancellationToken = default);

    /// <summary>Returns the card ids that currently have an open (not exited) assignment (RULE-008).</summary>
    Task<IReadOnlyCollection<CardId>> GetCardIdsInUseAsync(CancellationToken cancellationToken = default);

    void Add(VisitorCardAssignment assignment);
}
