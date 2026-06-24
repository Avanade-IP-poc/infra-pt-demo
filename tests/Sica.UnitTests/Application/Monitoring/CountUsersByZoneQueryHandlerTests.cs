using FluentAssertions;
using NSubstitute;
using Sica.Application.Integration.Smi;
using Sica.Application.Monitoring.CountUsersByZone;
using Xunit;

namespace Sica.UnitTests.Application.Monitoring;

public sealed class CountUsersByZoneQueryHandlerTests
{
    private readonly ISmiService _smi = Substitute.For<ISmiService>();

    [Fact]
    public async Task HandleAsync_ProjectsZoneOccupancy()
    {
        _smi.CountUsersByZoneAsync(Arg.Any<CancellationToken>())
            .Returns(new List<SmiZone>
            {
                new(100, "Receção", 3),
                new(102, "Datacenter", 1),
            });

        var handler = new CountUsersByZoneQueryHandler(_smi);

        var result = await handler.HandleAsync(new CountUsersByZoneQuery());

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().HaveCount(2);
        result.Value[0].Should().Be(new ZoneOccupancyDto(100, "Receção", 3));
        result.Value[1].Should().Be(new ZoneOccupancyDto(102, "Datacenter", 1));
    }

    [Fact]
    public async Task HandleAsync_WhenNoZones_ReturnsEmptyList()
    {
        _smi.CountUsersByZoneAsync(Arg.Any<CancellationToken>())
            .Returns(new List<SmiZone>());

        var handler = new CountUsersByZoneQueryHandler(_smi);

        var result = await handler.HandleAsync(new CountUsersByZoneQuery());

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().BeEmpty();
    }
}
