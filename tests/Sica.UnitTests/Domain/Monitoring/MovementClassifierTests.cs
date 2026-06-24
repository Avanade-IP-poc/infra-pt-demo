using FluentAssertions;
using Sica.Domain.Monitoring;
using Xunit;

namespace Sica.UnitTests.Domain.Monitoring;

public sealed class MovementClassifierTests
{
    [Theory]
    [InlineData("Entrada Principal", 0)]
    [InlineData("ENTRADA Lateral", 2)]
    [InlineData("entrada de serviço", 9)]
    public void Classify_WhenDescriptionContainsEntrada_ReturnsEntry(string description, int parameter)
    {
        MovementClassifier.Classify(description, parameter).Should().Be(AccessEventType.Entry);
    }

    [Theory]
    [InlineData("Saída Datacenter", 0)]
    [InlineData("SALIDA Garaje", 1)]
    [InlineData("saida de emergência", 9)]
    public void Classify_WhenDescriptionContainsSalida_ReturnsExit(string description, int parameter)
    {
        MovementClassifier.Classify(description, parameter).Should().Be(AccessEventType.Exit);
    }

    [Fact]
    public void Classify_WhenDescriptionWins_OverridesContradictoryParameter()
    {
        // Description says Entrada but parameter says Exit (2): description wins.
        MovementClassifier.Classify("Entrada Principal", 2).Should().Be(AccessEventType.Entry);
    }

    [Theory]
    [InlineData(1, AccessEventType.Entry)]
    [InlineData(2, AccessEventType.Exit)]
    public void Classify_WhenDescriptionUnknown_FallsBackToParameter(int parameter, AccessEventType expected)
    {
        MovementClassifier.Classify("Sala Servidores", parameter).Should().Be(expected);
    }

    [Theory]
    [InlineData("Sala Servidores", 0)]
    [InlineData("Receção", 9)]
    [InlineData(null, 0)]
    [InlineData("", 7)]
    public void Classify_WhenNeitherDescriptionNorParameterMatch_ReturnsUnknown(string? description, int parameter)
    {
        MovementClassifier.Classify(description, parameter).Should().Be(AccessEventType.Unknown);
    }
}
