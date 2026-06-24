using FluentAssertions;
using NSubstitute;
using Sica.Application.Abstractions;
using Sica.Application.Cards.RecordVisitorExit;
using Sica.Domain.Cards;
using Sica.UnitTests.TestDoubles;
using Xunit;

namespace Sica.UnitTests.Application.Cards;

public sealed class RecordVisitorExitCommandHandlerTests
{
    private readonly IVisitorCardAssignmentRepository _assignments =
        Substitute.For<IVisitorCardAssignmentRepository>();
    private readonly IUnitOfWork _unitOfWork = Substitute.For<IUnitOfWork>();
    private readonly FixedTimeProvider _clock =
        new(new DateTimeOffset(2026, 06, 24, 18, 0, 0, TimeSpan.Zero));

    private RecordVisitorExitCommandHandler CreateHandler()
        => new(_assignments, _unitOfWork, _clock);

    private static VisitorCardAssignment OpenAssignment()
        => VisitorCardAssignment.Assign(
            CardId.New(),
            Guid.NewGuid(),
            "Empresa",
            "IT",
            null,
            [Guid.NewGuid()],
            new DateTime(2026, 06, 24, 8, 0, 0, DateTimeKind.Utc),
            new DateTime(2026, 06, 24, 20, 0, 0, DateTimeKind.Utc),
            new DateTime(2026, 06, 24, 9, 0, 0, DateTimeKind.Utc)).Value;

    [Fact]
    public async Task HandleAsync_OnOpenAssignment_ShouldRecordExit()
    {
        var assignment = OpenAssignment();
        _assignments.GetByIdAsync(assignment.Id, Arg.Any<CancellationToken>())
            .Returns(assignment);

        var result = await CreateHandler().HandleAsync(
            new RecordVisitorExitCommand(assignment.Id.Value));

        result.IsSuccess.Should().BeTrue();
        assignment.IsCompleted.Should().BeTrue();
        await _unitOfWork.Received(1).SaveChangesAsync(Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task HandleAsync_WhenAssignmentNotFound_ShouldFail()
    {
        _assignments.GetByIdAsync(Arg.Any<VisitorCardAssignmentId>(), Arg.Any<CancellationToken>())
            .Returns((VisitorCardAssignment?)null);

        var result = await CreateHandler().HandleAsync(
            new RecordVisitorExitCommand(Guid.NewGuid()));

        result.IsFailure.Should().BeTrue();
        result.Error.Code.Should().Be("VisitorCard.AssignmentNotFound");
        await _unitOfWork.DidNotReceive().SaveChangesAsync(Arg.Any<CancellationToken>());
    }
}
