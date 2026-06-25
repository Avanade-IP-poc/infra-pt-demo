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

    /// <summary>
    /// Returns visitor assignments optionally filtered by completion state.
    /// When <paramref name="active"/> is <c>true</c>, only open assignments are returned.
    /// When <paramref name="active"/> is <c>false</c>, only completed assignments are returned.
    /// When <paramref name="active"/> is <c>null</c>, all assignments are returned.
    /// </summary>
    Task<IReadOnlyList<VisitorCardAssignment>> ListAsync(
        bool? active,
        CancellationToken cancellationToken = default);

    void Add(VisitorCardAssignment assignment);
}
