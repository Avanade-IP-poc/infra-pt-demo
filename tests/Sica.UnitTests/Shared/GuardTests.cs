using FluentAssertions;
using Sica.Shared;
using Xunit;

namespace Sica.UnitTests.Shared;

public sealed class GuardTests
{
    [Fact]
    public void AgainstNull_WithValue_ShouldReturnValue()
    {
        var value = new object();

        Guard.AgainstNull(value, nameof(value)).Should().BeSameAs(value);
    }

    [Fact]
    public void AgainstNull_WithNull_ShouldThrow()
    {
        var act = () => Guard.AgainstNull<object>(null, "param");

        act.Should().Throw<ArgumentNullException>().WithParameterName("param");
    }

    [Theory]
    [InlineData("")]
    [InlineData("   ")]
    [InlineData(null)]
    public void AgainstNullOrWhiteSpace_WithInvalid_ShouldThrow(string? value)
    {
        var act = () => Guard.AgainstNullOrWhiteSpace(value, "param");

        act.Should().Throw<ArgumentException>().WithParameterName("param");
    }

    [Fact]
    public void AgainstNullOrWhiteSpace_WithValue_ShouldReturnValue()
    {
        Guard.AgainstNullOrWhiteSpace("term01", "param").Should().Be("term01");
    }

    [Fact]
    public void AgainstNegative_WithNegative_ShouldThrow()
    {
        var act = () => Guard.AgainstNegative(-1, "param");

        act.Should().Throw<ArgumentOutOfRangeException>().WithParameterName("param");
    }

    [Fact]
    public void AgainstNegativeOrZero_WithZero_ShouldThrow()
    {
        var act = () => Guard.AgainstNegativeOrZero(0, "param");

        act.Should().Throw<ArgumentOutOfRangeException>().WithParameterName("param");
    }

    [Fact]
    public void AgainstNegativeOrZero_WithPositive_ShouldReturnValue()
    {
        Guard.AgainstNegativeOrZero(5, "param").Should().Be(5);
    }
}
