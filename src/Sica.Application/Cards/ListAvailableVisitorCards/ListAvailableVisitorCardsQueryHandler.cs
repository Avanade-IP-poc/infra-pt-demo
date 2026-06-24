using Sica.Application.Abstractions;
using Sica.Domain.Cards;
using Sica.Shared;

namespace Sica.Application.Cards.ListAvailableVisitorCards;

/// <summary>
/// RULE-008: a visitor card is available when it has never been assigned or its
/// latest assignment has a recorded exit time. Cards with an open assignment
/// (entry without exit) are excluded.
/// </summary>
public sealed class ListAvailableVisitorCardsQueryHandler(
    ISmartCardRepository cards,
    IVisitorCardAssignmentRepository assignments)
    : IQueryHandler<ListAvailableVisitorCardsQuery, IReadOnlyList<AvailableVisitorCard>>
{
    private readonly ISmartCardRepository _cards = Guard.AgainstNull(cards, nameof(cards));
    private readonly IVisitorCardAssignmentRepository _assignments =
        Guard.AgainstNull(assignments, nameof(assignments));

    public async Task<Result<IReadOnlyList<AvailableVisitorCard>>> HandleAsync(
        ListAvailableVisitorCardsQuery query,
        CancellationToken cancellationToken = default)
    {
        var visitorCards = await _cards.ListByTypeAsync(CardType.Visitor, cancellationToken);
        var inUse = await _assignments.GetCardIdsInUseAsync(cancellationToken);
        var inUseSet = inUse.ToHashSet();

        var available = new List<AvailableVisitorCard>();
        foreach (var card in visitorCards)
        {
            if (inUseSet.Contains(card.Id) || card.Status != CardStatus.Active)
            {
                continue;
            }

            var latest = await _assignments.GetLatestForCardAsync(card.Id, cancellationToken);
            available.Add(new AvailableVisitorCard(
                card.Id.Value,
                card.Code.Value,
                card.Label,
                latest?.ExitTime));
        }

        return available;
    }
}
