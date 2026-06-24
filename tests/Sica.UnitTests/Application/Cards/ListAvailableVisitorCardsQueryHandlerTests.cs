using FluentAssertions;
using NSubstitute;
using Sica.Application.Abstractions;
using Sica.Application.Cards.ListAvailableVisitorCards;
using Sica.Domain.Cards;
using Xunit;

namespace Sica.UnitTests.Application.Cards;

public sealed class ListAvailableVisitorCardsQueryHandlerTests
{
    private readonly ISmartCardRepository _cards = Substitute.For<ISmartCardRepository>();
    private readonly IVisitorCardAssignmentRepository _assignments =
        Substitute.For<IVisitorCardAssignmentRepository>();

    private ListAvailableVisitorCardsQueryHandler CreateHandler() => new(_cards, _assignments);

    [Fact]
    public async Task HandleAsync_ShouldExcludeInUseAndInactiveCards()
    {
        var free = SmartCard.Create(CardCode.Create("V001"));
        var inUse = SmartCard.Create(CardCode.Create("V002"));
        var inactive = SmartCard.Create(CardCode.Create("V003"));
        inactive.Deactivate();

        _cards.ListByTypeAsync(CardType.Visitor, Arg.Any<CancellationToken>())
            .Returns(new[] { free, inUse, inactive });
        _assignments.GetCardIdsInUseAsync(Arg.Any<CancellationToken>())
            .Returns([inUse.Id]);
        _assignments.GetLatestForCardAsync(free.Id, Arg.Any<CancellationToken>())
            .Returns((VisitorCardAssignment?)null);

        var result = await CreateHandler().HandleAsync(new ListAvailableVisitorCardsQuery());

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().ContainSingle()
            .Which.CardId.Should().Be(free.Id.Value);
    }

    [Fact]
    public async Task HandleAsync_WhenNoVisitorCards_ShouldReturnEmpty()
    {
        _cards.ListByTypeAsync(CardType.Visitor, Arg.Any<CancellationToken>())
            .Returns([]);
        _assignments.GetCardIdsInUseAsync(Arg.Any<CancellationToken>())
            .Returns([]);

        var result = await CreateHandler().HandleAsync(new ListAvailableVisitorCardsQuery());

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().BeEmpty();
    }
}
