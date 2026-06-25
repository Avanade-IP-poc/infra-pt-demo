using FluentAssertions;
using NSubstitute;
using Sica.Application.Abstractions;
using Sica.Application.Cards.AssignVisitorCard;
using Sica.Domain.Cards;
using Sica.UnitTests.TestDoubles;
using Xunit;

namespace Sica.UnitTests.Application.Cards;

public sealed class AssignVisitorCardCommandHandlerTests
{
    private readonly ISmartCardRepository _cards = Substitute.For<ISmartCardRepository>();
    private readonly IVisitorCardAssignmentRepository _assignments =
        Substitute.For<IVisitorCardAssignmentRepository>();
    private readonly IUnitOfWork _unitOfWork = Substitute.For<IUnitOfWork>();
    private readonly FixedTimeProvider _clock =
        new(new DateTimeOffset(2026, 06, 24, 9, 0, 0, TimeSpan.Zero));

    private AssignVisitorCardCommandHandler CreateHandler()
        => new(_cards, _assignments, _unitOfWork, _clock);

    private static AssignVisitorCardCommand ValidCommand(Guid cardId) => new(
        cardId,
        Guid.NewGuid(),
        "John",
        "Doe",
        "Empresa XYZ",
        "Departamento IT",
        "12-AB-34",
        [Guid.NewGuid()],
        new DateTime(2026, 06, 24, 8, 0, 0, DateTimeKind.Utc),
        new DateTime(2026, 06, 24, 18, 0, 0, DateTimeKind.Utc));

    [Fact]
    public async Task HandleAsync_WithAvailableVisitorCard_ShouldAssignAndPersist()
    {
        var card = SmartCard.Create(CardCode.Create("V001"));
        _cards.GetByIdAsync(card.Id, Arg.Any<CancellationToken>()).Returns(card);
        _assignments.GetCardIdsInUseAsync(Arg.Any<CancellationToken>()).Returns([]);

        var result = await CreateHandler().HandleAsync(ValidCommand(card.Id.Value));

        result.IsSuccess.Should().BeTrue();
        result.Value.EntryTime.Should().Be(_clock.GetUtcNow().UtcDateTime);
        card.IsActive.Should().BeTrue();
        _assignments.Received(1).Add(Arg.Any<VisitorCardAssignment>());
        await _unitOfWork.Received(1).SaveChangesAsync(Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task HandleAsync_WhenCardNotFound_ShouldFail()
    {
        var cardId = Guid.NewGuid();
        _cards.GetByIdAsync(Arg.Any<CardId>(), Arg.Any<CancellationToken>())
            .Returns((SmartCard?)null);

        var result = await CreateHandler().HandleAsync(ValidCommand(cardId));

        result.IsFailure.Should().BeTrue();
        result.Error.Code.Should().Be("Card.NotFound");
        await _unitOfWork.DidNotReceive().SaveChangesAsync(Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task HandleAsync_WhenCardIsNotVisitor_ShouldFail()
    {
        var card = SmartCard.Create(CardCode.Create("C001"));
        _cards.GetByIdAsync(card.Id, Arg.Any<CancellationToken>()).Returns(card);

        var result = await CreateHandler().HandleAsync(ValidCommand(card.Id.Value));

        result.IsFailure.Should().BeTrue();
        result.Error.Code.Should().Be("VisitorCard.NoCardSelected");
    }

    [Fact]
    public async Task HandleAsync_WhenCardInUse_ShouldFail()
    {
        var card = SmartCard.Create(CardCode.Create("V001"));
        _cards.GetByIdAsync(card.Id, Arg.Any<CancellationToken>()).Returns(card);
        _assignments.GetCardIdsInUseAsync(Arg.Any<CancellationToken>()).Returns([card.Id]);

        var result = await CreateHandler().HandleAsync(ValidCommand(card.Id.Value));

        result.IsFailure.Should().BeTrue();
        result.Error.Code.Should().Be("Card.NotAvailable");
    }
}
