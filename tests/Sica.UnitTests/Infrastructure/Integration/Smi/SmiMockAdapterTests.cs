using FluentAssertions;
using Sica.Application.Integration.Smi;
using Sica.Infrastructure.Integration.Smi;
using Xunit;

namespace Sica.UnitTests.Infrastructure.Integration.Smi;

public sealed class SmiMockAdapterTests
{
    private readonly SmiMockAdapter _adapter = new();

    [Fact]
    public async Task GetSmartCardById_WhenKnown_ShouldReturnCard()
    {
        var card = await _adapter.GetSmartCardByIdAsync(1001);

        card.Should().NotBeNull();
        card!.LogicalCode.Should().Be("C001");
        card.Status.Should().Be(SmiSmartCardStatus.Active);
    }

    [Fact]
    public async Task GetSmartCardById_WhenUnknown_ShouldReturnNull()
    {
        var card = await _adapter.GetSmartCardByIdAsync(999_999);

        card.Should().BeNull();
    }

    [Fact]
    public async Task GetExternalSmartCards_ShouldReturnAllSeededCards()
    {
        var cards = await _adapter.GetExternalSmartCardsAsync();

        cards.Should().HaveCount(3);
    }

    [Fact]
    public async Task UpdateSmartCard_WhenKnown_ShouldPersistStatusAndExpiration()
    {
        var newExpiration = new DateTime(2030, 01, 01);

        var updated = await _adapter.UpdateSmartCardAsync(1001, newExpiration, SmiSmartCardStatus.Lost);

        updated.Should().BeTrue();
        var card = await _adapter.GetSmartCardByIdAsync(1001);
        card!.Status.Should().Be(SmiSmartCardStatus.Lost);
        card.ExpirationDate.Should().Be(newExpiration);
    }

    [Fact]
    public async Task UpdateSmartCard_WhenUnknown_ShouldReturnFalse()
    {
        var updated = await _adapter.UpdateSmartCardAsync(
            999_999, DateTime.UtcNow, SmiSmartCardStatus.Active);

        updated.Should().BeFalse();
    }

    [Fact]
    public async Task GetFamilies_ShouldReturnSeededFamilies()
    {
        var families = await _adapter.GetFamiliesAsync();

        families.Should().HaveCount(4);
        families.Should().Contain(f => f.Label == "Visitantes");
    }

    [Fact]
    public async Task GetCircuits_ShouldReturnSeededCircuits()
    {
        var circuits = await _adapter.GetCircuitsAsync();

        circuits.Should().HaveCount(3);
        circuits.Should().Contain(c => c.IpAddress == "192.168.10.12");
    }

    [Fact]
    public async Task CountUsersByZone_ShouldReturnSeededZones()
    {
        var zones = await _adapter.CountUsersByZoneAsync();

        zones.Should().HaveCount(3);
        zones.Sum(z => z.UserCount).Should().Be(16);
    }

    [Fact]
    public async Task GetLastCircuitEvents_ShouldFilterByCircuit()
    {
        var events = await _adapter.GetLastCircuitEventsAsync([12], lastHours: 24, maxRecords: 50);

        events.Should().OnlyContain(e => e.CircuitId == 12);
        events.Should().HaveCount(1);
    }

    [Fact]
    public async Task GetLastCircuitEvents_WithNoCircuitFilter_ShouldReturnRecentEventsOrdered()
    {
        var events = await _adapter.GetLastCircuitEventsAsync([], lastHours: 24, maxRecords: 50);

        events.Should().HaveCount(3);
        events.Should().BeInDescendingOrder(e => e.Timestamp);
    }

    [Fact]
    public async Task GetLastCircuitEvents_ShouldRespectMaxRecords()
    {
        var events = await _adapter.GetLastCircuitEventsAsync([], lastHours: 24, maxRecords: 1);

        events.Should().HaveCount(1);
    }
}
