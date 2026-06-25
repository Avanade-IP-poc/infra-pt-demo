using FluentAssertions;
using Sica.Domain.Primitives;
using Xunit;

namespace Sica.UnitTests.Domain;

public sealed class ValueObjectTests
{
    private sealed class Money(decimal amount, string currency) : ValueObject
    {
        public decimal Amount { get; } = amount;

        public string Currency { get; } = currency;

        protected override IEnumerable<object?> GetEqualityComponents()
        {
            yield return Amount;
            yield return Currency;
        }
    }

    [Fact]
    public void Equals_WithSameComponents_ShouldBeEqual()
    {
        var a = new Money(10m, "EUR");
        var b = new Money(10m, "EUR");

        a.Should().Be(b);
        (a == b).Should().BeTrue();
        a.GetHashCode().Should().Be(b.GetHashCode());
    }

    [Fact]
    public void Equals_WithDifferentComponents_ShouldNotBeEqual()
    {
        var a = new Money(10m, "EUR");
        var b = new Money(10m, "USD");

        a.Should().NotBe(b);
        (a != b).Should().BeTrue();
    }
}
