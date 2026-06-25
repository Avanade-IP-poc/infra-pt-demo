using FluentAssertions;
using NSubstitute;
using Sica.Application.Integration.Smi;
using Sica.Application.Monitoring.ListAccessEvents;
using Xunit;

namespace Sica.UnitTests.Application.Monitoring;

public sealed class ListAccessEventsQueryHandlerTests
{
    private readonly ISmiService _smi = Substitute.For<ISmiService>();

    private ListAccessEventsQueryHandler CreateHandler() => new(_smi);

    [Fact]
    public async Task HandleAsync_MapsAndClassifiesEvents()
    {
        _smi.GetLastCircuitEventsAsync(Arg.Any<IReadOnlyCollection<int>>(), Arg.Any<int>(), Arg.Any<int>(), Arg.Any<CancellationToken>())
            .Returns(new List<SmiAccessEvent>
            {
                new(DateTime.UtcNow, "João", 2, "Funcionários", 1, "Acme", "C001", 1, "Entrada", 100, "Receção", 10, "Entrada Principal"),
                new(DateTime.UtcNow, "Pedro", 4, "Manutenção", 1, "Acme", "M001", 2, "Saída", 102, "Datacenter", 12, "Sala Servidores"),
            });

        var result = await CreateHandler().HandleAsync(new ListAccessEventsQuery(10));

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().HaveCount(2);
        result.Value[0].EventType.Should().Be("Entry");
        result.Value[0].CardCode.Should().Be("C001");
        result.Value[0].CircuitName.Should().Be("Entrada Principal");
        result.Value[1].EventType.Should().Be("Exit");
    }

    [Fact]
    public async Task HandleAsync_ClampsHoursAndMaxEventsToSupportedRanges()
    {
        _smi.GetLastCircuitEventsAsync(Arg.Any<IReadOnlyCollection<int>>(), Arg.Any<int>(), Arg.Any<int>(), Arg.Any<CancellationToken>())
            .Returns(new List<SmiAccessEvent>());

        await CreateHandler().HandleAsync(new ListAccessEventsQuery(10, Hours: 1000, MaxEvents: 5000));

        await _smi.Received(1).GetLastCircuitEventsAsync(
            Arg.Is<IReadOnlyCollection<int>>(c => c.Contains(10)),
            168,
            100,
            Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task HandleAsync_WhenNoEvents_ReturnsEmptyList()
    {
        _smi.GetLastCircuitEventsAsync(Arg.Any<IReadOnlyCollection<int>>(), Arg.Any<int>(), Arg.Any<int>(), Arg.Any<CancellationToken>())
            .Returns(new List<SmiAccessEvent>());

        var result = await CreateHandler().HandleAsync(new ListAccessEventsQuery(10));

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().BeEmpty();
    }
}
