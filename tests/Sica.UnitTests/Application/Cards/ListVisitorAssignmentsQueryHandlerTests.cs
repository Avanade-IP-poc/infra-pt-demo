using FluentAssertions;
using NSubstitute;
using Sica.Application.Cards.ListVisitorAssignments;
using Sica.Domain.Cards;
using Xunit;

namespace Sica.UnitTests.Application.Cards;

public sealed class ListVisitorAssignmentsQueryHandlerTests
{
    private readonly IVisitorCardAssignmentRepository _assignments =
        Substitute.For<IVisitorCardAssignmentRepository>();
    private readonly ISmartCardRepository _cards = Substitute.For<ISmartCardRepository>();

    private ListVisitorAssignmentsQueryHandler CreateHandler() => new(_assignments, _cards);

    [Fact]
    public async Task HandleAsync_ShouldMapAssignmentsToDtos()
    {
        var assignment = VisitorCardAssignment.Assign(
            CardId.New(),
            Guid.NewGuid(),
            "Empresa",
            "IT",
            null,
            [Guid.NewGuid()],
            new DateTime(2026, 06, 25, 8, 0, 0, DateTimeKind.Utc),
            new DateTime(2026, 06, 25, 18, 0, 0, DateTimeKind.Utc),
            new DateTime(2026, 06, 25, 9, 0, 0, DateTimeKind.Utc)).Value;

        _assignments.ListAsync(true, Arg.Any<CancellationToken>())
            .Returns([assignment]);
        _cards.GetByIdAsync(assignment.CardId, Arg.Any<CancellationToken>())
            .Returns((SmartCard?)null);

        var result = await CreateHandler().HandleAsync(new ListVisitorAssignmentsQuery(1, true));

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().ContainSingle();
        result.Value[0].AssignmentId.Should().Be(assignment.Id.Value);
        result.Value[0].CardId.Should().Be(assignment.CardId.Value);
        result.Value[0].IsCompleted.Should().BeFalse();
        await _assignments.Received(1).ListAsync(true, Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task HandleAsync_WhenCardIsMissing_ShouldFallbackToCardIdAsCode()
    {
        var assignment = VisitorCardAssignment.Assign(
            CardId.New(),
            Guid.NewGuid(),
            "Empresa",
            null,
            null,
            [Guid.NewGuid()],
            new DateTime(2026, 06, 25, 8, 0, 0, DateTimeKind.Utc),
            new DateTime(2026, 06, 25, 18, 0, 0, DateTimeKind.Utc),
            new DateTime(2026, 06, 25, 9, 0, 0, DateTimeKind.Utc)).Value;

        _assignments.ListAsync(Arg.Any<bool?>(), Arg.Any<CancellationToken>())
            .Returns([assignment]);
        _cards.GetByIdAsync(assignment.CardId, Arg.Any<CancellationToken>())
            .Returns((SmartCard?)null);

        var result = await CreateHandler().HandleAsync(new ListVisitorAssignmentsQuery(null, null));

        result.IsSuccess.Should().BeTrue();
        result.Value[0].CardCode.Should().Be(assignment.CardId.Value.ToString());
    }
}
