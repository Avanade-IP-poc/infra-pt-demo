using Sica.Application.Abstractions;
using Sica.Domain.Cards;
using Sica.Shared;

namespace Sica.Application.Cards.AssignVisitorCard;

/// <summary>
/// RULE-009: validates the card, visitor identification and access family before
/// creating a visitor card assignment, recording the entry timestamp. The card must
/// exist, be a Visitor card and not be currently in use (RULE-008).
/// </summary>
public sealed class AssignVisitorCardCommandHandler(
    ISmartCardRepository cards,
    IVisitorCardAssignmentRepository assignments,
    IUnitOfWork unitOfWork,
    TimeProvider timeProvider)
    : ICommandHandler<AssignVisitorCardCommand, AssignVisitorCardResult>
{
    private readonly ISmartCardRepository _cards = Guard.AgainstNull(cards, nameof(cards));
    private readonly IVisitorCardAssignmentRepository _assignments =
        Guard.AgainstNull(assignments, nameof(assignments));
    private readonly IUnitOfWork _unitOfWork = Guard.AgainstNull(unitOfWork, nameof(unitOfWork));
    private readonly TimeProvider _timeProvider = Guard.AgainstNull(timeProvider, nameof(timeProvider));

    public async Task<Result<AssignVisitorCardResult>> HandleAsync(
        AssignVisitorCardCommand command,
        CancellationToken cancellationToken = default)
    {
        var card = await _cards.GetByIdAsync(new CardId(command.CardId), cancellationToken);
        if (card is null)
        {
            return CardErrors.CardNotFound;
        }

        if (card.Type != CardType.Visitor)
        {
            return CardErrors.NoCardSelected;
        }

        var inUse = await _assignments.GetCardIdsInUseAsync(cancellationToken);
        if (inUse.Contains(card.Id))
        {
            return CardErrors.CardNotAvailable;
        }

        var entryTime = _timeProvider.GetUtcNow().UtcDateTime;

        var assignmentResult = VisitorCardAssignment.Assign(
            card.Id,
            command.VisitorId,
            command.Company,
            command.VisitedEntity,
            command.VehiclePlate,
            command.AccessFamilyIds,
            command.ValidFrom,
            command.ValidUntil,
            entryTime);

        if (assignmentResult.IsFailure)
        {
            return assignmentResult.Error;
        }

        var assignment = assignmentResult.Value;

        card.Activate();
        _assignments.Add(assignment);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return new AssignVisitorCardResult(assignment.Id.Value, entryTime);
    }
}
