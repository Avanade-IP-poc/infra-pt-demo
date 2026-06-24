using FluentAssertions;
using Sica.Domain.Cards;
using Xunit;

namespace Sica.UnitTests.Domain.Cards;

public sealed class SmartCardTests
{
    [Fact]
    public void Create_ShouldClassifyTypeFromCode()
    {
        var card = SmartCard.Create(CardCode.Create("V001"));

        card.Type.Should().Be(CardType.Visitor);
        card.Status.Should().Be(CardStatus.Active);
        card.Id.Value.Should().NotBe(Guid.Empty);
    }

    [Fact]
    public void SyncFromMaster_WithSyncablePrefix_ShouldSucceed()
    {
        var result = SmartCard.SyncFromMaster(
            CardCode.Create("C001"), smiCardId: 42, label: "Corp", CardStatus.Active, expirationDate: null);

        result.IsSuccess.Should().BeTrue();
        result.Value.SmiCardId.Should().Be(42);
        result.Value.Type.Should().Be(CardType.Employee);
    }

    [Fact]
    public void SyncFromMaster_WithNonSyncablePrefix_ShouldFail()
    {
        var result = SmartCard.SyncFromMaster(
            CardCode.Create("X001"), smiCardId: 1, label: null, CardStatus.Active, expirationDate: null);

        result.IsFailure.Should().BeTrue();
        result.Error.Code.Should().Be("Card.NotSyncable");
    }

    [Fact]
    public void DeactivateAndActivate_ShouldToggleStatus()
    {
        var card = SmartCard.Create(CardCode.Create("V001"));

        card.Deactivate();
        card.IsActive.Should().BeFalse();

        card.Activate();
        card.IsActive.Should().BeTrue();
    }
}
