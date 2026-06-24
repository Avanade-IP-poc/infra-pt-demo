using FluentAssertions;
using Sica.Shared;
using Xunit;

namespace Sica.UnitTests.Shared;

public sealed class ResultTests
{
    [Fact]
    public void Success_ShouldHaveNoError()
    {
        var result = Result.Success();

        result.IsSuccess.Should().BeTrue();
        result.IsFailure.Should().BeFalse();
        result.Error.Should().Be(Error.None);
    }

    [Fact]
    public void Failure_ShouldCarryError()
    {
        var error = Error.Validation("invalid input");

        var result = Result.Failure(error);

        result.IsSuccess.Should().BeFalse();
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Be(error);
    }

    [Fact]
    public void SuccessWithValue_ShouldExposeValue()
    {
        var result = Result.Success(42);

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().Be(42);
    }

    [Fact]
    public void FailureWithValue_AccessingValue_ShouldThrow()
    {
        Result<int> result = Error.NotFound("missing");

        var act = () => result.Value;

        act.Should().Throw<InvalidOperationException>();
    }

    [Fact]
    public void ImplicitConversion_FromValue_ShouldProduceSuccess()
    {
        Result<string> result = "card-123";

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().Be("card-123");
    }

    [Fact]
    public void ImplicitConversion_FromError_ShouldProduceFailure()
    {
        Result<string> result = Error.Conflict("duplicate");

        result.IsFailure.Should().BeTrue();
        result.Error.Code.Should().Be("General.Conflict");
    }

    [Fact]
    public void Success_WithError_ShouldThrow()
    {
        var act = () => Result.Failure(Error.None);

        act.Should().Throw<InvalidOperationException>();
    }
}
