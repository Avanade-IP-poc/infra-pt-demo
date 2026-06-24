using Sica.Application.Abstractions;
using Sica.Domain.Cards;
using Sica.Shared;

namespace Sica.Application.Cards.RecordVisitorExit;

/// <summary>Records a visitor exit on an open assignment (RULE-008).</summary>
public sealed class RecordVisitorExitCommandHandler(
    IVisitorCardAssignmentRepository assignments,
    IUnitOfWork unitOfWork,
    TimeProvider timeProvider)
    : ICommandHandler<RecordVisitorExitCommand>
{
    private readonly IVisitorCardAssignmentRepository _assignments =
        Guard.AgainstNull(assignments, nameof(assignments));
    private readonly IUnitOfWork _unitOfWork = Guard.AgainstNull(unitOfWork, nameof(unitOfWork));
    private readonly TimeProvider _timeProvider = Guard.AgainstNull(timeProvider, nameof(timeProvider));

    public async Task<Result> HandleAsync(
        RecordVisitorExitCommand command,
        CancellationToken cancellationToken = default)
    {
        var assignment = await _assignments.GetByIdAsync(
            new VisitorCardAssignmentId(command.AssignmentId),
            cancellationToken);

        if (assignment is null)
        {
            return Result.Failure(CardErrors.AssignmentNotFound);
        }

        var exitResult = assignment.RecordExit(_timeProvider.GetUtcNow().UtcDateTime);
        if (exitResult.IsFailure)
        {
            return exitResult;
        }

        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
