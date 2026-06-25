using FluentAssertions;
using Sica.Domain.Cards;
using Xunit;

namespace Sica.UnitTests.Domain.Cards;

public sealed class CardCodeTests
{
    [Theory]
    [InlineData("V001", CardType.Visitor)]
    [InlineData("v123", CardType.Visitor)]
    [InlineData("M500", CardType.Service)]
    [InlineData("C010", CardType.Employee)]
    [InlineData("A001", CardType.Employee)]
    [InlineData("R007", CardType.Employee)]
    [InlineData("E042", CardType.Employee)]
    [InlineData("X999", CardType.Visitor)]
    public void ClassifyType_ShouldDeriveTypeFromPrefix(string code, CardType expected)
    {
        CardCode.Create(code).ClassifyType().Should().Be(expected);
    }

    [Fact]
    public void Create_ShouldNormalizeToUpperCase()
    {
        CardCode.Create("  v001 ").Value.Should().Be("V001");
    }

    [Theory]
    [InlineData("C001", true)]
    [InlineData("V001", true)]
    [InlineData("M001", true)]
    [InlineData("A001", true)]
    [InlineData("R001", true)]
    [InlineData("E001", false)]
    [InlineData("X001", false)]
    public void IsSyncable_ShouldHonorAllowedPrefixes(string code, bool expected)
    {
        CardCode.Create(code).IsSyncable().Should().Be(expected);
    }

    [Fact]
    public void Create_WithBlank_ShouldThrow()
    {
        var act = () => CardCode.Create("  ");
        act.Should().Throw<ArgumentException>();
    }
}
