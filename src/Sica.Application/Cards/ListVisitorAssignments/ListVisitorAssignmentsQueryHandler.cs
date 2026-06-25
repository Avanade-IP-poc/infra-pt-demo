using Sica.Application.Abstractions;
using Sica.Domain.Cards;
using Sica.Shared;

namespace Sica.Application.Cards.ListVisitorAssignments;

/// <summary>Projects visitor assignments to a UI-friendly read model.</summary>
public sealed class ListVisitorAssignmentsQueryHandler(
    IVisitorCardAssignmentRepository assignments,
    ISmartCardRepository cards)
    : IQueryHandler<ListVisitorAssignmentsQuery, IReadOnlyList<VisitorAssignmentDto>>
{
    private readonly IVisitorCardAssignmentRepository _assignments =
        Guard.AgainstNull(assignments, nameof(assignments));
    private readonly ISmartCardRepository _cards = Guard.AgainstNull(cards, nameof(cards));

    public async Task<Result<IReadOnlyList<VisitorAssignmentDto>>> HandleAsync(
        ListVisitorAssignmentsQuery query,
        CancellationToken cancellationToken = default)
    {
        var assignments = await _assignments.ListAsync(query.Active, cancellationToken);

        var result = new List<VisitorAssignmentDto>(assignments.Count);
        foreach (var assignment in assignments)
        {
            var card = await _cards.GetByIdAsync(assignment.CardId, cancellationToken);
            var cardCode = card?.Code.Value ?? assignment.CardId.Value.ToString();

            result.Add(new VisitorAssignmentDto(
                assignment.Id.Value,
                assignment.CardId.Value,
                cardCode,
                assignment.VisitorId,
                assignment.Company,
                assignment.VisitedEntity,
                assignment.VehiclePlate,
                [.. assignment.AccessFamilyIds],
                assignment.ValidFrom,
                assignment.ValidUntil,
                assignment.EntryTime,
                assignment.ExitTime,
                assignment.IsCompleted));
        }

        return result;
    }
}
